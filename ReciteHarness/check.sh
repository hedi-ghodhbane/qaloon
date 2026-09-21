#!/usr/bin/env bash
# Runs the follower checks that need no model and no audio: a minute, offline.
set -euo pipefail
cd "$(dirname "$0")"
swift build -c release --product replay 2>&1 | tail -1
swift build -c release --product pages 2>&1 | tail -1
cp ../Mushaf/Mushaf/Resources/layout.json .build/release/
echo "== follower vs the Python prototype, same hypotheses (expect 0, or a word or two half a second apart)"
for s in husary-001 huthaifi-001 huthaifi-067 husary-078 husary-067; do
  printf '%-14s' "$s"; .build/release/replay "Fixtures/$s" | head -1
done
echo "== on a straight recitation the cursor never moves back (expect 0 everywhere)"
for s in husary-001 huthaifi-067 husary-078; do
  mkdir -p .build/coreml && cp "Fixtures/$s.follow.json" ".build/coreml/$s.follow.json" && cp "Fixtures/$s.hyps-coreml.json" ".build/coreml/$s.hyps.json"
  printf '%-14s%s\n' "$s" "$(TRACE=1 .build/release/replay ".build/coreml/$s" | grep -c '^ *[0-9.]* [F ] cursor' || true)"
done
echo "== page flow: every cover of a full page lifted by voice, then the turn"
.build/release/pages Fixtures/huthaifi-067.hyps-coreml.json 562
.build/release/pages Fixtures/husary-078.hyps-coreml.json 582
echo "== the reader begins mid-page: found, and followed to the end of the page"
.build/release/pages Fixtures/huthaifi-067.hyps-coreml.json 562 70 | head -1
.build/release/pages Fixtures/husary-078.hyps-coreml.json 582 100 | head -1
