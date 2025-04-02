import { useState } from 'react';
import { Link } from 'react-router-dom';

const LoginPage = () => {
  const [currentStep, setCurrentStep] = useState(1);
  const [loginData, setLoginData] = useState({
    email: '',
    phoneNumber: '',
    otpPhone: '',
    password: '',
    rememberMe: false,
  });

  const [phoneOtpSent, setPhoneOtpSent] = useState(false);
  const [isLoadingPhoneOtp, setIsLoadingPhoneOtp] = useState(false);
  const [isLoggingIn, setIsLoggingIn] = useState(false);
  const [isLoginSuccess, setIsLoginSuccess] = useState(false);
  const [error, setError] = useState('');

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const target = e.target;
    const name = target.name;
    const value = target.type === 'checkbox' ? target.checked : target.value;

    setLoginData((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  const handleSendPhoneOtp = async () => {
    if (!loginData.phoneNumber.trim()) {
      setError('Please enter a valid phone number');
      return;
    }
    if (phoneOtpSent) {
      setError('OTP already sent. Proceed to login or reset if needed.');
      return;
    }
    setIsLoadingPhoneOtp(true);
    try {
      const response = await fetch('http://localhost:5000/api/auth/send-phone-otp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ phoneNumber: loginData.phoneNumber.trim() }),
      });
      const data = await response.json();
      if (data.success) {
        setPhoneOtpSent(true);
        // For development: Auto-fill OTP (remove in production)
        setLoginData((prev) => ({ ...prev, otpPhone: data.otp }));
        console.log(`Phone OTP received: ${data.otp}`);
      } else {
        setError(data.message);
      }
    } catch (err) {
      setError('Failed to send phone OTP');
    } finally {
      setIsLoadingPhoneOtp(false);
    }
  };

  const handleNextStep = () => {
    if (!phoneOtpSent) {
      setError('Please verify your phone number');
      return;
    }
    if (!loginData.otpPhone.trim()) {
      setError('Please enter the OTP sent to your phone');
      return;
    }
    setTimeout(() => setCurrentStep(2), 1000); // 1-second delay
  };
  interface LoginResponse {
    success: boolean;
    message?: string;
    data?: {
      token: string;
    };
  }

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (!loginData.password.trim()) {
      setError('Please enter your password');
      return;
    }
    if (!loginData.otpPhone.trim()) {
      setError('Please enter the phone OTP');
      return;
    }
    setIsLoggingIn(true);
    try {
      console.log('Login payload:', loginData); // Debug payload
      const response = await fetch('http://localhost:5000/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email: loginData.email.trim(),
          phoneNumber: loginData.phoneNumber.trim(),
          otpPhone: loginData.otpPhone.trim(),
          password: loginData.password.trim(),
          rememberMe: loginData.rememberMe,
        }),
      });
      const data: LoginResponse = await response.json();
      if (data.success) {
        localStorage.setItem('token', data.data?.token || '');
        setIsLoginSuccess(true);
      } else {
        setError(data.message || 'Login failed');
      }
    } catch (err) {
      setError('Failed to login');
    } finally {
      setIsLoggingIn(false);
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
          <div className="flex items-center space-x-4">
            <Link to="/register">
              <button className="px-4 py-2 text-blue-700 border border-blue-700 rounded-md hover:bg-blue-50 transition duration-200">
                Register
              </button>
            </Link>
            <Link to="/">
              <button className="px-4 py-2 text-gray-700 hover:text-gray-900 transition duration-200">
                Home
              </button>
            </Link>
          </div>
        </div>
      </nav>

      {/* Main Content */}
      <div className="max-w-md mx-auto mt-16">
        <div className="bg-white shadow-xl rounded-lg overflow-hidden">
          {/* Header */}
          <div className="bg-blue-600 px-6 py-4">
            <h1 className="text-2xl font-bold text-white">Login to DocHub</h1>
            <p className="text-blue-100">Access your healthcare dashboard</p>
          </div>

          {/* Progress Steps */}
          <div className="px-6 pt-4">
            <div className="flex justify-center mb-4">
              {[1, 2].map((step) => (
                <div
                  key={step}
                  className={`flex flex-col items-center mx-8 ${
                    currentStep >= step ? 'text-blue-600' : 'text-gray-400'
                  }`}
                >
                  <div
                    className={`w-10 h-10 flex items-center justify-center rounded-full ${
                      currentStep > step
                        ? 'bg-blue-600 text-white'
                        : currentStep === step
                        ? 'border-2 border-blue-600 text-blue-600'
                        : 'border-2 border-gray-300 text-gray-400'
                    }`}
                  >
                    {currentStep > step ? '✓' : step}
                  </div>
                  <div className="text-sm mt-2">
                    {step === 1 && 'Verification'}
                    {step === 2 && 'Password'}
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Form */}
          <form onSubmit={handleSubmit} className="px-6 py-4">
            {error && <div className="text-red-500 text-sm mb-4">{error}</div>}
            {currentStep === 1 ? (
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Email Address <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="email"
                    name="email"
                    value={loginData.email}
                    onChange={handleChange}
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-gray-50 p-3 text-gray-800"
                    required
                    placeholder="doctor@example.com"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Phone Number <span className="text-red-500">*</span>
                  </label>
                  <div className="flex space-x-2">
                    <input
                      type="tel"
                      name="phoneNumber"
                      value={loginData.phoneNumber}
                      onChange={handleChange}
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-gray-50 p-3 text-gray-800"
                      required
                      placeholder="+1 (123) 456-7890"
                    />
                    <button
                      type="button"
                      onClick={handleSendPhoneOtp}
                      className="mt-1 inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                      disabled={isLoadingPhoneOtp || phoneOtpSent}
                    >
                      {isLoadingPhoneOtp ? (
                        <svg
                          className="animate-spin h-5 w-5 text-white"
                          xmlns="http://www.w3.org/2000/svg"
                          fill="none"
                          viewBox="0 0 24 24"
                        >
                          <circle
                            className="opacity-25"
                            cx="12"
                            cy="12"
                            r="10"
                            stroke="currentColor"
                            strokeWidth="4"
                          ></circle>
                          <path
                            className="opacity-75"
                            fill="currentColor"
                            d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                          ></path>
                        </svg>
                      ) : phoneOtpSent ? (
                        'Sent'
                      ) : (
                        'Send OTP'
                      )}
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
                      value={loginData.otpPhone}
                      onChange={handleChange}
                      className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-gray-50 p-3 text-gray-800"
                      required
                      placeholder="Enter OTP sent to your phone"
                    />
                  </div>
                )}

                <div className="mt-8 flex justify-end">
                  <button
                    type="button"
                    onClick={handleNextStep}
                    className="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                  >
                    Next
                  </button>
                </div>
              </div>
            ) : (
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700">
                    Password <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="password"
                    name="password"
                    value={loginData.password}
                    onChange={handleChange}
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 bg-gray-50 p-3 text-gray-800"
                    required
                    placeholder="Enter your password"
                  />
                </div>

                <div className="flex items-center justify-between">
                  <div className="flex items-center">
                    <input
                      id="remember-me"
                      name="rememberMe"
                      type="checkbox"
                      checked={loginData.rememberMe}
                      onChange={handleChange}
                      className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                    />
                    <label htmlFor="remember-me" className="ml-2 block text-sm text-gray-700">
                      Remember me
                    </label>
                  </div>

                  <div className="text-sm">
                    <a href="#" className="text-blue-600 hover:text-blue-500">
                      Forgot your password?
                    </a>
                  </div>
                </div>

                <div className="mt-6 flex items-center justify-between">
                  <button
                    type="button"
                    onClick={() => setCurrentStep(1)}
                    className="px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                  >
                    Back
                  </button>

                  <button
                    type="submit"
                    className="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 flex items-center"
                    disabled={isLoggingIn}
                  >
                    {isLoggingIn ? (
                      <>
                        <svg
                          className="animate-spin h-5 w-5 mr-2 text-white"
                          xmlns="http://www.w3.org/2000/svg"
                          fill="none"
                          viewBox="0 0 24 24"
                        >
                          <circle
                            className="opacity-25"
                            cx="12"
                            cy="12"
                            r="10"
                            stroke="currentColor"
                            strokeWidth="4"
                          ></circle>
                          <path
                            className="opacity-75"
                            fill="currentColor"
                            d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                          ></path>
                        </svg>
                        Logging in...
                      </>
                    ) : (
                      'Login'
                    )}
                  </button>
                </div>
              </div>
            )}

            <div className="mt-6 text-center text-sm text-gray-600">
              Don't have an account?{' '}
              <Link to="/register" className="text-blue-600 hover:text-blue-500">
                Register now
              </Link>
            </div>
          </form>
        </div>
      </div>

      {isLoginSuccess && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white p-6 rounded-lg shadow-lg max-w-sm w-full text-center">
            <svg
              className="w-16 h-16 text-green-500 mx-auto mb-4 animate-bounce"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth="2"
                d="M5 13l4 4L19 7"
              />
            </svg>
            <h3 className="text-xl font-semibold text-gray-800 mb-2">Login Successful!</h3>
            <p className="text-gray-600">
              Welcome back to DocHub. You are now being redirected to your dashboard.
            </p>
            <Link to="/">
              <button className="mt-4 px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700">
                Go to Dashboard
              </button>
            </Link>
          </div>
        </div>
      )}
    </div>
  );
};

export default LoginPage;