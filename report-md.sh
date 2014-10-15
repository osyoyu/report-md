#!/bin/bash

# option parsing
while [[ $# > 1 ]]
do
  key="$1"
  shift

  case $key in
    -t|--title)
      TITLE=${1}
      shift
      ;;
    --header-left)
      HEADER_LEFT=${1}
      shift
      ;;
    --header-right)
      HEADER_RIGHT=${1}
      shift
      ;;
    *)
      ;;
  esac
done

if [ -z "$1" ] || [ -z "$TITLE" ]; then
  echo "usage: report-md.sh [-t title] [--header-left] [--header-right] target_file"
  exit 1
fi

if [ -z "${HEADER_LEFT}" ]; then
  HEADER_LEFT=${TITLE}
fi

if [ -z "${HEADER_RIGHT}" ]; then
  HEADER_RIGHT=""
fi

echo "Title: ${TITLE}
Header (Left): ${HEADER_LEFT}
Header (Right): ${HEADER_RIGHT}"

# check for pandoc and wkhtmltopdf
if [ ! type pandoc > /dev/null 2>&1 ]; then
  echo "pandoc not found"
  exit 1
fi

if [ ! type wkhtmltopdf > /dev/null 2>&1 ]; then
  echo "wkhtmltopdf not found"
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CSS="$(awk -F\n -v ORS=' ' '{print}' ${DIR}/style.css)"

FILENAME=$(basename ${1} .md)
TITLE=${2}

# generate HTML from Markdown
pandoc -f markdown -t html -o ${FILENAME}.html ${1}

# insert headers and footers
sed -i "" -e '1i\
<!DOCTYPE html><html lang="ja"><head><meta charset=\"UTF-8\"><style></style></head><body>' \
${FILENAME}.html
sed -i "" -e "s%<style></style>%<style>${CSS}</style>%" ${FILENAME}.html
echo '</body></html>' >> ${FILENAME}.html

# convert HTML to PDF
wkhtmltopdf --encoding UTF-8 \
  --title "${TITLE}" \
  --margin-top 20mm --margin-bottom 20mm --margin-left 15mm --margin-right 15mm \
  --header-left "${HEADER_LEFT}" --header-right "${HEADER_RIGHT}" --header-line ${FILENAME}.html --header-spacing 5 \
  --footer-center '[page] / [toPage]' --footer-spacing 5 \
  ${FILENAME}.pdf
