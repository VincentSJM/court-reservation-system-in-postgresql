--
--
-- Insert member
INSERT INTO member 
VALUES (11331276,'Jiaming SU');

INSERT INTO member 
VALUES (11331177,'Qi Tang');

INSERT INTO member 
VALUES (11331079,'Tianqin Zhao');

INSERT INTO member 
VALUES (11331779,'Juno Yu');

INSERT INTO member 
VALUES (11331003,'Tim Yu');

--
--
-- Insert court
INSERT INTO court 
VALUES (1,'Central Court','River Campus');

INSERT INTO court 
VALUES (2,'East Court','River Campus');

INSERT INTO court 
VALUES (3,'West Court','River Campus');

INSERT INTO court 
VALUES (4,'South Court','River Campus');

INSERT INTO court 
VALUES (5,'North Court','River Campus');

--
--
-- Insert reservation
-- Normal Booked
INSERT INTO reservation 
VALUES (10010,11331276, now(),'booked',1,now()::date + integer '2', TIME '08:00');

-- Normal UPDATE
UPDATE reservation
SET type_of_action = 'dropped', time_stamp = (now()::date + integer '2' + TIME '08:11')
WHERE reservation_id = 10010;

-- Normal Booked
INSERT INTO reservation 
VALUES (10012,11331177, now(),'booked',1,now()::date + integer '5', TIME '08:00');

-- Normal Booked
INSERT INTO reservation 
VALUES (10014,11331177, now(),'booked',1,now()::date + integer '5', TIME '09:00');

-- Normal Booked
INSERT INTO reservation 
VALUES (10015,11331079, now(),'booked',2,now()::date + integer '5', TIME '10:00');

-- Normal Booked
INSERT INTO reservation 
VALUES (10016,11331779, now(),'booked',2,now()::date + integer '1', TIME '10:00');

-- Normal Booked
INSERT INTO reservation 
VALUES (10017,11331276, now(),'booked',1,now()::date + integer '3', TIME '10:00');

-- Normal UPDATE
UPDATE reservation
SET type_of_action = 'dropped', time_stamp = (now()::date + integer '3' + TIME '10:11')
WHERE reservation_id = 10017;

-- Normal Booked
INSERT INTO reservation 
VALUES (10018,11331276, now(),'booked',1,now()::date + integer '4', TIME '10:00');

-- Normal Booked
INSERT INTO reservation 
VALUES (10019,11331276, now(),'booked',1,now()::date + integer '5', TIME '10:00');

-- Normal Booked
INSERT INTO reservation 
VALUES (10020,11331003, now(),'booked',1,now()::date , TIME '20:00');

--
--
-- UPDATE reservation
-- Normal UPDATE.
UPDATE reservation
SET type_of_action = 'canceled', time_stamp = (now()::date + integer '5' + TIME '08:59')
WHERE reservation_id = 10014;

-- Normal UPDATE
UPDATE reservation
SET type_of_action = 'dropped', time_stamp = (now()::date + integer '5' + TIME '10:11')
WHERE reservation_id = 10015;
