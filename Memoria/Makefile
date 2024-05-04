# Nombre del documento sin la extensión
DOCNAME = Memoria

# Compilador de LaTeX
COMPILER = pdflatex
BIBTEX=bibtex

# Opciones del compilador
# -shell-escape permite la ejecución de comandos externos, necesario si usas el paquete minted
COMPILER_OPTS = -shell-escape

# Limpia archivos auxiliares
CLEAN = rm -f $(DOCNAME).aux $(DOCNAME).log $(DOCNAME).out $(DOCNAME).toc $(DOCNAME).lof $(DOCNAME).lot $(DOCNAME).bbl $(DOCNAME).blg $(DOCNAME).idx $(DOCNAME).ind $(DOCNAME).ilg $(DOCNAME).synctex.gz

# Por defecto, hacer todo
all: $(DOCNAME).pdf

# Cómo construir el PDF
$(DOCNAME).pdf: $(DOCNAME).tex
	$(COMPILER) $(COMPILER_OPTS) $(DOCNAME).tex
	$(COMPILER) $(COMPILER_OPTS) $(DOCNAME).tex  # Segunda compilación para referencias cruzadas
	$(BIBTEX) $(DOCNAME)
	$(COMPILER) $(COMPILER_OPTS) $(DOCNAME).tex
	$(COMPILER) $(COMPILER_OPTS) $(DOCNAME).tex

# Comando para limpiar los archivos auxiliares
clean:
	$(CLEAN)

# Comando para limpiar todo, incluido el PDF
distclean:
	$(CLEAN)
	rm -f $(DOCNAME).pdf

# Evita problemas con archivos que puedan tener nombres conflictivos
.PHONY: all clean distclean

