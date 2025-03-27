import './App.css';
import React, { Fragment, useState } from 'react';

//components
import InputRoom from './components/roomComponents/InputRoom';
import ListRooms from "./components/roomComponents/ListRooms";
import InputHotel from './components/hotelComponents/InputHotel';
import ListHotels from './components/hotelComponents/ListHotels';
import InputBooking from "./components/booking/InputBooking";

function App() {
  const [showRoomInput, setShowRoomInput] = useState(false);
  const [showHotelInput, setShowHotelInput] = useState(false);
  const [showHotelList, setShowHotelList] = useState(false);
  const [showRoomList, setShowRoomList] = useState(false);
  const [showHome, setShowHome] = useState(false)

  const handleHomeClick = () => {
    setShowRoomInput(false);
    setShowRoomList(false);
    setShowHotelInput(false);
    setShowHotelList(false);
  }

  const handleRoomClick = () => {
    setShowRoomInput(true);
    setShowRoomList(true);
    setShowHotelInput(false);
    setShowHotelList(false);
  }

  const handleHotelClick = () => {
    setShowHotelInput(true);
    setShowHotelList(true);
    setShowRoomInput(false);
    setShowRoomList(false);
    
  }

  return (
    <Fragment>
      <div className="header">
        <button onClick={handleHomeClick}>Home</button>
        <button onClick={handleRoomClick}>Rooms</button>
        <button onClick={handleHotelClick}>Hotels</button>
      </div>
  
      <div className="container">
        <div className="text">
          <p>Welcome to eHotel System</p>
        </div>
  
        {/* Room section */}
        {showRoomInput && showRoomList && (
          <Fragment>
            <InputRoom />
            <ListRooms />
          </Fragment>
        )}
  
        {/* Hotel section */}
        {showHotelInput && showHotelList && (
          <Fragment>
            <InputHotel />
            <ListHotels />
          </Fragment>
        )}
        <InputBooking />
      </div>
    </Fragment>
  );  
}

export default App;
