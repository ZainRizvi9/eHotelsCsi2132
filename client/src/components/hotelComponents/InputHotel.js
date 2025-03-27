import React, { Fragment, useState } from "react";

const InputHotel = () => {
  const [hotelID, setHotelID] = useState("");
  const [companyName, setCompanyName] = useState("");
  const [category, setCategory] = useState("");
  const [numberOfRooms, setNumberOfRooms] = useState("");
  const [address, setAddress] = useState({
    streetNumber: "",
    streetName: "",
    aptNumber: "",
    city: "",
    state: "",
    postalCode: ""
  });

  const onSubmitForm = async e => {
    e.preventDefault();
    try {
      const body = {
        hotelID: parseInt(hotelID),
        companyName,
        category,
        numberOfRooms: parseInt(numberOfRooms),
        address
      };
      const response = await fetch("http://localhost:5001/api/hotel", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body)
      });
      if (response.ok) {
        alert("Hotel added successfully!");
        window.location.reload();
      } else {
        alert("Failed to add hotel.");
      }
    } catch (error) {
      console.error(error.message);
    }
  };

  return (
    <Fragment>
      <h1 className="text-center mt-5">Input Hotel</h1>
      <form className="mt-3" onSubmit={onSubmitForm}>
        <input className="form-control mb-2" placeholder="Hotel ID" type="number" value={hotelID} onChange={e => setHotelID(e.target.value)} required />
        <input className="form-control mb-2" placeholder="Company Name" type="text" value={companyName} onChange={e => setCompanyName(e.target.value)} required />
        <input className="form-control mb-2" placeholder="Category" type="text" value={category} onChange={e => setCategory(e.target.value)} required />
        <input className="form-control mb-2" placeholder="Number of Rooms" type="number" value={numberOfRooms} onChange={e => setNumberOfRooms(e.target.value)} required />
        
        <input className="form-control mb-2" placeholder="Street Number" type="number" value={address.streetNumber} onChange={e => setAddress({...address, streetNumber: e.target.value})} required />
        <input className="form-control mb-2" placeholder="Street Name" type="text" value={address.streetName} onChange={e => setAddress({...address, streetName: e.target.value})} required />
        <input className="form-control mb-2" placeholder="Apt Number (optional)" type="number" value={address.aptNumber} onChange={e => setAddress({...address, aptNumber: e.target.value})} />
        <input className="form-control mb-2" placeholder="City" type="text" value={address.city} onChange={e => setAddress({...address, city: e.target.value})} required />
        <input className="form-control mb-2" placeholder="State" type="text" value={address.state} onChange={e => setAddress({...address, state: e.target.value})} required />
        <input className="form-control mb-2" placeholder="Postal Code" type="text" value={address.postalCode} onChange={e => setAddress({...address, postalCode: e.target.value})} required />

        <button className="btn btn-success">Add Hotel</button>
      </form>
    </Fragment>
  );
};

export default InputHotel;
