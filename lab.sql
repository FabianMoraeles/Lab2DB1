
-- =====================================================
--          Funciones definidas por el usuario
-- =====================================================

-- 1) Función escalar: calcula duración de la estadía en días
CREATE OR REPLACE FUNCTION fn_stay_duration(
    p_reservation_id INTEGER
) RETURNS INTEGER AS $$
DECLARE
    v_days INTEGER;
BEGIN
    SELECT (end_date - start_date)
      INTO v_days
    FROM reservation
    WHERE reservation_id = p_reservation_id;

    RETURN v_days;
END;
$$ LANGUAGE plpgsql;

-- 2) Función que retorna un conjunto: lista de habitaciones disponibles entre fechas
CREATE OR REPLACE FUNCTION fn_available_rooms(
    p_start DATE,
    p_end   DATE
) RETURNS TABLE(
    room_id     INTEGER,
    room_number VARCHAR,
    room_type   VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.room_id, r.room_number, rt.name
    FROM room r
    JOIN room_type rt ON r.room_type_id = rt.room_type_id
    WHERE r.status = 'available'
      AND NOT EXISTS (
        SELECT 1
        FROM reservation res
        WHERE res.room_id = r.room_id
          AND res.status IN ('booked','checked_in')
          AND res.start_date < p_end
          AND res.end_date > p_start
      );
END;
$$ LANGUAGE plpgsql;

-- 3) Función sencilla con múltiples parámetros y lógica condicional:
--    calcula cargo total aplicando descuento si la estadía es larga
CREATE OR REPLACE FUNCTION fn_total_charge(
    p_reservation_id INTEGER,
    p_discount_threshold INTEGER DEFAULT 3,
    p_discount_rate NUMERIC(5,2) DEFAULT 0.10
) RETURNS NUMERIC(10,2) AS $$
DECLARE
    v_days INTEGER;
    v_rate NUMERIC(8,2);
    v_total NUMERIC(10,2);
BEGIN
    -- Obtener duración y tarifa por noche
    SELECT (end_date - start_date), rt.rate_per_night
      INTO v_days, v_rate
    FROM reservation res
    JOIN room r ON res.room_id = r.room_id
    JOIN room_type rt ON r.room_type_id = rt.room_type_id
    WHERE res.reservation_id = p_reservation_id;

    v_total := v_days * v_rate;

    -- Aplicar descuento si la estadía supera el umbral
    IF v_days > p_discount_threshold THEN
        v_total := v_total * (1 - p_discount_rate);
    END IF;

    RETURN ROUND(v_total, 2);
END;
$$ LANGUAGE plpgsql;


-- =====================================================
--                       Triggers
-- =====================================================

-- Trigger BEFORE INSERT en reservation para validar disponibilidad
CREATE OR REPLACE FUNCTION trg_check_availability() RETURNS trigger AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM reservation res
        WHERE res.room_id = NEW.room_id
          AND res.status IN ('booked','checked_in')
          AND res.start_date < NEW.end_date
          AND res.end_date > NEW.start_date
    ) THEN
        RAISE EXCEPTION 'La habitación % no está disponible entre % y %',
            NEW.room_id, NEW.start_date, NEW.end_date;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS before_reservation_insert ON reservation;
CREATE TRIGGER before_reservation_insert
BEFORE INSERT ON reservation
FOR EACH ROW EXECUTE FUNCTION trg_check_availability();

-- Trigger AFTER INSERT en reservation para actualizar estado de habitación
CREATE OR REPLACE FUNCTION trg_mark_room_occupied() RETURNS trigger AS $$
BEGIN
    UPDATE room
    SET status = 'occupied'
    WHERE room_id = NEW.room_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS after_reservation_insert ON reservation;
CREATE TRIGGER after_reservation_insert
AFTER INSERT ON reservation
FOR EACH ROW EXECUTE FUNCTION trg_mark_room_occupied();

