# --- ÉTAPE 1: Image de build (pour installer les dépendances Composer) ---
# Utilisation d'une image PHP avec FPM et Alpine pour la légèreté
FROM php:8.2-fpm-alpine3.16 AS symfony_build

# Définir le répertoire de travail dans le conteneur
WORKDIR /var/www/html

# Installer les dépendances système nécessaires
# `apk add --virtual .build-deps` crée un groupe de dépendances temporaire
RUN apk add --no-cache --virtual .build-deps \
    git \
    bash \
    make \
    icu-dev \
    libzip-dev \
    libpng-dev \
    libxml2-dev \
    autoconf \
    g++ \
    php8-dev

# Installer les extensions PHP requises
RUN docker-php-ext-configure intl && \
    docker-php-ext-install -j"$(nproc)" intl pdo_mysql zip exif pcntl gd && \
    pecl install apcu && \
    docker-php-ext-enable apcu intl

# Copier l'exécutable de Composer à partir de son image officielle
# Nous le mettons dans le chemin standard pour qu'il soit accessible
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Copier l'ensemble du projet dans le conteneur de build
COPY . .

# Créer un fichier .env si il n'existe pas pour éviter les erreurs de Symfony Dotenv
RUN if [ ! -f .env ]; then cp .env.example .env; fi

# Définir les permissions pour l'utilisateur non-root avant d'installer les dépendances
# Cela résout l'erreur de "permission denied" pour Composer
RUN chown -R 1000:1000 /var/www/html

# Définir l'utilisateur pour éviter les problèmes de permissions
USER 1000:1000

# Exécuter l'installation des dépendances Composer une seule fois
# On installe les dépendances avec le mode dev pour que les scripts se lancent
RUN composer install

# Installation de symfony/asset pour que la fonction asset() soit reconnue par Twig
# La commande est corrigée en supprimant l'option --no-dev
RUN composer require symfony/asset --no-interaction

# --- ÉTAPE 2: Image finale (pour l'exécution) ---
# L'image finale est basée sur la même image PHP, mais sans les outils de build
FROM php:8.2-fpm-alpine3.16 AS symfony_final

# Définir le répertoire de travail
WORKDIR /var/www/html

# Installer seulement les dépendances runtime
RUN apk add --no-cache \
    git \
    bash \
    icu-dev \
    libzip-dev \
    libpng-dev \
    libxml2-dev

# Installer les extensions PHP requises pour le runtime, en utilisant une approche temporaire
RUN apk add --no-cache --virtual .build-deps-runtime \
    make \
    autoconf \
    g++ \
    php8-dev && \
    docker-php-ext-configure intl && \
    docker-php-ext-install -j"$(nproc)" intl pdo_mysql zip exif pcntl gd && \
    pecl install apcu && \
    docker-php-ext-enable apcu intl && \
    apk del .build-deps-runtime

# Copier le projet depuis l'étape de build
COPY --from=symfony_build /var/www/html .

# S'assurer que les permissions sont correctes
RUN chown -R 1000:1000 /var/www/html && \
    chmod -R u+w /var/www/html/var

# Définir l'utilisateur sous lequel l'application s'exécutera
USER 1000:1000

# Le conteneur ne fait rien par lui-même, il est contrôlé par Nginx via le docker-compose
# Laissez cette section vide
