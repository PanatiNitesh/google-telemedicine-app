require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bodyParser = require('body-parser');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const multer = require('multer');

const app = express();
const PORT = process.env.PORT || 5000;

// Set server timeout
app.timeout = 60000; // 60 seconds timeout

// JWT Secret - should be in an environment variable in production
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

// Middleware
app.use(cors({
  origin: process.env.FRONTEND_URL || '*', 
  credentials: true
}));
app.use(bodyParser.json({ limit: '10mb' }));
app.use(bodyParser.urlencoded({ limit: '10mb', extended: true }));

// Request timeout middleware
app.use((req, res, next) => {
  res.setTimeout(30000, () => {
    console.log('Request has timed out.');
    if (!res.headersSent) {
      res.status(408).send('Request Timeout');
    }
  });
  next();
});

// Configure multer for file uploads
const storage = multer.memoryStorage();
const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter: (req, file, cb) => {
    // Properly implemented file filter
    if (file.mimetype.startsWith('image/')) {
      console.log('Valid image file received:', file.originalname);
      cb(null, true);
    } else {
      console.log('Invalid file type rejected:', file.mimetype);
      cb(new Error('Only image files are allowed!'), false);
    }
  }
});

// MongoDB Connection with timeout settings
mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  dbName: 'hack2skills-telemedicine',
  serverSelectionTimeoutMS: 5000, // 5 seconds timeout for server selection
  socketTimeoutMS: 45000, // 45 seconds timeout for socket operations
  connectTimeoutMS: 10000 // 10 seconds timeout for initial connection
})
  .then(() => console.log('Connected to MongoDB: hack2skills-telemedicine'))
  .catch(err => console.error('MongoDB connection error:', err));

// MongoDB connection error handler
mongoose.connection.on('error', (err) => {
  console.error('MongoDB connection error:', err);
});

// User Schema
const userSchema = new mongoose.Schema({
  firstName: { type: String, required: true },
  lastName: { type: String, required: true },
  gender: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  phoneNumber: { type: String, required: true },
  dateOfBirth: { type: String, required: true },
  address: { type: String, required: true },
  country: { type: String, required: true },
  state: { type: String, required: true },
  governmentId: { type: String, required: true },
  profileImage: { type: Buffer, required: false },
  password: { type: String, required: true },
  createdAt: { type: Date, default: Date.now }
});

// User Model
const User = mongoose.model('RegisteredUser', userSchema);

// Registration Route with error handling
app.post('/api/register', (req, res) => {
  console.log('Registration request received');
  
  // Use multer middleware with error handling
  upload.single('profileImage')(req, res, async (err) => {
    // Handle multer errors
    if (err) {
      console.error('File upload error:', err.message);
      return res.status(400).json({ success: false, message: `File upload error: ${err.message}` });
    }
    
    try {
      console.log('Processing registration data:', {
        ...req.body,
        password: '[REDACTED]',
        hasImage: !!req.file
      });

      const {
        firstName,
        lastName,
        gender,
        email,
        phoneNumber,
        dateOfBirth,
        address,
        country,
        state,
        governmentId,
        password
      } = req.body;

      // Validate required fields
      if (!firstName || !lastName || !gender || !email || !phoneNumber || !dateOfBirth || 
          !address || !country || !state || !governmentId || !password) {
        console.error('Missing required fields');
        return res.status(400).json({ success: false, message: 'All fields are required' });
      }

      // Check if user already exists
      console.log('Checking if email exists:', email);
      const existingUser = await User.findOne({ email });
      if (existingUser) {
        console.error('Email already registered:', email);
        return res.status(400).json({ success: false, message: 'Email already registered' });
      }

      // Hash password
      console.log('Hashing password');
      const saltRounds = 10;
      const hashedPassword = await bcrypt.hash(password, saltRounds);

      // Create new user with image (if provided)
      console.log('Creating new user');
      const newUser = new User({
        firstName,
        lastName,
        gender,
        email,
        phoneNumber,
        dateOfBirth,
        address,
        country,
        state,
        governmentId,
        profileImage: req.file ? req.file.buffer : null,
        password: hashedPassword
      });

      console.log('Saving user to database');
      await newUser.save();
      console.log('User registered successfully:', newUser.email);
      res.status(201).json({ success: true, message: 'Registration successful' });
    } catch (error) {
      console.error('Registration error:', error);
      res.status(500).json({ success: false, message: `Server error: ${error.message}` });
    }
  });
});

// Login Route - Step 1: Check if user exists
app.post('/api/login', async (req, res) => {
  try {
    console.log('Received login data:', req.body);

    const { username } = req.body;

    if (!username) {
      console.error('Missing username');
      return res.status(400).json({ success: false, message: 'Username is required' });
    }

    // Find user by email or username
    const user = await User.findOne({
      $or: [
        { email: username },
        { firstName: username }
      ]
    });

    if (!user) {
      console.error('User not found:', username);
      return res.status(401).json({
        success: false,
        message: 'User not found'
      });
    }

    console.log('User found:', user.email);

    // Return user information for password page
    res.status(200).json({
      success: true,
      message: 'User found',
      user: {
        id: user._id,
        firstName: user.firstName,
        profileImage: user.profileImage ? user.profileImage.toString('base64') : null
      }
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ success: false, message: `Server error: ${error.message}` });
  }
});

// Login Route - Step 2: Verify Password
app.post('/api/verify-password', async (req, res) => {
  try {
    console.log('Received password verification data');

    const { userId, password } = req.body;

    if (!userId || !password) {
      console.error('Missing required fields');
      return res.status(400).json({ success: false, message: 'User ID and password are required' });
    }

    // Find user by ID
    const user = await User.findById(userId);

    if (!user) {
      console.error('User not found:', userId);
      return res.status(401).json({
        success: false,
        message: 'User not found'
      });
    }

    // Compare password
    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      console.error('Invalid password for user:', user.email);
      return res.status(401).json({
        success: false,
        message: 'Invalid password'
      });
    }

    // Generate JWT token
    const token = jwt.sign(
      {
        userId: user._id,
        email: user.email
      },
      JWT_SECRET,
      { expiresIn: '1h' }
    );

    console.log('Login successful for user:', user.email);

    // Return user data and token
    res.status(200).json({
      success: true,
      message: 'Login successful',
      token,
      user: {
        id: user._id,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        profileImage: user.profileImage ? user.profileImage.toString('base64') : null
      }
    });

  } catch (error) {
    console.error('Password verification error:', error);
    res.status(500).json({ success: false, message: `Server error: ${error.message}` });
  }
});

// Social Sign-in Routes
app.post('/api/login/google', (req, res) => {
  console.log('Google login request received:', req.body);
  res.status(200).json({ success: true, message: 'Google login successful' });
});

app.post('/api/login/microsoft', (req, res) => {
  console.log('Microsoft login request received:', req.body);
  res.status(200).json({ success: true, message: 'Microsoft login successful' });
});

app.post('/api/login/apple', (req, res) => {
  console.log('Apple login request received:', req.body);
  res.status(200).json({ success: true, message: 'Apple login successful' });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'Server is running',
    mongoConnection: mongoose.connection.readyState === 1 ? 'connected' : 'disconnected'
  });
});

// Error handler middleware
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({
    success: false,
    message: 'Server encountered an error',
    error: process.env.NODE_ENV === 'production' ? null : err.message
  });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});