---Testing
----Create Roles----
CREATE ROLE AdminRole;
CREATE ROLE StaffRole;
CREATE ROLE CustomerRole;

----creating logins----
-- NOTE: passwords redacted for public repo. Replace with your own before running locally.
CREATE LOGIN admin_user WITH PASSWORD = '<your_password_here>';
CREATE LOGIN staff_user WITH PASSWORD = '<your_password_here>';
CREATE LOGIN customer_user WITH PASSWORD = '<your_password_here>';

----creating users (mapped to login)----
CREATE USER admin_user FOR LOGIN admin_user;
CREATE USER staff_user FOR LOGIN staff_user;
CREATE USER customer_user FOR LOGIN customer_user;

----assign users to roles----
ALTER ROLE AdminRole ADD MEMBER admin_user;
ALTER ROLE StaffRole ADD MEMBER staff_user;
ALTER ROLE CustomerRole ADD MEMBER customer_user;

----granting privileges to admin (full access)----
GRANT SELECT, INSERT, UPDATE, DELETE ON Customer TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Cars TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Rentals TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Payments TO AdminRole;

----granting privileges to staff (can manage rentals)----
GRANT SELECT ON Customer TO StaffRole;
GRANT SELECT ON Cars TO StaffRole;
GRANT SELECT, INSERT, UPDATE ON Rentals TO StaffRole;
GRANT SELECT, INSERT ON Payments TO StaffRole;

----granting privileges to customers (limited access)----
GRANT SELECT ON Cars TO CustomerRole;
GRANT SELECT, INSERT ON Rentals TO CustomerRole;
GRANT SELECT ON Payments TO CustomerRole;

-- Test: verify staff_user's role membership
SELECT 
    dp.name AS UserName,
    dp2.name AS RoleName
FROM sys.database_role_members drm
JOIN sys.database_principals dp ON drm.member_principal_id = dp.principal_id
JOIN sys.database_principals dp2 ON drm.role_principal_id = dp2.principal_id
WHERE dp.name = 'staff_user';

-- Test: confirm staff_user CAN read Payments BEFORE revoke
EXECUTE AS USER = 'staff_user';
SELECT * FROM Payments;  
REVERT;

-- Revoke SELECT on Payments from StaffRole
REVOKE SELECT ON Payments FROM StaffRole;

-- Test: confirm staff_user CANNOT read Payments AFTER revoke
EXECUTE AS USER = 'staff_user';
SELECT * FROM Payments; 
REVERT;