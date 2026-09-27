--PROCEDURE 
-- Creating a new rental
CREATE PROCEDURE CreateRental
    @CustomerID  VARCHAR(10),   -- ID of the customer making the rental
    @CarID       VARCHAR(10),   -- ID of the car being rented
    @StaffID     VARCHAR(10),   -- ID of the staff processing the rental
    @LocationID  VARCHAR(10),   -- ID of the pickup location
    @PickUpDate  DATE,          -- Rental start date
    @ReturnDate  DATE,          -- Rental end date
    @PaymentMethod VARCHAR(30)  -- Payment method (e.g. Cash, Card, Online Transfer)
AS
BEGIN
    -- Declare necessary variables
    DECLARE @CarStatus    VARCHAR(20),  -- Stores current status of the car
            @DailyRate    DECIMAL(10,2),-- Stores daily rate of the car type
            @TotalAmount  DECIMAL(10,2),-- Stores total rental cost
            @Days         INT,          -- Stores number of rental days
            @RentalID     VARCHAR(10),  -- Stores the new RentalID
            @PaymentID    VARCHAR(10),  -- Stores the new PaymentID
            @ValidPayment BIT;          -- Flag to check if payment method is valid

    -- Validate payment method
    SET @ValidPayment = CASE
        WHEN @PaymentMethod IN ('Cash', 'Card', 'Online Transfer') THEN 1
        ELSE 0
    END;

    -- If payment method is invalid raise an error and exit
    IF @ValidPayment = 0
    BEGIN
        RAISERROR('Invalid payment method. Please use Cash, Card or Online Transfer.', 16, 1);
        RETURN;
    END

    -- Validate that ReturnDate is after PickUpDate
    IF @ReturnDate <= @PickUpDate
    BEGIN
        RAISERROR('Return date must be after pickup date.', 16, 1);
        RETURN;
    END

    -- Start transaction to ensure all operations execute successfully together
    BEGIN TRANSACTION;
    BEGIN TRY

        -- Fetch current car status and daily rate
        SELECT @CarStatus = c.Status,
               @DailyRate = ct.DailyRate
        FROM   Cars c
        JOIN   Car_Types ct ON c.CarTypeID = ct.CarTypeID
        WHERE  c.CarID = @CarID;

        -- Check if car is available
        IF @CarStatus = 'Available'
        BEGIN
            -- Calculate number of days and total amount
            SET @Days        = DATEDIFF(DAY, @PickUpDate, @ReturnDate);
            SET @TotalAmount = @Days * @DailyRate;

            -- Generate new RentalID
            SET @RentalID = 'R' + RIGHT('000' + CAST(
                (SELECT ISNULL(MAX(TRY_CAST(SUBSTRING(RentalID,2,10) AS INT)),0) + 1
                 FROM Rentals) AS VARCHAR(3)), 3);

            -- Insert new rental record
            INSERT INTO Rentals
                (RentalID, PickUpDate, ReturnDate, TotalAmount, Status,
                 CustomerID, CarID, StaffID, LocationID)
            VALUES
                (@RentalID, @PickUpDate, @ReturnDate, @TotalAmount, 'Active',
                 @CustomerID, @CarID, @StaffID, @LocationID);

            -- Update car status to Rented
            UPDATE Cars
            SET    Status = 'Rented'
            WHERE  CarID  = @CarID;

            -- Generate new PaymentID
            SET @PaymentID = 'PAY' + RIGHT('000' + CAST(
                (SELECT ISNULL(MAX(TRY_CAST(SUBSTRING(PaymentID,4,10) AS INT)),0) + 1
                 FROM Payments) AS VARCHAR(3)), 3);

            -- Insert payment record
            INSERT INTO Payments
                (PaymentID, Amount, PaymentMethod, Status, RentalID)
            VALUES
                (@PaymentID, @TotalAmount, @PaymentMethod, 'Pending', @RentalID);

            -- Commit transaction if everything executes successfully
            COMMIT TRANSACTION;
            SELECT 
                   @RentalID AS RentalID,
                   @PaymentID AS PaymentID,
                   @TotalAmount AS TotalAmount,
                  'Rental created successfully' AS Message;
        END
        ELSE
        BEGIN
            -- If car is not available rollback transaction
            ROLLBACK TRANSACTION;
            RAISERROR('Car is not available for rental.', 16, 1);
        END

    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of any error
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;


EXEC CreateRental @CustomerID = 'C001', @CarID = 'CAR003', @StaffID = 'S002', @LocationID = 'LOC001', 
     @PickUpDate = '2026-04-01', @ReturnDate = '2026-04-06', @PaymentMethod = 'Card';


SELECT * FROM Rentals;
SELECT * FROM Payments;


-- Cursor
CREATE PROCEDURE GenerateMonthlyRevenueReport
    @Year INT,   -- Year to filter 
    @Month INT   -- Month to filter 
AS
BEGIN
    -- Declare variables to store each row from cursor
    DECLARE @LocationID VARCHAR(10),   -- Current location ID
            @Address VARCHAR(200),     -- Current location address
            @Revenue DECIMAL(10,2);    -- Revenue for that location

    -- Declare cursor (defines the dataset to loop through)
    DECLARE cur_Locations CURSOR FOR
    SELECT LocationID, Address
    FROM Locations;

    -- Temporary table to store results
    CREATE TABLE #RevenueReport (
        LocationID VARCHAR(10),
        Address VARCHAR(200),
        TotalRevenue DECIMAL(10,2)
    );

    -- Open cursor (load data into memory)
    OPEN cur_Locations;

    -- Fetch first row into variables
    FETCH NEXT FROM cur_Locations INTO @LocationID, @Address;

    -- Loop until no more rows
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Calculate revenue for current location
        SELECT @Revenue = ISNULL(SUM(p.Amount), 0)
        FROM Payments p
        JOIN Rentals r ON p.RentalID = r.RentalID
        WHERE r.LocationID = @LocationID
          AND p.Status = 'Paid'
          AND YEAR(r.PickUpDate) = @Year
          AND MONTH(r.PickUpDate) = @Month;

        -- Insert result into temporary table
        INSERT INTO #RevenueReport (LocationID, Address, TotalRevenue)
        VALUES (@LocationID, @Address, @Revenue);

        -- Move to next row
        FETCH NEXT FROM cur_Locations INTO @LocationID, @Address;
    END

    -- Close cursor
    CLOSE cur_Locations;

    -- Remove cursor from memory
    DEALLOCATE cur_Locations;

    -- Return final results
    SELECT LocationID,
           Address,
           TotalRevenue
    FROM #RevenueReport
    ORDER BY TotalRevenue DESC;

    -- Clean up temporary table
    DROP TABLE #RevenueReport;
END;

EXEC GenerateMonthlyRevenueReport
    @Year = 2026, @Month = 2;
