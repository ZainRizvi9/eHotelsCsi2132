import React, { useEffect, useState, useCallback } from 'react';
import DashboardHeader from '../shared/DashboardHeader';

const EmployeeDashboard = () => {
  const [rentals, setRentals] = useState([]);
  const [issues, setIssues] = useState([]);
  const [amenities, setAmenities] = useState([]);

  const token = localStorage.getItem('token');

  const fetchData = useCallback(async () => {
    try {
      const headers = { Authorization: `Bearer ${token}` };
      const [rentalsRes, issuesRes, amenitiesRes] = await Promise.all([
        fetch('http://localhost:5001/api/dashboard/employee/rentals', { headers }),
        fetch('http://localhost:5001/api/dashboard/employee/issues', { headers }),
        fetch('http://localhost:5001/api/dashboard/employee/amenities', { headers }),
      ]);
      const rentalsData = await rentalsRes.json();
      const issuesData = await issuesRes.json();
      const amenitiesData = await amenitiesRes.json();
      setRentals(rentalsData);
      setIssues(issuesData);
      setAmenities(amenitiesData);
    } catch (err) {
      console.error('Error fetching dashboard data:', err);
    }
  }, [token]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  return (
    <div>
      <DashboardHeader />
      <div className="container mt-4">
        <h2>Employee Dashboard</h2>
        <section>
          <h4>Rentals You Handled</h4>
          <ul>
            {rentals.map(r => (
              <li key={r.rentalid}>
                Room {r.roomnumber} – Rental Date: {r.rentaldate} – CustomerID: {r.customerid}
              </li>
            ))}
          </ul>
        </section>
        <section>
          <h4>Room Issues</h4>
          <ul>
            {issues.map((issue, idx) => (
              <li key={idx}>
                Room {issue.roomnumber} ({issue.companyname}) – {issue.issue}
              </li>
            ))}
          </ul>
        </section>
        <section>
          <h4>Room Amenities</h4>
          <ul>
            {amenities.map((amenity, idx) => (
              <li key={idx}>
                Room {amenity.roomnumber} ({amenity.companyname}) – {amenity.amenity}
              </li>
            ))}
          </ul>
        </section>
      </div>
    </div>
  );
};

export default EmployeeDashboard;
