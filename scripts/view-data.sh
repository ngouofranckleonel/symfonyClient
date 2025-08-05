#!/bin/bash

# Script pour visualiser les données sauvegardées
echo "🗄️  Visualisation des données sauvegardées"
echo "=========================================="

# Vérifier si les conteneurs sont actifs
if ! docker-compose ps | grep -q "Up"; then
    echo "❌ Les conteneurs Docker ne sont pas actifs."
    echo "Lancez d'abord: docker-compose up -d"
    exit 1
fi

echo ""
echo "📁 Emplacement des fichiers de données :"
echo "   - JSON: /var/www/html/var/data.json"
echo "   - CSV:  /var/www/html/var/data.csv"
echo ""

# Vérifier l'existence des fichiers
echo "🔍 Vérification de l'existence des fichiers..."
docker-compose exec web ls -la /var/www/html/var/data.*

echo ""
echo "📊 Contenu du fichier JSON :"
echo "----------------------------"
if docker-compose exec web test -f /var/www/html/var/data.json; then
    docker-compose exec web cat /var/www/html/var/data.json | jq . 2>/dev/null || docker-compose exec web cat /var/www/html/var/data.json
else
    echo "❌ Aucune donnée JSON trouvée. Soumettez d'abord le formulaire."
fi

echo ""
echo "📈 Contenu du fichier CSV :"
echo "---------------------------"
if docker-compose exec web test -f /var/www/html/var/data.csv; then
    docker-compose exec web cat /var/www/html/var/data.csv
else
    echo "❌ Aucune donnée CSV trouvée. Soumettez d'abord le formulaire."
fi

echo ""
echo "📊 Statistiques :"
echo "-----------------"
JSON_COUNT=$(docker-compose exec web sh -c 'if [ -f /var/www/html/var/data.json ]; then cat /var/www/html/var/data.json | jq length 2>/dev/null || echo "0"; else echo "0"; fi')
CSV_COUNT=$(docker-compose exec web sh -c 'if [ -f /var/www/html/var/data.csv ]; then wc -l < /var/www/html/var/data.csv | awk "{print \$1-1}"; else echo "0"; fi')

echo "   - Entrées JSON: $JSON_COUNT"
echo "   - Entrées CSV:  $CSV_COUNT"
