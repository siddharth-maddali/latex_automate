#!/bin/bash -f


# Initial preparation
CC=$( which pdflatex )
BB=$( which bibtex )
EXPAND=$( which latexpand )
ROOT=$( echo $1 | sed "s#\.tex##g" )
NULL=/dev/null
ZIP=$( which zip )
HERE=$( pwd )

######################### Custom routines #######################################

function switchTextToBibtex() {
	# switch back from using .bbl file to using bibtex file in case
	# this is being done.
	sed -i 's/%\\bibliographystyle{/\\bibliographystyle{/' $ROOT.tex
	sed -i 's/%\\bibliography{/\\bibliography{/' $ROOT.tex
	sed -i 's/\\input{'$ROOT'.bbl/%\\input{'$ROOT'.bbl/' $ROOT.tex
}

function compileSequence() {
	# compile assuming .bib file is being used
	$CC $ROOT.tex 
	$BB $ROOT.aux 
	$CC $ROOT.tex 
	$CC $ROOT.tex
}

function switchBackToPureLatex() {
	# modify main file to use generated .bbl file
	# Make sure there's a commented line that inputs the .bbl file.
	sed -i 's/\\bibliographystyle{/%&/' $ROOT.tex
	sed -i 's/\\bibliography{/%&/' $ROOT.tex
	sed -i 's/%\\input{'$ROOT'.bbl/\\input{'$ROOT'.bbl/' $ROOT.tex
}

function createUploadPackage() {
	# creating upload package. This contains lean set of 
	# source files free of auxiliary files like inputs and bibs
	[ -d "./upload_$ROOT" ] && rm -rf upload_$ROOT
	[ -e "./upload_$ROOT.zip" ] && rm upload_$ROOT.zip
	mkdir upload_$ROOT
	bash -c "$EXPAND $ROOT.tex > upload_$ROOT/$ROOT.tex 2>$NULL"
	bash -c "cp $HERE/*.jpg upload_$ROOT/"		# for some reason, this
	bash -c "cp $HERE/*.sty upload_$ROOT/"		# is the only way to get 
	bash -c "cp $HERE/*.cls upload_$ROOT/"		# this to work...
	cp $HERE/$ROOT.bbl upload_$ROOT/
	cp $HERE/coverLetter*.pdf upload_$ROOT/
	$ZIP -r upload_$ROOT.zip upload_$ROOT/
}

###############################################################################

switchTextToBibtex
compileSequence
switchBackToPureLatex
$CC $ROOT.tex
createUploadPackage
