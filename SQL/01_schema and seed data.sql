CREATE DATABASE CarRental;
USE CarRental;

-- Create Table Customer
CREATE TABLE Customer (
    CustomerID      VARCHAR(10)   NOT NULL PRIMARY KEY,
    FirstName       VARCHAR(50)   NOT NULL,
    LastName        VARCHAR(50)   NOT NULL,
    DateOfBirth     DATE          NOT NULL,
    LicenseNo       VARCHAR(20)   NOT NULL UNIQUE,
    Email           VARCHAR(100)  NOT NULL UNIQUE,
    Customer_Phone  VARCHAR(15)
);

SELECT * FROM Customer


-- Create Table Cars
CREATE TABLE Cars (
    CarID        VARCHAR(10)  NOT NULL PRIMARY KEY,
    LicencePlate VARCHAR(20)  NOT NULL UNIQUE,
    Make         VARCHAR(50)  NOT NULL,
    Model        VARCHAR(50)  NOT NULL,
    Year         INT          NOT NULL,
    Colour       VARCHAR(30),
    Mileage      INT          NOT NULL DEFAULT 0,
    Status       VARCHAR(20)  NOT NULL DEFAULT 'Available',
    CarTypeID    VARCHAR(10)  NOT NULL
);

SELECT * FROM Cars

-- Create Table Car Types
CREATE TABLE Car_Types (
    CarTypeID        VARCHAR(10)  NOT NULL PRIMARY KEY,
    TypeName         VARCHAR(50)  NOT NULL,
    DailyRate        DECIMAL(8,2) NOT NULL,
    SeatingCapacity  INT          NOT NULL
);

SELECT * FROM Car_Types

-- Adding FK to Cars
ALTER TABLE Cars
    ADD CONSTRAINT fk_Cars_CarType
    FOREIGN KEY (CarTypeID) REFERENCES Car_Types(CarTypeID);

-- Create Table Locations
CREATE TABLE Locations (
    LocationID    VARCHAR(10)   NOT NULL PRIMARY KEY,
    Address       VARCHAR(200)  NOT NULL,
    Phone         VARCHAR(15)   NOT NULL UNIQUE,
    OpeningHours  VARCHAR(100)
);

SELECT * FROM Locations

-- Create Table Staff
CREATE TABLE Staff (
    StaffID     VARCHAR(10)  NOT NULL PRIMARY KEY,
    FirstName   VARCHAR(50)  NOT NULL,
    LastName    VARCHAR(50)  NOT NULL,
    Role        VARCHAR(50)  NOT NULL,
    LocationID  VARCHAR(10)  NOT NULL,
    FOREIGN KEY (LocationID) REFERENCES Locations(LocationID)
);

SELECT * FROM Staff

-- Create Table Rentals
CREATE TABLE Rentals (
    RentalID     VARCHAR(10)   NOT NULL PRIMARY KEY,
    PickUpDate   DATE          NOT NULL,
    ReturnDate   DATE,
    TotalAmount  DECIMAL(10,2),
    Status       VARCHAR(20)   NOT NULL DEFAULT 'Active',
    CustomerID   VARCHAR(10)   NOT NULL,
    CarID        VARCHAR(10)   NOT NULL,
    StaffID      VARCHAR(10)   NOT NULL,
    LocationID   VARCHAR(10)   NOT NULL,
    FOREIGN KEY (CustomerID)  REFERENCES Customer(CustomerID),
    FOREIGN KEY (CarID)       REFERENCES Cars(CarID),
    FOREIGN KEY (StaffID)     REFERENCES Staff(StaffID),
    FOREIGN KEY (LocationID)  REFERENCES Locations(LocationID)
);

SELECT * FROM Rentals


-- Create Table Payments
CREATE TABLE Payments (
    PaymentID      VARCHAR(10)   NOT NULL PRIMARY KEY,
    Amount         DECIMAL(10,2) NOT NULL,
    PaymentMethod  VARCHAR(30)   NOT NULL,
    Status         VARCHAR(20)   NOT NULL DEFAULT 'Pending',
    RentalID       VARCHAR(10)   NOT NULL,
    FOREIGN KEY (RentalID) REFERENCES Rentals(RentalID)
);

