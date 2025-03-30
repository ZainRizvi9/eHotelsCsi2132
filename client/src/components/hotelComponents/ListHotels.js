import React, { Fragment, useEffect, useState } from "react";
import { useNavigate } from 'react-router-dom';

const ListHotels = ({ allowFilters }) => {
  const [hotels, setHotels] = useState([]);
  const [filters, setFilters] = useState({ city: '', category: '', company: '' });
  const navigate = useNavigate();

  const deleteHotel = async (hotelID, companyName) => {
    if (!window.confirm("Are you sure you want to delete this hotel?")) return;
    try {
      await fetch("http://localhost:5001/api/hotel", {
        method: "DELETE",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ hotelID, companyName })
      });
      setHotels(hotels.filter(h => h.hotelid !== hotelID || h.companyname !== companyName));
    } catch (err) {
      console.error("Delete error:", err);
    }
  };

  const getHotels = async () => {
    try {
      const res = await fetch("http://localhost:5001/api/hotel");
      const json = await res.json();
      setHotels(json);
    } catch (err) {
      console.error("Fetch error:", err);
    }
  };

  useEffect(() => {
    getHotels();
  }, []);

  const filtered = hotels.filter(h => {
    return (
      (!filters.city || h.city.toLowerCase().includes(filters.city.toLowerCase())) &&
      (!filters.category || h.category.toLowerCase().includes(filters.category.toLowerCase())) &&
      (!filters.company || h.companyname.toLowerCase().includes(filters.company.toLowerCase()))
    );
  });

  return (
    <Fragment>
      <h2 className="mt-4">Hotels</h2>

      {allowFilters && (
        <div className="filters mb-3">
          <input placeholder="Filter by city" onChange={e => setFilters({ ...filters, city: e.target.value })} />
          <input placeholder="Filter by category" onChange={e => setFilters({ ...filters, category: e.target.value })} />
          <input placeholder="Filter by company" onChange={e => setFilters({ ...filters, company: e.target.value })} />
        </div>
      )}

      <table className="table text-center">
        <thead>
          <tr>
            <th>Hotel ID</th>
            <th>Company</th>
            <th>Address</th>
            <th>Category</th>
            <th>Rooms</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {filtered.map(hotel => (
            <tr key={`${hotel.hotelid}-${hotel.companyname}`}>
              <td>{hotel.hotelid}</td>
              <td>{hotel.companyname}</td>
              <td>{hotel.streetnumber} {hotel.streetname}, {hotel.city}, {hotel.state}</td>
              <td>{hotel.category}</td>
              <td>{hotel.numberofrooms}</td>
              <td>
                <button onClick={() => navigate(`/hotel-rooms?hotelId=${hotel.hotelid}&company=${hotel.companyname}`)} className="btn btn-primary btn-sm">View Rooms</button>
                <button onClick={() => deleteHotel(hotel.hotelid, hotel.companyname)} className="btn btn-danger btn-sm">Delete</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </Fragment>
  );
};

export default ListHotels;
