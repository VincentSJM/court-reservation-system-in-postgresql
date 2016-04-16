-- a
-- List all of today's reservations (members, times, courts and confirmation status). 
-- This might be what the receptionist prints and posts every morning.
SELECT member_id, member_name, time_of_day, court_id, court_name, court_location, type_of_action
FROM member NATURAL JOIN 
     reservation NATURAL JOIN 
     court
WHERE reservation.day = now()::date AND
      (reservation.type_of_action = 'booked' OR reservation.type_of_action = 'confirmed') 
ORDER BY court_id, time_of_day;

-- b
-- Show all of member m's reservations (minimally 3; show times, courts and confirmation status) for the next 7 days. 
-- Include p: the current number of penalty points incurred by m (must be > 1 for member m).
SELECT member_id, 
       member_name, 
       day, 
       time_of_day, 
       court_id, 
       court_name, 
       type_of_action,
       penalty_point
FROM member NATURAL JOIN 
     reservation NATURAL JOIN 
     court NATURAL JOIN
     penalty
WHERE member_id = 11331276 AND
      day <= now()::date + integer '7';

-- c
-- Add a reservation for member m for some court at some time t for n days from today, where n + p > 7. 
-- Repeat with a different n such that n + p <= 7.

INSERT INTO reservation 
VALUES (11019,11331276, now(),'booked',1,now()::date + integer '6', TIME '10:00');

INSERT INTO reservation 
VALUES (11020,11331276, now(),'booked',1,now()::date + integer '5', TIME '11:00');


-- d
-- Confirm member m's next reservation.
CREATE OR REPLACE VIEW m_s_next_reservation AS
SELECT reservation_id, day, time_of_day
FROM reservation
WHERE member_id = 11331276 AND
      type_of_action = 'booked'
ORDER BY day, time_of_day ASC
LIMIT 1; 

UPDATE reservation
SET type_of_action = 'confirmed', 
    time_stamp = ((SELECT day FROM m_s_next_reservation) + 
                 (SELECT time_of_day FROM m_s_next_reservation))
WHERE reservation_id = (SELECT reservation_id FROM m_s_next_reservation);

-- e
-- Cancel one of member m's upcoming reservations.

UPDATE reservation
SET type_of_action = 'canceled', 
    time_stamp = ((SELECT day FROM m_s_next_reservation) + 
                 (SELECT time_of_day FROM m_s_next_reservation) -
                 interval '1 minutes')
WHERE reservation_id = (SELECT reservation_id FROM m_s_next_reservation);

-- f
-- Show all of m's reservations again, as before.
SELECT member_id, 
       member_name, 
       day, 
       time_of_day, 
       court_id, 
       court_name, 
       type_of_action,
       penalty_point
FROM member NATURAL JOIN 
     reservation NATURAL JOIN 
     court NATURAL JOIN
     penalty
WHERE member_id = 11331276 AND
      day <=  now()::date + integer '7';


DROP VIEW m_s_next_reservation;

-- g
-- Add any additional queries and commands you deem appropriate to show off the effectiveness of your constraints.
-- Trigger initially insertion should be 'booked'
INSERT INTO reservation 
VALUES (10009,11331276, now(),'confirmed',1,now()::date + integer '5', TIME '08:00');

-- Trigger Reservations can only be made on the working hour 8AM to 9PM.
INSERT INTO reservation 
VALUES (12012,11331177, now(),'booked',1,now()::date + integer '5', TIME '08:02');


-- Trigger No 2 reservation should be on the same court same day same time.
INSERT INTO reservation 
 VALUES (11012,11331177, now(),'booked',1,now()::date + integer '5', TIME '08:00');

-- Trigger Reservation exceed the lead time.
INSERT INTO reservation 
VALUES (10013,11331177, now(),'booked',1,now()::date + integer '8', TIME '08:00');

-- Trigger confrim not within the time near the reservation.
UPDATE reservation
SET type_of_action = 'confirmed', time_stamp = now()
WHERE reservation_id = 10012;

-- Trigger cancel reservation not before the time of the reservation.
UPDATE reservation
SET type_of_action = 'canceled', time_stamp = (now()::date + integer '5' + TIME '08:01')
WHERE reservation_id = 10012;

-- Trigger Drop not after the time.
UPDATE reservation
SET type_of_action = 'dropped', time_stamp = (now()::date + integer '4' + TIME '08:59')
WHERE reservation_id = 10012;


-- Trigger not enough lead day.
INSERT INTO reservation 
VALUES (10016,11331079, now(),'booked',2,now()::date + integer '7', TIME '10:00');
