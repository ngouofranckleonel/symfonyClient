# Guide d'Installation Complet - Formulaire Client Symfony

## 📋 Table des Matières
1. [Prérequis Système](#prérequis-système)
2. [Installation Docker](#installation-docker)
3. [Installation Git](#installation-git)
4. [Installation du Projet](#installation-du-projet)
5. [Configuration et Lancement](#configuration-et-lancement)
6. [Vérification de l'Installation](#vérification-de-linstallation)
7. [Dépannage](#dépannage)

---

## 🖥️ Prérequis Système

### Configuration Minimale Requise
- **RAM** : 4 GB minimum (8 GB recommandé)
- **Espace disque** : 2 GB libres minimum
- **Processeur** : x64 (Intel/AMD)
- **Système d'exploitation** : 
  - Windows 10/11 (64-bit)
  - macOS 10.14+ 
  - Linux (Ubuntu 18.04+, CentOS 7+, Debian 9+)

---

## 🐳 Installation Docker

### Windows 10/11

#### Option 1 : Docker Desktop (Recommandé)
1. **Télécharger Docker Desktop**
   \`\`\`
   https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe
   \`\`\`

2. **Installer Docker Desktop**
   - Double-cliquer sur le fichier téléchargé
   - Suivre l'assistant d'installation
   - Cocher "Use WSL 2 instead of Hyper-V" si disponible
   - Redémarrer l'ordinateur si demandé

3. **Vérifier l'installation**
   ```powershell
   # Ouvrir PowerShell en tant qu'administrateur
   docker --version
   docker-compose --version
   \`\`\`

#### Option 2 : Installation manuelle
1. **Activer WSL 2**
   ```powershell
   # PowerShell en tant qu'administrateur
   dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
   dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
   \`\`\`

2. **Redémarrer et installer le kernel WSL 2**
   \`\`\`
   https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi
   \`\`\`

3. **Définir WSL 2 par défaut**
   ```powershell
   wsl --set-default-version 2
   \`\`\`

### macOS

#### Option 1 : Docker Desktop
1. **Télécharger Docker Desktop**
   \`\`\`
   # Pour Mac Intel
   https://desktop.docker.com/mac/main/amd64/Docker.dmg
   
   # Pour Mac Apple Silicon (M1/M2)
   https://desktop.docker.com/mac/main/arm64/Docker.dmg
   \`\`\`

2. **Installer**
   - Ouvrir le fichier .dmg
   - Glisser Docker vers Applications
   - Lancer Docker depuis Applications

#### Option 2 : Homebrew
\`\`\`bash
# Installer Homebrew si pas déjà fait
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Installer Docker
brew install --cask docker

# Ou installer Docker et Docker Compose séparément
brew install docker docker-compose
\`\`\`

3. **Vérifier l'installation**
   \`\`\`bash
   docker --version
   docker-compose --version
   \`\`\`

### Linux (Ubuntu/Debian)

1. **Mettre à jour le système**
   \`\`\`bash
   sudo apt update
   sudo apt upgrade -y
   \`\`\`

2. **Installer les dépendances**
   \`\`\`bash
   sudo apt install -y \
       apt-transport-https \
       ca-certificates \
       curl \
       gnupg \
       lsb-release
   \`\`\`

3. **Ajouter la clé GPG Docker**
   \`\`\`bash
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
   \`\`\`

4. **Ajouter le repository Docker**
   \`\`\`bash
   echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   \`\`\`

5. **Installer Docker**
   \`\`\`bash
   sudo apt update
   sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
   \`\`\`

6. **Installer Docker Compose (version standalone)**
   \`\`\`bash
   sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   \`\`\`

7. **Configurer les permissions**
   \`\`\`bash
   # Ajouter l'utilisateur au groupe docker
   sudo usermod -aG docker $USER
   
   # Redémarrer la session ou exécuter
   newgrp docker
   \`\`\`

8. **Démarrer Docker**
   \`\`\`bash
   sudo systemctl start docker
   sudo systemctl enable docker
   \`\`\`

### Linux (CentOS/RHEL/Fedora)

1. **CentOS/RHEL 7/8**
   \`\`\`bash
   # Installer les dépendances
   sudo yum install -y yum-utils device-mapper-persistent-data lvm2
   
   # Ajouter le repository
   sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
   
   # Installer Docker
   sudo yum install -y docker-ce docker-ce-cli containerd.io
   
   # Démarrer Docker
   sudo systemctl start docker
   sudo systemctl enable docker
   \`\`\`

2. **Fedora**
   \`\`\`bash
   # Installer Docker
   sudo dnf install -y docker-ce docker-ce-cli containerd.io
   
   # Démarrer Docker
   sudo systemctl start docker
   sudo systemctl enable docker
   \`\`\`

3. **Installer Docker Compose**
   \`\`\`bash
   sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   \`\`\`

---

## 📦 Installation Git

### Windows

#### Option 1 : Git for Windows (Recommandé)
1. **Télécharger Git**
   \`\`\`
   https://git-scm.com/download/win
   \`\`\`

2. **Installer Git**
   - Exécuter le fichier téléchargé
   - Accepter les paramètres par défaut
   - Choisir "Git from the command line and also from 3rd-party software"
   - Choisir "Use the OpenSSL library"
   - Choisir "Checkout Windows-style, commit Unix-style line endings"

#### Option 2 : Chocolatey
```powershell
# Installer Chocolatey d'abord
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Installer Git
choco install git -y
