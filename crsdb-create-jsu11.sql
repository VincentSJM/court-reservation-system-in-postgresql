-- CSC461 2016 Hwk 6
-- Jiaming Su
-- NetID: jsu11

--
-- Court Reservation System
--
DROP TABLE IF EXISTS member CASCADE;

CREATE TABLE member (
    member_id INTEGER PRIMARY KEY,
    member_name CHAR(40) NOT NULL
);


DROP TABLE IF EXISTS court CASCADE;

CREATE TABLE court (
    court_id SMALLINT PRIMARY KEY,
    court_name CHAR(40) NOT NULL,
    court_location CHAR(40) NOT NULL
);


DROP TABLE IF EXISTS reservation CASCADE;

CREATE TABLE reservation (
    reservation_id INTEGER PRIMARY KEY,
    
    member_id INTEGER NOT NULL,
    time_stamp TIMESTAMP NOT NULL,
    type_of_action CHAR(9) CHECK(type_of_action = 'booked' or
                                 type_of_action = 'confirmed' or
                                 type_of_action = 'canceled' or
                                 type_of_action = 'dropped'),
    court_id INTEGER NOT NULL,
    day DATE NOT NULL,
    time_of_day TIME CHECK(time_of_day = TIME '08:00' or
                           time_of_day = TIME '09:00' or
                           time_of_day = TIME '10:00' or
                           time_of_day = TIME '11:00' or
                           time_of_day = TIME '12:00' or
                           time_of_day = TIME '13:00' or
                           time_of_day = TIME '14:00' or
                           time_of_day = TIME '15:00' or
                           time_of_day = TIME '16:00' or
                           time_of_day = TIME '17:00' or
                           time_of_day = TIME '18:00' or
                           time_of_day = TIME '19:00' or
                           time_of_day = TIME '20:00' or
                           time_of_day = TIME '21:00'),
    
    FOREIGN KEY (member_id) REFERENCES member(member_id),
    FOREIGN KEY (court_id) REFERENCES court(court_id),
    
    CHECK(day >= time_stamp::date)
);

-- CREATE VIEW penalty AS
-- SELECT member_id, COUNT(*) AS penalty_point, (7 - COUNT(*)) AS lead_time
-- FROM reservation
-- WHERE type_of_action = 'dropped' AND 
--       now() - time_stamp < interval '42 days'
-- GROUP BY member_id;

CREATE OR REPLACE VIEW penalty AS
SELECT member_id, 
       CASE WHEN pp IS NULL THEN 0 ELSE pp END AS penalty_point,
       CASE WHEN lt IS NULL THEN 7 ELSE lt END AS lead_time
FROM
    (SELECT member_id FROM member) AS all_member
    LEFT JOIN
    (SELECT member_id, COUNT(*) AS pp, (7 - COUNT(*)) AS lt
    FROM reservation
    WHERE type_of_action = 'dropped' AND 
        now() - time_stamp < interval '42 days'
    GROUP BY member_id) AS has_dropped USING(member_id);


CREATE OR REPLACE FUNCTION init_reservation() RETURNS TRIGGER as $init_reservation$
    BEGIN
        -- type_of_action in a reservation tupple should initially be 'booked'
        IF NEW.type_of_action <> 'booked' THEN
            RAISE EXCEPTION 'type_of_action in a reservation tupple should initially be booked.';
        END IF;
        
        IF (SELECT COUNT(*) 
            FROM reservation 
            WHERE member_id = NEW.member_id AND 
                  type_of_action = 'booked') > 7 THEN
            RAISE EXCEPTION 'Make too many reservation for one member!';
        END IF;
        
        IF (SELECT COUNT(*) 
            FROM reservation 
            WHERE court_id = NEW.court_id AND
                  day = NEW.day AND
                  time_of_day = NEW.time_of_day AND
                  (type_of_action = 'booked'OR type_of_action = 'confirmed')) <> 0 THEN
            RAISE EXCEPTION 'The Time Slot of that court is Not Available!';
        END IF;
        
        IF (SELECT lead_time
            FROM penalty
            WHERE member_id = NEW.member_id) <= 0 THEN
            RAISE EXCEPTION 'You have no lead time, You can not make a reservation!';
        END IF;
        
        -- People without any dropped and penalty, Check they make the reservation within 7 days.
        IF NEW.time_stamp::date + integer '7' < NEw.day THEN
            RAISE EXCEPTION 'Making a reservation exceeds maximum lead time';
        END IF;
        
        IF NEW.time_stamp::date + 
           (SELECT lead_time FROM penalty WHERE member_id = NEW.member_id)::integer < NEW.day THEN
            RAISE EXCEPTION 'Please make a reservation within your lead time!';        
        END IF;
        
        RETURN NEW;
    END;
$init_reservation$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS init_reservation ON reservation;

CREATE TRIGGER init_reservation BEFORE INSERT ON reservation
    FOR EACH ROW EXECUTE PROCEDURE init_reservation();
    

CREATE OR REPLACE FUNCTION update_reservation() RETURNS TRIGGER as $update_reservation$
    BEGIN
        IF NEW.type_of_action = 'confirmed' AND
           OLD.type_of_action = 'booked' AND
           NEW.time_stamp >= OLD.day + OLD.time_of_day - interval '20 minutes' AND
           NEW.time_stamp <= OLD.day + OLD.time_of_day + interval '10 minutes' THEN
            RETURN NEW;
        ELSEIF NEW.type_of_action = 'canceled' AND
               OLD.type_of_action = 'booked' AND
               NEW.time_stamp < OLD.day + OLD.time_of_day THEN
            RETURN NEW;
        ELSEIF NEW.type_of_action = 'dropped' AND
               OLD.type_of_action = 'booked' AND
               NEW.time_stamp > OLD.day + OLD.time_of_day + interval '10 minutes' THEN
            RETURN NEW;
        END IF;

        RAISE EXCEPTION 'Illegal Update on reservation';
    END;
$update_reservation$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_reservation ON reservation;

CREATE TRIGGER update_reservation BEFORE UPDATE OF type_of_action, time_stamp ON reservation
    FOR EACH ROW EXECUTE PROCEDURE update_reservation();