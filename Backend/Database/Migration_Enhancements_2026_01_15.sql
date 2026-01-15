SET FOREIGN_KEY_CHECKS = 1;
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

ALTER TABLE `employee_allowances`
ADD COLUMN `currency` VARCHAR(10) DEFAULT 'PKR' AFTER `allowance_amount`;

ALTER TABLE `employee_allowances`
ADD COLUMN `exchange_rate` DECIMAL(10, 4) DEFAULT 1.0000 AFTER `currency`;

UPDATE `employee_allowances`
SET `currency` = 'PKR', `exchange_rate` = 278.0
WHERE `currency` = 'PKR' OR `currency` IS NULL OR `currency` = '';

ALTER TABLE `employee_onboarding`
ADD COLUMN `account_title_name` VARCHAR(255) DEFAULT NULL AFTER `bank_account`;

ALTER TABLE `employee_onboarding`
ADD COLUMN `bank_name` VARCHAR(100) DEFAULT NULL AFTER `account_title_name`;

CREATE TABLE IF NOT EXISTS `employee_bank_accounts` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `employee_id` INT(11) NOT NULL,
  `account_number` VARCHAR(50) NOT NULL,
  `account_title_name` VARCHAR(255) NOT NULL,
  `bank_name` VARCHAR(100) NOT NULL,
  `bank_code` VARCHAR(10) DEFAULT NULL,
  `branch_code` VARCHAR(10) DEFAULT NULL,
  `account_type` ENUM('Savings', 'Current', 'Fixed Deposit') DEFAULT 'Savings',
  `is_primary` TINYINT(1) DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`),
  FOREIGN KEY (`employee_id`) REFERENCES `employee_onboarding`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  UNIQUE KEY `unique_account_per_employee` (`employee_id`, `account_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

ALTER TABLE `employee_onboarding`
ADD COLUMN `confirmation_date` DATE DEFAULT NULL AFTER `join_date`;

ALTER TABLE `employee_onboarding`
ADD COLUMN `employment_status` ENUM('Probation', 'Part-Time', 'Intern', 'MTO', 'Permanent')
DEFAULT 'Probation' AFTER `sub_department`;

ALTER TABLE `employee_onboarding`
ADD COLUMN `cnic_issue_date` DATE DEFAULT NULL AFTER `cnic`;

ALTER TABLE `employee_onboarding`
ADD COLUMN `cnic_expiry_date` DATE DEFAULT NULL AFTER `cnic_issue_date`;

ALTER TABLE `user_as_employees`
ADD COLUMN `employment_status` ENUM('Probation', 'Part-Time', 'Intern', 'MTO', 'Permanent') DEFAULT 'Probation' AFTER `position`;

ALTER TABLE `user_as_employees`
ADD COLUMN `confirmation_date` DATE DEFAULT NULL AFTER `department`;

ALTER TABLE `user_as_employees`
ADD COLUMN `account_title_name` VARCHAR(255) DEFAULT NULL;

ALTER TABLE `user_as_employees`
ADD COLUMN `bank_name` VARCHAR(100) DEFAULT NULL;

ALTER TABLE `user_as_employees`
ADD COLUMN `cnic_issue_date` DATE DEFAULT NULL;

ALTER TABLE `user_as_employees`
ADD COLUMN `cnic_expiry_date` DATE DEFAULT NULL;

DELIMITER $$
DROP TRIGGER IF EXISTS `after_employee_insert` $$
CREATE TRIGGER `after_employee_insert` AFTER INSERT ON `employee_onboarding` FOR EACH ROW BEGIN
    INSERT INTO user_as_employees (
        employee_id,
        name,
        email,
        password,
        department,
        position,
        employment_status,
        designation,
        confirmation_date,
        account_title_name,
        bank_name,
        cnic_issue_date,
        cnic_expiry_date,
        status,
        request_password_change,
        created_at,
        updated_at
    ) VALUES (
        NEW.id,
        NEW.name,
        NEW.email,
        NEW.password_temp,
        NEW.department,
        NEW.sub_department,
        NEW.employment_status,
        NEW.designation,
        NEW.confirmation_date,
        NEW.account_title_name,
        NEW.bank_name,
        NEW.cnic_issue_date,
        NEW.cnic_expiry_date,
        NEW.status,
        TRUE,
        NOW(),
        NOW()
    )
    ON DUPLICATE KEY UPDATE
        name = VALUES(name),
        email = VALUES(email),
        password = VALUES(password),
        department = VALUES(department),
        position = VALUES(position),
        employment_status = VALUES(employment_status),
        designation = VALUES(designation),
        confirmation_date = VALUES(confirmation_date),
        account_title_name = VALUES(account_title_name),
        bank_name = VALUES(bank_name),
        cnic_issue_date = VALUES(cnic_issue_date),
        cnic_expiry_date = VALUES(cnic_expiry_date),
        status = VALUES(status),
        updated_at = NOW();
