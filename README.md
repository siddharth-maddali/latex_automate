# latex_automate
An assortment of macros I use to do a variety of LaTeX tasks, such as compiling, preparing uploading packages, preparing figures for publication

# Macro description

  1. `latexBuild`: Bash script to compile $\LaTeX$ document source files, into minimal package that can be uploaded anywhere, to journals and preprint servers. 
  Particularly useful for arXiv, which doesn't allow entire Bibtex databases to be uploaded, and usually requires a minimal set of references in a .bbl file.
  1. `processFigures.sh`: Starts with a pdf of images (usually prepared using Libreoffice Draw, in my case), does cropping and dumping of individual images to high-res jpegs, to be included in $\LaTeX$ documents.
