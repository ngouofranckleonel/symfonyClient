#!/bin/bash

# Script d'installation automatique pour le projet Symfony Client Form
# Usage: ./install.sh

set -e

echo "🚀 Installation du projet Symfony Client Form"
echo "=============================================="

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Vérifier si Docker est installé
check_docker() {
    print_status "Vérification de Docker..."
    if ! command -v docker &> /dev/null; then
        print_error "Docker n'est pas installé. Veuillez l'installer d'abord."
        echo "Visitez: https://docs.docker.com/get-docker/"
        exit 1
    fi
    print_success "Docker est installé: $(docker --version)"
}

# Vérifier si Docker Compose est installé
check_docker_compose() {
    print_status "Vérification de Docker Compose..."
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose n'est pas installé. Veuillez l'installer d'abord."
        echo "Visitez: https://docs.docker.com/compose/install/"
        exit 1
    fi
    print_success "Docker Compose est installé: $(docker-compose --version)"
}

# Vérifier si Git est installé
check_git() {
    print_status "Vérification de Git..."
    if ! command -v git &> /dev/null; then
        print_error "Git n'est pas installé. Veuillez l'installer d'abord."
        echo "Visitez: https://git-scm.com/downloads"
        exit 1
    fi
    print_success "Git est installé: $(git --version)"
}

# Vérifier les ports
check_ports() {
    print_status "Vérification des ports..."
    
    if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null 2>&1; then
        print_warning "Le port 8080 est déjà utilisé. Vous devrez peut-être modifier docker-compose.yml"
    else
        print_success "Port 8080 disponible"
    fi
    
    if lsof -Pi :3306 -sTCP:LISTEN -t >/dev/null 2>&1; then
        print_warning "Le port 3306 est déjà utilisé. Vous devrez peut-être modifier docker-compose.yml"
    else
        print_success "Port 3306 disponible"
    fi
}

# Créer le fichier .env s'il n'existe pas
create_env_file() {
    if [ ! -f .env ]; then
        print_status "Création du fichier .env..."
        
        # Générer une clé secrète aléatoire
        SECRET_KEY=$(openssl rand -hex 32 2>/dev/null || date +%s | sha256sum | base64 | head -c 32)
        
        cat > .env << EOF
APP_ENV=prod
APP_SECRET=${SECRET_KEY}
DATABASE_URL="mysql://symfony:symfony@db:3306/client_form?serverVersion=8.0&charset=utf8mb4"
EOF
        print_success "Fichier .env créé avec une clé secrète générée"
    else
        print_success "Fichier .env existe déjà"
    fi
}

# Construire et lancer les conteneurs
build_and_start() {
    print_status "Construction des images Docker..."
    docker-compose build
    
    print_status "Démarrage des conteneurs..."
    docker-compose up -d
    
    # Attendre que les conteneurs soient prêts
    print_status "Attente du démarrage des services..."
    sleep 10
}

# Installer les dépendances
install_dependencies() {
    print_status "Installation des dépendances Composer..."
    docker-compose exec -T web composer install --optimize-autoloader --no-dev
}

# Configurer les permissions
set_permissions() {
    print_status "Configuration des permissions..."
    docker-compose exec -T web chown -R www-data:www-data /var/www/html/var
    docker-compose exec -T web chmod -R 775 /var/www/html/var
}

# Tester l'installation
test_installation() {
    print_status "Test de l'installation..."
    
    # Attendre que le serveur web soit prêt
    sleep 5
    
    if curl -f -s http://localhost:8080 > /dev/null; then
        print_success "L'application est accessible sur http://localhost:8080"
    else
        print_error "L'application n'est pas accessible. Vérifiez les logs avec: docker-compose logs"
        return 1
    fi
}

# Afficher les informations finales
show_final_info() {
    echo ""
    echo "🎉 Installation terminée avec succès !"
    echo "======================================"
    echo ""
    echo "📱 Application web : http://localhost:8080"
    echo "🗄️  Base de données : localhost:3306"
    echo "   - Utilisateur : symfony"
    echo "   - Mot de passe : symfony"
    echo "   - Base : client_form"
    echo ""
    echo "🔧 Commandes utiles :"
    echo "   - Voir les logs : docker-compose logs -f"
    echo "   - Arrêter : docker-compose down"
    echo "   - Redémarrer : docker-compose restart"
    echo "   - Reconstruire : docker-compose up --build -d"
    echo ""
    echo "📁 Fichiers de données :"
    echo "   - JSON : var/data.json"
    echo "   - CSV : var/data.csv"
    echo ""
    echo "🌐 Pour déployer sur Render.com, suivez le README.md"
}

# Fonction principale
main() {
    echo "Démarrage de l'installation..."
    echo ""
    
    # Vérifications préalables
    check_docker
    check_docker_compose
    check_git
    check_ports
    
    echo ""
    print_status "Toutes les vérifications sont passées. Début de l'installation..."
    echo ""
    
    # Installation
    create_env_file
    build_and_start
    install_dependencies
    set_permissions
    
    # Test
    if test_installation; then
        show_final_info
    else
        print_error "L'installation a échoué. Consultez les logs pour plus d'informations."
        echo "Logs: docker-compose logs"
        exit 1
    fi
}

# Gestion des signaux pour nettoyer en cas d'interruption
cleanup() {
    print_warning "Installation interrompue. Nettoyage..."
    docker-compose down 2>/dev/null || true
    exit 1
}

trap cleanup INT TERM

# Vérifier si le script est exécuté dans le bon répertoire
if [ ! -f "docker-compose.yml" ]; then
    print_error "Le fichier docker-compose.yml n'est pas trouvé."
    print_error "Assurez-vous d'être dans le répertoire du projet."
    exit 1
fi

# Exécuter l'installation
main
