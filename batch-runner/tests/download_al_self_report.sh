#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# Download all self_report.json from HuggingFace experiment repos
# to batch-runner/workspace/self_reports/ (gitignored) for local analysis.
#
# Usage:
#   cd batch-runner
#   bash tests/download_al_self_report.sh
# ─────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BATCH_DIR="$(dirname "$SCRIPT_DIR")"
RESULTS_DIR="$BATCH_DIR/results"
DOWNLOAD_DIR="$BATCH_DIR/workspace/self_reports"

HF_USER="HyeonSang"
HF_BASE="https://huggingface.co/datasets/${HF_USER}"

mkdir -p "$DOWNLOAD_DIR"

echo "📥 Downloading self_report.json files from HuggingFace"
echo "   Source: ${HF_BASE}/*/blob/main/self_report.json"
echo "   Target: ${DOWNLOAD_DIR}/"
echo ""

count=0
failed=0

for exp_dir in "$RESULTS_DIR"/exp*/; do
  exp_name=$(basename "$exp_dir")

  # Skip smoke tests
  if [[ "$exp_name" == *smoke* ]]; then
    echo "   ⏭  $exp_name (smoke test, skipped)"
    continue
  fi

  url="${HF_BASE}/${exp_name}/resolve/main/self_report.json"
  out_file="${DOWNLOAD_DIR}/${exp_name}_self_report.json"

  echo -n "   ⬇  $exp_name ... "

  if curl -fsSL -o "$out_file" "$url" 2>/dev/null; then
    size=$(wc -c < "$out_file" | tr -d ' ')
    echo "✅ $(( size / 1024 ))KB"
    count=$((count + 1))
  else
    echo "❌ not found on HF"
    rm -f "$out_file"
    failed=$((failed + 1))
  fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Downloaded: $count"
[ "$failed" -gt 0 ] && echo "❌ Failed: $failed"
echo "📂 Location: $DOWNLOAD_DIR/"
echo ""
echo "Files (gitignored, safe to keep locally):"
ls -lh "$DOWNLOAD_DIR"/*.json 2>/dev/null || echo "   (none)"
