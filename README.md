# 🏨 Hotel Room Reservation System – SQL Project

This project implements a basic hotel room reservation system using Microsoft SQL Server. It includes the creation of tables, stored procedures, and sample data to simulate a real-world booking workflow.

---

## 📌 Features

- ✅ User login with role management (admin/guest)
- 🏨 Hotel and room registration by admins
- 🔍 Room availability checking for specific dates
- 📝 Room booking with overlap validation
- 💵 Automatic bill generation based on stay duration
- 🛎️ Check-in and check-out functionality
- 🛏️ Room suggestions if requested room is unavailable

---

## 🛠️ Technologies

- SQL Server (T-SQL)
- SSMS or Azure Data Studio (Recommended)
- DDL, DML, and Stored Procedures

---

## 🗃️ Database Schema

- **Users**: Login and role info  
- **Hotels**: Basic hotel details  
- **Rooms**: Linked to hotels with price and type  
- **Reservations**: Tracks user bookings with dates and status  
- **Bills**: Tracks billing for each reservation  

---

## 🚀 Setup Instructions

1. Open SQL Server Management Studio (SSMS)
2. Create and select a new database (or let the script handle it)
3. Run the script [`Humanized_Hotel_DB_Project.sql`](./Humanized_Hotel_DB_Project.sql)
4. Optional: Modify or insert your own sample data

---

## 📋 Sample Stored Procedures

| Procedure             | Description                                      |
|----------------------|--------------------------------------------------|
| `UserLogin`          | Authenticates a user based on credentials       |
| `AddHotel`           | Inserts a new hotel into the database           |
| `RoomRegister`       | Adds a new room to a hotel                      |
| `CheckRoom`          | Checks room availability for given dates       |
| `RoomBooking`        | Makes reservation if the room is available      |
| `BillGen`            | Calculates and inserts the bill for reservation |
| `CheckIn` / `CheckOut` | Updates the reservation status                |
| `SuggestAvailableRooms` | Returns list of available rooms in hotel     |

---

## 📎 Example Usage

```sql
EXEC UserLogin 'guest1', 'guest123';
EXEC AddHotel 'City Inn', 'Delhi', 'Business hotel';
EXEC RoomRegister 1, '103', 'Standard', 4000;
EXEC CheckRoom 1, '2025-07-10', '2025-07-12';
EXEC RoomBooking 2, 1, '2025-07-10', '2025-07-12';
EXEC BillGen 1;
EXEC CheckIn 1;
EXEC CheckOut 1;
EXEC SuggestAvailableRooms 1, '2025-07-10', '2025-07-12';
