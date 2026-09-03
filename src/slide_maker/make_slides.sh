#!/bin/bash
#
# bash ../make_slides.sh slides_nickname.do.txt
#
# But this script is normally run from make.sh to make both
# chapter and slides.
set -e 

dofile=$1
class=MOD550
if [ ! -f class-$dofile-$class.do.txt ]; then
  echo "No such file: class-$dofile-$class"
  exit 1
fi

filename=`echo class-$dofile-$class | sed 's/\.do\.txt//'`

# Default font size of the slides. Beamer only accepts
# 8pt, 9pt, 10pt, 11pt (beamer default), 12pt, 14pt, 17pt, 20pt.
fontsize=9pt

# doconce always emits \documentclass{beamer} (or [handout]) without a font
# size, so patch it into the generated .tex before running pdflatex.
set_fontsize() {
  sed -i 's/\\documentclass{beamer}/\\documentclass['"$fontsize"']{beamer}/; s/\\documentclass\[handout\]{beamer}/\\documentclass[handout,'"$fontsize"']{beamer}/' ${filename}.tex
}

# LaTeX PDF for printing
# (Smart to make this first to detect latex errors - HTML/MathJax
# gives far less errors and warnings)

# LaTeX Beamer
preprocess -DFORMAT=pdflatex ../newcommands.p.tex > newcommands_keep.tex
doconce format pdflatex $filename --latex_title_layout=beamer --latex_table_format=footnotesize --latex_admon_title_no_period --latex_code_style=pyg --no_ampersand_quote 
doconce slides_beamer $filename --beamer_slide_theme=blue_shadow
set_fontsize
pdflatex -shell-escape $filename
pdflatex -shell-escape $filename
mv ${filename}.pdf ${filename}-beamer.pdf

# Handouts
doconce format pdflatex $filename --latex_title_layout=beamer --latex_table_format=footnotesize --latex_admon_title_no_period --latex_code_style=pyg --no_ampersand_quote 
doconce slides_beamer $filename --beamer_slide_theme=blue_shadow --handout
set_fontsize
pdflatex -shell-escape $filename
pdfjam ${filename}.pdf --no-landscape --frame true --nup 2x3 --suffix 6up
rm ${filename}.pdf 
cp ${filename}-6up.pdf ../../doc/${filename}-6up.pdf
./clean.sh

