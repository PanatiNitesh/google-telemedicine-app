import React from 'react';
import { Routes, Route } from 'react-router-dom';
import Homepage from './pages/homepage';
import DoctorRegistrationForm  from './pages/Register';
import LoginPage from './pages/Loginpage';
import DoctorVideoConsultation from './pages/videoconsult';
import PatientVideoConsultation from './pages/PatientVideoConsultation';

const App: React.FC = () => {
  return (
    <Routes>
      <Route path="/" element={<Homepage />} />
      <Route path="/login" element={<LoginPage />} />
      <Route path="/register" element={<DoctorRegistrationForm />} />
      <Route path="/faq" element={<h2>FAQ Page (To be implemented)</h2>} />
      <Route path="/features" element={<DoctorVideoConsultation doctorId="DOC333592508" userId="PAT123" />} />
      <Route path="/patient" element={<PatientVideoConsultation doctorId="DOC333592508" userId="PAT123" />} />
    
    </Routes>
  );
};

export default App;