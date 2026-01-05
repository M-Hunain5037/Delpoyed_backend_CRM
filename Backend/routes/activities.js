const express = require('express');
const router = express.Router();
const activityController = require('./controllers/activityController');
const authMiddleware = require('../middleware/auth');

// Record employee activity
router.post('/record', authMiddleware, activityController.recordActivity);

// Get all activities (Admin)
router.get('/all', activityController.getAllActivities);

// Get activities by employee
router.get('/employee/:employee_id', activityController.getEmployeeActivities);

// Get today's activities
router.get('/today', activityController.getTodayActivities);

// Get activity statistics
router.get('/stats', activityController.getActivityStats);

module.exports = router;
