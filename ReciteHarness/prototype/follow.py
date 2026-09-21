#!/usr/bin/env python3
"""Recitation follower, offline prototype.

Feeds a recording to the Tarteel Whisper model the way a live microphone would
(a growing signal, one pass per HOP seconds over the last WINDOW seconds), and
moves a cursor through the known text of the surah. Reports how far behind the
reciter the cursor runs, using MP3Quran's ayah timings as the truth.

  follow.py <reciter> <surah> [--model tarteel-ai/whisper-base-ar-quran]
"""
import argparse, glob, json, os, re, sys, time
import numpy as np
import soundfile as sf

HERE = os.path.dirname(os.path.abspath(__file__))
ERTAK = os.path.expanduser("~/ertak/public/mushaf/qaloun")
SR = 16000
STAR = "۞"

# ---------------------------------------------------------------- text

MARKS = re.compile("[ؐ-ًؚ-ٟۖ-ۭ࣓-ࣿـ‎‏]")
DROP = str.maketrans({
    "ا": "", "ٱ": "", "أ": "", "إ": "", "آ": "",   # alef and its hamza forms
    "ٰ": "",                                                        # dagger alef
    "ى": "", "ے": "",                                          # alef maqsura, the Qalun final ya
    "ء": "",                                                        # free-standing hamza
    "ؤ": "و", "ئ": "ي",                              # hamza on waw / ya
    "ة": "ه",                                                  # ta marbuta
    "ی": "ي", "ک": "ك",
})


def skel(word):
    """Consonant skeleton shared by the Uthmani Qalun spelling and an everyday one.

    Long a is written three ways (alef, dagger alef, a waw or ya carrying one), so
    every alef goes; a waw or ya that only carries a dagger alef goes with it.
    """
    w = re.sub("[ويى]ٰ", "", word)      # الصلوٰة -> الصلة, موسىٰ -> موس
    w = w.replace("ٰ", "")
    w = MARKS.sub("", w).translate(DROP)
    if len(w) > 1 and w.endswith("ي"):                 # في / فى / فے
        w = w[:-1]
    return w


def sim(a, b):
    """1 - normalised edit distance between two skeletons."""
    if a == b:
        return 1.0
    if not a or not b:
        return 0.0
    prev = list(range(len(b) + 1))
    for i, ca in enumerate(a, 1):
        cur = [i]
        for j, cb in enumerate(b, 1):
            cur.append(min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + (ca != cb)))
        prev = cur
    return 1.0 - prev[-1] / max(len(a), len(b))


def surah_words(surah):
    """[(ayah, word index in ayah (1-based, ertak rows), text)] in reading order; the star is skipped."""
    seen, out = set(), []
    for f in sorted(glob.glob(os.path.join(ERTAK, "*.json")), key=lambda p: int(os.path.basename(p)[:-5])):
        for a in json.load(open(f))["ayahs"]:
            if a["s"] != surah or a["id"] in seen:
                continue
            seen.add(a["id"])
            for i, t in enumerate(a["t"].split()):
                if t != STAR:
                    out.append((a["a"], i + 1, t))
    return out


# ---------------------------------------------------------------- follower

