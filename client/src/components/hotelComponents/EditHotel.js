import React, { Fragment, useState } from "react";

const EditHotel = ({ hotel }) => {
  const [category, setCategory] = useState(hotel.category);

  const updateCategory = async (e) => {
    e.preventDefault();
    try {
      const body = {
        hotelID: hotel.hotelid,
        companyName: hotel.companyname,
        category
      };
      const response = await fetch("http://localhost:5001/api/hotel/category", {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body)
      });
      if (response.ok) {
        alert("Hotel category updated!");
        window.location.reload();
      } else {
        alert("Update failed.");
      }
    } catch (error) {
      console.error(error.message);
    }
  };

  return (
    <Fragment>
      <button
        type="button"
        className="btn btn-warning"
        data-toggle="modal"
        data-target={`#id${hotel.hotelid}`}
      >
        Edit
      </button>

      <div className="modal" id={`id${hotel.hotelid}`}>
        <div className="modal-dialog">
          <div className="modal-content">

            <div className="modal-header">
              <h4 className="modal-title">Edit Hotel Category</h4>
              <button type="button" className="close" data-dismiss="modal">
                &times;
              </button>
            </div>

            <div className="modal-body">
              <input
                type="text"
                className="form-control"
                value={category}
                onChange={e => setCategory(e.target.value)}
              />
            </div>

            <div className="modal-footer">
              <button
                type="button"
                className="btn btn-warning"
                data-dismiss="modal"
                onClick={updateCategory}
              >
                Save
              </button>
              <button
                type="button"
                className="btn btn-danger"
                data-dismiss="modal"
              >
                Close
              </button>
            </div>

          </div>
        </div>
      </div>
    </Fragment>
  );
};

export default EditHotel;
