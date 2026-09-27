- TRIGGERS
-- TRIGGER: trg_PreventUnavailableCarRental
CREATE TRIGGER trg_PreventUnavailableCarRentals
ON Rentals
INSTEAD OF INSERT
AS
BEGIN
    -- Check if any car in the attempted insert is not Available
    IF EXISTS (
        SELECT 1
        FROM   inserted i
        JOIN   Cars c ON i.CarID = c.CarID
        WHERE  c.Status <> 'Available'
    )
    BEGIN
        -- Car is not available
        RAISERROR('Cannot create rental: car is not available.', 16, 1);
        RETURN;
    END

    -- Car is available 
    INSERT INTO Rentals (RentalID, PickUpDate, ReturnDate, TotalAmount,
                         Status, CustomerID, CarID, StaffID, LocationID)
    SELECT RentalID, PickUpDate, ReturnDate, TotalAmount,
           Status, CustomerID, CarID, StaffID, LocationID
    FROM inserted;
END;


-- TEST: Try to insert a rental for a car that is NOT Available
INSERT INTO Rentals (RentalID, PickUpDate, ReturnDate, TotalAmount,
                     Status, CustomerID, CarID, StaffID, LocationID)
VALUES ('R100', '2026-04-10', '2026-04-15', 5000,
        'Active', 'C001', 'CAR002', 'S001', 'LOC001');

-- VERIFY: Check car status to confirm nothing was inserted
SELECT CarID, Status
FROM   Cars
WHERE  CarID = 'CAR002';


-- TRIGGER: trg_RestoreCarOnCompletion
CREATE TRIGGER trg_RestoreCarOnCompletion
ON Rentals
AFTER UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM   inserted i
        JOIN   deleted  d ON i.RentalID = d.RentalID
        WHERE  i.Status IN ('Completed', 'Cancelled')
          AND  d.Status NOT IN ('Completed', 'Cancelled')
    )
    BEGIN
        -- Restore car status to Available
        UPDATE Cars
        SET    Status = 'Available'
        WHERE  CarID IN (
            SELECT i.CarID
            FROM   inserted i
            JOIN   deleted  d ON i.RentalID = d.RentalID
            WHERE  i.Status IN ('Completed', 'Cancelled')
              AND  d.Status NOT IN ('Completed', 'Cancelled')
        );
    END
END;


-- Check car status BEFORE
SELECT CarID, Status
FROM   Cars
WHERE  CarID = 'CAR010';

-- Complete the rental
UPDATE Rentals
SET    Status = 'Completed'
WHERE  RentalID = 'R010';

-- Check car status AFTER
SELECT CarID, Status
FROM   Cars
WHERE  CarID = 'CAR010';


-- Create the Audit_Log table
CREATE TABLE Audit_Log (
    LogID       INT IDENTITY(1,1) PRIMARY KEY,  -- Auto-incrementing ID
    TableName   VARCHAR(50),                     -- Which table was changed
    RecordID    VARCHAR(10),                     -- Which record was changed
    Action      VARCHAR(50),                     -- What type of change
    OldValue    VARCHAR(100),                    -- Value before the change
    NewValue    VARCHAR(100),                    -- Value after the change
    ChangedAt   DATETIME DEFAULT GETDATE()       -- When the change happened
);

-- TRIGGER: trg_AuditPaymentChanges
CREATE TRIGGER trg_AuditPaymentChanges
ON Payments
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Status)
    BEGIN
        INSERT INTO Audit_Log (TableName, RecordID, Action, OldValue, NewValue)
        SELECT
            'Payments',         -- Table that was changed
            i.PaymentID,        -- Which payment record
            'STATUS_CHANGE',    -- Type of action
            d.Status,           -- Old status (before update)
            i.Status            -- New status (after update)
        FROM inserted i
        JOIN deleted  d ON i.PaymentID = d.PaymentID
        WHERE i.Status <> d.Status;  -- Only log if status actually changed
    END
END;


UPDATE Payments
SET    Status = 'Paid'
WHERE  PaymentID = 'PAY010';


SELECT LogID,
       TableName,
       RecordID    AS PaymentID,
       Action,
       OldValue    AS [Status Before],
       NewValue    AS [Status After],
       ChangedAt   AS [Changed At]
FROM   Audit_Log;
