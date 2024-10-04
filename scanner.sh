#!/bin/bash

echo "Entrez le temps d'intervalle des sauvegardes des états des processus (en secondes)"
read temps

echo "A partir de quelle pourcentage de consommation du CPU souhaitez vous créer une alerte ?"
read utilisation

if -e journalEtatProcessus.txt ; then
    echo " Le fichier de sauvegarde est déjà existant (journalEtatProcessus.txt)"
else 
    touch journalEtatProcessus.txt
    echo " Fichier de sauvegarde créé (journalEtatProcessus.txt)"
fi


enregistrer_etat_processus() {
    while true; do
        ps aux > journalEtatProcessus.txt
        sleep "$temps"
    done
}

enregistrer_etat_processus &

