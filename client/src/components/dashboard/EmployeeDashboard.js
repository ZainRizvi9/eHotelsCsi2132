import React, { useEffect, useState, useCallback } from 'react';
import DashboardHeader from '../shared/DashboardHeader';
import CreateCustomerForm from './CreateCustomerForm';

const EmployeeDashboard = () => {
  const [rentals, setRentals] = useState([]);
  const [issues, setIssues] = useState([]);
  const [amenities, setAmenities] = useState([]);
  const [pendingBookings, setPendingBookings] = useState([]);
  const [availableRooms, setAvailableRooms] = useState([]);
  const [customers, setCustomers] = useState([]);
  const [employeeHotel, setEmployeeHotel] = useState({ hotelId: null, companyName: '' });
  const [walkInData, setWalkInData] = useState({
    roomNumber: '',
    customerId: '',
    startDate: '',
    endDate: '',
    paymentAmount: '',
    paymentMethod: ''
  });
  const token = localStorage.getItem('token');

  const refreshCustomers = async () => {
    try {
      const res = await fetch('http://localhost:5001/api/customer');
      setCustomers(await res.json());
    } catch (err) {
      console.error("Error refreshing customers:", err);
    }
  };

  useEffect(() => {
    if (token) {
      try {
        const payload = JSON.parse(atob(token.split('.')[1]));
        setEmployeeHotel({ hotelId: payload.hotelId, companyName: payload.companyName });
      } catch (err) {
        console.error("Failed to decode token:", err);
      }
    }
  }, [token]);

  const fetchData = useCallback(async () => {
    try {
      const headers = { Authorization: `Bearer ${token}` };
      const [rentalsRes, issuesRes, amenitiesRes] = await Promise.all([
        fetch('http://localhost:5001/api/dashboard/employee/rentals', { headers }),
        fetch('http://localhost:5001/api/dashboard/employee/issues', { headers }),
        fetch('http://localhost:5001/api/dashboard/employee/amenities', { headers })
      ]);
      setRentals(await rentalsRes.json());
      setIssues(await issuesRes.json());
      setAmenities(await amenitiesRes.json());
    } catch (err) {
      console.error('Error fetching dashboard data:', err);
    }
  }, [token]);

  const fetchPendingBookings = async () => {
    try {
      const res = await fetch("http://localhost:5001/api/bookings", {
        headers: { Authorization: `Bearer ${token}` }
      });
      const data = await res.json();
      const pending = data.filter(b => b.status === "RESERVED");
      setPendingBookings(pending);
    } catch (err) {
      console.error("Error fetching pending bookings:", err);
    }
  };

  const convertBooking = async (bookingId) => {
    const paymentAmount = prompt("Enter payment amount for this booking:");
    const paymentMethod = prompt("Enter payment method (cash/credit/debit):");

    try {
      const res = await fetch(`http://localhost:5001/api/bookings/convert/${bookingId}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`
        },
        body: JSON.stringify({ paymentAmount, paymentMethod })
      });
      if (!res.ok) {
        const errorData = await res.json();
        alert("Conversion failed: " + (errorData.error || "Unknown error"));
        return;
      }
      alert("Booking converted to renting successfully!");
      fetchPendingBookings();
      fetchData();
    } catch (err) {
      console.error("Conversion error:", err);
      alert("Conversion failed.");
    }
  };

  const fetchRoomsAndCustomers = async () => {
    try {
      const [roomRes, custRes] = await Promise.all([
        fetch('http://localhost:5001/api/room'),
        fetch('http://localhost:5001/api/customer')
      ]);
      setAvailableRooms(await roomRes.json());
      setCustomers(await custRes.json());
    } catch (err) {
      console.error("Error fetching walk-in form data:", err);
    }
  };

  const handleWalkInSubmit = async (e) => {
    e.preventDefault();
    try {
      const res = await fetch('http://localhost:5001/api/bookings/walkin', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`
        },
        body: JSON.stringify(walkInData)
      });
      if (!res.ok) {
        const errData = await res.json();
        alert("Walk-in failed: " + (errData.error || "Unknown error"));
        return;
      }
      alert("Walk-in rental created successfully!");
      setWalkInData({ roomNumber: '', customerId: '', startDate: '', endDate: '', paymentAmount: '', paymentMethod: '' });
      fetchData();
    } catch (err) {
      console.error("Walk-in rental error:", err);
      alert("Failed to create walk-in rental");
    }
  };

  useEffect(() => {
    fetchData();
    fetchPendingBookings();
    fetchRoomsAndCustomers();
  }, [fetchData]);

  return (
    <div>
      <DashboardHeader />
      <div className="container mt-4">
        <h2>Employee Dashboard</h2>
        <p>You work at: {employeeHotel.companyName} - Hotel #{employeeHotel.hotelId}</p>

        {/* Customer Registration */}
        <section className="mt-4">
          <h4>Register Walk-In Customer</h4>
          <CreateCustomerForm onCustomerCreated={refreshCustomers} />
        </section>

        {/* Pending Bookings */}
        <section className="mt-4">
          <h4>Pending Bookings for Conversion</h4>
          {pendingBookings.length === 0 ? (
            <p>No pending bookings.</p>
          ) : (
            <table className="table table-striped">
              <thead>
                <tr>
                  <th>Booking ID</th>
                  <th>Room Number</th>
                  <th>Start Date</th>
                  <th>End Date</th>
                  <th>Customer ID</th>
                  <th>Action</th>
                </tr>
              </thead>
              <tbody>
                {pendingBookings.map(booking => (
                  <tr key={booking.bookingid}>
                    <td>{booking.bookingid}</td>
                    <td>{booking.roomnumber}</td>
                    <td>{booking.startdate}</td>
                    <td>{booking.enddate}</td>
                    <td>{booking.customerid}</td>
                    <td>
                      <button className="btn btn-success" onClick={() => convertBooking(booking.bookingid)}>Convert</button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </section>

        {/* Walk-in Form */}
        <section className="mt-4">
          <h4>Create Walk-in Rental</h4>
          <form onSubmit={handleWalkInSubmit} className="mb-3">
            <div className="row">
              <div className="col-md-3">
                <label>Room</label>
                <select className="form-control" value={walkInData.roomNumber} onChange={e => setWalkInData({ ...walkInData, roomNumber: e.target.value })} required>
                  <option value="">Select Room</option>
                  {availableRooms.map(r => (
                    <option key={r.roomnumber} value={r.roomnumber}>Room #{r.roomnumber}</option>
                  ))}
                </select>
              </div>
              <div className="col-md-3">
                <label>Customer</label>
                <select className="form-control" value={walkInData.customerId} onChange={e => setWalkInData({ ...walkInData, customerId: e.target.value })} required>
                  <option value="">Select Customer</option>
                  {customers.map(c => (
                    <option key={c.customerid} value={c.customerid}>{c.firstname} {c.lastname}</option>
                  ))}
                </select>
              </div>
              <div className="col-md-2">
                <label>Start</label>
                <input type="date" className="form-control" value={walkInData.startDate} onChange={e => setWalkInData({ ...walkInData, startDate: e.target.value })} required />
              </div>
              <div className="col-md-2">
                <label>End</label>
                <input type="date" className="form-control" value={walkInData.endDate} onChange={e => setWalkInData({ ...walkInData, endDate: e.target.value })} required />
              </div>
              <div className="col-md-2">
                <label>Amount</label>
                <input type="number" className="form-control" value={walkInData.paymentAmount} onChange={e => setWalkInData({ ...walkInData, paymentAmount: e.target.value })} required />
              </div>
              <div className="col-md-3 mt-2">
                <label>Method</label>
                <select className="form-control" value={walkInData.paymentMethod} onChange={e => setWalkInData({ ...walkInData, paymentMethod: e.target.value })} required>
                  <option value="">Select Method</option>
                  <option value="cash">Cash</option>
                  <option value="credit">Credit</option>
                  <option value="debit">Debit</option>
                </select>
              </div>
              <div className="col-md-3 mt-4">
                <button type="submit" className="btn btn-primary mt-2">Submit Walk-in</button>
              </div>
            </div>
          </form>
        </section>

        {/* Rentals */}
        <section className="mt-4">
          <h4>Rentals You Handled</h4>
          {rentals.length === 0 ? <p>No rentals available.</p> : (
            <ul>{rentals.map(r => <li key={r.rentalid}>Room {r.roomnumber} – Rental Date: {r.rentaldate} – CustomerID: {r.customerid}</li>)}</ul>
          )}
        </section>

        {/* Room Issues */}
        <section className="mt-4">
          <h4>Room Issues</h4>
          {issues.length === 0 ? <p>No issues reported.</p> : (
            <ul>{issues.map((issue, idx) => <li key={idx}>Room {issue.roomnumber} ({issue.companyname}) – {issue.issue}</li>)}</ul>
          )}
        </section>

        {/* Room Amenities */}
        <section className="mt-4">
          <h4>Room Amenities</h4>
          {amenities.length === 0 ? <p>No amenities available.</p> : (
            <ul>{amenities.map((a, idx) => <li key={idx}>Room {a.roomnumber} ({a.companyname}) – {a.amenity}</li>)}</ul>
          )}
        </section>
      </div>
    </div>
  );
};

export default EmployeeDashboard;