END
$$
DELIMITER ;

DELIMITER $$
DROP TRIGGER IF EXISTS `after_employee_update` $$
CREATE TRIGGER `after_employee_update` AFTER UPDATE ON `employee_onboarding` FOR EACH ROW BEGIN
    UPDATE user_as_employees
    SET
        name = NEW.name,
        email = NEW.email,
        department = NEW.department,
        position = NEW.sub_department,
        employment_status = NEW.employment_status,
        designation = NEW.designation,
        confirmation_date = NEW.confirmation_date,
        account_title_name = NEW.account_title_name,
        bank_name = NEW.bank_name,
        cnic_issue_date = NEW.cnic_issue_date,
        cnic_expiry_date = NEW.cnic_expiry_date,
        status = NEW.status,
        updated_at = NOW()
    WHERE employee_id = NEW.id;
END
$$
DELIMITER ;

UPDATE `employee_onboarding`
SET
    `employment_status` = 'Permanent',
    `confirmation_date` = DATE_ADD(`join_date`, INTERVAL 3 MONTH),
    `account_title_name` = CONCAT(name, ' (Main Account)'),
    `bank_name` = 'HBL',
    `cnic_issue_date` = DATE_SUB(NOW(), INTERVAL 5 YEAR),
    `cnic_expiry_date` = DATE_ADD(NOW(), INTERVAL 5 YEAR)
WHERE `employment_status` IS NULL AND id IN (1, 2, 3, 4, 5);

UPDATE `employee_onboarding`
SET
    `employment_status` = 'MTO',
    `confirmation_date` = DATE_ADD(`join_date`, INTERVAL 6 MONTH)
WHERE id IN (12, 13) AND `employment_status` IS NULL;

UPDATE `employee_onboarding`
SET
    `employment_status` = 'Intern',
    `confirmation_date` = DATE_ADD(`join_date`, INTERVAL 3 MONTH)
WHERE id IN (14, 15) AND `employment_status` IS NULL;

UPDATE `employee_onboarding`
SET
    `employment_status` = 'Part-Time',
    `confirmation_date` = NULL
WHERE id IN (16, 17) AND `employment_status` IS NULL;

UPDATE `employee_onboarding`
SET
    `account_title_name` = CONCAT(name, ' (Main Account)'),
    `bank_name` = 'HBL'
WHERE (`account_title_name` IS NULL OR `bank_name` IS NULL) AND bank_account IS NOT NULL;

UPDATE `employee_onboarding`
SET
    `cnic_issue_date` = DATE_SUB(NOW(), INTERVAL 5 YEAR),
    `cnic_expiry_date` = DATE_ADD(NOW(), INTERVAL 5 YEAR)
WHERE `cnic_issue_date` IS NULL AND cnic IS NOT NULL;

INSERT INTO `employee_bank_accounts` (`employee_id`, `account_number`, `account_title_name`, `bank_name`, `bank_code`, `branch_code`, `account_type`, `is_primary`, `created_at`)
VALUES
(1, 'PKRIBAN123456', 'Muhammad Hunain', 'HBL', '0063', 'KHI001', 'Savings', 1, NOW()),
(2, 'PKRIBAN654321', 'Ahmed Ali', 'UBL', '0070', 'KHI002', 'Savings', 1, NOW()),
(3, 'PKRIBAN789012', 'Fatima Khan', 'MCB', '0009', 'KHI003', 'Current', 1, NOW()),
(4, 'PKRIBAN345678', 'Hassan Raza', 'Allied Bank', '0074', 'KHI004', 'Savings', 1, NOW()),
(5, 'PKRIBAN901234', 'Sara Ahmed', 'NBP', '0015', 'KHI005', 'Savings', 1, NOW())
ON DUPLICATE KEY UPDATE `updated_at` = NOW();

UPDATE `employee_allowances`
SET `currency` = 'PKR', `exchange_rate` = 278.0
WHERE `currency` IS NULL OR `currency` = '';

