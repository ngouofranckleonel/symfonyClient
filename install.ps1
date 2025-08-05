# Script d'installation PowerShell pour Windows
# Usage: .\install.ps1

param(
    [switch]$SkipChecks = $false
)

# Configuration des couleurs
$Host.UI.RawUI.ForegroundColor = "White"

function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Test-Docker {
    Write-Status "Vérification de Docker..."
    try {
        $dockerVersion = docker --version
        Write-Success "Docker est installé: $dockerVersion"
        return $true
    }
    catch {
        Write-Error "Docker n'est pas installé ou n'est pas dans le PATH."
        Write-Host "Téléchargez Docker Desktop: https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
        return $false
    }
}

function Test-DockerCompose {
    Write-Status "Vérification de Docker Compose..."
    try {
        $composeVersion = docker-compose --version
        Write-Success "Docker Compose est installé: $composeVersion"
        return $true
    }
    catch {
        Write-Error "Docker Compose n'est pas installé."
        Write-Host "Docker Compose est inclus avec Docker Desktop."
        return $false
    }
}

function Test-Git {
    Write-Status "Vérification de Git..."
    try {
        $gitVersion = git --version
        Write-Success "Git est installé: $gitVersion"
        return $true
    }
    catch {
        Write-Error "Git n'est pas installé."
        Write-Host "Téléchargez Git: https://git-scm.com/download/win"
        return $false
    }
}

function Test-Ports {
    Write-Status "Vérification des ports..."
    
    $port8080 = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
    if ($port8080) {
        Write-Warning "Le port 8080 est déjà utilisé."
    } else {
        Write-Success "Port 8080 disponible"
    }
    
    $port3306 = Get-NetTCPConnection -LocalPort 3306 -ErrorAction SilentlyContinue
    if ($port3306) {
        Write-Warning "Le port 3306 est déjà utilisé."
    } else {
        Write-Success "Port 3306 disponible"
    }
}

function New-EnvFile {
    if (-not (Test-Path ".env")) {
        Write-Status "Création du fichier .env..."
        
        # Générer une clé secrète
        $secretKey = [System.Web.Security.Membership]::GeneratePassword(32, 0)
        
        $envContent = @"
APP_ENV=prod
APP_SECRET=$secretKey
DATABASE_URL="mysql://symfony:symfony@db:3306/client_form?serverVersion=8.0&charset=utf8mb4"
"@
        
        $envContent | Out-File -FilePath ".env" -Encoding UTF8
        Write-Success "Fichier .env créé"
    } else {
        Write-Success "Fichier .env existe déjà"
    }
}

function Start-DockerServices {
    Write-Status "Construction des images Docker..."
    docker-compose build
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Erreur lors de la construction des images"
        return $false
    }
    
    Write-Status "Démarrage des conteneurs..."
    docker-compose up -d
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Erreur lors du démarrage des conteneurs"
        return $false
    }
    
    Write-Status "Attente du démarrage des services..."
    Start-Sleep -Seconds 10
    return $true
}

function Install-Dependencies {
    Write-Status "Installation des dépendances Composer..."
    docker-compose exec -T web composer install --optimize-autoloader --no-dev
    
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Erreur lors de l'installation des dépendances. Tentative de réinstallation de Composer..."
        docker-compose exec web curl -sS https://getcomposer.org/installer | php
        docker-compose exec web mv composer.phar /usr/local/bin/composer
        docker-compose exec web composer install --optimize-autoloader --no-dev
    }
}

function Set-Permissions {
    Write-Status "Configuration des permissions..."
    docker-compose exec web chown -R www-data:www-data /var/www/html/var
    docker-compose exec web chmod -R 775 /var/www/html/var
}

function Test-Installation {
    Write-Status "Test de l'installation..."
    Start-Sleep -Seconds 5
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080" -UseBasicParsing -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Success "L'application est accessible sur http://localhost:8080"
            return $true
        }
    }
    catch {
        Write-Error "L'application n'est pas accessible: $($_.Exception.Message)"
        Write-Host "Vérifiez les logs avec: docker-compose logs"
        return $false
    }
    return $false
}

function Show-FinalInfo {
    Write-Host ""
    Write-Host "🎉 Installation terminée avec succès !" -ForegroundColor Green
    Write-Host "======================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "📱 Application web : http://localhost:8080" -ForegroundColor Cyan
    Write-Host "🗄️  Base de données : localhost:3306" -ForegroundColor Cyan
    Write-Host "   - Utilisateur : symfony" -ForegroundColor Gray
    Write-Host "   - Mot de passe : symfony" -ForegroundColor Gray
    Write-Host "   - Base : client_form" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🔧 Commandes utiles :" -ForegroundColor Yellow
    Write-Host "   - Voir les logs : docker-compose logs -f" -ForegroundColor Gray
    Write-Host "   - Arrêter : docker-compose down" -ForegroundColor Gray
    Write-Host "   - Redémarrer : docker-compose restart" -ForegroundColor Gray
    Write-Host "   - Reconstruire : docker-compose up --build -d" -ForegroundColor Gray
    Write-Host ""
    Write-Host "📁 Fichiers de données :" -ForegroundColor Yellow
    Write-Host "   - JSON : var/data.json" -ForegroundColor Gray
    Write-Host "   - CSV : var/data.csv" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🌐 Pour déployer sur Render.com, suivez le README.md" -ForegroundColor Magenta
}

# Fonction principale
function Main {
    Write-Host "🚀 Installation du projet Symfony Client Form" -ForegroundColor Cyan
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Vérifier si on est dans le bon répertoire
    if (-not (Test-Path "docker-compose.yml")) {
        Write-Error "Le fichier docker-compose.yml n'est pas trouvé."
        Write-Error "Assurez-vous d'être dans le répertoire du projet."
        exit 1
    }
    
    # Vérifications préalables
    if (-not $SkipChecks) {
        $dockerOk = Test-Docker
        $composeOk = Test-DockerCompose
        $gitOk = Test-Git
        
        if (-not ($dockerOk -and $composeOk -and $gitOk)) {
            Write-Error "Certaines dépendances sont manquantes. Installation interrompue."
            exit 1
        }
        
        Test-Ports
    }
    
    Write-Host ""
    Write-Status "Toutes les vérifications sont passées. Début de l'installation..."
    Write-Host ""
    
    try {
        # Installation
        New-EnvFile
        
        if (-not (Start-DockerServices)) {
            throw "Erreur lors du démarrage des services Docker"
        }
        
        Install-Dependencies
        Set-Permissions
        
        # Test
        if (Test-Installation) {
            Show-FinalInfo
        } else {
            throw "L'installation a échoué lors du test final"
        }
    }
    catch {
        Write-Error "Erreur durant l'installation: $($_.Exception.Message)"
        Write-Host "Nettoyage..." -ForegroundColor Yellow
        docker-compose down 2>$null
        exit 1
    }
}

# Vérifier les privilèges administrateur
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Il est recommandé d'exécuter ce script en tant qu'administrateur."
    $continue = Read-Host "Continuer quand même ? (y/N)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        exit 1
    }
}

# Exécuter l'installation
Main
