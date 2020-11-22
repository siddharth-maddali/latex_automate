#!/bin/bash

FIGBOOK=./figureBook.pdf
FIGPREF=figure

pdfcrop $FIGBOOK $FIGBOOK
pdftoppm $FIGBOOK $FIGPREF -jpeg
