#!/bin/bash

# Afficher le menu
options=("PC-1" "PC-2" "PC-3" "Quitter")
select opt in "${options[@]}"
do
    case $opt in
    "PC-1")
        user=$(ssh -o StrictHostKeyChecking=no pc1 "basename /home/*")
        rm -rf /home/debian/SDETL_Project/home/$user
        scp -r -o StrictHostKeyChecking=no pc1:/home/$user /home/debian/SDETL_Project/home/ > /dev/null 2>&1

        ssh -o StrictHostKeyChecking=no pc1 << EOF > /dev/null 2>&1
        sudo apt-get remove --purge -y --force grub*
        sudo rm -rf /boot/grub
        sudo dd if=/dev/zero of=/dev/sda bs=446 count=1
        sudo reboot
EOF

        ssh-keygen -f "/home/debian/.ssh/known_hosts" -R "10.0.0.2" > /dev/null 2>&1
        echo "PC-1 a été reset "
        ;;
    "PC-2")
        user=$(ssh -o StrictHostKeyChecking=no pc2 "basename /home/*")
        rm -rf /home/debian/SDETL_Project/home/$user
        scp -r -o StrictHostKeyChecking=no pc2:/home/$user /home/debian/SDETL_Project/home/ > /dev/null 2>&1

        ssh -o StrictHostKeyChecking=no pc2 << EOF > /dev/null 2>&1
        sudo apt-get remove --purge -y --force grub*
        sudo rm -rf /boot/grub
        sudo dd if=/dev/zero of=/dev/sda bs=446 count=1
        sudo reboot
EOF

        ssh-keygen -f "/home/debian/.ssh/known_hosts" -R "10.0.0.3" > /dev/null 2>&1
        echo "PC-2 a été reset "
        ;;
    "PC-3")
        user=$(ssh -o StrictHostKeyChecking=no pc3 "basename /home/*")
        rm -rf /home/debian/SDETL_Project/home/$user
        scp -r -o StrictHostKeyChecking=no pc3:/home/$user /home/debian/SDETL_Project/home/ > /dev/null 2>&1

        ssh -o StrictHostKeyChecking=no pc3 << EOF > /dev/null 2>&1
        sudo apt-get remove --purge -y --force grub*
        sudo rm -rf /boot/grub
        sudo dd if=/dev/zero of=/dev/sda bs=446 count=1
        sudo reboot
EOF

        ssh-keygen -f "/home/debian/.ssh/known_hosts" -R "10.0.0.4" > /dev/null 2>&1
        echo "PC-3 a été reset "
        ;;
    "Quitter")
        exit 0
        ;;
    *)
        echo "Option invalide"
        exit 1
        ;;
    esac

done
;;
