const express = require('express');
const router = express.Router();
const onboardingController = require('./controllers/onboardingController');
const debugController = require('./controllers/debugController');
const authMiddleware = require('../middleware/auth');

// POST - Create new employee
router.post('/employees', onboardingController.createEmployee);

// GET - Get all employees
router.get('/employees', onboardingController.getAllEmployees);
router.get('/all-employees', onboardingController.getAllEmployees); // Alias for compatibility

// GET - Get employee by ID
router.get('/employees/:id', onboardingController.getEmployeeById);

// PUT - Update employee
router.put('/employees/:id', onboardingController.updateEmployee);

// DELETE - Delete employee
router.delete('/employees/:id', onboardingController.deleteEmployee);

// GET - Get onboarding progress
router.get('/employees/:id/progress', onboardingController.getOnboardingProgress);

// DEBUG ENDPOINTS
router.get('/debug/resources', debugController.debugDynamicResources);
router.get('/debug/employee/:id/resources', debugController.debugEmployeeResources);

module.exports = router;
