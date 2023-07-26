TARGET=main
BUILD_DIR ?= build

SOURCE_FORMAT='markdown$\
+pipe_tables$\
+backtick_code_blocks$\
+auto_identifiers$\
+strikeout$\
+yaml_metadata_block$\
+implicit_figures$\
+all_symbols_escapable$\
+link_attributes$\
+smart$\
+fenced_divs$\
+fenced_code_attributes$\
+tex_math_single_backslash'

FILTERS=./listing.py

PANDOC_FLAGS =\
	-f $(SOURCE_FORMAT) \
	$(patsubst %,--filter %, $(FILTERS)) \
	-t beamer \
	--no-highlight

	# --toc \
	# --slide-level 1 \

PDF_ENGINE = lualatex
PANDOCVERSIONGTEQ2 := $(shell expr `pandoc --version | grep ^pandoc | sed 's/^.* //g' | cut -f1 -d.` \>= 2)
LATEX_FLAGS += -pdflatex=$(PDF_ENGINE) \
							 -shell-escape

all: $(patsubst %.md,%.pdf,$(wildcard *.md))

# Generalized rule: how to build a .pdf from each .md
%.pdf: %.tex %.md
	@mkdir -p $(@D)/$(BUILD_DIR)
	latexmk $(LATEX_FLAGS) -output-directory=$(@D)/$(BUILD_DIR) $<
	cp $(@D)/$(BUILD_DIR)/$@ $(@D)

# Generalized rule: how to build a .tex from each .md
%.tex: %.md beamercolorthemesolarized.sty beamer-includes.tex
	pandoc --standalone $(PANDOC_FLAGS) -o $@ $<

touch:
	touch *.md

again: touch all

clean:
	cd $(BUILD_DIR)
	rm -f *.fdb_latexmk *.fls *.aux *.log *.nav *.out *.snm *.toc *.vrb || true

distclean:
	rm -rf $(BUILD_DIR)

view: $(TARGET).pdf
	if [ "Darwin" = "$(shell uname)" ]; then open $(TARGET).pdf ; else xdg-open $(TARGET).pdf ; fi

print: $(TARGET).pdf
	lpr $(TARGET).pdf

.PHONY: all again touch clean veryclean view print