UPDATE `employee_onboarding`
SET `employment_status` = 'Probation'
WHERE `employment_status` IS NULL;

UPDATE `employee_onboarding`
SET `confirmation_date` = DATE_ADD(`join_date`, INTERVAL 3 MONTH)
WHERE `confirmation_date` IS NULL
  AND `employment_status` IN ('Permanent', 'Intern', 'Probation');

UPDATE `employee_onboarding`
SET `confirmation_date` = DATE_ADD(`join_date`, INTERVAL 6 MONTH)
WHERE `confirmation_date` IS NULL
  AND `employment_status` = 'MTO';

INSERT INTO user_as_employees (
    employee_id, name, email, password, department, position, employment_status, designation,
    confirmation_date, account_title_name, bank_name, cnic_issue_date, cnic_expiry_date, status,
    request_password_change, created_at, updated_at
)
SELECT
    eo.id, eo.name, eo.email, eo.password_temp, eo.department, eo.sub_department, eo.employment_status, eo.designation,
    eo.confirmation_date, eo.account_title_name, eo.bank_name, eo.cnic_issue_date, eo.cnic_expiry_date, eo.status,
    TRUE, NOW(), NOW()
FROM employee_onboarding eo
WHERE NOT EXISTS (SELECT 1 FROM user_as_employees u WHERE u.employee_id = eo.id);

INSERT INTO employee_bank_accounts (employee_id, account_number, account_title_name, bank_name, account_type, is_primary, created_at)
SELECT
    eo.id, eo.bank_account, COALESCE(eo.account_title_name, CONCAT(eo.name, ' (Main Account)')), COALESCE(eo.bank_name, 'HBL'), 'Savings', 1, NOW()
FROM employee_onboarding eo
LEFT JOIN employee_bank_accounts ba ON ba.employee_id = eo.id
WHERE eo.bank_account IS NOT NULL AND ba.id IS NULL;

ALTER TABLE `employee_onboarding`
ADD INDEX `idx_employment_status` (`employment_status`),
ADD INDEX `idx_confirmation_date` (`confirmation_date`),
ADD INDEX `idx_bank_name` (`bank_name`),
ADD INDEX `idx_cnic_dates` (`cnic_issue_date`, `cnic_expiry_date`);

ALTER TABLE `employee_bank_accounts`
ADD INDEX `idx_employee_id` (`employee_id`),
ADD INDEX `idx_is_primary` (`is_primary`);

ALTER TABLE `employee_allowances`
ADD INDEX `idx_currency` (`currency`);

DROP VIEW IF EXISTS `employee_allowances_in_pkr`;
CREATE VIEW `employee_allowances_in_pkr` AS
SELECT
    ea.id,
    ea.employee_id,
    eo.name AS employee_name,
    eo.email,
    ea.allowance_name,
    ea.allowance_amount,
    ea.currency,
    ROUND(ea.allowance_amount * ea.exchange_rate, 2) AS amount_in_pkr,
    ea.exchange_rate,
    ea.created_at
FROM `employee_allowances` ea
LEFT JOIN `employee_onboarding` eo ON ea.employee_id = eo.id
ORDER BY ea.employee_id;

SELECT 'WARNING: CNIC with no expiry date' AS check_type, COUNT(*) AS count
FROM `employee_onboarding`
WHERE cnic IS NOT NULL AND cnic_expiry_date IS NULL;

SELECT 'ERROR: Confirmation date before join date' AS check_type, id, name, join_date, confirmation_date
FROM `employee_onboarding`
WHERE confirmation_date IS NOT NULL AND confirmation_date < join_date;

SELECT 'WARNING: Missing bank details' AS check_type, COUNT(*) AS count
FROM `employee_onboarding`
WHERE bank_account IS NULL OR account_title_name IS NULL OR bank_name IS NULL;

SELECT 'INFO: Allowance currency distribution' AS check_type, currency, COUNT(*) AS count
FROM `employee_allowances`
GROUP BY currency;

SHOW CREATE TABLE `employee_onboarding`;
SHOW CREATE TABLE `employee_bank_accounts`;
SHOW CREATE TABLE `employee_allowances`;

SELECT
    'employee_onboarding' AS table_name, COUNT(*) AS total_records
FROM `employee_onboarding`
UNION ALL
SELECT
    'employee_bank_accounts', COUNT(*)
FROM `employee_bank_accounts`
UNION ALL
SELECT
    'employee_allowances', COUNT(*)
FROM `employee_allowances`;

COMMIT;

