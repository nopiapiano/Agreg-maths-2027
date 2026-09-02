#!/bin/sh
# macOS : un double-clic sur ce fichier ouvre le Terminal et compile toutes les leçons (./lecon.sh all).
# Au premier lancement, si macOS refuse de l'ouvrir : clic droit > Ouvrir, une seule fois.
cd "$(dirname "$0")" && ./lecon.sh all
echo
echo "Terminé. Tu peux fermer cette fenêtre."
