
-- Clean Reset
DROP TABLE IF EXISTS Payment, Renting, Booking, EmployeeRole, Manages, Employee, Customer,
RoomAmenity, RoomIssue, Room, HotelEmail, HotelPhone, Hotel,
HeadquartersEmail, HeadquartersPhone, Headquarters, Company CASCADE;

-- 1. Create Company Table
CREATE TABLE Company (
    CompanyName VARCHAR(100) PRIMARY KEY
);

-- 2. Headquarters Table
CREATE TABLE Headquarters (
    CompanyName VARCHAR(100) PRIMARY KEY REFERENCES Company(CompanyName),
    StreetNumber INTEGER,
    StreetName VARCHAR(100),
    City VARCHAR(100),
    State VARCHAR(100),
    PostalCode VARCHAR(20)
);

CREATE TABLE HeadquartersPhone (
    CompanyName VARCHAR(100) REFERENCES Company(CompanyName),
    Phone VARCHAR(20)
);

CREATE TABLE HeadquartersEmail (
    CompanyName VARCHAR(100) REFERENCES Company(CompanyName),
    Email VARCHAR(100)
);

-- 3. Hotel Table
CREATE TABLE Hotel (
    HotelID SERIAL,
    CompanyName VARCHAR(100),
    Category VARCHAR(50),
    NumberOfRooms INTEGER,
    StreetNumber INTEGER,
    StreetName VARCHAR(100),
    AptNumber VARCHAR(10),
    City VARCHAR(100),
    State VARCHAR(100),
    PostalCode VARCHAR(20),
    PRIMARY KEY (HotelID, CompanyName),
    FOREIGN KEY (CompanyName) REFERENCES Company(CompanyName)
);

CREATE TABLE HotelPhone (
    HotelID INTEGER,
    CompanyName VARCHAR(100),
    Phone VARCHAR(20),
    FOREIGN KEY (HotelID, CompanyName) REFERENCES Hotel(HotelID, CompanyName)
);

CREATE TABLE HotelEmail (
    HotelID INTEGER,
    CompanyName VARCHAR(100),
    Email VARCHAR(100),
    FOREIGN KEY (HotelID, CompanyName) REFERENCES Hotel(HotelID, CompanyName)
);

-- 4. Room Table
CREATE TABLE Room (
    RoomNumber INTEGER,
    HotelID INTEGER,
    CompanyName VARCHAR(100),
    Price NUMERIC(10,2),
    Capacity VARCHAR(20),
    SeaView BOOLEAN,
    MountainView BOOLEAN,
    Extendable BOOLEAN,
    PRIMARY KEY (RoomNumber, HotelID, CompanyName),
    FOREIGN KEY (HotelID, CompanyName) REFERENCES Hotel(HotelID, CompanyName)
);

CREATE TABLE RoomIssue (
    Issue TEXT,
    RoomNumber INTEGER,
    HotelID INTEGER,
    CompanyName VARCHAR(100),
    PRIMARY KEY (Issue, RoomNumber, HotelID, CompanyName),
    FOREIGN KEY (RoomNumber, HotelID, CompanyName) REFERENCES Room(RoomNumber, HotelID, CompanyName)
);

CREATE TABLE RoomAmenity (
    Amenity TEXT,
    RoomNumber INTEGER,
    HotelID INTEGER,
    CompanyName VARCHAR(100),
    PRIMARY KEY (Amenity, RoomNumber, HotelID, CompanyName),
    FOREIGN KEY (RoomNumber, HotelID, CompanyName) REFERENCES Room(RoomNumber, HotelID, CompanyName)
);

-- 5. Customer Table
CREATE TABLE Customer (
    CustomerID SERIAL PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Address TEXT,
    IDType VARCHAR(20),
    IDNumber VARCHAR(50),
    RegistrationDate DATE DEFAULT CURRENT_DATE,
    Password TEXT
);

-- 6. Employee Table
CREATE TABLE Employee (
    EmployeeID SERIAL,
    HotelID INTEGER,
    CompanyName VARCHAR(100),
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Address TEXT,
    SIN VARCHAR(20),
    Password TEXT,
    PRIMARY KEY (EmployeeID, HotelID, CompanyName),
    FOREIGN KEY (HotelID, CompanyName) REFERENCES Hotel(HotelID, CompanyName)
);

-- 7. Roles + Management
CREATE TABLE EmployeeRole (
    Role VARCHAR(50),
    EmployeeID INTEGER,
    HotelID INTEGER,
    CompanyName VARCHAR(100),
    PRIMARY KEY (Role, EmployeeID, HotelID, CompanyName),
    FOREIGN KEY (EmployeeID, HotelID, CompanyName) REFERENCES Employee(EmployeeID, HotelID, CompanyName)
);

CREATE TABLE Manages (
    EmployeeID INTEGER,
    HotelID INTEGER,
    CompanyName VARCHAR(100),
    PRIMARY KEY (EmployeeID, HotelID, CompanyName),
    FOREIGN KEY (EmployeeID, HotelID, CompanyName) REFERENCES Employee(EmployeeID, HotelID, CompanyName)
);

