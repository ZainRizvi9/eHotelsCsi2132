import React, { useState, useEffect } from "react";
import DatePicker from "react-datepicker";
import "react-datepicker/dist/react-datepicker.css";

const InputBooking = () => {
  const [hotels, setHotels] = useState([]);
  const [rooms, setRooms] = useState([]);
  const [selectedHotel, setSelectedHotel] = useState("");
  const [selectedRoom, setSelectedRoom] = useState("");
  const [customerID, setCustomerID] = useState("");
  const [checkInDate, setCheckInDate] = useState(null);
  const [checkOutDate, setCheckOutDate] = useState(null);

  useEffect(() => {
    fetch("http://localhost:5001/api/hotel")
      .then(res => res.json())
      .then(data => setHotels(data))
      .catch(err => console.error(err));
  }, []);

  useEffect(() => {
    if (selectedHotel) {
      const [hotelID, companyName] = selectedHotel.split("-");
      fetch(`http://localhost:5001/api/room?hotelID=${hotelID}&companyName=${companyName}`)
        .then(res => res.json())
        .then(data => setRooms(data))
        .catch(err => console.error(err));
    }
  }, [selectedHotel]);

  const onSubmit = async e => {
    e.preventDefault();
    const [hotelID, companyName] = selectedHotel.split("-");

    const body = {
      checkInDate: checkInDate.toLocaleDateString("en-GB"),
      checkOutDate: checkOutDate.toLocaleDateString("en-GB"),
      roomNumber: parseInt(selectedRoom),
      hotelID: parseInt(hotelID),
      companyName,
      customerID: parseInt(customerID),
      status: "RESERVED"
    };

    try {
      const response = await fetch("http://localhost:5001/api/booking", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body)
      });

      if (response.ok) {
        alert("Booking successful!");
      } else {
        alert("Failed to book.");
      }
    } catch (err) {
      console.error(err.message);
    }
  };

  return (
    <div className="container mt-5">
      <h3>Create a Booking</h3>
      <form onSubmit={onSubmit}>
        <div className="form-group">
          <label>Customer ID</label>
          <input
            type="number"
            className="form-control"
            value={customerID}
            onChange={e => setCustomerID(e.target.value)}
            required
          />
        </div>

        <div className="form-group mt-2">
          <label>Select Hotel</label>
          <select className="form-control" onChange={e => setSelectedHotel(e.target.value)} required>
            <option value="">Select a hotel</option>
            {hotels.map(h => (
              <option key={`${h.hotelid}-${h.companyname}`} value={`${h.hotelid}-${h.companyname}`}>
                {h.companyname} - {h.city}
              </option>
            ))}
          </select>
        </div>

        <div className="form-group mt-2">
          <label>Select Room</label>
          <select className="form-control" onChange={e => setSelectedRoom(e.target.value)} required>
            <option value="">Select a room</option>
            {rooms.map(r => (
              <option key={r.roomnumber} value={r.roomnumber}>
                Room {r.roomnumber} - ${r.price} - {r.viewtype}
              </option>
            ))}
          </select>
        </div>

        <div className="form-group mt-2">
          <label>Check-In Date</label>
          <DatePicker
            selected={checkInDate}
            onChange={date => setCheckInDate(date)}
            dateFormat="dd/MM/yyyy"
            className="form-control"
            required
          />
        </div>

        <div className="form-group mt-2">
          <label>Check-Out Date</label>
          <DatePicker
            selected={checkOutDate}
            onChange={date => setCheckOutDate(date)}
            dateFormat="dd/MM/yyyy"
            className="form-control"
            required
          />
        </div>

        <button className="btn btn-primary mt-3" type="submit">Book Now</button>
      </form>
    </div>
  );
};

export default InputBooking;
