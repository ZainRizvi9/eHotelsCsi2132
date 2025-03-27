import React, { Fragment, useEffect, useState } from "react";
import EditRoom from "./EditRoom";

const ListRooms = () => {
  const [room, setRoom] = useState([]);

  const deleteRoom = async (roomNumber) => {
    try {
      await fetch(`http://localhost:5001/api/room/${roomNumber}`, {
        method: "DELETE"
      });
      setRoom(room.filter((r) => r.roomnumber !== roomNumber));
    } catch (error) {
      console.error(error.message);
    }
  };

  const getRooms = async () => {
    try {
      const response = await fetch("http://localhost:5001/api/room");
      const jsonData = await response.json();
      setRoom(jsonData);
    } catch (error) {
      console.error(error.message);
    }
  };

  useEffect(() => {
    getRooms();
  }, []);

  return (
    <Fragment>
      <h1 className="mt-5 text-centre">List of Rooms</h1>
      <table className="table mt-5 text-centre">
        <thead>
          <tr>
            <th>Room Number</th>
            <th>Company Name</th>
            <th>Hotel ID</th>
            <th>Price</th>
            <th>Capacity</th>
            <th>Room Type</th>
            <th>Expandable</th>
          </tr>
        </thead>
        <tbody>
          {room.map((r) => (
            <tr key={r.roomnumber}>
              <td>{r.roomnumber}</td>
              <td>{r.companyname}</td>
              <td>{r.hotelid}</td>
              <td>{r.price}</td>
              <td>{r.capacity}</td>
              <td>{r.viewtype}</td>
              <td>{r.expandable}</td>
              <td>
                <EditRoom room={r} />
              </td>
              <td>
                <button className="btn btn-danger" onClick={() => deleteRoom(r.roomnumber)}>
                  Delete
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </Fragment>
  );
};

export default ListRooms;
