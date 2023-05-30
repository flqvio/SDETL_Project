#!/usr/bin/env python3
import cgi
import csv
import mysql.connector
import subprocess

# Configuration de la base de données
db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': 'toor',
    'database': 'sdetl_database'
}

ip_mapping = {
    'PC-1': '10.0.0.2',
    'PC-2': '10.0.0.3',
    'PC-3': '10.0.0.4'
}

packages = {
    'Mozilla Firefox': 'firefox',
    'LibreOffice': 'libreoffice',
    'VLC': 'vlc',
    'virt-manager': 'virt-manager',
    'Transmission': 'transmission',
    'GParted': 'gparted',
    'Audacity': 'audacity',
    'FileZilla': 'filezilla',
    'Remmina': 'remmina',
    'Asterisk': 'asterisk',
    'GCC': 'build-essential',
    'Apache2': 'apache2',
    'Visual Studio Code': 'code'
}

# Récupération des données du formulaire
form = cgi.FieldStorage()
login = form.getvalue('login')
password = form.getvalue('password')
applications = form.getlist('applications')
poste = form.getvalue('poste')

# Connexion à la base de données
try:
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()

    # Exécution de la requête pour vérifier les informations de connexion
    cursor.execute("SELECT COUNT(*) FROM informations WHERE login = %s AND password = %s", (login, password))
    result = cursor.fetchone()[0]

    if result == 1:
        
        # Supprimer les lignes existantes pour l'utilisateur et le poste choisis dans le fichier CSV
        lines_to_keep = []
        with open('/var/www/html/script/user_association_pc.txt', 'r') as file:
            reader = csv.reader(file, delimiter=';')
            for row in reader:
                if not row or (login in row) or (poste in row):
                    continue
                lines_to_keep.append(row)

        # Écrire les lignes à conserver dans le fichier CSV
        with open('/var/www/html/script/user_association_pc.txt', 'w', newline='') as file:
            writer = csv.writer(file, delimiter=';')
            for row in lines_to_keep:
                writer.writerow(row)

        # Ajouter la nouvelle ligne pour l'utilisateur et le poste choisis
        with open('/var/www/html/script/user_association_pc.txt', 'a', newline='') as file:
            writer = csv.writer(file, delimiter=';')
            writer.writerow([login, poste, ip_mapping.get(poste), ' '.join(packages[app] for app in applications)])
        
        print("Content-Type: text/html")
        print()
        with open('test.html') as f:
            html_content = f.read()
            alert_message = """<div class="goodalert">
                <h2>Récapitulatif du formulaire</h2>
                <p>Login : {0}</p>""".format(login)
            alert_message += "<p>Applications :</p><ul>"
            for app in applications:
                alert_message += "<li>{0}</li>".format(app)
            alert_message += "</ul>"
            alert_message += "<p>Poste de travail : {0}</p>".format(poste)
            alert_message += "</div>"

            modified_html_content = html_content.replace("""<div class="alert"></div>""", alert_message)
            print(modified_html_content)
            
        
        cmd = "/home/debian/SDETL_Project/redemarrer_automatiquement.sh " + poste
        process = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE)
        output, error = process.communicate()
        

    else:
        print("Content-Type: text/html")
        print()
        with open('test.html') as f:
            html_content = f.read()
            alert_message = """<div class="badalert">Identifiants invalides !</div>"""
            modified_html_content = html_content.replace("""<div class="alert"></div>""", alert_message)
            print(modified_html_content)

except mysql.connector.Error as e:
    
    print("Content-Type: text/html")
    print()
    with open('test.html') as f:
            html_content = f.read()
            alert_message = """<div class="badalert">Une erreur s'est produite lors de la connexion à la base de données.</div>"""
            modified_html_content = html_content.replace("""<div class="alert"></div>""", alert_message)
            print(modified_html_content)
            
finally:
    # Fermeture de la connexion à la base de données
    if cursor:
        cursor.close()
    if conn:
        conn.close()
