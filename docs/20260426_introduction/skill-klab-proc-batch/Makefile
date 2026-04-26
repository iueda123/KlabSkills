CHROME_BIN ?= google-chrome
QMD        := slides.qmd
HTML       := slides.html
PDF        := slides.pdf

.PHONY: all html pdf pdf-force preview clean

all: html pdf

html: $(HTML)
pdf: $(PDF)
pdf-force: clean $(PDF)

$(HTML): $(QMD)
	quarto render $(QMD) --to revealjs

$(PDF): $(HTML)
	$(CHROME_BIN) \
	  --headless --disable-gpu --no-sandbox --disable-dev-shm-usage \
	  --print-to-pdf="$$(pwd)/$(PDF)" \
	  "file://$$(pwd)/$(HTML)?print-pdf"

preview:
	quarto preview $(QMD)

clean:
	rm -f $(HTML) $(PDF)
