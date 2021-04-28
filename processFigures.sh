#!/bin/bash

FIGBOOK=./figureBook
FIGPREF=figure

pdfcrop $FIGBOOK.pdf $FIGBOOK.pdf
pdftoppm $FIGBOOK.pdf $FIGPREF -jpeg
