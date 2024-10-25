#!/bin/bash

echo "Entrez le temps dintervalle des sauvegardes des états des processus (en secondes)"
read temps

#Création du fichier journalEtatProcessus.txt si non existant
if [[ -e journalEtatProcessus.txt ]]; then
    echo "Le fichier de sauvegarde est déjà existant (journalEtatProcessus.txt)"
else 
    touch journalEtatProcessus.txt
    echo "Fichier de sauvegarde créé (journalEtatProcessus.txt)"
fi

#Création du fichier process_suspects.log si non existant
if [[ -e process_suspects.log ]]; then
    echo "Le fichier process_suspects.log est déjà existant"
    echo "" > process_suspects.log
else 
    touch process_suspects.log
    echo "Fichier process_suspects.log créé "
fi

enregistrer_etat_processus() {
    while true; do
        ps aux > journalEtatProcessus.txt   #Enregistre tout les $temps dans le journal le aux
        sleep "$temps"
        echo "sauvgarde du journal"
    done
}

detecter_anomalies() {
    echo "détection en cours";
    while true; do
        mapfile -t lignes < journalEtatProcessus.txt    #Chaque ligne du aux
        for line in "${lignes[@]}"; do
            if [[ $line == *"USER"* ]]; then
                continue
            fi  
            pid=$(echo "$line" | awk '{print $2}')
            comm=$(echo "$line" | awk '{print $11}')
            user=$(echo "$line" | awk '{print $1}')
            cpu=$(echo "$line" | awk '{print $3}')

            if (( $(echo "$cpu > 80" | bc -l) )); then  #Détection si cpu trop élevé
                echo "$(date) - Anomalie : Utilisation CPU élevée - PID: $pid, Processus: $comm, Utilisateur: $user, CPU: $cpu%" > journalEtatProcessus.txt
                if [[ $user != "root" ]]; then
                    gerer_anomalie "$pid" "$comm" "$user" "$cpu" "Utilisation CPU élevée"
                fi
            elif [[ $(echo "$line" | awk '{print $8}') == "Z" ]]; then  #Détection si process zombie
                echo "$(date) - Anomalie : Processus zombie détecté - PID: $pid, Processus: $comm, Utilisateur: $user" >> journalEtatProcessus.txt
                if [[ $user != "root" ]]; then
                    gerer_anomalie "$pid" "$comm" "$user" "$cpu" "Processus zombie détecté"
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
    read choix  < /dev/tty  #choix de l'utilisateur pour l'action à prendre
    

    if [[ "$choix" =~ ^[1-3]$ ]]; then
        echo "Vous avez choisi : $choix"

        case "$choix" in
            1)
                echo "Tentative de tuer le processus $pid..."
                echo "Sauvegarde des informations du processus $pid avant de le tuer..."
                ps -p "$pid" -o pid,comm,user,%mem,%cpu,state >> "process_suspects.log"
                if kill -0 "$pid" 2>/dev/null; then #On regarde si le process existe toujours
                    kill -9 "$pid"  #Si oui on le tue
                    if [[ ! -e "process_suspects.log" ]]; then
                        touch "process_suspects.log"
                    fi
                    echo "Processus $pid tué."
                    echo "Processus $pid tué." >> "process_suspects.log"
                else
                    echo "Le processus $pid n'existe plus."
                    echo "Le processus $pid n'existe plus." >> "process_suspects.log"
                fi
                ;;
            2)
                renice 10 "$pid"    #renice du process
                echo "Priorité du processus $pid baissée."
                echo "Priorité du processus $pid baissée." >> "process_suspects.log"
                ;;
            3)
                echo "Processus $pid ignoré."
                echo "Processus $pid ignoré." >> "process_suspects.log"
                ;;
            *)
                echo "Choix invalide."
                echo "Choix invalide." >> "process_suspects.log"
                ;;
        esac    
    fi

}

generer_rapport_quotidien() {
    local rapport="rapport_quotidien_$(date +%Y-%m-%d).log"
    echo "Rapport quotidien pour le $(date +%Y-%m-%d)" > "$rapport"
    echo "----------------------------------------" >> "$rapport"
    cat process_suspects.log >> "$rapport"
    echo "Rapport généré : $rapport"
}

# Appel des fonctions en parallèle
enregistrer_etat_processus &
detecter_anomalies &

wait

# Appel de la fonction pour générer le rapport quotidien
generer_rapport_quotidien