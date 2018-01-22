# This Makefile relies on LaTeX-Mk
# See: http://latex-mk.sourceforge.net/

NAME=collection-px

KNITR=$(wildcard sections/*.Rnw)
KNITR_TEX=$(KNITR:.Rnw=.tex)
KNITR_TEX=$(patsubst sections/%.Rnw,gen/%.tex,$(KNITR))
TEXSRCS=$(NAME).tex $(wildcard scripts/*.tex) $(wildcard sections/*.tex) $(KNITR_TEX)
USE_PDFLATEX=true
BIBTEXSRCS=references.bib

CLEAN_FILES+=$(wildcard *.synctex.gz) $(wildcard *.fdb_latexmk) $(wildcard *.fls) $(KNITR_TEX) comment.cut

ifeq ($(CI_SERVER),yes)
	GIT_MSG=$(shell git log -1 --pretty=%B | grep -v Signed-off)
	# GV=curl -F file=@$(NAME).pdf -F filename=$(NAME).pdf -F title="$(NAME)" -F initial_comment="$(GIT_MSG)" -F channels="\#writing" -F token= https://slack.com/api/files.upload && touch
else
	GV=@open -a Skim.app 
endif



gen/%.tex: sections/%.Rnw gen scripts/*.R
	scripts/knit.R $< $@

# We are going to try a couple of standard locations to find LaTeX-Mk:
-include ~/.local/share/latex-mk/latex.gmk
-include /usr/local/share/latex-mk/latex.gmk
-include /opt/local/share/latex-mk/latex.gmk
-include /usr/share/latex-mk/latex.gmk

gen:
	-mkdir gen

open:
	mate $(TEXSRCS)

clobber: clean
	rm -Rf gen cache

html5:
	~/Projects/misc/latex-to-html5/ht-latex $(NAME).tex tmp-html/

zip:
	zip paper.zip $(TEXSRCS) $(BIBTEXSRCS) scripts/collab.sty ACM-Reference-Format.bst acmart.cls paper.bbl figures/process-view.pdf figures/protocol-class-diagram.pdf figures/protocol-overview.pdf figures/stm-example.pdf figures/system-view.pdf

latexdiff:
	-mkdir submission-latex
	git archive --format=tar --prefix=submission-latex/ dls-2017 | tar xf -
	latexdiff submission-latex/paper.tex paper.tex > diff.tex
	pdflatex diff
	pdflatex diff
	bibtex diff
	pdflatex diff
	pdflatex diff
