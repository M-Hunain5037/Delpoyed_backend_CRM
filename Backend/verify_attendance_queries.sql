-- Attendance Data Verification SQL Queries
-- Run these queries to verify attendance data integrity

-- ==========================================
-- 1. Get total attendance records count
-- ==========================================
SELECT COUNT(*) as total_records 
FROM Employee_Attendance;

-- ==========================================
-- 2. Count by status
-- ==========================================
SELECT 
    status,
    COUNT(*) as count
FROM Employee_Attendance
GROUP BY status
ORDER BY count DESC;

-- ==========================================
-- 3. Today's attendance
-- ==========================================
SELECT 
    name,
    check_in_time,
    check_out_time,
    status,
    total_breaks_taken,
    net_working_time_minutes,
    late_by_minutes
FROM Employee_Attendance
WHERE DATE(attendance_date) = CURDATE()
ORDER BY check_in_time;

-- ==========================================
-- 4. Active employees (currently working)
-- ==========================================
SELECT 
    name,
    check_in_time,
    TIMESTAMPDIFF(MINUTE, CONCAT(CURDATE(), ' ', check_in_time), NOW()) as minutes_working,
    total_breaks_taken
FROM Employee_Attendance
WHERE DATE(attendance_date) = CURDATE()
  AND check_out_time IS NULL
  AND status = 'Present'
ORDER BY check_in_time;

-- ==========================================
-- 5. Late arrivals
-- ==========================================
SELECT 
    name,
    attendance_date,
    check_in_time,
    late_by_minutes,
    status
FROM Employee_Attendance
WHERE late_by_minutes > 0
ORDER BY attendance_date DESC, late_by_minutes DESC
LIMIT 10;

-- ==========================================
-- 6. Break statistics
-- ==========================================
SELECT 
    name,
    attendance_date,
    total_breaks_taken,
    total_break_duration_minutes,
    smoke_break_count,
    dinner_break_count,
    washroom_break_count,
    prayer_break_count
FROM Employee_Attendance
WHERE total_breaks_taken > 0
ORDER BY attendance_date DESC
LIMIT 10;

-- ==========================================
-- 7. Data integrity check - Orphaned breaks
-- ==========================================
SELECT 
    id,
    name,
    attendance_date,
    total_breaks_taken,
    total_break_duration_minutes,
    'Orphaned breaks - count mismatch' as issue
FROM Employee_Attendance
WHERE total_breaks_taken > 0
  AND id NOT IN (
    SELECT DISTINCT attendance_id 
    FROM Employee_Breaks
  );

-- ==========================================
-- 8. Data integrity check - Break count mismatch
-- ==========================================
SELECT 
    id,
    name,
    attendance_date,
    total_breaks_taken,
    (smoke_break_count + dinner_break_count + washroom_break_count + prayer_break_count) as calculated_total,
    'Break count mismatch' as issue
FROM Employee_Attendance
WHERE total_breaks_taken != (smoke_break_count + dinner_break_count + washroom_break_count + prayer_break_count);

-- ==========================================
-- 9. Data integrity check - Break duration mismatch
-- ==========================================
SELECT 
    id,
    name,
    attendance_date,
    total_break_duration_minutes,
    (smoke_break_duration_minutes + dinner_break_duration_minutes + washroom_break_duration_minutes + prayer_break_duration_minutes) as calculated_duration,
    'Break duration mismatch' as issue
FROM Employee_Attendance
WHERE total_break_duration_minutes != (smoke_break_duration_minutes + dinner_break_duration_minutes + washroom_break_duration_minutes + prayer_break_duration_minutes);

-- ==========================================
-- 10. Data integrity check - Working time mismatch
-- ==========================================
SELECT 
    id,
    name,
    attendance_date,
    gross_working_time_minutes,
    total_break_duration_minutes,
    net_working_time_minutes,
    (gross_working_time_minutes - total_break_duration_minutes) as calculated_net,
    'Working time mismatch' as issue
FROM Employee_Attendance
WHERE net_working_time_minutes != (gross_working_time_minutes - total_break_duration_minutes);

-- ==========================================
-- 11. Weekly attendance summary
-- ==========================================
SELECT 
    DATE(attendance_date) as date,
    COUNT(*) as total_records,
    SUM(CASE WHEN status = 'Present' THEN 1 ELSE 0 END) as present,
    SUM(CASE WHEN status = 'Absent' THEN 1 ELSE 0 END) as absent,
    SUM(CASE WHEN late_by_minutes > 0 THEN 1 ELSE 0 END) as late,
    SUM(CASE WHEN on_time = 1 THEN 1 ELSE 0 END) as on_time,
    ROUND(AVG(net_working_time_minutes) / 60, 2) as avg_working_hours
FROM Employee_Attendance
WHERE attendance_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY DATE(attendance_date)
ORDER BY date DESC;

-- ==========================================
-- 12. Employee attendance statistics
-- ==========================================
SELECT 
    name,
    COUNT(*) as total_days,
    SUM(CASE WHEN status = 'Present' THEN 1 ELSE 0 END) as days_present,
    SUM(CASE WHEN status = 'Absent' THEN 1 ELSE 0 END) as days_absent,
    SUM(CASE WHEN late_by_minutes > 0 THEN 1 ELSE 0 END) as days_late,
    ROUND(AVG(net_working_time_minutes) / 60, 2) as avg_working_hours,
    SUM(total_breaks_taken) as total_breaks,
    ROUND(SUM(total_break_duration_minutes) / 60, 2) as total_break_hours
FROM Employee_Attendance
GROUP BY name
ORDER BY total_days DESC;

-- ==========================================
-- 13. Overtime analysis
-- ==========================================
SELECT 
    name,
    attendance_date,
    gross_working_time_minutes,
    expected_working_time_minutes,
    overtime_minutes,
    overtime_hours,
    status
FROM Employee_Attendance
WHERE overtime_minutes > 0
ORDER BY overtime_minutes DESC
LIMIT 10;

-- ==========================================
-- 14. Break details with attendance
-- ==========================================
SELECT 
    ea.name,
    ea.attendance_date,
    eb.break_type,
    eb.break_start_time,
    eb.break_end_time,
    eb.break_duration_minutes,
    eb.reason
FROM Employee_Attendance ea
LEFT JOIN Employee_Breaks eb ON ea.id = eb.attendance_id
WHERE ea.total_breaks_taken > 0
ORDER BY ea.attendance_date DESC, eb.break_start_time
LIMIT 20;

-- ==========================================
-- 15. Summary statistics for dashboard
-- ==========================================
SELECT 
    COUNT(*) as total_records,
    COUNT(DISTINCT employee_id) as unique_employees,
    SUM(CASE WHEN status = 'Present' THEN 1 ELSE 0 END) as total_present,
    SUM(CASE WHEN status = 'Absent' THEN 1 ELSE 0 END) as total_absent,
    SUM(CASE WHEN late_by_minutes > 0 THEN 1 ELSE 0 END) as total_late,
    SUM(CASE WHEN on_time = 1 THEN 1 ELSE 0 END) as total_on_time,
    SUM(total_breaks_taken) as total_breaks,
    ROUND(AVG(net_working_time_minutes) / 60, 2) as avg_working_hours,
    ROUND(SUM(overtime_minutes) / 60, 2) as total_overtime_hours
FROM Employee_Attendance;
