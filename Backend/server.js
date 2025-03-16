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

// JWT Secret - should be in an environment variable in production
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

// Middleware
app.use(cors({
  origin: "*",
  methods: ["GET", "POST"],
  credentials: true
}));
app.use(bodyParser.json());

// Increase server timeout to 120 seconds
app.use((req, res, next) => {
  req.setTimeout(120000);
  res.setTimeout(120000);
  next();
});

// Configure multer for file uploads (store in memory before saving to MongoDB)
const storage = multer.memoryStorage();
const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // Limit file size to 5MB
  fileFilter: (req, file, cb) => {
    const filetypes = /jpeg|jpg|png/;
    const mimetype = filetypes.test(file.mimetype);
    if (mimetype) {
      return cb(null, true);
    }
    cb(new Error('Only JPEG, JPG, and PNG images are allowed'));
  }
});

// MongoDB Connection
mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  dbName: 'hack2skills-telemedicine'
})
  .then(() => console.log('Connected to MongoDB'))
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
  profileImage: { type: Buffer, required: false },
  password: { type: String, required: true },
  createdAt: { type: Date, default: Date.now }
});

// User Model
const User = mongoose.model('RegisteredUser', userSchema);

// Registration Route with Image Upload
app.post('/api/register', upload.single('profileImage'), async (req, res) => {
  console.log('Received registration request:', req.body);
  if (req.file) {
    console.log('Uploaded file:', {
      originalname: req.file.originalname,
      size: req.file.size,
      mimetype: req.file.mimetype
    });
  }
  try {
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

    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      console.log('Email already registered:', email);
      return res.status(400).json({ success: false, message: 'Email already registered' });
    }

    // Hash password
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);
    console.log('Password hashed successfully');

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
      profileImage: req.file ? req.file.buffer : null,
      password: hashedPassword
    });

    await newUser.save();
    console.log('User registered successfully:', newUser.email);
    res.status(201).json({ success: true, message: 'Registration successful' });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

// Login Route - Step 1: Check if user exists
app.post('/api/login', async (req, res) => {
  console.log('Received login request:', req.body);
  try {
    const { username } = req.body;

    const user = await User.findOne({
      $or: [
        { email: username },
        { firstName: username }
      ]
    });

    if (!user) {
      console.log('User not found:', username);
      return res.status(401).json({
        success: false,
        message: 'User not found'
      });
    }

    console.log('User found:', user.email);
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
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

// Login Route - Step 2: Verify Password
app.post('/api/verify-password', async (req, res) => {
  console.log('Received verify-password request:', req.body);
  try {
    const { userId, password } = req.body;

    const user = await User.findById(userId);

    if (!user) {
      console.log('User not found by ID:', userId);
      return res.status(401).json({
        success: false,
        message: 'User not found'
      });
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      console.log('Invalid password for user:', user.email);
      return res.status(401).json({
        success: false,
        message: 'Invalid password'
      });
    }

    const token = jwt.sign(
      {
        userId: user._id,
        email: user.email
      },
      JWT_SECRET,
      { expiresIn: '1h' }
    );

    console.log('Login successful for user:', user.email);
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
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

// Social Sign-in Routes (placeholders)
app.post('/api/login/google', (req, res) => {
  console.log('Google login request received');
  res.status(200).json({ success: true, message: 'Google login successful' });
});

app.post('/api/login/microsoft', (req, res) => {
  console.log('Microsoft login request received');
  res.status(200).json({ success: true, message: 'Microsoft login successful' });
});

app.post('/api/login/apple', (req, res) => {
  console.log('Apple login request received');
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