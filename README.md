# Qaloon — مصحف قالون (iPhone, iPad, Mac)

A stand-alone SwiftUI app for the riwāya of Qālūn ʿan Nāfiʿ: the mushaf page by page,
hide-to-memorise word by word, reciting aloud with the words appearing as they are said,
listening, and stats. No account. It talks to the page-image CDN, to MP3Quran, and — only
if you turn device sync on — to the Ertak server it was split from.

|               |                                                                                                                                                                                                                                     |
| ------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Pages         | King Fahd Complex Qaloun PNGs from `cdn.makeathar.com/kf/{n}.png`                                                                                                                                                                   |
| Ayah + word boxes | `Resources/layout.json`, built from the same data as the web app (word boxes from [qaloon-wordmap](https://github.com/hedi-ghodhbane/qaloon-wordmap)) |
| Turning pages | swipe (next page is to the left, like a book), ← → keys on Mac                                                                                                                                                                      |
| Hide mode     | covers the page under a faint dashed rule, keeping the ayah signs ۝ visible (switchable). Covers are per word, and words and ayahs are both in reach at once: «كلمة» / space lifts the next word, «آية» / return lifts the rest of the next ayah; a tap lifts a word, a tap on the ayah sign ۝ lifts its whole ayah (Tools can make a tap anywhere take the whole ayah), and a second tap puts the cover back. Each ayah's opening word stays visible as the prompt to recite the rest from (switchable), and the rub' al-hizb star is never covered. When the page is fully shown it turns to the next page by itself (can be switched off) |
| Reciting      | «سمِّع» in hide mode listens to the reader and lifts each word's cover as it is said, turning the page at its end. A word left out stops the reader there (its cover is outlined in red): nothing said after it is shown. Before the first word is followed the reader may be anywhere — further down the page, or in another surah, which the app then goes to. On the device only: a Whisper model fine-tuned on recitation, no sound leaves it. See *Following a recitation* |
| Stats         | Tools → «تلاوتي»: words, pages, letters, hasanat (ten a written letter) and time recited aloud — today, in total, the streak, and a day grid like a contribution graph. Only what was followed by ear counts. Kept on the device |
| Listening     | page or selected ayah, 1/3/5/10 repeats, three Qaloun reciters; keeps playing with the screen locked; lock-screen controls                                                                                                          |
| Offline       | every opened page is kept on disk for good; a juz or the whole mushaf can be stored ahead of time                                                                                                                                   |
| Progress      | tap an ayah, press «احفظ»: it is outlined in gold with a bookmark; «موضعي» jumps back to it (also in the tools sheet)                                                                                                               |
| Remembered    | last page, progress ayah, reciter, repeat count, hide mode (and what a tap lifts, opening word), auto-turn — in UserDefaults                                                                                                                                             |

Requires iOS 17 / macOS 14.

## Run it

Open `Qaloon/Qaloon.xcodeproj` in Xcode and press ▶ with a destination:

- **My Mac** — runs immediately, nothing to sign (ad-hoc signing, sandboxed). To keep it as a
  normal app, build Release and copy it: `xcodebuild -scheme Qaloon -configuration Release -destination 'platform=macOS' build`
  then copy `Qaloon.app` from the build products into /Applications.
- **iPhone simulator** — runs immediately.
- **Your iPhone** — one-time: select the _Qaloon_ target → Signing & Capabilities →
  tick _Automatically manage signing_ → Team → _Add an Account…_ with your normal
  Apple ID → pick _Your Name (Personal Team)_. If Xcode says the bundle identifier
  is taken, change `com.makeathar.mushaf` to anything unique. Plug the phone in,
  press ▶, then on the phone trust the certificate under
  Settings → General → VPN & Device Management.

A free Apple ID signs the app for 7 days; after that it refuses to launch until
you press ▶ again (or refresh it with SideStore). Data on the phone is kept.
Without any Apple ID the app can only run on the Mac and in the simulator.

From the command line (no signing needed):

```bash
cd Qaloon
xcodebuild -scheme Qaloon -destination 'platform=macOS' build
xcodebuild -scheme Qaloon -destination 'platform=iOS Simulator,name=iPhone 17' build CODE_SIGNING_ALLOWED=NO
```

## Where things are

```
Qaloon/Qaloon/
  MushafApp.swift            entry; RTL, parchment theme
  Model/Quran.swift          surahs / ayah ids / pages / juz from qaloun-index.json
  Model/Layout.swift         ayah line boxes + word boxes per page (layout.json)
  Services/PageImageStore.swift  disk + memory cache, CDN download, offline download
  Services/Recitation.swift  reciters, MP3Quran timing API (+ Madani/Hafs numbering check)
  Services/AyahPlayer.swift  AVPlayer: seek windows per ayah, highlight, background audio
  Services/Recite/ReciteSession.swift  microphone → WhisperKit → follower, twice a second
  Services/Recite/Follower.swift       the cursor through the page's words (pure, tested headless)
  Services/Recite/Locator.swift        where in the mushaf a few recited words are (voice navigation)
  Services/Recite/Tracker.swift        one page being recited: follower + locator + "stopped"
  Services/ReciteStats.swift           what was recited, per day (recited.json in Application Support)
  Views/StatsView.swift                totals, streak, day grid
  Services/Recite/Skeleton.swift       Uthmani Qaloun spelling and everyday spelling → one skeleton
  Views/ReaderView.swift     paging, caption, bottom bar, hide mode, auto-turn, keys
  Views/PageView.swift       image + Canvas overlay (ayah / word covers) + tap → ayah or word
  Views/NavigateSheet.swift  page / juz / surah
  Views/ToolsSheet.swift     reciter, repeat, hide options, offline storage
  Resources/                 qaloun-index.json, layout.json (generated — see below)
  Resources/ReciteModel/     the Core ML speech model (git-ignored — see below)
ReciteHarness/        headless checks of the follower on recordings (./check.sh)
```

The Xcode project uses a synchronized folder, so new Swift files dropped into
`Qaloon/Qaloon/` are picked up without editing the project.

## Regenerating the data

The generated files are committed, so the app builds as it is. They come from the word map
([qaloon-wordmap](https://github.com/hedi-ghodhbane/qaloon-wordmap)) by way of an Ertak checkout
next to this one (`ERTAK=/path/to/ertak` to point elsewhere):

```bash
(cd ../ertak && npm run mushaf:build)   # the Ertak checkout builds public/mushaf/qaloun/{page}.json
node scripts/build-data.mjs          # → Qaloon/Qaloon/Resources/*.json
```

`layout.json` keeps ayah ids, line boxes, the word boxes and each word's spelling (~3.4 MB).
Each word row carries a `kind` (word / rub' al-hizb star / the ayah's opening word); the
spellings are what a recitation is matched against.

## Following a recitation

```bash
scripts/build-recite-model.sh        # once: → Qaloon/Qaloon/Resources/ReciteModel (143 MB, git-ignored)
ReciteHarness/check.sh        # the follower on saved recordings: a minute, no model needed
```

The model is [tarteel-ai/whisper-base-ar-quran](https://huggingface.co/tarteel-ai/whisper-base-ar-quran)
(Apache-2.0), converted to Core ML and run with [WhisperKit](https://github.com/argmaxinc/WhisperKit)
(MIT). Without the model folder the app builds and runs as before, without the «سمِّع» button.

Every 0.4 s — or as fast as the device manages — the last 10 s of sound go through the model
(0.15–0.25 s a pass on a Mac; the pass time is shown next to what was heard), and the text it
returns goes to the follower.

Getting the model ready means Core ML compiling it for the Neural Engine: once per install
(8.5 s on a Mac — the audio encoder 7 s of it — and several times that on a phone), cached
after that (0.4 s). It happens in the background as soon as hide mode is on, so «سمِّع» is
usually instant; pressed sooner, «تحميل…» shows the seconds passing and says the first time is
longer. The model is let go when hide mode goes off (150 MB of memory). The follower never trusts that text as such:
it knows the page's words, reduces both sides to a consonant skeleton (`ٱلصَّلَوٰةَ` and
`الصلاة` are the same), and only asks which of the next few expected words were just said.
That is why a model trained on Ḥafṣ follows a Qālūn recitation: the differences are in
vowels, imāla and ṣila, which the skeleton drops.

- It advances only over words that were heard, one after the other. The same phrase often
  returns a few words later (67:16 / 67:17), and a match ahead must not pull the cursor on;
  and a reader who leaves a word out is meant to be stopped there. On the recordings this
  strictness costs nothing: no word ever needed skipping. A word the model will not hear
  can always be lifted by hand, which moves the cursor past it.
- The last word of a live transcript is usually cut short: it counts only once it is, letter
  for letter, a word expected next, or once the sound ends in a pause.
- Silence is never transcribed: Whisper makes words up out of it.
- Until a first word is followed on a page the reader may be anywhere, and the locator is
  asked: the whole mushaf as one sequence of skeletons, the last words heard — four in a row
  at least, ending where the sound ends — found in one place only. On another page, the app
  goes there; what comes before the place is shown (it is where they chose to start) and
  only the words heard are counted. The basmala does not count as a first word: it opens
  every surah. Once held to the text, the reader is never looked for elsewhere — a jump is
  then a mistake to notice, not a wish to follow. Stopping and starting «سمِّع», or turning
  the page by hand, frees them again.
- A reader who has said two or more words past the cursor that the text cannot take, and
  stays that way for three seconds or so, is shown where they are stopped, with a haptic.
  A pause is not that, nor is a long madd (the model rewrites the end of what it hears as
  the sound goes on). A word the model mishears looks the same as a word left out: tap it
  to go on.
- The recogniser writes «يا أيها» as two words; the mushaf writes «يٰٓأيها» as one. The
  vocative is joined to the word after it before matching, else every surah that opens so
  stalls on its first word.
- The istiʿādha, said before reciting, is found once in the text (16:98): its words are
  left out of the search for where the reader is. And a place the locator found is
  provisional until the follower itself advances from it, so a wrong one is undone by the
  next words rather than kept.
- A cover lifted by hand moves the cursor past it.

Measured on MP3Quran's Qālūn recordings (al-Ḥuṣarī, al-Ḥudhayfī; surahs 1, 67, 78; 909
words): every word followed in order, none skipped, and an ayah's last word uncovered
before the next ayah begins. Not measured: a phone's microphone in a room, a fast ḥadr,
a learner's hesitations — that is what trying it is for.

## Notes

- Page images are stored in the app's Application Support folder, which iOS
  never purges; deleting the app deletes them. A page is about 0.8 MB, so a
  juz is roughly 16 MB and the whole mushaf about 0.5 GB.
- Ayah timings come straight from `mp3quran.net/api/v3/ayat_timing` (the web
  app proxies the same API); a reciter whose rows follow the Hafs count for a
  surah is refused for per-ayah playback with an explanation, as in the web app.
- This app was split from the Ertak platform's repository (its history came along). They
  share the CDN, the page data and the feature semantics, but no code.

## Sync between devices (no account)

Tools → «المزامنة بين الأجهزة». One device presses «إنشاء رمز مزامنة» and gets a
code such as `XJ2HF-E3TND`; the other enters it and presses «ربط». From then on
the last page, the progress ayah, hide mode, ayah signs, auto-turn, reciter and
repeat count follow you. Downloaded pages stay per device.

How it works:

- The code is generated by the server (10 symbols, about 49 bits) and is the
  only secret. There is no login; anyone with the code can read and change that
  group's reader state, which holds nothing personal.
- Every field carries the time it last changed on a device. The server merges
  per field, newest wins, so a phone and a Mac can change different things
  offline and still converge. A joining device sends stamp 0, so the group wins.
- A device only ever does `PUT /api/mushaf-sync/:code` with what it has and
  adopts the answer. It syncs on launch, when the app comes to the foreground,
  and 1.5 s after a local change.
- Server side, in the Ertak repository: `src/lib/mushaf-sync.ts` (validation, merge, codes, unit tests),
  `src/lib/mushaf-sync-store.ts` (Postgres, optimistic `version` column because
  Workers run each query on its own connection), routes under
  `src/routes/api/mushaf-sync/`, table `mushaf_sync` (migration `0005`).

Going live needs two steps on the Ertak deployment:

```bash
npm run db:migrate   # applies drizzle/0005_mushaf_sync.sql (one CREATE TABLE)
npm run deploy       # ships the /api/mushaf-sync routes
```

Until then the app reports that sync failed (404) and keeps working locally.
To try it against a dev server instead, launch a build with
`-syncBaseURL http://<your-mac>:3000`; `-syncJoin CODE` links a fresh install
from the command line.

## Credits

- **The pages** are the King Fahd Glorious Quran Printing Complex's mushaf in the riwāya of
  Qālūn (Madanī ayah count, 6214 ayahs). The artwork is theirs; this app only displays it,
  from `cdn.makeathar.com`.
- **The word boxes** come from [qaloon-wordmap](https://github.com/hedi-ghodhbane/qaloon-wordmap),
  computed from the same mushaf's vector pages as published by
  [quran-ws/quran-svg](https://github.com/quran-ws/quran-svg).
- **The speech model** is [tarteel-ai/whisper-base-ar-quran](https://huggingface.co/tarteel-ai/whisper-base-ar-quran)
  by Tarteel AI, Apache-2.0: OpenAI's Whisper fine-tuned on Quran recitation. It is converted
  to Core ML here (`scripts/build-recite-model.sh`), otherwise unchanged. All the credit for
  the model is theirs.
- **[WhisperKit](https://github.com/argmaxinc/WhisperKit)** by Argmax, MIT, runs it on the device.
- **Recitations and ayah timings**: [MP3Quran](https://mp3quran.net).
