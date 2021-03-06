# This Makefile relies on LaTeX-Mk
# See: http://latex-mk.sourceforge.net/

NAME=collection-px

KNITR=$(wildcard sections/*.Rnw)
KNITR_TEX=$(KNITR:.Rnw=.tex)
KNITR_TEX=$(patsubst sections/%.Rnw,gen/%.tex,$(KNITR))
TEXSRCS=$(NAME).tex $(wildcard scripts/*.tex) $(wildcard sections/*.tex) $(KNITR_TEX)
USE_PDFLATEX=true
BIBTEXSRCS=references.bib

CLEAN_FILES+=$(wildcard *.synctex.gz) $(wildcard *.fdb_latexmk) \
             $(wildcard *.fls) $(KNITR_TEX) comment.cut \
             $(NAME).4ct $(NAME).4tc $(NAME).css $(NAME).html $(NAME).idv \
             $(NAME).lg $(NAME).tmp $(NAME).xcp $(NAME).xref

ifeq ($(CI_SERVER),yes)
	GIT_MSG=$(shell git log -1 --pretty=%B | grep -v Signed-off)
	# GV=curl -F file=@$(NAME).pdf -F filename=$(NAME).pdf -F title="$(NAME)" -F initial_comment="$(GIT_MSG)" -F channels="\#writing" -F token= https://slack.com/api/files.upload && touch
else
	ifeq ($(TRAVIS),true)
		GV=echo 
	else
		GV=@open -a Skim.app 
	endif
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
	zip paper.zip $(TEXSRCS) $(BIBTEXSRCS) scripts/collab.sty ACM-Reference-Format.bst acmart.cls px18.sty $(NAME).bbl

latexdiff:
	-mkdir submission-latex
	git archive --format=tar --prefix=submission-latex/ dls-2017 | tar xf -
	latexdiff submission-latex/$(NAME).tex $(NAME).tex > diff.tex
	pdflatex diff
	pdflatex diff
	bibtex diff
	pdflatex diff
	pdflatex diff

lacheck:
	lacheck $(NAME).tex

chktex:
	chktex $(NAME).tex

lint: chktex lacheck
