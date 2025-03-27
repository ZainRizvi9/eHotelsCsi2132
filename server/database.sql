CREATE DATABASE ehotels;

CREATE TABLE IF NOT EXISTS Headquarters(
	CompanyName Varchar(225) PRIMARY KEY,
	NumberOfHotels Integer NOT NULL,
	StreetNumber Integer NOT NULL,
	StreetName Varchar(225) NOT NULL,
	AptNumber Varchar(25),
	City Varchar(225) NOT NULL,
	State Varchar(225) NOT NULL,
	PostalCode Varchar(25) NOT NULL
);

CREATE TABLE IF NOT EXISTS HeadquartersPhone(
	CompanyName Varchar(225),
	phoneNumber VarChar(20),
	FOREIGN KEY (CompanyName) REFERENCES Headquarters(CompanyName) ON DELETE CASCADE,
	PRIMARY KEY (phoneNumber, CompanyName)
);

CREATE TABLE IF NOT EXISTS HeadquartersEmail(
	CompanyName Varchar(225),
	email VarChar(40),
	FOREIGN KEY (CompanyName) REFERENCES Headquarters(CompanyName) ON DELETE CASCADE,
	PRIMARY KEY (email, CompanyName)
);

CREATE TABLE IF NOT EXISTS Hotel (
	HotelID Integer UNIQUE,
	CompanyName Varchar(225) NOT NULL,
	Category Varchar(225) NOT NULL,
	NumberOfRooms Integer NOT NULL,
	StreetNumber Integer NOT NULL,
	StreetName Varchar(225) NOT NULL,
	AptNumber Varchar(25),
	City Varchar(225) NOT NULL,
	State Varchar(225) NOT NULL,
	PostalCode Varchar(25) NOT NULL,
	FOREIGN KEY (CompanyName) REFERENCES Headquarters(CompanyName) ON DELETE CASCADE,
	PRIMARY KEY (HotelID, CompanyName)
);

CREATE TABLE IF NOT EXISTS HotelPhone(
	HotelID Integer,
	CompanyName Varchar(225),
	phoneNumber VarChar(20),
	FOREIGN KEY (HotelID, CompanyName) REFERENCES Hotel(HotelID, CompanyName) ON DELETE CASCADE,
	PRIMARY KEY (phoneNumber, HotelID, CompanyName)
);

CREATE TABLE IF NOT EXISTS HotelEmail(
	HotelID Integer,
	CompanyName Varchar(225),
	email VarChar(40),
	FOREIGN KEY (HotelID, CompanyName) REFERENCES Hotel(HotelID, CompanyName) ON DELETE CASCADE,
	PRIMARY KEY (email, HotelID, CompanyName)
);

CREATE TABLE IF NOT EXISTS Room (
	RoomNumber Integer,
	CompanyName Varchar(225),
	HotelID Integer,
	ViewType Varchar(225) NOT NULL,
	Price Integer NOT NULL,
	Capacity Integer NOT NULL,
	Expandable Varchar(225) NOT NULL,
	FOREIGN KEY (HotelID, CompanyName) REFERENCES Hotel(HotelID, CompanyName) ON DELETE CASCADE,
	PRIMARY KEY (RoomNumber, HotelID, CompanyName)
);

CREATE TABLE IF NOT EXISTS RoomIssue(
	Issue Varchar(20),
	RoomNumber Integer,
	HotelID Integer,
	CompanyName Varchar(225),
	FOREIGN KEY (RoomNumber, HotelID, CompanyName) REFERENCES Room(RoomNumber, HotelID, CompanyName) ON DELETE CASCADE,
	PRIMARY KEY (Issue, RoomNumber, HotelID, CompanyName)
);

CREATE TABLE IF NOT EXISTS RoomAmenity(
	Amenity Varchar(20),
	RoomNumber Integer,
	HotelID Integer,
	CompanyName Varchar(225),
	FOREIGN KEY (RoomNumber, HotelID, CompanyName) REFERENCES Room(RoomNumber, HotelID, CompanyName) ON DELETE CASCADE,
	PRIMARY KEY (Amenity, RoomNumber, HotelID, CompanyName)
);

CREATE TABLE IF NOT EXISTS Customer (
	CustomerID Integer PRIMARY KEY,
	SIN Varchar(20) NOT NULL,
	RegistrationDate Date NOT NULL,
	FirstName Varchar(20) NOT NULL,
	LastName Varchar(20) NOT NULL,
	StreetNumber Integer NOT NULL,
	StreetName Varchar(225) NOT NULL,
	AptNumber Varchar(25),
	City Varchar(225) NOT NULL,
	State Varchar(225) NOT NULL,
	PostalCode Varchar(25) NOT NULL
);