-- 8. Booking and Renting
CREATE TABLE Booking (
    BookingID SERIAL PRIMARY KEY,
    RoomNumber INTEGER,
    HotelID INTEGER,
    CompanyName VARCHAR(100),
    CustomerID INTEGER,
    StartDate DATE,
    EndDate DATE,
    BookingDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (RoomNumber, HotelID, CompanyName) REFERENCES Room(RoomNumber, HotelID, CompanyName),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

CREATE TABLE Renting (
    RentalID SERIAL PRIMARY KEY,
    BookingID INTEGER,
    RoomNumber INTEGER,
    HotelID INTEGER,
    CompanyName VARCHAR(100),
    CustomerID INTEGER,
    EmployeeID INTEGER,
    RentalDate DATE,
    CheckoutDate DATE,
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID),
    FOREIGN KEY (RoomNumber, HotelID, CompanyName) REFERENCES Room(RoomNumber, HotelID, CompanyName),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (EmployeeID, HotelID, CompanyName) REFERENCES Employee(EmployeeID, HotelID, CompanyName)
);

-- 9. Payments
CREATE TABLE Payment (
    PaymentID SERIAL PRIMARY KEY,
    RentalID INTEGER REFERENCES Renting(RentalID),
    Amount NUMERIC(10, 2),
    PaymentDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PaymentMethod VARCHAR(20)
);

-- 10. Views
CREATE VIEW AvailableRoomsPerArea AS
SELECT City, COUNT(*) AS TotalRooms
FROM Hotel H
JOIN Room R ON R.HotelID = H.HotelID AND R.CompanyName = H.CompanyName
WHERE NOT EXISTS (
    SELECT 1 FROM Booking B
    WHERE B.RoomNumber = R.RoomNumber
    AND B.HotelID = R.HotelID
    AND B.CompanyName = R.CompanyName
    AND CURRENT_DATE BETWEEN B.StartDate AND B.EndDate
)
GROUP BY City;

CREATE VIEW HotelCapacity AS
SELECT H.HotelID, H.CompanyName, COUNT(*) AS RoomCount
FROM Hotel H
JOIN Room R ON R.HotelID = H.HotelID AND R.CompanyName = H.CompanyName
GROUP BY H.HotelID, H.CompanyName;

-- 11. Sample Data Insertions
-- (to be appended)

-- === Sample Data Population ===

-- Companies
INSERT INTO Company (CompanyName) VALUES ('Marriott');
INSERT INTO Headquarters (CompanyName, StreetNumber, StreetName, City, State, PostalCode) VALUES ('Marriott', 190, 'HQ Blvd', 'Montreal', 'ON', 'H1X1X1');
INSERT INTO Company (CompanyName) VALUES ('Hilton');
INSERT INTO Headquarters (CompanyName, StreetNumber, StreetName, City, State, PostalCode) VALUES ('Hilton', 767, 'HQ Blvd', 'Calgary', 'ON', 'H1X1X1');
INSERT INTO Company (CompanyName) VALUES ('HolidayInn');
INSERT INTO Headquarters (CompanyName, StreetNumber, StreetName, City, State, PostalCode) VALUES ('HolidayInn', 553, 'HQ Blvd', 'Vancouver', 'ON', 'H1X1X1');
INSERT INTO Company (CompanyName) VALUES ('LuxuryStay');
INSERT INTO Headquarters (CompanyName, StreetNumber, StreetName, City, State, PostalCode) VALUES ('LuxuryStay', 989, 'HQ Blvd', 'Calgary', 'ON', 'H1X1X1');
INSERT INTO Company (CompanyName) VALUES ('BudgetLodge');
INSERT INTO Headquarters (CompanyName, StreetNumber, StreetName, City, State, PostalCode) VALUES ('BudgetLodge', 514, 'HQ Blvd', 'Vancouver', 'ON', 'H1X1X1');

