import React, { useState, FormEvent, ChangeEvent } from 'react';
import { Link } from 'react-router-dom';

interface FormData {
  firstName: string;
  lastName: string;
  dateOfBirth: string;
  gender: string;
  profilePicture: File | null;
  phoneNumber: string;
  email: string;
  specialization: string;
  qualifications: string;
  licenseNumber: string;
  issuingAuthority: string;
  licenseExpiryDate: string;
  clinicName: string;
  clinicAddress: string;
  practiceType: string;
  consultationFees: string;
  country: string;
  state: string;
  city: string;
  postalCode: string;
  communicationPreference: string;
  availabilityHours: string;
  password: string;
  confirmPassword: string;
  otpPhone: string;
  agreeTerms: boolean;
  socialMediaProfiles: string;
  languagesSpoken: string;
}

const DoctorRegistrationForm: React.FC = () => {
  const [currentStep, setCurrentStep] = useState<number>(1);
  const [formData, setFormData] = useState<FormData>({
    firstName: '',
    lastName: '',
    dateOfBirth: '',
    gender: '',
    profilePicture: null,
    phoneNumber: '',
    email: '',
    specialization: '',
    qualifications: '',
    licenseNumber: '',
    issuingAuthority: '',
    licenseExpiryDate: '',
    clinicName: '',
    clinicAddress: '',
    practiceType: '',
    consultationFees: '',
    country: '',
    state: '',
    city: '',
    postalCode: '',
    communicationPreference: '',
    availabilityHours: '',
    password: '',
    confirmPassword: '',
    otpPhone: '',
    agreeTerms: false,
    socialMediaProfiles: '',
    languagesSpoken: '',
  });

  const [phoneOtpSent, setPhoneOtpSent] = useState<boolean>(false);
  const [isLoadingPhoneOtp, setIsLoadingPhoneOtp] = useState<boolean>(false);
  const [isSubmitting, setIsSubmitting] = useState<boolean>(false);
  const [isSubmitted, setIsSubmitted] = useState<boolean>(false);
  const [error, setError] = useState<string>('');

  const handleChange = (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const target = e.target;
    const name = target.name as keyof FormData;
    const value = target.type === 'checkbox' ? (target as HTMLInputElement).checked : target.type === 'file' ? (target as HTMLInputElement).files?.[0] || null : target.value;

    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  const handleSendPhoneOtp = async () => {
    setIsLoadingPhoneOtp(true);
    try {
      const response = await fetch('http://localhost:5000/api/doctor/register/send-phone-otp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ phoneNumber: formData.phoneNumber }),
      });
      const data = await response.json();
      if (data.success) {
        setPhoneOtpSent(true);
        setFormData((prev) => ({ ...prev, otpPhone: data.otp }));
        console.log(`Phone OTP set: ${data.otp}`); // Debug
      } else {
        setError(data.message);
      }
    } catch (err) {
      setError('Failed to send phone OTP');
    } finally {
      setIsLoadingPhoneOtp(false);
    }
  };

  const handleNextStep = () => setCurrentStep((prev) => prev + 1);
  const handlePrevStep = () => setCurrentStep((prev) => prev - 1);

  const handleSubmit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
  
    setError('');
    setIsSubmitting(true);
  
    if (!formData.agreeTerms) {
      setError('Please agree to the Terms and Conditions.');
      setIsSubmitting(false);
      return;
    }
  
    if (formData.password.trim() !== formData.confirmPassword.trim()) {
      setError('Passwords do not match.');
      setIsSubmitting(false);
      return;
    }
  
    const requiredFields = [
      'firstName', 'lastName', 'dateOfBirth', 'gender', 'phoneNumber', 'email',
      'specialization', 'qualifications', 'licenseNumber', 'issuingAuthority',
      'licenseExpiryDate', 'clinicAddress', 'practiceType', 'country', 'state',
      'city', 'postalCode', 'communicationPreference', 'availabilityHours',
      'password', 'otpPhone',
    ];
    const missingField = requiredFields.find((field) => !formData[field as keyof FormData]?.toString().trim());
    if (missingField) {
      setError(`Please fill in ${missingField.replace(/([A-Z])/g, ' $1').toLowerCase()}`);
      setIsSubmitting(false);
      return;
    }
  
    const formDataToSend = new FormData();
    Object.entries(formData).forEach(([key, value]) => {
      if (key === 'profilePicture' && value instanceof File) {
        formDataToSend.append(key, value);
      } else if (typeof value === 'boolean') {
        formDataToSend.append(key, value.toString());
      } else {
        formDataToSend.append(key, value as string);
      }
    });
  
    console.log('FormData to send:');
    for (const [key, value] of formDataToSend.entries()) {
      console.log(`${key}: ${value}`);
    }
  
    try {
      const response = await fetch('http://localhost:5000/api/doctor/register', {
        method: 'POST',
        body: formDataToSend,
      });
  
      const data = await response.json();
      if (!response.ok) {
        console.log('Server response:', data);
        throw new Error(`Server Error: ${response.status} - ${data.message || 'Unknown error'}`);
      }
  
      if (data.success) {
        setIsSubmitted(true);
      } else {
        setError(data.message || 'Registration failed.');
      }
    } catch (err) {
      if (err instanceof Error) {
        setError(err.message || 'Failed to submit registration.');
      } else {
        setError('An unknown error occurred.');
      }
    } finally {
      setIsSubmitting(false);
    }
  };

  const renderStep = () => {
    switch (currentStep) {
      case 1:
        return (
          <div className="space-y-4">
            {error && <div className="text-red-500 text-sm">{error}</div>}
            <h2 className="text-xl font-semibold text-gray-800">Personal Information</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700">
                  First Name <span className="text-red-500">*</span>
                </label>
                <input
                  type="text"
                  name="firstName"
                  value={formData.firstName}
                  onChange={handleChange}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-gray-50 p-3 text-gray-800"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Last Name <span className="text-red-500">*</span>
                </label>
                <input
                  type="text"
                  name="lastName"
                  value={formData.lastName}
                  onChange={handleChange}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-gray-50 p-3 text-gray-800"
                  required
                />
              </div>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">
                Date of Birth <span className="text-red-500">*</span>
              </label>
              <input
                type="date"
                name="dateOfBirth"
                value={formData.dateOfBirth}
                onChange={handleChange}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-gray-50 p-3 text-gray-800"
                required
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">
                Gender <span className="text-red-500">*</span>
              </label>
              <select
                name="gender"
                value={formData.gender}
                onChange={handleChange}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-gray-50 p-3 text-gray-800"
                required
              >
                <option value="">Select Gender</option>
                <option value="male">Male</option>
                <option value="female">Female</option>
                <option value="other">Other</option>
                <option value="prefer-not-to-say">Prefer not to say</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">Profile Picture (Optional)</label>
              <input
                type="file"
                name="profilePicture"
                onChange={handleChange}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-gray-50 p-3 text-gray-800 file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100"
                accept="image/*"
              />
            </div>
          </div>
        );
      case 2:
        return (
          <div className="space-y-4">
            {error && <div className="text-red-500 text-sm">{error}</div>}
            <h2 className="text-xl font-semibold text-gray-800">Contact Information</h2>
            <div>
              <label className="block text-sm font-medium text-gray-700">
                Phone Number <span className="text-red-500">*</span>
              </label>
              <div className="flex space-x-2">
                <input
                  type="tel"
                  name="phoneNumber"
                  value={formData.phoneNumber}
                  onChange={handleChange}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-gray-50 p-3 text-gray-800"
                  required
                />
                <button
                  type="button"
                  onClick={handleSendPhoneOtp}
                  className="mt-1 inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                  disabled={isLoadingPhoneOtp}
                >
                  {isLoadingPhoneOtp ? 'Sending...' : 'Send OTP'}
                </button>
              </div>
            </div>
            {phoneOtpSent && (
              <div>
                <label className="block text-sm font-medium text-gray-700">
                  Phone OTP <span className="text-red-500">*</span>
                </label>
                <input
                  type="text"
                  name="otpPhone"
                  value={formData.otpPhone}
                  onChange={handleChange}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-gray-50 p-3 text-gray-800"
                  required
                  placeholder="Enter OTP sent to your phone"
                />
              </div>
            )}
            <div>
              <label className="block text-sm font-medium text-gray-700">
                Email Address <span className="text-red-500">*</span>
              </label>
              <input
                type="email"
                name="email"
                value={formData.email}
                onChange={handleChange}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-gray-50 p-3 text-gray-800"
                required
              />
            </div>
          </div>
        );
      case 3:
        return (
          <div className="space-y-4">
            {error && <div className="text-red-500 text-sm">{error}</div>}
            <h2 className="text-xl font-semibold text-gray-800">Medical Information</h2>
            <div>
              <label className="block text-sm font-medium text-gray-700">
                Specialization <span className="text-red-500">*</span>
              </label>
              <select
                name="specialization"
                value={formData.specialization}
                onChange={handleChange}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-gray-50 p-3 text-gray-800"
                required
              >
                <option value="">Select Specialization</option>
                <option value="general-physician">General Physician</option>
                <option value="cardiologist">Cardiologist</option>
                <option value="dermatologist">Dermatologist</option>
                <option value="neurologist">Neurologist</option>
                <option value="gynecologist">Gynecologist</option>
                <option value="pediatrician">Pediatrician</option>
                <option value="psychiatrist">Psychiatrist</option>
                <option value="orthopedic">Orthopedic</option>
                <option value="ophthalmologist">Ophthalmologist</option>
                <option value="ent-specialist">ENT Specialist</option>
                <option value="other">Other</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">
                Qualifications/Degrees <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                name="qualifications"
                value={formData.qualifications}
                onChange={handleChange}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-gray-50 p-3 text-gray-800"
                required
                placeholder="e.g., MBBS, MD, MS, DNB"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">
                Medical License Number <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                name="licenseNumber"
                value={formData.licenseNumber}
                onChange={handleChange}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-gray-50 p-3 text-gray-800"
                required
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">
                License Issuing Authority <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                name="issuingAuthority"
                value={formData.issuingAuthority}
                onChange={handleChange}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-gray-50 p-3 text-gray-800"
                required
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">
                License Expiry Date <span className="text-red-500">*</span>
              </label>
              <input
                type="date"
                name="licenseExpiryDate"
                value={formData.licenseExpiryDate}
                onChange={handleChange}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-gray-50 p-3 text-gray-800"
                required
              />
            </div>
          </div>
        );
      case 4:
        return (
          <div className="space-y-4">
            {error && <div className="text-red-500 text-sm">{error}</div>}
            <h2 className="text-xl font-semibold text-gray-800">Practice Details</h2>
            <div>
              <label className="block text-sm font-medium text-gray-700">Clinic/Hospital Name</label>
              <input
                type="text"
                name="clinicName"
                value={formData.clinicName}
                onChange={handleChange}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-gray-50 p-3 text-gray-800"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">
                Clinic/Hospital Address <span className="text-red-500">*</span>
              </label>
              <textarea
                name="clinicAddress"
                value={formData.clinicAddress}
                onChange={handleChange}
                rows={3}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-gray-50 p-3 text-gray-800"
                required
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">
                Practice Type <span className="text-red-500">*</span>
              </label>
              <select
                name="practiceType"
                value={formData.practiceType}
                onChange={handleChange}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-gray-50 p-3 text-gray-800"
                required
              >
                <option value="">Select Practice Type</option>
                <option value="online">Online Consultation</option>
                <option value="in-person">In-person Consultation</option>
                <option value="both">Both Online and In-person</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">Consultation Fees (Optional)</label>
              <input
                type="number"
                name="consultationFees"
                value={formData.consultationFees}
                onChange={handleChange}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-gray-50 p-3 text-gray-800"
                placeholder="Enter amount"
              />
            </div>
          </div>
        );
      case 5:
        return (
          <div className="space-y-4">
            {error && <div className="text-red-500 text-sm">{error}</div>}
            <h2 className="text-xl font-semibold text-gray-800">Location Information</h2>
            <div>
              <label className="block text-sm font-medium text-gray-700">
                Country/Region <span className="text-red-500">*</span>
              </label>
              <select
                name="country"
                value={formData.country}
                onChange={handleChange}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-gray-50 p-3 text-gray-800"
                required
              >
                <option value="">Select Country</option>
                <option value="us">United States</option>
                <option value="ca">Canada</option>
                <option value="uk">United Kingdom</option>
                <option value="au">Australia</option>
                <option value="in">India</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">
                State/Province <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                name="state"
                value={formData.state}
                onChange={handleChange}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-gray-50 p-3 text-gray-800"
                required
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">
                City <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                name="city"
                value={formData.city}
                onChange={handleChange}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-gray-50 p-3 text-gray-800"
                required
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">
                Postal Code <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                name="postalCode"
                value={formData.postalCode}
                onChange={handleChange}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-gray-50 p-3 text-gray-800"
                required
              />
            </div>
          </div>
        );
      case 6:
        return (
          <div className="space-y-4">
            {error && <div className="text-red-500 text-sm">{error}</div>}
            <h2 className="text-xl font-semibold text-gray-800">Communication Preferences</h2>
            <div>
              <label className="block text-sm font-medium text-gray-700">
                Preferred Communication Method <span className="text-red-500">*</span>
              </label>
              <select
                name="communicationPreference"
                value={formData.communicationPreference}
                onChange={handleChange}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-gray-50 p-3 text-gray-800"
                required
              >
                <option value="">Select Preference</option>
                <option value="video">Video</option>
                <option value="voice">Voice</option>
                <option value="chat">Chat</option>
                <option value="all">All Methods</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">
                Availability Hours <span className="text-red-500">*</span>
              </label>
              <textarea
                name="availabilityHours"
                value={formData.availabilityHours}
                onChange={handleChange}
                rows={3}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-gray-50 p-3 text-gray-800"
                required
                placeholder="E.g., Mon-Fri: 9AM-5PM, Sat: 10AM-2PM"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">Languages Spoken (Optional)</label>
              <input
                type="text"
                name="languagesSpoken"
                value={formData.languagesSpoken}
                onChange={handleChange}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-gray-50 p-3 text-gray-800"
                placeholder="E.g., English, Spanish, French"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">Social Media Profiles (Optional)</label>
              <input
                type="text"
                name="socialMediaProfiles"
                value={formData.socialMediaProfiles}
                onChange={handleChange}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-gray-50 p-3 text-gray-800"
                placeholder="LinkedIn, Twitter, etc."
              />
            </div>
          </div>
        );
      case 7:
        return (
          <div className="space-y-4">
            {error && <div className="text-red-500 text-sm">{error}</div>}
            <h2 className="text-xl font-semibold text-gray-800">Security and Terms</h2>
            <div>
              <label className="block text-sm font-medium text-gray-700">
                Password <span className="text-red-500">*</span>
              </label>
              <input
                type="password"
                name="password"
                value={formData.password}
                onChange={handleChange}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-gray-50 p-3 text-gray-800"
                required
                placeholder="Create a strong password"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">
                Confirm Password <span className="text-red-500">*</span>
              </label>
              <input
                type="password"
                name="confirmPassword"
                value={formData.confirmPassword}
                onChange={handleChange}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-gray-50 p-3 text-gray-800"
                required
                placeholder="Confirm your password"
              />
            </div>
            <div className="flex items-start">
              <div className="flex items-center h-5">
                <input
                  id="terms"
                  name="agreeTerms"
                  type="checkbox"
                  checked={formData.agreeTerms}
                  onChange={handleChange}
                  className="focus:ring-blue-500 h-4 w-4 text-blue-600 border-gray-300 rounded"
                  required
                />
              </div>
              <div className="ml-3 text-sm">
                <label htmlFor="terms" className="font-medium text-gray-700">
                  I agree to the{' '}
                  <a href="#" className="text-blue-600 hover:underline">
                    Terms and Conditions
                  </a>{' '}
                  and{' '}
                  <a href="#" className="text-blue-600 hover:underline">
                    Privacy Policy
                  </a>{' '}
                  <span className="text-red-500">*</span>
                </label>
              </div>
            </div>
          </div>
        );
      default:
        return null;
    }
  };

  return (
    <div className="min-h-screen bg-gray-200">
      {/* Navbar */}
      <nav className="sticky top-0 z-50 bg-white bg-opacity-80 backdrop-blur-md">
        <div className="container mx-auto px-4 py-3 flex items-center justify-between">
          <div className="flex items-center">
            <svg
              className="w-8 h-8 text-blue-600 mr-2"
              fill="currentColor"
              viewBox="0 0 20 20"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                fillRule="evenodd"
                d="M5 4a3 3 0 00-3 3v6a3 3 0 003 3h10a3 3 0 003-3V7a3 3 0 00-3-3H5zm-1 9v-1h5v2H5a1 1 0 01-1-1zm7 1h4a1 1 0 001-1v-1h-5v2zm0-4h5V8h-5v2zM9 8H4v2h5V8z"
                clipRule="evenodd"
              />
            </svg>
            <h1 className="text-xl font-bold text-blue-700">DocHub</h1>
          </div>
          <div className="flex items-center">
            <Link to="/">
              <button className="px-4 py-2 text-blue-700 border border-blue-700 rounded-md hover:bg-blue-50 transition duration-200">
                Back to Home
              </button>
            </Link>
          </div>
        </div>
      </nav>

      {/* Main Content */}
      <div className="max-w-4xl mx-auto mt-8">
        <div className="bg-white shadow-xl rounded-lg overflow-hidden">
          {/* Header */}
          <div className="bg-blue-600 px-6 py-4">
            <h1 className="text-2xl font-bold text-white">Doctor Registration</h1>
            <p className="text-blue-100">
              Please complete all required fields to register as a healthcare provider
            </p>
          </div>

          {/* Progress Steps */}
          <div className="px-6 pt-4">
            <div className="flex justify-between mb-4">
              {[1, 2, 3, 4, 5, 6, 7].map((step) => (
                <div
                  key={step}
                  className={`flex flex-col items-center ${currentStep >= step ? 'text-blue-600' : 'text-gray-400'}`}
                >
                  <div
                    className={`w-8 h-8 flex items-center justify-center rounded-full ${
                      currentStep > step
                        ? 'bg-blue-600 text-white'
                        : currentStep === step
                        ? 'border-2 border-blue-600 text-blue-600'
                        : 'border-2 border-gray-300 text-gray-400'
                    }`}
                  >
                    {currentStep > step ? '✓' : step}
                  </div>
                  <div className="text-xs mt-1 hidden sm:block">
                    {step === 1 && 'Personal'}
                    {step === 2 && 'Contact'}
                    {step === 3 && 'Medical'}
                    {step === 4 && 'Practice'}
                    {step === 5 && 'Location'}
                    {step === 6 && 'Comm Pref'}
                    {step === 7 && 'Security'}
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Form */}
          <form onSubmit={handleSubmit} className="px-6 py-4">
            {renderStep()}

            {/* Navigation Buttons */}
            <div className="mt-8 flex justify-between">
              <button
                type="button"
                onClick={handlePrevStep}
                className={`px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 ${
                  currentStep === 1 ? 'invisible' : ''
                }`}
              >
                Previous
              </button>

              {currentStep < 7 ? (
                <button
                  type="button"
                  onClick={handleNextStep}
                  className="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                >
                  Next
                </button>
              ) : (
                <button
                  type="submit"
                  className="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 flex items-center"
                  disabled={isSubmitting}
                >
                  {isSubmitting ? 'Submitting...' : 'Submit Registration'}
                </button>
              )}
            </div>
          </form>
        </div>
      </div>

      {/* Submission Success Modal */}
      {isSubmitted && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white p-6 rounded-lg shadow-lg max-w-sm w-full text-center">
            <svg
              className="w-16 h-16 text-green-500 mx-auto mb-4 animate-bounce"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 13l4 4L19 7" />
            </svg>
            <h3 className="text-xl font-semibold text-gray-800 mb-2">Application Submitted!</h3>
            <p className="text-gray-600">
              You will receive a confirmation via email in 2-3 business days with your login details.
            </p>
            <Link to="/">
              <button className="mt-4 px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700">
                Back to Home
              </button>
            </Link>
          </div>
        </div>
      )}
    </div>
  );
};

export default DoctorRegistrationForm;