-- =========================================
-- Clientes (guest)
-- =========================================
INSERT INTO guest (first_name, last_name, email, phone) VALUES
('Judith', 'Peres', 'nayeli76@club.net', '502-4123-0021'),
('Clara', 'Lerma', 'henriquezoscar@corporacin.com', '502-4123-0022'),
('Mariana', 'Valencia', 'manuel59@industrias.net', '502-4123-0023'),
('Juan', 'Jiménez', 'carlayanez@grupo.com', '502-4123-0024'),
('Esteban', 'Ramos', 'alejandro93@correo.org', '502-4123-0025'),
('Raúl', 'Suárez', 'juliocamacho@hotmail.com', '502-4123-0026'),
('Claudia', 'Mora', 'claudia76@ejemplo.com', '502-4123-0027'),
('Renata', 'Zúñiga', 'renata.zuniga@empresa.com', '502-4123-0028'),
('Iván', 'Silva', 'ivan1985@webmail.com', '502-4123-0029'),
('Patricia', 'Pineda', 'pineda.pat@correo.com', '502-4123-0030'),
('Felipe', 'Aguilar', 'felipea@info.net', '502-4123-0031'),
('Ximena', 'Sánchez', 'ximena23@correo.org', '502-4123-0032'),
('Emilia', 'Delgado', 'emiliadg@hotmail.com', '502-4123-0033'),
('Óscar', 'Rosales', 'oscarros@grupo.com', '502-4123-0034'),
('Bárbara', 'Mejía', 'bmejia@ejemplo.com', '502-4123-0035'),
('Álvaro', 'Pérez', 'alvaro89@industrias.com', '502-4123-0036'),
('Liliana', 'López', 'lilopez@mail.org', '502-4123-0037'),
('César', 'Guerrero', 'cesarguerrero@web.com', '502-4123-0038'),
('Marcela', 'Herrera', 'marcelah@correo.com', '502-4123-0039'),
('Natalia', 'Chacón', 'nchacon@ejemplo.com', '502-4123-0040'),
('Andrés', 'Vega', 'andresv@hotmail.com', '502-4123-0041'),
('Lorena', 'Montoya', 'lorenam@grupo.com', '502-4123-0042'),
('Hugo', 'Salinas', 'hugosalinas@empresa.com', '502-4123-0043'),
('Mónica', 'Ortega', 'monicao@correo.org', '502-4123-0044'),
('Javier', 'Campos', 'jcampos@mail.net', '502-4123-0045'),
('Daniela', 'Barrera', 'danibarrera@correo.com', '502-4123-0046'),
('Tania', 'Paz', 'tpaz@info.com', '502-4123-0047'),
('Arturo', 'Acosta', 'arturoa@grupo.net', '502-4123-0048'),
('Gloria', 'Cisneros', 'gloriac@empresa.com', '502-4123-0049'),
('Cristina', 'Medina', 'cristina@correo.org', '502-4123-0050');
-- =========================================
-- Tipos de habitación (room_type)
-- =========================================
INSERT INTO room_type (name, description, capacity, rate_per_night) VALUES
('Sencilla', 'Habitación individual con una cama y baño privado.', 1, 80.00),
('Doble', 'Habitación con dos camas individuales o una matrimonial.', 2, 120.00),
('Suite', 'Espaciosa habitación con sala de estar y servicios premium.', 3, 200.00),
('Familiar', 'Habitación grande para familias con múltiples camas.', 4, 180.00),
('Ejecutiva', 'Habitación de lujo para viajeros de negocios.', 2, 220.00);

-- =========================================
-- Habitaciones (room)
-- =========================================
INSERT INTO room (room_number, room_type_id, floor, status) VALUES
('101', 1, 1, 'available'),
('102', 2, 1, 'occupied'),
('103', 3, 1, 'maintenance'),
('104', 4, 1, 'available'),
('105', 5, 1, 'out_of_service'),
('201', 1, 2, 'available'),
('202', 2, 2, 'occupied'),
('203', 3, 2, 'available'),
('204', 4, 2, 'maintenance'),
('205', 5, 2, 'available'),
('301', 1, 3, 'available'),
('302', 2, 3, 'occupied'),
('303', 3, 3, 'available'),
('304', 4, 3, 'maintenance'),
('305', 5, 3, 'available'),
('401', 1, 4, 'available'),
('402', 2, 4, 'occupied'),
('403', 3, 4, 'maintenance'),
('404', 4, 4, 'available'),
('405', 5, 4, 'available');

