const express = require('express');
const router = express.Router();
const authController = require('./controllers/authController');
const authMiddleware = require('../middleware/auth');

// Public routes
router.post('/login', authController.login);
router.get('/user/email/:email', authController.getUserByEmail);
router.get('/ip-info', authController.getIPInfo);

// Protected routes (require JWT)
router.get('/session', authMiddleware, authController.getSession);
router.post('/logout', authMiddleware, authController.logout);
router.post('/logout-no-checkout', authMiddleware, authController.logoutNoCheckout);
router.post('/password/update', authMiddleware, authController.updatePassword);

// Admin routes
router.get('/users', authController.getAllUsers);
router.delete('/users/:userId/deactivate', authController.deactivateUser);

module.exports = router;

