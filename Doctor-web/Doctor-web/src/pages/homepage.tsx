import React from "react";
import { Link } from "react-router-dom";

const Homepage: React.FC = () => {
  return (
    <div className="relative min-h-screen bg-gradient-to-b from-blue-50 to-white overflow-hidden">
      {/* Background Shapes */}
      <div className="absolute inset-0 z-0">
        {/* Shape 1: Circle */}
        <div className="absolute top-10 left-10 w-64 h-64 bg-blue-200 rounded-full opacity-30 blur-3xl"></div>
        {/* Shape 2: Ellipse */}
        <div className="absolute bottom-20 right-20 w-96 h-64 bg-blue-300 rounded-full opacity-20 blur-3xl transform rotate-45"></div>
        {/* Shape 3: Smaller Circle */}
        <div className="absolute top-1/3 right-1/4 w-48 h-48 bg-blue-100 rounded-full opacity-25 blur-2xl"></div>
        {/* Shape 4: Abstract Shape */}
        <div className="absolute bottom-1/4 left-1/4 w-72 h-72 bg-blue-400 opacity-15 blur-3xl rounded-tl-[50%] rounded-br-[50%]"></div>
      </div>

      <nav className="sticky top-0 z-50 bg-white shadow-lg backdrop-blur-md bg-opacity-90">
        <div className="container mx-auto px-6 py-4 flex items-center justify-between">
          <div className="flex items-center">
            <svg className="w-10 h-10 text-blue-600 mr-3" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
              <path fillRule="evenodd" d="M5 4a3 3 0 00-3 3v6a3 3 0 003 3h10a3 3 0 003-3V7a3 3 0 00-3-3H5zm-1 9v-1h5v2H5a1 1 0 01-1-1zm7 1h4a1 1 0 001-1v-1h-5v2zm0-4h5V8h-5v2zM9 8H4v2h5V8z" clipRule="evenodd" />
            </svg>
            <h1 className="text-2xl font-extrabold text-blue-700 tracking-tight">DocHub</h1>
          </div>
          <div className="hidden md:flex items-center space-x-8">
            <Link to="/features" className="text-gray-700 font-medium hover:text-blue-600 transition duration-300">Features</Link>
            <Link to="/pricing" className="text-gray-700 font-medium hover:text-blue-600 transition duration-300">Pricing</Link>
            <Link to="/resources" className="text-gray-700 font-medium hover:text-blue-600 transition duration-300">Resources</Link>
            <Link to="/login">
              <button className="px-5 py-2 text-blue-700 border-2 border-blue-700 rounded-full hover:bg-blue-50 transition duration-300 font-semibold">
                Login
              </button>
            </Link>
            <Link to="/register">
              <button className="px-5 py-2 bg-blue-700 text-white rounded-full hover:bg-blue-800 transition duration-300 font-semibold shadow-md">
                Register Now
              </button>
            </Link>
          </div>
          <div className="md:hidden">
            <button className="text-gray-600 hover:text-blue-600 focus:outline-none transition duration-300">
              <svg className="w-7 h-7" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 6h16M4 12h16M4 18h16" />
              </svg>
            </button>
          </div>
        </div>
      </nav>
      <section className="container mx-auto px-4 py-12 md:py-20 flex flex-col md:flex-row items-center relative z-10">
        <div className="md:w-1/2 mb-8 md:mb-0 pr-0 md:pr-8">
          <h2 className="text-4xl md:text-5xl font-bold text-gray-800 mb-4">
            Elevate Your <span className="text-blue-700">Medical Practice</span>
          </h2>
          <p className="text-lg text-gray-600 mb-8">
            DocHub provides physicians with a powerful platform to expand their
            practice, reduce administrative burden, and deliver exceptional care
            to patients remotely.
          </p>
          <div className="bg-white p-6 rounded-lg shadow-lg mb-8">
            <h3 className="text-xl font-semibold mb-4">
              Join our network of healthcare providers
            </h3>
            <div className="space-y-4">
              <input
                type="text"
                placeholder="Full Name"
                className="w-full p-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              <input
                type="email"
                placeholder="Email Address"
                className="w-full p-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              <input
                type="tel"
                placeholder="Phone Number"
                className="w-full p-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              <select className="w-full p-3 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 bg-white">
                <option value="">Select Specialty</option>
                <option value="family-medicine">Family Medicine</option>
                <option value="internal-medicine">Internal Medicine</option>
                <option value="pediatrics">Pediatrics</option>
                <option value="cardiology">Cardiology</option>
                <option value="dermatology">Dermatology</option>
                <option value="psychiatry">Psychiatry</option>
                <option value="other">Other</option>
              </select>
              <Link to="/register">
                <button className="w-full py-3 bg-blue-700 text-white rounded-md hover:bg-blue-800 transition duration-200 font-medium">
                  Get Started
                </button>
              </Link>
            </div>
            <div className="mt-4 text-center text-sm text-gray-500">
              Already registered?{" "}
              <Link to="/login" className="text-blue-700 hover:underline">
                Log in
              </Link>
            </div>
          </div>
        </div>
        <div className="md:w-1/2">
          <div className="relative">
            <div className="absolute inset-0 bg-blue-600 rounded-lg transform rotate-3"></div>
            <img
              src="/specialist.png"
              alt="Doctor using telemedicine platform"
              className="relative rounded-lg shadow-lg"
            />
          </div>
        </div>
      </section>
      <section className="bg-white py-12 relative z-10">
        <div className="container mx-auto px-4">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-6 text-center">
            <div className="p-4">
              <p className="text-3xl font-bold text-blue-700 mb-1">-------</p>
              <p className="text-gray-600">Physicians</p>
            </div>
            <div className="p-4">
              <p className="text-3xl font-bold text-blue-700 mb-1">-------</p>
              <p className="text-gray-600">Specialties</p>
            </div>
            <div className="p-4">
              <p className="text-3xl font-bold text-blue-700 mb-1">-------</p>
              <p className="text-gray-600">Patient Consultations</p>
            </div>
            <div className="p-4">
              <p className="text-3xl font-bold text-blue-700 mb-1">-------</p>
              <p className="text-gray-600">Provider Satisfaction</p>
            </div>
          </div>
        </div>
      </section>
      <section className="bg-blue-50 py-16 relative z-10">
        <div className="container mx-auto px-4">
          <div className="text-center mb-12">
            <h3 className="text-3xl font-bold text-gray-800 mb-4">
              Practice Medicine, Your Way
            </h3>
            <p className="text-lg text-gray-600 max-w-2xl mx-auto">
              Our platform is designed by doctors, for doctors, with features
              that streamline your workflow and improve patient care.
            </p>
          </div>
          <div className="grid md:grid-cols-3 gap-8">
            <div className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition duration-200">
              <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center mb-4">
                <svg
                  className="w-6 h-6 text-blue-700"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2"
                    d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
                  />
                </svg>
              </div>
              <h4 className="text-xl font-semibold text-gray-800 mb-2">
                Flexible Scheduling
              </h4>
              <p className="text-gray-600">
                Set your own hours and availability. Our AI-powered scheduling
                reduces no-shows and cancellations by 60%.
              </p>
            </div>
            <div className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition duration-200">
              <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center mb-4">
                <svg
                  className="w-6 h-6 text-blue-700"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2"
                    d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"
                  />
                </svg>
              </div>
              <h4 className="text-xl font-semibold text-gray-800 mb-2">
                Seamless Video Consults
              </h4>
              <p className="text-gray-600">
                High-definition, encrypted video consultations with integrated
                clinical tools for enhanced diagnosis.
              </p>
            </div>
            <div className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition duration-200">
              <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center mb-4">
                <svg
                  className="w-6 h-6 text-blue-700"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2"
                    d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                  />
                </svg>
              </div>
              <h4 className="text-xl font-semibold text-gray-800 mb-2">
                One-Click Prescriptions
              </h4>
              <p className="text-gray-600">
                Write and send prescriptions electronically with our secure
                EPCS-certified e-prescription system.
              </p>
            </div>
            <div className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition duration-200">
              <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center mb-4">
                <svg
                  className="w-6 h-6 text-blue-700"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2"
                    d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01"
                  />
                </svg>
              </div>
              <h4 className="text-xl font-semibold text-gray-800 mb-2">
                Smart Clinical Documentation
              </h4>
              <p className="text-gray-600">
                AI-assisted note-taking and documentation that reduces charting
                time by up to 40%.
              </p>
            </div>
            <div className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition duration-200">
              <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center mb-4">
                <svg
                  className="w-6 h-6 text-blue-700"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2"
                    d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z"
                  />
                </svg>
              </div>
              <h4 className="text-xl font-semibold text-gray-800 mb-2">
                Simplified Billing
              </h4>
              <p className="text-gray-600">
                Integrated billing solutions with insurance verification and
                real-time eligibility checks.
              </p>
            </div>
            <div className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition duration-200">
              <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center mb-4">
                <svg
                  className="w-6 h-6 text-blue-700"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2"
                    d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"
                  />
                </svg>
              </div>
              <h4 className="text-xl font-semibold text-gray-800 mb-2">
                HIPAA & Regulatory Compliance
              </h4>
              <p className="text-gray-600">
                End-to-end encryption and built-in compliance tools for HIPAA,
                GDPR, and other healthcare regulations.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* How It Works */}
      <section className="py-16 relative z-10">
        <div className="container mx-auto px-4">
          <div className="text-center mb-12">
            <h3 className="text-3xl font-bold text-gray-800 mb-4">
              How DocHub Works For Providers
            </h3>
            <p className="text-lg text-gray-600 max-w-2xl mx-auto">
              Get started in three simple steps and see your first patient
              within 24 hours.
            </p>
          </div>
          <div className="grid md:grid-cols-3 gap-8">
            <div className="text-center">
              <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-2xl font-bold text-blue-700">1</span>
              </div>
              <h4 className="text-xl font-semibold text-gray-800 mb-2">
                Register & Verify
              </h4>
              <p className="text-gray-600">
                Complete our streamlined registration process and verification.
                Our team will validate your credentials within hours.
              </p>
            </div>
            <div className="text-center">
              <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-2xl font-bold text-blue-700">2</span>
              </div>
              <h4 className="text-xl font-semibold text-gray-800 mb-2">
                Set Your Schedule
              </h4>
              <p className="text-gray-600">
                Define your availability and consultation fees. Our platform
                automatically adapts to your time zone and practice
                requirements.
              </p>
            </div>
            <div className="text-center">
              <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-2xl font-bold text-blue-700">3</span>
              </div>
              <h4 className="text-xl font-semibold text-gray-800 mb-2">
                Start Seeing Patients
              </h4>
              <p className="text-gray-600">
                Connect with patients through our mobile app or web platform.
                All consultations, records, and billing are handled seamlessly.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Testimonials Section */}
      <section className="bg-white py-16 relative z-10">
        <div className="container mx-auto px-4">
          <h3 className="text-3xl font-bold text-gray-800 text-center mb-12">
            What Doctors Say About Us
          </h3>
          <div className="grid md:grid-cols-3 gap-8">
            <div className="bg-blue-50 p-6 rounded-lg">
              <div className="flex items-center mb-4">
                <div className="w-12 h-12 bg-blue-200 rounded-full mr-4"></div>
                <div>
                  <h5 className="font-semibold">Dr. James Wilson</h5>
                  <p className="text-sm text-gray-500">
                    Cardiologist, 8 years with DocHub
                  </p>
                </div>
              </div>
              <p className="text-gray-600 italic">
                "DocHub has changed how I practice medicine. I've been able to
                reach more patients, reduce overhead costs, and actually improve
                patient satisfaction scores by 32%."
              </p>
            </div>
            <div className="bg-blue-50 p-6 rounded-lg">
              <div className="flex items-center mb-4">
                <div className="w-12 h-12 bg-blue-200 rounded-full mr-4"></div>
                <div>
                  <h5 className="font-semibold">Dr. Lisa Chen</h5>
                  <p className="text-sm text-gray-500">
                    Family Medicine, 5 years with DocHub
                  </p>
                </div>
              </div>
              <p className="text-gray-600 italic">
                "As a busy physician with two young children, DocHub has given
                me the flexibility to maintain my practice while balancing
                family life. The documentation tools alone save me 2 hours
                daily."
              </p>
            </div>
            <div className="bg-blue-50 p-6 rounded-lg">
              <div className="flex items-center mb-4">
                <div className="w-12 h-12 bg-blue-200 rounded-full mr-4"></div>
                <div>
                  <h5 className="font-semibold">Dr. Marcus Johnson</h5>
                  <p className="text-sm text-gray-500">
                    Psychiatrist, 3 years with DocHub
                  </p>
                </div>
              </div>
              <p className="text-gray-600 italic">
                "For mental health providers, DocHub offers unique advantages.
                My patients are more comfortable, show up more consistently, and
                the platform's security features ensure confidentiality."
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Revenue Section */}
      <section className="bg-blue-700 py-16 text-white relative z-10">
        <div className="container mx-auto px-4">
          <div className="flex flex-col md:flex-row items-center">
            <div className="md:w-1/2 mb-8 md:mb-0">
              <h3 className="text-3xl font-bold mb-4">
                Increase Your Practice Revenue
              </h3>
              <p className="text-xl mb-6">
                Doctors using DocHub report an average 26% increase in practice
                revenue within the first 6 months.
              </p>
              <ul className="space-y-3">
                <li className="flex items-center">
                  <svg
                    className="w-5 h-5 mr-2"
                    fill="currentColor"
                    viewBox="0 0 20 20"
                    xmlns="http://www.w3.org/2000/svg"
                  >
                    <path
                      fillRule="evenodd"
                      d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                      clipRule="evenodd"
                    />
                  </svg>
                  <span>Reduce overhead costs by up to 40%</span>
                </li>
                <li className="flex items-center">
                  <svg
                    className="w-5 h-5 mr-2"
                    fill="currentColor"
                    viewBox="0 0 20 20"
                    xmlns="http://www.w3.org/2000/svg"
                  >
                    <path
                      fillRule="evenodd"
                      d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                      clipRule="evenodd"
                    />
                  </svg>
                  <span>
                    Minimize no-shows (2% vs. industry average of 18%)
                  </span>
                </li>
                <li className="flex items-center">
                  <svg
                    className="w-5 h-5 mr-2"
                    fill="currentColor"
                    viewBox="0 0 20 20"
                    xmlns="http://www.w3.org/2000/svg"
                  >
                    <path
                      fillRule="evenodd"
                      d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                      clipRule="evenodd"
                    />
                  </svg>
                  <span>Streamlined billing with 94% clean claim rate</span>
                </li>
                <li className="flex items-center">
                  <svg
                    className="w-5 h-5 mr-2"
                    fill="currentColor"
                    viewBox="0 0 20 20"
                    xmlns="http://www.w3.org/2000/svg"
                  >
                    <path
                      fillRule="evenodd"
                      d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                      clipRule="evenodd"
                    />
                  </svg>
                  <span>See more patients with efficient scheduling</span>
                </li>
              </ul>
            </div>
            <div className="md:w-1/2 md:pl-12">
              <div className="bg-white p-6 rounded-lg shadow-lg text-gray-800">
                <h4 className="text-xl font-bold mb-4 text-blue-700">
                  Average Additional Annual Income
                </h4>
                <div className="space-y-4">
                  <div className="flex justify-between items-center pb-2 border-b border-gray-200">
                    <span className="font-medium">Primary Care</span>
                    <span className="font-bold">-----</span>
                  </div>
                  <div className="flex justify-between items-center pb-2 border-b border-gray-200">
                    <span className="font-medium">Cardiology</span>
                    <span className="font-bold">-----</span>
                  </div>
                  <div className="flex justify-between items-center pb-2 border-b border-gray-200">
                    <span className="font-medium">Dermatology</span>
                    <span className="font-bold">-----</span>
                  </div>
                  <div className="flex justify-between items-center pb-2 border-b border-gray-200">
                    <span className="font-medium">Psychiatry</span>
                    <span className="font-bold">-----</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="font-medium">Pediatrics</span>
                    <span className="font-bold">-----</span>
                  </div>
                </div>
                <div className="mt-6">
                  <Link to="/roi-calculator">
                    <button className="w-full py-2 bg-blue-700 text-white rounded-md hover:bg-blue-800 transition duration-200 font-medium">
                      Calculate Your Potential Revenue
                    </button>
                  </Link>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-16">
        <div className="container mx-auto px-4 text-center">
          <h3 className="text-3xl font-bold text-gray-800 mb-4">
            Ready to Transform Your Practice?
          </h3>
          <p className="text-xl mb-8 max-w-2xl mx-auto text-gray-600">
            Join our network of healthcare providers delivering exceptional care
            through telemedicine.
          </p>
          <div className="flex flex-col sm:flex-row justify-center gap-4">
            <Link to="/register">
              <button className="px-8 py-3 bg-blue-700 text-white rounded-md font-medium hover:bg-blue-800 transition duration-200">
                Register Your Practice
              </button>
            </Link>
            <Link to="/demo">
              <button className="px-8 py-3 bg-transparent border-2 border-blue-700 text-blue-700 rounded-md font-medium hover:bg-blue-50 transition duration-200">
                Request a Demo
              </button>
            </Link>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-800 text-white py-12">
        <div className="container mx-auto px-4">
          <div className="grid md:grid-cols-4 gap-8">
            <div>
              <h4 className="text-xl font-bold mb-4 flex items-center">
                <svg
                  className="w-6 h-6 mr-2"
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
                DocHub
              </h4>
              <p className="text-gray-400">
                Empowering physicians with tools to provide exceptional care
                through telemedicine.
              </p>
            </div>
            <div>
              <h5 className="font-semibold mb-4">Company</h5>
              <ul className="space-y-2">
                <li>
                  <Link
                    to="/about"
                    className="text-gray-400 hover:text-white transition duration-200"
                  >
                    About Us
                  </Link>
                </li>
                <li>
                  <Link
                    to="/leadership"
                    className="text-gray-400 hover:text-white transition duration-200"
                  >
                    Medical Leadership
                  </Link>
                </li>
                <li>
                  <Link
                    to="/careers"
                    className="text-gray-400 hover:text-white transition duration-200"
                  >
                    Careers
                  </Link>
                </li>
                <li>
                  <Link
                    to="/contact"
                    className="text-gray-400 hover:text-white transition duration-200"
                  >
                    Contact
                  </Link>
                </li>
              </ul>
            </div>
            <div>
              <h5 className="font-semibold mb-4">Resources</h5>
              <ul className="space-y-2">
                <li>
                  <Link
                    to="/provider-resources"
                    className="text-gray-400 hover:text-white transition duration-200"
                  >
                    Provider Resources
                  </Link>
                </li>
                <li>
                  <Link
                    to="/cme"
                    className="text-gray-400 hover:text-white transition duration-200"
                  >
                    CME Opportunities
                  </Link>
                </li>
                <li>
                  <Link
                    to="/telemedicine-guides"
                    className="text-gray-400 hover:text-white transition duration-200"
                  >
                    Telemedicine Guides
                  </Link>
                </li>
                <li>
                  <Link
                    to="/integrations"
                    className="text-gray-400 hover:text-white transition duration-200"
                  >
                    EHR Integrations
                  </Link>
                </li>
              </ul>
            </div>
            <div>
              <h5 className="font-semibold mb-4">Legal</h5>
              <ul className="space-y-2">
                <li>
                  <Link
                    to="/terms"
                    className="text-gray-400 hover:text-white transition duration-200"
                  >
                    Terms of Service
                  </Link>
                </li>
                <li>
                  <Link
                    to="/privacy"
                    className="text-gray-400 hover:text-white transition duration-200"
                  >
                    Privacy Policy
                  </Link>
                </li>
                <li>
                  <Link
                    to="/hipaa"
                    className="text-gray-400 hover:text-white transition duration-200"
                  >
                    HIPAA Compliance
                  </Link>
                </li>
                <li>
                  <Link
                    to="/disclaimers"
                    className="text-gray-400 hover:text-white transition duration-200"
                  >
                    Disclaimers
                  </Link>
                </li>
              </ul>
            </div>
          </div>
          <div className="border-t border-gray-700 mt-8 pt-8 flex flex-col md:flex-row justify-between items-center">
            <div className="text-gray-400 mb-4 md:mb-0">
              &copy; {new Date().getFullYear()} DocHub, Inc. All rights
              reserved.
            </div>
            <div className="flex space-x-4">
              <a
                href="#"
                className="text-gray-400 hover:text-white transition duration-200"
              >
                <svg
                  className="w-6 h-6"
                  fill="currentColor"
                  viewBox="0 0 24 24"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path d="M22 12c0-5.523-4.477-10-10-10S2 6.477 2 12c0 4.991 3.657 9.128 8.438 9.878v-6.987h-2.54V12h2.54V9.797c0-2.506 1.492-3.89 3.777-3.89 1.094 0 2.238.195 2.238.195v2.46h-1.26c-1.243 0-1.63.771-1.63 1.562V12h2.773l-.443 2.89h-2.33v6.988C18.343 21.128 22 16.991 22 12z" />
                </svg>
              </a>
              <a
                href="#"
                className="text-gray-400 hover:text-white transition duration-200"
              >
                <svg
                  className="w-6 h-6"
                  fill="currentColor"
                  viewBox="0 0 24 24"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path d="M8.29 20.251c7.547 0 11.675-6.253 11.675-11.675 0-.178 0-.355-.012-.53A8.348 8.348 0 0022 5.92a8.19 8.19 0 01-2.357.646 4.118 4.118 0 001.804-2.27 8.224 8.224 0 01-2.605.996 4.107 4.107 0 00-6.993 3.743 11.65 11.65 0 01-8.457-4.287 4.106 4.106 0 001.27 5.477A4.072 4.072 0 012.8 9.713v.052a4.105 4.105 0 003.292 4.022 4.095 4.095 0 01-1.853.07 4.108 4.108 0 003.834 2.85A8.233 8.233 0 012 18.407a11.616 11.616 0 006.29 1.84" />
                </svg>
              </a>
              <a
                href="#"
                className="text-gray-400 hover:text-white transition duration-200"
              >
                <svg
                  className="w-6 h-6"
                  fill="currentColor"
                  viewBox="0 0 24 24"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z" />
                </svg>
              </a>
              <a
                href="#"
                className="text-gray-400 hover:text-white transition duration-200"
              >
                <svg
                  className="w-6 h-6"
                  fill="currentColor"
                  viewBox="0 0 24 24"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z" />
                </svg>
              </a>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default Homepage;