-- =========================================
-- Servicios (amenity)
-- =========================================
INSERT INTO amenity (name, description, charge) VALUES
('WiFi', 'Internet inalámbrico de alta velocidad.', 0.00),
('Desayuno', 'Desayuno continental incluido.', 10.00),
('Estacionamiento', 'Estacionamiento privado.', 5.00),
('Piscina', 'Acceso a piscina climatizada.', 15.00),
('Spa', 'Acceso a área de spa y masajes.', 25.00);

-- =========================================
-- Asociación habitaciones-servicios (room_amenity)
-- =========================================
INSERT INTO room_amenity (room_id, amenity_id) VALUES
(1, 1), (1, 2),
(2, 1), (2, 2), (2, 3),
(3, 1),
(4, 1), (4, 4),
(5, 1), (5, 2),
(6, 1), (6, 5),
(7, 1),
(8, 1), (8, 2), (8, 4),
(9, 1),
(10, 1), (10, 3),
(11, 1), (11, 2),
(12, 1), (12, 3),
(13, 1), (13, 4),
(14, 1), (14, 2),
(15, 1), (15, 5),
(16, 1), (16, 2), (16, 3),
(17, 1),
(18, 1), (18, 4),
(19, 1), (19, 2),
(20, 1), (20, 3);

-- =========================================
-- Reservas (reservation)
-- =========================================
INSERT INTO reservation (guest_id, room_id, start_date, end_date, status) VALUES
(1, 1, '2025-06-01', '2025-06-03', 'booked'),
(2, 2, '2025-06-02', '2025-06-04', 'checked_in'),
(3, 3, '2025-06-03', '2025-06-05', 'booked'),
(4, 4, '2025-06-04', '2025-06-07', 'cancelled'),
(5, 5, '2025-06-05', '2025-06-06', 'checked_out'),
(6, 6, '2025-06-06', '2025-06-08', 'booked'),
(7, 7, '2025-06-07', '2025-06-10', 'checked_in'),
(8, 8, '2025-06-08', '2025-06-09', 'booked'),
(9, 9, '2025-06-09', '2025-06-12', 'cancelled'),
(10, 10, '2025-06-10', '2025-06-13', 'booked'),
(11, 11, '2025-06-11', '2025-06-14', 'checked_out'),
(12, 12, '2025-06-12', '2025-06-16', 'checked_in'),
(13, 13, '2025-06-13', '2025-06-14', 'booked'),
(14, 14, '2025-06-14', '2025-06-15', 'cancelled'),
(15, 15, '2025-06-15', '2025-06-17', 'booked'),
(16, 16, '2025-06-16', '2025-06-19', 'checked_in'),
(17, 17, '2025-06-17', '2025-06-20', 'booked'),
(18, 18, '2025-06-18', '2025-06-21', 'booked'),
(19, 19, '2025-06-19', '2025-06-22', 'cancelled'),
(20, 20, '2025-06-20', '2025-06-24', 'booked');

-- =========================================
-- Pagos (payment)
-- =========================================
INSERT INTO payment (reservation_id, paid_amount, paid_date, payment_method, receipt_number) VALUES
(1, 160.00, '2025-05-31', 'tarjeta', 'REC-0001'),
(2, 240.00, '2025-06-01', 'efectivo', 'REC-0002'),
(3, 200.00, '2025-06-02', 'transferencia', 'REC-0003'),
(4, 0.00, '2025-01-05' ,'efectivo', 'REC-0004'),
(5, 180.00, '2025-06-05', 'tarjeta', 'REC-0005'),
(6, 160.00, '2025-06-06', 'efectivo', 'REC-0006'),
(7, 210.00, '2025-06-07', 'tarjeta', 'REC-0007'),
(8, 120.00, '2025-06-08', 'transferencia', 'REC-0008'),
(9, 0.00,'2025-02-05', 'efectivo', 'REC-0009'),
(10, 200.00, '2025-06-10', 'efectivo', 'REC-0010'),
(11, 220.00, '2025-06-11', 'tarjeta', 'REC-0011'),
(12, 240.00, '2025-06-12', 'efectivo', 'REC-0012'),
(13, 100.00, '2025-06-13', 'tarjeta', 'REC-0013'),
(14, 0.00, '2025-03-05', 'transferencia', 'REC-0014'),
(15, 150.00, '2025-06-15', 'efectivo', 'REC-0015'),
(16, 260.00, '2025-06-16', 'tarjeta', 'REC-0016'),
(17, 160.00, '2025-06-17', 'efectivo', 'REC-0017'),
(18, 190.00, '2025-06-18', 'transferencia', 'REC-0018'),
(19, 0.00, '2025-0-05', 'efectivo', 'REC-0019'),
(20, 220.00, '2025-06-20', 'tarjeta', 'REC-0020');