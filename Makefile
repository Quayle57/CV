# LaTeX Makefile
FILE=		nicolas-dinquel-cv

all: 		$(FILE).pdf

.PHONY: 	clean
clean:
		rm -rf *.aux *.blg *.out *.bbl *.log *.bcf *.xml *~

fclean:		clean
		rm -rf $(FILE).pdf

re:		fclean all

$(FILE).pdf: 	$(FILE).tex
		xelatex $(FILE) ; biber $(FILE) ; xelatex $(FILE)
