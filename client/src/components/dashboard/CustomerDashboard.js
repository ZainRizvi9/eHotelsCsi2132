import React, { useEffect, useState, useCallback } from 'react';
import DashboardHeader from '../shared/DashboardHeader';

const CustomerDashboard = () => {
  const [availableRooms, setAvailableRooms] = useState([]);
  const [bookings, setBookings] = useState([]);
  const [filters, setFilters] = useState({
    startDate: '',
    endDate: '',
    capacity: '',
    city: '',
    companyName: '',
    category: '',
    totalRooms: '',
    minPrice: '',
    maxPrice: ''
  });

  const token = localStorage.getItem('token');

  const fetchAvailableRooms = useCallback(async () => {
    try {
      const queryString = new URLSearchParams(filters).toString();
      const response = await fetch(
        `http://localhost:5001/api/dashboard/available-rooms?${queryString}`,
        {
          headers: { Authorization: `Bearer ${token}` }
        }
      );
      if (!response.ok) throw new Error('Failed to fetch rooms');
      const data = await response.json();
      setAvailableRooms(data);
    } catch (err) {
      console.error('Error fetching rooms:', err);
    }
  }, [token, filters]);

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

  const handleFilterChange = (e) => {
    setFilters({ ...filters, [e.target.name]: e.target.value });
  };

  const handleBookRoom = async (room) => {
    const startDate = prompt("Enter start date (YYYY-MM-DD):");
    const endDate = prompt("Enter end date (YYYY-MM-DD):");
    if (!startDate || !endDate) return alert("Both dates are required.");

    try {
      const res = await fetch('http://localhost:5001/api/bookings', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`
        },
        body: JSON.stringify({
          roomNumber: room.roomnumber,
          hotelId: room.hotelid,
          companyName: room.companyname,
          startDate,
          endDate
        })
      });
      if (res.ok) {
        alert('Booking successful!');
        fetchMyBookings();
      } else {
        const data = await res.json();
        alert(data.error || 'Booking failed');
      }
    } catch (err) {
      console.error('Booking error:', err);
      alert('Booking error');
    }
  };

  return (
    <div>
      <DashboardHeader />
      <div className="container mt-4">
        <h2>Welcome, Customer</h2>

        {/* Room Filters */}
        <div className="filter-section">
          <h4>🔍 Filter Available Rooms</h4>
          <input type="date" name="startDate" className="form-control" onChange={handleFilterChange} />
          <input type="date" name="endDate" className="form-control" onChange={handleFilterChange} />
          <input type="text" name="capacity" placeholder="Capacity (e.g. Single)" className="form-control" onChange={handleFilterChange} />
          <input type="text" name="city" placeholder="City" className="form-control" onChange={handleFilterChange} />
          <input type="text" name="companyName" placeholder="Hotel Chain" className="form-control" onChange={handleFilterChange} />
          <input type="text" name="category" placeholder="Category (e.g. 3-star)" className="form-control" onChange={handleFilterChange} />
          <input type="number" name="totalRooms" placeholder="Min Rooms in Hotel" className="form-control" onChange={handleFilterChange} />
          <input type="number" name="minPrice" placeholder="Min Price" className="form-control" onChange={handleFilterChange} />
          <input type="number" name="maxPrice" placeholder="Max Price" className="form-control" onChange={handleFilterChange} />
          <button onClick={fetchAvailableRooms} className="btn btn-secondary mt-2">Search</button>
        </div>

        {/* Available Rooms */}
        <h4 className="mt-4">📋 Available Rooms</h4>
        <table className="table">
          <thead>
            <tr>
              <th>Room</th>
              <th>Hotel</th>
              <th>Company</th>
              <th>City</th>
              <th>Category</th>
              <th>Price</th>
              <th>Capacity</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {availableRooms.map((room, idx) => (
              <tr key={idx}>
                <td>{room.roomnumber}</td>
                <td>{room.hotelid}</td>
                <td>{room.companyname}</td>
                <td>{room.city || 'N/A'}</td>
                <td>{room.category || 'N/A'}</td>
                <td>${room.price}</td>
                <td>{room.capacity}</td>
                <td><button className="btn btn-sm btn-primary" onClick={() => handleBookRoom(room)}>Book</button></td>
              </tr>
            ))}
          </tbody>
        </table>

        {/* My Bookings */}
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
