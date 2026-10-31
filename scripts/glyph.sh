#!/usr/bin/env bash
# 古文字形制作：从扫描页裁切古文字（甲骨文/金文等）或整组字形阵列，
# 输出 SVG（默认）或 PNG 位图。
#
# 用法:
#   scripts/glyph.sh <PDF页码> <x> <y> <宽> <高> <输出名> [svg|png]
#
# 坐标以 600dpi 渲染图为准。600dpi 整页 PNG 缓存于 ocr/glyph-src/page-NNNN.png
# （首次自动渲染，之后复用）。定位坐标的方法见 docs/workflow.md「古文字形」节。
#
# svg（默认）：potrace 矢量化，只保留 viewBox，显示尺寸交给 CSS。
#   行内单字：![墉](assets/glyphs/yong.svg){.glyph}
#   字形阵列：![耤字甲骨文五形（令鼎、戬鼎等）](assets/glyphs/jie-jiagu.svg)
# png：原样 600dpi 位图（带灰度阈值清理），用于矢量化效果差的复杂阵列：
#   scripts/glyph.sh 70 300 2100 2800 400 jie-jinwen-plate png
set -euo pipefail
cd "$(dirname "$0")/.."

if [ $# -lt 6 ] || [ $# -gt 7 ]; then
  sed -n '2,17p' "$0" >&2
  exit 1
fi

PAGE="$1"; X="$2"; Y="$3"; W="$4"; H="$5"; NAME="$6"
FMT="${7:-svg}"
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

# 裁切 → 加余白 → 灰度阈值清理
magick "$page_png" -crop "${W}x${H}+${X}+${Y}" +repage \
  -bordercolor white -border 6 \
  -colorspace Gray -threshold 60% \
  "$tmp/glyph.pbm"

if [ "$FMT" = png ]; then
  magick "$tmp/glyph.pbm" "$OUT_DIR/$NAME.png"
  echo "已生成 $OUT_DIR/$NAME.png（600dpi 位图）" >&2
else
  potrace "$tmp/glyph.pbm" --svg --flat -o "$tmp/glyph.svg"
  # potrace 输出含绝对尺寸，改为只保留 viewBox，显示尺寸交给 CSS
  perl -0777 -pe 's{<svg[^>]*viewBox="([^"]*)"[^>]*>}{<svg xmlns="http://www.w3.org/2000/svg" viewBox="$1">}s' \
    "$tmp/glyph.svg" > "$OUT_DIR/$NAME.svg"
  echo "已生成 $OUT_DIR/$NAME.svg" >&2
fi
