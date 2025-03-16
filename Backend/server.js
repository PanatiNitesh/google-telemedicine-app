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
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

// Middleware
app.use(cors({
  origin: (origin, callback) => {
    if (!origin || origin.startsWith('http://localhost') || origin.startsWith('http://127.0.0.1')) {
      callback(null, true);
    } else if (process.env.FRONTEND_URL && origin === process.env.FRONTEND_URL) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  methods: ['GET', 'POST'],
  credentials: true
}));
app.use(bodyParser.json());

// Configure multer for file uploads
const storage = multer.memoryStorage();
const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const fileTypes = /jpeg|jpg|png/;
    const extname = fileTypes.test(file.originalname.toLowerCase());
    const mimetype = fileTypes.test(file.mimetype);
    if (extname && mimetype) {
      console.log('File accepted:', file.originalname);
      cb(null, true);
    } else {
      console.error('Invalid file type:', file.originalname);
      cb(null, false);
    }
  }
}).single('profileImage');

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

const User = mongoose.model('RegisteredUser', userSchema);

// MongoDB Connection and Server Start
async function startServer() {
  try {
    await mongoose.connect(process.env.MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      dbName: 'hack2skills-telemedicine',
      serverSelectionTimeoutMS: 5000 // Reduce timeout to fail faster if MongoDB is down
    });
    console.log('Connected to MongoDB: hack2skills-telemedicine');

    // Registration Route with Image Upload
    app.post('/api/register', (req, res) => {
      upload(req, res, async (err) => {
        if (err) {
          console.error('Multer error:', err.message);
          return res.status(400).json({ success: false, message: err.message });
        }

        try {
          console.log('Received registration data:', req.body);
          console.log('Received file:', req.file ? req.file.originalname : 'No file');

          const {
            firstName, lastName, gender, email, phoneNumber, dateOfBirth, address, country, state, governmentId, password
          } = req.body;

          if (!firstName || !lastName || !gender || !email || !phoneNumber || !dateOfBirth || !address || !country || !state || !governmentId || !password) {
            console.error('Missing required fields:', req.body);
            return res.status(400).json({ success: false, message: 'All fields are required' });
          }

          const existingUser = await User.findOne({ email });
          if (existingUser) {
            console.error('Email already registered:', email);
            return res.status(400).json({ success: false, message: 'Email already registered' });
          }

          const saltRounds = 10;
          const hashedPassword = await bcrypt.hash(password, saltRounds);

          const newUser = new User({
            firstName, lastName, gender, email, phoneNumber, dateOfBirth, address, country, state, governmentId,
            profileImage: req.file ? req.file.buffer : null,
            password: hashedPassword
          });

          await newUser.save();
          console.log('User registered successfully:', newUser.email);
          res.status(201).json({ success: true, message: 'Registration successful' });
        } catch (error) {
          console.error('Registration error:', error.message, error.stack);
          res.status(500).json({ success: false, message: 'Server error: ' + error.message });
        }
      });
    });

    // Login Route - Step 1: Check if user exists
    app.post('/api/login', async (req, res) => {
      try {
        console.log('Received login data:', req.body);
        const { username } = req.body;

        if (!username) {
          console.error('Missing username:', req.body);
          return res.status(400).json({ success: false, message: 'Username is required' });
        }

        const user = await User.findOne({ $or: [{ email: username }, { firstName: username }] });
        if (!user) {
          console.error('User not found:', username);
          return res.status(401).json({ success: false, message: 'User not found' });
        }

        console.log('User found:', user.email);
        res.status(200).json({
          success: true,
          message: 'User found',
          user: { id: user._id, firstName: user.firstName, profileImage: user.profileImage ? user.profileImage.toString('base64') : null }
        });
      } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ success: false, message: 'Server error' });
      }
    });

    // Login Route - Step 2: Verify Password
    app.post('/api/verify-password', async (req, res) => {
      try {
        console.log('Received password verification data:', req.body);
        const { userId, password } = req.body;

        if (!userId || !password) {
          console.error('Missing required fields:', req.body);
          return res.status(400).json({ success: false, message: 'User ID and password are required' });
        }

        const user = await User.findById(userId);
        if (!user) {
          console.error('User not found:', userId);
          return res.status(401).json({ success: false, message: 'User not found' });
        }

        const isPasswordValid = await bcrypt.compare(password, user.password);
        if (!isPasswordValid) {
          console.error('Invalid password for user:', user.email);
          return res.status(401).json({ success: false, message: 'Invalid password' });
        }

        const token = jwt.sign({ userId: user._id, email: user.email }, JWT_SECRET, { expiresIn: '1h' });
        console.log('Login successful for user:', user.email);
        res.status(200).json({
          success: true,
          message: 'Login successful',
          token,
          user: { id: user._id, firstName: user.firstName, lastName: user.lastName, email: user.email }
        });
      } catch (error) {
        console.error('Password verification error:', error);
        res.status(500).json({ success: false, message: 'Server error' });
      }
    });

    // Social Sign-in Routes (placeholders)
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

    // Health Check Routes
    app.get('/api/health', (req, res) => {
      console.log('Health check request received');
      res.status(200).json({ status: 'Server is running' });
    });

    app.get('/ping', (req, res) => {
      console.log('Ping request received');
      res.status(200).json({ message: 'pong' });
    });

    // Start server only after MongoDB connection is established
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`Server running on port ${PORT}`);
    });
  } catch (err) {
    console.error('Failed to connect to MongoDB:', err);
    process.exit(1); // Exit if MongoDB connection fails
  }
}

// Start the server
startServer();