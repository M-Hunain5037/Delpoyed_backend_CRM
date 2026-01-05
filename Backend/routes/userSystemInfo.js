const express = require('express');
const router = express.Router();
const userSystemInfoController = require('./controllers/userSystemInfoController');
const { verifyToken } = require('../middleware/auth');

// Admin only routes (require JWT)
router.post('/record-login', userSystemInfoController.recordLogin);
router.post('/record-logout', userSystemInfoController.recordLogout);
router.post('/update-activity', userSystemInfoController.updateLastActivity);

// Get active users (admin)
router.get('/active-users', userSystemInfoController.getActiveUsers);

// Get user specific info
router.get('/user/:employeeId/summary', userSystemInfoController.getUserSessionSummary);
router.get('/user/:employeeId/concurrent', userSystemInfoController.getConcurrentLoginCount);
router.get('/user/:employeeId/history', userSystemInfoController.getUserLoginHistory);

module.exports = router;