SELECT * FROM Payments


-- Inserting Values
-- Customer Table
INSERT INTO Customer (CustomerID, FirstName, LastName, DateOfBirth, LicenseNo, Email, Customer_Phone)
VALUES
('C001', 'Solomon',  'Anyeneh',  '2005-05-14', 'LN123456', 'solomon@email.com',  '57201234'),
('C002', 'Azhar',    'Bhukoo',  '2005-11-22', 'LN654321', 'azhar@email.com',    '57205678'),
('C003', 'Zwahir',  'Dahal',  '2005-03-08', 'LN987654', 'zwahir@email.com',  '57209012'),
('C004', 'Akhil',  'Khundoo',    '2005-07-19', 'LN112233', 'akhil@email.com',  '57203456'),
('C005', 'Emma',   'Taylor', '2000-01-30', 'LN445566', 'emma@email.com',   '57207890'),
('C006', 'Frank',  'Wilson', '1992-09-25', 'LN778899', 'frank@email.com',  '57201111'),
('C007', 'Grace',  'Martin', '1988-04-11', 'LN332211', 'grace@email.com',  '57202222'),
('C008', 'Henry',  'Davis',  '1975-12-03', 'LN556677', 'henry@email.com',  '57203333'),
('C009', 'Isla',   'Clark',  '1998-06-17', 'LN998877', 'isla@email.com',   '57204444'),
('C010', 'James',  'White',  '1983-08-29', 'LN664455', 'james@email.com',  '57205555');

-- Car Types Table
INSERT INTO Car_Types (CarTypeID, TypeName, DailyRate, SeatingCapacity)
VALUES
('CT001', 'Economy',     800,  5),
('CT002', 'Compact',    1200,  5),
('CT003', 'SUV',        2000,  7),
('CT004', 'Luxury',     4500,  4),
('CT005', 'Minivan',    2500,  8),
('CT006', 'Pickup',     1800,  5),
('CT007', 'Sports',     3500,  2),
('CT008', 'Hybrid',     1500,  5),
('CT009', 'Electric',   2200,  5),
('CT010', 'Convertible',3000,  4);

-- Cars Table
INSERT INTO Cars (CarID, LicencePlate, Make, Model, Year, Colour, Mileage, Status, CarTypeID)
VALUES
('CAR001', 'AB1234', 'Toyota',   'Corolla',   2020, 'White',  12000, 'Available',   'CT001'),
('CAR002', 'CD5678', 'Honda',    'Civic',      2019, 'Blue',   34000, 'Rented',      'CT002'),
('CAR003', 'EF9012', 'Ford',     'Explorer',   2021, 'Black',   8500, 'Available',   'CT003'),
('CAR004', 'GH3456', 'BMW',      '5 Series',   2022, 'Silver',  5200, 'Available',   'CT004'),
('CAR005', 'IJ7890', 'Kia',      'Carnival',   2020, 'Grey',   22000, 'Maintenance', 'CT005'),
('CAR006', 'KL2345', 'Nissan',   'Almera',     2018, 'Red',    50000, 'Available',   'CT001'),
('CAR007', 'MN6789', 'Hyundai',  'Tucson',     2023, 'White',   3000, 'Rented',      'CT003'),
('CAR008', 'OP1234', 'Toyota',   'Hilux',      2021, 'Black',  15000, 'Available',   'CT006'),
('CAR009', 'QR5678', 'Mazda',    'MX-5',       2022, 'Red',     7000, 'Available',   'CT007'),
('CAR010', 'ST9012', 'Tesla',    'Model 3',    2023, 'White',   4000, 'Available',   'CT009');

