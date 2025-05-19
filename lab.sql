
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

-- =====================================================
--                       Procedimientos
-- =====================================================

-- Procedure para validar que una habitación se encuentre disponible y realizar una reserva.
CREATE OR REPLACE PROCEDURE sp_insertar_reserva(
    p_guest_id INTEGER,
    p_room_id INTEGER,
    p_start_date DATE,
    p_end_date DATE,
    p_paid_amount NUMERIC(10,2),
    p_payment_method VARCHAR,
    p_receipt_number VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_reservation_id INTEGER;
BEGIN
    -- Validar disponibilidad
    IF EXISTS (
        SELECT 1 FROM reservation
        WHERE room_id = p_room_id
          AND status IN ('booked', 'checked_in')
          AND p_start_date < end_date
          AND p_end_date > start_date
    ) THEN
        RAISE EXCEPTION 'La habitación % no está disponible entre % y %',
            p_room_id, p_start_date, p_end_date;
    END IF;

    -- Insertar reserva
    INSERT INTO reservation (guest_id, room_id, start_date, end_date, status)
    VALUES (p_guest_id, p_room_id, p_start_date, p_end_date, 'booked')
    RETURNING reservation_id INTO v_reservation_id;

    -- Insertar pago
    INSERT INTO payment (reservation_id, paid_amount, paid_date, payment_method, receipt_number)
    VALUES (v_reservation_id, p_paid_amount, CURRENT_DATE, p_payment_method, p_receipt_number);

    -- Actualizar estado de habitación
    UPDATE room SET status = 'occupied'
    WHERE room_id = p_room_id;

    RAISE NOTICE 'Reserva % insertada correctamente', v_reservation_id;
END;
$$;


-- Procedure para validar que una habitación se encuentre disponible y cancelar una reserva mientras no se encuentre procesada la reserva.
CREATE OR REPLACE PROCEDURE sp_cancelar_reserva(p_reservation_id INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    v_start_date DATE;
    v_status TEXT;
BEGIN
    SELECT start_date, status INTO v_start_date, v_status
    FROM reservation
    WHERE reservation_id = p_reservation_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Reserva no encontrada con ID %', p_reservation_id;
    END IF;

    IF v_status = 'cancelled' THEN
        RAISE NOTICE 'La reserva ya está cancelada.';
        RETURN;
    END IF;

    IF v_start_date <= CURRENT_DATE THEN
        RAISE EXCEPTION 'No se puede cancelar una reserva que ya inició o finalizó.';
    END IF;

    UPDATE reservation
    SET status = 'cancelled'
    WHERE reservation_id = p_reservation_id;

    RAISE NOTICE 'Reserva % cancelada exitosamente', p_reservation_id;
END;
$$;


-- =====================================================
--                       Vistas
-- =====================================================


-- Vista Simple
CREATE OR REPLACE VIEW v_isponibles AS
SELECT room_id, room_number, floor, status
FROM room
WHERE status = 'available';


-- Vista con JOIN y GROUP BY
CREATE OR REPLACE VIEW v_total_pagos AS
SELECT 
    g.guest_id,
    g.first_name || ' ' || g.last_name AS nombre_completo,
    COUNT(p.payment_id) AS cantidad_pagos,
    SUM(p.paid_amount) AS total_pagado
FROM guest g
JOIN reservation r ON g.guest_id = r.guest_id
JOIN payment p ON r.reservation_id = p.reservation_id
GROUP BY g.guest_id, g.first_name, g.last_name;


-- Vista con CASE
CREATE OR REPLACE VIEW v_estado_reserva AS
SELECT
    reservation_id,
    guest_id,
    room_id,
    status,
    CASE status
        WHEN 'booked' THEN 'Reservada (pendiente de check-in)'
        WHEN 'checked_in' THEN 'En curso (cliente presente)'
        WHEN 'checked_out' THEN 'Finalizada (check-out completado)'
        WHEN 'cancelled' THEN 'Cancelada por el cliente o el hotel'
        ELSE 'Estado desconocido'
    END AS descripcion_estado
FROM reservation;



-- Vista con COALESCE
CREATE OR REPLACE VIEW v_habitacion_detalle AS
SELECT
    r.room_id,
    r.room_number,
    rt.name AS tipo,
    COALESCE(rt.description, 'Sin descripción disponible') AS descripcion,
    rt.capacity,
    rt.rate_per_night,
    r.status
FROM room r
JOIN room_type rt ON r.room_type_id = rt.room_type_id;