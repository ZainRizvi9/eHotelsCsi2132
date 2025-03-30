import './App.css';
import React, { Fragment, useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, useNavigate, Navigate } from 'react-router-dom';  // Only this import

import ListHotels from './components/hotelComponents/ListHotels';
import ListRooms from './components/roomComponents/ListRooms';
import Login from './components/auth/Login';
import Signup from './components/auth/Signup';
import CustomerDashboard from './components/dashboard/CustomerDashboard';
import EmployeeDashboard from './components/dashboard/EmployeeDashboard';
import ProtectedRoute from './components/ProtectedRoute';
import HotelRoomsPage from './pages/HotelRoomsPage';

function HomePage({
  handleLoginClick,
  handleSignupClick,
  handleLogout,
  user
}) {
  return (
    <Fragment>
      <div className="header">
        <button onClick={() => window.location.href = '/'}>Home</button>
        {user && (
          <>
            <button onClick={() => window.location.href = '/hotels'}>Hotels</button>
            <button onClick={() => window.location.href = '/rooms'}>Rooms</button>
          </>
        )}
        {!user ? (
          <>
            <button onClick={handleLoginClick}>Login</button>
            <button onClick={handleSignupClick}>Signup</button>
          </>
        ) : (
          <button onClick={handleLogout}>Logout</button>
        )}
      </div>

      <div className="container">
        <div className="text">
          <p>Welcome to eHotel System</p>
        </div>
      </div>
    </Fragment>
  );
}

function AppWrapper() {
  const [user, setUser] = useState(null);
  const [showLogin, setShowLogin] = useState(false);
  const [showSignup, setShowSignup] = useState(false);

  const navigate = useNavigate();

  useEffect(() => {
    const storedUser = localStorage.getItem('ehotel_user');
    if (storedUser) setUser(JSON.parse(storedUser));
  }, []);

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('ehotel_user');
    setUser(null);
    navigate('/');
  };

  const handleLoginClick = () => {
    setShowLogin(true);
    setShowSignup(false);
    navigate('/');
  };

  const handleSignupClick = () => {
    setShowSignup(true);
    setShowLogin(false);
    navigate('/');
  };

  return (
    <Routes>
      <Route
        path="/"
        element={
          <>
            <HomePage
              user={user}
              handleLoginClick={handleLoginClick}
              handleSignupClick={handleSignupClick}
              handleLogout={handleLogout}
            />
            {showLogin && <Login setUser={setUser} />}
            {showSignup && <Signup />}
          </>
        }
      />

      <Route
        path="/hotels"
        element={
          user ? (
            <div className="container">
              <ListHotels allowFilters={true} />
            </div>
          ) : (
            <Navigate to="/" />
          )
        }
      />

      <Route
        path="/rooms"
        element={
          user ? (
            <div className="container">
              <ListRooms allowFilters={true} />
            </div>
          ) : (
            <Navigate to="/" />
          )
        }
      />

      <Route
        path="/dashboard/customer"
        element={
          <ProtectedRoute user={user} allowedRoles={['customer']}>
            <CustomerDashboard user={user} />
          </ProtectedRoute>
        }
      />

      <Route path="/hotel-rooms" element={<HotelRoomsPage />} />

      <Route
        path="/dashboard/employee"
        element={
          <ProtectedRoute user={user} allowedRoles={['employee']}>
            <EmployeeDashboard user={user} />
          </ProtectedRoute>
        }
      />
    </Routes>
  );
}

export default function RootApp() {
  return (
    <Router>
      <AppWrapper />
    </Router>
  );
}
