const express = require('express');
const router = express.Router();
const rulesController = require('./controllers/rulesController');
const authenticateToken = require('../middleware/auth');

// Public routes - Get rules (no auth required)
// Specific routes BEFORE parameter routes to avoid conflicts
router.get('/break-rules', rulesController.getBreakRules);
router.get('/type/:type', rulesController.getRulesByType);
router.get('/:id', rulesController.getRuleById);
router.get('/', rulesController.getAllRules);

// Protected routes - Add, Update, Delete (Admin only)
router.post('/', authenticateToken, rulesController.addRule);
router.put('/:id', authenticateToken, rulesController.updateRule);
router.delete('/:id', authenticateToken, rulesController.deleteRule);

module.exports = router;
