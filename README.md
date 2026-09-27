# Car Rental Management System

A car rental management system — relational database design (SQL Server), full UML/SA&D documentation, and an object-oriented Java backend (in progress).

## Overview

This project models the core operations of a car rental business: customer registration, vehicle inventory, staff-managed bookings, payments, and location management. It was built in two phases — systems analysis & design (UML modeling) followed by database implementation — with the Java application layer currently being developed to apply the design on top of the database.

## Tech Stack

- **Database:** Microsoft SQL Server (T-SQL)
- **Design & Modeling:** UML (draw.io) — Class, Use Case, Activity, State Chart, and ER diagrams
- **Backend (in progress):** Java — applying abstraction, inheritance, polymorphism, and encapsulation

## Project Status

- Database schema, seed data, stored procedures, triggers, and role-based security — complete
- Full SA&D documentation (5 UML diagrams) — complete
- Java backend — in progress

## Project Structure

```
Car-Rental-Management/
├── SQL/
│   ├── 01_schema and seed data.sql
│   ├── 02_procedure.sql
│   ├── 03_triggers.sql
│   └── 04_roles and security.sql
├── Diagrams/
│   ├── ER Diagram.png / .drawio
│   ├── Class Diagram.png / .drawio
│   ├── Use Case Diagram.png / .drawio
│   ├── Activity Diagram.png / .drawio
│   └── State Chart Diagram.png / .drawio
├── Java/            (in progress)
└── README.md
```

## Database Design

**Entity-Relationship Diagram**

![ER Diagram](Diagrams/ER%20Diagram.png)

The schema centers on seven core tables — `Customer`, `Cars`, `Car_Types`, `Locations`, `Staff`, `Rentals`, and `Payments` — plus an `Audit_Log` table populated automatically via trigger. Key relationships:

- A **Rental** links a Customer, a Car, a Staff member, and a pickup Location
- A **Payment** is tied to exactly one Rental
- Each **Car** belongs to a Car_Type, which defines its daily rate and seating capacity

### Business Logic

- **`CreateRental`** — validates payment method and date range, checks car availability, calculates cost, and inserts the rental and payment records inside a transaction with rollback on failure
- **`GenerateMonthlyRevenueReport`** — uses a cursor to compute total revenue per location for a given month/year
- **Triggers:**
  - `trg_PreventUnavailableCarRentals` — blocks booking a car that isn't marked Available
  - `trg_RestoreCarOnCompletion` — automatically frees up a car when its rental is completed or cancelled
  - `trg_AuditPaymentChanges` — logs every payment status change to `Audit_Log`
- **Role-based security** — three roles (`AdminRole`, `StaffRole`, `CustomerRole`) with scoped `GRANT`/`REVOKE` permissions per table

## System Design (UML)

| Diagram | Description |
|---|---|
| ![Class Diagram](Diagrams/Class%20Diagram.png) | **Class Diagram** — object model of the system's core entities |
| ![Use Case Diagram](Diagrams/Use%20Case%20Diagram.png) | **Use Case Diagram** — actor interactions across customer, staff, and system roles |
| ![Activity Diagram](Diagrams/Activity%20Diagram.png) | **Activity Diagram** — end-to-end booking flow from login through payment and cancellation |
| ![State Chart Diagram](Diagrams/State%20Chart%20Diagram.png) | **State Chart Diagram** — lifecycle states of a rental (Active, Completed, Cancelled) |

## Getting Started

1. Clone the repository
2. Open SQL Server Management Studio (SSMS) and run the scripts in `/SQL` **in order** (01 → 04)
3. Replace the placeholder passwords in `04_roles and security.sql` with your own before running
4. Run the sample `EXEC` statements in `02_procedure.sql` to test rental creation and revenue reporting

## Roadmap

- Java domain classes (`Customer`, `Staff`, `Car`, `Rental`, `Payment`) using abstraction and inheritance
- `RentalService` class connecting the Java layer to the SQL Server database
- Console-based demo of core operations (book a rental, generate a report)

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
