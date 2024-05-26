const express = require('express');
const router = express.Router();
const { MenuCategory, MenuItem } = require('../models');
const authenticate = require('../middleware/authenticate');

// Middleware pour vérifier le rôle admin
const requireAdmin = (req, res, next) => {
  if (req.user && req.user.role === 'admin') {
    next();
  } else {
    return res.status(403).json({ 
      error: 'Accès refusé. Droits administrateur requis.' 
    });
  }
};

// ===============================
// ROUTES PUBLIQUES (NO AUTH)
// ===============================

/**
 * @route GET /menu
 * @desc Récupérer le menu complet avec les catégories et leurs plats
 * @access Public
 */
router.get('/', async (req, res) => {
  try {
    const menuData = await MenuItem.findAll({
      include: [{
        model: MenuCategory,
        as: 'category',
        where: { is_active: true },
        attributes: ['id', 'name', 'description']
      }],
      where: { is_available: true },
      order: [
        [{ model: MenuCategory, as: 'category' }, 'name', 'ASC'],
        ['name', 'ASC']
      ]
    });

    // Formatage des données selon le format requis par le front
    const formattedMenu = menuData.map(item => ({
      id: item.id,
      category: item.category.name,
      name: item.name,
      description: item.description,
      price: parseFloat(item.price),
      is_available: item.is_available,
      created_at: item.created_at,
      updated_at: item.updated_at
    }));

    res.json(formattedMenu);
  } catch (error) {
    console.error('Erreur lors de la récupération du menu:', error);
    res.status(500).json({ 
      error: 'Erreur serveur lors de la récupération du menu' 
    });
  }
});

/**
 * @route GET /menu/categories
 * @desc Récupérer toutes les catégories actives
 * @access Public
 */
router.get('/categories', async (req, res) => {
  try {
    const categories = await MenuCategory.findAll({
      where: { is_active: true },
      order: [['name', 'ASC']],
      attributes: ['id', 'name', 'description', 'created_at', 'updated_at']
    });

    res.json(categories);
  } catch (error) {
    console.error('Erreur lors de la récupération des catégories:', error);
    res.status(500).json({ 
      error: 'Erreur serveur lors de la récupération des catégories' 
    });
  }
});

// ===============================
// ROUTES ADMIN - CATÉGORIES
// ===============================

/**
 * @route POST /admin/menu/categories
 * @desc Créer une nouvelle catégorie
 * @access Admin uniquement
 */
router.post('/admin/categories', authenticate, requireAdmin, async (req, res) => {
  try {
    const { name, description } = req.body;

    // Validation des données
    if (!name || name.trim().length === 0) {
      return res.status(400).json({ 
        error: 'Le nom de la catégorie est requis' 
      });
    }

    if (name.length > 100) {
      return res.status(400).json({ 
        error: 'Le nom de la catégorie ne peut pas dépasser 100 caractères' 
      });
    }

    // Vérifier si la catégorie existe déjà
    const existingCategory = await MenuCategory.findOne({
      where: { name: name.trim() }
    });

    if (existingCategory) {
      return res.status(409).json({ 
        error: 'Une catégorie avec ce nom existe déjà' 
      });
    }

    // Créer la nouvelle catégorie
    const newCategory = await MenuCategory.create({
      name: name.trim(),
      description: description ? description.trim() : null,
      is_active: true
    });

    res.status(201).json({
      message: 'Catégorie créée avec succès',
      category: newCategory
    });
  } catch (error) {
    console.error('Erreur lors de la création de la catégorie:', error);
    res.status(500).json({ 
      error: 'Erreur serveur lors de la création de la catégorie' 
    });
  }
});

/**
 * @route PATCH /admin/menu/categories/:id
 * @desc Modifier une catégorie existante
 * @access Admin uniquement
 */
