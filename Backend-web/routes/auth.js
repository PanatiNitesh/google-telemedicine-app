const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const Doctor = require('../models/Doctor');

const generateOtp = () => Math.floor(100000 + Math.random() * 900000).toString();

// Send Phone OTP for Login
router.post('/send-phone-otp', async (req, res) => {
  const { phoneNumber } = req.body;
  if (!phoneNumber) {
    return res.status(400).json({ success: false, message: 'Phone number is required' });
  }
  try {
    const doctor = await Doctor.findOne({ phoneNumber });
    if (!doctor) {
      return res.status(404).json({ success: false, message: 'Doctor not found with this phone number' });
    }
    const otp = generateOtp();
    doctor.phoneOtp = otp;
    await doctor.save();
    const updatedDoctor = await Doctor.findOne({ phoneNumber }); // Verify immediately
    console.log(`OTP Generated and Saved for ${phoneNumber}: ${otp}`);
    console.log(`Verified Stored OTP: ${updatedDoctor.phoneOtp}`);
    res.status(200).json({ success: true, message: 'Phone OTP sent successfully', otp });
  } catch (error) {
    console.error('Send Phone OTP error:', error);
    res.status(500).json({ success: false, message: 'Server error sending phone OTP', error: error.message });
  }
});

// Login
router.post('/login', async (req, res) => {
  const { email, phoneNumber, otpPhone, password } = req.body;
  if (!email || !phoneNumber || !otpPhone || !password) {
    return res.status(400).json({ success: false, message: 'All fields are required' });
  }
  try {
    // Fetch doctor by phoneNumber first to ensure consistency
    const doctorByPhone = await Doctor.findOne({ phoneNumber });
    if (!doctorByPhone) {
      return res.status(400).json({ success: false, message: 'Doctor not found with this phone number' });
    }
    console.log(`Fetched by phoneNumber - Stored OTP: ${doctorByPhone.phoneOtp}`);

    // Check if email matches (optional, depending on your logic)
    if (doctorByPhone.email !== email) {
      return res.status(400).json({ success: false, message: 'Email and phone number do not match' });
    }

    console.log(`Checking OTP - Stored: ${doctorByPhone.phoneOtp}, Submitted: ${otpPhone}`);
    if (!doctorByPhone.phoneOtp || doctorByPhone.phoneOtp !== otpPhone) {
      return res.status(400).json({ success: false, message: 'Invalid phone OTP' });
    }

    const isMatch = await bcrypt.compare(password, doctorByPhone.password);
    if (!isMatch) {
      return res.status(400).json({ success: false, message: 'Invalid password' });
    }

    // Clear OTP after successful login
    doctorByPhone.phoneOtp = undefined;
    doctorByPhone.isVerified = true;
    await doctorByPhone.save();

    const token = jwt.sign({ id: doctorByPhone._id }, process.env.JWT_SECRET, { expiresIn: '1h' });
    res.status(200).json({
      success: true,
      message: 'Login successful',
      data: { token, doctorId: doctorByPhone.doctorId },
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ success: false, message: 'Server error during login', error: error.message });
  }
});

module.exports = router;