#!/bin/bash -f

# Initial preparation
LERR="ERROR"
LWRN="WARNING"
CC=$( which pdflatex )
BB=$( which bibtex )
EXPAND=$( which latexpand )
ROOT=$( echo $1 | sed "s#\.tex##g" )
REPO=$( echo $2 )
NAME=$( echo $REPO | tr '/' '\n' | tail -n1 )
ZIP=$( which zip )
HERE=$( pwd )
TRASH=/dev/null
FILELIST=files_$ROOT.log
GIT=$( which git )

######################### Custom routines #######################################

function sanityCheck(){ 
	if [[ -z $CC ]]; then echo $LERR: Latex compiler not found.; exit 1; else echo "$CC found."; fi
	if [[ -z $BB ]]; then echo $LERR: Bibtex not found.; exit 1; else echo "$BB found."; fi
	if [[ -z $EXPAND ]]; then echo $LERR: Latexpand not found.; exit 1; else echo "$EXPAND found."; fi
	if [[ -z $ZIP ]]; then echo $LERR: zip not found.; exit 1; else echo "$ZIP found."; fi
	if [[ -z $TRASH ]]; then echo $LERR: /dev/null not found.; exit 1; else echo "$TRASH found."; fi
	if [[ -z $GIT ]]; then echo $LERR: git not found.; exit 1; else echo "$GIT found."; fi
}

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
	$CC $ROOT.tex |\
		awk '/ \*File List\*/{flag=1;next}/\*\*\*\*\*\*\*\*\*\*\*/{flag=0}flag {print $1; }' |\
		xargs -I '{}' bash -c "ls {} 2>$TRASH" |\
		grep -v "\.tex$\|\.out$\|\.aux$" > $FILELIST
}

function switchBackToPureLatex() {
	# modify main file to use generated .bbl file
	# Make sure there's a commented line that inputs the .bbl file.
	sed -i 's/\\bibliographystyle{/%&/' $ROOT.tex
	sed -i 's/\\bibliography{/%&/' $ROOT.tex
	sed -i 's/%\\input{'$ROOT'.bbl/\\input{'$ROOT'.bbl/' $ROOT.tex
}

function updateUploadDirectory() { 
	[[ -d "./upload_$ROOT" ]] && rm ./upload_$ROOT/*.*
	[[ -e "./upload_$ROOT.zip" ]] && rm ./upload_$ROOT.zip
	bash -c "\
		$EXPAND $ROOT.tex > upload_$ROOT/$ROOT.tex 2>$TRASH && \
		cat $FILELIST | cpio -pdm upload_$ROOT/ \
	"
	$ZIP -r upload_$ROOT.zip upload_$ROOT/
}

function createUploadPackage() {
	if [[ -d "./upload_$ROOT" ]]; then  
		updateUploadDirectory
	else
		if [[ -z "$REPO" ]]; then
			echo $LWRN: remote git repository not provided.
			mkdir upload_$ROOT
		else
			$GIT clone $REPO
			mv $NAME upload_$ROOT
		fi
		updateUploadDirectory
	fi
}

###############################################################################
grep "^\\\\listfiles$" $ROOT.tex
if [[ $? -eq 0 ]]; then
	sanityCheck
	switchTextToBibtex
	compileSequence
	switchBackToPureLatex
	$CC $ROOT.tex
	createUploadPackage
else
	echo $LERR: $ROOT.tex does not contain command \\listfiles at the top.
fi
