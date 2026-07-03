# Préparer votre environnement Prospectius

Ce guide vous explique comment installer Prospectius sur votre ordinateur. Nous avons conçu ce processus pour qu'il soit le plus simple possible, que vous soyez un professionnel ou un passionné d'informatique.

---

## 🏗️ Étape 1 : Choisir votre moteur de stockage

Prospectius a besoin d'un espace sécurisé pour conserver vos données commerciales sur votre propre machine. Nous utilisons pour cela **MariaDB**, un moteur de base de données reconnu pour sa fiabilité.

### Pour Windows 🪟
1. Téléchargez l'installateur sur [mariadb.org](https://mariadb.org/download/).
2. Lancez l'installation et suivez les étapes par défaut.
3. Notez bien le mot de passe "root" que vous allez définir.

### Pour Linux 🐧
Ouvrez votre terminal et installez le moteur avec ces commandes :
```bash
sudo apt update
sudo apt install mariadb-server
sudo systemctl start mariadb
```

---

## 📊 Étape 2 : Préparer vos données

Une fois le moteur installé, il faut lui donner la structure nécessaire pour accueillir Prospectius.
1. Téléchargez le fichier `Prospectius.sql` fourni avec l'application.
2. Dans votre terminal ou invite de commande, lancez l'importation :
   ```bash
   mysql -u root -p < Prospectius.sql
   ```
   *(On vous demandera le mot de passe que vous avez choisi à l'étape 1)*.

---

## 🚀 Étape 3 : Lancer Prospectius

### Première utilisation
Lors du tout premier lancement, Prospectius vous demandera de "brancher" votre base de données. 
- **Hôte** : Saisissez `localhost` (votre ordinateur).
- **Port** : Laissez `3306` (le port standard).
- **Utilisateur** : `root`.
- **Mot de passe** : Celui que vous avez choisi à l'étape 1.

### Créer votre espace de travail
Une fois connecté, cliquez sur **"S'inscrire"**. Cela créera votre profil de gestionnaire local. Vos données ne quittent jamais votre ordinateur.

---

## 👨‍💻 Pour les Développeurs (Installation avancée)

Si vous souhaitez modifier Prospectius, voici la marche à suivre :

1. **Préparez vos outils** : Installez le kit de développement **Flutter (3.16+)**.
2. **Récupérez le code** :
   ```bash
   git clone https://github.com/josoavj/ProspectiusFinal.git
   cd ProspectiusFinal
   flutter pub get
   ```
3. **Lancez la compilation** :
   ```bash
   # Pour Windows
   flutter run -d windows
   # Pour Linux
   flutter run -d linux
   ```

---

## 🛠️ Un problème d'installation ?

### "Le moteur de données ne répond pas"
Vérifiez que MariaDB est bien actif. Sur Windows, tapez "Services" dans le menu démarrer et vérifiez que MariaDB est sur "Démarré".

### "Erreur d'identifiants"
Assurez-vous que l'utilisateur est bien `root` et que le mot de passe correspond à celui saisi lors de l'installation du moteur de base de données.

---

*Besoin d'aide supplémentaire ? Consultez notre [Foire Aux Questions](./README.md#troubleshooting).*
