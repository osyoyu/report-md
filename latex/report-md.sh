#!/bin/sh

inputfile=`basename $1 .md`
templatename=RG_TEMP

cp $2 ${templatename}.tex
pandoc -f markdown -t latex -o mid-output.tex ${1}
platex ${templatename}.tex && dvipdfmx -o ${inputfile}.pdf ${templatename}.dvi && rm ${templatename}.dvi ${templatename}.log ${templatename}.tex