-- Hotel 1 for Marriott
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (1, 'Marriott', '2-star', 5, 463, 'Main St', NULL, 'Ottawa', 'ON', 'M9A3A3');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (100, 1, 'Marriott', 126, 'Single', TRUE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (101, 1, 'Marriott', 245, 'Suite', FALSE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (102, 1, 'Marriott', 218, 'Single', TRUE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (103, 1, 'Marriott', 244, 'Double', TRUE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (104, 1, 'Marriott', 267, 'Single', TRUE, FALSE, TRUE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1000, 1, 'Marriott', 'John', 'Doe', '123 Main St', 'SIN1000', 'pass1000');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1000, 1, 'Marriott');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1000, 1, 'Marriott');

-- Hotel 2 for Marriott
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (2, 'Marriott', 'Luxury', 5, 236, 'Main St', NULL, 'Calgary', 'ON', 'M9A6A7');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (105, 2, 'Marriott', 135, 'Suite', TRUE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (106, 2, 'Marriott', 126, 'Suite', TRUE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (107, 2, 'Marriott', 179, 'Double', FALSE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (108, 2, 'Marriott', 141, 'Double', TRUE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (109, 2, 'Marriott', 113, 'Double', TRUE, FALSE, FALSE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1001, 2, 'Marriott', 'John', 'Doe', '123 Main St', 'SIN1001', 'pass1001');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1001, 2, 'Marriott');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1001, 2, 'Marriott');

-- Hotel 3 for Marriott
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (3, 'Marriott', '2-star', 5, 722, 'Main St', NULL, 'Montreal', 'ON', 'M1A1A5');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (110, 3, 'Marriott', 278, 'Suite', FALSE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (111, 3, 'Marriott', 295, 'King', FALSE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (112, 3, 'Marriott', 289, 'Double', FALSE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (113, 3, 'Marriott', 186, 'Single', TRUE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (114, 3, 'Marriott', 242, 'Suite', TRUE, TRUE, TRUE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1002, 3, 'Marriott', 'John', 'Doe', '123 Main St', 'SIN1002', 'pass1002');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1002, 3, 'Marriott');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1002, 3, 'Marriott');

-- Hotel 4 for Marriott
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (4, 'Marriott', '2-star', 5, 797, 'Main St', NULL, 'Toronto', 'ON', 'M6A6A8');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (115, 4, 'Marriott', 117, 'Single', FALSE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (116, 4, 'Marriott', 107, 'Single', TRUE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (117, 4, 'Marriott', 275, 'King', FALSE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (118, 4, 'Marriott', 106, 'Queen', TRUE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (119, 4, 'Marriott', 137, 'Double', TRUE, TRUE, TRUE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1003, 4, 'Marriott', 'John', 'Doe', '123 Main St', 'SIN1003', 'pass1003');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1003, 4, 'Marriott');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1003, 4, 'Marriott');

-- Hotel 5 for Marriott
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (5, 'Marriott', '2-star', 5, 305, 'Main St', NULL, 'Calgary', 'ON', 'M1A6A1');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (120, 5, 'Marriott', 293, 'King', TRUE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (121, 5, 'Marriott', 136, 'Queen', TRUE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (122, 5, 'Marriott', 118, 'King', FALSE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (123, 5, 'Marriott', 253, 'Single', FALSE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (124, 5, 'Marriott', 221, 'King', TRUE, TRUE, TRUE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1004, 5, 'Marriott', 'John', 'Doe', '123 Main St', 'SIN1004', 'pass1004');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1004, 5, 'Marriott');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1004, 5, 'Marriott');

-- Hotel 6 for Marriott
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (6, 'Marriott', 'Standard', 5, 881, 'Main St', NULL, 'Montreal', 'ON', 'M5A4A5');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (125, 6, 'Marriott', 158, 'King', TRUE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (126, 6, 'Marriott', 182, 'Double', TRUE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (127, 6, 'Marriott', 290, 'King', TRUE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (128, 6, 'Marriott', 116, 'Queen', FALSE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (129, 6, 'Marriott', 240, 'Double', FALSE, TRUE, FALSE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1005, 6, 'Marriott', 'John', 'Doe', '123 Main St', 'SIN1005', 'pass1005');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1005, 6, 'Marriott');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1005, 6, 'Marriott');

-- Hotel 7 for Marriott
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (7, 'Marriott', '3-star', 5, 913, 'Main St', NULL, 'Calgary', 'ON', 'M1A1A1');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (130, 7, 'Marriott', 241, 'Single', TRUE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (131, 7, 'Marriott', 166, 'Single', TRUE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (132, 7, 'Marriott', 277, 'Double', FALSE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (133, 7, 'Marriott', 171, 'Suite', TRUE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (134, 7, 'Marriott', 110, 'Double', FALSE, TRUE, FALSE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1006, 7, 'Marriott', 'John', 'Doe', '123 Main St', 'SIN1006', 'pass1006');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1006, 7, 'Marriott');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1006, 7, 'Marriott');

-- Hotel 8 for Marriott
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (8, 'Marriott', 'Standard', 5, 779, 'Main St', NULL, 'Montreal', 'ON', 'M4A2A2');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (135, 8, 'Marriott', 182, 'Suite', TRUE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (136, 8, 'Marriott', 250, 'King', FALSE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (137, 8, 'Marriott', 259, 'Double', TRUE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (138, 8, 'Marriott', 219, 'Suite', FALSE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (139, 8, 'Marriott', 245, 'Suite', TRUE, FALSE, FALSE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1007, 8, 'Marriott', 'John', 'Doe', '123 Main St', 'SIN1007', 'pass1007');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1007, 8, 'Marriott');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1007, 8, 'Marriott');

-- Hotel 9 for Hilton
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (9, 'Hilton', '3-star', 5, 974, 'Main St', NULL, 'Montreal', 'ON', 'M1A6A6');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (140, 9, 'Hilton', 130, 'Queen', FALSE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (141, 9, 'Hilton', 210, 'Double', TRUE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (142, 9, 'Hilton', 235, 'Suite', FALSE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (143, 9, 'Hilton', 143, 'Single', FALSE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (144, 9, 'Hilton', 189, 'Suite', TRUE, FALSE, TRUE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1008, 9, 'Hilton', 'John', 'Doe', '123 Main St', 'SIN1008', 'pass1008');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1008, 9, 'Hilton');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1008, 9, 'Hilton');

-- Hotel 10 for Hilton
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (10, 'Hilton', '2-star', 5, 382, 'Main St', NULL, 'Calgary', 'ON', 'M7A9A1');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (145, 10, 'Hilton', 115, 'Single', FALSE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (146, 10, 'Hilton', 190, 'Single', FALSE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (147, 10, 'Hilton', 136, 'Suite', TRUE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (148, 10, 'Hilton', 104, 'Suite', TRUE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (149, 10, 'Hilton', 110, 'Double', TRUE, FALSE, TRUE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1009, 10, 'Hilton', 'John', 'Doe', '123 Main St', 'SIN1009', 'pass1009');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1009, 10, 'Hilton');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1009, 10, 'Hilton');

-- Hotel 11 for Hilton
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (11, 'Hilton', 'Standard', 5, 215, 'Main St', NULL, 'Toronto', 'ON', 'M7A5A4');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (150, 11, 'Hilton', 189, 'King', TRUE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (151, 11, 'Hilton', 202, 'Suite', FALSE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (152, 11, 'Hilton', 103, 'Double', FALSE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (153, 11, 'Hilton', 176, 'Queen', TRUE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (154, 11, 'Hilton', 231, 'Suite', TRUE, FALSE, FALSE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1010, 11, 'Hilton', 'John', 'Doe', '123 Main St', 'SIN1010', 'pass1010');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1010, 11, 'Hilton');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1010, 11, 'Hilton');

-- Hotel 12 for Hilton
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (12, 'Hilton', 'Standard', 5, 87, 'Main St', NULL, 'Toronto', 'ON', 'M3A9A4');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (155, 12, 'Hilton', 255, 'Double', FALSE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (156, 12, 'Hilton', 225, 'King', FALSE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (157, 12, 'Hilton', 210, 'Double', TRUE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (158, 12, 'Hilton', 253, 'Suite', TRUE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (159, 12, 'Hilton', 180, 'King', FALSE, TRUE, FALSE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1011, 12, 'Hilton', 'John', 'Doe', '123 Main St', 'SIN1011', 'pass1011');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1011, 12, 'Hilton');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1011, 12, 'Hilton');

-- Hotel 13 for Hilton
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (13, 'Hilton', 'Economy', 5, 217, 'Main St', NULL, 'Calgary', 'ON', 'M8A8A2');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (160, 13, 'Hilton', 251, 'Suite', FALSE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (161, 13, 'Hilton', 262, 'Single', FALSE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (162, 13, 'Hilton', 134, 'King', TRUE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (163, 13, 'Hilton', 166, 'Suite', TRUE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (164, 13, 'Hilton', 272, 'Double', TRUE, TRUE, FALSE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1012, 13, 'Hilton', 'John', 'Doe', '123 Main St', 'SIN1012', 'pass1012');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1012, 13, 'Hilton');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1012, 13, 'Hilton');

-- Hotel 14 for Hilton
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (14, 'Hilton', '2-star', 5, 698, 'Main St', NULL, 'Calgary', 'ON', 'M2A5A3');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (165, 14, 'Hilton', 241, 'Queen', FALSE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (166, 14, 'Hilton', 197, 'Suite', TRUE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (167, 14, 'Hilton', 142, 'Double', FALSE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (168, 14, 'Hilton', 197, 'King', FALSE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (169, 14, 'Hilton', 152, 'Suite', TRUE, FALSE, FALSE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1013, 14, 'Hilton', 'John', 'Doe', '123 Main St', 'SIN1013', 'pass1013');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1013, 14, 'Hilton');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1013, 14, 'Hilton');

-- Hotel 15 for Hilton
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (15, 'Hilton', 'Economy', 5, 300, 'Main St', NULL, 'Montreal', 'ON', 'M7A4A8');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (170, 15, 'Hilton', 102, 'Queen', TRUE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (171, 15, 'Hilton', 274, 'Suite', FALSE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (172, 15, 'Hilton', 115, 'Double', TRUE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (173, 15, 'Hilton', 107, 'King', TRUE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (174, 15, 'Hilton', 254, 'Suite', FALSE, TRUE, TRUE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1014, 15, 'Hilton', 'John', 'Doe', '123 Main St', 'SIN1014', 'pass1014');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1014, 15, 'Hilton');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1014, 15, 'Hilton');

-- Hotel 16 for Hilton
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (16, 'Hilton', 'Luxury', 5, 506, 'Main St', NULL, 'Ottawa', 'ON', 'M7A6A6');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (175, 16, 'Hilton', 185, 'Suite', FALSE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (176, 16, 'Hilton', 261, 'Suite', FALSE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (177, 16, 'Hilton', 216, 'Suite', TRUE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (178, 16, 'Hilton', 112, 'Queen', FALSE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (179, 16, 'Hilton', 265, 'Queen', TRUE, FALSE, FALSE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1015, 16, 'Hilton', 'John', 'Doe', '123 Main St', 'SIN1015', 'pass1015');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1015, 16, 'Hilton');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1015, 16, 'Hilton');

-- Hotel 17 for HolidayInn
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (17, 'HolidayInn', 'Economy', 5, 8, 'Main St', NULL, 'Montreal', 'ON', 'M2A7A3');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (180, 17, 'HolidayInn', 158, 'Suite', FALSE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (181, 17, 'HolidayInn', 167, 'King', TRUE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (182, 17, 'HolidayInn', 200, 'Suite', FALSE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (183, 17, 'HolidayInn', 135, 'Double', TRUE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (184, 17, 'HolidayInn', 107, 'Single', TRUE, FALSE, TRUE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1016, 17, 'HolidayInn', 'John', 'Doe', '123 Main St', 'SIN1016', 'pass1016');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1016, 17, 'HolidayInn');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1016, 17, 'HolidayInn');

-- Hotel 18 for HolidayInn
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (18, 'HolidayInn', 'Economy', 5, 585, 'Main St', NULL, 'Montreal', 'ON', 'M4A8A2');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (185, 18, 'HolidayInn', 151, 'Double', FALSE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (186, 18, 'HolidayInn', 166, 'Suite', FALSE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (187, 18, 'HolidayInn', 141, 'Suite', TRUE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (188, 18, 'HolidayInn', 231, 'Single', FALSE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (189, 18, 'HolidayInn', 212, 'Single', FALSE, FALSE, FALSE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1017, 18, 'HolidayInn', 'John', 'Doe', '123 Main St', 'SIN1017', 'pass1017');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1017, 18, 'HolidayInn');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1017, 18, 'HolidayInn');

-- Hotel 19 for HolidayInn
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (19, 'HolidayInn', 'Luxury', 5, 31, 'Main St', NULL, 'Montreal', 'ON', 'M9A4A8');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (190, 19, 'HolidayInn', 138, 'Single', TRUE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (191, 19, 'HolidayInn', 210, 'Double', FALSE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (192, 19, 'HolidayInn', 105, 'Double', TRUE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (193, 19, 'HolidayInn', 178, 'Suite', TRUE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (194, 19, 'HolidayInn', 231, 'Queen', FALSE, FALSE, FALSE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1018, 19, 'HolidayInn', 'John', 'Doe', '123 Main St', 'SIN1018', 'pass1018');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1018, 19, 'HolidayInn');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1018, 19, 'HolidayInn');

-- Hotel 20 for HolidayInn
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (20, 'HolidayInn', 'Luxury', 5, 436, 'Main St', NULL, 'Montreal', 'ON', 'M8A3A5');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (195, 20, 'HolidayInn', 178, 'Double', FALSE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (196, 20, 'HolidayInn', 114, 'King', FALSE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (197, 20, 'HolidayInn', 274, 'Double', TRUE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (198, 20, 'HolidayInn', 154, 'Double', TRUE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (199, 20, 'HolidayInn', 270, 'Queen', TRUE, TRUE, TRUE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1019, 20, 'HolidayInn', 'John', 'Doe', '123 Main St', 'SIN1019', 'pass1019');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1019, 20, 'HolidayInn');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1019, 20, 'HolidayInn');

-- Hotel 21 for HolidayInn
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (21, 'HolidayInn', '3-star', 5, 948, 'Main St', NULL, 'Calgary', 'ON', 'M8A9A3');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (200, 21, 'HolidayInn', 289, 'Queen', FALSE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (201, 21, 'HolidayInn', 132, 'Suite', FALSE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (202, 21, 'HolidayInn', 133, 'Single', TRUE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (203, 21, 'HolidayInn', 199, 'King', FALSE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (204, 21, 'HolidayInn', 171, 'Queen', TRUE, TRUE, FALSE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1020, 21, 'HolidayInn', 'John', 'Doe', '123 Main St', 'SIN1020', 'pass1020');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1020, 21, 'HolidayInn');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1020, 21, 'HolidayInn');

-- Hotel 22 for HolidayInn
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (22, 'HolidayInn', 'Luxury', 5, 691, 'Main St', NULL, 'Vancouver', 'ON', 'M2A2A3');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (205, 22, 'HolidayInn', 230, 'King', FALSE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (206, 22, 'HolidayInn', 110, 'King', FALSE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (207, 22, 'HolidayInn', 141, 'Double', FALSE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (208, 22, 'HolidayInn', 121, 'Double', FALSE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (209, 22, 'HolidayInn', 173, 'Suite', TRUE, FALSE, FALSE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1021, 22, 'HolidayInn', 'John', 'Doe', '123 Main St', 'SIN1021', 'pass1021');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1021, 22, 'HolidayInn');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1021, 22, 'HolidayInn');

-- Hotel 23 for HolidayInn
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (23, 'HolidayInn', '3-star', 5, 157, 'Main St', NULL, 'Calgary', 'ON', 'M1A9A5');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (210, 23, 'HolidayInn', 213, 'Double', TRUE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (211, 23, 'HolidayInn', 241, 'Double', TRUE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (212, 23, 'HolidayInn', 164, 'Double', FALSE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (213, 23, 'HolidayInn', 254, 'Suite', FALSE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (214, 23, 'HolidayInn', 292, 'King', TRUE, FALSE, TRUE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1022, 23, 'HolidayInn', 'John', 'Doe', '123 Main St', 'SIN1022', 'pass1022');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1022, 23, 'HolidayInn');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1022, 23, 'HolidayInn');

-- Hotel 24 for HolidayInn
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (24, 'HolidayInn', '3-star', 5, 133, 'Main St', NULL, 'Vancouver', 'ON', 'M8A9A5');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (215, 24, 'HolidayInn', 188, 'Suite', TRUE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (216, 24, 'HolidayInn', 162, 'Double', FALSE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (217, 24, 'HolidayInn', 276, 'King', TRUE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (218, 24, 'HolidayInn', 260, 'Double', TRUE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (219, 24, 'HolidayInn', 236, 'King', TRUE, FALSE, TRUE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1023, 24, 'HolidayInn', 'John', 'Doe', '123 Main St', 'SIN1023', 'pass1023');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1023, 24, 'HolidayInn');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1023, 24, 'HolidayInn');

-- Hotel 25 for LuxuryStay
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (25, 'LuxuryStay', 'Standard', 5, 676, 'Main St', NULL, 'Toronto', 'ON', 'M7A4A7');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (220, 25, 'LuxuryStay', 178, 'King', TRUE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (221, 25, 'LuxuryStay', 268, 'Double', FALSE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (222, 25, 'LuxuryStay', 263, 'Suite', FALSE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (223, 25, 'LuxuryStay', 151, 'King', TRUE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (224, 25, 'LuxuryStay', 144, 'Queen', TRUE, TRUE, TRUE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1024, 25, 'LuxuryStay', 'John', 'Doe', '123 Main St', 'SIN1024', 'pass1024');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1024, 25, 'LuxuryStay');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1024, 25, 'LuxuryStay');

-- Hotel 26 for LuxuryStay
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (26, 'LuxuryStay', '2-star', 5, 434, 'Main St', NULL, 'Ottawa', 'ON', 'M8A6A8');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (225, 26, 'LuxuryStay', 263, 'Double', TRUE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (226, 26, 'LuxuryStay', 276, 'King', TRUE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (227, 26, 'LuxuryStay', 209, 'Single', TRUE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (228, 26, 'LuxuryStay', 289, 'Queen', FALSE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (229, 26, 'LuxuryStay', 113, 'Suite', FALSE, TRUE, FALSE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1025, 26, 'LuxuryStay', 'John', 'Doe', '123 Main St', 'SIN1025', 'pass1025');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1025, 26, 'LuxuryStay');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1025, 26, 'LuxuryStay');

-- Hotel 27 for LuxuryStay
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (27, 'LuxuryStay', '2-star', 5, 99, 'Main St', NULL, 'Ottawa', 'ON', 'M6A2A5');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (230, 27, 'LuxuryStay', 278, 'Suite', FALSE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (231, 27, 'LuxuryStay', 235, 'Double', FALSE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (232, 27, 'LuxuryStay', 275, 'Queen', TRUE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (233, 27, 'LuxuryStay', 280, 'Double', TRUE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (234, 27, 'LuxuryStay', 270, 'King', TRUE, FALSE, FALSE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1026, 27, 'LuxuryStay', 'John', 'Doe', '123 Main St', 'SIN1026', 'pass1026');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1026, 27, 'LuxuryStay');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1026, 27, 'LuxuryStay');

-- Hotel 28 for LuxuryStay
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (28, 'LuxuryStay', 'Economy', 5, 880, 'Main St', NULL, 'Toronto', 'ON', 'M3A2A6');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (235, 28, 'LuxuryStay', 114, 'King', TRUE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (236, 28, 'LuxuryStay', 148, 'Queen', TRUE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (237, 28, 'LuxuryStay', 179, 'Queen', TRUE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (238, 28, 'LuxuryStay', 229, 'Double', TRUE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (239, 28, 'LuxuryStay', 112, 'Queen', TRUE, FALSE, FALSE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1027, 28, 'LuxuryStay', 'John', 'Doe', '123 Main St', 'SIN1027', 'pass1027');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1027, 28, 'LuxuryStay');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1027, 28, 'LuxuryStay');

-- Hotel 29 for LuxuryStay
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (29, 'LuxuryStay', 'Luxury', 5, 372, 'Main St', NULL, 'Vancouver', 'ON', 'M2A4A3');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (240, 29, 'LuxuryStay', 167, 'King', TRUE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (241, 29, 'LuxuryStay', 181, 'Queen', FALSE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (242, 29, 'LuxuryStay', 250, 'Queen', TRUE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (243, 29, 'LuxuryStay', 161, 'Double', FALSE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (244, 29, 'LuxuryStay', 189, 'King', FALSE, FALSE, FALSE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1028, 29, 'LuxuryStay', 'John', 'Doe', '123 Main St', 'SIN1028', 'pass1028');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1028, 29, 'LuxuryStay');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1028, 29, 'LuxuryStay');

-- Hotel 30 for LuxuryStay
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (30, 'LuxuryStay', 'Economy', 5, 871, 'Main St', NULL, 'Calgary', 'ON', 'M6A8A7');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (245, 30, 'LuxuryStay', 194, 'Double', TRUE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (246, 30, 'LuxuryStay', 267, 'King', TRUE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (247, 30, 'LuxuryStay', 190, 'Suite', TRUE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (248, 30, 'LuxuryStay', 145, 'Double', FALSE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (249, 30, 'LuxuryStay', 175, 'King', FALSE, FALSE, FALSE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1029, 30, 'LuxuryStay', 'John', 'Doe', '123 Main St', 'SIN1029', 'pass1029');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1029, 30, 'LuxuryStay');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1029, 30, 'LuxuryStay');

-- Hotel 31 for LuxuryStay
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (31, 'LuxuryStay', 'Standard', 5, 22, 'Main St', NULL, 'Vancouver', 'ON', 'M4A6A5');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (250, 31, 'LuxuryStay', 266, 'Single', FALSE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (251, 31, 'LuxuryStay', 248, 'King', TRUE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (252, 31, 'LuxuryStay', 202, 'Double', TRUE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (253, 31, 'LuxuryStay', 163, 'Double', TRUE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (254, 31, 'LuxuryStay', 291, 'Queen', FALSE, FALSE, TRUE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1030, 31, 'LuxuryStay', 'John', 'Doe', '123 Main St', 'SIN1030', 'pass1030');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1030, 31, 'LuxuryStay');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1030, 31, 'LuxuryStay');

-- Hotel 32 for LuxuryStay
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (32, 'LuxuryStay', '3-star', 5, 779, 'Main St', NULL, 'Calgary', 'ON', 'M7A5A6');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (255, 32, 'LuxuryStay', 223, 'King', FALSE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (256, 32, 'LuxuryStay', 275, 'Single', FALSE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (257, 32, 'LuxuryStay', 126, 'Double', TRUE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (258, 32, 'LuxuryStay', 283, 'King', TRUE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (259, 32, 'LuxuryStay', 235, 'Suite', FALSE, FALSE, TRUE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1031, 32, 'LuxuryStay', 'John', 'Doe', '123 Main St', 'SIN1031', 'pass1031');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1031, 32, 'LuxuryStay');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1031, 32, 'LuxuryStay');

-- Hotel 33 for BudgetLodge
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (33, 'BudgetLodge', 'Luxury', 5, 697, 'Main St', NULL, 'Vancouver', 'ON', 'M3A8A5');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (260, 33, 'BudgetLodge', 289, 'King', TRUE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (261, 33, 'BudgetLodge', 286, 'Queen', TRUE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (262, 33, 'BudgetLodge', 230, 'Double', FALSE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (263, 33, 'BudgetLodge', 221, 'Double', TRUE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (264, 33, 'BudgetLodge', 269, 'King', TRUE, TRUE, FALSE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1032, 33, 'BudgetLodge', 'John', 'Doe', '123 Main St', 'SIN1032', 'pass1032');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1032, 33, 'BudgetLodge');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1032, 33, 'BudgetLodge');

-- Hotel 34 for BudgetLodge
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (34, 'BudgetLodge', 'Luxury', 5, 968, 'Main St', NULL, 'Ottawa', 'ON', 'M9A4A8');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (265, 34, 'BudgetLodge', 275, 'Suite', TRUE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (266, 34, 'BudgetLodge', 231, 'Double', TRUE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (267, 34, 'BudgetLodge', 252, 'Queen', TRUE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (268, 34, 'BudgetLodge', 221, 'Single', FALSE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (269, 34, 'BudgetLodge', 290, 'Queen', FALSE, FALSE, TRUE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1033, 34, 'BudgetLodge', 'John', 'Doe', '123 Main St', 'SIN1033', 'pass1033');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1033, 34, 'BudgetLodge');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1033, 34, 'BudgetLodge');

-- Hotel 35 for BudgetLodge
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (35, 'BudgetLodge', '2-star', 5, 611, 'Main St', NULL, 'Calgary', 'ON', 'M6A9A7');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (270, 35, 'BudgetLodge', 104, 'Double', TRUE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (271, 35, 'BudgetLodge', 143, 'King', TRUE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (272, 35, 'BudgetLodge', 207, 'Single', TRUE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (273, 35, 'BudgetLodge', 217, 'Double', FALSE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (274, 35, 'BudgetLodge', 256, 'Single', FALSE, TRUE, FALSE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1034, 35, 'BudgetLodge', 'John', 'Doe', '123 Main St', 'SIN1034', 'pass1034');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1034, 35, 'BudgetLodge');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1034, 35, 'BudgetLodge');

-- Hotel 36 for BudgetLodge
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (36, 'BudgetLodge', '2-star', 5, 479, 'Main St', NULL, 'Calgary', 'ON', 'M4A7A8');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (275, 36, 'BudgetLodge', 106, 'Double', TRUE, FALSE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (276, 36, 'BudgetLodge', 223, 'Suite', FALSE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (277, 36, 'BudgetLodge', 226, 'Double', TRUE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (278, 36, 'BudgetLodge', 170, 'Double', FALSE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (279, 36, 'BudgetLodge', 189, 'King', FALSE, FALSE, FALSE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1035, 36, 'BudgetLodge', 'John', 'Doe', '123 Main St', 'SIN1035', 'pass1035');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1035, 36, 'BudgetLodge');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1035, 36, 'BudgetLodge');

-- Hotel 37 for BudgetLodge
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (37, 'BudgetLodge', 'Standard', 5, 154, 'Main St', NULL, 'Toronto', 'ON', 'M8A3A7');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (280, 37, 'BudgetLodge', 184, 'Suite', FALSE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (281, 37, 'BudgetLodge', 193, 'Single', FALSE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (282, 37, 'BudgetLodge', 213, 'Double', TRUE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (283, 37, 'BudgetLodge', 231, 'Single', FALSE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (284, 37, 'BudgetLodge', 141, 'Single', FALSE, TRUE, TRUE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1036, 37, 'BudgetLodge', 'John', 'Doe', '123 Main St', 'SIN1036', 'pass1036');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1036, 37, 'BudgetLodge');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1036, 37, 'BudgetLodge');

-- Hotel 38 for BudgetLodge
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (38, 'BudgetLodge', 'Economy', 5, 645, 'Main St', NULL, 'Ottawa', 'ON', 'M9A1A2');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (285, 38, 'BudgetLodge', 127, 'Suite', FALSE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (286, 38, 'BudgetLodge', 270, 'Double', TRUE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (287, 38, 'BudgetLodge', 257, 'King', FALSE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (288, 38, 'BudgetLodge', 148, 'Queen', FALSE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (289, 38, 'BudgetLodge', 220, 'Suite', TRUE, FALSE, TRUE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1037, 38, 'BudgetLodge', 'John', 'Doe', '123 Main St', 'SIN1037', 'pass1037');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1037, 38, 'BudgetLodge');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1037, 38, 'BudgetLodge');

-- Hotel 39 for BudgetLodge
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (39, 'BudgetLodge', '3-star', 5, 831, 'Main St', NULL, 'Calgary', 'ON', 'M3A3A8');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (290, 39, 'BudgetLodge', 177, 'Double', FALSE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (291, 39, 'BudgetLodge', 272, 'Single', TRUE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (292, 39, 'BudgetLodge', 235, 'King', FALSE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (293, 39, 'BudgetLodge', 178, 'Double', TRUE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (294, 39, 'BudgetLodge', 251, 'Queen', TRUE, FALSE, FALSE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1038, 39, 'BudgetLodge', 'John', 'Doe', '123 Main St', 'SIN1038', 'pass1038');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1038, 39, 'BudgetLodge');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1038, 39, 'BudgetLodge');

-- Hotel 40 for BudgetLodge
INSERT INTO Hotel (HotelID, CompanyName, Category, NumberOfRooms, StreetNumber, StreetName, AptNumber, City, State, PostalCode)
VALUES (40, 'BudgetLodge', 'Standard', 5, 773, 'Main St', NULL, 'Ottawa', 'ON', 'M5A9A1');
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (295, 40, 'BudgetLodge', 122, 'Suite', TRUE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (296, 40, 'BudgetLodge', 140, 'Double', TRUE, TRUE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (297, 40, 'BudgetLodge', 262, 'Double', TRUE, TRUE, TRUE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (298, 40, 'BudgetLodge', 213, 'Queen', FALSE, FALSE, FALSE);
INSERT INTO Room (RoomNumber, HotelID, CompanyName, Price, Capacity, SeaView, MountainView, Extendable)
VALUES (299, 40, 'BudgetLodge', 122, 'King', FALSE, FALSE, TRUE);
INSERT INTO Employee (EmployeeID, HotelID, CompanyName, FirstName, LastName, Address, SIN, Password)
VALUES (1039, 40, 'BudgetLodge', 'John', 'Doe', '123 Main St', 'SIN1039', 'pass1039');
INSERT INTO EmployeeRole (Role, EmployeeID, HotelID, CompanyName)
VALUES ('Manager', 1039, 40, 'BudgetLodge');
INSERT INTO Manages (EmployeeID, HotelID, CompanyName)
VALUES (1039, 40, 'BudgetLodge');

-- Sample Customer
INSERT INTO Customer (CustomerID, FirstName, LastName, Address, IDType, IDNumber, Password)
VALUES (5000, 'Alice', 'Smith', '456 Queen St', 'DriverLicense', 'DL123456', 'alicepass');

-- Sample Booking
INSERT INTO Booking (RoomNumber, HotelID, CompanyName, CustomerID, StartDate, EndDate)
VALUES (100, 1, 'Marriott', 5000, '2025-04-10', '2025-04-15');

-- Sample Renting
INSERT INTO Renting (BookingID, RoomNumber, HotelID, CompanyName, CustomerID, EmployeeID, RentalDate, CheckoutDate)
VALUES (1, 100, 1, 'Marriott', 5000, 1000, '2025-04-10', '2025-04-15');

-- Sample Payment
INSERT INTO Payment (RentalID, Amount, PaymentMethod)
VALUES (1, 1200, 'CreditCard');

ALTER TABLE Customer ADD COLUMN Email VARCHAR(100) UNIQUE;
ALTER TABLE Employee ADD COLUMN Email VARCHAR(100) UNIQUE;


-- ===============================================
-- Triggers, Indexes, and Example Queries Script
-- e-Hotels Project – Additional SQL Code
-- ===============================================

-- 1. TRIGGERS

-- Trigger 1: Prevent Overlapping Bookings
CREATE OR REPLACE FUNCTION check_booking_overlap() 
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
       SELECT 1 
       FROM Booking 
       WHERE RoomNumber = NEW.RoomNumber 
         AND HotelID = NEW.HotelID 
         AND CompanyName = NEW.CompanyName 
         AND (NEW.StartDate, NEW.EndDate) OVERLAPS (StartDate, EndDate)
    ) THEN
       RAISE EXCEPTION 'Room is already booked during the requested period';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_booking_overlap ON Booking;
CREATE TRIGGER trg_check_booking_overlap
BEFORE INSERT ON Booking
FOR EACH ROW EXECUTE FUNCTION check_booking_overlap();

-- Trigger 2: Validate Renting Dates
CREATE OR REPLACE FUNCTION check_renting_dates()
RETURNS TRIGGER AS $$
BEGIN
   IF NEW.CheckoutDate <= NEW.RentalDate THEN
      RAISE EXCEPTION 'Checkout date must be later than rental date';
   END IF;
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_renting_dates ON Renting;
CREATE TRIGGER trg_check_renting_dates
BEFORE INSERT OR UPDATE ON Renting
FOR EACH ROW EXECUTE FUNCTION check_renting_dates();

-- 2. INDEXES

-- Index 1: Fast Lookup for Bookings by Room and Date Range
CREATE INDEX IF NOT EXISTS idx_booking_room_dates 
ON Booking(RoomNumber, HotelID, CompanyName, StartDate, EndDate);

-- Index 2: Customer Email Lookup (assumes Email is UNIQUE)
CREATE UNIQUE INDEX IF NOT EXISTS idx_customer_email 
ON Customer(Email);

-- Index 3: Employee Lookup by Hotel
CREATE INDEX IF NOT EXISTS idx_employee_hotel 
ON Employee(HotelID, CompanyName);

-- 3. EXAMPLE QUERIES

-- Query 1: List Available Rooms in a Specified City (e.g., Toronto)
SELECT R.RoomNumber, R.Price, R.Capacity, H.City
FROM Room R
JOIN Hotel H 
  ON R.HotelID = H.HotelID AND R.CompanyName = H.CompanyName
WHERE H.City = 'Toronto';

-- Query 2: Aggregation – Total Number of Rooms per Hotel Chain
SELECT CompanyName, COUNT(*) AS TotalRooms
FROM Hotel
GROUP BY CompanyName;

-- Query 3: Nested Query – Get Booking for the Room with the Highest Price
SELECT *
FROM Booking
WHERE RoomNumber = (
    SELECT RoomNumber 
    FROM Room 
    ORDER BY Price DESC 
    LIMIT 1
);

-- Query 4: Aggregation – Total Capacity of All Rooms per Hotel
-- Assumes 'Single'=1, 'Double'=2, 'Suite'=3; adjust values as needed.
SELECT HotelID, CompanyName, 
       SUM(CASE 
             WHEN Capacity = 'Single' THEN 1
             WHEN Capacity = 'Double' THEN 2
             WHEN Capacity = 'Suite' THEN 3
             ELSE 0 
           END) AS TotalCapacity
FROM Room
GROUP BY HotelID, CompanyName;
ALTER TABLE Booking ADD COLUMN Status VARCHAR(20);
