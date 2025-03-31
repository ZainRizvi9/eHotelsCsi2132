import React, { useState } from 'react';

const CreateCustomerForm = ({ onCustomerCreated }) => {
  const [formData, setFormData] = useState({
    customerID: '',
    SIN: '',
    registrationdate: '',
    firstname: '',
    lastname: ''
  });

  const handleChange = (e) => {
    setFormData(prev => ({
      ...prev,
      [e.target.name]: e.target.value
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const res = await fetch('http://localhost:5001/api/customer', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData)
      });

      if (!res.ok) {
        const errData = await res.json();
        alert("Error creating customer: " + (errData.error || "Unknown error"));
        return;
      }

      alert("Customer created successfully!");

      if (onCustomerCreated) onCustomerCreated();

      setFormData({
        customerID: '',
        SIN: '',
        registrationdate: '',
        firstname: '',
        lastname: ''
      });
    } catch (err) {
      console.error("Customer creation error:", err);
      alert("Failed to create customer.");
    }
  };

  return (
    <form onSubmit={handleSubmit} className="mb-3 border p-3 rounded">
      <div className="row">
        <div className="col-md-2">
          <label>Customer ID</label>
          <input name="customerID" value={formData.customerID} onChange={handleChange} className="form-control" required />
        </div>
        <div className="col-md-2">
          <label>SIN</label>
          <input name="SIN" value={formData.SIN} onChange={handleChange} className="form-control" required />
        </div>
        <div className="col-md-3">
          <label>First Name</label>
          <input name="firstname" value={formData.firstname} onChange={handleChange} className="form-control" required />
        </div>
        <div className="col-md-3">
          <label>Last Name</label>
          <input name="lastname" value={formData.lastname} onChange={handleChange} className="form-control" required />
        </div>
        <div className="col-md-2">
          <label>Registration Date</label>
          <input type="date" name="registrationdate" value={formData.registrationdate} onChange={handleChange} className="form-control" required />
        </div>
      </div>

      <button type="submit" className="btn btn-primary mt-3">Add Customer</button>
    </form>
  );
};

export default CreateCustomerForm;
