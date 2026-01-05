-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Jan 01, 2026 at 08:08 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `Digious_CRM_DataBase`
--

-- --------------------------------------------------------

--
-- Stand-in structure for view `active_users_view`
-- (See below for the actual view)
--
CREATE TABLE `active_users_view` (
`id` int(11)
,`employee_id` int(11)
,`email` varchar(255)
,`name` varchar(255)
,`login_time` timestamp
,`device_type` enum('PC','Mobile','Tablet','Other')
,`device_name` varchar(255)
,`ip_address` varchar(45)
,`hostname` varchar(255)
,`mac_address` varchar(17)
,`browser` varchar(100)
,`os` varchar(100)
,`country` varchar(100)
,`city` varchar(100)
,`last_activity_time` timestamp
,`logged_in_minutes` bigint(21)
,`is_active` tinyint(1)
);

-- --------------------------------------------------------

--
-- Table structure for table `admin_users`
--

CREATE TABLE `admin_users` (
  `id` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `role` enum('admin','super_admin') NOT NULL DEFAULT 'admin',
  `status` enum('Active','Inactive') NOT NULL DEFAULT 'Active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `admin_users`
--

INSERT INTO `admin_users` (`id`, `email`, `password`, `full_name`, `phone`, `role`, `status`, `created_at`, `updated_at`) VALUES
(1, 'admin@digious.com', '$2a$12$Tdc/e2C9kf.GOIVDwS0HQ.GIqPNlmfjL.R5wImzRWSHniZO1eKDUa', 'Administrator', '03100000000', 'super_admin', 'Active', '2025-12-28 16:04:33', '2025-12-29 17:06:53');

-- --------------------------------------------------------

--
-- Stand-in structure for view `Attendance_Summary_View`
-- (See below for the actual view)
--
CREATE TABLE `Attendance_Summary_View` (
`employee_id` int(11)
,`name` varchar(100)
,`email` varchar(100)
,`attendance_date` date
,`check_in_time` time
,`check_out_time` time
,`status` enum('Present','Absent','Late','On Leave','Half Day')
,`total_breaks_taken` int(11)
,`total_break_duration_minutes` int(11)
,`gross_working_time` varchar(26)
,`net_working_time` varchar(26)
,`overtime_hours` decimal(5,2)
,`on_time` tinyint(1)
,`late_by_minutes` int(11)
,`created_at` timestamp
,`updated_at` timestamp
);

-- --------------------------------------------------------

--
-- Table structure for table `Company_Rules`
--

CREATE TABLE `Company_Rules` (
  `id` int(11) NOT NULL,
  `rule_name` varchar(100) NOT NULL,
  `rule_type` enum('WORKING_HOURS','BREAK_TIME','OVERTIME','LEAVE') NOT NULL,
  `description` text DEFAULT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `total_hours` int(11) DEFAULT NULL,
  `break_duration_minutes` int(11) DEFAULT NULL,
  `break_type` varchar(50) DEFAULT NULL,
  `overtime_starts_after_minutes` int(11) DEFAULT NULL,
  `overtime_multiplier` decimal(3,2) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `priority` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `Company_Rules`
--

INSERT INTO `Company_Rules` (`id`, `rule_name`, `rule_type`, `description`, `start_time`, `end_time`, `total_hours`, `break_duration_minutes`, `break_type`, `overtime_starts_after_minutes`, `overtime_multiplier`, `is_active`, `priority`, `created_at`, `updated_at`) VALUES
(1, 'Office Working Hours - Night Shift', 'WORKING_HOURS', 'Office working hours from 21:00 (9 PM) to 06:00 (6 AM)', '21:00:00', '06:00:00', 9, NULL, NULL, NULL, NULL, 1, 1, '2025-12-23 16:25:46', '2025-12-23 16:25:46'),
(2, 'Smoke Break', 'BREAK_TIME', 'Smoke break allowed during working hours', NULL, NULL, NULL, 5, 'Smoke Break', NULL, NULL, 1, 2, '2025-12-23 16:25:46', '2025-12-23 16:25:46'),
(3, 'Dinner Break', 'BREAK_TIME', 'Dinner/Lunch break during working hours', NULL, NULL, NULL, 60, 'Dinner Break', NULL, NULL, 1, 2, '2025-12-23 16:25:46', '2025-12-23 16:25:46'),
(4, 'Washroom Break', 'BREAK_TIME', 'Washroom/Restroom break', NULL, NULL, NULL, 10, 'Washroom Break', NULL, NULL, 1, 3, '2025-12-23 16:25:46', '2025-12-23 16:25:46'),
(5, 'Prayer Break', 'BREAK_TIME', 'Prayer break during working hours', NULL, NULL, NULL, 10, 'Prayer Break', NULL, NULL, 1, 3, '2025-12-23 16:25:46', '2025-12-23 16:25:46'),
(6, 'Overtime - Standard Rate', 'OVERTIME', 'Overtime payment after regular working hours (9 hours)', NULL, NULL, NULL, NULL, NULL, 540, 1.50, 1, 4, '2025-12-23 16:25:46', '2025-12-23 16:25:46');

-- --------------------------------------------------------

--
-- Table structure for table `Employee_Activities`
--

CREATE TABLE `Employee_Activities` (
  `id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `activity_type` varchar(50) NOT NULL,
  `action` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  `location` varchar(100) DEFAULT NULL,
  `device` varchar(100) DEFAULT NULL,
  `duration_minutes` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `employee_allowances`
--

CREATE TABLE `employee_allowances` (
  `id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `allowance_name` varchar(100) NOT NULL,
  `allowance_amount` decimal(12,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `employee_allowances`
--

INSERT INTO `employee_allowances` (`id`, `employee_id`, `allowance_name`, `allowance_amount`, `created_at`) VALUES
(1, 1, 'Housing Allowance', 5000.00, '2025-11-01 10:00:00'),
(2, 1, 'Transport Allowance', 2000.00, '2025-11-01 10:00:00'),
(3, 2, 'Transport Allowance', 1500.00, '2025-11-15 09:30:00'),
(4, 3, 'Housing Allowance', 8000.00, '2025-10-20 08:00:00'),
(5, 4, 'Sales Incentive', 3000.00, '2025-11-01 11:00:00'),
(6, 5, 'Professional Allowance', 2500.00, '2025-12-01 10:30:00');

-- --------------------------------------------------------

--
-- Table structure for table `Employee_Attendance`
--

CREATE TABLE `Employee_Attendance` (
  `id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `name` varchar(100) NOT NULL,
  `attendance_date` date NOT NULL,
  `check_in_time` time DEFAULT NULL,
  `check_out_time` time DEFAULT NULL,
  `status` enum('Present','Absent','Late','On Leave','Half Day') DEFAULT 'Absent',
  `total_breaks_taken` int(11) DEFAULT 0,
  `smoke_break_count` int(11) DEFAULT 0,
  `dinner_break_count` int(11) DEFAULT 0,
  `washroom_break_count` int(11) DEFAULT 0,
  `prayer_break_count` int(11) DEFAULT 0,
  `smoke_break_duration_minutes` int(11) DEFAULT 0,
  `dinner_break_duration_minutes` int(11) DEFAULT 0,
  `washroom_break_duration_minutes` int(11) DEFAULT 0,
  `prayer_break_duration_minutes` int(11) DEFAULT 0,
  `total_break_duration_minutes` int(11) DEFAULT 0,
  `gross_working_time_minutes` int(11) DEFAULT 0,
  `net_working_time_minutes` int(11) DEFAULT 0,
  `expected_working_time_minutes` int(11) DEFAULT 540,
  `overtime_minutes` int(11) DEFAULT 0,
  `overtime_hours` decimal(5,2) DEFAULT 0.00,
  `on_time` tinyint(1) DEFAULT 0,
  `late_by_minutes` int(11) DEFAULT 0,
  `remarks` text DEFAULT NULL,
  `device_info` text DEFAULT NULL,
  `ip_address` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `Employee_Attendance`
--

INSERT INTO `Employee_Attendance` (`id`, `employee_id`, `email`, `name`, `attendance_date`, `check_in_time`, `check_out_time`, `status`, `total_breaks_taken`, `smoke_break_count`, `dinner_break_count`, `washroom_break_count`, `prayer_break_count`, `smoke_break_duration_minutes`, `dinner_break_duration_minutes`, `washroom_break_duration_minutes`, `prayer_break_duration_minutes`, `total_break_duration_minutes`, `gross_working_time_minutes`, `net_working_time_minutes`, `expected_working_time_minutes`, `overtime_minutes`, `overtime_hours`, `on_time`, `late_by_minutes`, `remarks`, `device_info`, `ip_address`, `created_at`, `updated_at`) VALUES
-- November 2025 Data
(1, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-11-01', '21:00:00', '06:00:00', 'Present', 4, 2, 1, 1, 0, 10, 60, 10, 0, 80, 540, 460, 540, 0, 0.00, 1, 0, 'First day on job', 'Mozilla/5.0 Chrome', '192.168.1.100', '2025-11-01 21:00:00', '2025-11-01 21:00:00'),
(2, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-11-02', '21:15:00', '06:30:00', 'Late', 3, 1, 1, 1, 0, 5, 45, 8, 0, 58, 555, 497, 540, 0, 0.00, 0, 15, 'Traffic jam', 'Mozilla/5.0 Chrome', '192.168.1.100', '2025-11-02 21:15:00', '2025-11-02 21:15:00'),
(3, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-11-03', '20:45:00', '06:45:00', 'Present', 5, 3, 1, 1, 0, 15, 60, 5, 0, 80, 600, 520, 540, 60, 1.00, 1, 0, 'Overtime for project deadline', 'Mozilla/5.0 Chrome', '192.168.1.100', '2025-11-03 20:45:00', '2025-11-03 20:45:00'),
(4, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-11-04', '21:05:00', '06:05:00', 'Present', 4, 2, 1, 1, 0, 10, 50, 7, 0, 67, 540, 473, 540, 0, 0.00, 1, 5, NULL, 'Mozilla/5.0 Chrome', '192.168.1.100', '2025-11-04 21:05:00', '2025-11-04 21:05:00'),
(5, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-11-05', '21:00:00', '07:15:00', 'Present', 3, 1, 1, 1, 0, 5, 60, 10, 0, 75, 615, 540, 540, 75, 1.25, 1, 0, 'Extra work on features', 'Mozilla/5.0 Chrome', '192.168.1.100', '2025-11-05 21:00:00', '2025-11-05 21:00:00'),
(6, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-11-15', '21:00:00', '06:00:00', 'Present', 4, 2, 1, 1, 0, 8, 45, 12, 0, 65, 540, 475, 540, 0, 0.00, 1, 0, 'First day', 'Mozilla/5.0 Firefox', '192.168.1.101', '2025-11-15 21:00:00', '2025-11-15 21:00:00'),
(7, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-11-16', '21:30:00', '06:30:00', 'Late', 2, 1, 1, 0, 0, 5, 30, 0, 0, 35, 540, 505, 540, 0, 0.00, 0, 30, 'Overslept', 'Mozilla/5.0 Firefox', '192.168.1.101', '2025-11-16 21:30:00', '2025-11-16 21:30:00'),
(8, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-11-17', '21:00:00', '06:00:00', 'Present', 3, 1, 1, 1, 0, 5, 40, 8, 0, 53, 540, 487, 540, 0, 0.00, 1, 0, NULL, 'Mozilla/5.0 Firefox', '192.168.1.101', '2025-11-17 21:00:00', '2025-11-17 21:00:00'),
-- December 2025 Data
(9, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-12-01', '20:50:00', '06:50:00', 'Present', 4, 2, 1, 1, 0, 10, 55, 10, 0, 75, 600, 525, 540, 60, 1.00, 1, 0, 'Working on year-end project', 'Mozilla/5.0 Chrome', '192.168.1.100', '2025-12-01 20:50:00', '2025-12-01 20:50:00'),
(10, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-12-01', '21:20:00', '06:00:00', 'Late', 3, 1, 1, 1, 0, 5, 45, 7, 0, 57, 520, 463, 540, 0, 0.00, 0, 20, 'Car trouble', 'Mozilla/5.0 Firefox', '192.168.1.101', '2025-12-01 21:20:00', '2025-12-01 21:20:00'),
(11, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-12-01', '21:00:00', '06:00:00', 'Present', 2, 0, 1, 1, 0, 0, 45, 8, 0, 53, 540, 487, 540, 0, 0.00, 1, 0, NULL, 'Mozilla/5.0 Safari', '192.168.1.102', '2025-12-01 21:00:00', '2025-12-01 21:00:00'),
(12, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-12-01', '21:00:00', '07:30:00', 'Present', 3, 1, 1, 1, 0, 5, 60, 10, 0, 75, 630, 555, 540, 90, 1.50, 1, 0, 'Working late on sales reports', 'Mozilla/5.0 Edge', '192.168.1.103', '2025-12-01 21:00:00', '2025-12-01 21:00:00'),
(13, 5, 'sara.ahmed@digious.com', 'Sara Ahmed', '2025-12-01', '21:00:00', '06:00:00', 'Present', 2, 0, 1, 1, 0, 0, 50, 5, 0, 55, 540, 485, 540, 0, 0.00, 1, 0, 'First day', 'Mozilla/5.0 Chrome', '192.168.1.104', '2025-12-01 21:00:00', '2025-12-01 21:00:00'),
(14, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-12-02', '21:10:00', '06:10:00', 'Present', 5, 3, 1, 1, 0, 15, 60, 8, 0, 83, 540, 457, 540, 0, 0.00, 1, 10, NULL, 'Mozilla/5.0 Chrome', '192.168.1.100', '2025-12-02 21:10:00', '2025-12-02 21:10:00'),
(15, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-12-02', '21:45:00', '06:45:00', 'Late', 2, 1, 1, 0, 0, 5, 35, 0, 0, 40, 540, 500, 540, 0, 0.00, 0, 45, 'Family emergency', 'Mozilla/5.0 Firefox', '192.168.1.101', '2025-12-02 21:45:00', '2025-12-02 21:45:00'),
(16, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-12-15', '21:00:00', '08:00:00', 'Present', 4, 1, 1, 2, 0, 5, 60, 15, 0, 80, 660, 580, 540, 120, 2.00, 1, 0, 'HR policy review meeting ran late', 'Mozilla/5.0 Safari', '192.168.1.102', '2025-12-15 21:00:00', '2025-12-15 21:00:00'),
(17, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-12-15', '22:00:00', '06:00:00', 'Late', 2, 1, 1, 0, 0, 5, 45, 0, 0, 50, 480, 430, 540, 0, 0.00, 0, 60, 'Client meeting ran over', 'Mozilla/5.0 Edge', '192.168.1.103', '2025-12-15 22:00:00', '2025-12-15 22:00:00'),
(18, 5, 'sara.ahmed@digious.com', 'Sara Ahmed', '2025-12-15', '21:00:00', '06:00:00', 'Present', 3, 0, 1, 2, 0, 0, 55, 12, 0, 67, 540, 473, 540, 0, 0.00, 1, 0, NULL, 'Mozilla/5.0 Chrome', '192.168.1.104', '2025-12-15 21:00:00', '2025-12-15 21:00:00'),
(19, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-12-30', '21:00:00', '08:30:00', 'Present', 6, 4, 1, 1, 0, 20, 60, 10, 0, 90, 690, 600, 540, 150, 2.50, 1, 0, 'Year-end deployment', 'Mozilla/5.0 Chrome', '192.168.1.100', '2025-12-30 21:00:00', '2025-12-30 21:00:00'),
(20, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-12-30', '22:30:00', '06:30:00', 'Late', 3, 2, 1, 0, 0, 10, 40, 0, 0, 50, 480, 430, 540, 0, 0.00, 0, 90, 'New Year party hangover', 'Mozilla/5.0 Firefox', '192.168.1.101', '2025-12-30 22:30:00', '2025-12-30 22:30:00'),
-- January 2026 Data (current month)
(21, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-01', '21:00:00', '06:00:00', 'Present', 3, 1, 1, 1, 0, 5, 45, 8, 0, 58, 540, 482, 540, 0, 0.00, 1, 0, 'New Year - normal shift', 'Mozilla/5.0 Chrome', '192.168.1.100', '2026-01-01 21:00:00', '2026-01-01 21:00:00'),
(22, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-02', '21:00:00', '06:00:00', 'Present', 2, 0, 1, 1, 0, 0, 50, 7, 0, 57, 540, 483, 540, 0, 0.00, 1, 0, 'Back from holidays', 'Mozilla/5.0 Safari', '192.168.1.102', '2026-01-02 21:00:00', '2026-01-02 21:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `Employee_Breaks`
--

CREATE TABLE `Employee_Breaks` (
  `id` int(11) NOT NULL,
  `attendance_id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `break_type` enum('Smoke','Dinner','Washroom','Prayer','Other') NOT NULL,
  `break_start_time` time NOT NULL,
  `break_end_time` time DEFAULT NULL,
  `break_duration_minutes` int(11) DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `Employee_Breaks`
--

INSERT INTO `Employee_Breaks` (`id`, `attendance_id`, `employee_id`, `break_type`, `break_start_time`, `break_end_time`, `break_duration_minutes`, `reason`, `created_at`, `updated_at`) VALUES
-- November 2025 Breaks
(1, 1, 1, 'Smoke', '22:30:00', '22:35:00', 5, 'Smoke break', '2025-11-01 22:30:00', '2025-11-01 22:30:00'),
(2, 1, 1, 'Smoke', '01:15:00', '01:20:00', 5, 'Smoke break', '2025-11-02 01:15:00', '2025-11-02 01:15:00'),
(3, 1, 1, 'Dinner', '02:00:00', '03:00:00', 60, 'Dinner break', '2025-11-02 02:00:00', '2025-11-02 02:00:00'),
(4, 1, 1, 'Washroom', '04:30:00', '04:40:00', 10, 'Restroom break', '2025-11-02 04:30:00', '2025-11-02 04:30:00'),
(5, 2, 1, 'Smoke', '23:00:00', '23:05:00', 5, 'Smoke break', '2025-11-02 23:00:00', '2025-11-02 23:00:00'),
(6, 2, 1, 'Dinner', '01:30:00', '02:15:00', 45, 'Dinner break', '2025-11-03 01:30:00', '2025-11-03 01:30:00'),
(7, 2, 1, 'Washroom', '04:00:00', '04:08:00', 8, 'Restroom break', '2025-11-03 04:00:00', '2025-11-03 04:00:00'),
(8, 3, 1, 'Smoke', '22:15:00', '22:20:00', 5, 'Smoke break', '2025-11-03 22:15:00', '2025-11-03 22:15:00'),
(9, 3, 1, 'Smoke', '00:30:00', '00:35:00', 5, 'Smoke break', '2025-11-04 00:30:00', '2025-11-04 00:30:00'),
(10, 3, 1, 'Smoke', '03:15:00', '03:20:00', 5, 'Smoke break', '2025-11-04 03:15:00', '2025-11-04 03:15:00'),
(11, 3, 1, 'Dinner', '01:00:00', '02:00:00', 60, 'Dinner break', '2025-11-04 01:00:00', '2025-11-04 01:00:00'),
(12, 3, 1, 'Washroom', '05:00:00', '05:05:00', 5, 'Quick break', '2025-11-04 05:00:00', '2025-11-04 05:00:00'),
-- December 2025 Breaks
(13, 9, 1, 'Smoke', '22:30:00', '22:40:00', 10, 'Smoke break', '2025-12-01 22:30:00', '2025-12-01 22:30:00'),
(14, 9, 1, 'Dinner', '01:30:00', '02:25:00', 55, 'Dinner break', '2025-12-02 01:30:00', '2025-12-02 01:30:00'),
(15, 9, 1, 'Washroom', '04:15:00', '04:25:00', 10, 'Restroom break', '2025-12-02 04:15:00', '2025-12-02 04:15:00'),
(16, 10, 2, 'Smoke', '22:45:00', '22:50:00', 5, 'Smoke break', '2025-12-01 22:45:00', '2025-12-01 22:45:00'),
(17, 10, 2, 'Dinner', '02:00:00', '02:45:00', 45, 'Late dinner', '2025-12-02 02:00:00', '2025-12-02 02:00:00'),
(18, 10, 2, 'Washroom', '04:30:00', '04:37:00', 7, 'Quick break', '2025-12-02 04:30:00', '2025-12-02 04:30:00'),
(19, 11, 3, 'Dinner', '01:15:00', '02:00:00', 45, 'Dinner break', '2025-12-02 01:15:00', '2025-12-02 01:15:00'),
(20, 11, 3, 'Washroom', '03:45:00', '03:53:00', 8, 'Restroom break', '2025-12-02 03:45:00', '2025-12-02 03:45:00'),
(21, 12, 4, 'Smoke', '23:00:00', '23:05:00', 5, 'Smoke break', '2025-12-01 23:00:00', '2025-12-01 23:00:00'),
(22, 12, 4, 'Dinner', '02:30:00', '03:30:00', 60, 'Working dinner', '2025-12-02 02:30:00', '2025-12-02 02:30:00'),
(23, 12, 4, 'Washroom', '05:15:00', '05:25:00', 10, 'Break before overtime', '2025-12-02 05:15:00', '2025-12-02 05:15:00'),
(24, 16, 3, 'Smoke', '22:30:00', '22:35:00', 5, 'Smoke break', '2025-12-15 22:30:00', '2025-12-15 22:30:00'),
(25, 16, 3, 'Dinner', '01:00:00', '02:00:00', 60, 'Dinner during meeting break', '2025-12-16 01:00:00', '2025-12-16 01:00:00'),
(26, 16, 3, 'Washroom', '03:30:00', '03:38:00', 8, 'Quick break', '2025-12-16 03:30:00', '2025-12-16 03:30:00'),
(27, 16, 3, 'Washroom', '06:15:00', '06:22:00', 7, 'Before leaving', '2025-12-16 06:15:00', '2025-12-16 06:15:00'),
(28, 19, 1, 'Smoke', '22:00:00', '22:05:00', 5, 'Year-end stress relief', '2025-12-30 22:00:00', '2025-12-30 22:00:00'),
(29, 19, 1, 'Smoke', '00:30:00', '00:35:00', 5, 'Midnight break', '2025-12-31 00:30:00', '2025-12-31 00:30:00'),
(30, 19, 1, 'Smoke', '03:15:00', '03:25:00', 10, 'Long break', '2025-12-31 03:15:00', '2025-12-31 03:15:00'),
(31, 19, 1, 'Dinner', '01:30:00', '02:30:00', 60, 'Working dinner', '2025-12-31 01:30:00', '2025-12-31 01:30:00'),
(32, 19, 1, 'Washroom', '05:45:00', '05:55:00', 10, 'Final break', '2025-12-31 05:45:00', '2025-12-31 05:45:00'),
-- January 2026 Breaks
(33, 21, 1, 'Smoke', '23:30:00', '23:35:00', 5, 'New Year smoke', '2026-01-01 23:30:00', '2026-01-01 23:30:00'),
(34, 21, 1, 'Dinner', '02:00:00', '02:45:00', 45, 'New Year dinner', '2026-01-02 02:00:00', '2026-01-02 02:00:00'),
(35, 21, 1, 'Washroom', '04:30:00', '04:38:00', 8, 'Quick break', '2026-01-02 04:30:00', '2026-01-02 04:30:00'),
(36, 22, 3, 'Dinner', '01:15:00', '02:05:00', 50, 'Back from holidays dinner', '2026-01-03 01:15:00', '2026-01-03 01:15:00'),
(37, 22, 3, 'Washroom', '04:00:00', '04:07:00', 7, 'Quick break', '2026-01-03 04:00:00', '2026-01-03 04:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `employee_dynamic_resources`
--

CREATE TABLE `employee_dynamic_resources` (
  `id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `resource_name` varchar(100) NOT NULL,
  `resource_serial` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `employee_onboarding`
--

CREATE TABLE `employee_onboarding` (
  `id` int(11) NOT NULL,
  `employee_id` varchar(50) NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_temp` varchar(255) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `department` varchar(100) NOT NULL,
  `position` varchar(100) NOT NULL,
  `join_date` date NOT NULL,
  `address` text DEFAULT NULL,
  `emergency_contact` varchar(255) DEFAULT NULL,
  `request_password_change` tinyint(1) DEFAULT 1,
  `bank_account` varchar(50) DEFAULT NULL,
  `tax_id` varchar(50) DEFAULT NULL,
  `cnic` varchar(20) DEFAULT NULL,
  `designation` varchar(100) DEFAULT NULL,
  `status` enum('Pending','Active','Inactive','Suspended') DEFAULT 'Active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `employee_onboarding`
--

INSERT INTO `employee_onboarding` (`id`, `employee_id`, `name`, `email`, `password_temp`, `phone`, `department`, `position`, `join_date`, `address`, `emergency_contact`, `request_password_change`, `bank_account`, `tax_id`, `cnic`, `designation`, `status`, `created_at`, `updated_at`) VALUES
(1, 'DIG-001', 'Muhammad Hunain', 'muhammad.hunain@digious.com', '$2a$12$Tdc/e2C9kf.GOIVDwS0HQ.GIqPNlmfjL.R5wImzRWSHniZO1eKDUa', '03183598103', 'Production', 'Software Engineer', '2025-11-01', 'Nazimabad, Karachi', '03123598003', 0, 'PKRIBAN123456', '123456789', '4210151036535', 'Senior Developer', 'Active', '2025-11-01 10:00:00', '2025-12-29 15:18:20'),
(2, 'DIG-002', 'Ahmed Ali', 'ahmed.ali@digious.com', '$2a$12$Tdc/e2C9kf.GOIVDwS0HQ.GIqPNlmfjL.R5wImzRWSHniZO1eKDUa', '03215678901', 'Production', 'Software Developer', '2025-11-15', 'Gulshan, Karachi', '03005555555', 1, 'PKRIBAN654321', '987654321', '4210252547382', 'Junior Developer', 'Active', '2025-11-15 09:30:00', '2025-12-29 15:18:20'),
(3, 'DIG-003', 'Fatima Khan', 'fatima.khan@digious.com', '$2a$12$Tdc/e2C9kf.GOIVDwS0HQ.GIqPNlmfjL.R5wImzRWSHniZO1eKDUa', '03045678901', 'HR', 'HR Manager', '2025-10-20', 'Clifton, Karachi', '03006666666', 0, 'PKRIBAN789012', 'SSN12345', '4210351045678', 'HR Manager', 'Active', '2025-10-20 08:00:00', '2025-12-29 15:18:20'),
(4, 'DIG-004', 'Hassan Raza', 'hassan.raza@digious.com', '$2a$12$Tdc/e2C9kf.GOIVDwS0HQ.GIqPNlmfjL.R5wImzRWSHniZO1eKDUa', '03134455667', 'Sales', 'Sales Manager', '2025-11-01', 'Defense, Karachi', '03007777777', 1, 'PKRIBAN345678', 'PAN123456', '4210452658934', 'Sales Head', 'Active', '2025-11-01 11:00:00', '2025-12-29 15:18:20'),
(5, 'DIG-005', 'Sara Ahmed', 'sara.ahmed@digious.com', '$2a$12$Tdc/e2C9kf.GOIVDwS0HQ.GIqPNlmfjL.R5wImzRWSHniZO1eKDUa', '03008888888', 'Finance', 'Finance Officer', '2025-12-01', 'Saddar, Karachi', '03009999999', 1, 'PKRIBAN901234', 'TIN456789', '4210552759045', 'Finance Officer', 'Active', '2025-12-01 10:30:00', '2025-12-29 15:18:20');

--
-- Triggers `employee_onboarding`
--
DELIMITER $$
CREATE TRIGGER `after_employee_delete` AFTER DELETE ON `employee_onboarding` FOR EACH ROW BEGIN
    -- Mark user as inactive instead of deleting (for audit trail)
    UPDATE user_as_employees
    SET 
        status = 'Inactive',
        updated_at = NOW()
    WHERE employee_id = OLD.id;
    
    -- Optionally, you can delete instead:
    -- DELETE FROM user_as_employees WHERE employee_id = OLD.employee_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_employee_insert` AFTER INSERT ON `employee_onboarding` FOR EACH ROW BEGIN
    -- Insert into user_as_employees with essential auth information
    -- employee_id here is the numeric ID (foreign key to employee_onboarding.id)
    INSERT INTO user_as_employees (
        employee_id,
        name,
        email,
        password,
        department,
        position,
        designation,
        status,
        request_password_change,
        created_at,
        updated_at
    ) VALUES (
        NEW.id,  -- Use the auto-increment ID, not the employee_id string
        NEW.name,
        NEW.email,
        NEW.password_temp,  -- Copy the hashed password from onboarding
        NEW.department,
        NEW.position,
        NEW.designation,
        NEW.status,
        TRUE,  -- Always request password change for new employees
        NOW(),
        NOW()
    )
    ON DUPLICATE KEY UPDATE
        name = VALUES(name),
        email = VALUES(email),
        password = VALUES(password),
        department = VALUES(department),
        position = VALUES(position),
        designation = VALUES(designation),
        status = VALUES(status),
        updated_at = NOW();
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_employee_update` AFTER UPDATE ON `employee_onboarding` FOR EACH ROW BEGIN
    -- Update user_as_employees with changed information
    -- Only update password if it changed in onboarding and user hasn't changed it yet
    IF OLD.password_temp != NEW.password_temp THEN
        -- Password was reset in onboarding, update and request change
        UPDATE user_as_employees
        SET 
            name = NEW.name,
            email = NEW.email,
            password = NEW.password_temp,
            department = NEW.department,
            position = NEW.position,
            designation = NEW.designation,
            status = NEW.status,
            request_password_change = TRUE,
            updated_at = NOW()
        WHERE employee_id = NEW.id;
    ELSE
        -- Regular update, don't touch password
        UPDATE user_as_employees
        SET 
            name = NEW.name,
            email = NEW.email,
            department = NEW.department,
            position = NEW.position,
            designation = NEW.designation,
            status = NEW.status,
            updated_at = NOW()
        WHERE employee_id = NEW.id;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `employee_resources`
--

CREATE TABLE `employee_resources` (
  `id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `laptop` tinyint(1) DEFAULT 0,
  `laptop_serial` varchar(100) DEFAULT NULL,
  `charger` tinyint(1) DEFAULT 0,
  `charger_serial` varchar(100) DEFAULT NULL,
  `mouse` tinyint(1) DEFAULT 0,
  `mouse_serial` varchar(100) DEFAULT NULL,
  `keyboard` tinyint(1) DEFAULT 0,
  `keyboard_serial` varchar(100) DEFAULT NULL,
  `monitor` tinyint(1) DEFAULT 0,
  `monitor_serial` varchar(100) DEFAULT NULL,
  `mobile` tinyint(1) DEFAULT 0,
  `mobile_serial` varchar(100) DEFAULT NULL,
  `resources_note` text DEFAULT NULL,
  `allocated_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `returned_date` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `employee_resources`
--

INSERT INTO `employee_resources` (`id`, `employee_id`, `laptop`, `laptop_serial`, `charger`, `charger_serial`, `mouse`, `mouse_serial`, `keyboard`, `keyboard_serial`, `monitor`, `monitor_serial`, `mobile`, `mobile_serial`, `resources_note`, `allocated_date`, `returned_date`) VALUES
(1, 1, 1, 'DELL-DIG-0001', 1, 'CHARGER-001', 1, 'MOUSE-001', 1, 'KEYBOARD-001', 1, 'MONITOR-001', 1, 'MOBILE-001', 'Good Condition', '2025-11-01 10:00:00', NULL),
(2, 2, 1, 'DELL-DIG-0002', 1, 'CHARGER-002', 1, 'MOUSE-002', 1, 'KEYBOARD-002', 1, 'MONITOR-002', 1, 'MOBILE-002', 'New Equipment', '2025-11-15 09:30:00', NULL),
(3, 3, 1, 'DELL-DIG-0003', 1, 'CHARGER-003', 1, 'MOUSE-003', 1, 'KEYBOARD-003', 1, 'MONITOR-003', 1, 'MOBILE-003', 'Good Condition', '2025-10-20 08:00:00', NULL),
(4, 4, 1, 'DELL-DIG-0004', 1, 'CHARGER-004', 1, 'MOUSE-004', 0, NULL, 1, 'MONITOR-004', 1, 'MOBILE-004', 'Working', '2025-11-01 11:00:00', NULL),
(5, 5, 1, 'DELL-DIG-0005', 1, 'CHARGER-005', 1, 'MOUSE-005', 1, 'KEYBOARD-005', 0, NULL, 0, NULL, 'Needs Monitor Setup', '2025-12-01 10:30:00', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `employee_salary`
--

CREATE TABLE `employee_salary` (
  `id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `base_salary` decimal(12,2) NOT NULL,
  `total_salary` decimal(12,2) DEFAULT NULL,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `employee_salary`
--

INSERT INTO `employee_salary` (`id`, `employee_id`, `base_salary`, `total_salary`, `last_updated`) VALUES
(1, 1, 100000.00, 107000.00, '2025-11-01 10:00:00'),
(2, 2, 75000.00, 76500.00, '2025-11-15 09:30:00'),
(3, 3, 95000.00, 103000.00, '2025-10-20 08:00:00'),
(4, 4, 85000.00, 91000.00, '2025-11-01 11:00:00'),
(5, 5, 65000.00, 67500.00, '2025-12-01 10:30:00');

-- --------------------------------------------------------

--
-- Stand-in structure for view `Monthly_Attendance_Summary`
-- (See below for the actual view)
--
CREATE TABLE `Monthly_Attendance_Summary` (
`employee_id` int(11)
,`name` varchar(100)
,`email` varchar(100)
,`year` int(4)
,`month` int(2)
,`total_days` bigint(21)
,`present_days` decimal(22,0)
,`absent_days` decimal(22,0)
,`late_days` decimal(22,0)
,`leave_days` decimal(22,0)
,`attendance_rate` decimal(28,2)
,`on_time_rate` decimal(28,2)
,`total_working_minutes` decimal(32,0)
,`total_overtime_minutes` decimal(32,0)
,`total_break_minutes` decimal(32,0)
);

-- --------------------------------------------------------

--
-- Table structure for table `onboarding_progress`
--

CREATE TABLE `onboarding_progress` (
  `id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `step_1_basic_info` tinyint(1) DEFAULT 0,
  `step_1_completed_at` timestamp NULL DEFAULT NULL,
  `step_2_security_setup` tinyint(1) DEFAULT 0,
  `step_2_completed_at` timestamp NULL DEFAULT NULL,
  `step_3_job_details` tinyint(1) DEFAULT 0,
  `step_3_completed_at` timestamp NULL DEFAULT NULL,
  `step_4_allowances` tinyint(1) DEFAULT 0,
  `step_4_completed_at` timestamp NULL DEFAULT NULL,
  `step_5_additional_info` tinyint(1) DEFAULT 0,
  `step_5_completed_at` timestamp NULL DEFAULT NULL,
  `step_6_review_confirm` tinyint(1) DEFAULT 0,
  `step_6_completed_at` timestamp NULL DEFAULT NULL,
  `overall_completion_percentage` int(11) DEFAULT 0,
  `is_completed` tinyint(1) DEFAULT 0,
  `completed_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `onboarding_progress`
--

INSERT INTO `onboarding_progress` (`id`, `employee_id`, `step_1_basic_info`, `step_1_completed_at`, `step_2_security_setup`, `step_2_completed_at`, `step_3_job_details`, `step_3_completed_at`, `step_4_allowances`, `step_4_completed_at`, `step_5_additional_info`, `step_5_completed_at`, `step_6_review_confirm`, `step_6_completed_at`, `overall_completion_percentage`, `is_completed`, `completed_at`) VALUES
(1, 1, 1, '2025-11-01 10:30:00', 1, '2025-11-01 11:00:00', 1, '2025-11-01 11:30:00', 1, '2025-11-01 12:00:00', 1, '2025-11-01 12:30:00', 1, '2025-11-01 13:00:00', 100, 1, '2025-11-01 13:00:00'),
(2, 2, 1, '2025-11-15 10:00:00', 1, '2025-11-15 10:30:00', 1, '2025-11-15 11:00:00', 0, NULL, 0, NULL, 0, NULL, 50, 0, NULL),
(3, 3, 1, '2025-10-20 08:30:00', 1, '2025-10-20 09:00:00', 1, '2025-10-20 09:30:00', 1, '2025-10-20 10:00:00', 1, '2025-10-20 10:30:00', 1, '2025-10-20 11:00:00', 100, 1, '2025-10-20 11:00:00'),
(4, 4, 1, '2025-11-01 11:30:00', 1, '2025-11-01 12:00:00', 1, '2025-11-01 12:30:00', 1, '2025-11-01 13:00:00', 1, '2025-11-01 13:30:00', 0, NULL, 85, 0, NULL),
(5, 5, 1, '2025-12-01 11:00:00', 1, '2025-12-01 11:30:00', 1, '2025-12-01 12:00:00', 0, NULL, 0, NULL, 0, NULL, 50, 0, NULL);

-- --------------------------------------------------------

--
-- Stand-in structure for view `Overtime_Report_View`
-- (See below for the actual view)
--
CREATE TABLE `Overtime_Report_View` (
`employee_id` int(11)
,`name` varchar(100)
,`email` varchar(100)
,`attendance_date` date
,`check_in_time` time
,`check_out_time` time
,`net_working_time_minutes` int(11)
,`expected_working_time_minutes` int(11)
,`overtime_minutes` int(11)
,`overtime_hours` decimal(5,2)
,`overtime_pay_multiplier` decimal(7,2)
);

-- --------------------------------------------------------

--
-- Table structure for table `user_as_employees`
--

CREATE TABLE `user_as_employees` (
  `id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `department` varchar(100) DEFAULT NULL,
  `position` varchar(100) DEFAULT NULL,
  `designation` varchar(100) DEFAULT NULL,
  `status` enum('Active','Inactive','Suspended') DEFAULT 'Active',
  `request_password_change` tinyint(4) DEFAULT 1,
  `login_count` int(11) DEFAULT 0,
  `last_login_time` datetime DEFAULT NULL,
  `current_session_token` varchar(500) DEFAULT NULL,
  `session_token_expires_at` datetime DEFAULT NULL,
  `is_active` tinyint(4) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user_as_employees`
--

INSERT INTO `user_as_employees` (`id`, `employee_id`, `name`, `email`, `password`, `department`, `position`, `designation`, `status`, `request_password_change`, `login_count`, `last_login_time`, `current_session_token`, `session_token_expires_at`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 1, 'Muhammad Hunain', 'muhammad.hunain@digious.com', '$2a$12$Tdc/e2C9kf.GOIVDwS0HQ.GIqPNlmfjL.R5wImzRWSHniZO1eKDUa', 'Production', 'Software Engineer', 'Senior Developer', 'Active', 0, 15, '2026-01-02 09:00:00', NULL, NULL, 1, '2025-11-01 10:00:00', '2026-01-02 09:00:00'),
(2, 2, 'Ahmed Ali', 'ahmed.ali@digious.com', '$2a$12$Tdc/e2C9kf.GOIVDwS0HQ.GIqPNlmfjL.R5wImzRWSHniZO1eKDUa', 'Production', 'Software Developer', 'Junior Developer', 'Active', 1, 8, '2026-01-02 10:15:00', NULL, NULL, 1, '2025-11-15 09:30:00', '2026-01-02 10:15:00'),
(3, 3, 'Fatima Khan', 'fatima.khan@digious.com', '$2a$12$Tdc/e2C9kf.GOIVDwS0HQ.GIqPNlmfjL.R5wImzRWSHniZO1eKDUa', 'HR', 'HR Manager', 'HR Manager', 'Active', 0, 25, '2026-01-02 08:30:00', NULL, NULL, 1, '2025-10-20 08:00:00', '2026-01-02 08:30:00'),
(4, 4, 'Hassan Raza', 'hassan.raza@digious.com', '$2a$12$Tdc/e2C9kf.GOIVDwS0HQ.GIqPNlmfjL.R5wImzRWSHniZO1eKDUa', 'Sales', 'Sales Manager', 'Sales Head', 'Active', 1, 12, '2026-01-02 11:00:00', NULL, NULL, 1, '2025-11-01 11:00:00', '2026-01-02 11:00:00'),
(5, 5, 'Sara Ahmed', 'sara.ahmed@digious.com', '$2a$12$Tdc/e2C9kf.GOIVDwS0HQ.GIqPNlmfjL.R5wImzRWSHniZO1eKDUa', 'Finance', 'Finance Officer', 'Finance Officer', 'Active', 1, 5, '2026-01-02 09:30:00', NULL, NULL, 1, '2025-12-01 10:30:00', '2026-01-02 09:30:00');

-- --------------------------------------------------------

--
-- Table structure for table `user_concurrent_sessions`
--

CREATE TABLE `user_concurrent_sessions` (
  `id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `total_active_sessions` int(11) DEFAULT 0,
  `pc_count` int(11) DEFAULT 0,
  `mobile_count` int(11) DEFAULT 0,
  `tablet_count` int(11) DEFAULT 0,
  `other_count` int(11) DEFAULT 0,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user_concurrent_sessions`
--

INSERT INTO `user_concurrent_sessions` (`id`, `employee_id`, `email`, `total_active_sessions`, `pc_count`, `mobile_count`, `tablet_count`, `other_count`, `updated_at`) VALUES
(1, 1, 'muhammad.hunain@digious.com', 2, 1, 1, 0, 0, '2026-01-02 09:00:00'),
(2, 2, 'ahmed.ali@digious.com', 1, 1, 0, 0, 0, '2026-01-02 10:15:00'),
(3, 3, 'fatima.khan@digious.com', 3, 2, 0, 1, 0, '2026-01-02 08:30:00'),
(4, 4, 'hassan.raza@digious.com', 2, 1, 1, 0, 0, '2026-01-02 11:00:00'),
(5, 5, 'sara.ahmed@digious.com', 1, 1, 0, 0, 0, '2026-01-02 09:30:00');

-- --------------------------------------------------------

--
-- Stand-in structure for view `user_session_summary`
-- (See below for the actual view)
--
CREATE TABLE `user_session_summary` (
`id` int(11)
,`employee_id` varchar(50)
,`name` varchar(255)
,`email` varchar(255)
,`department` varchar(100)
,`total_active_sessions` bigint(21)
,`pc_sessions` bigint(21)
,`mobile_sessions` bigint(21)
,`tablet_sessions` bigint(21)
,`last_login_time` timestamp
,`all_ip_addresses` mediumtext
,`all_device_types` mediumtext
);

-- --------------------------------------------------------

--
-- Table structure for table `user_system_info`
--

CREATE TABLE `user_system_info` (
  `id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `session_token` varchar(500) NOT NULL,
  `email` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `login_time` timestamp NOT NULL DEFAULT current_timestamp(),
  `logout_time` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `device_type` enum('PC','Mobile','Tablet','Other') DEFAULT 'PC',
  `device_name` varchar(255) DEFAULT NULL,
  `browser` varchar(100) DEFAULT NULL,
  `os` varchar(100) DEFAULT NULL,
  `ip_address` varchar(45) NOT NULL,
  `hostname` varchar(255) DEFAULT NULL,
  `mac_address` varchar(17) DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `timezone` varchar(50) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `last_activity_time` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
--
-- Dumping data for table `user_system_info`
--

INSERT INTO `user_system_info` (`id`, `employee_id`, `session_token`, `email`, `name`, `login_time`, `logout_time`, `is_active`, `device_type`, `device_name`, `browser`, `os`, `ip_address`, `hostname`, `mac_address`, `country`, `city`, `timezone`, `user_agent`, `last_activity_time`, `created_at`, `updated_at`) VALUES
(1, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTczNTgyNjQwMH0.abc123', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 09:00:00', NULL, 1, 'PC', 'Dell Laptop', 'Chrome', 'Windows 10', '192.168.1.100', 'DEV-PC-001', '00:11:22:33:44:55', 'Pakistan', 'Karachi', 'Asia/Karachi', 'Mozilla/5.0 Chrome/120.0', '2026-01-02 09:30:00', '2026-01-02 09:00:00', '2026-01-02 09:30:00'),
(2, 2, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIsImlhdCI6MTczNTgzMTQwMH0.def456', 'ahmed.ali@digious.com', 'Ahmed Ali', '2026-01-02 10:30:00', NULL, 1, 'PC', 'HP Laptop', 'Firefox', 'Windows 11', '192.168.1.101', 'DEV-PC-002', '00:11:22:33:44:56', 'Pakistan', 'Karachi', 'Asia/Karachi', 'Mozilla/5.0 Firefox/121.0', '2026-01-02 11:00:00', '2026-01-02 10:30:00', '2026-01-02 11:00:00'),
(3, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImlhdCI6MTczNTgyNDAzMH0.ghi789', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-02 08:30:00', NULL, 1, 'PC', 'MacBook Pro', 'Safari', 'macOS', '192.168.1.102', 'HR-MAC-001', '00:11:22:33:44:57', 'Pakistan', 'Karachi', 'Asia/Karachi', 'Mozilla/5.0 Safari/605.1', '2026-01-02 09:00:00', '2026-01-02 08:30:00', '2026-01-02 09:00:00'),
(4, 4, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjQsImlhdCI6MTczNTgzNDA0MH0.jkl012', 'hassan.raza@digious.com', 'Hassan Raza', '2026-01-02 11:00:00', NULL, 1, 'Mobile', 'iPhone 14', 'Safari Mobile', 'iOS 17', '192.168.1.103', 'Hassans-iPhone', '00:11:22:33:44:58', 'Pakistan', 'Karachi', 'Asia/Karachi', 'Mozilla/5.0 iPhone OS 17_0', '2026-01-02 11:30:00', '2026-01-02 11:00:00', '2026-01-02 11:30:00'),
(5, 5, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjUsImlhdCI6MTczNTgyODIwMH0.mno345', 'sara.ahmed@digious.com', 'Sara Ahmed', '2026-01-02 09:30:00', NULL, 1, 'PC', 'Lenovo ThinkPad', 'Edge', 'Windows 10', '192.168.1.104', 'FIN-PC-001', '00:11:22:33:44:59', 'Pakistan', 'Karachi', 'Asia/Karachi', 'Mozilla/5.0 Edge/120.0', '2026-01-02 10:00:00', '2026-01-02 09:30:00', '2026-01-02 10:00:00');

-- --------------------------------------------------------

--
-- Structure for view `active_users_view`
--
DROP TABLE IF EXISTS `active_users_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`u115615899_plustaff`u115615899_plustaff`%` SQL SECURITY DEFINER VIEW `active_users_view`  AS SELECT `usi`.`id` AS `id`, `usi`.`employee_id` AS `employee_id`, `usi`.`email` AS `email`, `usi`.`name` AS `name`, `usi`.`login_time` AS `login_time`, `usi`.`device_type` AS `device_type`, `usi`.`device_name` AS `device_name`, `usi`.`ip_address` AS `ip_address`, `usi`.`hostname` AS `hostname`, `usi`.`mac_address` AS `mac_address`, `usi`.`browser` AS `browser`, `usi`.`os` AS `os`, `usi`.`country` AS `country`, `usi`.`city` AS `city`, `usi`.`last_activity_time` AS `last_activity_time`, timestampdiff(MINUTE,`usi`.`login_time`,current_timestamp()) AS `logged_in_minutes`, `usi`.`is_active` AS `is_active` FROM `user_system_info` AS `usi` WHERE `usi`.`is_active` = 1 ORDER BY `usi`.`login_time` DESC ;

-- --------------------------------------------------------

--
-- Structure for view `Attendance_Summary_View`
--
DROP TABLE IF EXISTS `Attendance_Summary_View`;

CREATE ALGORITHM=UNDEFINED DEFINER=`u115615899_plustaff`u115615899_plustaff`%` SQL SECURITY DEFINER VIEW `Attendance_Summary_View`  AS SELECT `ea`.`employee_id` AS `employee_id`, `ea`.`name` AS `name`, `ea`.`email` AS `email`, `ea`.`attendance_date` AS `attendance_date`, `ea`.`check_in_time` AS `check_in_time`, `ea`.`check_out_time` AS `check_out_time`, `ea`.`status` AS `status`, `ea`.`total_breaks_taken` AS `total_breaks_taken`, `ea`.`total_break_duration_minutes` AS `total_break_duration_minutes`, concat(floor(`ea`.`gross_working_time_minutes` / 60),'h ',`ea`.`gross_working_time_minutes` MOD 60,'m') AS `gross_working_time`, concat(floor(`ea`.`net_working_time_minutes` / 60),'h ',`ea`.`net_working_time_minutes` MOD 60,'m') AS `net_working_time`, `ea`.`overtime_hours` AS `overtime_hours`, `ea`.`on_time` AS `on_time`, `ea`.`late_by_minutes` AS `late_by_minutes`, `ea`.`created_at` AS `created_at`, `ea`.`updated_at` AS `updated_at` FROM `Employee_Attendance` AS `ea` ORDER BY `ea`.`attendance_date` DESC, `ea`.`employee_id` ASC ;

-- --------------------------------------------------------

--
-- Structure for view `Monthly_Attendance_Summary`
--
DROP TABLE IF EXISTS `Monthly_Attendance_Summary`;

CREATE ALGORITHM=UNDEFINED DEFINER=`u115615899_plustaff`u115615899_plustaff`%` SQL SECURITY DEFINER VIEW `Monthly_Attendance_Summary`  AS SELECT `Employee_Attendance`.`employee_id` AS `employee_id`, `Employee_Attendance`.`name` AS `name`, `Employee_Attendance`.`email` AS `email`, year(`Employee_Attendance`.`attendance_date`) AS `year`, month(`Employee_Attendance`.`attendance_date`) AS `month`, count(0) AS `total_days`, sum(case when `Employee_Attendance`.`status` = 'Present' then 1 else 0 end) AS `present_days`, sum(case when `Employee_Attendance`.`status` = 'Absent' then 1 else 0 end) AS `absent_days`, sum(case when `Employee_Attendance`.`status` = 'Late' then 1 else 0 end) AS `late_days`, sum(case when `Employee_Attendance`.`status` = 'On Leave' then 1 else 0 end) AS `leave_days`, round(sum(case when `Employee_Attendance`.`status` = 'Present' then 1 else 0 end) * 100 / count(0),2) AS `attendance_rate`, round(sum(case when `Employee_Attendance`.`on_time` = 1 then 1 else 0 end) * 100 / count(0),2) AS `on_time_rate`, sum(`Employee_Attendance`.`net_working_time_minutes`) AS `total_working_minutes`, sum(`Employee_Attendance`.`overtime_minutes`) AS `total_overtime_minutes`, sum(`Employee_Attendance`.`total_break_duration_minutes`) AS `total_break_minutes` FROM `Employee_Attendance` GROUP BY `Employee_Attendance`.`employee_id`, `Employee_Attendance`.`name`, `Employee_Attendance`.`email`, year(`Employee_Attendance`.`attendance_date`), month(`Employee_Attendance`.`attendance_date`) ;

-- --------------------------------------------------------

--
-- Structure for view `Overtime_Report_View`
--
DROP TABLE IF EXISTS `Overtime_Report_View`;

CREATE ALGORITHM=UNDEFINED DEFINER=`u115615899_plustaff`u115615899_plustaff`%` SQL SECURITY DEFINER VIEW `Overtime_Report_View`  AS SELECT `ea`.`employee_id` AS `employee_id`, `ea`.`name` AS `name`, `ea`.`email` AS `email`, `ea`.`attendance_date` AS `attendance_date`, `ea`.`check_in_time` AS `check_in_time`, `ea`.`check_out_time` AS `check_out_time`, `ea`.`net_working_time_minutes` AS `net_working_time_minutes`, `ea`.`expected_working_time_minutes` AS `expected_working_time_minutes`, `ea`.`overtime_minutes` AS `overtime_minutes`, `ea`.`overtime_hours` AS `overtime_hours`, CASE WHEN `ea`.`overtime_hours` > 0 THEN round(`ea`.`overtime_hours` * 1.5,2) ELSE 0 END AS `overtime_pay_multiplier` FROM `Employee_Attendance` AS `ea` WHERE `ea`.`overtime_minutes` > 0 ORDER BY `ea`.`attendance_date` DESC, `ea`.`overtime_hours` DESC ;

-- --------------------------------------------------------

--
-- Structure for view `user_session_summary`
--
DROP TABLE IF EXISTS `user_session_summary`;

CREATE ALGORITHM=UNDEFINED DEFINER=`u115615899_plustaff`u115615899_plustaff`%` SQL SECURITY DEFINER VIEW `user_session_summary`  AS SELECT `eo`.`id` AS `id`, `eo`.`employee_id` AS `employee_id`, `eo`.`name` AS `name`, `eo`.`email` AS `email`, `eo`.`department` AS `department`, count(case when `usi`.`is_active` = 1 then 1 end) AS `total_active_sessions`, count(case when `usi`.`device_type` = 'PC' and `usi`.`is_active` = 1 then 1 end) AS `pc_sessions`, count(case when `usi`.`device_type` = 'Mobile' and `usi`.`is_active` = 1 then 1 end) AS `mobile_sessions`, count(case when `usi`.`device_type` = 'Tablet' and `usi`.`is_active` = 1 then 1 end) AS `tablet_sessions`, max(`usi`.`login_time`) AS `last_login_time`, group_concat(distinct `usi`.`ip_address` separator ',') AS `all_ip_addresses`, group_concat(distinct `usi`.`device_type` separator ',') AS `all_device_types` FROM (`employee_onboarding` `eo` left join `user_system_info` `usi` on(`eo`.`id` = `usi`.`employee_id`)) GROUP BY `eo`.`id`, `eo`.`employee_id`, `eo`.`name`, `eo`.`email`, `eo`.`department` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin_users`
--
ALTER TABLE `admin_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `idx_role` (`role`);

--
-- Indexes for table `Company_Rules`
--
ALTER TABLE `Company_Rules`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `rule_name` (`rule_name`),
  ADD KEY `idx_rule_type` (`rule_type`),
  ADD KEY `idx_is_active` (`is_active`),
  ADD KEY `idx_priority` (`priority`);

--
-- Indexes for table `Employee_Activities`
--
ALTER TABLE `Employee_Activities`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_employee_id` (`employee_id`),
  ADD KEY `idx_activity_type` (`activity_type`),
  ADD KEY `idx_timestamp` (`timestamp`);

--
-- Indexes for table `employee_allowances`
--
ALTER TABLE `employee_allowances`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_employee_id` (`employee_id`),
  ADD KEY `idx_allowance_name` (`allowance_name`);

--
-- Indexes for table `Employee_Attendance`
--
ALTER TABLE `Employee_Attendance`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_employee_date` (`employee_id`,`attendance_date`),
  ADD KEY `idx_employee_id` (`employee_id`),
  ADD KEY `idx_attendance_date` (`attendance_date`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `Employee_Breaks`
--
ALTER TABLE `Employee_Breaks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `employee_id` (`employee_id`),
  ADD KEY `idx_attendance_id` (`attendance_id`),
  ADD KEY `idx_break_type` (`break_type`);

--
-- Indexes for table `employee_dynamic_resources`
--
ALTER TABLE `employee_dynamic_resources`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_employee_id` (`employee_id`),
  ADD KEY `idx_resource_name` (`resource_name`);

--
-- Indexes for table `employee_onboarding`
--
ALTER TABLE `employee_onboarding`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `employee_id` (`employee_id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `cnic` (`cnic`),
  ADD KEY `idx_employee_id` (`employee_id`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `idx_department` (`department`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_join_date` (`join_date`);

--
-- Indexes for table `employee_resources`
--
ALTER TABLE `employee_resources`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_employee_id` (`employee_id`),
  ADD KEY `idx_allocated_date` (`allocated_date`);

--
-- Indexes for table `employee_salary`
--
ALTER TABLE `employee_salary`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_employee_id` (`employee_id`);

--
-- Indexes for table `onboarding_progress`
--
ALTER TABLE `onboarding_progress`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `employee_id` (`employee_id`),
  ADD KEY `idx_employee_id` (`employee_id`),
  ADD KEY `idx_is_completed` (`is_completed`);

--
-- Indexes for table `user_as_employees`
--
ALTER TABLE `user_as_employees`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_employee_id` (`employee_id`),
  ADD KEY `idx_session_token` (`current_session_token`),
  ADD KEY `idx_last_login` (`last_login_time`);

--
-- Indexes for table `user_concurrent_sessions`
--
ALTER TABLE `user_concurrent_sessions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_employee_id` (`employee_id`),
  ADD KEY `idx_email` (`email`);

--
-- Indexes for table `user_system_info`
--
ALTER TABLE `user_system_info`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `session_token` (`session_token`),
  ADD UNIQUE KEY `uk_session_token` (`session_token`),
  ADD KEY `idx_employee_id` (`employee_id`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `idx_is_active` (`is_active`),
  ADD KEY `idx_login_time` (`login_time`),
  ADD KEY `idx_device_type` (`device_type`),
  ADD KEY `idx_ip_address` (`ip_address`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin_users`
--
ALTER TABLE `admin_users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `Company_Rules`
--
ALTER TABLE `Company_Rules`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `Employee_Activities`
--
ALTER TABLE `Employee_Activities`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `employee_allowances`
--
ALTER TABLE `employee_allowances`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `Employee_Attendance`
--
ALTER TABLE `Employee_Attendance`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `Employee_Breaks`
--
ALTER TABLE `Employee_Breaks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `employee_dynamic_resources`
--
ALTER TABLE `employee_dynamic_resources`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `employee_onboarding`
--
ALTER TABLE `employee_onboarding`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `employee_resources`
--
ALTER TABLE `employee_resources`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `employee_salary`
--
ALTER TABLE `employee_salary`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `onboarding_progress`
--
ALTER TABLE `onboarding_progress`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `user_as_employees`
--
ALTER TABLE `user_as_employees`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `user_concurrent_sessions`
--
ALTER TABLE `user_concurrent_sessions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `user_system_info`
--
ALTER TABLE `user_system_info`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=49;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `Employee_Activities`
--
ALTER TABLE `Employee_Activities`
  ADD CONSTRAINT `Employee_Activities_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employee_onboarding` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `employee_allowances`
--
ALTER TABLE `employee_allowances`
  ADD CONSTRAINT `employee_allowances_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employee_onboarding` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `Employee_Attendance`
--
ALTER TABLE `Employee_Attendance`
  ADD CONSTRAINT `Employee_Attendance_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employee_onboarding` (`id`);

--
-- Constraints for table `Employee_Breaks`
--
ALTER TABLE `Employee_Breaks`
  ADD CONSTRAINT `Employee_Breaks_ibfk_1` FOREIGN KEY (`attendance_id`) REFERENCES `Employee_Attendance` (`id`),
  ADD CONSTRAINT `Employee_Breaks_ibfk_2` FOREIGN KEY (`employee_id`) REFERENCES `employee_onboarding` (`id`);

--
-- Constraints for table `employee_dynamic_resources`
--
ALTER TABLE `employee_dynamic_resources`
  ADD CONSTRAINT `employee_dynamic_resources_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employee_onboarding` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `employee_resources`
--
ALTER TABLE `employee_resources`
  ADD CONSTRAINT `employee_resources_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employee_onboarding` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `employee_salary`
--
ALTER TABLE `employee_salary`
  ADD CONSTRAINT `employee_salary_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employee_onboarding` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `onboarding_progress`
--
ALTER TABLE `onboarding_progress`
  ADD CONSTRAINT `onboarding_progress_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employee_onboarding` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_as_employees`
--
ALTER TABLE `user_as_employees`
  ADD CONSTRAINT `user_as_employees_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employee_onboarding` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_concurrent_sessions`
--
ALTER TABLE `user_concurrent_sessions`
  ADD CONSTRAINT `user_concurrent_sessions_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employee_onboarding` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_system_info`
--
ALTER TABLE `user_system_info`
  ADD CONSTRAINT `user_system_info_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employee_onboarding` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;