import React, { Fragment, useEffect, useState } from "react";
import EditHotel from "./EditHotel";

const ListHotels = () => {
  const [hotels, setHotels] = useState([]);

  const deleteHotel = async (id) => {
    try {
      await fetch(`http://localhost:5001/api/hotel/${id}`, {
        method: "DELETE"
      });
      setHotels(hotels.filter(hotel => hotel.hotelid !== id));
    } catch (error) {
      console.error(error.message);
    }
  };

  const getHotels = async () => {
    try {
      const response = await fetch("http://localhost:5001/api/hotel");
      const jsonData = await response.json();
      setHotels(jsonData);
    } catch (error) {
      console.error(error.message);
    }
  };

  useEffect(() => {
    getHotels();
  }, []);

  return (
    <Fragment>
      <h1 className="mt-5 text-centre">List of Hotels</h1>
      <table className="table mt-5 text-centre">
        <thead>
          <tr>
            <th>Hotel ID</th>
            <th>Company Name</th>
            <th>Address</th>
            <th>Category</th>
            <th>Number Of Rooms</th>
          </tr>
        </thead>
        <tbody>
          {hotels.map(hotel => (
            <tr key={hotel.hotelid}>
              <td>{hotel.hotelid}</td>
              <td>{hotel.companyname}</td>
              <td>
                {hotel.streetnumber} {hotel.streetname}, {hotel.city}, {hotel.state} {hotel.postalcode}
              </td>
              <td>{hotel.category}</td>
              <td>{hotel.numberofrooms}</td>
              <td>
                <EditHotel hotel={hotel} />
              </td>
              <td>
                <button className="btn btn-danger" onClick={() => deleteHotel(hotel.hotelid)}>Delete</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </Fragment>
  );
};

export default ListHotels;
