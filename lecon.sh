#!/bin/sh
# Compile une leçon du recueil toute seule (deux passes de pdflatex) et range le PDF :
#   ./lecon.sh 101                  -> Lecons/AG/101.pdf   (algèbre : leçons 1xx, lues dans 100/)
#   ./lecon.sh 201                  -> Lecons/AP/201.pdf   (analyse-probas : leçons 2xx, lues dans 200/)
#   ./lecon.sh DevAlg/baseburnside  -> DevAlg/baseburnside.pdf   (chemin explicite : PDF à côté du source)
#   ./lecon.sh all                  -> toutes les leçons de 100/ et 200/
# À lancer depuis la racine du recueil (le script s'y place tout seul).
if [ $# -ne 1 ]; then
	echo "usage : $0 <numéro de leçon | chemin/du/fichier sans .tex | all>" >&2
	exit 1
fi
cd "$(dirname "$0")" || exit 1

# compile_une <numéro | chemin sans .tex> : compile et écrit le PDF au bon endroit.
compile_une() {
	case "$1" in
		*/*)
			job="$(basename "$1")"; dossier="$(dirname "$1")"; def="\\def\\fichier{$1}" ;;
		*)
			job="$1"; def="\\def\\numlecon{$1}"
			if [ "$1" -lt 200 ]; then dossier="Lecons/AG"; else dossier="Lecons/AP"; fi ;;
	esac
	mkdir -p "$dossier"
	for passe in 1 2; do
		if ! pdflatex -interaction=nonstopmode -halt-on-error -output-directory="$dossier" -jobname="$job" "$def\\input{lecon}" > /dev/null; then
			echo "Erreur de compilation ($1) : voir $dossier/$job.log" >&2
			return 1
		fi
	done
	rm -f "$dossier/$job.aux" "$dossier/$job.log" "$dossier/$job.out"
	echo "-> $dossier/$job.pdf"
}

if [ "$1" != "all" ]; then
	compile_une "$1"
	exit $?
fi

# all : toutes les leçons de 100/ et 200/ (fichiers <numéro>.tex), échecs listés à la fin.
echecs=""
for f in 100/*.tex 200/*.tex; do
	[ -e "$f" ] || continue
	num="$(basename "$f" .tex)"
	case "$num" in
		*[!0-9]*) echo "ignoré : $f (le nom n'est pas un numéro de leçon)" >&2; continue ;;
	esac
	compile_une "$num" || echecs="$echecs $num"
done
if [ -n "$echecs" ]; then
	echo "Leçons en échec :$echecs" >&2
	exit 1
fi