CREATE TABLE IF NOT EXISTS Booking (
  BookingID SERIAL PRIMARY KEY,
  CheckInDate Date,
  CheckOutDate Date,
  HotelID Integer,
  RoomNumber Integer,
  CustomerID Integer,
  CompanyName Varchar(225),
  Status Varchar(20),
  FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) ON DELETE CASCADE,
  FOREIGN KEY (RoomNumber, HotelID, CompanyName) REFERENCES Room(RoomNumber, HotelID, CompanyName) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS Employee (
	EmployeeID Integer,
	SIN Varchar(20) NOT NULL,
	HotelID Integer,
	CompanyName Varchar(225),
	FirstName Varchar(20) NOT NULL,
	MiddleName Varchar(20),
	LastName Varchar(20) NOT NULL,
	StreetNumber Integer NOT NULL,
	StreetName Varchar(225) NOT NULL,
	AptNumber Varchar(25),
	City Varchar(225) NOT NULL,
	State Varchar(225) NOT NULL,
	PostalCode Varchar(25) NOT NULL,
	FOREIGN KEY (HotelID, CompanyName) REFERENCES Hotel(HotelID, CompanyName) ON DELETE CASCADE,
	PRIMARY KEY (EmployeeID, HotelID, CompanyName)
);

CREATE TABLE IF NOT EXISTS Manages (
	EmployeeID Integer,
	HotelID Integer,
	CompanyName Varchar(225),
	FOREIGN KEY (EmployeeID, HotelID, CompanyName) REFERENCES Employee(EmployeeID, HotelID, CompanyName) ON DELETE CASCADE,
	PRIMARY KEY (EmployeeID, HotelID, CompanyName),
	CONSTRAINT HotelInfo UNIQUE (HotelID, CompanyName)
);

CREATE TABLE IF NOT EXISTS EmployeeRole (
	Role Varchar(225),
	EmployeeID Integer,
	HotelID Integer,
	CompanyName Varchar(225),
	FOREIGN KEY (EmployeeID, HotelID, CompanyName) REFERENCES Employee(EmployeeID, HotelID, CompanyName) ON DELETE CASCADE,
	PRIMARY KEY (Role, EmployeeID, HotelID, CompanyName)
);

CREATE TABLE IF NOT EXISTS Renting (
  RentalID SERIAL PRIMARY KEY,
  BookingID Integer,
  RoomNumber Integer,
  HotelID Integer,
  CompanyName Varchar(225),
  CustomerID Integer,
  EmployeeID Integer,
  RentalDate Date NOT NULL,
  FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE SET NULL,
  FOREIGN KEY (RoomNumber, HotelID, CompanyName) REFERENCES Room(RoomNumber, HotelID, CompanyName) ON DELETE CASCADE,
  FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) ON DELETE CASCADE,
  FOREIGN KEY (EmployeeID, HotelID, CompanyName) REFERENCES Employee(EmployeeID, HotelID, CompanyName) ON DELETE SET NULL
);
-- Trigger 1: Prevent overlapping bookings
CREATE OR REPLACE FUNCTION prevent_overlapping_bookings()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM Booking
    WHERE 
      RoomNumber = NEW.RoomNumber AND
      HotelID = NEW.HotelID AND
      CompanyName = NEW.CompanyName AND
      (
        NEW.StartDate BETWEEN StartDate AND EndDate OR
        NEW.EndDate BETWEEN StartDate AND EndDate OR
        StartDate BETWEEN NEW.StartDate AND NEW.EndDate
      )
  ) THEN
    RAISE EXCEPTION 'Room already booked during this period.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_booking_conflict
BEFORE INSERT ON Booking
FOR EACH ROW EXECUTE FUNCTION prevent_overlapping_bookings();


-- Trigger 2: Ensure renting happens only if booking exists and rental date is valid
CREATE OR REPLACE FUNCTION check_rental_date()
RETURNS TRIGGER AS $$
DECLARE
  booking_rec RECORD;
BEGIN
  SELECT * INTO booking_rec
  FROM Booking
  WHERE 
    BookingID = NEW.BookingID;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Booking does not exist.';
  END IF;

  IF NEW.RentalDate < booking_rec.StartDate THEN
    RAISE EXCEPTION 'Rental date cannot be before booking date.';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_rental_date
BEFORE INSERT ON Renting
FOR EACH ROW EXECUTE FUNCTION check_rental_date();

-- Index 1: For fast room lookup
CREATE INDEX idx_room_roomnumber ON Room (RoomNumber);

-- Index 2: For efficient booking conflict checks
CREATE INDEX idx_booking_room_dates ON Booking (RoomNumber, HotelID, CompanyName, StartDate, EndDate);

-- Index 3: For filtering hotels by location/category
CREATE INDEX idx_hotel_city_category ON Hotel (City, Category);

-- View 1: Number of available rooms per city
CREATE OR REPLACE VIEW AvailableRoomsPerCity AS
SELECT 
  H.City,
  COUNT(R.RoomNumber) AS AvailableRooms
FROM 
  Room R
JOIN Hotel H ON R.HotelID = H.HotelID AND R.CompanyName = H.CompanyName
WHERE 
  R.RoomNumber NOT IN (
    SELECT RoomNumber
    FROM Booking
    WHERE CURRENT_DATE BETWEEN StartDate AND EndDate
  )
GROUP BY H.City;

-- View 2: Aggregated capacity per hotel
CREATE OR REPLACE VIEW HotelCapacity AS
SELECT 
  HotelID,
  CompanyName,
  SUM(Capacity) AS TotalCapacity
