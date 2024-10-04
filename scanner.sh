#!/bin/bash

echo "A partir de quelle pourcentage de consommation du CPU souhaitez vous créer une alerte ?"
read utilisation

touch journalEtatProcessus.txt
ps aux > journalEtatProcessus.txt