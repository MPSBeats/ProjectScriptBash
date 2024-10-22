#!/bin/bash

<<<<<<< HEAD
echo "Entrez le temps dintervalle des sauvegardes des états des processus (en secondes)"
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
        echo "sauvgarde du journal"
    done
}

detecter_anomalies() {
    echo "détection en cours";
    while true; do
        mapfile -t lignes < journalEtatProcessus.txt
        for line in "${lignes[@]}"; do
            if [[ $line == *"USER"* ]]; then
                continue
            fi  
            pid=$(echo "$line" | awk '{print $2}')
            comm=$(echo "$line" | awk '{print $11}')
            user=$(echo "$line" | awk '{print $1}')
            cpu=$(echo "$line" | awk '{print $3}')

            if (( $(echo "$cpu > 80" | bc -l) )); then
                echo "$(date) - Anomalie : Utilisation CPU élevée - PID: $pid, Processus: $comm, Utilisateur: $user, CPU: $cpu%" > journalEtatProcessus.txt
                if [[ $user != "root" ]]; then
                    gerer_anomalie "$pid" "$comm" "$user" "$cpu" "Utilisation CPU élevée"
                fi
            fi
        done
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

    echo "Entrez votre choix (1/2/3) : "
    read choix  < /dev/tty
    

    if [[ "$choix" =~ ^[1-3]$ ]]; then
        echo "Vous avez choisi : $choix"

        case "$choix" in
            1)
                echo "Tentative de tuer le processus $pid..."
                echo "Sauvegarde des informations du processus $pid avant de le tuer..."
                ps -p "$pid" -o pid,comm,user,%mem,%cpu,state >> "$HOME/process_suspects.log"
                if kill -0 "$pid" 2>/dev/null; then
                    kill -9 "$pid"
                    if [[ ! -e "$HOME/process_monitor.log" ]]; then
                        touch "$HOME/process_monitor.log"
                    fi
                    echo "Processus $pid tué."
                    echo "Processus $pid tué." >> "$HOME/process_monitor.log"
                else
                    echo "Le processus $pid n'existe plus."
                    echo "Le processus $pid n'existe plus." >> "$HOME/process_monitor.log"
                fi
                ;;
            2)
                renice 10 "$pid"
                echo "Priorité du processus $pid baissée."
                echo "Priorité du processus $pid baissée." >> journalEtatProcessus.txt
                ;;
            3)
                echo "Processus $pid ignoré."
                echo "Processus $pid ignoré." >> journalEtatProcessus.txt
                ;;
            *)
                echo "Choix invalide."
                echo "Choix invalide." >> journalEtatProcessus.txt
                ;;
        esac    
    fi

}

enregistrer_etat_processus &
detecter_anomalies &

wait
=======
echo "A partir de quelle pourcentage de consommation du CPU souhaitez vous créer une alerte ?"
read utilisation

touch journalEtatProcessus.txt
ps aux > journalEtatProcessus.txt
>>>>>>> 9539ab4fb02c749dffd674707f364417d5944e70
