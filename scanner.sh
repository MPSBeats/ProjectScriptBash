#!/bin/bash

echo "Entrez le temps d'intervalle des sauvegardes des états des processus (en secondes) :"
read temps

if [[ -e journalEtatProcessus.txt ]]; then
    echo "Le fichier de sauvegarde est déjà existant (journalEtatProcessus.txt)"
else 
    touch journalEtatProcessus.txt
    echo "Fichier de sauvegarde créé (journalEtatProcessus.txt)"
fi

enregistrer_etat_processus() {
    while true; do
        ps aux > journalEtatProcessus.txt
        sleep "$temps"
    done
}

detecter_anomalies() {
    while true; do
        while read -r line; do
            if [[ $line == *"USER"* ]]; then
                continue
            fi

            pid=$(echo "$line" | awk '{print $2}')
            comm=$(echo "$line" | awk '{print $11}')
            user=$(echo "$line" | awk '{print $1}')
            cpu=$(echo "$line" | awk '{print $3}')

            if (( $(echo "$cpu > 80" | bc -l) )); then
                echo "$(date) - Anomalie : Utilisation CPU élevée - PID: $pid, Processus: $comm, Utilisateur: $user, CPU: $cpu%" >> journalEtatProcessus.txt
                gerer_anomalie "$pid" "$comm" "$user" "$cpu" "Utilisation CPU élevée"
            fi
        done < journalEtatProcessus.txt
        sleep "$temps"
    done
}

gerer_anomalie() {
    local pid="$1"
    local comm="$2"
    local user="$3"
    local cpu="$4"
    local type="$5"

    echo "Anomalie détectée : $type"
    echo "PID: $pid, Processus: $comm, Utilisateur: $user, CPU: $cpu%"
    echo "Quelle action souhaitez-vous entreprendre ?"
    echo "1. Tuer le processus"
    echo "2. Baisser la priorité (renice)"
    echo "3. Ignorer"
    read -p "Entrez votre choix (1/2/3) : " choix

    case "$choix" in
        1)
            echo "Sauvegarde des informations du processus $pid avant de le tuer..."
            ps -p "$pid" -o pid,comm,user,%mem,%cpu,state >> /var/log/process_suspects.log
            kill "$pid"
            echo "Processus $pid tué." >> journalEtatProcessus.txt
            ;;
        2)
            renice 10 "$pid"
            echo "Priorité du processus $pid baissée." >> journalEtatProcessus.txt
            ;;
        3)
            echo "Processus $pid ignoré." >> journalEtatProcessus.txt
            ;;
        *)
            echo "Choix invalide." >> journalEtatProcessus.txt
            ;;
    esac
}

enregistrer_etat_processus &
detecter_anomalies &

wait
