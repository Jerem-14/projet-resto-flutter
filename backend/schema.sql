-- Schéma SQL pour le projet restaurant
-- Généré à partir de la migration Sequelize 20240526_create_tables.js

-- Table des utilisateurs
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    role ENUM('client', 'admin', 'staff') DEFAULT 'client',
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL
);

-- Table de configuration du restaurant
CREATE TABLE restaurant_config (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    total_capacity INTEGER NOT NULL,
    restaurant_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    address TEXT NOT NULL,
    description TEXT,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL
);

-- Table des créneaux horaires
CREATE TABLE timeslots (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    start_time TIME NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL
);

-- Table des catégories de menu
CREATE TABLE menu_categories (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL
);

-- Table des éléments de menu
CREATE TABLE menu_items (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    category_id INTEGER NOT NULL,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(8, 2) NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    FOREIGN KEY (category_id) REFERENCES menu_categories(id) 
        ON UPDATE CASCADE ON DELETE SET NULL
);

-- Table des réservations
CREATE TABLE reservations (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    user_id INTEGER NOT NULL,
    timeslot_id INTEGER NOT NULL,
    reservation_date DATE NOT NULL,
    number_of_guests INTEGER NOT NULL,
    is_cancelled BOOLEAN DEFAULT FALSE,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) 
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (timeslot_id) REFERENCES timeslots(id) 
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Index pour améliorer les performances
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_reservations_date ON reservations(reservation_date);
CREATE INDEX idx_reservations_user ON reservations(user_id);
CREATE INDEX idx_menu_items_category ON menu_items(category_id);
CREATE INDEX idx_reservations_timeslot ON reservations(timeslot_id); 