-- Locations Table
INSERT INTO Locations (LocationID, Address, Phone, OpeningHours)
VALUES
('LOC001', '12 Grand Baie Road, Port Louis',      '57001111', 'Mon-Sat 8am-6pm'),
('LOC002', '45 Flic en Flac Ave, Riviere Noire',  '57002222', 'Mon-Fri 9am-5pm'),
('LOC003', '8 Royal Road, Curepipe',              '57003333', 'Mon-Sun 7am-8pm'),
('LOC004', '23 Main Street, Quatre Bornes',       '57004444', 'Mon-Sat 8am-7pm'),
('LOC005', '67 Beach Road, Grand Baie',           '57005555', 'Mon-Sun 8am-9pm'),
('LOC006', '15 Pope Hennessy St, Port Louis',     '57006666', 'Mon-Fri 8am-6pm'),
('LOC007', '90 Trianon Road, Vacoas',             '57007777', 'Mon-Sat 9am-6pm'),
('LOC008', '34 Remy Ollier St, Port Louis',       '57008888', 'Mon-Fri 8am-5pm'),
('LOC009', '56 Mahebourg Road, Rose Hill',        '57009999', 'Mon-Sun 7am-7pm'),
('LOC010', '11 Vandermeersch St, Beau Bassin',    '57000000', 'Mon-Sat 8am-6pm');

-- Staffs Table
INSERT INTO Staff (StaffID, FirstName, LastName, Role, LocationID)
VALUES
('S001', 'James',   'Martin',   'Branch Manager', 'LOC001'),
('S002', 'Linda',   'Davis',    'Rental Agent',   'LOC001'),
('S003', 'Mark',    'Wilson',   'Rental Agent',   'LOC002'),
('S004', 'Sara',    'Thompson', 'Branch Manager', 'LOC002'),
('S005', 'Tom',     'Clark',    'Rental Agent',   'LOC003'),
('S006', 'Nina',    'Adams',    'Branch Manager', 'LOC003'),
('S007', 'Peter',   'Hall',     'Rental Agent',   'LOC004'),
('S008', 'Rachel',  'Young',    'Branch Manager', 'LOC004'),
('S009', 'Steven',  'King',     'Rental Agent',   'LOC005'),
('S010', 'Tina',    'Scott',    'Branch Manager', 'LOC005');

-- Rental Table
INSERT INTO Rentals (RentalID, PickUpDate, ReturnDate, TotalAmount, Status, CustomerID, CarID, StaffID, LocationID)
VALUES
('R001', '2026-01-05', '2026-01-10',  4000, 'Completed', 'C001', 'CAR001', 'S002', 'LOC001'),
('R002', '2026-01-12', '2026-01-17',  6000, 'Completed', 'C002', 'CAR002', 'S003', 'LOC002'),
('R003', '2026-01-20', '2026-01-28', 36000, 'Completed', 'C003', 'CAR004', 'S001', 'LOC001'),
('R004', '2026-02-01', '2026-02-06', 10000, 'Completed', 'C004', 'CAR007', 'S005', 'LOC003'),
('R005', '2026-02-08', '2026-02-12',  3200, 'Completed', 'C005', 'CAR006', 'S002', 'LOC001'),
('R006', '2026-02-15', '2026-02-20', 10000, 'Completed', 'C006', 'CAR003', 'S003', 'LOC002'),
('R007', '2026-02-22', '2026-03-01', 31500, 'Completed', 'C007', 'CAR004', 'S004', 'LOC002'),
('R008', '2026-03-03', '2026-03-08', 12500, 'Completed', 'C008', 'CAR005', 'S006', 'LOC003'),
('R009', '2026-03-10', '2026-03-12',  1600, 'Completed', 'C009', 'CAR001', 'S007', 'LOC004'),
('R010', '2026-03-20', '2026-03-24',  8800, 'Active',    'C010', 'CAR010', 'S009', 'LOC005');

-- Payments Table
INSERT INTO Payments (PaymentID, Amount, PaymentMethod, Status,RentalID)
VALUES
('PAY001',  4000, 'Card',            'Paid',    'R001'),
('PAY002',  6000, 'Cash',            'Paid',    'R002'),
('PAY003', 36000, 'Online Transfer', 'Paid',    'R003'),
('PAY004', 10000, 'Card',            'Paid',    'R004'),
('PAY005',  3200, 'Cash',            'Paid',    'R005'),
('PAY006', 10000, 'Card',            'Paid',    'R006'),
('PAY007', 31500, 'Online Transfer', 'Paid',    'R007'),
('PAY008', 12500, 'Cash',            'Paid',    'R008'),
('PAY009',  1600, 'Card',            'Paid',    'R009'),
('PAY010',  8800, 'Online Transfer', 'Pending', 'R010');
