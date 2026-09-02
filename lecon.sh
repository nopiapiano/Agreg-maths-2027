#!/bin/sh
# Compile une leçon du recueil toute seule (deux passes de pdflatex) et range le PDF :
#   ./lecon.sh 101                  -> Lecons/AG/101.pdf   (algèbre : leçons 1xx, lues dans 100/)
#   ./lecon.sh 201                  -> Lecons/AP/201.pdf   (analyse-probas : leçons 2xx, lues dans 200/)
#   ./lecon.sh DevAlg/baseburnside  -> DevAlg/baseburnside.pdf   (chemin explicite : PDF à côté du source)
# À lancer depuis la racine du recueil (le script s'y place tout seul).
set -e
if [ $# -ne 1 ]; then
	echo "usage : $0 <numéro de leçon | chemin/du/fichier sans .tex>" >&2
	exit 1
fi
cd "$(dirname "$0")"
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
		echo "Erreur de compilation : voir $dossier/$job.log" >&2
		exit 1
	fi
done
rm -f "$dossier/$job.aux" "$dossier/$job.log" "$dossier/$job.out"
echo "-> $dossier/$job.pdf"
