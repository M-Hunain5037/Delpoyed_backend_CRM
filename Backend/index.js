const express = require('express');
const cors = require('cors');
require('dotenv').config();
const { getPakistanISO } = require('./utils/timezone');

const app = express();

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// CORS Configuration
const corsOptions = {
  origin: function (origin, callback) {
    // Base allowed origins - always allow localhost for development
    const allowedOrigins = [
      'http://localhost:3000',
      'http://localhost:5000',
      'http://127.0.0.1:3000',
      'http://127.0.0.1:5000'
    ];

    // Add environment-specific origins from .env
    const envOrigins = process.env.CORS_ORIGINS 
      ? process.env.CORS_ORIGINS.split(',').map(origin => origin.trim())
      : [];
    
    const allAllowedOrigins = [...allowedOrigins, ...envOrigins];

    console.log('🔐 CORS Check - Origin:', origin);
    console.log('✅ Allowed Origins:', allAllowedOrigins);

    // Allow requests with no origin (like mobile apps or curl requests)
    // Also allow any origin that matches our allowlist
    if (!origin || allAllowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      console.error('❌ CORS Blocked - Origin not in allowlist:', origin);
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  maxAge: 86400 // 24 hours
};

app.use(cors(corsOptions));

// Test route
app.get('/api/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Server is running',
    timestamp: getPakistanISO()
  });
});

// Routes
const onboardingRoutes = require('./routes/onboarding');
const authRoutes = require('./routes/auth');
const userSystemInfoRoutes = require('./routes/userSystemInfo');
const attendanceRoutes = require('./routes/attendance');
const rulesRoutes = require('./routes/rules');
const activitiesRoutes = require('./routes/activities');

app.use(`/api/${process.env.API_VERSION}`, onboardingRoutes);
app.use(`/api/${process.env.API_VERSION}/auth`, authRoutes);
app.use(`/api/${process.env.API_VERSION}/system-info`, userSystemInfoRoutes);
app.use(`/api/${process.env.API_VERSION}/attendance`, attendanceRoutes);
app.use(`/api/${process.env.API_VERSION}/activities`, activitiesRoutes);
app.use(`/api/${process.env.API_VERSION}/rules`, rulesRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found'
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`
╔════════════════════════════════════════╗
║   Digious CRM Backend Server Started   ║
║   🚀 Running on: http://localhost:${PORT}    ║
║   📊 Environment: ${process.env.NODE_ENV}       ║
╚════════════════════════════════════════╝
  `);
});
