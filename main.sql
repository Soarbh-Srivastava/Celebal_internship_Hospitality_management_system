-- ===========================================
-- Hotel Room Reservation System SQL Project
-- ===========================================

-- 1. TABLE CREATION (DDL)
-- -----------------------

-- Drop existing tables (if any)
IF OBJECT_ID('Bills', 'U') IS NOT NULL DROP TABLE Bills;
IF OBJECT_ID('Reservations', 'U') IS NOT NULL DROP TABLE Reservations;
IF OBJECT_ID('Rooms', 'U') IS NOT NULL DROP TABLE Rooms;
IF OBJECT_ID('Hotels', 'U') IS NOT NULL DROP TABLE Hotels;
IF OBJECT_ID('Users', 'U') IS NOT NULL DROP TABLE Users;

-- Users table
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY,
    Username NVARCHAR(50) NOT NULL,
    Password NVARCHAR(100) NOT NULL,   -- In production, use hashing
    Email NVARCHAR(100),
    Role NVARCHAR(20)
);

-- Hotels table
CREATE TABLE Hotels (
    HotelID INT PRIMARY KEY IDENTITY,
    HotelName NVARCHAR(100) NOT NULL,
    Location NVARCHAR(100),
    Description NVARCHAR(255)
);

-- Rooms table
CREATE TABLE Rooms (
    RoomID INT PRIMARY KEY IDENTITY,
    HotelID INT FOREIGN KEY REFERENCES Hotels(HotelID),
    RoomNumber NVARCHAR(10),
    RoomType NVARCHAR(20),
    Price DECIMAL(10,2)
);

-- Reservations table
CREATE TABLE Reservations (
    ReservationID INT PRIMARY KEY IDENTITY,
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    RoomID INT FOREIGN KEY REFERENCES Rooms(RoomID),
    CheckInDate DATE,
    CheckOutDate DATE,
    Status NVARCHAR(20) CHECK (Status IN ('booked', 'checked-in', 'checked-out'))
);

-- Bills table
CREATE TABLE Bills (
    BillID INT PRIMARY KEY IDENTITY,
    ReservationID INT FOREIGN KEY REFERENCES Reservations(ReservationID),
    Amount DECIMAL(10,2),
    IssueDate DATE,
    Status NVARCHAR(20) CHECK (Status IN ('unpaid', 'paid'))
);

-- 2. SAMPLE DATA
-- --------------

-- Sample users
INSERT INTO Users (Username, Password, Email, Role)
VALUES 
('admin', 'admin123', 'admin@hotel.com', 'admin'),
('guest1', 'guest123', 'guest1@hotel.com', 'guest');

-- Sample hotels
INSERT INTO Hotels (HotelName, Location, Description)
VALUES 
('Grand Palace', 'Mumbai', 'Luxury hotel in Mumbai'),
('Sea View', 'Goa', 'Beachside hotel in Goa');

-- Sample rooms
INSERT INTO Rooms (HotelID, RoomNumber, RoomType, Price)
VALUES 
(1, '101', 'Deluxe', 5000),
(1, '102', 'Suite', 8000),
(2, '201', 'Standard', 3000),
(2, '202', 'Deluxe', 4500);

-- 3. STORED PROCEDURES
-- --------------------

-- a. LoginUser
IF OBJECT_ID('LoginUser', 'P') IS NOT NULL DROP PROCEDURE LoginUser;
GO
CREATE PROCEDURE LoginUser
    @Username NVARCHAR(50),
    @Password NVARCHAR(100)
AS
BEGIN
    SELECT UserID, Username, Role
    FROM Users
    WHERE Username = @Username AND Password = @Password;
END
GO

-- b. RegisterHotel
IF OBJECT_ID('RegisterHotel', 'P') IS NOT NULL DROP PROCEDURE RegisterHotel;
GO
CREATE PROCEDURE RegisterHotel
    @HotelName NVARCHAR(100),
    @Location NVARCHAR(100),
    @Description NVARCHAR(255)
AS
BEGIN
    INSERT INTO Hotels (HotelName, Location, Description)
    VALUES (@HotelName, @Location, @Description);
END
GO

-- c. RegisterRoom
IF OBJECT_ID('RegisterRoom', 'P') IS NOT NULL DROP PROCEDURE RegisterRoom;
GO
CREATE PROCEDURE RegisterRoom
    @HotelID INT,
    @RoomNumber NVARCHAR(10),
    @RoomType NVARCHAR(20),
    @Price DECIMAL(10,2)
