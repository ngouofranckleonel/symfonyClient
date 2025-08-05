# Formulaire de Client Robuste et Adaptatif

## Description

Formulaire d'enregistrement client développé avec **Symfony**, **HTML**, **CSS** et **JavaScript** (aucun framework frontend), respectant intégralement les exigences du cahier des charges.

## 📋 Livrables Fournis

Conformément aux exigences, le projet contient exactement les fichiers demandés :

- ✅ **index.html** - Formulaire HTML principal
- ✅ **style.css** - Styles CSS avec thème adaptatif
- ✅ **script.js** - JavaScript pour validation client et fonctionnalités
- ✅ **User.php** - Entité utilisateur avec contraintes de validation
- ✅ **UserController.php** - Contrôleur Symfony pour validation serveur
- ✅ **Dockerfile** - Configuration Docker
- ✅ **docker-compose.yml** - Orchestration des services

## 🚀 Instructions pour Lancer le Projet

### Prérequis
- Docker et Docker Compose installés
- Port 8080 disponible

### Installation et Lancement

\`\`\`bash
# 1. Cloner le projet
git clone <votre-repo>
cd symfony-client-form

# 2. Construire et lancer les conteneurs
docker-compose up --build -d

# 3. Installer les dépendances Symfony
docker-compose exec web composer install

# 4. Configurer les permissions
docker-compose exec web chown -R www-data:www-data /var/www/html/var

# 5. Accéder à l'application
# URL: http://localhost:8080
\`\`\`

### Vérification de l'Installation

\`\`\`bash
# Vérifier que les conteneurs sont actifs
docker-compose ps

# Tester l'accès à l'application
curl -I http://localhost:8080
\`\`\`

## 📊 Règles de Validation

| Champ | Type | Règles de Validation |
|-------|------|---------------------|
| **Nom complet** | Texte | Obligatoire, entre 3 et 50 caractères |
| **Email** | Email | Obligatoire, format valide |
| **Téléphone** | Texte | Obligatoire, uniquement des chiffres, entre 9 et 12 caractères |
| **Date de naissance** | Date | Obligatoire, dans le passé |
| **Adresse** | Texte | Obligatoire, avec autocomplétion OpenStreetMap |

### Validation Double (Client + Serveur)

- **Côté Client (JavaScript)** : Validation en temps réel avec messages d'erreur
- **Côté Serveur (Symfony)** : Validation avec contraintes Symfony Validator
- **Conservation des valeurs** : Les données sont préservées en cas d'erreur via localStorage

## 🎨 Logique de Changement de Thème

Le thème s'adapte automatiquement selon l'heure locale du navigateur :

\`\`\`javascript
function applyThemeBasedOnTime() {
    const now = new Date();
    const hour = now.getHours();
    
    // Thème sombre de 18h à 6h
    if (hour >= 18 || hour < 6) {
        document.body.classList.add('dark-theme');
    } else {
        document.body.classList.remove('dark-theme');
    }
}
\`\`\`

### Fonctionnement :
- **6h à 18h** : Thème bleu clair (jour)
- **18h à 6h** : Thème sombre (nuit)
- **Vérification automatique** : Toutes les minutes
- **Variables CSS** : Changement fluide des couleurs via CSS custom properties

## 🔧 Conservation des Valeurs en Cas d'Erreur

### Mécanisme Technique

1. **Côté Client** : Sauvegarde automatique dans localStorage à chaque modification
\`\`\`javascript
function saveFormValues() {
    const formData = {
        fullName: document.getElementById("fullName").value,
        email: document.getElementById("email").value,
        phone: document.getElementById("phone").value,
        birthDate: document.getElementById("birthDate").value,
        address: document.getElementById("address").value,
    }
    localStorage.setItem("formData", JSON.stringify(formData))
}
\`\`\`

2. **Côté Serveur** : Renvoi des données dans la réponse JSON en cas d'erreur
3. **Restauration** : Rechargement automatique des valeurs au chargement de la page

## 🌍 Fonctionnalités Implémentées

### Fonctionnalités Obligatoires ✅
- ✅ Validation client (JavaScript) et serveur (Symfony)
- ✅ Conservation des valeurs en cas d'erreur
- ✅ Messages d'erreur clairs et visibles
- ✅ Résumé sécurisé des données en cas de succès
- ✅ Centrage vertical et horizontal sur tous écrans
- ✅ Thème adaptatif jour/nuit selon l'heure locale
- ✅ Design responsive (mobile, tablette, desktop)
- ✅ API OpenStreetMap pour autocomplétion d'adresse

### Points Bonus Implémentés ⭐
- ✅ Sauvegarde des données en **data.json** et **data.csv**
- ✅ Protection CSRF avec jetons de sécurité
- ✅ Sélecteur de langue (français/anglais) via JavaScript
- ✅ Design responsive avancé avec champs adaptés mobile

## 📁 Structure du Projet

\`\`\`
symfony-client-form/
├── public/
│   ├── index.html              # Formulaire HTML principal
│   ├── style.css               # Styles CSS avec thème adaptatif
│   ├── script.js               # JavaScript validation + fonctionnalités
│   └── api/
│       └── submit.php          # Point d'entrée API
├── src/
│   ├── Entity/
│   │   └── User.php            # Entité utilisateur
│   └── Controller/
│       └── UserController.php  # Contrôleur Symfony
├── var/
│   ├── data.json              # Sauvegarde JSON (généré)
│   └── data.csv               # Sauvegarde CSV (généré)
├── Dockerfile                 # Configuration Docker
├── docker-compose.yml         # Orchestration services
└── README.md                  # Documentation
\`\`\`

## 🔒 Sécurité

- **Protection CSRF** : Jetons générés côté client et vérifiés côté serveur
- **Échappement HTML** : `htmlspecialchars()` sur toutes les données sauvegardées
- **Validation double** : Client + Serveur pour éviter les contournements
- **Résumé sécurisé** : Échappement HTML dans l'affichage des données

## 📊 Sauvegarde des Données (Points Bonus)

Les données validées sont automatiquement sauvegardées dans :

### Format JSON (`var/data.json`)
\`\`\`json
[
    {
        "timestamp": "2024-01-15 14:30:25",
        "fullName": "Jean Dupont",
        "email": "jean.dupont@email.com",
        "phone": "0123456789",
        "birthDate": "1990-05-15",
        "address": "123 Rue de la Paix, 75001 Paris, France"
    }
]
\`\`\`

### Format CSV (`var/data.csv`)
\`\`\`csv
Timestamp,Nom Complet,Email,Téléphone,Date de Naissance,Adresse
2024-01-15 14:30:25,Jean Dupont,jean.dupont@email.com,0123456789,1990-05-15,"123 Rue de la Paix, 75001 Paris, France"
\`\`\`

## 🌐 Déploiement sur Render.com

### Configuration pour le Déploiement

1. **Build Command** : `composer install --no-dev --optimize-autoloader`
2. **Start Command** : `apache2-foreground`
3. **Environment** : `production`

### Variables d'Environnement Render
\`\`\`
APP_ENV=prod
APP_SECRET=your-production-secret-key-32-chars
\`\`\`

### Lien de Déploiement
🔗 **Application déployée** : [À COMPLÉTER APRÈS DÉPLOIEMENT]

## ❌ Problèmes Rencontrés et Limites Techniques

### Limitations Identifiées

1. **API OpenStreetMap** :
   - Limite de requêtes non documentée officiellement
   - Qualité des résultats variable selon les régions
   - Dépendance à un service externe

2. **Thème Adaptatif** :
   - Basé uniquement sur l'heure locale du navigateur
   - Pas de détection des préférences système (prefers-color-scheme)
   - Changement automatique peut surprendre l'utilisateur

3. **Sauvegarde Locale** :
   - Fichiers stockés sur le serveur (pas de base de données)
   - Pas de rotation automatique des logs
   - Croissance illimitée des fichiers de données

4. **Validation Téléphone** :
   - Format français uniquement (pas international)
   - Pas de vérification de l'existence du numéro

### Solutions Mises en Place

- **Gestion d'erreurs** : Try/catch sur toutes les requêtes API
- **Fallback** : Fonctionnement dégradé si API indisponible
- **Validation robuste** : Double validation client/serveur
- **Responsive design** : Tests sur multiples appareils

### Améliorations Possibles

- **Cache Redis** : Pour les suggestions d'adresse fréquentes
- **Base de données** : Migration vers Doctrine ORM
- **Tests automatisés** : PHPUnit + Jest pour la robustesse
- **Monitoring** : Logs structurés et métriques de performance
- **Internationalisation** : Support de formats téléphoniques internationaux

## 🔧 Commandes Utiles

\`\`\`bash
# Voir les logs
docker-compose logs -f

# Redémarrer les services
docker-compose restart

# Arrêter les services
docker-compose down

# Voir les données sauvegardées
docker-compose exec web cat /var/www/html/var/data.json
docker-compose exec web cat /var/www/html/var/data.csv

# Nettoyer et reconstruire
docker-compose down && docker-compose up --build -d
\`\`\`

## 📞 Support

En cas de problème :
1. Vérifiez que Docker est démarré
2. Consultez les logs : `docker-compose logs -f`
3. Vérifiez que le port 8080 est libre
4. Redémarrez les conteneurs : `docker-compose restart`

---

**✅ Projet conforme aux exigences du cahier des charges**  
**🚀 Prêt pour le déploiement sur Render.com**
