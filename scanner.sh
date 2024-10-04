#!/bin/bash

echo "Entrez le temps d'intervalle des sauvegardes des états des processus (en secondes)"
read temps

if -e journalEtatProcessus.txt ; then
    echo " Le fichier de sauvegarde est déjà existant (journalEtatProcessus.txt)"
else 
    touch save/journalEtatProcessus.txt
    echo " Fichier de sauvegarde créé (journalEtatProcessus.txt)"
fi


enregistrer_etat_processus() {
    while true; do
        ps aux > journalEtatProcessus.txt
        sleep "$temps"
    done
}

enregistrer_etat_processus &