class Follower:
    """Cursor over the expected words, moved by successive hypotheses of the recent audio."""

    BACK, AHEAD = 6, 14          # window of expected words searched around the cursor
    OK = 0.72                    # skeleton similarity that counts as the same word
    FAR = 0.15                   # per word beyond the cursor, taken off a match
    SKIP = 0                     # unheard words one advance may pass over: none, a reader who leaves a word out is stopped

    def __init__(self, words):
        self.E = [skel(w) for w in words]
        self.cursor = 0          # index of the next word not yet recited
        self.when = [None] * len(words)

    def feed(self, hyp_words, now, final=False):
        H = [skel(w) for w in hyp_words]
        H = [h for h in H if h]
        if not final and H:
            # The last word of a live hypothesis is usually cut short. It stays only when it is
            # already, letter for letter, a word the text expects next.
            near = self.E[self.cursor: self.cursor + 3]
            if not (len(H[-1]) >= 3 and H[-1] in near):
                H = H[:-1]
        if not H:
            return
        lo, hi = max(0, self.cursor - self.BACK), min(len(self.E), self.cursor + self.AHEAD)
        E = self.E[lo:hi]
        # local alignment of H against E: consecutive matches score, gaps cost
        n, m = len(H), len(E)
        S = [[0.0] * (m + 1) for _ in range(n + 1)]
        P = [[None] * (m + 1) for _ in range(n + 1)]
        best, at = 0.0, None
        for i in range(1, n + 1):
            for j in range(1, m + 1):
                s = sim(H[i - 1], E[j - 1])
                # a match far beyond the cursor is worth less: the same phrase often returns
                # a few words later (67:16 / 67:17), and the reciter is at the nearer one
                far = self.FAR * max(0, lo + j - 1 - self.cursor)
                d = S[i - 1][j - 1] + (2.0 * s - far if s >= self.OK else -1.0)
                u = S[i - 1][j] - 0.7          # a heard word that is not in the text
                l = S[i][j - 1] - 0.7          # a text word that was not heard
                v, p = max(((d, "d"), (u, "u"), (l, "l"), (0.0, None)), key=lambda t: t[0])
                S[i][j], P[i][j] = v, p
                if v > best:
                    best, at = v, (i, j)
        if at is None:
            return
        i, j = at
        hits = []
        while i > 0 and j > 0 and P[i][j]:
            p = P[i][j]
            if p == "d":
                if sim(H[i - 1], E[j - 1]) >= self.OK:
                    hits.append(lo + j - 1)
                i, j = i - 1, j - 1
            elif p == "u":
                i -= 1
            else:
                j -= 1
        hits.reverse()
        if not hits:
            return
        # The recitation continues from the cursor, so the matches must too: walk them in
        # order and stop at the first that would leap over more than SKIP unheard words.
        reach, fresh = self.cursor, 0
        for h in hits:
            if h < reach:
                continue
            if h - reach > self.SKIP:
                break
            reach, fresh = h + 1, fresh + 1
        if fresh == 0:
            return
        # one new word needs support: an earlier match in the same hypothesis, or a long word
        anchored = any(h < self.cursor for h in hits) or fresh >= 2
        if not anchored and len(self.E[reach - 1]) < 4:
            return
        for k in range(self.cursor, reach):
            if self.when[k] is None:
                self.when[k] = now
        self.cursor = reach


# ---------------------------------------------------------------- run

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("reciter"); ap.add_argument("surah", type=int)
    ap.add_argument("--model", default="tarteel-ai/whisper-base-ar-quran")
    ap.add_argument("--base", default="openai/whisper-base", help="stock model whose generation config fits")
    ap.add_argument("--hop", type=float, default=0.5)
    ap.add_argument("--quiet", type=float, default=0.15, help="tail RMS under this share of the overall RMS is a pause")
    ap.add_argument("--window", type=float, default=10.0)
    ap.add_argument("--limit", type=float, default=0, help="seconds of audio to use (0 = all)")
    ap.add_argument("--show", type=int, default=0, help="print the first N hypotheses")
    ap.add_argument("--replay", action="store_true", help="reuse the hypotheses saved by an earlier full run")
    ap.add_argument("--trace", type=float, nargs=2, default=[-1, -1], help="print hypotheses between two times")
    a = ap.parse_args()

    stem = os.path.join(HERE, "audio", "%s-%03d" % (a.reciter, a.surah))
    if a.replay:
        return replay(a, stem)
    import torch
    from transformers import WhisperForConditionalGeneration, WhisperProcessor
    proc = WhisperProcessor.from_pretrained(a.model)
    model = WhisperForConditionalGeneration.from_pretrained(a.model).eval()
    dev = "mps" if torch.backends.mps.is_available() else "cpu"
    model.to(dev)
    # the fine-tune predates Whisper's generation_config (language / task tokens): borrow the stock one
    from transformers import GenerationConfig
    model.generation_config = GenerationConfig.from_pretrained(a.base)
    model.generation_config.forced_decoder_ids = None
    model.generation_config.max_length = None

    wav, sr = sf.read(stem + ".wav", dtype="float32")
    assert sr == SR
    if a.limit:
        wav = wav[: int(a.limit * SR)]
    words = surah_words(a.surah)
    F = Follower([w[2] for w in words])
    print("surah %d: %d words, %.0f s of audio, model %s on %s" % (a.surah, len(words), len(wav) / SR, a.model, dev))

    t, cost, shown, hyps = a.hop, [], 0, []
    total = len(wav) / SR
    peak = float(np.sqrt(np.mean(wav ** 2)))          # overall level, for the pause test
    while True:
        now = min(t, total)
        seg = wav[max(0, int((now - a.window) * SR)): int(now * SR)]
        t0 = time.time()
        feats = proc(seg, sampling_rate=SR, return_tensors="pt").input_features.to(dev)
        with torch.no_grad():
            ids = model.generate(feats, max_new_tokens=96, language="ar", task="transcribe")
        text = proc.batch_decode(ids, skip_special_tokens=True)[0]
        cost.append(time.time() - t0)
        if shown < a.show or a.trace[0] <= now <= a.trace[1]:
            print("  %6.1fs cursor %3d | %s" % (now, F.cursor, text)); shown += 1
        # a pause at the end of the window means the last word is complete
        tail = seg[-int(0.35 * SR):]
        quiet = len(tail) > 0 and float(np.sqrt(np.mean(tail ** 2))) < a.quiet * peak
        hyps.append([round(now, 2), bool(now >= total or quiet), text])
        F.feed(text.split(), now, final=now >= total or quiet)
        if now >= total:
            break
        t += a.hop

    if not a.limit:
        json.dump(hyps, open(stem + ".hyps.json", "w"), ensure_ascii=False)
    report(a, stem, words, F, total, cost)


