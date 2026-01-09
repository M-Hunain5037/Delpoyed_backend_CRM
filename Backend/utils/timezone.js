// ============================================================
// TIMEZONE UTILITY - Pakistan Standard Time (PKT)
// ============================================================
// This file ensures all date/time operations use Pakistan timezone
// Timezone: Asia/Karachi (PKT - UTC+5)
// ============================================================

/**
 * Get current date and time in Pakistan timezone
 * @returns {Date} Date object representing current time in Pakistan
 */
const getPakistanDate = () => {
  // Pakistan is UTC+5
  const now = new Date();
  const utc = now.getTime() + (now.getTimezoneOffset() * 60000);
  const pakistanTime = new Date(utc + (3600000 * 5)); // UTC+5
  return pakistanTime;
};

/**
 * Get current date string in YYYY-MM-DD format (Pakistan timezone)
 * @returns {string} Date string in YYYY-MM-DD format
 */
const getPakistanDateString = () => {
  const date = getPakistanDate();
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
};

/**
 * Get current time string in HH:MM:SS format (Pakistan timezone)
 * @returns {string} Time string in HH:MM:SS format
 */
const getPakistanTimeString = () => {
  const date = getPakistanDate();
  const hours = String(date.getHours()).padStart(2, '0');
  const minutes = String(date.getMinutes()).padStart(2, '0');
  const seconds = String(date.getSeconds()).padStart(2, '0');
  return `${hours}:${minutes}:${seconds}`;
};

/**
 * Get current time in UTC format for database storage
 * Since database timezone is set to +05:00, we need to subtract 5 hours from PKT to get UTC
 * @returns {string} Time string in HH:MM:SS format (UTC)
 */
const getUTCTimeString = () => {
  const now = new Date();
  const hours = String(now.getUTCHours()).padStart(2, '0');
  const minutes = String(now.getUTCMinutes()).padStart(2, '0');
  const seconds = String(now.getUTCSeconds()).padStart(2, '0');
  return `${hours}:${minutes}:${seconds}`;
};

/**
 * Get current datetime in ISO format for Pakistan timezone
 * @returns {string} ISO datetime string (Pakistan timezone)
 */
const getPakistanISO = () => {
  return getPakistanDate().toISOString();
};

/**
 * Get current datetime in MySQL datetime format (Pakistan timezone)
 * @returns {string} MySQL datetime format: YYYY-MM-DD HH:MM:SS
 */
const getPakistanMySQLDateTime = () => {
  const date = getPakistanDate();
  const dateStr = getPakistanDateString();
  const timeStr = getPakistanTimeString();
  return `${dateStr} ${timeStr}`;
};

/**
 * Convert any date to Pakistan timezone
 * @param {Date|string} date - Date to convert
 * @returns {Date} Date in Pakistan timezone
 */
const convertToPakistanTime = (date) => {
  const inputDate = new Date(date);
  const utc = inputDate.getTime() + (inputDate.getTimezoneOffset() * 60000);
  const pakistanTime = new Date(utc + (3600000 * 5)); // UTC+5
  return pakistanTime;
};

/**
 * Format date to local date string in Pakistan timezone
 * @param {Date|string} date - Date to format
 * @returns {string} Date string in YYYY-MM-DD format
 */
const formatPakistanDate = (date) => {
  const pkDate = convertToPakistanTime(date);
  const year = pkDate.getFullYear();
  const month = String(pkDate.getMonth() + 1).padStart(2, '0');
  const day = String(pkDate.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
};

/**
 * Get yesterday's date in Pakistan timezone
 * @returns {Date} Yesterday's date in Pakistan timezone
 */
const getPakistanYesterday = () => {
  const today = getPakistanDate();
  const yesterday = new Date(today);
  yesterday.setDate(yesterday.getDate() - 1);
  return yesterday;
};

/**
 * Get yesterday's date string in YYYY-MM-DD format (Pakistan timezone)
 * @returns {string} Yesterday's date string
 */
const getPakistanYesterdayString = () => {
  const yesterday = getPakistanYesterday();
  const year = yesterday.getFullYear();
  const month = String(yesterday.getMonth() + 1).padStart(2, '0');
  const day = String(yesterday.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
};

/**
 * Convert UTC time string (HH:MM:SS) to Pakistan time string (HH:MM:SS)
 * Database stores times in UTC, this function converts them for display
 * @param {string} utcTimeString - Time string in HH:MM:SS format (UTC)
 * @returns {string} Time string in HH:MM:SS format (Pakistan timezone - UTC+5)
 */
const convertUTCTimeToPakistani = (utcTimeString) => {
  if (!utcTimeString) return null;
  
  try {
    const [hours, minutes, seconds] = utcTimeString.split(':').map(Number);
    
    // Create a date with the UTC time
    const utcDate = new Date(Date.UTC(2000, 0, 1, hours, minutes, seconds));
    
    // Add 5 hours to convert from UTC to Pakistan time (UTC+5)
    const pakistanDate = new Date(utcDate.getTime() + (5 * 3600000)); // 5 hours in milliseconds
    
    // Handle day overflow (if adding 5 hours goes past midnight)
    // We only care about the time portion, so if it goes to next day, that's fine for display
    
    const pkHours = String(pakistanDate.getUTCHours()).padStart(2, '0');
    const pkMinutes = String(pakistanDate.getUTCMinutes()).padStart(2, '0');
    const pkSeconds = String(pakistanDate.getUTCSeconds()).padStart(2, '0');
    
    return `${pkHours}:${pkMinutes}:${pkSeconds}`;
  } catch (error) {
    console.error('Error converting UTC time to Pakistan time:', error);
    return utcTimeString; // Return original if conversion fails
  }
};

module.exports = {
  getPakistanDate,
  getPakistanDateString,
  getPakistanTimeString,
  getUTCTimeString,
  getPakistanISO,
  getPakistanMySQLDateTime,
  convertToPakistanTime,
  formatPakistanDate,
  getPakistanYesterday,
  getPakistanYesterdayString,
  convertUTCTimeToPakistani
};
