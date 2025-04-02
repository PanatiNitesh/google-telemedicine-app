const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const Doctor = require('../models/Doctor');
const multer = require('multer');
const path = require('path');

// Multer setup for file uploads (already in your code, included for completeness)
const storage = multer.diskStorage({
  destination: './uploads/',
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});
const upload = multer({ storage });

// Temporary in-memory OTP storage (replace with Redis or a database in production)
const otps = new Map();

// Generate a 6-digit OTP
const generateOtp = () => Math.floor(100000 + Math.random() * 900000).toString();

// Send Phone OTP for Registration
router.post('/register/send-phone-otp', async (req, res) => {
  const { phoneNumber } = req.body;

  if (!phoneNumber) {
    return res.status(400).json({ success: false, message: 'Phone number is required' });
  }

  try {
    // Check if phone number is already registered
    const existingDoctor = await Doctor.findOne({ phoneNumber });
    if (existingDoctor) {
      return res.status(400).json({ success: false, message: 'Phone number already registered' });
    }

    // Generate and store OTP
    const otp = generateOtp();
    otps.set(phoneNumber, otp); // Store OTP temporarily
    console.log(`Registration Phone OTP for ${phoneNumber}: ${otp}`);

    // TODO: Integrate SMS service (e.g., Twilio) here
    // For now, return OTP in response for development purposes
    res.status(200).json({ success: true, message: 'Phone OTP sent successfully', otp });
  } catch (error) {
    console.error('Send Phone OTP error:', error);
    res.status(500).json({ success: false, message: 'Server error sending phone OTP', error: error.message });
  }
});

// Register Doctor (updated to verify OTP from temporary storage)
router.post('/register', upload.single('profilePicture'), async (req, res) => {
  const {
    firstName, lastName, dateOfBirth, gender, phoneNumber, email, specialization,
    qualifications, licenseNumber, issuingAuthority, licenseExpiryDate, clinicName,
    clinicAddress, practiceType, consultationFees, country, state, city, postalCode,
    communicationPreference, availabilityHours, password, otpPhone, agreeTerms,
    socialMediaProfiles, languagesSpoken,
  } = req.body;

  // Validation
  const requiredFields = {
    firstName, lastName, dateOfBirth, gender, phoneNumber, email, specialization,
    qualifications, licenseNumber, issuingAuthority, licenseExpiryDate, clinicAddress,
    practiceType, country, state, city, postalCode, communicationPreference,
    availabilityHours, password, otpPhone,
  };
  for (const [key, value] of Object.entries(requiredFields)) {
    if (!value) {
      return res.status(400).json({ success: false, message: `${key} is required` });
    }
  }

  if (agreeTerms !== 'true') {
    return res.status(400).json({ success: false, message: 'You must agree to the terms' });
  }

  try {
    // Check for existing doctor
    const existingDoctor = await Doctor.findOne({
      $or: [{ email }, { phoneNumber }, { licenseNumber }],
    });
    if (existingDoctor) {
      return res.status(400).json({ success: false, message: 'Doctor already exists with this email, phone number, or license number' });
    }

    // Verify Phone OTP from temporary storage
    const storedOtp = otps.get(phoneNumber);
    if (!storedOtp || storedOtp !== otpPhone) {
      return res.status(400).json({ success: false, message: 'Invalid phone OTP' });
    }
    otps.delete(phoneNumber); // Clear OTP after successful verification

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Generate doctorId
    const doctorCount = await Doctor.countDocuments();
    const doctorId = `DOC${String(doctorCount + 1).padStart(4, '0')}`;

    // Create new doctor
    const doctor = new Doctor({
      doctorId,
      firstName,
      lastName,
      dateOfBirth,
      gender,
      phoneNumber,
      email,
      specialization,
      qualifications,
      licenseNumber,
      issuingAuthority,
      licenseExpiryDate,
      clinicName,
      clinicAddress,
      practiceType,
      consultationFees: consultationFees ? Number(consultationFees) : undefined,
      country,
      state,
      city,
      postalCode,
      communicationPreference,
      availabilityHours,
      password: hashedPassword,
      isVerified: true,
      socialMediaProfiles: socialMediaProfiles ? socialMediaProfiles.split(',') : [],
      languagesSpoken: languagesSpoken ? languagesSpoken.split(',') : [],
      profilePicture: req.file ? req.file.path : undefined,
    });

    await doctor.save();

    res.status(201).json({ success: true, message: 'Doctor registered successfully', doctorId });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ success: false, message: 'Server error during registration', error: error.message });
  }
});

module.exports = router;