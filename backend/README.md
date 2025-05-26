# Backend du Projet Restaurant

Ce dossier contient le backend de l'application de restaurant, développé avec Node.js, Express et PostgreSQL.

## Prérequis

- Node.js (v14 ou supérieur)
- PostgreSQL (ou une base de données PostgreSQL hébergée comme Azure Neon)
- npm ou yarn

## Installation

1. Cloner le dépôt
2. Naviguer vers le dossier backend : `cd backend`
3. Installer les dépendances : `npm install`
4. Créer un fichier `.env` à la racine du dossier backend avec les variables d'environnement nécessaires (voir `.env.example`)

## Structure du projet

```
backend/
├── config/             # Configuration (base de données, etc.)
├── controllers/        # Contrôleurs pour les routes
├── middleware/         # Middlewares personnalisés
├── migrations/         # Migrations de base de données
├── models/             # Modèles Sequelize
├── routes/             # Routes de l'API
├── seeders/            # Données initiales
├── uploads/            # Fichiers uploadés
├── app.js              # Point d'entrée de l'application
├── package.json        # Dépendances et scripts
└── .env                # Variables d'environnement (à créer)
```

## Scripts disponibles

- `npm start` : Démarrer le serveur en mode production
- `npm run dev` : Démarrer le serveur en mode développement avec rechargement automatique
- `npm run db:migrate` : Exécuter les migrations de base de données
- `npm run db:seed` : Remplir la base de données avec des données initiales

## API Endpoints

- `GET /api/health` : Vérifier l'état du serveur

## Base de données

Le projet utilise PostgreSQL avec Sequelize comme ORM. La configuration de la base de données se trouve dans `config/database.js`.

## Sécurité

- Helmet pour la sécurité des en-têtes HTTP
- CORS configuré pour limiter les origines autorisées
- JWT pour l'authentification
- Validation des entrées utilisateur