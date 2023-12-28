# General Makefile rules
#        
# The following commands are supported:
#
# make 
# make view 
# make clean

TOPIC   = main
MAIN    = $(TOPIC)

FIGS_ORIG_DIR   = ./figs_orig
FIGS_DIR        = ./figs
LATEXDIR        = ./

PDF_FIGS	 = $(patsubst $(FIGS_ORIG_DIR)%.pdf,$(FIGS_DIR)%.pdf,$(wildcard $(FIGS_ORIG_DIR)/*.pdf))
EPS_FIGS	 = $(patsubst $(FIGS_ORIG_DIR)%.eps,$(FIGS_DIR)%.pdf,$(wildcard $(FIGS_ORIG_DIR)/*.eps))
TIKZ_FIGS    = $(patsubst $(FIGS_ORIG_DIR)%.tex,$(FIGS_DIR)%.pdf,$(wildcard $(FIGS_ORIG_DIR)/*.tex))
SVG_FIGS	 = $(patsubst $(FIGS_ORIG_DIR)%.svg,$(FIGS_DIR)%.pdf,$(wildcard $(FIGS_ORIG_DIR)/*.svg))
JPG_FIGS	 = $(patsubst $(FIGS_ORIG_DIR)%.jpg,$(FIGS_DIR)%.jpg,$(wildcard $(FIGS_ORIG_DIR)/*.jpg))
PNG_FIGS	 = $(patsubst $(FIGS_ORIG_DIR)%.png,$(FIGS_DIR)%.png,$(wildcard $(FIGS_ORIG_DIR)/*.png))
XFIG_FIGS    = $(patsubst $(FIGS_ORIG_DIR)%.fig,$(FIGS_DIR)%.pdf_t,$(wildcard $(FIGS_ORIG_DIR)/*.fig))

LATEXFILES   = $(wildcard $(LATEXDIR)/*.tex)
TEXFILES     = $(wildcard ./*.tex)
STYLEFILES   = $(wildcard ./*.sty)

all: $(MAIN).pdf

# decide which PDF viewer based on the operating system
LINUX_PDF_VIEWER = evince
MAC_PDF_VIEWER = start
PDF_VIEWER = 
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
PDF_VIEWER = $(LINUX_PDF_VIEWER)
else
PDF_VIEWER = $(MAC_PDF_VIEWER)
endif

view: $(MAIN).pdf
	@echo Currently using $(UNAME_S) 
	$(PDF_VIEWER) $(MAIN).pdf &

# main rule
$(MAIN).pdf : $(MAIN).tex $(EPS_FIGS) $(PDF_FIGS) $(XFIG_FIGS) $(SVG_FIGS) \
              $(JPG_FIGS) $(PNG_FIGS) $(LATEXFILES) $(TIKZ_FIGS) $(TEXFILES) \
              Makefile $(STYLEFILES)
	pdflatex --shell-escape $(MAIN)
	pdflatex $(MAIN)
#	@while ( grep "Rerun to get cross-references" 	\
#	$(MAIN).log > /dev/null ); do		\
#	        echo '** Re-running LaTeX **';		\
#	        pdflatex $(MAIN);				\
#	done
	
#
#	TO DO: entender o porque "make" nao sai deste while ...
#
#	@while ( grep "Rerun to get cross-references" 	\
#	$(subst .pdf,.log,$@) > /dev/null ); do		\
#	        echo '** Re-running LaTeX **';		\
#	        pdflatex $(subst .pdf,.tex,$@);         \
#	done

# clean rule
clean:
	rm -f ./*.brf
	rm -f ./*.aux
	rm -f ./*.tex~
	rm -f ./*.log
	rm -f ./*.ps
	rm -f ./*.dvi
	rm -f ./*.blg
	rm -f ./*.bbl
	rm -f ./*.tmp
	rm -f ./*.bib~
	rm -f ./*.thm
	rm -f ./*.toc
	rm -f ./*.lo*
	rm -f ./comment.cut
	rm -f ./*.nav
	rm -f ./*.out
	rm -f ./*.snm
	rm -f ./*~
	#rm -f ./*.pdf
	rm -f ./*.gl*
	rm -f ./*.ist
	rm -f ./*.rel
	rm -f ./\#*
	rm -f ./*.tdo
	rm -f ./*.fdb_latexmk
	rm -f ./*.fls
	rm -rf ./figs/*.pdf
	rm -rf ./figs_orig/*.log
	rm -rf ./figs_orig/*.aux


view: $(MAIN).pdf
	@echo Currently using $(UNAME_S) 
	$(PDF_VIEWER) $(MAIN).pdf &

# continuous latex compilation
continous:
	make all
	latexmk -pvc -bibtex -pdf -view=none $(MAIN).tex
	
# Rules for original PDF figures
$(PDF_FIGS) : $(FIGS_DIR)/%.pdf: $(FIGS_ORIG_DIR)/%.pdf
	cp $< $@ 

# Rules for original JPG figures
$(JPG_FIGS) : $(FIGS_DIR)/%.jpg: $(FIGS_ORIG_DIR)/%.jpg
	cp $< $@ 

# Rules for original PNG figures
$(PNG_FIGS) : $(FIGS_DIR)/%.png: $(FIGS_ORIG_DIR)/%.png
	cp $< $@ 

# Rules for original EPS figures
GS_OPTS:= -dPDFX
$(EPS_FIGS) : $(FIGS_DIR)/%.pdf : $(FIGS_ORIG_DIR)/%.eps
        #Creates .pdf files from .esp files
	a2ping --gsextra='$(GS_OPTS)' --outfile=$@  $(<)

# Rules for Tikz and LaTeX figures
$(TIKZ_FIGS): $(FIGS_DIR)/%.pdf: $(FIGS_ORIG_DIR)/%.tex
	echo $(@F)
	mkdir -p $(FIGS_DIR)
	cd $(FIGS_ORIG_DIR); TEXINPUTS=:../ pdflatex $(*F);
	mv $(FIGS_ORIG_DIR)/$(@F) $@ 
	rm $(FIGS_ORIG_DIR)/*.log
	rm $(FIGS_ORIG_DIR)/*.aux

# Rules for SVG files
$(SVG_FIGS): $(FIGS_DIR)/%.pdf : $(FIGS_ORIG_DIR)/%.svg
	echo $<
	inkscape -z -D --export-pdf=$@ $(<)

# Rules for FIG files (xfig)
# Create combined pdf/latex figures from .fig file
$(XFIG_FIGS): $(FIGS_DIR)/%.pdf_t: $(FIGS_ORIG_DIR)/%.fig
	echo $*
	fig2dev -L pdftex -p dummy $(FIGS_ORIG_DIR)/$*.fig > $(FIGS_DIR)/$*.pdf
	fig2dev -L pdftex_t -p $(FIGS_DIR)/$* $(FIGS_ORIG_DIR)/$*.fig > $(FIGS_DIR)/$*.pdf_t 


$(MAIN).bbl : $(MAIN).tex $(BIBFILES)
	pdflatex $(MAIN).tex
	bibtex $(MAIN)

# annotated diff version
# compares from the version to the HEAD
# make diff version=<commit-hash>
# make diff version=e7de90d57864b2127096a8eb40ed16bcc366c9fc
diff:
	git latexdiff --quiet --cleanup keeppdf --main ./manuscript.tex $(version) HEAD