FROM Room
GROUP BY HotelID, CompanyName;

INSERT INTO Headquarters (CompanyName, NumberOfHotels, StreetNumber, StreetName, AptNumber, City, State, PostalCode) VALUES
('BudgetLodge', 8, 220, 'Main Street', NULL, 'Vancouver', 'BC', 'V5K0A1'),
('EliteResorts', 8, 50, 'Beach Avenue', NULL, 'Miami', 'FL', '33101'),
('ComfortHomes', 8, 75, 'Park Lane', NULL, 'New York', 'NY', '10001'),
('UrbanEscape', 8, 10, 'Queen Street', NULL, 'Ottawa', 'ON', 'K1P1N2');

--aggregation
SELECT H.City, COUNT(*) AS TotalRooms
FROM Room R
JOIN Hotel H ON R.HotelID = H.HotelID AND R.CompanyName = H.CompanyName
GROUP BY H.City
ORDER BY TotalRooms DESC;

--nested query
SELECT *
FROM Hotel
WHERE City IN (
  SELECT City
  FROM Hotel
  GROUP BY City
  HAVING COUNT(*) > 3
);

--basic search query - five star hotels in NYC
SELECT HotelID, CompanyName, City, Category
FROM Hotel
WHERE City = 'New York' AND Category = '5-star';

-- all bookings with customer and room details

SELECT B.CheckInDate, B.CheckOutDate, C.FirstName, C.LastName, R.RoomNumber, R.Price, H.City
FROM Booking B
JOIN Customer C ON B.CustomerID = C.CustomerID
JOIN Room R ON B.RoomNumber = R.RoomNumber AND B.HotelID = R.HotelID AND B.CompanyName = R.CompanyName
JOIN Hotel H ON R.HotelID = H.HotelID AND R.CompanyName = H.CompanyName;

-- Payment Table
CREATE TABLE IF NOT EXISTS Payment (
  PaymentID SERIAL PRIMARY KEY,
  RentalID Integer,
  Amount Integer NOT NULL,
  PaymentDate Date NOT NULL,
  Method Varchar(50),
  FOREIGN KEY (RentalID) REFERENCES Renting(RentalID) ON DELETE CASCADE
);


-- Sample Data Inserts
--  Hotels (for BudgetLodge)
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode) VALUES
(100, 'BudgetLodge', '2-star', 20, 123, 'Maple Street', NULL, 'Vancouver', 'BC', 'V5K0A1'),
(101, 'BudgetLodge', '3-star', 30, 456, 'Oak Avenue', NULL, 'Calgary', 'AB', 'T2P1A1');

--  Rooms
INSERT INTO Room (RoomNumber, HotelID, CompanyName, ViewType, Price, Capacity, Expandable) VALUES
(1, 100, 'BudgetLodge', 'City', 80, 2, 'No'),
(2, 100, 'BudgetLodge', 'Mountain', 90, 3, 'Yes'),
(1, 101, 'BudgetLodge', 'City', 70, 2, 'No');

--  Customer
INSERT INTO Customer (CustomerID, SIN, RegistrationDate, FirstName, LastName, StreetNumber, StreetName, AptNumber, City, State, PostalCode) VALUES
(5002, '123456789', CURRENT_DATE, 'Gunin', 'James', 15, 'Bloor Street', NULL, 'Toronto', 'ON', 'M4W1A1');

--  Booking
INSERT INTO Booking (CheckInDate, CheckOutDate, HotelID, RoomNumber, CustomerID, CompanyName, Status) VALUES
('2025-04-01', '2025-04-05', 100, 1, 5002, 'BudgetLodge', 'Confirmed');

--  Employee
INSERT INTO Employee (EmployeeID, SIN, HotelID, CompanyName, FirstName, MiddleName, LastName, StreetNumber, StreetName, AptNumber, City, State, PostalCode) VALUES
(2001, '987654321', 100, 'BudgetLodge', 'Emily', NULL, 'Smith', 88, 'King Street', NULL, 'Vancouver', 'BC', 'V5K0B2');

--  Manages
INSERT INTO Manages (EmployeeID, HotelID, CompanyName) VALUES
(2001, 100, 'BudgetLodge');

--  Role
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName) VALUES
('Manager', 2001, 100, 'BudgetLodge');

--  Renting
INSERT INTO Renting (BookingID, RoomNumber, HotelID, CompanyName, CustomerID, EmployeeID, RentalDate) VALUES
(1, 1, 100, 'BudgetLodge', 5001, 2001, '2025-04-01');

--  Payment
INSERT INTO Payment (RentalID, Amount, PaymentDate, Method) VALUES
(1, 400, CURRENT_DATE, 'Credit Card');



-- Optional Sample Room Amenity/Issue
INSERT INTO RoomAmenity (Amenity, RoomNumber, HotelID, CompanyName) VALUES
('TV', 1, 100, 'BudgetLodge'),
('WiFi', 2, 100, 'BudgetLodge');

INSERT INTO RoomIssue (Issue, RoomNumber, HotelID, CompanyName) VALUES
('Broken Lamp', 2, 100, 'BudgetLodge');
