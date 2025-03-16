require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bodyParser = require('body-parser');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const multer = require('multer'); // For file uploads

const app = express();
const PORT = process.env.PORT || 5000;

// JWT Secret - should be in an environment variable in production
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key'; // Fallback for development

// Middleware
app.use(cors({
  origin: process.env.FRONTEND_URL, // Allow all origins (update for production)
  methods: ["GET", "POST"],
  credentials: true
}));
app.use(bodyParser.json());

// Configure multer for file uploads (store in memory before saving to MongoDB)
const storage = multer.memoryStorage();
const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // Limit file size to 5MB
  fileFilter: (req, file, cb) => {
    // Accept only image files
    const fileFilter = (req, file, cb) => {
      console.log('File details:', file);
      cb(null, true); // Temporarily allow all files
    }
  }
});

// MongoDB Connection
mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  dbName: 'hack2skills-telemedicine' // Specify the database name
})
  .then(() => console.log('Connected to MongoDB: hack2skills-telemedicine'))
  .catch(err => console.error('MongoDB connection error:', err));

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
  profileImage: { type: Buffer, required: false }, // Store image as binary data
  password: { type: String, required: true },
  createdAt: { type: Date, default: Date.now }
});

// User Model
const User = mongoose.model('RegisteredUser', userSchema);

// Registration Route with Image Upload
app.post('/api/register', upload.single('profileImage'), async (req, res) => {
  try {
    // Log received fields from the frontend
    console.log('Received registration data:', req.body);

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
    if (!firstName || !lastName || !gender || !email || !phoneNumber || !dateOfBirth || !address || !country || !state || !governmentId || !password) {
      console.error('Missing required fields:', req.body);
      return res.status(400).json({ success: false, message: 'All fields are required' });
    }

    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      console.error('Email already registered:', email);
      return res.status(400).json({ success: false, message: 'Email already registered' });
    }

    // Hash password
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Create new user with image (if provided)
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
      profileImage: req.file ? req.file.buffer : null, // Store image as binary data
      password: hashedPassword
    });

    await newUser.save();
    console.log('User registered successfully:', newUser.email);
    res.status(201).json({ success: true, message: 'Registration successful' });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// Login Route - Step 1: Check if user exists
app.post('/api/login', async (req, res) => {
  try {
    // Log received fields from the frontend
    console.log('Received login data:', req.body);

    const { username } = req.body;

    // Validate required fields
    if (!username) {
      console.error('Missing username:', req.body);
      return res.status(400).json({ success: false, message: 'Username is required' });
    }

    // Find user by email or username
    const user = await User.findOne({
      $or: [
        { email: username },
        { firstName: username }
      ]
    });

    // If user not found
    if (!user) {
      console.error('User not found:', username);
      return res.status(401).json({
        success: false,
        message: 'User not found'
      });
    }

    // Log user data being sent to the frontend
    console.log('User found:', user.email);

    // Return user information for password page (excluding image for now)
    res.status(200).json({
      success: true,
      message: 'User found',
      user: {
        id: user._id,
        firstName: user.firstName,
        profileImage: user.profileImage ? user.profileImage.toString('base64') : null // Convert Buffer to base64
      }
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// Login Route - Step 2: Verify Password
app.post('/api/verify-password', async (req, res) => {
  try {
    // Log received fields from the frontend
    console.log('Received password verification data:', req.body);

    const { userId, password } = req.body;

    // Validate required fields
    if (!userId || !password) {
      console.error('Missing required fields:', req.body);
      return res.status(400).json({ success: false, message: 'User ID and password are required' });
    }

    // Find user by ID
    const user = await User.findById(userId);

    // If user not found
    if (!user) {
      console.error('User not found:', userId);
      return res.status(401).json({
        success: false,
        message: 'User not found'
      });
    }

    // Compare password with hashed password in database
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

    // Log user data being sent to the frontend
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
        email: user.email
      }
    });

  } catch (error) {
    console.error('Password verification error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
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

// Health check route
app.get('/api/health', (req, res) => {
  console.log('Health check request received');
  res.status(200).json({ status: 'Server is running' });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});