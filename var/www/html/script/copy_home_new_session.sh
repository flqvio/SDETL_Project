#!/bin/bash

# Définir les variables pour les nouveaux utilisateurs
USER1="user1"
PASSWORD1="mdp"
GROUPS1="user1"

USER2="user2"
PASSWORD2="mdp"
GROUPS2="user2"

USER3="user3"
PASSWORD3="mdp"
GROUPS3="user3"

addgroup "$GROUPS1"
addgroup "$GROUPS2"
addgroup "$GROUPS3"

# Créer les utilisateurs
useradd -m -s /bin/bash -g "$GROUPS1" "$USER1"
echo "$USER1:$PASSWORD1" | chpasswd

useradd -m -s /bin/bash -g "$GROUPS2" "$USER2"
echo "$USER2:$PASSWORD2" | chpasswd

useradd -m -s /bin/bash -g "$GROUPS3" "$USER3"
echo "$USER3:$PASSWORD3" | chpasswd

chage -d 0 "$USER1"
chage -d 0 "$USER2"
chage -d 0 "$USER3"

wget -P /root/ wget http://10.0.0.1/script/user_association_pc.txt
my_ip=$(ip addr show enp0s3 | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)

# Lecture du fichier exemple_user_pc.txt
while read -r line
do
    touch /var/log/test.txt
    echo "apt update" >> /var/log/test.txt 2>&1
    apt update >> /var/log/test.txt 2>&1

    # Séparation des champs utilisateur, pc et adresse IP
    username=$(echo $line | cut -d ";" -f 1)
    pc=$(echo $line | cut -d ";" -f 2)
    ip=$(echo $line | cut -d ";" -f 3)
    paquet=$(echo $line | cut -d ";" -f 4)
    
    # Vérification si l'adresse IP est présente sur le système
    if [ "$my_ip" = "$ip" ]; then
        # Vérifier si le mot "code" est présent dans la ligne
        if echo "$paquet" | grep -q "code"; then
            # Supprimer le mot "code" de la ligne
            paquet=$(echo "$paquet" | sed 's/code//g')
            echo "download vsc:\n\n" >> /var/log/test.txt 2>&1
            wget -P /root/ http://10.0.0.1/script/vsc.deb
            dpkg -i /root/vsc.deb >> /var/log/test.txt 2>&1
        fi
        echo "apt install $paquet -y" >> /var/log/test.txt 2>&1
        apt install -y $paquet  >> /var/log/test.txt 2>&1
        apt --fix-broken -y install >> /var/log/test.txt 2>&1
        rm -rf /home/*
        scp -o StrictHostKeyChecking=no -r debian@10.0.0.1:/home/debian/SDETL_Project/home/$username /home/
    fi
    echo $username $my_ip $ip
done < "/root/user_association_pc.txt"

exit 0