router.patch('/admin/categories/:id', authenticate, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description, is_active } = req.body;

    // Vérifier si la catégorie existe
    const category = await MenuCategory.findByPk(id);
    if (!category) {
      return res.status(404).json({ 
        error: 'Catégorie non trouvée' 
      });
    }

    // Validation des données
    if (name !== undefined) {
      if (!name || name.trim().length === 0) {
        return res.status(400).json({ 
          error: 'Le nom de la catégorie ne peut pas être vide' 
        });
      }
      if (name.length > 100) {
        return res.status(400).json({ 
          error: 'Le nom de la catégorie ne peut pas dépasser 100 caractères' 
        });
      }

      // Vérifier l'unicité du nom (sauf pour la catégorie actuelle)
      const existingCategory = await MenuCategory.findOne({
        where: { 
          name: name.trim(),
          id: { [require('sequelize').Op.ne]: id }
        }
      });

      if (existingCategory) {
        return res.status(409).json({ 
          error: 'Une autre catégorie avec ce nom existe déjà' 
        });
      }
    }

    // Mise à jour des champs modifiés
    const updateData = {};
    if (name !== undefined) updateData.name = name.trim();
    if (description !== undefined) updateData.description = description ? description.trim() : null;
    if (is_active !== undefined) updateData.is_active = is_active;

    await category.update(updateData);

    res.json({
      message: 'Catégorie mise à jour avec succès',
      category: category
    });
  } catch (error) {
    console.error('Erreur lors de la mise à jour de la catégorie:', error);
    res.status(500).json({ 
      error: 'Erreur serveur lors de la mise à jour de la catégorie' 
    });
  }
});

/**
 * @route DELETE /admin/menu/categories/:id
 * @desc Supprimer une catégorie
 * @access Admin uniquement
 */
router.delete('/admin/categories/:id', authenticate, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;

    // Vérifier si la catégorie existe
    const category = await MenuCategory.findByPk(id);
    if (!category) {
      return res.status(404).json({ 
        error: 'Catégorie non trouvée' 
      });
    }

    // Vérifier s'il y a des plats associés à cette catégorie
    const associatedItems = await MenuItem.count({
      where: { category_id: id }
    });

    if (associatedItems > 0) {
      return res.status(409).json({ 
        error: 'Impossible de supprimer cette catégorie car elle contient des plats. Supprimez d\'abord les plats associés.' 
      });
    }

    await category.destroy();

    res.json({
      message: 'Catégorie supprimée avec succès'
    });
  } catch (error) {
    console.error('Erreur lors de la suppression de la catégorie:', error);
    res.status(500).json({ 
      error: 'Erreur serveur lors de la suppression de la catégorie' 
    });
  }
});

// ===============================
// ROUTES ADMIN - PLATS/ITEMS
// ===============================

/**
 * @route POST /admin/menu/items
 * @desc Ajouter un nouveau plat
 * @access Admin uniquement
 */
router.post('/admin/items', authenticate, requireAdmin, async (req, res) => {
  try {
    const { category_id, name, description, price, is_available } = req.body;

    // Validation des données obligatoires
    if (!category_id || !name || price === undefined || price === null) {
      return res.status(400).json({ 
        error: 'Les champs category_id, name et price sont obligatoires' 
      });
    }

    // Validation du format des données
    if (name.length > 150) {
      return res.status(400).json({ 
        error: 'Le nom du plat ne peut pas dépasser 150 caractères' 
      });
    }

    if (isNaN(price) || parseFloat(price) < 0) {
      return res.status(400).json({ 
        error: 'Le prix doit être un nombre positif' 
      });
    }

    // Vérifier si la catégorie existe et est active
    const category = await MenuCategory.findByPk(category_id);
    if (!category) {
      return res.status(404).json({ 
        error: 'Catégorie non trouvée' 
      });
    }

    if (!category.is_active) {
      return res.status(400).json({ 
        error: 'Impossible d\'ajouter un plat à une catégorie inactive' 
      });
    }

    // Créer le nouveau plat
    const newItem = await MenuItem.create({
      category_id: parseInt(category_id),
      name: name.trim(),
      description: description ? description.trim() : null,
      price: parseFloat(price),
      is_available: is_available !== undefined ? is_available : true
    });

    // Récupérer le plat avec sa catégorie pour la réponse
    const itemWithCategory = await MenuItem.findByPk(newItem.id, {
      include: [{
        model: MenuCategory,
        as: 'category',
        attributes: ['id', 'name']
      }]
    });

    res.status(201).json({
      message: 'Plat créé avec succès',
      item: itemWithCategory
    });
  } catch (error) {
    console.error('Erreur lors de la création du plat:', error);
    res.status(500).json({ 
      error: 'Erreur serveur lors de la création du plat' 
    });
  }
});



module.exports = router;