def replay(a, stem):
    """Run the follower over hypotheses saved by an earlier run: no model needed."""
    words = surah_words(a.surah)
    F = Follower([w[2] for w in words])
    hyps = json.load(open(stem + ".hyps.json"))
    for now, final, text in hyps:
        if a.trace[0] <= now <= a.trace[1]:
            print("  %6.1fs cursor %3d | %s" % (now, F.cursor, text))
        F.feed(text.split(), now, final=final)
    report(a, stem, words, F, hyps[-1][0], [])
    json.dump({"words": [(w[0], w[1], w[2], F.when[k]) for k, w in enumerate(words)]},
              open(stem + ".follow.json", "w"), ensure_ascii=False)


def report(a, stem, words, F, total, cost):
    timing = json.load(open(stem + ".timing.json"))
    end_of = {r["ayah"]: r["end_time"] / 1000 for r in timing}
    lags, missing = [], 0
    last_idx = {}
    for k, (ay, _, _) in enumerate(words):
        last_idx[ay] = k
    for ay, k in sorted(last_idx.items()):
        if ay in end_of and end_of[ay] <= total:
            if F.when[k] is None:
                missing += 1
            else:
                lags.append(F.when[k] - end_of[ay])
    reached = sum(1 for w in F.when if w is not None)
    start_of = {r["ayah"]: r["start_time"] / 1000 for r in timing}
    early = [(ay, i, F.when[k] - start_of[ay]) for k, (ay, i, _) in enumerate(words)
             if F.when[k] is not None and ay in start_of and F.when[k] < start_of[ay] - 0.25]
    print("words shown before their ayah had begun: %d %s" % (len(early), [(a_, i, round(d, 1)) for a_, i, d in early[:8]]))
    print("cursor reached %d / %d words" % (F.cursor, len(words)))
    print("words given a time: %d" % reached)
    if lags:
        L = np.array(lags)
        print("ayah ends followed: %d, never reached: %d" % (len(L), missing))
        print("lag behind the reciter at ayah ends (s): median %.1f  p90 %.1f  max %.1f  min %.1f"
              % (np.median(L), np.percentile(L, 90), L.max(), L.min()))
    if cost:
        print("model pass: median %.2f s, p90 %.2f s (%d passes)" % (np.median(cost), np.percentile(cost, 90), len(cost)))
    json.dump({"words": [(w[0], w[1], w[2], F.when[k]) for k, w in enumerate(words)]},
              open(stem + ".follow.json", "w"), ensure_ascii=False)


if __name__ == "__main__":
    main()
