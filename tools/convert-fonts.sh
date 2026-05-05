#!/usr/bin/env bash
# convert-fonts.sh — конвертує всі TTF/OTF у вказаній папці у WOFF2 + WOFF
#
# Використання:
#   ./tools/convert-fonts.sh fonts/my-font/
#
# Залежності (встановити один раз):
#   pip install fonttools brotli zopfli
#
# Скрипт не видаляє оригінальні TTF/OTF — лише додає поряд .woff2 і .woff.

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Використання: $0 <папка-з-TTF-або-OTF>"
  exit 1
fi

DIR="$1"

if [ ! -d "$DIR" ]; then
  echo "Папка не знайдена: $DIR"
  exit 1
fi

if ! python3 -c "import fontTools" 2>/dev/null; then
  echo "fontTools не встановлено. Запусти: pip install fonttools brotli zopfli"
  exit 1
fi

shopt -s nullglob nocaseglob

count=0
for src in "$DIR"/*.ttf "$DIR"/*.otf; do
  [ -e "$src" ] || continue
  base="${src%.*}"
  echo "→ $(basename "$src")"

  python3 - "$src" "$base.woff2" <<'PY'
import sys
from fontTools.ttLib import TTFont
src, dst = sys.argv[1], sys.argv[2]
f = TTFont(src)
f.flavor = "woff2"
f.save(dst)
PY

  python3 - "$src" "$base.woff" <<'PY'
import sys
from fontTools.ttLib import TTFont
src, dst = sys.argv[1], sys.argv[2]
f = TTFont(src)
f.flavor = "woff"
f.save(dst)
PY

  count=$((count + 1))
done

echo ""
echo "Готово. Сконвертовано $count файлів."
echo "WOFF2/WOFF лежать поряд з оригіналами в $DIR"
