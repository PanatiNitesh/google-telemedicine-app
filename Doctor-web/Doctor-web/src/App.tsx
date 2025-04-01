import React from 'react';
import { Routes, Route } from 'react-router-dom';
import Homepage from './pages/homepage';


const Login: React.FC = () => <h2>Doctor Login Page (To be implemented)</h2>;
const Register: React.FC = () => <h2>Doctor Registration Page (To be implemented)</h2>;

const App: React.FC = () => {
  return (
    <Routes>
      <Route path="/" element={<Homepage />} />
      <Route path="/login" element={<Login />} />
      <Route path="/register" element={<Register />} />
      <Route path="/features" element={<h2>Features Page (To be implemented)</h2>} />
      <Route path="/faq" element={<h2>FAQ Page (To be implemented)</h2>} />
    </Routes>
  );
};

export default App;