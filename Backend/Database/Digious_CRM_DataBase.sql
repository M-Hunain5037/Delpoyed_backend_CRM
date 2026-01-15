-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Jan 15, 2026 at 01:53 PM
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
(4, 3, 'Housing Allowance', 8000.00, '2025-10-20 08:00:00'),
(5, 4, 'Sales Incentive', 3000.00, '2025-11-01 11:00:00'),
(6, 5, 'Professional Allowance', 2500.00, '2025-12-01 10:30:00'),
(7, 12, 'House Rent', 10000.00, '2026-01-02 19:14:56'),
(8, 13, 'HA', 1000.00, '2026-01-02 19:54:33'),
(9, 15, 'Transpotation Allowance', 20000.00, '2026-01-04 19:22:59'),
(11, 16, 'HA', 600.00, '2026-01-12 21:32:11'),
(13, 2, 'Transport Allowance', 1510.00, '2026-01-13 13:33:42');

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
(1, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-11-01', '21:00:00', '06:00:00', 'Present', 4, 2, 1, 1, 0, 10, 60, 10, 0, 80, 540, 460, 540, 0, 0.00, 1, 0, 'First day on job', 'Mozilla/5.0 Chrome', '192.168.1.100', '2025-11-01 21:00:00', '2025-11-01 21:00:00'),
(2, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-11-02', '21:15:00', '06:30:00', 'Present', 3, 1, 1, 1, 0, 5, 45, 8, 0, 58, 555, 497, 540, 0, 0.00, 1, 0, 'Traffic jam', 'Mozilla/5.0 Chrome', '192.168.1.100', '2025-11-02 21:15:00', '2026-01-03 09:21:05'),
(3, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-11-03', '20:45:00', '06:45:00', 'Present', 5, 3, 1, 1, 0, 15, 60, 5, 0, 80, 600, 520, 540, 60, 1.00, 1, 0, 'Overtime for project deadline', 'Mozilla/5.0 Chrome', '192.168.1.100', '2025-11-03 20:45:00', '2025-11-03 20:45:00'),
(4, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-11-04', '21:05:00', '06:05:00', 'Present', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 540, 540, 0, 0.00, 1, 0, NULL, 'Mozilla/5.0 Chrome', '192.168.1.100', '2025-11-04 21:05:00', '2026-01-03 09:32:55'),
(5, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-11-05', '21:00:00', '07:15:00', 'Present', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 615, 615, 540, 75, 1.25, 1, 0, 'Extra work on features', 'Mozilla/5.0 Chrome', '192.168.1.100', '2025-11-05 21:00:00', '2026-01-02 16:04:05'),
(6, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-11-15', '21:00:00', '06:00:00', 'Present', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 540, 540, 0, 0.00, 1, 0, 'First day', 'Mozilla/5.0 Firefox', '192.168.1.101', '2025-11-15 21:00:00', '2026-01-02 16:04:05'),
(7, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-11-16', '21:30:00', '06:30:00', 'Late', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 540, 540, 0, 0.00, 0, 30, 'Overslept', 'Mozilla/5.0 Firefox', '192.168.1.101', '2025-11-16 21:30:00', '2026-01-02 16:04:05'),
(8, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-11-17', '21:00:00', '06:00:00', 'Present', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 540, 540, 0, 0.00, 1, 0, NULL, 'Mozilla/5.0 Firefox', '192.168.1.101', '2025-11-17 21:00:00', '2026-01-02 16:04:05'),
(9, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-12-01', '20:50:00', '06:50:00', 'Present', 4, 2, 1, 1, 0, 10, 55, 10, 0, 75, 600, 525, 540, 60, 1.00, 1, 0, 'Working on year-end project', 'Mozilla/5.0 Chrome', '192.168.1.100', '2025-12-01 20:50:00', '2025-12-01 20:50:00'),
(10, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-12-01', '21:20:00', '06:00:00', 'Late', 3, 1, 1, 1, 0, 5, 45, 7, 0, 57, 520, 463, 540, 0, 0.00, 0, 20, 'Car trouble', 'Mozilla/5.0 Firefox', '192.168.1.101', '2025-12-01 21:20:00', '2025-12-01 21:20:00'),
(11, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-12-01', '21:00:00', '06:00:00', 'Present', 2, 0, 1, 1, 0, 0, 45, 8, 0, 53, 540, 487, 540, 0, 0.00, 1, 0, NULL, 'Mozilla/5.0 Safari', '192.168.1.102', '2025-12-01 21:00:00', '2025-12-01 21:00:00'),
(12, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-12-01', '21:00:00', '07:30:00', 'Present', 3, 1, 1, 1, 0, 5, 60, 10, 0, 75, 630, 555, 540, 90, 1.50, 1, 0, 'Working late on sales reports', 'Mozilla/5.0 Edge', '192.168.1.103', '2025-12-01 21:00:00', '2025-12-01 21:00:00'),
(13, 5, 'sara.ahmed@digious.com', 'Sara Ahmed', '2025-12-01', '21:00:00', '06:00:00', 'Present', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 540, 540, 0, 0.00, 1, 0, 'First day', 'Mozilla/5.0 Chrome', '192.168.1.104', '2025-12-01 21:00:00', '2026-01-02 16:04:05'),
(14, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-12-02', '21:10:00', '06:10:00', 'Present', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 540, 540, 0, 0.00, 1, 0, NULL, 'Mozilla/5.0 Chrome', '192.168.1.100', '2025-12-02 21:10:00', '2026-01-03 09:32:10'),
(15, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-12-02', '21:45:00', '06:45:00', 'Late', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 540, 540, 0, 0.00, 0, 45, 'Family emergency', 'Mozilla/5.0 Firefox', '192.168.1.101', '2025-12-02 21:45:00', '2026-01-02 16:04:05'),
(16, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-12-15', '21:00:00', '08:00:00', 'Present', 4, 1, 1, 2, 0, 5, 60, 15, 0, 80, 660, 580, 540, 120, 2.00, 1, 0, 'HR policy review meeting ran late', 'Mozilla/5.0 Safari', '192.168.1.102', '2025-12-15 21:00:00', '2025-12-15 21:00:00'),
(17, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-12-15', '22:00:00', '06:00:00', 'Late', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 480, 480, 540, 0, 0.00, 0, 60, 'Client meeting ran over', 'Mozilla/5.0 Edge', '192.168.1.103', '2025-12-15 22:00:00', '2026-01-02 16:04:05'),
(18, 5, 'sara.ahmed@digious.com', 'Sara Ahmed', '2025-12-15', '21:00:00', '06:00:00', 'Present', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 540, 540, 0, 0.00, 1, 0, NULL, 'Mozilla/5.0 Chrome', '192.168.1.104', '2025-12-15 21:00:00', '2026-01-02 16:04:05'),
(19, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-12-30', '21:00:00', '08:30:00', 'Present', 5, 3, 1, 1, 0, 20, 60, 10, 0, 90, 690, 600, 540, 150, 2.50, 1, 0, 'Year-end deployment', 'Mozilla/5.0 Chrome', '192.168.1.100', '2025-12-30 21:00:00', '2026-01-04 16:10:50'),
(20, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-12-30', '22:30:00', '06:30:00', 'Late', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 480, 480, 540, 0, 0.00, 0, 90, 'New Year party hangover', 'Mozilla/5.0 Firefox', '192.168.1.101', '2025-12-30 22:30:00', '2026-01-02 16:04:05'),
(21, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-01', '21:00:00', '06:00:00', 'Present', 3, 1, 1, 1, 0, 5, 45, 8, 0, 58, 540, 482, 540, 0, 0.00, 1, 0, 'New Year - normal shift', 'Mozilla/5.0 Chrome', '192.168.1.100', '2026-01-01 21:00:00', '2026-01-01 21:00:00'),
(22, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-02', '21:00:00', '06:00:00', 'Present', 2, 0, 1, 1, 0, 0, 50, 7, 0, 57, 540, 483, 540, 0, 0.00, 1, 0, 'Back from holidays', 'Mozilla/5.0 Safari', '192.168.1.102', '2026-01-02 21:00:00', '2026-01-02 21:00:00'),
(23, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02', '21:00:00', '16:25:03', 'Present', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1165, 1165, 540, 625, 10.42, 1, 0, NULL, NULL, '127.0.0.1', '2026-01-02 09:26:31', '2026-01-02 11:25:03'),
(32, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2026-01-01', '00:10:20', '06:00:00', 'Late', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 350, 350, 540, 0, 0.00, 0, 115, NULL, 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '127.0.0.1', '2026-01-02 19:10:20', '2026-01-03 11:38:10'),
(34, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-11-06', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(35, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-11-07', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(36, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-11-10', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(37, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-11-11', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(38, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-11-12', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(39, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-11-13', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(40, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-11-14', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(41, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-11-17', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(42, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-11-18', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(43, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-11-19', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(44, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-11-20', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(45, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-11-21', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(46, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-11-24', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(47, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-11-25', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(48, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-11-26', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(49, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-11-27', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(50, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-11-28', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(51, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-12-03', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(52, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-12-04', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(53, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-12-05', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(54, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-12-08', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(55, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-12-09', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(56, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-12-10', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(57, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-12-11', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(58, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-12-12', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(59, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-12-15', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(60, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-12-16', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(61, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-12-17', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(62, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-12-18', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(63, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-12-19', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(64, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-12-22', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(65, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-12-23', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(66, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-12-24', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(67, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-12-25', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(68, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2025-12-26', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(69, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-11-18', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(70, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-11-19', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(71, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-11-20', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(72, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-11-21', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(73, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-11-24', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(74, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-11-25', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(75, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-11-26', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(76, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-11-27', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(77, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-11-28', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(78, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-12-03', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(79, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-12-04', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(80, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-12-05', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(81, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-12-08', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(82, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-12-09', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(83, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-12-10', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(84, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-12-11', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(85, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-12-12', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(86, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-12-15', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(87, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-12-16', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(88, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-12-17', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(89, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-12-18', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(90, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-12-19', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(91, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-12-22', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(92, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-12-23', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(93, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-12-24', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:17', '2026-01-02 19:26:17'),
(94, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-12-25', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(95, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-12-26', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(96, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2025-12-31', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(97, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2026-01-01', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(98, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2026-01-02', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(99, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-10-20', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(100, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-10-21', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(101, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-10-22', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(102, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-10-23', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(103, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-10-24', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(104, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-10-27', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(105, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-10-28', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(106, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-10-29', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(107, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-10-30', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(108, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-10-31', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(109, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-11-03', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(110, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-11-04', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(111, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-11-05', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(112, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-11-06', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(113, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-11-07', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(114, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-11-10', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(115, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-11-11', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(116, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-11-12', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(117, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-11-13', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(118, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-11-14', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(119, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-11-17', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(120, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-11-18', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(121, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-11-19', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(122, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-11-20', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(123, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-11-21', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(124, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-11-24', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(125, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-11-25', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(126, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-11-26', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(127, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-11-27', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(128, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-11-28', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(129, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-12-02', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(130, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-12-03', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(131, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-12-04', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(132, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-12-05', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(133, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-12-08', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(134, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-12-09', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(135, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-12-10', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(136, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-12-11', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(137, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-12-12', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(138, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-12-16', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(139, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-12-17', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(140, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-12-18', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(141, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-12-19', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(142, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-12-22', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(143, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-12-23', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(144, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-12-24', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(145, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-12-25', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(146, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-12-26', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(147, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-12-29', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(148, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-12-30', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(149, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2025-12-31', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(150, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-11-03', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(151, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-11-04', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(152, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-11-05', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(153, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-11-06', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(154, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-11-07', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(155, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-11-10', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(156, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-11-11', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(157, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-11-12', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(158, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-11-13', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(159, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-11-14', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(160, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-11-17', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(161, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-11-18', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(162, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-11-19', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(163, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-11-20', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(164, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-11-21', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(165, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-11-24', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(166, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-11-25', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(167, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-11-26', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(168, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-11-27', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(169, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-11-28', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(170, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-12-02', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(171, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-12-03', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(172, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-12-04', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(173, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-12-05', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(174, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-12-08', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(175, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-12-09', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(176, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-12-10', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(177, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-12-11', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(178, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-12-12', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(179, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-12-16', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(180, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-12-17', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(181, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-12-18', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(182, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-12-19', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(183, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-12-22', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(184, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-12-23', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(185, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-12-24', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(186, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-12-25', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(187, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-12-26', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(188, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-12-29', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(189, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2025-12-30', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(190, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2026-01-02', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(191, 5, 'sara.ahmed@digious.com', 'Sara Ahmed', '2025-12-02', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(192, 5, 'sara.ahmed@digious.com', 'Sara Ahmed', '2025-12-03', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(193, 5, 'sara.ahmed@digious.com', 'Sara Ahmed', '2025-12-04', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(194, 5, 'sara.ahmed@digious.com', 'Sara Ahmed', '2025-12-05', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(195, 5, 'sara.ahmed@digious.com', 'Sara Ahmed', '2025-12-08', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(196, 5, 'sara.ahmed@digious.com', 'Sara Ahmed', '2025-12-09', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(197, 5, 'sara.ahmed@digious.com', 'Sara Ahmed', '2025-12-10', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(198, 5, 'sara.ahmed@digious.com', 'Sara Ahmed', '2025-12-11', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(199, 5, 'sara.ahmed@digious.com', 'Sara Ahmed', '2025-12-12', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(200, 5, 'sara.ahmed@digious.com', 'Sara Ahmed', '2025-12-16', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(201, 5, 'sara.ahmed@digious.com', 'Sara Ahmed', '2025-12-17', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(202, 5, 'sara.ahmed@digious.com', 'Sara Ahmed', '2025-12-18', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(203, 5, 'sara.ahmed@digious.com', 'Sara Ahmed', '2025-12-19', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(204, 5, 'sara.ahmed@digious.com', 'Sara Ahmed', '2025-12-22', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(205, 5, 'sara.ahmed@digious.com', 'Sara Ahmed', '2025-12-23', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(206, 5, 'sara.ahmed@digious.com', 'Sara Ahmed', '2025-12-24', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(207, 5, 'sara.ahmed@digious.com', 'Sara Ahmed', '2025-12-25', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(208, 5, 'sara.ahmed@digious.com', 'Sara Ahmed', '2025-12-26', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(209, 5, 'sara.ahmed@digious.com', 'Sara Ahmed', '2025-12-29', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(210, 5, 'sara.ahmed@digious.com', 'Sara Ahmed', '2025-12-30', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(211, 5, 'sara.ahmed@digious.com', 'Sara Ahmed', '2025-12-31', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(212, 5, 'sara.ahmed@digious.com', 'Sara Ahmed', '2026-01-01', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(213, 5, 'sara.ahmed@digious.com', 'Sara Ahmed', '2026-01-02', NULL, NULL, 'Absent', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 0, NULL, NULL, NULL, '2026-01-02 19:26:18', '2026-01-02 19:26:18'),
(214, 12, 'raffay.ahmed@digious.com', 'Raffay Ahmed', '2026-01-02', '00:16:00', '03:24:24', 'Late', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 188, 188, 540, 0, 0.00, 0, 121, NULL, NULL, NULL, '2026-01-02 19:35:04', '2026-01-03 09:17:34'),
(215, 13, 'test1@digious.com', 'test1', '2026-01-01', '00:55:08', '06:00:00', 'Late', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 305, 305, 540, 0, 0.00, 0, 160, NULL, 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '127.0.0.1', '2026-01-02 19:55:08', '2026-01-03 11:40:06'),
(216, 14, 'ron@digious.com', 'Ron', '2026-01-02', '01:08:43', '02:35:17', 'Late', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 87, 87, 540, 0, 0.00, 0, 173, NULL, 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '127.0.0.1', '2026-01-02 20:08:43', '2026-01-02 22:23:22'),
(217, 14, 'ron@digious.com', 'Ron', '2026-01-01', '02:07:51', '06:00:00', 'Late', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 232, 232, 540, 0, 0.00, 0, 232, NULL, NULL, '1', '2026-01-02 21:07:51', '2026-01-03 11:59:02'),
(218, 12, 'raffay.ahmed@digious.com', 'Raffay Ahmed', '2026-01-01', '03:24:20', '03:24:34', 'Late', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 309, NULL, NULL, '1', '2026-01-02 22:24:20', '2026-01-02 22:24:34'),
(219, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-03', '22:07:50', '06:00:00', 'Late', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 473, 473, 540, 0, 0.00, 0, 52, NULL, NULL, '1', '2026-01-03 09:07:50', '2026-01-03 09:23:33'),
(220, 4, 'hassan.raza@digious.com', 'Hassan Raza', '2026-01-03', '16:21:59', '16:22:12', 'Present', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 540, 0, 0.00, 1, 0, NULL, NULL, '127.0.0.1', '2026-01-03 11:21:59', '2026-01-03 11:22:12'),
(231, 12, 'raffay.ahmed@digious.com', 'Raffay Ahmed', '2026-01-03', '21:55:46', '03:15:01', 'Late', 1, 1, 0, 0, 0, 15, 0, 0, 0, 15, 320, 305, 540, 0, 0.00, 0, 40, NULL, NULL, '1', '2026-01-03 16:55:46', '2026-01-03 22:15:01'),
(232, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2026-01-03', '22:28:48', '03:15:39', 'Late', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 287, 287, 540, 0, 0.00, 0, 73, NULL, NULL, '1', '2026-01-03 17:28:48', '2026-01-03 22:15:39'),
(240, 14, 'ron@digious.com', 'Ron', '2026-01-03', '22:40:08', '03:14:19', 'Late', 1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 274, 273, 540, 0, 0.00, 0, 357, NULL, NULL, '1', '2026-01-03 22:12:08', '2026-01-03 22:14:19'),
(241, 15, 'khalid.iqbal@digious.com', 'Khalid Iqbal', '2026-01-05', '13:51:34', NULL, 'Present', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 73, 73, 540, 0, 0.00, 1, 0, NULL, 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0', '127.0.0.1', '2026-01-05 08:51:34', '2026-01-05 10:05:04'),
(242, 2, 'ahmed.ali@digious.com', 'Ahmed Ali', '2026-01-05', '19:42:07', NULL, 'Present', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 1, 0, NULL, NULL, '1', '2026-01-05 14:42:07', '2026-01-05 14:42:07'),
(243, 16, 'muneeb.baig@digious.com', 'Muneeb Baig', '2026-01-05', '21:37:31', NULL, 'Late', 1, 1, 0, 0, 0, 6, 0, 0, 0, 6, 1, 1, 540, 0, 0.00, 0, 22, NULL, 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '127.0.0.1', '2026-01-05 16:37:31', '2026-01-05 16:45:12'),
(244, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-06', '23:26:19', '23:36:19', 'Late', 1, 1, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 540, 0, 0.00, 0, 131, NULL, NULL, '1', '2026-01-06 18:26:19', '2026-01-08 18:29:45'),
(245, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-07', '21:56:24', '23:26:19', 'Late', 2, 1, 0, 0, 1, 0, 0, 0, 2, 2, 0, 0, 540, 0, 0.00, 0, 41, NULL, NULL, '1', '2026-01-07 16:56:24', '2026-01-08 18:29:45'),
(249, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-08', '23:36:23', NULL, 'Late', 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 141, NULL, 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '127.0.0.1', '2026-01-08 18:36:23', '2026-01-08 18:45:57'),
(250, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-09', '16:17:10', NULL, 'Late', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 0, 2, NULL, NULL, '1', '2026-01-09 16:17:10', '2026-01-09 16:17:10'),
(251, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-12', '11:43:27', '00:26:34', 'Present', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 1, 0, NULL, 'PC', NULL, '2026-01-12 11:43:27', '2026-01-12 19:26:34'),
(252, 1, 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-13', '17:21:24', NULL, 'Present', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 540, 0, 0.00, 1, 0, NULL, 'PC', NULL, '2026-01-13 12:21:24', '2026-01-13 12:21:24'),
(254, 3, 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-13', '21:34:18', '01:28:05', 'Late', 2, 2, 0, 0, 0, 13694112, 0, 0, 0, 13694112, 234, 0, 540, 0, 0.00, 0, 19, NULL, 'Web Browser', NULL, '2026-01-13 16:34:18', '2026-01-13 20:28:05');

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
(33, 21, 1, 'Smoke', '23:30:00', '23:35:00', 5, 'New Year smoke', '2026-01-01 23:30:00', '2026-01-01 23:30:00'),
(34, 21, 1, 'Dinner', '02:00:00', '02:45:00', 45, 'New Year dinner', '2026-01-02 02:00:00', '2026-01-02 02:00:00'),
(35, 21, 1, 'Washroom', '04:30:00', '04:38:00', 8, 'Quick break', '2026-01-02 04:30:00', '2026-01-02 04:30:00'),
(36, 22, 3, 'Dinner', '01:15:00', '02:05:00', 50, 'Back from holidays dinner', '2026-01-03 01:15:00', '2026-01-03 01:15:00'),
(37, 22, 3, 'Washroom', '04:00:00', '04:07:00', 7, 'Quick break', '2026-01-03 04:00:00', '2026-01-03 04:00:00'),
(40, 231, 12, 'Smoke', '21:56:01', '22:11:20', 15, 'Smoke Break break - Auto-saved on start', '2026-01-03 16:56:01', '2026-01-03 17:11:20'),
(46, 240, 14, 'Dinner', '03:12:57', '03:13:57', 1, 'Dinner Break break - Auto-saved on start', '2026-01-03 22:12:57', '2026-01-03 22:13:57'),
(47, 243, 16, 'Smoke', '21:39:06', '21:45:12', 6, 'Smoke Break break - Auto-saved on start', '2026-01-05 16:39:06', '2026-01-05 16:45:12'),
(48, 244, 1, 'Smoke', '23:26:40', '23:30:48', 4, 'Smoke Break break - Auto-saved on start', '2026-01-06 18:26:40', '2026-01-06 18:30:48'),
(49, 245, 1, 'Smoke', '22:43:19', '22:43:51', 0, 'Smoke Break break - Auto-saved on start', '2026-01-07 17:43:19', '2026-01-07 17:43:51'),
(50, 245, 1, 'Prayer', '22:44:40', '22:46:59', 2, 'Prayer Break break - Auto-saved on start', '2026-01-07 17:44:40', '2026-01-07 17:46:59'),
(51, 249, 1, 'Smoke', '23:45:08', '23:45:57', 0, 'Smoke Break break - Auto-saved on start', '2026-01-08 18:45:08', '2026-01-08 18:45:57'),
(52, 254, 3, 'Smoke', '23:52:07', '00:03:59', 13694111, 'Smoke break', '2026-01-13 18:52:07', '2026-01-13 19:03:59'),
(53, 254, 3, 'Smoke', '00:22:58', '00:24:22', 1, 'Smoke break', '2026-01-13 19:22:58', '2026-01-13 19:24:22');

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
(5, 'DIG-005', 'Sara Ahmed', 'sara.ahmed@digious.com', '$2a$12$Tdc/e2C9kf.GOIVDwS0HQ.GIqPNlmfjL.R5wImzRWSHniZO1eKDUa', '03008888888', 'Finance', 'Finance Officer', '2025-12-01', 'Saddar, Karachi', '03009999999', 1, 'PKRIBAN901234', 'TIN456789', '4210552759045', 'Finance Officer', 'Active', '2025-12-01 10:30:00', '2025-12-29 15:18:20'),
(12, 'DIG-010', 'Raffay Ahmed', 'raffay.ahmed@digious.com', '$2a$10$eWvhWkhKGqnlO3QA..cWdOHIXyu/LjzpvhCwWYsq4qSOURZSPMIqi', '0986789010', 'Production', 'Software Developer', '2026-01-03', 'hunain', '0312398003', 1, 'pkriban1234589', 'SSN1234', '42101-5103653-51', 'Mid Level', 'Active', '2026-01-02 19:14:56', '2026-01-02 19:14:56'),
(13, 'DIG-100', 'test1', 'test1@digious.com', '$2a$10$zf5ChX237SfY4A2rTMmTA.D.x3r8VREGqe.vvi642.ax5k3Isqcfy', '42101510365356', 'Production', 'MD1', '2026-01-03', 'qwerty123', '031239800311', 1, 'pkriban1234590', 'SSN12367', '42101-5103653-512', 'SMD', 'Inactive', '2026-01-02 19:54:33', '2026-01-12 12:31:48'),
(14, 'DIG-101', 'Ron', 'ron@digious.com', '$2a$10$cVjt3I.H.AhYMlt264Dvjem4pxnAepwrD0U4F/LfRRb5PfqbNfpn6', '421015103653511', 'Production', 'MDq', '2026-01-02', 'qwerty', '031239800311', 1, 'pkriban123459012', 'SSN12311', '42101-5103653-5111', 'MD2', 'Active', '2026-01-02 20:07:51', '2026-01-02 20:19:07'),
(15, 'DiG-105', 'Khalid Iqbal', 'khalid.iqbal@digious.com', '$2a$10$fXR7nYYtwew6CXS6pyoN.uJCpHrE3RuHpgUOqUCByMIe/C.ruRJ1S', '03123598003', 'Production', ' Manager', '2026-01-05', 'North Nazimabd Karachi', '03102588816', 1, 'PKR 450 123456 789', 'CDN-4567', '1234-5103653-5', 'Branch Head', 'Active', '2026-01-04 19:22:59', '2026-01-04 19:22:59'),
(16, 'DIG-503', 'Muneeb Baig', 'muneeb.baig@digious.com', '$2a$10$7c3e3ve.x1SkZiOydTY5Nuv9KnNbT8qaOawOSEH4EQwNakbpQ56Rm', '4210151036535', 'Production', 'Developer ', '2026-01-01', '123qwerty', '031239800311', 1, 'pkriban1234590009', 'SSN123123', '42101-5103653-5121', 'Senior', 'Active', '2026-01-05 16:36:20', '2026-01-05 16:36:20'),
(17, 'DIG-444', 'NEW Test1', 'fatima.khan11@digious.com', '$2a$10$ui8OhY3roEIGZZZfr/NmieYMDkYgsKgw.yG/HthN.WKRKszbWIdMG', '4210151036535', 'Sales', 'MD', '2026-01-01', NULL, '11111', 1, '111111111111111', '1111111111', '1111111111111111111', 'MD', 'Active', '2026-01-13 20:51:49', '2026-01-13 20:51:49');

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
(2, 2, 1, 'DELL-DIG-0002', 1, 'CHARGER-002', 1, 'MOUSE-002', 1, 'KEYBOARD-002', 1, 'Hunain Monitior test', 1, 'MOBILE-002', 'New Equipment', '2025-11-15 09:30:00', NULL),
(3, 3, 1, 'DELL-DIG-0003', 1, 'CHARGER-003', 1, 'MOUSE-003', 1, 'KEYBOARD-003', 1, 'MONITOR-003', 1, 'MOBILE-003', 'Good Condition', '2025-10-20 08:00:00', NULL),
(4, 4, 1, 'DELL-DIG-0004', 1, 'CHARGER-004', 1, 'MOUSE-004', 0, NULL, 1, 'MONITOR-004', 1, 'MOBILE-004', 'Working', '2025-11-01 11:00:00', NULL),
(5, 5, 1, 'DELL-DIG-0005', 1, 'CHARGER-005', 1, 'MOUSE-005', 1, 'KEYBOARD-005', 0, NULL, 0, NULL, 'Needs Monitor Setup', '2025-12-01 10:30:00', NULL),
(6, 12, 0, NULL, 0, NULL, 0, NULL, 0, NULL, 0, NULL, 0, NULL, NULL, '2026-01-02 19:14:56', NULL),
(7, 13, 0, NULL, 0, NULL, 0, NULL, 0, NULL, 0, NULL, 0, NULL, NULL, '2026-01-02 19:54:33', NULL),
(8, 14, 0, NULL, 0, NULL, 0, NULL, 0, NULL, 0, NULL, 0, NULL, NULL, '2026-01-02 20:07:51', NULL),
(9, 15, 0, NULL, 0, NULL, 0, NULL, 0, NULL, 0, NULL, 0, NULL, NULL, '2026-01-04 19:22:59', NULL),
(10, 16, 0, NULL, 0, NULL, 0, NULL, 0, NULL, 0, NULL, 0, NULL, NULL, '2026-01-05 16:36:20', NULL),
(11, 17, 0, NULL, 0, NULL, 0, NULL, 0, NULL, 0, NULL, 0, NULL, NULL, '2026-01-13 20:51:49', NULL);

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
(5, 5, 65000.00, 67500.00, '2025-12-01 10:30:00'),
(6, 12, 75000.00, 85000.00, '2026-01-02 19:14:56'),
(7, 13, 100000.00, 101000.00, '2026-01-02 19:54:33'),
(8, 14, 100000.00, 100000.00, '2026-01-02 20:07:51'),
(9, 15, 190000.00, 210000.00, '2026-01-04 19:22:59'),
(10, 16, 30000.00, 35000.00, '2026-01-05 16:36:20'),
(11, 17, 1111.00, 1111.00, '2026-01-13 20:51:49');

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
(5, 5, 1, '2025-12-01 11:00:00', 1, '2025-12-01 11:30:00', 1, '2025-12-01 12:00:00', 0, NULL, 0, NULL, 0, NULL, 50, 0, NULL),
(6, 12, 1, NULL, 1, NULL, 1, NULL, 1, NULL, 1, NULL, 1, NULL, 100, 1, NULL),
(7, 13, 1, NULL, 1, NULL, 1, NULL, 1, NULL, 1, NULL, 1, NULL, 100, 1, NULL),
(8, 14, 1, NULL, 1, NULL, 1, NULL, 1, NULL, 1, NULL, 1, NULL, 100, 1, NULL),
(9, 15, 1, NULL, 1, NULL, 1, NULL, 1, NULL, 1, NULL, 1, NULL, 100, 1, NULL),
(10, 16, 1, NULL, 1, NULL, 1, NULL, 1, NULL, 1, NULL, 1, NULL, 100, 1, NULL),
(11, 17, 1, NULL, 1, NULL, 1, NULL, 1, NULL, 1, NULL, 1, NULL, 100, 1, NULL);

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
(1, 1, 'Muhammad Hunain', 'muhammad.hunain@digious.com', '$2a$12$Tdc/e2C9kf.GOIVDwS0HQ.GIqPNlmfjL.R5wImzRWSHniZO1eKDUa', 'Production', 'Software Engineer', 'Senior Developer', 'Active', 0, 15, '2026-01-02 09:00:00', NULL, NULL, 1, '2025-11-01 10:00:00', '2026-01-12 21:29:00'),
(2, 2, 'Ahmed Ali', 'ahmed.ali@digious.com', '$2a$10$iiNWuFJ27Mb42.TwAfp08e05//2dPnSnAIioD8G8D5heXSzhG1UDC', 'Production', 'Software Developer', 'Junior Developer', 'Active', 0, 8, '2026-01-02 10:15:00', NULL, NULL, 1, '2025-11-15 09:30:00', '2026-01-13 13:33:42'),
(3, 3, 'Fatima Khan', 'fatima.khan@digious.com', '$2a$12$Tdc/e2C9kf.GOIVDwS0HQ.GIqPNlmfjL.R5wImzRWSHniZO1eKDUa', 'HR', 'HR Manager', 'HR Manager', 'Active', 0, 25, '2026-01-02 08:30:00', NULL, NULL, 1, '2025-10-20 08:00:00', '2026-01-02 08:30:00'),
(4, 4, 'Hassan Raza', 'hassan.raza@digious.com', '$2a$10$MQOPnBPpBTWOIFnd1f1UJu3cZQJIc104ucgrYkOc3Xl6RXd3ADT2q', 'Sales', 'Sales Manager', 'Sales Head', 'Active', 0, 12, '2026-01-02 11:00:00', NULL, NULL, 1, '2025-11-01 11:00:00', '2026-01-02 19:09:52'),
(5, 5, 'Sara Ahmed', 'sara.ahmed@digious.com', '$2a$12$Tdc/e2C9kf.GOIVDwS0HQ.GIqPNlmfjL.R5wImzRWSHniZO1eKDUa', 'Finance', 'Finance Officer', 'Finance Officer', 'Active', 1, 5, '2026-01-02 09:30:00', NULL, NULL, 1, '2025-12-01 10:30:00', '2026-01-02 09:30:00'),
(6, 12, 'Raffay Ahmed', 'raffay.ahmed@digious.com', '$2a$10$XlzGt7qZM0kJOPYz53pE4e75VCxg0f0jJONXe4zC7VQH1UiyOGoT6', 'Production', 'Software Developer', 'Mid Level', 'Active', 0, 0, NULL, NULL, NULL, 1, '2026-01-02 19:14:56', '2026-01-02 19:15:53'),
(7, 13, 'test1', 'test1@digious.com', '$2a$10$zR9/TX7yDNo3mwWv.A.4ROUUw4i6KaGvLA1nlvluiiXMSqGB5610m', 'Production', 'MD1', 'SMD', 'Inactive', 0, 0, NULL, NULL, NULL, 1, '2026-01-02 19:54:33', '2026-01-12 12:31:48'),
(8, 14, 'Ron', 'ron@digious.com', '$2a$10$sSFUxoEgbmDuCF1WgnPtm.avY4muLF2Inqe5RkYOzK06Q8XToaeba', 'Production', 'MDq', 'MD2', 'Active', 0, 0, NULL, NULL, NULL, 1, '2026-01-02 20:07:51', '2026-01-02 20:19:07'),
(9, 15, 'Khalid Iqbal', 'khalid.iqbal@digious.com', '$2a$10$Ox1EPyf8Jcs1Rl0gDSJEpONnz3v97wwVrFeVInqNJqlXhtiUYFWbS', 'Production', ' Manager', 'Branch Head', 'Active', 0, 0, NULL, NULL, NULL, 1, '2026-01-04 19:22:59', '2026-01-05 08:51:00'),
(10, 16, 'Muneeb Baig', 'muneeb.baig@digious.com', '$2a$10$.HVtdNt9PQ2PQHyHwndefu0KRKSenfWVsQ1gyXNavh0lHzblry5WW', 'Production', 'Developer ', 'Senior', 'Active', 0, 0, NULL, NULL, NULL, 1, '2026-01-05 16:36:20', '2026-01-12 21:32:11'),
(11, 17, 'NEW Test1', 'fatima.khan11@digious.com', '$2a$10$ui8OhY3roEIGZZZfr/NmieYMDkYgsKgw.yG/HthN.WKRKszbWIdMG', 'Sales', 'MD', 'MD', 'Active', 1, 0, NULL, NULL, NULL, 1, '2026-01-13 20:51:49', '2026-01-13 20:51:49');

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
(1, 1, 'muhammad.hunain@digious.com', 43, 42, 1, 0, 0, '2026-01-13 16:24:21'),
(2, 2, 'ahmed.ali@digious.com', 3, 3, 0, 0, 0, '2026-01-05 16:47:12'),
(3, 3, 'fatima.khan@digious.com', 27, 26, 0, 1, 0, '2026-01-15 11:54:53'),
(4, 4, 'hassan.raza@digious.com', 4, 3, 1, 0, 0, '2026-01-03 11:21:59'),
(5, 5, 'sara.ahmed@digious.com', 1, 1, 0, 0, 0, '2026-01-02 09:30:00'),
(30, 15, 'khalid.iqbal@digious.com', 2, 2, 0, 0, 0, '2026-01-05 16:40:14'),
(31, 16, 'muneeb.baig@digious.com', 2, 2, 0, 0, 0, '2026-01-05 19:46:53');

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
-- Dumping data for table `user_system_info`
--

INSERT INTO `user_system_info` (`id`, `employee_id`, `session_token`, `email`, `name`, `login_time`, `logout_time`, `is_active`, `device_type`, `device_name`, `browser`, `os`, `ip_address`, `hostname`, `mac_address`, `country`, `city`, `timezone`, `user_agent`, `last_activity_time`, `created_at`, `updated_at`) VALUES
(1, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTczNTgyNjQwMH0.abc123', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 09:00:00', NULL, 1, 'PC', 'Dell Laptop', 'Chrome', 'Windows 10', '192.168.1.100', 'DEV-PC-001', '00:11:22:33:44:55', 'Pakistan', 'Karachi', 'Asia/Karachi', 'Mozilla/5.0 Chrome/120.0', '2026-01-02 09:30:00', '2026-01-02 09:00:00', '2026-01-02 09:30:00'),
(2, 2, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIsImlhdCI6MTczNTgzMTQwMH0.def456', 'ahmed.ali@digious.com', 'Ahmed Ali', '2026-01-02 10:30:00', NULL, 1, 'PC', 'HP Laptop', 'Firefox', 'Windows 11', '192.168.1.101', 'DEV-PC-002', '00:11:22:33:44:56', 'Pakistan', 'Karachi', 'Asia/Karachi', 'Mozilla/5.0 Firefox/121.0', '2026-01-02 11:00:00', '2026-01-02 10:30:00', '2026-01-02 11:00:00'),
(3, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImlhdCI6MTczNTgyNDAzMH0.ghi789', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-02 08:30:00', NULL, 1, 'PC', 'MacBook Pro', 'Safari', 'macOS', '192.168.1.102', 'HR-MAC-001', '00:11:22:33:44:57', 'Pakistan', 'Karachi', 'Asia/Karachi', 'Mozilla/5.0 Safari/605.1', '2026-01-02 09:00:00', '2026-01-02 08:30:00', '2026-01-02 09:00:00'),
(4, 4, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjQsImlhdCI6MTczNTgzNDA0MH0.jkl012', 'hassan.raza@digious.com', 'Hassan Raza', '2026-01-02 11:00:00', NULL, 1, 'Mobile', 'iPhone 14', 'Safari Mobile', 'iOS 17', '192.168.1.103', 'Hassans-iPhone', '00:11:22:33:44:58', 'Pakistan', 'Karachi', 'Asia/Karachi', 'Mozilla/5.0 iPhone OS 17_0', '2026-01-02 11:30:00', '2026-01-02 11:00:00', '2026-01-02 11:30:00'),
(5, 5, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjUsImlhdCI6MTczNTgyODIwMH0.mno345', 'sara.ahmed@digious.com', 'Sara Ahmed', '2026-01-02 09:30:00', NULL, 1, 'PC', 'Lenovo ThinkPad', 'Edge', 'Windows 10', '192.168.1.104', 'FIN-PC-001', '00:11:22:33:44:59', 'Pakistan', 'Karachi', 'Asia/Karachi', 'Mozilla/5.0 Edge/120.0', '2026-01-02 10:00:00', '2026-01-02 09:30:00', '2026-01-02 10:00:00'),
(49, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3MzQ1OTkxLCJleHAiOjE3Njc0MzIzOTF9.NFTncggc-leU-jpFEMHNn3IqKilcUEjRasNnUssDcW4', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 09:26:31', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '127.0.0.1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0', '2026-01-02 09:26:31', '2026-01-02 09:26:31', '2026-01-02 09:26:31'),
(50, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjczNDYwMzgsImV4cCI6MTc2NzQzMjQzOH0.3enAJ-kC_uqNmf0GCi2FKkACq3n9nAbpecXQOmhDxIU', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-02 09:27:18', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Unknown', 'Unknown', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-02 09:27:18', '2026-01-02 09:27:18', '2026-01-02 09:27:18'),
(51, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3MzUwNjkyLCJleHAiOjE3Njc0MzcwOTJ9.N_oBpMgQHGOuMRfxA6YCXGyVdLXq-YYqxXmali4Pnmc', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 10:44:52', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '::1', 'Unknown Host', 'N/A', 'Unknown', 'Unknown', 'Unknown', 'curl/8.5.0', '2026-01-02 10:44:52', '2026-01-02 10:44:52', '2026-01-02 10:44:52'),
(52, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3MzUwNzgyLCJleHAiOjE3Njc0MzcxODJ9.FPC5qq-wM_JRfvHtTigO-UixDQ_fbEm3-Z9QFpKWwjE', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 10:46:22', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '::1', 'Unknown Host', 'N/A', 'Unknown', 'Unknown', 'Unknown', 'curl/8.5.0', '2026-01-02 10:46:22', '2026-01-02 10:46:22', '2026-01-02 10:46:22'),
(53, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3MzUxMDM1LCJleHAiOjE3Njc0Mzc0MzV9.dXqqXpEwmSBM6XY1bFi4De4SkxUaOLAc3XMtR54ydtM', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 10:50:35', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '127.0.0.1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0', '2026-01-02 10:50:35', '2026-01-02 10:50:35', '2026-01-02 10:50:35'),
(54, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3MzUyOTA5LCJleHAiOjE3Njc0MzkzMDl9.DL2qfb7E3K7N__iG_dPvKZBLuY8X6synOizXUEMRLxA', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 11:21:49', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '::1', 'Unknown Host', 'N/A', 'Unknown', 'Unknown', 'Unknown', 'curl/8.5.0', '2026-01-02 11:21:49', '2026-01-02 11:21:49', '2026-01-02 11:21:49'),
(55, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3MzUyOTE3LCJleHAiOjE3Njc0MzkzMTd9.JTAVNAyasirbkdL0gHeNYWTZiQ_EZE2uDwHb55lSQyU', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 11:21:57', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '::1', 'Unknown Host', 'N/A', 'Unknown', 'Unknown', 'Unknown', 'curl/8.5.0', '2026-01-02 11:21:57', '2026-01-02 11:21:57', '2026-01-02 11:21:57'),
(56, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3MzUyOTQzLCJleHAiOjE3Njc0MzkzNDN9.WkSREWYBewsSgCDfDIBIuuDnWBxIbDqQM1f4Uo5Cb5I', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 11:22:23', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '::1', 'Unknown Host', 'N/A', 'Unknown', 'Unknown', 'Unknown', 'curl/8.5.0', '2026-01-02 11:22:23', '2026-01-02 11:22:23', '2026-01-02 11:22:23'),
(57, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3MzU1ODM1LCJleHAiOjE3Njc0NDIyMzV9.u-zRX9ONXHbwzJB5yt2vQQ8TLq9jotmSFQkHYZGDDVE', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 12:10:35', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-02 12:10:35', '2026-01-02 12:10:35', '2026-01-02 12:10:35'),
(58, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3MzU4MjkxLCJleHAiOjE3Njc0NDQ2OTF9.rAozzxPfSckFFG0cJ6WIH_Cn82uuGUtfFwJBBtDYMJE', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 12:51:31', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-02 12:51:31', '2026-01-02 12:51:31', '2026-01-02 12:51:31'),
(59, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3MzU5OTg3LCJleHAiOjE3Njc0NDYzODd9.uP5BVtItSzHEn-KwJ_bb2vmtKQU_mpIaSvpo-7WW9cU', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 13:19:47', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-02 13:19:47', '2026-01-02 13:19:47', '2026-01-02 13:19:47'),
(60, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjczNjA5NTMsImV4cCI6MTc2NzQ0NzM1M30.vBZ_jzigbKeq4YK2J5T8FfZKWKzVje4jJ1JzqrDIFzA', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-02 13:35:53', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-02 13:35:53', '2026-01-02 13:35:53', '2026-01-02 13:35:53'),
(61, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjczNjUwNTcsImV4cCI6MTc2NzQ1MTQ1N30.vvy39nXDNEIX4xGTD3z9EbBggCYmgkGBKbufNsCF1Ng', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-02 14:44:17', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-02 14:44:17', '2026-01-02 14:44:17', '2026-01-02 14:44:17'),
(62, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjczNjY1MzUsImV4cCI6MTc2NzQ1MjkzNX0.0TO9MRVcTcO-m1arYuc0MU6qF-Z_zhc6CRrqsEVGKpk', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-02 15:08:55', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-02 15:08:55', '2026-01-02 15:08:55', '2026-01-02 15:08:55'),
(63, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjczNjcwNTgsImV4cCI6MTc2NzQ1MzQ1OH0.EXszqGUCE6GG3wsumd6MOGgl8wZtbwSOmUn-HMD-O6I', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-02 15:17:38', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-02 15:17:38', '2026-01-02 15:17:38', '2026-01-02 15:17:38'),
(64, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjczNzE5OTYsImV4cCI6MTc2NzQ1ODM5Nn0.D3Eg5aeq7NWKQZJx30aOKm18WhMNtLLtcDH3BdwCyzM', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-02 16:39:56', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-02 16:39:56', '2026-01-02 16:39:56', '2026-01-02 16:39:56'),
(65, 2, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIsImVtcGxveWVlSWQiOjIsImVtYWlsIjoiYWhtZWQuYWxpQGRpZ2lvdXMuY29tIiwibmFtZSI6IkFobWVkIEFsaSIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJKdW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3MzcyNDA3LCJleHAiOjE3Njc0NTg4MDd9.269QdEPAtXScOiIU_pkhBwTn001g20jeG3sBGVzY5n0', 'ahmed.ali@digious.com', 'Ahmed Ali', '2026-01-02 16:46:47', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-02 16:46:47', '2026-01-02 16:46:47', '2026-01-02 16:46:47'),
(66, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjczNzQwMTgsImV4cCI6MTc2NzQ2MDQxOH0.VNopUl2GqJ8XdkhtZC5_kCAdvyca7l2acq_Ucm_y2QE', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-02 17:13:38', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-02 17:13:38', '2026-01-02 17:13:38', '2026-01-02 17:13:38'),
(67, 4, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjQsImVtcGxveWVlSWQiOjQsImVtYWlsIjoiaGFzc2FuLnJhemFAZGlnaW91cy5jb20iLCJuYW1lIjoiSGFzc2FuIFJhemEiLCJyb2xlIjoiU2FsZXMiLCJkZXNpZ25hdGlvbiI6IlNhbGVzIEhlYWQiLCJpYXQiOjE3NjczODA5NzgsImV4cCI6MTc2NzQ2NzM3OH0.1vtesMfBg4i2-6UyWCRdn2_zIoUxoPK-ciFbzw5boE4', 'hassan.raza@digious.com', 'Hassan Raza', '2026-01-02 19:09:38', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-02 19:09:38', '2026-01-02 19:09:38', '2026-01-02 19:09:38'),
(68, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjczODExNDIsImV4cCI6MTc2NzQ2NzU0Mn0.pWzyzGI2y101eHLG-67vMuRqgmqqui2xwTzmSrKMuGw', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-02 19:12:22', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-02 19:12:22', '2026-01-02 19:12:22', '2026-01-02 19:12:22'),
(70, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3MzgxNTc2LCJleHAiOjE3Njc0Njc5NzZ9.zK94Cp5QBJpLuRepuzHMEZv0udVkEmI-XJF6SMNvWqU', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 19:19:36', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-02 19:19:36', '2026-01-02 19:19:36', '2026-01-02 19:19:36'),
(72, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjczODM3NTcsImV4cCI6MTc2NzQ3MDE1N30.2VgfsyaB6Ln-IdTElAq33bXPjFnqaboAYHZdbdrR_5M', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-02 19:55:57', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-02 19:55:57', '2026-01-02 19:55:57', '2026-01-02 19:55:57'),
(74, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjczODQ4NjYsImV4cCI6MTc2NzQ3MTI2Nn0.IRRXE-UeCF6Os8KYOu5Y-zVB3pseDwSy15csQW5Cce8', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-02 20:14:26', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-02 20:14:26', '2026-01-02 20:14:26', '2026-01-02 20:14:26'),
(76, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3Mzg3NDczLCJleHAiOjE3Njc0NzM4NzN9.cPceRMbIe9q47dYG3pJRGx-TglSb72L_9fKdheS1HuY', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 20:57:53', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '::1', 'Unknown Host', 'N/A', 'Unknown', 'Unknown', 'Unknown', 'curl/8.5.0', '2026-01-02 20:57:53', '2026-01-02 20:57:53', '2026-01-02 20:57:53'),
(77, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3Mzg3NDg4LCJleHAiOjE3Njc0NzM4ODh9.qVIPY7Fc18Salzz5v1_LqpnVuSi5WICkoqWn6O-fhxE', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 20:58:08', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '::1', 'Unknown Host', 'N/A', 'Unknown', 'Unknown', 'Unknown', 'curl/8.5.0', '2026-01-02 20:58:08', '2026-01-02 20:58:08', '2026-01-02 20:58:08'),
(78, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3Mzg3NDk4LCJleHAiOjE3Njc0NzM4OTh9.k-Bnb7E1P7Qie7uLaPTLHQKzLxoToAKX6d59d3z113I', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 20:58:18', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '::1', 'Unknown Host', 'N/A', 'Unknown', 'Unknown', 'Unknown', 'curl/8.5.0', '2026-01-02 20:58:18', '2026-01-02 20:58:18', '2026-01-02 20:58:18'),
(79, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3Mzg3NTY1LCJleHAiOjE3Njc0NzM5NjV9.N3fbKuhlJVnO3ANSK4WgBMcJOXVgrMVVCRsfdWDmdFs', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 20:59:25', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '::1', 'Unknown Host', 'N/A', 'Unknown', 'Unknown', 'Unknown', 'curl/8.5.0', '2026-01-02 20:59:25', '2026-01-02 20:59:25', '2026-01-02 20:59:25'),
(81, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3Mzg4NDgzLCJleHAiOjE3Njc0NzQ4ODN9.Ygy9dwjkH3ymWWY4uvOvgB8zL1ov2d_H42L0dVlUGe0', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 21:14:43', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '::1', 'Unknown Host', 'N/A', 'Unknown', 'Unknown', 'Unknown', 'curl/8.5.0', '2026-01-02 21:14:43', '2026-01-02 21:14:43', '2026-01-02 21:14:43'),
(82, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3Mzg4NDkwLCJleHAiOjE3Njc0NzQ4OTB9.b89KANkfgW-FOzwm7exoG3M5EyX6TEZl6ls1njrIsY4', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 21:14:50', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '::1', 'Unknown Host', 'N/A', 'Unknown', 'Unknown', 'Unknown', 'curl/8.5.0', '2026-01-02 21:14:50', '2026-01-02 21:14:50', '2026-01-02 21:14:50'),
(83, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3Mzg4NjM1LCJleHAiOjE3Njc0NzUwMzV9.PNo1Oowyv2coXXXL0NnrY9e-ZjFVgUWvBd6IcLBRvHU', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 21:17:15', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '::1', 'Unknown Host', 'N/A', 'Unknown', 'Unknown', 'Unknown', 'curl/8.5.0', '2026-01-02 21:17:15', '2026-01-02 21:17:15', '2026-01-02 21:17:15'),
(84, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3Mzg4ODA5LCJleHAiOjE3Njc0NzUyMDl9.cxnVxHJ203r9605w5UYWyXx8YoDLqLvjydKdUYXqQ1k', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 21:20:09', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '::1', 'Unknown Host', 'N/A', 'Unknown', 'Unknown', 'Unknown', 'curl/8.5.0', '2026-01-02 21:20:09', '2026-01-02 21:20:09', '2026-01-02 21:20:09'),
(85, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3Mzg4ODE1LCJleHAiOjE3Njc0NzUyMTV9.jxGbl7-fJsT7CB-OiwX96VfHy8M0zkqWXVyc1SBkp4g', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 21:20:15', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '::1', 'Unknown Host', 'N/A', 'Unknown', 'Unknown', 'Unknown', 'curl/8.5.0', '2026-01-02 21:20:15', '2026-01-02 21:20:15', '2026-01-02 21:20:15'),
(86, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3Mzg4ODYyLCJleHAiOjE3Njc0NzUyNjJ9.mgLTXKZJYgcSfJP5cSTBh1W2593weX7dDjfs3vQ7eqM', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 21:21:02', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '::1', 'Unknown Host', 'N/A', 'Unknown', 'Unknown', 'Unknown', 'curl/8.5.0', '2026-01-02 21:21:02', '2026-01-02 21:21:02', '2026-01-02 21:21:02'),
(87, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3Mzg5MzYzLCJleHAiOjE3Njc0NzU3NjN9.IgoGtTxEH9j4zfTmb6m_28XqRf_b_sf5BiFkl1W-Lws', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 21:29:23', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '::1', 'Unknown Host', 'N/A', 'Unknown', 'Unknown', 'Unknown', 'curl/8.5.0', '2026-01-02 21:29:23', '2026-01-02 21:29:23', '2026-01-02 21:29:23'),
(88, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3Mzg5MzkxLCJleHAiOjE3Njc0NzU3OTF9.mUdtcdxoTFxnv6mCkMowA9Xx237-L2yITeW5HzgkXvU', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 21:29:51', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '::1', 'Unknown Host', 'N/A', 'Unknown', 'Unknown', 'Unknown', 'curl/8.5.0', '2026-01-02 21:29:51', '2026-01-02 21:29:51', '2026-01-02 21:29:51'),
(89, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3MzkwMzk1LCJleHAiOjE3Njc0NzY3OTV9.YoX06GzSrDkOJjhHdL_EEhdfyqsZR-BemU62NulyNRs', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 21:46:35', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '::1', 'Unknown Host', 'N/A', 'Unknown', 'Unknown', 'Unknown', 'curl/8.5.0', '2026-01-02 21:46:35', '2026-01-02 21:46:35', '2026-01-02 21:46:35'),
(90, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3MzkwNDAyLCJleHAiOjE3Njc0NzY4MDJ9.XcXcwpnA_lROMUeQ-yXecPmZKTXju_n0zFWQRVId3hI', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 21:46:42', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '::1', 'Unknown Host', 'N/A', 'Unknown', 'Unknown', 'Unknown', 'curl/8.5.0', '2026-01-02 21:46:42', '2026-01-02 21:46:42', '2026-01-02 21:46:42'),
(91, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3MzkwNDY4LCJleHAiOjE3Njc0NzY4Njh9.l1q_nEyg75HyFwEMbmPewOITXRc-js3ZjyOQv59zUYo', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 21:47:48', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '::1', 'Unknown Host', 'N/A', 'Unknown', 'Unknown', 'Unknown', 'curl/8.5.0', '2026-01-02 21:47:48', '2026-01-02 21:47:48', '2026-01-02 21:47:48'),
(92, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3MzkwNzA4LCJleHAiOjE3Njc0NzcxMDh9.3WRdSFOJOgU4s4ZJyy_GV9iQsCznLzPlsWwuKdDsegA', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 21:51:48', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '::1', 'Unknown Host', 'N/A', 'Unknown', 'Unknown', 'Unknown', 'curl/8.5.0', '2026-01-02 21:51:48', '2026-01-02 21:51:48', '2026-01-02 21:51:48'),
(93, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3MzkwNzI1LCJleHAiOjE3Njc0NzcxMjV9.-YIcB3iy_Jqqj5GPMtPdk_Ww4vtRCoFEPRNngHru_kI', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 21:52:05', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '::1', 'Unknown Host', 'N/A', 'Unknown', 'Unknown', 'Unknown', 'curl/8.5.0', '2026-01-02 21:52:05', '2026-01-02 21:52:05', '2026-01-02 21:52:05'),
(94, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3MzkwODY3LCJleHAiOjE3Njc0NzcyNjd9.YnPDNG3o-DiMj2o84Hh6AWrwCAbjZO0jiYP4YQxyUow', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 21:54:27', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '::1', 'Unknown Host', 'N/A', 'Unknown', 'Unknown', 'Unknown', 'curl/8.5.0', '2026-01-02 21:54:27', '2026-01-02 21:54:27', '2026-01-02 21:54:27'),
(95, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3MzkwOTUzLCJleHAiOjE3Njc0NzczNTN9.UIDVBg9N8b_VrciVJeovIq1OhLjHnMyoga_kyo1BCUE', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-02 21:55:53', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '::1', 'Unknown Host', 'N/A', 'Unknown', 'Unknown', 'Unknown', 'curl/8.5.0', '2026-01-02 21:55:53', '2026-01-02 21:55:53', '2026-01-02 21:55:53'),
(96, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjczOTE5MjIsImV4cCI6MTc2NzQ3ODMyMn0.twhL9oOtuDLCa6Mx8NLNxreGWjrBgzByLZLmWYbhMMI', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-02 22:12:02', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-02 22:12:02', '2026-01-02 22:12:02', '2026-01-02 22:12:02'),
(98, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3NDMxMjcwLCJleHAiOjE3Njc1MTc2NzB9.1BfWBhyB_LSuQAdJHPac4Wy7fAJV7EvsrRFNtnkaumc', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-03 09:07:50', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-03 09:07:50', '2026-01-03 09:07:50', '2026-01-03 09:07:50'),
(99, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3NDM1MTQwLCJleHAiOjE3Njc1MjE1NDB9.f6rvnEkZIBt18Muudjsaadfgb3lS5wwek9WBR753Z04', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-03 10:12:20', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '127.0.0.1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0', '2026-01-03 10:12:20', '2026-01-03 10:12:20', '2026-01-03 10:12:20'),
(100, 4, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjQsImVtcGxveWVlSWQiOjQsImVtYWlsIjoiaGFzc2FuLnJhemFAZGlnaW91cy5jb20iLCJuYW1lIjoiSGFzc2FuIFJhemEiLCJyb2xlIjoiU2FsZXMiLCJkZXNpZ25hdGlvbiI6IlNhbGVzIEhlYWQiLCJpYXQiOjE3Njc0MzkzMTksImV4cCI6MTc2NzUyNTcxOX0.6gCjQ8lX5okO_zZ5_FAm7Hlz9YIZ7TnN1kZVKtCiL9k', 'hassan.raza@digious.com', 'Hassan Raza', '2026-01-03 11:21:59', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '127.0.0.1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0', '2026-01-03 11:21:59', '2026-01-03 11:21:59', '2026-01-03 11:21:59'),
(123, 14, 'manual-test-token-14', 'ron@digious.com', 'Ron', '2026-01-03 15:17:05', NULL, 1, 'PC', NULL, NULL, NULL, '127.0.0.1', NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-03 15:17:05', '2026-01-03 15:17:05', '2026-01-03 15:17:05'),
(127, 14, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjgsImVtcGxveWVlSWQiOjE0LCJlbWFpbCI6InJvbkBkaWdpb3VzLmNvbSIsIm5hbWUiOiJSb24iLCJyb2xlIjoiUHJvZHVjdGlvbiIsImRlc2lnbmF0aW9uIjoiTUQyIiwiaWF0IjoxNzY3NDU2NzU3LCJleHAiOjE3Njc1NDMxNTd9.Pyzhgtj5Ajstwp8ftxJDRlH88ncJ067CU7d14r1rTKY', 'ron@digious.com', 'Ron', '2026-01-03 16:12:37', '2026-01-03 16:12:53', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-03 16:12:53', '2026-01-03 16:12:37', '2026-01-03 16:12:53'),
(129, 14, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjgsImVtcGxveWVlSWQiOjE0LCJlbWFpbCI6InJvbkBkaWdpb3VzLmNvbSIsIm5hbWUiOiJSb24iLCJyb2xlIjoiUHJvZHVjdGlvbiIsImRlc2lnbmF0aW9uIjoiTUQyIiwiaWF0IjoxNzY3NDU2NzgyLCJleHAiOjE3Njc1NDMxODJ9.Avrg4-DfD_2Xr9ffN6uUci6uVwa_gSIVU9STKoUGlgQ', 'ron@digious.com', 'Ron', '2026-01-03 16:13:02', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-03 16:13:02', '2026-01-03 16:13:02', '2026-01-03 16:13:02'),
(131, 14, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjgsImVtcGxveWVlSWQiOjE0LCJlbWFpbCI6InJvbkBkaWdpb3VzLmNvbSIsIm5hbWUiOiJSb24iLCJyb2xlIjoiUHJvZHVjdGlvbiIsImRlc2lnbmF0aW9uIjoiTUQyIiwiaWF0IjoxNzY3NDU4NTA2LCJleHAiOjE3Njc1NDQ5MDZ9.1Ou495lj6VVHeU7qIK-CS0QdwKKg-unI1OyhIfAm71c', 'ron@digious.com', 'Ron', '2026-01-03 16:41:46', '2026-01-03 16:54:35', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-03 16:54:35', '2026-01-03 16:41:46', '2026-01-03 16:54:35'),
(133, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3NDU5MjgzLCJleHAiOjE3Njc1NDU2ODN9.GM6qUr2tUPLbbt98F0r-8HMb3LQEOQtkgwmjJB_ErX8', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-03 16:54:43', '2026-01-03 16:55:39', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-03 16:55:39', '2026-01-03 16:54:43', '2026-01-03 16:55:39'),
(134, 12, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjYsImVtcGxveWVlSWQiOjEyLCJlbWFpbCI6InJhZmZheS5haG1lZEBkaWdpb3VzLmNvbSIsIm5hbWUiOiJSYWZmYXkgQWhtZWQiLCJyb2xlIjoiUHJvZHVjdGlvbiIsImRlc2lnbmF0aW9uIjoiTWlkIExldmVsIiwiaWF0IjoxNzY3NDU5MzQ2LCJleHAiOjE3Njc1NDU3NDZ9.oXcYiX2xebiu11rMAwxqEA3V1AnlQWPapp9PO1BYORg', 'raffay.ahmed@digious.com', 'Raffay Ahmed', '2026-01-03 16:55:46', '2026-01-03 17:26:39', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-03 17:26:39', '2026-01-03 16:55:46', '2026-01-03 17:26:39'),
(136, 14, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjgsImVtcGxveWVlSWQiOjE0LCJlbWFpbCI6InJvbkBkaWdpb3VzLmNvbSIsIm5hbWUiOiJSb24iLCJyb2xlIjoiUHJvZHVjdGlvbiIsImRlc2lnbmF0aW9uIjoiTUQyIiwiaWF0IjoxNzY3NDYxMjg5LCJleHAiOjE3Njc1NDc2ODl9.jjiApQKeQ39B357GL77ZnH_VF4U6tR6_34ZHMLeru7Q', 'ron@digious.com', 'Ron', '2026-01-03 17:28:09', '2026-01-03 17:28:33', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-03 17:28:33', '2026-01-03 17:28:09', '2026-01-03 17:28:33'),
(138, 2, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIsImVtcGxveWVlSWQiOjIsImVtYWlsIjoiYWhtZWQuYWxpQGRpZ2lvdXMuY29tIiwibmFtZSI6IkFobWVkIEFsaSIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJKdW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3NDYxMzI3LCJleHAiOjE3Njc1NDc3Mjd9.9d3rUSSmnYotjtfOzv8KIiH377tZuEJr23pB-v45TRM', 'ahmed.ali@digious.com', 'Ahmed Ali', '2026-01-03 17:28:47', '2026-01-03 17:44:09', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-03 17:44:09', '2026-01-03 17:28:47', '2026-01-03 17:44:09'),
(139, 14, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjgsImVtcGxveWVlSWQiOjE0LCJlbWFpbCI6InJvbkBkaWdpb3VzLmNvbSIsIm5hbWUiOiJSb24iLCJyb2xlIjoiUHJvZHVjdGlvbiIsImRlc2lnbmF0aW9uIjoiTUQyIiwiaWF0IjoxNzY3NDY3ODc2LCJleHAiOjE3Njc1NTQyNzZ9.Js49g_fnZMKp2MUJH8tasSf2qOK9DpK5p7OsIM3luNA', 'ron@digious.com', 'Ron', '2026-01-03 19:17:56', '2026-01-03 19:34:29', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-03 19:34:29', '2026-01-03 19:17:56', '2026-01-03 19:34:29'),
(141, 14, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjgsImVtcGxveWVlSWQiOjE0LCJlbWFpbCI6InJvbkBkaWdpb3VzLmNvbSIsIm5hbWUiOiJSb24iLCJyb2xlIjoiUHJvZHVjdGlvbiIsImRlc2lnbmF0aW9uIjoiTUQyIiwiaWF0IjoxNzY3NDY4ODg2LCJleHAiOjE3Njc1NTUyODZ9.l_O_JXKyQ_BJp1XaF60e3ZjUmnIzX_jguaLoZuFvDKA', 'ron@digious.com', 'Ron', '2026-01-03 19:34:46', '2026-01-03 19:44:33', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-03 19:44:33', '2026-01-03 19:34:46', '2026-01-03 19:44:33'),
(143, 14, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjgsImVtcGxveWVlSWQiOjE0LCJlbWFpbCI6InJvbkBkaWdpb3VzLmNvbSIsIm5hbWUiOiJSb24iLCJyb2xlIjoiUHJvZHVjdGlvbiIsImRlc2lnbmF0aW9uIjoiTUQyIiwiaWF0IjoxNzY3NDY5NDgwLCJleHAiOjE3Njc1NTU4ODB9.uUPv-DoCgzuZ5bR3LuuSre-6zuyCZlEbnvI8RIXJqKA', 'ron@digious.com', 'Ron', '2026-01-03 19:44:40', '2026-01-03 19:51:46', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-03 19:51:46', '2026-01-03 19:44:40', '2026-01-03 19:51:46'),
(145, 14, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjgsImVtcGxveWVlSWQiOjE0LCJlbWFpbCI6InJvbkBkaWdpb3VzLmNvbSIsIm5hbWUiOiJSb24iLCJyb2xlIjoiUHJvZHVjdGlvbiIsImRlc2lnbmF0aW9uIjoiTUQyIiwiaWF0IjoxNzY3NDY5OTE2LCJleHAiOjE3Njc1NTYzMTZ9.Se_lUUjfL5PrFstwFNitM_dXR3hYrx7fLQzLSbfFWP8', 'ron@digious.com', 'Ron', '2026-01-03 19:51:56', '2026-01-03 19:53:40', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-03 19:53:40', '2026-01-03 19:51:56', '2026-01-03 19:53:40'),
(147, 14, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjgsImVtcGxveWVlSWQiOjE0LCJlbWFpbCI6InJvbkBkaWdpb3VzLmNvbSIsIm5hbWUiOiJSb24iLCJyb2xlIjoiUHJvZHVjdGlvbiIsImRlc2lnbmF0aW9uIjoiTUQyIiwiaWF0IjoxNzY3NDcwMDMyLCJleHAiOjE3Njc1NTY0MzJ9.INwibu2Ug8Iic1pxBjhhsdaXUt1fDaOWC8LppMQE_wU', 'ron@digious.com', 'Ron', '2026-01-03 19:53:52', '2026-01-03 19:57:41', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-03 19:57:41', '2026-01-03 19:53:52', '2026-01-03 19:57:41'),
(149, 14, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjgsImVtcGxveWVlSWQiOjE0LCJlbWFpbCI6InJvbkBkaWdpb3VzLmNvbSIsIm5hbWUiOiJSb24iLCJyb2xlIjoiUHJvZHVjdGlvbiIsImRlc2lnbmF0aW9uIjoiTUQyIiwiaWF0IjoxNzY3NDcwMjcxLCJleHAiOjE3Njc1NTY2NzF9.hco1djuLgc0Sfs6AMDo-kQUu5Ai10NkCQpEG7D8qkPs', 'ron@digious.com', 'Ron', '2026-01-03 19:57:51', '2026-01-03 20:08:57', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-03 20:08:57', '2026-01-03 19:57:51', '2026-01-03 20:08:57'),
(151, 14, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjgsImVtcGxveWVlSWQiOjE0LCJlbWFpbCI6InJvbkBkaWdpb3VzLmNvbSIsIm5hbWUiOiJSb24iLCJyb2xlIjoiUHJvZHVjdGlvbiIsImRlc2lnbmF0aW9uIjoiTUQyIiwiaWF0IjoxNzY3NDcwOTU0LCJleHAiOjE3Njc1NTczNTR9.VinxvlWjh-7ozyzps-bE780W9Mr5SV2gawv1QiwiT6E', 'ron@digious.com', 'Ron', '2026-01-03 20:09:14', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-03 20:09:14', '2026-01-03 20:09:14', '2026-01-03 20:09:14'),
(153, 14, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjgsImVtcGxveWVlSWQiOjE0LCJlbWFpbCI6InJvbkBkaWdpb3VzLmNvbSIsIm5hbWUiOiJSb24iLCJyb2xlIjoiUHJvZHVjdGlvbiIsImRlc2lnbmF0aW9uIjoiTUQyIiwiaWF0IjoxNzY3NDcxMDA3LCJleHAiOjE3Njc1NTc0MDd9.kib5v50k5pN6fn2EAs6EhgCzoXuKsEFy8i9dfmn6t9k', 'ron@digious.com', 'Ron', '2026-01-03 20:10:07', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-03 20:10:07', '2026-01-03 20:10:07', '2026-01-03 20:10:07'),
(155, 14, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjgsImVtcGxveWVlSWQiOjE0LCJlbWFpbCI6InJvbkBkaWdpb3VzLmNvbSIsIm5hbWUiOiJSb24iLCJyb2xlIjoiUHJvZHVjdGlvbiIsImRlc2lnbmF0aW9uIjoiTUQyIiwiaWF0IjoxNzY3NDcxMjI0LCJleHAiOjE3Njc1NTc2MjR9.jMl5IMNIFFLfBAPVWSHXlZXoZG55Wd7cA6jCxmkWIM0', 'ron@digious.com', 'Ron', '2026-01-03 20:13:44', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-03 20:13:44', '2026-01-03 20:13:44', '2026-01-03 20:13:44'),
(157, 14, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjgsImVtcGxveWVlSWQiOjE0LCJlbWFpbCI6InJvbkBkaWdpb3VzLmNvbSIsIm5hbWUiOiJSb24iLCJyb2xlIjoiUHJvZHVjdGlvbiIsImRlc2lnbmF0aW9uIjoiTUQyIiwiaWF0IjoxNzY3NDcxOTU3LCJleHAiOjE3Njc1NTgzNTd9.MgmRP3qbqY7-kmUevaMqho3EXZ-WOgvkljh5168NoE8', 'ron@digious.com', 'Ron', '2026-01-03 20:25:57', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-03 20:25:57', '2026-01-03 20:25:57', '2026-01-03 20:25:57'),
(159, 14, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjgsImVtcGxveWVlSWQiOjE0LCJlbWFpbCI6InJvbkBkaWdpb3VzLmNvbSIsIm5hbWUiOiJSb24iLCJyb2xlIjoiUHJvZHVjdGlvbiIsImRlc2lnbmF0aW9uIjoiTUQyIiwiaWF0IjoxNzY3NDcyMjI4LCJleHAiOjE3Njc1NTg2Mjh9.NjOYlfe7VxDhHEF_ldq0WhFjoMkso-__8c8mMQzuDNI', 'ron@digious.com', 'Ron', '2026-01-03 20:30:28', '2026-01-03 20:36:13', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-03 20:36:13', '2026-01-03 20:30:28', '2026-01-03 20:36:13'),
(161, 14, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjgsImVtcGxveWVlSWQiOjE0LCJlbWFpbCI6InJvbkBkaWdpb3VzLmNvbSIsIm5hbWUiOiJSb24iLCJyb2xlIjoiUHJvZHVjdGlvbiIsImRlc2lnbmF0aW9uIjoiTUQyIiwiaWF0IjoxNzY3NDcyNTgxLCJleHAiOjE3Njc1NTg5ODF9.fvpUE-lVgwA0iebA8rVt_YRys6cWU78240a3ECSRCV4', 'ron@digious.com', 'Ron', '2026-01-03 20:36:21', '2026-01-03 21:03:33', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-03 21:03:33', '2026-01-03 20:36:21', '2026-01-03 21:03:33'),
(163, 14, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjgsImVtcGxveWVlSWQiOjE0LCJlbWFpbCI6InJvbkBkaWdpb3VzLmNvbSIsIm5hbWUiOiJSb24iLCJyb2xlIjoiUHJvZHVjdGlvbiIsImRlc2lnbmF0aW9uIjoiTUQyIiwiaWF0IjoxNzY3NDc0NDY1LCJleHAiOjE3Njc1NjA4NjV9.nrmX0717SifOKFDBKfRKgzVKAtblVFOy7_3jg5SnnVU', 'ron@digious.com', 'Ron', '2026-01-03 21:07:45', '2026-01-03 21:23:29', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-03 21:23:29', '2026-01-03 21:07:45', '2026-01-03 21:23:29'),
(165, 14, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjgsImVtcGxveWVlSWQiOjE0LCJlbWFpbCI6InJvbkBkaWdpb3VzLmNvbSIsIm5hbWUiOiJSb24iLCJyb2xlIjoiUHJvZHVjdGlvbiIsImRlc2lnbmF0aW9uIjoiTUQyIiwiaWF0IjoxNzY3NDc1OTA4LCJleHAiOjE3Njc1NjIzMDh9.bFLZcw3NMy1fMUoXvcptR9xMJ4QbgGdZOx-RM77NZTc', 'ron@digious.com', 'Ron', '2026-01-03 21:31:48', '2026-01-03 21:33:01', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-03 21:33:01', '2026-01-03 21:31:48', '2026-01-03 21:33:01'),
(167, 14, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjgsImVtcGxveWVlSWQiOjE0LCJlbWFpbCI6InJvbkBkaWdpb3VzLmNvbSIsIm5hbWUiOiJSb24iLCJyb2xlIjoiUHJvZHVjdGlvbiIsImRlc2lnbmF0aW9uIjoiTUQyIiwiaWF0IjoxNzY3NDc1OTg5LCJleHAiOjE3Njc1NjIzODl9.APEv6Meq8SAPMr8JVH76fTAi6MTOiMjiVXwbdkk_FUI', 'ron@digious.com', 'Ron', '2026-01-03 21:33:09', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-03 21:33:09', '2026-01-03 21:33:09', '2026-01-03 21:33:09'),
(169, 14, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjgsImVtcGxveWVlSWQiOjE0LCJlbWFpbCI6InJvbkBkaWdpb3VzLmNvbSIsIm5hbWUiOiJSb24iLCJyb2xlIjoiUHJvZHVjdGlvbiIsImRlc2lnbmF0aW9uIjoiTUQyIiwiaWF0IjoxNzY3NDc2OTc1LCJleHAiOjE3Njc1NjMzNzV9.N7RGlOqCznrRODq9xTOpBdkN3QXzFGvmlhgdFrDibDs', 'ron@digious.com', 'Ron', '2026-01-03 21:49:35', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-03 21:49:35', '2026-01-03 21:49:35', '2026-01-03 21:49:35'),
(171, 14, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjgsImVtcGxveWVlSWQiOjE0LCJlbWFpbCI6InJvbkBkaWdpb3VzLmNvbSIsIm5hbWUiOiJSb24iLCJyb2xlIjoiUHJvZHVjdGlvbiIsImRlc2lnbmF0aW9uIjoiTUQyIiwiaWF0IjoxNzY3NDc4MzI4LCJleHAiOjE3Njc1NjQ3Mjh9.K73UoTmkJTzYKyvRav-MIydVUdWX96F9Gm7QZ6npz1g', 'ron@digious.com', 'Ron', '2026-01-03 22:12:08', '2026-01-03 22:14:38', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-03 22:14:38', '2026-01-03 22:12:08', '2026-01-03 22:14:38'),
(173, 12, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjYsImVtcGxveWVlSWQiOjEyLCJlbWFpbCI6InJhZmZheS5haG1lZEBkaWdpb3VzLmNvbSIsIm5hbWUiOiJSYWZmYXkgQWhtZWQiLCJyb2xlIjoiUHJvZHVjdGlvbiIsImRlc2lnbmF0aW9uIjoiTWlkIExldmVsIiwiaWF0IjoxNzY3NDc4NDkyLCJleHAiOjE3Njc1NjQ4OTJ9.dt6XnSW3p4ro0Jq1iwz_wdWr2y3TkRN-H9l1YUsLweo', 'raffay.ahmed@digious.com', 'Raffay Ahmed', '2026-01-03 22:14:52', '2026-01-03 22:15:23', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-03 22:15:23', '2026-01-03 22:14:52', '2026-01-03 22:15:23'),
(175, 2, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIsImVtcGxveWVlSWQiOjIsImVtYWlsIjoiYWhtZWQuYWxpQGRpZ2lvdXMuY29tIiwibmFtZSI6IkFobWVkIEFsaSIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJKdW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3NDc4NTMxLCJleHAiOjE3Njc1NjQ5MzF9.SH1gxpfd2j0kTEpvLZUMv3HmR_UJ0OugCfZWXkEy_xY', 'ahmed.ali@digious.com', 'Ahmed Ali', '2026-01-03 22:15:31', '2026-01-03 22:16:27', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-03 22:16:27', '2026-01-03 22:15:31', '2026-01-03 22:16:27');
INSERT INTO `user_system_info` (`id`, `employee_id`, `session_token`, `email`, `name`, `login_time`, `logout_time`, `is_active`, `device_type`, `device_name`, `browser`, `os`, `ip_address`, `hostname`, `mac_address`, `country`, `city`, `timezone`, `user_agent`, `last_activity_time`, `created_at`, `updated_at`) VALUES
(176, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3Njc0Nzg3NDgsImV4cCI6MTc2NzU2NTE0OH0.x9v2lVu30KNjv4niOHwf6ud0LoNkGiAJJQ1ED_IlpYU', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-03 22:19:08', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-03 22:19:08', '2026-01-03 22:19:08', '2026-01-03 22:19:08'),
(177, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3Njc1MjEyNzEsImV4cCI6MTc2NzYwNzY3MX0.y2ZEMJmCaVxSI4hRI2bom8asG88BGW_1YEUERQI6A4U', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-04 10:07:51', '2026-01-04 10:16:45', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-04 10:16:45', '2026-01-04 10:07:51', '2026-01-04 10:16:45'),
(178, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3Njc1MjE4MTIsImV4cCI6MTc2NzYwODIxMn0.tOCvVjGL6dzfeEIG_5X8eAvrkWHHSSw4yJAnlmuniPg', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-04 10:16:52', '2026-01-04 10:32:20', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-04 10:32:20', '2026-01-04 10:16:52', '2026-01-04 10:32:20'),
(179, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3Njc1MjM4ODAsImV4cCI6MTc2NzYxMDI4MH0.M_uwEXvQ4uoYuBp-YQWJwJ89TRaGX4kslOeAzNtIEm8', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-04 10:51:20', '2026-01-04 11:07:23', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-04 11:07:23', '2026-01-04 10:51:20', '2026-01-04 11:07:23'),
(180, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3Njc1MjUxNjQsImV4cCI6MTc2NzYxMTU2NH0.0Fz3xWpWgdlXjCHr9q32gviIAW62hTzmdC1CW44aR-A', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-04 11:12:44', '2026-01-04 11:30:33', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-04 11:30:33', '2026-01-04 11:12:44', '2026-01-04 11:30:33'),
(181, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3Njc1Mjg5MzcsImV4cCI6MTc2NzYxNTMzN30.agqrkcpiE_Fhxs_RqeP8_Qjnhy-FSyo4EAl6nHNqQqE', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-04 12:15:37', '2026-01-04 12:40:16', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-04 12:40:16', '2026-01-04 12:15:37', '2026-01-04 12:40:16'),
(182, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3Njc1MzM1ODEsImV4cCI6MTc2NzYxOTk4MX0.BUI5iVQ1jiBCAym-e5qfYClZrOEUpJ6Mxe6GkyRn6ZE', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-04 13:33:01', '2026-01-04 14:44:45', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-04 14:44:45', '2026-01-04 13:33:01', '2026-01-04 14:44:45'),
(183, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3Njc1NDMxMDAsImV4cCI6MTc2NzYyOTUwMH0.L6RaEC6LgSUsd172spcny0DkkACzMNXEtldNDEr7ex8', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-04 16:11:40', '2026-01-04 17:17:12', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-04 17:17:12', '2026-01-04 16:11:40', '2026-01-04 17:17:12'),
(184, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3Njc1NDcwNTUsImV4cCI6MTc2NzYzMzQ1NX0.lu54pCBOV8VhV7KU9ES_iF-_N_4TcmBpAOwKtwQB6aU', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-04 17:17:35', '2026-01-04 17:41:57', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-04 17:41:57', '2026-01-04 17:17:35', '2026-01-04 17:41:57'),
(185, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3Njc1NDkzMDQsImV4cCI6MTc2NzYzNTcwNH0.V6dGqbXimBsTSTbIOeIEQw9mJ3_ctmCmwGmVrpnf_54', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-04 17:55:04', '2026-01-05 06:40:45', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-05 06:40:45', '2026-01-04 17:55:04', '2026-01-05 06:40:45'),
(186, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3Njc2MDI4NDgsImV4cCI6MTc2NzY4OTI0OH0.8qZMQ5ceupL-QmaLUzNaog3tQmAYtROSdcgYIxROB70', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-05 08:47:28', '2026-01-05 09:09:41', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-05 09:09:41', '2026-01-05 08:47:28', '2026-01-05 09:09:41'),
(187, 15, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjksImVtcGxveWVlSWQiOjE1LCJlbWFpbCI6ImtoYWxpZC5pcWJhbEBkaWdpb3VzLmNvbSIsIm5hbWUiOiJLaGFsaWQgSXFiYWwiLCJyb2xlIjoiUHJvZHVjdGlvbiIsImRlc2lnbmF0aW9uIjoiQnJhbmNoIEhlYWQiLCJpYXQiOjE3Njc2MDMwNDAsImV4cCI6MTc2NzY4OTQ0MH0.veTYgAMidEmHqh8-C2WgwXEEw_QYjcMiEGqGHn8y0N4', 'khalid.iqbal@digious.com', 'Khalid Iqbal', '2026-01-05 08:50:40', '2026-01-05 09:09:19', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '127.0.0.1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0', '2026-01-05 09:09:19', '2026-01-05 08:50:40', '2026-01-05 09:09:19'),
(189, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3Njc2MDY5MzksImV4cCI6MTc2NzY5MzMzOX0.VB-Y6h7sEXJAgOLp8PPwyn7mrGg9heVc7xvDBbb6X9g', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-05 09:55:39', '2026-01-05 10:24:57', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-05 10:24:57', '2026-01-05 09:55:39', '2026-01-05 10:24:57'),
(190, 15, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjksImVtcGxveWVlSWQiOjE1LCJlbWFpbCI6ImtoYWxpZC5pcWJhbEBkaWdpb3VzLmNvbSIsIm5hbWUiOiJLaGFsaWQgSXFiYWwiLCJyb2xlIjoiUHJvZHVjdGlvbiIsImRlc2lnbmF0aW9uIjoiQnJhbmNoIEhlYWQiLCJpYXQiOjE3Njc2MDczNTQsImV4cCI6MTc2NzY5Mzc1NH0.ycn_j4yrRZK1lQoXDRTOjo1LwsfbB2zx_-BNaFoCKDo', 'khalid.iqbal@digious.com', 'Khalid Iqbal', '2026-01-05 10:02:34', '2026-01-05 10:20:09', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '127.0.0.1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0', '2026-01-05 10:20:09', '2026-01-05 10:02:34', '2026-01-05 10:20:09'),
(191, 15, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjksImVtcGxveWVlSWQiOjE1LCJlbWFpbCI6ImtoYWxpZC5pcWJhbEBkaWdpb3VzLmNvbSIsIm5hbWUiOiJLaGFsaWQgSXFiYWwiLCJyb2xlIjoiUHJvZHVjdGlvbiIsImRlc2lnbmF0aW9uIjoiQnJhbmNoIEhlYWQiLCJpYXQiOjE3Njc2MDg1MzIsImV4cCI6MTc2NzY5NDkzMn0.W6e-yZFhIQqEqnB8pc9CBfePk7UD_O79OJUTZqUnpvQ', 'khalid.iqbal@digious.com', 'Khalid Iqbal', '2026-01-05 10:22:12', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '127.0.0.1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0', '2026-01-05 10:22:12', '2026-01-05 10:22:12', '2026-01-05 10:22:12'),
(192, 15, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjksImVtcGxveWVlSWQiOjE1LCJlbWFpbCI6ImtoYWxpZC5pcWJhbEBkaWdpb3VzLmNvbSIsIm5hbWUiOiJLaGFsaWQgSXFiYWwiLCJyb2xlIjoiUHJvZHVjdGlvbiIsImRlc2lnbmF0aW9uIjoiQnJhbmNoIEhlYWQiLCJpYXQiOjE3Njc2MjMzMjcsImV4cCI6MTc2NzcwOTcyN30.cJjjBQwu_dXf5o_A9Pcc1S0RPG_kziCmn2IW3-99Duk', 'khalid.iqbal@digious.com', 'Khalid Iqbal', '2026-01-05 14:28:47', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '127.0.0.1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0', '2026-01-05 14:28:47', '2026-01-05 14:28:47', '2026-01-05 14:28:47'),
(193, 2, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIsImVtcGxveWVlSWQiOjIsImVtYWlsIjoiYWhtZWQuYWxpQGRpZ2lvdXMuY29tIiwibmFtZSI6IkFobWVkIEFsaSIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJKdW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3NjI0MTI2LCJleHAiOjE3Njc3MTA1MjZ9.2f6uN5EXHsEdqYBL-6BrLOZWz1tUek70hNlLi69XMK8', 'ahmed.ali@digious.com', 'Ahmed Ali', '2026-01-05 14:42:06', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-05 14:42:06', '2026-01-05 14:42:06', '2026-01-05 14:42:06'),
(194, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3Njc2MzA0NTgsImV4cCI6MTc2NzcxNjg1OH0.eoS3bKjXcMf5xk4ckzFiX7C4qZkfCVOXkqeXPWbwv54', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-05 16:27:38', '2026-01-05 16:37:03', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-05 16:37:03', '2026-01-05 16:27:38', '2026-01-05 16:37:03'),
(195, 16, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEwLCJlbXBsb3llZUlkIjoxNiwiZW1haWwiOiJtdW5lZWIuYmFpZ0BkaWdpb3VzLmNvbSIsIm5hbWUiOiJNdW5lZWIgQmFpZyIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IiLCJpYXQiOjE3Njc2MzEwMzIsImV4cCI6MTc2NzcxNzQzMn0.r7qpUPuyiXGW4Iiz4mJouGzUIhZUIXN2uESxvm_QKEg', 'muneeb.baig@digious.com', 'Muneeb Baig', '2026-01-05 16:37:12', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-05 16:37:12', '2026-01-05 16:37:12', '2026-01-05 16:37:12'),
(196, 15, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjksImVtcGxveWVlSWQiOjE1LCJlbWFpbCI6ImtoYWxpZC5pcWJhbEBkaWdpb3VzLmNvbSIsIm5hbWUiOiJLaGFsaWQgSXFiYWwiLCJyb2xlIjoiUHJvZHVjdGlvbiIsImRlc2lnbmF0aW9uIjoiQnJhbmNoIEhlYWQiLCJpYXQiOjE3Njc2MzExOTksImV4cCI6MTc2NzcxNzU5OX0.JWdqNiMlFgKO9vTptFHmotAv6KC9plPewcZMJ3XMLw4', 'khalid.iqbal@digious.com', 'Khalid Iqbal', '2026-01-05 16:39:59', '2026-01-05 16:40:14', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-05 16:40:14', '2026-01-05 16:39:59', '2026-01-05 16:40:14'),
(197, 2, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIsImVtcGxveWVlSWQiOjIsImVtYWlsIjoiYWhtZWQuYWxpQGRpZ2lvdXMuY29tIiwibmFtZSI6IkFobWVkIEFsaSIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJKdW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3NjMxMjIyLCJleHAiOjE3Njc3MTc2MjJ9._bVuvGTQsvJcaEQht0LezYAuYJt9VBVM1ysmzsp6YAI', 'ahmed.ali@digious.com', 'Ahmed Ali', '2026-01-05 16:40:22', '2026-01-05 16:47:12', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-05 16:47:12', '2026-01-05 16:40:22', '2026-01-05 16:47:12'),
(198, 16, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEwLCJlbXBsb3llZUlkIjoxNiwiZW1haWwiOiJtdW5lZWIuYmFpZ0BkaWdpb3VzLmNvbSIsIm5hbWUiOiJNdW5lZWIgQmFpZyIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IiLCJpYXQiOjE3Njc2MzMyNzUsImV4cCI6MTc2NzcxOTY3NX0.O7HkL9gXw0F6NDHHFaHazvPYgJsKQihwNShLvWumedM', 'muneeb.baig@digious.com', 'Muneeb Baig', '2026-01-05 17:14:35', '2026-01-05 17:54:16', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-05 17:54:16', '2026-01-05 17:14:35', '2026-01-05 17:54:16'),
(199, 16, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEwLCJlbXBsb3llZUlkIjoxNiwiZW1haWwiOiJtdW5lZWIuYmFpZ0BkaWdpb3VzLmNvbSIsIm5hbWUiOiJNdW5lZWIgQmFpZyIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IiLCJpYXQiOjE3Njc2MzYwODgsImV4cCI6MTc2NzcyMjQ4OH0.BgzIIu9-7Kuw0vUNN1m3ff92T-tH64cfygoPpMacO1U', 'muneeb.baig@digious.com', 'Muneeb Baig', '2026-01-05 18:01:28', '2026-01-05 18:08:18', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-05 18:08:18', '2026-01-05 18:01:28', '2026-01-05 18:08:18'),
(200, 16, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEwLCJlbXBsb3llZUlkIjoxNiwiZW1haWwiOiJtdW5lZWIuYmFpZ0BkaWdpb3VzLmNvbSIsIm5hbWUiOiJNdW5lZWIgQmFpZyIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IiLCJpYXQiOjE3Njc2NDE0NDEsImV4cCI6MTc2NzcyNzg0MX0.6kCj8GjXEoMI_mDhy0idCWI2muDkiyxWQjVi9l1sHR8', 'muneeb.baig@digious.com', 'Muneeb Baig', '2026-01-05 19:30:41', '2026-01-05 19:46:21', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-05 19:46:21', '2026-01-05 19:30:41', '2026-01-05 19:46:21'),
(201, 16, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEwLCJlbXBsb3llZUlkIjoxNiwiZW1haWwiOiJtdW5lZWIuYmFpZ0BkaWdpb3VzLmNvbSIsIm5hbWUiOiJNdW5lZWIgQmFpZyIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IiLCJpYXQiOjE3Njc2NDI0MTMsImV4cCI6MTc2NzcyODgxM30.XNUaFje4X-u7mKKw7KsNJ9-EqnEBXvMdBDS7PI-Hda0', 'muneeb.baig@digious.com', 'Muneeb Baig', '2026-01-05 19:46:53', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-05 19:46:53', '2026-01-05 19:46:53', '2026-01-05 19:46:53'),
(202, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3Njc3MjMzMzksImV4cCI6MTc2NzgwOTczOX0.hQr7uveenlnB0VUg9iPH9YKsMgDfBv55u3YlzcJXBEE', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-06 18:15:39', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-06 18:15:39', '2026-01-06 18:15:39', '2026-01-06 18:15:39'),
(203, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3Njc3MjM4NzgsImV4cCI6MTc2NzgxMDI3OH0.IPUsxR0gAI5IpHvsnTsZuM1CHKrWfEo2y5IqIf8xbgA', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-06 18:24:38', '2026-01-06 18:26:11', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-06 18:26:11', '2026-01-06 18:24:38', '2026-01-06 18:26:11'),
(204, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3NzIzOTc5LCJleHAiOjE3Njc4MTAzNzl9.kSSepc1XtXkGdEj-kogNKCKSeuCMjAIxxpSfRz7iYp0', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-06 18:26:19', '2026-01-06 18:30:57', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-06 18:30:57', '2026-01-06 18:26:19', '2026-01-06 18:30:57'),
(205, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3ODA0OTg0LCJleHAiOjE3Njc4OTEzODR9.q6NoxOtxzmptOK5ydCcOGqPN5d8Um6Vc46iDSnMfJzQ', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-07 16:56:24', '2026-01-07 17:19:30', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-07 17:19:30', '2026-01-07 16:56:24', '2026-01-07 17:19:30'),
(206, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3ODA2NDY4LCJleHAiOjE3Njc4OTI4Njh9._VCUaURxUmkuNozU-N1U5aIvX3nmkH-rZMaqDDpgSXc', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-07 17:21:08', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-07 17:21:08', '2026-01-07 17:21:08', '2026-01-07 17:21:08'),
(207, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3ODA3Nzk0LCJleHAiOjE3Njc4OTQxOTR9.C8PZHlVdHzRg_8lcLcCg0Z5gj4P4WAckBRW14CKIKZg', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-07 17:43:14', '2026-01-07 18:04:36', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-07 18:04:36', '2026-01-07 17:43:14', '2026-01-07 18:04:36'),
(208, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3ODk2NDMxLCJleHAiOjE3Njc5ODI4MzF9.BFWsY0QwEELZjB9Wx6P5nTMc5ovCy0bRSkIA8SrB6ZE', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-08 18:20:31', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Unknown', 'Unknown', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-08 18:20:31', '2026-01-08 18:20:31', '2026-01-08 18:20:31'),
(209, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3ODk3MDA2LCJleHAiOjE3Njc5ODM0MDZ9.-NYg8k4nElaN8uCiZQhLTe9sV0MbAHjgcOb_mvekKxs', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-08 18:30:06', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-08 18:30:06', '2026-01-08 18:30:06', '2026-01-08 18:30:06'),
(210, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3ODk4OTc1LCJleHAiOjE3Njc5ODUzNzV9.gjp5C0agy7f9ssn3EVcsZW4EmbpR86QCPWArZqWYyUI', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-08 19:02:55', '2026-01-08 19:22:20', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '127.0.0.1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0', '2026-01-08 19:22:20', '2026-01-08 19:02:55', '2026-01-08 19:22:20'),
(211, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3OTAyMzgzLCJleHAiOjE3Njc5ODg3ODN9.eMwGZVzpMlgW7i1G1_LN2_hClw8n3EKpNR_wyafrcuU', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-08 19:59:43', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-08 19:59:43', '2026-01-08 19:59:43', '2026-01-08 19:59:43'),
(212, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3OTc1NDMwLCJleHAiOjE3NjgwNjE4MzB9.U7pEf4DeUR7fl22iQT_JMqPlh6idJfwOWAMe1LeHPr8', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-09 16:17:10', '2026-01-09 16:35:06', 0, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-09 16:35:06', '2026-01-09 16:17:10', '2026-01-09 16:35:06'),
(213, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3OTc5MDUwLCJleHAiOjE3NjgwNjU0NTB9.H6M_k_MABgD-dugrRTZps03x3J-HattHsvBXQui3dEY', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-09 17:17:30', NULL, 1, 'PC', 'Unknown Device', 'Unknown Browser', 'Unknown OS', '1', 'Unknown Host', 'N/A', 'Pakistan', 'Karachi Division', 'Unknown', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-09 17:17:30', '2026-01-09 17:17:30', '2026-01-09 17:17:30'),
(214, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY3OTg3MDAyLCJleHAiOjE3NjgwNzM0MDJ9.IeSa-cFfLz-FMpFbS0DspZ2d5TbkWX2Z99DWR6qA2Jc', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-09 19:30:02', NULL, 1, 'PC', 'Linux PC', 'Chrome 143', 'Linux', '::1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-09 19:30:02', '2026-01-09 19:30:02', '2026-01-09 19:30:02'),
(215, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjgyMTY3ODQsImV4cCI6MTc2ODMwMzE4NH0.vFdLfRjoxkUmtEmdPEuqwCYsjW7xJJwOKmRZKK8BMkw', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-12 11:19:44', NULL, 1, 'PC', 'Linux PC', 'Chrome 143', 'Linux', '::1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-12 11:19:44', '2026-01-12 11:19:44', '2026-01-12 11:19:44'),
(216, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjgyMTc3MzQsImV4cCI6MTc2ODMwNDEzNH0.d-72rtb1fbcKlFyWPB4lj-mDQ_Lkg2l3J3lhfUyL_CI', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-12 11:35:34', NULL, 1, 'PC', 'Linux PC', 'Chrome 143', 'Linux', '::1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-12 11:35:34', '2026-01-12 11:35:34', '2026-01-12 11:35:34'),
(217, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY4MjE4MjA3LCJleHAiOjE3NjgzMDQ2MDd9.7nO7NZdQrua1GDnnkVH8pexoVzvwlEgEaNKJ8St6JQk', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-12 11:43:27', NULL, 1, 'PC', 'Linux PC', 'Chrome 143', 'Linux', '::1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-12 11:43:27', '2026-01-12 11:43:27', '2026-01-12 11:43:27'),
(218, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjgyMjA5OTgsImV4cCI6MTc2ODMwNzM5OH0.s98CWTcQoXdusCFPXx6oZdhYS3eu6ImnJIiis2MyEXU', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-12 12:29:58', '2026-01-12 14:59:46', 0, 'PC', 'Linux PC', 'Firefox 146', 'Linux', '::ffff:127.0.0.1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0', '2026-01-12 14:59:46', '2026-01-12 12:29:58', '2026-01-12 14:59:46'),
(219, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjgyMjYxNzUsImV4cCI6MTc2ODMxMjU3NX0.HldHe5rJpkZXQQXHAQQfJxrqobE63x4t5rMEbZkhAqg', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-12 13:56:15', NULL, 1, 'PC', 'Linux PC', 'Chrome 143', 'Linux', '::1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-12 13:56:15', '2026-01-12 13:56:15', '2026-01-12 13:56:15'),
(220, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjgyMzE2ODQsImV4cCI6MTc2ODMxODA4NH0.dYjaHj-2hEphY9K5vpapNIaD7mNVUvZclnGEqfm4SUk', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-12 15:28:04', '2026-01-12 16:33:22', 0, 'PC', 'Linux PC', 'Firefox 146', 'Linux', '::ffff:127.0.0.1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0', '2026-01-12 16:33:22', '2026-01-12 15:28:04', '2026-01-12 16:33:22'),
(221, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjgyMzU5MzksImV4cCI6MTc2ODMyMjMzOX0.ont5EnxjKSXyQmjqhd3BNMfodd-uRtWcm8spl7DqRIk', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-12 16:38:59', '2026-01-12 18:05:24', 0, 'PC', 'Linux PC', 'Firefox 146', 'Linux', '::ffff:127.0.0.1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0', '2026-01-12 18:05:24', '2026-01-12 16:38:59', '2026-01-12 18:05:24'),
(222, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY4MjQxMTgyLCJleHAiOjE3NjgzMjc1ODJ9.qo6Be4VARsLCg9Pw9Biav5TlClOoiOxqsqcH3khi7AI', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-12 18:06:22', NULL, 1, 'PC', 'Linux PC', 'Firefox 146', 'Linux', '::ffff:127.0.0.1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0', '2026-01-12 18:06:22', '2026-01-12 18:06:22', '2026-01-12 18:06:22'),
(223, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY4MjQyMTk2LCJleHAiOjE3NjgzMjg1OTZ9.zByZQkHHdr11UTBzTgjAOwtNKixq8SE9Ux1XyJPtS30', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-12 18:23:16', '2026-01-12 20:09:04', 0, 'PC', 'Linux PC', 'Firefox 146', 'Linux', '::ffff:127.0.0.1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0', '2026-01-12 20:09:04', '2026-01-12 18:23:16', '2026-01-12 20:09:04'),
(224, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjgyNDkxMDMsImV4cCI6MTc2ODMzNTUwM30.xdo4ReTQWFZb-TJoLNQvT3yuksHihozSqoGies_UEcs', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-12 20:18:23', NULL, 1, 'PC', 'Linux PC', 'Firefox 146', 'Linux', '::ffff:127.0.0.1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0', '2026-01-12 20:18:23', '2026-01-12 20:18:23', '2026-01-12 20:18:23'),
(225, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjgyNDk5MDAsImV4cCI6MTc2ODMzNjMwMH0.nPPei2RlKldgIS-IeqqYIB-HVzW3Yae_PW7wSaXRg9w', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-12 20:31:40', '2026-01-12 20:55:14', 0, 'PC', 'Linux PC', 'Chrome 143', 'Linux', '::1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-12 20:55:14', '2026-01-12 20:31:40', '2026-01-12 20:55:14'),
(226, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjgyNTI1ODYsImV4cCI6MTc2ODMzODk4Nn0.K6CdXhY9uEQmZR10Tq_KDBTDun6FvCnOoyouShBGlho', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-12 21:16:26', NULL, 1, 'PC', 'Linux PC', 'Chrome 143', 'Linux', '::1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-12 21:16:26', '2026-01-12 21:16:26', '2026-01-12 21:16:26'),
(227, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY4MzA2ODg0LCJleHAiOjE3NjgzOTMyODR9.sJJK5Hhe1-cbtBUmCJ6cxUHjaj_nyjWZMdC-9BGon2k', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-13 12:21:24', '2026-01-13 12:46:49', 0, 'PC', 'Linux PC', 'Firefox 146', 'Linux', '::ffff:127.0.0.1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0', '2026-01-13 12:46:49', '2026-01-13 12:21:24', '2026-01-13 12:46:49'),
(228, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjgzMTA4NzIsImV4cCI6MTc2ODM5NzI3Mn0.fmvHxzgUzEUyIQH-9mtgrZic7xP0YnxekT3V6oVm8gA', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-13 13:27:52', '2026-01-13 15:08:17', 0, 'PC', 'Linux PC', 'Firefox 146', 'Linux', '::ffff:127.0.0.1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0', '2026-01-13 15:08:17', '2026-01-13 13:27:52', '2026-01-13 15:08:17'),
(229, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY4MzEzMjg4LCJleHAiOjE3NjgzOTk2ODh9.0SKHGCugsH1NGpD9CHANWYbWlUKRA31s13oFhp18_WQ', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-13 14:08:08', NULL, 1, 'PC', 'Linux PC', 'Firefox 146', 'Linux', '::ffff:127.0.0.1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0', '2026-01-13 14:08:08', '2026-01-13 14:08:08', '2026-01-13 14:08:08'),
(230, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY4MzE1NTEyLCJleHAiOjE3Njg0MDE5MTJ9.SKPNES_7b_xwqdOkzvtj8mv2qAGkDK9EiD16HCJgSDg', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-13 14:45:12', '2026-01-13 14:52:18', 0, 'PC', 'Linux PC', 'Firefox 146', 'Linux', '::ffff:127.0.0.1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0', '2026-01-13 14:52:18', '2026-01-13 14:45:12', '2026-01-13 14:52:18'),
(231, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjgzMTU5NTMsImV4cCI6MTc2ODQwMjM1M30.SunojHYtwhIilgi07ESg0pFOMNZ_q6Ca8WIOtNCBs6w', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-13 14:52:33', NULL, 1, 'PC', 'Linux PC', 'Firefox 146', 'Linux', '::ffff:127.0.0.1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0', '2026-01-13 14:52:33', '2026-01-13 14:52:33', '2026-01-13 14:52:33'),
(232, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjgzMTYwMzQsImV4cCI6MTc2ODQwMjQzNH0.6zFLS2ZSbUjjYmIUMg44JV3jpkP7lMCxnjcUrBrwj2E', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-13 14:53:54', '2026-01-13 15:12:11', 0, 'PC', 'Linux PC', 'Firefox 146', 'Linux', '::ffff:127.0.0.1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0', '2026-01-13 15:12:11', '2026-01-13 14:53:54', '2026-01-13 15:12:11'),
(233, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjgzMTczNDEsImV4cCI6MTc2ODQwMzc0MX0.uDDVsO0zXKzTAQh5UCMzGnQfhsmPKgzffMoteFMAlZ0', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-13 15:15:41', NULL, 1, 'PC', 'Linux PC', 'Firefox 146', 'Linux', '::ffff:127.0.0.1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0', '2026-01-13 15:15:41', '2026-01-13 15:15:41', '2026-01-13 15:15:41'),
(234, 1, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtcGxveWVlSWQiOjEsImVtYWlsIjoibXVoYW1tYWQuaHVuYWluQGRpZ2lvdXMuY29tIiwibmFtZSI6Ik11aGFtbWFkIEh1bmFpbiIsInJvbGUiOiJQcm9kdWN0aW9uIiwiZGVzaWduYXRpb24iOiJTZW5pb3IgRGV2ZWxvcGVyIiwiaWF0IjoxNzY4MzE4NDQ5LCJleHAiOjE3Njg0MDQ4NDl9._uZNFv_YxohaqKKyHgi1FeGTmtTQRxFdpxNEGZCYETs', 'muhammad.hunain@digious.com', 'Muhammad Hunain', '2026-01-13 15:34:09', '2026-01-13 16:24:21', 0, 'PC', 'Linux PC', 'Firefox 146', 'Linux', '::ffff:127.0.0.1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0', '2026-01-13 16:24:21', '2026-01-13 15:34:09', '2026-01-13 16:24:21'),
(235, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjgzMjE0NzYsImV4cCI6MTc2ODQwNzg3Nn0.pjM6zl7CNz4l6I0ULQ-59sgbRKOxhvga7UXTuD86czY', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-13 16:24:36', '2026-01-13 16:25:12', 0, 'PC', 'Linux PC', 'Firefox 146', 'Linux', '::ffff:127.0.0.1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0', '2026-01-13 16:25:12', '2026-01-13 16:24:36', '2026-01-13 16:25:12'),
(236, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjgzMjE1MzIsImV4cCI6MTc2ODQwNzkzMn0.3wxa5NosougRIUy7f9z5gYLGXgCXhnoRFmceZdXFink', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-13 16:25:32', '2026-01-13 16:28:01', 0, 'PC', 'Linux PC', 'Firefox 146', 'Linux', '::ffff:127.0.0.1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0', '2026-01-13 16:28:01', '2026-01-13 16:25:32', '2026-01-13 16:28:01'),
(237, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjgzMjE2OTUsImV4cCI6MTc2ODQwODA5NX0.kzF0FiUR_fE8KTt1oVQJ2cdAWR21BUqexD7Ls7eSj7Y', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-13 16:28:15', '2026-01-13 16:31:36', 0, 'PC', 'Linux PC', 'Firefox 146', 'Linux', '::ffff:127.0.0.1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0', '2026-01-13 16:31:36', '2026-01-13 16:28:15', '2026-01-13 16:31:36'),
(238, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjgzMjE5MDgsImV4cCI6MTc2ODQwODMwOH0._vjXcw22TThzw2TEvumGs2cmlm9OR11KNrv-2UevgxU', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-13 16:31:48', '2026-01-13 16:52:53', 0, 'PC', 'Linux PC', 'Firefox 146', 'Linux', '::ffff:127.0.0.1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0', '2026-01-13 16:52:53', '2026-01-13 16:31:48', '2026-01-13 16:52:53'),
(239, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjgzMjI3OTYsImV4cCI6MTc2ODQwOTE5Nn0.yjDHQjp4DotYlfvP8VaE-oz7tDx9l8C6Lm8sxrNx5ws', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-13 16:46:36', NULL, 1, 'PC', 'Linux PC', 'Firefox 146', 'Linux', '::ffff:127.0.0.1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0', '2026-01-13 16:46:36', '2026-01-13 16:46:36', '2026-01-13 16:46:36'),
(240, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjgzMjMyMDYsImV4cCI6MTc2ODQwOTYwNn0.OwFO4IwYhLwXl1N3QBQ5dP7Pmjfr7WRaey5CUO9GDmg', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-13 16:53:26', '2026-01-13 17:14:56', 0, 'PC', 'Linux PC', 'Firefox 146', 'Linux', '::ffff:127.0.0.1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0', '2026-01-13 17:14:56', '2026-01-13 16:53:26', '2026-01-13 17:14:56'),
(241, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjgzMjk0NzksImV4cCI6MTc2ODQxNTg3OX0.8ZhHXlqqlPUpMJMuOG_wa23XRLQofeXhDBtwpKvt8Vw', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-13 18:37:59', NULL, 1, 'PC', 'Linux PC', 'Chrome 143', 'Linux', '::1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 18:37:59', '2026-01-13 18:37:59', '2026-01-13 18:37:59'),
(242, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjgzMzAzMTksImV4cCI6MTc2ODQxNjcxOX0.-Wf64DAh7jDqfc2sylJ5JE-JrKUvkPNv9ygJJoLKrvA', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-13 18:51:59', '2026-01-13 19:19:14', 0, 'PC', 'Linux PC', 'Chrome 143', 'Linux', '::1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 19:19:14', '2026-01-13 18:51:59', '2026-01-13 19:19:14'),
(243, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjgzMzIxNTMsImV4cCI6MTc2ODQxODU1M30.Wn6KdCVhsvGKeC6AyjwroFoTtUW077vFtC2Jr8-di1U', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-13 19:22:33', NULL, 1, 'PC', 'Linux PC', 'Chrome 143', 'Linux', '::1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 19:22:33', '2026-01-13 19:22:33', '2026-01-13 19:22:33'),
(244, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3NjgzMzc0MzcsImV4cCI6MTc2ODQyMzgzN30.Lupzlxq08I1XoDDQI1aDTGI5NlA_Fp94UMm4Yhoex4o', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-13 20:50:37', '2026-01-13 21:13:38', 0, 'PC', 'Linux PC', 'Chrome 143', 'Linux', '::1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 21:13:38', '2026-01-13 20:50:37', '2026-01-13 21:13:38'),
(245, 3, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMsImVtcGxveWVlSWQiOjMsImVtYWlsIjoiZmF0aW1hLmtoYW5AZGlnaW91cy5jb20iLCJuYW1lIjoiRmF0aW1hIEtoYW4iLCJyb2xlIjoiSFIiLCJkZXNpZ25hdGlvbiI6IkhSIE1hbmFnZXIiLCJpYXQiOjE3Njg0NzgwOTMsImV4cCI6MTc2ODU2NDQ5M30.bYzLgZDFjGE9GwLMwGXGPgg1UjZR7qSgEzqa6v4s2e4', 'fatima.khan@digious.com', 'Fatima Khan', '2026-01-15 11:54:53', NULL, 1, 'PC', 'Linux PC', 'Chrome 143', 'Linux', '::1', 'localhost', 'N/A', 'Unknown', 'Unknown', 'Asia/Karachi', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-15 11:54:53', '2026-01-15 11:54:53', '2026-01-15 11:54:53');

-- --------------------------------------------------------

--
-- Structure for view `active_users_view`
--
DROP TABLE IF EXISTS `active_users_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `active_users_view`  AS SELECT `usi`.`id` AS `id`, `usi`.`employee_id` AS `employee_id`, `usi`.`email` AS `email`, `usi`.`name` AS `name`, `usi`.`login_time` AS `login_time`, `usi`.`device_type` AS `device_type`, `usi`.`device_name` AS `device_name`, `usi`.`ip_address` AS `ip_address`, `usi`.`hostname` AS `hostname`, `usi`.`mac_address` AS `mac_address`, `usi`.`browser` AS `browser`, `usi`.`os` AS `os`, `usi`.`country` AS `country`, `usi`.`city` AS `city`, `usi`.`last_activity_time` AS `last_activity_time`, timestampdiff(MINUTE,`usi`.`login_time`,current_timestamp()) AS `logged_in_minutes`, `usi`.`is_active` AS `is_active` FROM `user_system_info` AS `usi` WHERE `usi`.`is_active` = 1 ORDER BY `usi`.`login_time` DESC ;

-- --------------------------------------------------------

--
-- Structure for view `Attendance_Summary_View`
--
DROP TABLE IF EXISTS `Attendance_Summary_View`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `Attendance_Summary_View`  AS SELECT `ea`.`employee_id` AS `employee_id`, `ea`.`name` AS `name`, `ea`.`email` AS `email`, `ea`.`attendance_date` AS `attendance_date`, `ea`.`check_in_time` AS `check_in_time`, `ea`.`check_out_time` AS `check_out_time`, `ea`.`status` AS `status`, `ea`.`total_breaks_taken` AS `total_breaks_taken`, `ea`.`total_break_duration_minutes` AS `total_break_duration_minutes`, concat(floor(`ea`.`gross_working_time_minutes` / 60),'h ',`ea`.`gross_working_time_minutes` MOD 60,'m') AS `gross_working_time`, concat(floor(`ea`.`net_working_time_minutes` / 60),'h ',`ea`.`net_working_time_minutes` MOD 60,'m') AS `net_working_time`, `ea`.`overtime_hours` AS `overtime_hours`, `ea`.`on_time` AS `on_time`, `ea`.`late_by_minutes` AS `late_by_minutes`, `ea`.`created_at` AS `created_at`, `ea`.`updated_at` AS `updated_at` FROM `Employee_Attendance` AS `ea` ORDER BY `ea`.`attendance_date` DESC, `ea`.`employee_id` ASC ;

-- --------------------------------------------------------

--
-- Structure for view `Monthly_Attendance_Summary`
--
DROP TABLE IF EXISTS `Monthly_Attendance_Summary`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `Monthly_Attendance_Summary`  AS SELECT `Employee_Attendance`.`employee_id` AS `employee_id`, `Employee_Attendance`.`name` AS `name`, `Employee_Attendance`.`email` AS `email`, year(`Employee_Attendance`.`attendance_date`) AS `year`, month(`Employee_Attendance`.`attendance_date`) AS `month`, count(0) AS `total_days`, sum(case when `Employee_Attendance`.`status` = 'Present' then 1 else 0 end) AS `present_days`, sum(case when `Employee_Attendance`.`status` = 'Absent' then 1 else 0 end) AS `absent_days`, sum(case when `Employee_Attendance`.`status` = 'Late' then 1 else 0 end) AS `late_days`, sum(case when `Employee_Attendance`.`status` = 'On Leave' then 1 else 0 end) AS `leave_days`, round(sum(case when `Employee_Attendance`.`status` = 'Present' then 1 else 0 end) * 100 / count(0),2) AS `attendance_rate`, round(sum(case when `Employee_Attendance`.`on_time` = 1 then 1 else 0 end) * 100 / count(0),2) AS `on_time_rate`, sum(`Employee_Attendance`.`net_working_time_minutes`) AS `total_working_minutes`, sum(`Employee_Attendance`.`overtime_minutes`) AS `total_overtime_minutes`, sum(`Employee_Attendance`.`total_break_duration_minutes`) AS `total_break_minutes` FROM `Employee_Attendance` GROUP BY `Employee_Attendance`.`employee_id`, `Employee_Attendance`.`name`, `Employee_Attendance`.`email`, year(`Employee_Attendance`.`attendance_date`), month(`Employee_Attendance`.`attendance_date`) ;

-- --------------------------------------------------------

--
-- Structure for view `Overtime_Report_View`
--
DROP TABLE IF EXISTS `Overtime_Report_View`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `Overtime_Report_View`  AS SELECT `ea`.`employee_id` AS `employee_id`, `ea`.`name` AS `name`, `ea`.`email` AS `email`, `ea`.`attendance_date` AS `attendance_date`, `ea`.`check_in_time` AS `check_in_time`, `ea`.`check_out_time` AS `check_out_time`, `ea`.`net_working_time_minutes` AS `net_working_time_minutes`, `ea`.`expected_working_time_minutes` AS `expected_working_time_minutes`, `ea`.`overtime_minutes` AS `overtime_minutes`, `ea`.`overtime_hours` AS `overtime_hours`, CASE WHEN `ea`.`overtime_hours` > 0 THEN round(`ea`.`overtime_hours` * 1.5,2) ELSE 0 END AS `overtime_pay_multiplier` FROM `Employee_Attendance` AS `ea` WHERE `ea`.`overtime_minutes` > 0 ORDER BY `ea`.`attendance_date` DESC, `ea`.`overtime_hours` DESC ;

-- --------------------------------------------------------

--
-- Structure for view `user_session_summary`
--
DROP TABLE IF EXISTS `user_session_summary`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `user_session_summary`  AS SELECT `eo`.`id` AS `id`, `eo`.`employee_id` AS `employee_id`, `eo`.`name` AS `name`, `eo`.`email` AS `email`, `eo`.`department` AS `department`, count(case when `usi`.`is_active` = 1 then 1 end) AS `total_active_sessions`, count(case when `usi`.`device_type` = 'PC' and `usi`.`is_active` = 1 then 1 end) AS `pc_sessions`, count(case when `usi`.`device_type` = 'Mobile' and `usi`.`is_active` = 1 then 1 end) AS `mobile_sessions`, count(case when `usi`.`device_type` = 'Tablet' and `usi`.`is_active` = 1 then 1 end) AS `tablet_sessions`, max(`usi`.`login_time`) AS `last_login_time`, group_concat(distinct `usi`.`ip_address` separator ',') AS `all_ip_addresses`, group_concat(distinct `usi`.`device_type` separator ',') AS `all_device_types` FROM (`employee_onboarding` `eo` left join `user_system_info` `usi` on(`eo`.`id` = `usi`.`employee_id`)) GROUP BY `eo`.`id`, `eo`.`employee_id`, `eo`.`name`, `eo`.`email`, `eo`.`department` ;

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `Employee_Attendance`
--
ALTER TABLE `Employee_Attendance`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=255;

--
-- AUTO_INCREMENT for table `Employee_Breaks`
--
ALTER TABLE `Employee_Breaks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=54;

--
-- AUTO_INCREMENT for table `employee_dynamic_resources`
--
ALTER TABLE `employee_dynamic_resources`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `employee_onboarding`
--
ALTER TABLE `employee_onboarding`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `employee_resources`
--
ALTER TABLE `employee_resources`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `employee_salary`
--
ALTER TABLE `employee_salary`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `onboarding_progress`
--
ALTER TABLE `onboarding_progress`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `user_as_employees`
--
ALTER TABLE `user_as_employees`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `user_concurrent_sessions`
--
ALTER TABLE `user_concurrent_sessions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `user_system_info`
--
ALTER TABLE `user_system_info`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=246;

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