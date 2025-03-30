import React, { useEffect, useState, useCallback } from 'react';
import DashboardHeader from '../shared/DashboardHeader';

const CustomerDashboard = () => {
  const [availableRooms, setAvailableRooms] = useState([]);
  const [bookings, setBookings] = useState([]);
  const [bookingDetails, setBookingDetails] = useState({
    roomNumber: '', 
    hotelId: '', 
    companyName: '', 
    startDate: '', 
    endDate: ''
  });

  const token = localStorage.getItem('token');

  const fetchAvailableRooms = useCallback(async () => {
    try {
      const response = await fetch("http://localhost:5001/api/room/available", {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });
      if (!response.ok) {
        throw new Error("Failed to fetch rooms");
      }
      const data = await response.json();
      setAvailableRooms(data);
    } catch (err) {
      console.error("Error fetching rooms:", err);
    }
  }, [token]);

  const fetchMyBookings = useCallback(async () => {
    try {
      const res = await fetch('http://localhost:5001/api/dashboard/customer/bookings', {
        headers: { Authorization: `Bearer ${token}` }
      });
      const data = await res.json();
      setBookings(data);
    } catch (err) {
      console.error('Error fetching bookings:', err);
    }
  }, [token]);

  useEffect(() => {
    fetchAvailableRooms();
    fetchMyBookings();
  }, [fetchAvailableRooms, fetchMyBookings]);

  const handleBooking = async (e) => {
    e.preventDefault();
    try {
      const res = await fetch('http://localhost:5001/api/bookings', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`
        },
        body: JSON.stringify(bookingDetails)
      });
      if (res.ok) {
        alert('Booking successful!');
        fetchMyBookings(); // Refresh bookings after successful booking
      } else {
        const data = await res.json();
        alert(data.error || 'Booking failed');
      }
    } catch (err) {
      console.error(err);
      alert('Booking error');
    }
  };

  const handleInput = (e) => {
    setBookingDetails({ ...bookingDetails, [e.target.name]: e.target.value });
  };

  return (
    <div>
      <DashboardHeader />
      <div className="container mt-4">
        <h2>Welcome, Customer</h2>

        {/* Available Rooms */}
        <h4 className="mt-4">📋 Available Rooms</h4>
        <table className="table">
          <thead>
            <tr>
              <th>Room</th>
              <th>Hotel</th>
              <th>Company</th>
              <th>Price</th>
              <th>Capacity</th>
            </tr>
          </thead>
          <tbody>
            {availableRooms.map((room, idx) => (
              <tr key={idx}>
                <td>{room.roomnumber}</td>
                <td>{room.hotelid}</td>
                <td>{room.companyname}</td>
                <td>${room.price}</td>
                <td>{room.capacity}</td>
              </tr>
            ))}
          </tbody>
        </table>

        {/* Booking Form */}
        <h4 className="mt-4">📅 Book a Room</h4>
        <form onSubmit={handleBooking}>
          <div className="form-group">
            <label>Room Number</label>
            <input type="number" name="roomNumber" className="form-control" onChange={handleInput} required />
          </div>
          <div className="form-group">
            <label>Hotel ID</label>
            <input type="number" name="hotelId" className="form-control" onChange={handleInput} required />
          </div>
          <div className="form-group">
            <label>Company Name</label>
            <input type="text" name="companyName" className="form-control" onChange={handleInput} required />
          </div>
          <div className="form-group">
            <label>Start Date</label>
            <input type="date" name="startDate" className="form-control" onChange={handleInput} required />
          </div>
          <div className="form-group">
            <label>End Date</label>
            <input type="date" name="endDate" className="form-control" onChange={handleInput} required />
          </div>
          <button type="submit" className="btn btn-primary mt-2">Book Room</button>
        </form>

        {/* User Bookings */}
        <h4 className="mt-5">📦 My Bookings</h4>
        <table className="table">
          <thead>
            <tr>
              <th>Booking ID</th>
              <th>Room</th>
              <th>Hotel</th>
              <th>Company</th>
              <th>From</th>
              <th>To</th>
            </tr>
          </thead>
          <tbody>
            {bookings.map((b, idx) => (
              <tr key={idx}>
                <td>{b.bookingid}</td>
                <td>{b.roomnumber}</td>
                <td>{b.hotelid}</td>
                <td>{b.companyname}</td>
                <td>{b.startdate}</td>
                <td>{b.enddate}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default CustomerDashboard;
