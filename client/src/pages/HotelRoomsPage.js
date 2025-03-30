import React, { useState, useEffect } from 'react';
import { useLocation } from 'react-router-dom';

const HotelRoomsPage = () => {
  const [rooms, setRooms] = useState([]);
  const location = useLocation();
  
  const searchParams = new URLSearchParams(location.search);
  const hotelId = searchParams.get('hotelId');
  const companyName = searchParams.get('company');

  const getRooms = async () => {
    try {
      const response = await fetch(`http://localhost:5001/api/room?hotelId=${hotelId}&company=${companyName}`);
      const data = await response.json();
      setRooms(data);
    } catch (err) {
      console.error("Error fetching rooms:", err);
    }
  };

  useEffect(() => {
    getRooms();
  }, [hotelId, companyName, getRooms]);  // Add getRooms as a dependency

  return (
    <div>
      <h2>Rooms at {companyName} - Hotel {hotelId}</h2>
      <table className="table">
        <thead>
          <tr>
            <th>Room Number</th>
            <th>Price</th>
            <th>Capacity</th>
            <th>View</th>
            <th>Expandable</th>
          </tr>
        </thead>
        <tbody>
          {rooms.map((room) => (
            <tr key={room.roomnumber}>
              <td>{room.roomnumber}</td>
              <td>{room.price}</td>
              <td>{room.capacity}</td>
              <td>{room.viewtype}</td>
              <td>{room.expandable ? 'Yes' : 'No'}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default HotelRoomsPage;
