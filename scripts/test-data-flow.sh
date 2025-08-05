#!/bin/bash

# Script de test du flux de données
echo "🧪 Test du flux de sauvegarde des données"
echo "========================================="

# Vérifier que les conteneurs sont actifs
if ! docker-compose ps | grep -q "Up"; then
    echo "❌ Démarrage des conteneurs..."
    docker-compose up -d
    sleep 10
fi

echo ""
echo "1️⃣  Test de soumission de données de test..."

# Données de test
curl -X POST http://localhost:8080/submit \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "form[fullName]=Jean+Dupont&form[email]=jean.dupont@test.com&form[phone]=0123456789&form[birthDate]=1990-05-15&form[address]=123+Rue+de+la+Paix,+Paris&form[_token]=test"

echo ""
echo "2️⃣  Vérification des fichiers créés..."
docker-compose exec web ls -la /var/www/html/var/data.*

echo ""
echo "3️⃣  Contenu JSON généré :"
echo "------------------------"
docker-compose exec web cat /var/www/html/var/data.json 2>/dev/null || echo "❌ Fichier JSON non trouvé"

echo ""
echo "4️⃣  Contenu CSV généré :"
echo "-----------------------"
docker-compose exec web cat /var/www/html/var/data.csv 2>/dev/null || echo "❌ Fichier CSV non trouvé"

echo ""
echo "5️⃣  Test de l'API de données..."
curl -s http://localhost:8080/admin/data/api | jq . 2>/dev/null || curl -s http://localhost:8080/admin/data/api

echo ""
echo "✅ Test terminé ! Visitez http://localhost:8080/admin/data pour voir l'interface d'administration."
