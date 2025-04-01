import React, { useState } from 'react';
import { Link } from 'react-router-dom';

const Homepage: React.FC = () => {
  const [userType, setUserType] = useState<'patient' | 'doctor'>('patient');

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-gray-100">
      {/* Navbar */}
      <nav className="sticky top-0 z-50 bg-white shadow-lg">
        <div className="container mx-auto px-6 py-4 flex items-center justify-between">
          <div className="flex items-center">
            <svg className="w-10 h-10 text-blue-600 mr-3" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
              <path fillRule="evenodd" d="M5 4a3 3 0 00-3 3v6a3 3 0 003 3h10a3 3 0 003-3V7a3 3 0 00-3-3H5zm-1 9v-1h5v2H5a1 1 0 01-1-1zm7 1h4a1 1 0 001-1v-1h-5v2zm0-4h5V8h-5v2zM9 8H4v2h5V8z" clipRule="evenodd" />
            </svg>
            <h1 className="text-2xl font-extrabold text-blue-700 tracking-tight">TeleDoc</h1>
          </div>
          <div className="hidden md:flex items-center space-x-8">
            <Link to="/features" className="text-gray-700 font-medium hover:text-blue-600 transition duration-300">Features</Link>
            <Link to="/faq" className="text-gray-700 font-medium hover:text-blue-600 transition duration-300">FAQ</Link>
            <Link to="/pricing" className="text-gray-700 font-medium hover:text-blue-600 transition duration-300">Pricing</Link>
            <Link to="/login">
              <button className="px-5 py-2 text-blue-600 border-2 border-blue-600 rounded-full hover:bg-blue-50 hover:text-blue-700 transition duration-300 font-semibold">
                Login
              </button>
            </Link>
            <Link to="/register">
              <button className="px-5 py-2 bg-blue-600 text-white rounded-full hover:bg-blue-700 transition duration-300 font-semibold shadow-md">
                Sign Up
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

      {/* Hero Section */}
      <section className="container mx-auto px-6 py-16 md:py-24 flex flex-col md:flex-row items-center justify-between">
        <div className="md:w-1/2 mb-12 md:mb-0 pr-0 md:pr-12 animate-fade-in-up">
          <h2 className="text-4xl md:text-6xl font-extrabold text-gray-900 mb-6 leading-tight">
            Healthcare <span className="text-blue-600">Reimagined</span>
          </h2>
          <p className="text-xl text-gray-600 mb-8 leading-relaxed">
            Connect with patients seamlessly through secure video consultations. Manage appointments, prescriptions, and records—all in one intuitive platform.
          </p>
          <div className="bg-white p-8 rounded-xl shadow-2xl">
            <div className="flex mb-6 border-b border-gray-200">
              <button
                className={`pb-3 px-6 font-semibold text-lg ${userType === 'patient' 
                  ? 'text-blue-600 border-b-2 border-blue-600' 
                  : 'text-gray-500 hover:text-gray-700'}`}
                onClick={() => setUserType('patient')}
              >
                For Patients
              </button>
              <button
                className={`pb-3 px-6 font-semibold text-lg ${userType === 'doctor' 
                  ? 'text-blue-600 border-b-2 border-blue-600' 
                  : 'text-gray-500 hover:text-gray-700'}`}
                onClick={() => setUserType('doctor')}
              >
                For Doctors
              </button>
            </div>
            <div className="space-y-5">
              <input
                type="email"
                placeholder="Email Address"
                className="w-full p-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 transition duration-200"
              />
              <input
                type="password"
                placeholder="Password"
                className="w-full p-4 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 transition duration-200"
              />
              <button className="w-full py-4 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition duration-300 font-semibold shadow-md">
                {userType === 'patient' ? 'Sign Up as Patient' : 'Sign Up as Doctor'}
              </button>
            </div>
            <div className="mt-5 text-center text-sm text-gray-500">
              Already have an account? <Link to="/login" className="text-blue-600 hover:underline font-medium">Log in</Link>
            </div>
          </div>
        </div>
        <div className="md:w-1/2 animate-fade-in-right">
          <div className="relative">
            <div className="absolute inset-0 bg-blue-600 rounded-xl transform rotate-2 opacity-75 blur-md"></div>
            <img 
              src="https://via.placeholder.com/600x400" // Replace with a real image URL
              alt="Doctor consulting patient online" 
              className="relative rounded-xl shadow-xl hover:scale-105 transition-transform duration-300"
            />
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="bg-gray-50 py-20">
        <div className="container mx-auto px-6">
          <div className="text-center mb-16">
            <h3 className="text-4xl font-bold text-gray-900 mb-5">Why Choose TeleDoc?</h3>
            <p className="text-xl text-gray-600 max-w-3xl mx-auto">
              Streamline your practice and enhance patient care with our cutting-edge telemedicine platform.
            </p>
          </div>
          <div className="grid md:grid-cols-3 gap-10">
            {[
              { icon: "M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z", title: "HD Video Consultations", desc: "Crystal-clear, encrypted video calls for seamless patient interaction." },
              { icon: "M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z", title: "Smart Scheduling", desc: "AI-driven scheduling to minimize no-shows and optimize your time." },
              { icon: "M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z", title: "Digital Prescriptions", desc: "Securely send e-prescriptions with ease and compliance." },
              { icon: "M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z", title: "HIPAA Compliant", desc: "End-to-end encryption ensures patient data privacy." },
              { icon: "M17 8h2a2 2 0 012 2v6a2 2 0 01-2 2h-2v4l-4-4H9a1.994 1.994 0 01-1.414-.586m0 0L11 14h4a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2v4l.586-.586z", title: "Patient Messaging", desc: "Secure in-app messaging for quick follow-ups." },
              { icon: "M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z", title: "Analytics Dashboard", desc: "Actionable insights to grow your practice." },
            ].map((feature, index) => (
              <div key={index} className="bg-white p-8 rounded-xl shadow-lg hover:shadow-xl transition duration-300 transform hover:-translate-y-2">
                <div className="w-14 h-14 bg-blue-100 rounded-full flex items-center justify-center mb-5">
                  <svg className="w-7 h-7 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d={feature.icon} />
                  </svg>
                </div>
                <h4 className="text-xl font-semibold text-gray-900 mb-3">{feature.title}</h4>
                <p className="text-gray-600">{feature.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Testimonials Section */}
      <section className="py-20 bg-white">
        <div className="container mx-auto px-6">
          <h3 className="text-4xl font-bold text-gray-900 text-center mb-16">Trusted by Professionals</h3>
          <div className="grid md:grid-cols-3 gap-10">
            {[
              { name: "Dr. Sarah Johnson", role: "Cardiologist", quote: "TeleDoc has transformed my practice with its reliability and ease of use." },
              { name: "Dr. Michael Chen", role: "Family Medicine", quote: "The scheduling system saves hours—patients love the convenience." },
              { name: "Dr. Emily Rodriguez", role: "Pediatrician", quote: "Remote follow-ups with kids are a game-changer. Secure and supportive." },
            ].map((testimonial, index) => (
              <div key={index} className="bg-gray-50 p-8 rounded-xl shadow-md hover:shadow-lg transition duration-300">
                <div className="flex items-center mb-5">
                  <div className="w-14 h-14 bg-gray-300 rounded-full mr-4"></div>
                  <div>
                    <h5 className="font-semibold text-lg text-gray-900">{testimonial.name}</h5>
                    <p className="text-sm text-gray-500">{testimonial.role}</p>
                  </div>
                </div>
                <p className="text-gray-600 italic">"{testimonial.quote}"</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="bg-gradient-to-r from-blue-600 to-blue-800 py-20 text-white">
        <div className="container mx-auto px-6 text-center">
          <h3 className="text-4xl font-bold mb-6">Ready to Transform Your Practice?</h3>
          <p className="text-xl mb-10 max-w-2xl mx-auto">
            Join thousands of providers delivering care efficiently with TeleDoc.
          </p>
          <div className="flex flex-col sm:flex-row justify-center gap-6">
            <Link to="/register">
              <button className="px-10 py-4 bg-white text-blue-600 rounded-full font-semibold hover:bg-blue-50 transition duration-300 shadow-lg">
                Sign Up Now
              </button>
            </Link>
            <Link to="/demo">
              <button className="px-10 py-4 bg-transparent border-2 border-white rounded-full font-semibold hover:bg-blue-700 transition duration-300">
                Request a Demo
              </button>
            </Link>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 text-white py-16">
        <div className="container mx-auto px-6">
          <div className="grid md:grid-cols-4 gap-12">
            <div>
              <h4 className="text-2xl font-bold mb-6 flex items-center">
                <svg className="w-7 h-7 mr-3" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
                  <path fillRule="evenodd" d="M5 4a3 3 0 00-3 3v6a3 3 0 003 3h10a3 3 0 003-3V7a3 3 0 00-3-3H5zm-1 9v-1h5v2H5a1 1 0 01-1-1zm7 1h4a1 1 0 001-1v-1h-5v2zm0-4h5V8h-5v2zM9 8H4v2h5V8z" clipRule="evenodd" />
                </svg>
                TeleDoc
              </h4>
              <p className="text-gray-400">
                Secure telemedicine solutions for healthcare providers and patients.
              </p>
            </div>
            <div>
              <h5 className="font-semibold text-lg mb-5">Company</h5>
              <ul className="space-y-3">
                <li><Link to="/about" className="text-gray-400 hover:text-white transition duration-300">About Us</Link></li>
                <li><Link to="/careers" className="text-gray-400 hover:text-white transition duration-300">Careers</Link></li>
                <li><Link to="/blog" className="text-gray-400 hover:text-white transition duration-300">Blog</Link></li>
                <li><Link to="/contact" className="text-gray-400 hover:text-white transition duration-300">Contact</Link></li>
              </ul>
            </div>
            <div>
              <h5 className="font-semibold text-lg mb-5">Resources</h5>
              <ul className="space-y-3">
                <li><Link to="/support" className="text-gray-400 hover:text-white transition duration-300">Help Center</Link></li>
                <li><Link to="/guides" className="text-gray-400 hover:text-white transition duration-300">User Guides</Link></li>
                <li><Link to="/webinars" className="text-gray-400 hover:text-white transition duration-300">Webinars</Link></li>
                <li><Link to="/api" className="text-gray-400 hover:text-white transition duration-300">API Docs</Link></li>
              </ul>
            </div>
            <div>
              <h5 className="font-semibold text-lg mb-5">Legal</h5>
              <ul className="space-y-3">
                <li><Link to="/privacy" className="text-gray-400 hover:text-white transition duration-300">Privacy Policy</Link></li>
                <li><Link to="/terms" className="text-gray-400 hover:text-white transition duration-300">Terms of Service</Link></li>
                <li><Link to="/hipaa" className="text-gray-400 hover:text-white transition duration-300">HIPAA Compliance</Link></li>
                <li><Link to="/security" className="text-gray-400 hover:text-white transition duration-300">Security</Link></li>
              </ul>
            </div>
          </div>
          <div className="border-t border-gray-800 mt-12 pt-8 flex flex-col md:flex-row items-center justify-between">
            <p className="text-gray-400 text-sm mb-4 md:mb-0">
              © 2025 TeleDoc. All rights reserved.
            </p>
            <div className="flex space-x-6">
              {['facebook', 'twitter', 'linkedin', 'instagram'].map((platform, index) => (
                <a key={index} href="#" className="text-gray-400 hover:text-white transition duration-300">
                  <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path d={platform === 'facebook' ? "M22 12c0-5.523-4.477-10-10-10S2 6.477 2 12c0 4.991 3.657 9.128 8.438 9.878v-6.987h-2.54V12h2.54V9.797c0-2.506 1.492-3.89 3.777-3.89 1.094 0 2.238.195 2.238.195v2.46h-1.26c-1.243 0-1.63.771-1.63 1.562V12h2.773l-.443 2.89h-2.33v6.988C18.343 21.128 22 16.991 22 12z" : 
                            platform === 'twitter' ? "M8.29 20.251c7.547 0 11.675-6.253 11.675-11.675 0-.178 0-.355-.012-.53A8.348 8.348 0 0022 5.92a8.19 8.19 0 01-2.357.646 4.118 4.118 0 001.804-2.27 8.224 8.224 0 01-2.605.996 4.107 4.107 0 00-6.993 3.743 11.65 11.65 0 01-8.457-4.287 4.106 4.106 0 001.27 5.477A4.072 4.072 0 012.8 9.713v.052a4.105 4.105 0 003.292 4.022 4.095 4.095 0 01-1.853.07 4.108 4.108 0 003.834 2.85A8.233 8.233 0 012 18.407a11.616 11.616 0 006.29 1.84" :
                            platform === 'linkedin' ? "M19 0h-14c-2.761 0-5 2.239-5 5v14c0 2.761 2.239 5 5 5h14c2.762 0 5-2.239 5-5v-14c0-2.761-2.238-5-5-5zm-11 19h-3v-11h3v11zm-1.5-12.268c-.966 0-1.75-.79-1.75-1.764s.784-1.764 1.75-1.764 1.75.79 1.75 1.764-.783 1.764-1.75 1.764zm13.5 12.268h-3v-5.604c0-3.368-4-3.113-4 0v5.604h-3v-11h3v1.765c1.396-2.586 7-2.777 7 2.476v6.759z" :
                            "M12 0C5.373 0 0 5.373 0 12s5.373 12 12 12 12-5.373 12-12S18.627 0 12 0zm6 13.792c0 2.395-1.958 4.335-4.375 4.335H10.25A4.321 4.321 0 015.875 13.8v-3.6C5.875 7.805 7.833 5.865 10.25 5.865h3.375c2.417 0 4.375 1.94 4.375 4.335v3.592z"} />
                  </svg>
                </a>
              ))}
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default Homepage;