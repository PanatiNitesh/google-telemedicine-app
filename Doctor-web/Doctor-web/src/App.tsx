import React from 'react';
import { Routes, Route } from 'react-router-dom';
import Homepage from './pages/homepage';
import DoctorRegistrationForm  from './pages/Register';
import LoginPage from './pages/Loginpage';

const App: React.FC = () => {
  return (
    <Routes>
      <Route path="/" element={<Homepage />} />
      <Route path="/login" element={<LoginPage />} />
      <Route path="/register" element={<DoctorRegistrationForm />} />
      <Route path="/features" element={<h2>Features Page (To be implemented)</h2>} />
      <Route path="/faq" element={<h2>FAQ Page (To be implemented)</h2>} />
    </Routes>
  );
};

export default App;