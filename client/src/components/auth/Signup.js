import React, { useState, useEffect } from 'react';

const Signup = () => {
  const [userType, setUserType] = useState('customer');
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [address, setAddress] = useState('');
  const [idType, setIdType] = useState('passport');
  const [idNumber, setIdNumber] = useState('');
  const [password, setPassword] = useState('');
  const [email, setEmail] = useState('');

  const [hotels, setHotels] = useState([]);
  const [hotelId, setHotelId] = useState('');
  const [companyName, setCompanyName] = useState('');

  useEffect(() => {
    if (userType === 'employee') {
      fetch("http://localhost:5001/api/hotel")
        .then(res => res.json())
        .then(data => setHotels(data))
        .catch(err => console.error("Error fetching hotels", err));
    }
  }, [userType]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    const payload = {
      userType,
      firstName,
      lastName,
      address,
      idType,
      idNumber,
      password,
      email,
      ...(userType === 'employee' ? { hotelId, companyName } : {})
    };

    try {
      const response = await fetch("http://localhost:5001/api/auth/signup", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });

      const data = await response.json();
      if (response.ok) {
        alert("Signup successful! Please log in.");
      } else {
        alert(data.error);
      }
    } catch (err) {
      console.error(err);
      alert("Signup failed.");
    }
  };

  return (
    <div className="container mt-5">
      <h3>Sign Up</h3>
      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <label>User Type</label>
          <select className="form-control" value={userType} onChange={e => setUserType(e.target.value)}>
            <option value="customer">Customer</option>
            <option value="employee">Employee</option>
          </select>
        </div>

        <div className="form-group">
          <label>Email</label>
          <input type="email" className="form-control" value={email} onChange={e => setEmail(e.target.value)} required />
        </div>

        <div className="form-group">
          <label>First Name</label>
          <input type="text" className="form-control" value={firstName} onChange={e => setFirstName(e.target.value)} required />
        </div>

        <div className="form-group">
          <label>Last Name</label>
          <input type="text" className="form-control" value={lastName} onChange={e => setLastName(e.target.value)} required />
        </div>

        <div className="form-group">
          <label>Address</label>
          <input type="text" className="form-control" value={address} onChange={e => setAddress(e.target.value)} />
        </div>

        {userType === 'customer' && (
          <>
            <div className="form-group">
              <label>ID Type</label>
              <input type="text" className="form-control" value={idType} onChange={e => setIdType(e.target.value)} />
            </div>

            <div className="form-group">
              <label>ID Number</label>
              <input type="text" className="form-control" value={idNumber} onChange={e => setIdNumber(e.target.value)} />
            </div>
          </>
        )}

        {userType === 'employee' && (
          <>
            <div className="form-group">
              <label>Hotel</label>
              <select className="form-control" onChange={(e) => {
                const [hotelId, companyName] = e.target.value.split('|');
                setHotelId(hotelId);
                setCompanyName(companyName);
              }}>
                <option value="">Select Hotel</option>
                {hotels.map(h => (
                  <option key={`${h.hotelid}-${h.companyname}`} value={`${h.hotelid}|${h.companyname}`}>
                    {h.companyname} - Hotel #{h.hotelid}
                  </option>
                ))}
              </select>
            </div>
          </>
        )}

        <div className="form-group">
          <label>Password</label>
          <input type="password" className="form-control" value={password} onChange={e => setPassword(e.target.value)} required />
        </div>

        <button type="submit" className="btn btn-primary mt-3">Sign Up</button>
      </form>
    </div>
  );
};

export default Signup;