AS
BEGIN
    INSERT INTO Rooms (HotelID, RoomNumber, RoomType, Price)
    VALUES (@HotelID, @RoomNumber, @RoomType, @Price);
END
GO

-- d. CheckRoomAvailability
IF OBJECT_ID('CheckRoomAvailability', 'P') IS NOT NULL DROP PROCEDURE CheckRoomAvailability;
GO
CREATE PROCEDURE CheckRoomAvailability
    @RoomID INT,
    @CheckInDate DATE,
    @CheckOutDate DATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM Reservations
        WHERE RoomID = @RoomID
        AND Status IN ('booked', 'checked-in')
        AND (@CheckInDate < CheckOutDate AND @CheckOutDate > CheckInDate)
    )
        SELECT 'Not Available' AS Availability;
    ELSE
        SELECT 'Available' AS Availability;
END
GO

-- e. MakeReservation
IF OBJECT_ID('MakeReservation', 'P') IS NOT NULL DROP PROCEDURE MakeReservation;
GO
CREATE PROCEDURE MakeReservation
    @UserID INT,
    @RoomID INT,
    @CheckInDate DATE,
    @CheckOutDate DATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM Reservations
        WHERE RoomID = @RoomID
        AND Status IN ('booked', 'checked-in')
        AND (@CheckInDate < CheckOutDate AND @CheckOutDate > CheckInDate)
    )
    BEGIN
        SELECT 'Room not available for the selected dates.' AS Message;
    END
    ELSE
    BEGIN
        INSERT INTO Reservations (UserID, RoomID, CheckInDate, CheckOutDate, Status)
        VALUES (@UserID, @RoomID, @CheckInDate, @CheckOutDate, 'booked');
        SELECT 'Reservation successful.' AS Message;
    END
END
GO

-- f. GenerateBill
IF OBJECT_ID('GenerateBill', 'P') IS NOT NULL DROP PROCEDURE GenerateBill;
GO
CREATE PROCEDURE GenerateBill
    @ReservationID INT
AS
BEGIN
    DECLARE @Amount DECIMAL(10,2);
    SELECT @Amount = DATEDIFF(day, CheckInDate, CheckOutDate) * r.Price
    FROM Reservations res
    JOIN Rooms r ON res.RoomID = r.RoomID
    WHERE res.ReservationID = @ReservationID;

    INSERT INTO Bills (ReservationID, Amount, IssueDate, Status)
    VALUES (@ReservationID, @Amount, GETDATE(), 'unpaid');
END
GO

-- g. CheckIn
IF OBJECT_ID('CheckIn', 'P') IS NOT NULL DROP PROCEDURE CheckIn;
GO
CREATE PROCEDURE CheckIn
    @ReservationID INT
AS
BEGIN
    UPDATE Reservations
    SET Status = 'checked-in'
    WHERE ReservationID = @ReservationID;
END
GO

-- h. CheckOut
IF OBJECT_ID('CheckOut', 'P') IS NOT NULL DROP PROCEDURE CheckOut;
GO
CREATE PROCEDURE CheckOut
    @ReservationID INT
AS
BEGIN
    UPDATE Reservations
    SET Status = 'checked-out'
    WHERE ReservationID = @ReservationID;
END
GO

-- i. SuggestAvailableRooms (New Procedure)
IF OBJECT_ID('SuggestAvailableRooms', 'P') IS NOT NULL DROP PROCEDURE SuggestAvailableRooms;
GO
CREATE PROCEDURE SuggestAvailableRooms
    @HotelID INT,
    @CheckInDate DATE,
    @CheckOutDate DATE
AS
BEGIN
    SELECT * FROM Rooms
    WHERE HotelID = @HotelID
    AND RoomID NOT IN (
        SELECT RoomID FROM Reservations
        WHERE Status IN ('booked', 'checked-in')
        AND (@CheckInDate < CheckOutDate AND @CheckOutDate > CheckInDate)
    );
END
GO

-- ===========================================
-- End of Updated Hotel Room Reservation Script
-- ===========================================

 --Example Usage
 EXEC LoginUser 'guest1', 'guest123';
 EXEC RegisterHotel 'City Inn', 'Delhi', 'Business hotel in Delhi';
 EXEC RegisterRoom 1, '103', 'Standard', 4000;
 EXEC CheckRoomAvailability 1, '2025-07-10', '2025-07-12';
 EXEC MakeReservation 2, 1, '2025-07-10', '2025-07-12';
 EXEC GenerateBill 1;
 EXEC CheckIn 1;
 EXEC CheckOut 1;
 EXEC SuggestAvailableRooms 1, '2025-07-10', '2025-07-12';
