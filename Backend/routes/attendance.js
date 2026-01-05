const express = require('express');
const router = express.Router();
const attendanceController = require('./controllers/attendanceController');
const authMiddleware = require('../middleware/auth');

// Employee Routes (Protected)
router.post('/check-in', authMiddleware, attendanceController.checkIn);
router.post('/check-out', authMiddleware, attendanceController.checkOut);
router.post('/break', authMiddleware, attendanceController.recordBreak);
router.post('/break-start', authMiddleware, attendanceController.recordBreakStart);   // Save break immediately on start
router.patch('/break-progress', authMiddleware, attendanceController.recordBreakProgress); // Auto-save progress every 30s
router.patch('/break-end', authMiddleware, attendanceController.recordBreakEnd);     // Update break with end time
router.get('/ongoing-breaks/:employee_id', authMiddleware, attendanceController.getOngoingBreaks); // Get unfinished breaks
router.get('/today-breaks/:employee_id', authMiddleware, attendanceController.getTodayBreaks); // Get today's completed breaks

// Get attendance data (Public for HR Dashboard)
router.get('/today/:employee_id', attendanceController.getTodayAttendance);
router.get('/monthly/:employee_id', attendanceController.getMonthlyAttendance);

// Admin Routes (Public for HR Dashboard)
router.post('/generate-absent', attendanceController.generateAbsentRecords); // Generate absent records from joining date
router.get('/all-with-absent', attendanceController.getAllAttendanceWithAbsent); // New endpoint with absent records
router.get('/all', attendanceController.getAllAttendance);
router.get('/breaks', attendanceController.getAllBreaks);
router.get('/summary', authMiddleware, attendanceController.getAttendanceSummary);
router.get('/overtime', authMiddleware, attendanceController.getOvertimeReport);
router.post('/auto-fix-working-hours', attendanceController.autoFixMissingWorkingHours); // Auto-fix missing working hours

module.exports = router;
