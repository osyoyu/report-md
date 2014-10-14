#!/bin/bash

# check for pandoc
if ! type pandoc > /dev/null 2>&1; then
  echo "pandoc not found"
  exit 1
fi

if ! type wkhtmltopdf> /dev/null 2>&1; then
  echo "wkhtmltopdf not found"
  exit 1
fi

FILENAME=$(basename ${1} .md)
TITLE=${2}
pandoc -f markdown -t html -o ${FILENAME}.html ${1}

# insert headers and footers
sed -i "" -e '1i\
<!DOCTYPE html><html lang="ja"><head><meta charset="UTF-8"><link rel="stylesheet" type="text/css" href="style.css"></head><body>' ${FILENAME}.html
echo '</body></html>' >> ${FILENAME}.html

wkhtmltopdf --encoding UTF-8 \
  --title ${TITLE} \
  --margin-top 20mm --margin-left 15mm --margin-right 15mm --margin-bottom 20mm \
  --header-left '[doctitle]' --header-right 'おなまえ' --header-line ${FILENAME}.html --header-spacing 5 \
  --footer-center '[page] / [toPage]' --footer-spacing 5\
  ${FILENAME}.pdf
