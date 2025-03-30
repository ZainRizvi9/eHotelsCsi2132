// DashboardHeader.js
import React from 'react';
import { useNavigate } from 'react-router-dom';

const DashboardHeader = () => {
  const navigate = useNavigate();

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('ehotel_user');
    navigate('/');
  };

  return (
    <div className="dashboard-header">
      <button onClick={handleLogout}>Logout</button>
    </div>
  );
};

export default DashboardHeader;
