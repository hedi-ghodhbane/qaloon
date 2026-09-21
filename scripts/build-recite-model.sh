#!/usr/bin/env bash
# Builds the speech model the app follows a recitation with, and puts it where
# Xcode bundles it: Qaloon/Qaloon/Resources/ReciteModel (git-ignored, 143 MB).
#
#   model   tarteel-ai/whisper-base-ar-quran (Apache-2.0): Whisper base fine-tuned on
#           Quran recitation. Converted to Core ML with argmaxinc/whisperkittools for
#           WhisperKit, which runs it on the Neural Engine.
#
# Three things about that 2022 checkpoint need working around, all found the hard way:
#   - it ships pytorch_model.bin only, which the converter's torch refuses to load
#     -> saved again as safetensors;
#   - its config says use_cache=false, which breaks the converter's own decoder check
#     -> set to true (the weights are untouched);
#   - its tokenizer files predate Whisper's timestamp tokens and call <|nospeech|>
#     <|nocaptions|>; WhisperKit then takes every special token for a timestamp and
#     transcribes nothing -> the stock openai/whisper-base tokenizer is used instead
#     (same text vocabulary).
#
# Needs: uv (https://docs.astral.sh/uv), git, ~3 GB of disk, a few minutes. macOS only.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/Qaloon/Qaloon/Resources/ReciteModel"
WORK="${RECITE_MODEL_WORK:-$ROOT/.recite-model-build}"
MODEL="tarteel-ai/whisper-base-ar-quran"
mkdir -p "$WORK" && cd "$WORK"

[ -d whisperkittools ] || git clone --depth 1 https://github.com/argmaxinc/whisperkittools.git
[ -d venv-save ] || { uv venv --python 3.12 -q venv-save && uv pip install -q --python venv-save/bin/python torch transformers; }
[ -d venv-coreml ] || { uv venv --python 3.11 -q venv-coreml && uv pip install -q --python venv-coreml/bin/python -e ./whisperkittools; }

venv-save/bin/python - <<EOF
import json, shutil
from huggingface_hub import hf_hub_download
from transformers import GenerationConfig, WhisperForConditionalGeneration
model = WhisperForConditionalGeneration.from_pretrained("$MODEL")
model.generation_config = GenerationConfig.from_pretrained("openai/whisper-base")
model.config.use_cache = True
model.save_pretrained("hf", safe_serialization=True)
for name in ("tokenizer.json", "tokenizer_config.json"):
    shutil.copy(hf_hub_download("openai/whisper-base", name), "hf/" + name)
EOF

rm -rf coreml
venv-coreml/bin/whisperkit-generate-model --model-version hf --output-dir coreml
BUILT="$(dirname "$(find coreml -name TextDecoder.mlmodelc -maxdepth 2 | head -1)")"

rm -rf "$OUT" && mkdir -p "$OUT"
cp -R "$BUILT"/{AudioEncoder,MelSpectrogram,TextDecoder}.mlmodelc "$OUT/"
cp hf/{tokenizer.json,tokenizer_config.json,config.json,generation_config.json} "$OUT/"
du -sh "$OUT"
echo "Done. Build the app: the model is bundled with it."
