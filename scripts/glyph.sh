#!/usr/bin/env bash
# 古文字形矢量化：从扫描页裁切单个古文字（甲骨文/金文等）并转成 SVG。
#
# 用法:
#   scripts/glyph.sh <PDF页码> <x> <y> <宽> <高> <输出名>
#
# 坐标以 600dpi 渲染图为准。600dpi 整页 PNG 缓存于 ocr/glyph-src/page-NNNN.png
# （首次自动渲染，之后复用）。定位坐标的方法见 docs/workflow.md「古文字形」节。
# 产物写入 assets/glyphs/<输出名>.svg（入库），在 Markdown 里行内引用：
#
#   ……有“仆![墉](assets/glyphs/yong.svg){.glyph}土田”……
set -euo pipefail
cd "$(dirname "$0")/.."

if [ $# -ne 6 ]; then
  sed -n '2,14p' "$0" >&2
  exit 1
fi

PAGE="$1"; X="$2"; Y="$3"; W="$4"; H="$5"; NAME="$6"
PDF="source/中国古代史读本(上下).pdf"
SRC_DIR="ocr/glyph-src"
OUT_DIR="assets/glyphs"
mkdir -p "$SRC_DIR" "$OUT_DIR"

page_png=$(printf "%s/page-%04d.png" "$SRC_DIR" "$PAGE")
if [ ! -s "$page_png" ]; then
  echo "渲染第 $PAGE 页（600dpi）…" >&2
  gs -dNOPAUSE -dBATCH -sDEVICE=png16m -r600 \
     -dFirstPage="$PAGE" -dLastPage="$PAGE" \
     -sOutputFile="$page_png" "$PDF" -q
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# 裁切 → 放大余白 → 灰度阈值 → potrace 矢量化
magick "$page_png" -crop "${W}x${H}+${X}+${Y}" +repage \
  -bordercolor white -border 6 \
  -colorspace Gray -threshold 60% \
  "$tmp/glyph.pbm"

potrace "$tmp/glyph.pbm" --svg --flat -o "$tmp/glyph.svg"

# potrace 输出含绝对尺寸，改为只保留 viewBox，显示尺寸交给 CSS（img.glyph）
perl -0777 -pe 's{<svg[^>]*viewBox="([^"]*)"[^>]*>}{<svg xmlns="http://www.w3.org/2000/svg" viewBox="$1">}s' \
  "$tmp/glyph.svg" > "$OUT_DIR/$NAME.svg"

echo "已生成 $OUT_DIR/$NAME.svg" >&2
