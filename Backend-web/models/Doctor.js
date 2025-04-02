const mongoose = require('mongoose');

const doctorSchema = new mongoose.Schema({
  doctorId: {
    type: String,
    unique: true,
    required: true,
  },
  firstName: { type: String, required: true },
  lastName: { type: String, required: true },
  dateOfBirth: { type: Date, required: true },
  gender: { type: String, required: true },
  profilePicture: { type: String }, // Store file path or URL
  phoneNumber: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  specialization: { type: String, required: true },
  qualifications: { type: String, required: true },
  licenseNumber: { type: String, required: true, unique: true },
  issuingAuthority: { type: String, required: true },
  licenseExpiryDate: { type: Date, required: true },
  clinicName: { type: String },
  clinicAddress: { type: String, required: true },
  practiceType: { type: String, required: true },
  consultationFees: { type: Number, min: 0 },
  
  country: { type: String, required: true },
  state: { type: String, required: true },
  city: { type: String, required: true },
  postalCode: { type: String, required: true },
  communicationPreference: {
    type: String,
    enum: ['video', 'voice', 'chat', 'all methods'],
    required: true,
  },
  availabilityHours: { type: String, required: true },
  password: { type: String, required: true },
  socialMediaProfiles: [{ type: String }],
  languagesSpoken: [{ type: String }],
  phoneOtp: { type: String }, // Keep phone OTP
  isVerified: { type: Boolean, default: false },
}, { timestamps: true });

module.exports = mongoose.model('Doctor', doctorSchema);
