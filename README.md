# Application de Restaurant - Projet Flutter

Une application mobile complète de gestion de restaurant développée avec Flutter et Node.js.

## 🚀 Fonctionnalités

### Client
- Consultation du menu et des catégories de plats
- Système de réservation de table
- Gestion du profil utilisateur
- Consultation des disponibilités en temps réel
- Historique des réservations

### Administration
- Gestion complète du menu (CRUD catégories et plats)
- Gestion des créneaux horaires
- Administration des réservations
- Gestion des restaurants

## 🛠 Technologies Utilisées

### Frontend (Mobile)
- Flutter
- Provider pour la gestion d'état
- HTTP package pour les appels API

### Backend
- Node.js
- Express.js
- Sequelize ORM
- PostgreSQL
- JWT pour l'authentification

## 📦 Installation

### Prérequis
- Node.js (v14+)
- Flutter SDK
- PostgreSQL
- Git

### Backend

```bash
cd backend
npm install
cp .env.example .env
# Configurer les variables d'environnement dans .env
npm run db:migrate
npm run start
```

### Frontend (Flutter)

```bash
cd frontend
flutter pub get
flutter run
```

## 📝 Structure du Projet

```
projet-resto-flutter/
├── backend/
│   ├── controllers/     # Logique métier
│   ├── models/         # Modèles Sequelize
│   ├── routes/         # Routes API
│   ├── middleware/     # Middlewares
│   └── config/         # Configuration
└── frontend/
    ├── lib/
    │   ├── models/     # Modèles de données
    │   ├── screens/    # Écrans de l'application
    │   ├── widgets/    # Widgets réutilisables
    │   └── services/   # Services API
```

## 📚 Documentation API

La documentation complète de l'API est disponible via Swagger :
- En développement : http://localhost:3000/api/docs

### Points d'entrée principaux :

- Auth : `/api/auth/*`
- Menu : `/api/menu/*`
- Réservations : `/api/reservations/*`
- Admin : `/api/admin/*`

## 🔐 Sécurité

- Authentification JWT
- Validation des données
- Middleware de rôle admin
- Gestion sécurisée des mots de passe (bcrypt)

## 🧪 Tests

### Backend

```bash
npm run test
```

### Frontend

```bash
flutter test
```
