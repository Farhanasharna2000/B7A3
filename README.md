# Football Ticket Booking System — SQL Database

A relational database for managing football match ticket bookings. It models the
people who use the platform (`Users`), the matches that tickets are sold for
(`Matches`), and the bookings that connect them (`Bookings`). The project also
ships a set of sample queries that demonstrate common reporting and lookup tasks.

## Tech Stack

- **PostgreSQL** — uses Postgres-specific features such as `ENUM` types,
  `ILIKE` (case-insensitive matching), `FULL JOIN`, and `OFFSET ... LIMIT`.

## Schema Overview

The database contains three tables and several custom `ENUM` types.

### Custom Types (ENUMs)

| Type | Allowed Values |
| --- | --- |
| `user_role` | `Ticket Manager`, `Football Fan` |
| `tournament_category_type` | `Champions League`, `Premier League`, `Serie A` |
| `match_status_type` | `Available`, `Selling Fast`, `Sold Out`, `Postponed` |
| `payment_status_type` | `Pending`, `Confirmed`, `Cancelled`, `Refunded` |

### `Users`

Stores everyone who interacts with the platform.

| Column | Type | Constraints |
| --- | --- | --- |
| `user_id` | `INT` | Primary key |
| `full_name` | `varchar(100)` | Not null |
| `email` | `varchar(100)` | Unique, not null |
| `role` | `user_role` | Not null |
| `phone_number` | `varchar(15)` | Nullable |

### `Matches`

Stores the matches that tickets are sold for.

| Column | Type | Constraints |
| --- | --- | --- |
| `match_id` | `INT` | Primary key |
| `fixture` | `varchar(250)` | Not null |
| `tournament_category` | `tournament_category_type` | Not null |
| `base_ticket_price` | `INT` | Not null, `>= 0` |
| `match_status` | `match_status_type` | Not null |

### `Bookings`

Links a user to a match they have booked a seat for.

| Column | Type | Constraints |
| --- | --- | --- |
| `booking_id` | `INT` | Primary key |
| `user_id` | `INT` | Not null, FK → `Users(user_id)` |
| `match_id` | `INT` | Not null, FK → `Matches(match_id)` |
| `seat_number` | `varchar(250)` | Nullable |
| `payment_status` | `payment_status_type` | Nullable |
| `total_cost` | `INT` | Not null, `>= 0` |

**Constraints**

- `fk_user` — foreign key on `user_id` referencing `Users(user_id)`.
- `fk_match` — foreign key on `match_id` referencing `Matches(match_id)`.
- `uq_booking` — composite unique constraint on
  `(user_id, match_id, seat_number)`, ensuring one seat per user per match.

## Entity Relationships

- A **User** can have many **Bookings** (one-to-many).
- A **Match** can have many **Bookings** (one-to-many).
- **Bookings** is the junction table linking `Users` and `Matches`.

```
Users (1) ───< Bookings >─── (1) Matches
```

## Sample Data

The script seeds the tables with sample rows: 4 users, 5 matches, and 5 bookings.
Some bookings intentionally have a `NULL` `payment_status` / `seat_number` to
demonstrate handling of missing values.

## Queries

The script includes seven example queries.

| # | Purpose | Key Concepts |
| --- | --- | --- |
| 1 | List `Available` Champions League matches | `WHERE` with multiple conditions |
| 2 | Find users whose name starts with `Tanvir` or contains `Haque` | `ILIKE`, `OR` |
| 3 | Show bookings with missing payment status, labelled `Action Required` | `COALESCE`, `CAST`, `IS NULL` |
| 4 | Booking details with user name and match fixture | `INNER JOIN` |
| 5 | All users with their booking IDs, including users with none | `FULL JOIN` |
| 6 | Bookings costing more than the average booking | Scalar subquery, `AVG` |
| 7 | Top 2 most expensive matches, skipping the single most expensive | `ORDER BY`, `OFFSET`, `LIMIT` |


## Files

- `QUERY.sql` — schema definitions, sample data, and example queries.
