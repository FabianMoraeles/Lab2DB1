-- -----------------------------------------------------
-- Tabla: guest
-- Clientes que realizan reservas
-- -----------------------------------------------------
CREATE TABLE
    guest (
        guest_id SERIAL PRIMARY KEY,
        first_name VARCHAR(50) NOT NULL,
        last_name VARCHAR(50) NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        phone VARCHAR(20),
        created_at TIMESTAMP NOT NULL DEFAULT NOW (),
        CHECK (char_length(first_name) > 0),
        CHECK (char_length(last_name) > 0)
    );

-- -----------------------------------------------------
-- Tabla: room_type
-- Tipos o categorías de habitación
-- -----------------------------------------------------
CREATE TABLE
    room_type (
        room_type_id SERIAL PRIMARY KEY,
        name VARCHAR(50) NOT NULL UNIQUE,
        description TEXT,
        capacity INTEGER NOT NULL,
        rate_per_night NUMERIC(8, 2) NOT NULL CHECK (rate_per_night >= 0),
        CHECK (capacity > 0)
    );

-- -----------------------------------------------------
-- Tabla: room
-- Habitaciones específicas
-- -----------------------------------------------------
CREATE TABLE
    room (
        room_id SERIAL PRIMARY KEY,
        room_number VARCHAR(10) NOT NULL,
        room_type_id INTEGER NOT NULL REFERENCES room_type (room_type_id),
        floor INTEGER NOT NULL CHECK (floor >= 0),
        status VARCHAR(20) NOT NULL DEFAULT 'available',
        UNIQUE ( room_number),
        CHECK (
            status IN (
                'available',
                'occupied',
                'maintenance',
                'out_of_service'
            )
        )
    );

-- -----------------------------------------------------
-- Tabla: amenity
-- Servicios y comodidades disponibles
-- -----------------------------------------------------
CREATE TABLE
    amenity (
        amenity_id SERIAL PRIMARY KEY,
        name VARCHAR(50) NOT NULL UNIQUE,
        description TEXT,
        charge NUMERIC(7, 2) NOT NULL DEFAULT 0 CHECK (charge >= 0)
    );

-- -----------------------------------------------------
-- Tabla: room_amenity
-- Relación N:M entre habitaciones y amenities
-- -----------------------------------------------------
CREATE TABLE
    room_amenity (
        room_id INTEGER NOT NULL REFERENCES room (room_id) ON DELETE CASCADE,
        amenity_id INTEGER NOT NULL REFERENCES amenity (amenity_id) ON DELETE CASCADE,
        PRIMARY KEY (room_id, amenity_id)
    );

-- -----------------------------------------------------
-- Tabla: reservation
-- Reservas realizadas por los clientes
-- -----------------------------------------------------
CREATE TABLE
    reservation (
        reservation_id SERIAL PRIMARY KEY,
        guest_id INTEGER NOT NULL REFERENCES guest (guest_id),
        room_id INTEGER NOT NULL REFERENCES room (room_id),
        start_date DATE NOT NULL,
        end_date DATE NOT NULL,
        status VARCHAR(20) NOT NULL DEFAULT 'booked',
        created_at TIMESTAMP NOT NULL DEFAULT NOW (),
        CHECK (end_date > start_date),
        CHECK (
            status IN (
                'booked',
                'checked_in',
                'checked_out',
                'cancelled'
            )
        )
    );

-- -----------------------------------------------------
-- Tabla: payment
-- Pagos asociados a reservas
-- -----------------------------------------------------
CREATE TABLE
    payment (
        payment_id SERIAL PRIMARY KEY,
        reservation_id INTEGER NOT NULL REFERENCES reservation (reservation_id),
        paid_amount NUMERIC(10, 2) NOT NULL CHECK (paid_amount >= 0),
        paid_date TIMESTAMP NOT NULL DEFAULT NOW (),
        payment_method VARCHAR(20) NOT NULL,
        receipt_number VARCHAR(50) UNIQUE NOT NULL
    );


CREATE INDEX idx_reservation_guest ON reservation (guest_id);

CREATE INDEX idx_reservation_room ON reservation (room_id);

CREATE INDEX idx_payment_reservation ON payment (reservation_id);