-- 1. CREATE USERS TABLE
  
  CREATE TYPE user_role AS enum(
  'Ticket Manager', 
  'Football Fan'
  );


CREATE TABLE Users (
  user_id INT PRIMARY KEY,
  full_name varchar(100) NOT NULL,
  email varchar(100) UNIQUE NOT NULL,
  role user_role NOT NULL,
  phone_number varchar(15)
);

-- 2. CREATE MATCHES TABLE

CREATE TYPE tournament_category_type AS enum(
  'Champions League', 
  'Premier League', 
  'Serie A'
  );


CREATE TYPE match_status_type AS enum(
  'Available',
  'Selling Fast',
  'Sold Out',
  'Postponed'
);


CREATE TABLE Matches (
  match_id INT PRIMARY KEY,
  fixture varchar(250) NOT NULL,
  tournament_category tournament_category_type NOT NULL,
  base_ticket_price INT NOT NULL CHECK (base_ticket_price >= 0),
  match_status match_status_type NOT NULL
);

-- 3. CREATE BOOKINGS TABLE

CREATE TYPE payment_status_type AS enum(
  'Pending',
  'Confirmed',
  'Cancelled',
  'Refunded'
);

CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    match_id INT NOT NULL,
    seat_number varchar(250),
    payment_status payment_status_type,
    total_cost INT NOT NULL CHECK (total_cost >= 0),
  
    -- Foreign Key linking user_id to Users table
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES Users(user_id),

    -- Foreign Key linking match_id to Matches table
    CONSTRAINT fk_match FOREIGN KEY (match_id) REFERENCES Matches(match_id),

    -- Composite Unique constraint (1-to-1 logical: one seat per user per match)
    CONSTRAINT uq_booking UNIQUE (user_id, match_id, seat_number)
);

-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO USERS
-- =========================================================================

INSERT INTO Users (user_id, full_name, email, role, phone_number) VALUES
(1, 'Tanvir Rahman', 'tanvir@mail.com', 'Football Fan', '+8801711111111'),
(2, 'Asif Haque', 'asif@mail.com', 'Football Fan', '+8801722222222'),
(3, 'Sajjad Rahman', 'sajjad@mail.com', 'Ticket Manager', '+8801733333333'),
(4, 'Jannat Ara', 'jannat@mail.com', 'Football Fan', NULL);

-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO MATCHES
-- =========================================================================

INSERT INTO Matches (match_id, fixture, tournament_category, base_ticket_price, match_status) VALUES
(101, 'Real Madrid vs Barcelona', 'Champions League', 150.00, 'Available'),
(102, 'Man City vs Liverpool', 'Premier League', 120.00, 'Selling Fast'),
(103, 'Bayern Munich vs PSG', 'Champions League', 130.00, 'Available'),
(104, 'AC Milan vs Inter Milan', 'Serie A', 90.00, 'Sold Out'),
(105, 'Juventus vs Roma', 'Serie A', 80.00, 'Available');

-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO BOOKINGS
-- =========================================================================

INSERT INTO Bookings (booking_id, user_id, match_id, seat_number, payment_status, total_cost) VALUES
(501, 1, 101, 'A-12', 'Confirmed', 150.00),
(502, 1, 102, 'B-04', 'Confirmed', 120.00),
(503, 2, 101, 'A-13', 'Confirmed', 150.00),
(504, 2, 101, NULL, NULL, 150.00),
(505, 3, 102, 'C-20', 'Pending', 120.00);

-- ==========================================================================================================================
-- Query 1: Retrieve all upcoming football matches belonging to the 'Champions League' where the match status is 'Available'.
-- ==========================================================================================================================

SELECT
  match_id,
  fixture,
  base_ticket_price
FROM
  Matches
WHERE
  tournament_category = 'Champions League'
  AND match_status = 'Available'

  -- ==========================================================================================================================
  -- Query 2: Search for all users whose full names start with 'Tanvir' or contain the phrase 'Haque' (case-insensitive).
  -- ==========================================================================================================================
SELECT
  user_id,
  full_name,
  email
FROM
  Users
WHERE
  full_name ILIKE 'Tanvir%'
  OR full_name ILIKE '%Haque%'

   -- ====================================================================================================================================
  -- Query 3: Retrieve all booking records where the payment status is missing (NULL), replacing the empty result with 'Action Required'.
  -- ====================================================================================================================================
SELECT
  booking_id,
  user_id,
  match_id,
  COALESCE(
    CAST(payment_status AS varchar),
    'Action Required'
  ) AS systematic_status
FROM
  Bookings
WHERE
  payment_status IS NULL;

  -- ===============================================================================================================
-- Query 4: Retrieve match booking details along with the User's full name and the scheduled Match fixture teams.
-- ===============================================================================================================
SELECT
  Bookings.booking_id,
  Users.full_name,
  Matches.fixture,
  Bookings.total_cost
FROM
  Bookings
  INNER JOIN Users ON Bookings.user_id = Users.user_id
  INNER JOIN Matches ON Bookings.match_id = Matches.match_id

-- =============================================================================================================================================
  -- Query 5: Display a comprehensive list of all users and their booking IDs, ensuring that fans who have never bought a ticket are still listed.
  -- =============================================================================================================================================
SELECT
  Users.user_id,
  Users.full_name,
  Bookings.booking_id
FROM
  Users
  FULL JOIN Bookings ON Users.user_id = Bookings.user_id

  -- ========================================================================================================================
  -- Query 6: Find all ticket bookings where the total cost is strictly higher than the average cost of all ticket bookings.
  -- ========================================================================================================================
SELECT
  booking_id,
  match_id,
  total_cost
FROM
  Bookings
WHERE
  total_cost > (
    SELECT
      AVG(total_cost)
    FROM
      Bookings
  )