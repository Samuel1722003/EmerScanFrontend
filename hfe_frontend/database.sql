-- Primero definimos los ENUMs
CREATE TYPE genero_tipo AS ENUM ('Masculino', 'Femenino');
CREATE TYPE relacion_tipo AS ENUM ('Padre', 'Madre', 'Hermano', 'Pareja', 'Otro');
CREATE TYPE tipo_sangre_enum AS ENUM ('A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-');
CREATE TYPE estado_enfermedad_enum AS ENUM ('Tratamiento', 'Curada');

-- Tabla combinada Usuario_Persona
CREATE TABLE Usuario_Persona (
    id TEXT PRIMARY KEY,
    correo VARCHAR(60) NOT NULL UNIQUE,
    contrasena VARCHAR(255) NOT NULL,
    codigo_qr_base64 TEXT,
    nombre VARCHAR(30) NOT NULL,
    apellido_paterno VARCHAR(30) NOT NULL,
    apellido_materno VARCHAR(30) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    genero genero_tipo NOT NULL,
    telefono VARCHAR(15) NOT NULL
);

-- Tabla Contacto_emergencia
CREATE TABLE Contacto_emergencia (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    relacion relacion_tipo NOT NULL,
    usuario_persona_id TEXT NOT NULL REFERENCES Usuario_Persona(id)
);

-- Tabla Historial_clinico
CREATE TABLE Historial_clinico (
    id SERIAL PRIMARY KEY,
    peso NUMERIC(5,2) NOT NULL,
    estatura NUMERIC(3,2) NOT NULL,
    tipo_sangre tipo_sangre_enum NOT NULL,
    usuario_persona_id TEXT NOT NULL REFERENCES Usuario_Persona(id)
);

-- Tabla Antecedentes
CREATE TABLE Antecedentes (
    id SERIAL PRIMARY KEY,
    cirugias_anteriores TEXT,
    hospitalizaciones_anteriores TEXT,
    antecedentes_familiares TEXT,
    historial_id INT NOT NULL REFERENCES Historial_clinico(id)
);

-- Tabla Alergias
CREATE TABLE Alergias (
    id SERIAL PRIMARY KEY,
    nombre_alergia VARCHAR(50) NOT NULL,
    historial_id INT NOT NULL REFERENCES Historial_clinico(id)
);

-- Tabla Enfermedades
CREATE TABLE Enfermedades (
    id SERIAL PRIMARY KEY,
    nombre_enfermedad VARCHAR(50) NOT NULL,
    fecha_de_diagnostico DATE NOT NULL,
    estado estado_enfermedad_enum DEFAULT 'Tratamiento',
    historial_id INT NOT NULL REFERENCES Historial_clinico(id)
);

-- Tabla Tratamiento
CREATE TABLE Tratamiento (
    id SERIAL PRIMARY KEY,
    nombre_medicamento VARCHAR(50) NOT NULL,
    dosis VARCHAR(20) NOT NULL,
    frecuencia VARCHAR(20) NOT NULL,
    duracion INT NOT NULL,
    fecha_inicio DATE NOT NULL
);

-- Tabla Tratamiento_Enfermedad
CREATE TABLE Tratamiento_Enfermedad (
    id SERIAL PRIMARY KEY,
    tratamiento_id INT NOT NULL REFERENCES Tratamiento(id),
    enfermedad_id INT NOT NULL REFERENCES Enfermedades(id)
);

-- Tabla Bitacora_Acceso
CREATE TABLE Bitacora_Acceso (
    id SERIAL PRIMARY KEY,
    usuario_persona_id TEXT NOT NULL REFERENCES Usuario_Persona(id),
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Extensión y función para generar UUIDs personalizados
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE OR REPLACE FUNCTION generate_uuid()
RETURNS TRIGGER AS $$
BEGIN
  NEW.id := uuid_generate_v4()::text || '-' || to_char(NOW(), 'YYYYMMDDHH24MISS') || '-' || lpad(floor(random() * 1000000)::text, 6, '0');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_uuid_usuario_persona
BEFORE INSERT ON Usuario_Persona
FOR EACH ROW
EXECUTE FUNCTION generate_uuid();

-- Insert para Usuario_Persona 1
INSERT INTO Usuario_Persona (correo, contrasena, codigo_qr_base64, nombre, apellido_paterno, apellido_materno, fecha_nacimiento, genero, telefono)
VALUES (
    'juan.perez@email.com', 
    'hashed_password_123', 
    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUg...',
    'Juan',
    'Pérez',
    'González',
    '1990-05-15',
    'Masculino',
    '6671234567'
);

-- Contacto de emergencia
INSERT INTO Contacto_emergencia (nombre, telefono, relacion, usuario_persona_id)
VALUES (
    'Ana Pérez', 
    '6677654321', 
    'Madre', 
    (SELECT id FROM Usuario_Persona WHERE correo = 'juan.perez@email.com')
);

-- Historial clínico
INSERT INTO Historial_clinico (peso, estatura, tipo_sangre, usuario_persona_id)
VALUES (
    72.50, 
    1.75, 
    'O+', 
    (SELECT id FROM Usuario_Persona WHERE correo = 'juan.perez@email.com')
);

-- Antecedentes
INSERT INTO Antecedentes (cirugias_anteriores, hospitalizaciones_anteriores, antecedentes_familiares, historial_id)
VALUES (
    'Apendicectomía en 2015',
    'Hospitalizado por neumonía en 2018',
    'Padre con hipertensión',
    (SELECT id FROM Historial_clinico WHERE usuario_persona_id = (SELECT id FROM Usuario_Persona WHERE correo = 'juan.perez@email.com'))
);

-- Alergias
INSERT INTO Alergias (nombre_alergia, historial_id)
VALUES (
    'Penicilina',
    (SELECT id FROM Historial_clinico WHERE usuario_persona_id = (SELECT id FROM Usuario_Persona WHERE correo = 'juan.perez@email.com'))
);

-- Enfermedades
INSERT INTO Enfermedades (nombre_enfermedad, fecha_de_diagnostico, estado, historial_id)
VALUES (
    'Diabetes Tipo 2',
    '2021-04-10',
    'Tratamiento',
    (SELECT id FROM Historial_clinico WHERE usuario_persona_id = (SELECT id FROM Usuario_Persona WHERE correo = 'juan.perez@email.com'))
);

-- Tratamiento
INSERT INTO Tratamiento (nombre_medicamento, dosis, frecuencia, duracion, fecha_inicio)
VALUES (
    'Metformina',
    '500mg',
    '2 veces al día',
    180,
    '2024-01-01'
);

-- Relación Tratamiento-Enfermedad
INSERT INTO Tratamiento_Enfermedad (tratamiento_id, enfermedad_id)
VALUES (
    (SELECT id FROM Tratamiento WHERE nombre_medicamento = 'Metformina'),
    (SELECT id FROM Enfermedades WHERE nombre_enfermedad = 'Diabetes Tipo 2')
);

-- Bitácora de acceso
INSERT INTO Bitacora_Acceso (usuario_persona_id)
VALUES (
    (SELECT id FROM Usuario_Persona WHERE correo = 'juan.perez@email.com')
);

-- Insert para Usuario_Persona 2
INSERT INTO Usuario_Persona (correo, contrasena, codigo_qr_base64, nombre, apellido_paterno, apellido_materno, fecha_nacimiento, genero, telefono)
VALUES (
    'cristina.soliz@email.com', 
    'hashed_password_456', 
    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUg...',
    'Cristina',
    'Soliz',
    'Ramírez',
    '1985-11-22',
    'Femenino',
    '6679988776'
);

-- Contacto de emergencia (id = 2)
INSERT INTO Contacto_emergencia (nombre, telefono, relacion, usuario_persona_id)
VALUES (
    'Carlos Soliz', 
    '6671122334', 
    'Hermano', 
    (SELECT id FROM Usuario_Persona WHERE correo = 'cristina.soliz@email.com')
);

-- Historial clínico (id = 2)
INSERT INTO Historial_clinico (peso, estatura, tipo_sangre, usuario_persona_id)
VALUES (
    60.80, 
    1.63, 
    'A+', 
    (SELECT id FROM Usuario_Persona WHERE correo = 'cristina.soliz@email.com')
);

-- Antecedentes (id = 2)
INSERT INTO Antecedentes (cirugias_anteriores, hospitalizaciones_anteriores, antecedentes_familiares, historial_id)
VALUES (
    'Cesárea en 2010',
    'Ninguna',
    'Madre con diabetes',
    (SELECT id FROM Historial_clinico WHERE usuario_persona_id = (SELECT id FROM Usuario_Persona WHERE correo = 'cristina.soliz@email.com'))
);

-- Alergias (id = 2)
INSERT INTO Alergias (nombre_alergia, historial_id)
VALUES (
    'Ibuprofeno',
    (SELECT id FROM Historial_clinico WHERE usuario_persona_id = (SELECT id FROM Usuario_Persona WHERE correo = 'cristina.soliz@email.com'))
);

-- Enfermedades (id = 2)
INSERT INTO Enfermedades (nombre_enfermedad, fecha_de_diagnostico, estado, historial_id)
VALUES (
    'Hipotiroidismo',
    '2020-03-15',
    'Tratamiento',
    (SELECT id FROM Historial_clinico WHERE usuario_persona_id = (SELECT id FROM Usuario_Persona WHERE correo = 'cristina.soliz@email.com'))
);

-- Tratamiento (id = 2)
INSERT INTO Tratamiento (nombre_medicamento, dosis, frecuencia, duracion, fecha_inicio)
VALUES (
    'Levotiroxina',
    '100mcg',
    '1 vez al día',
    365,
    '2024-01-10'
);

-- Relación Tratamiento-Enfermedad (id = 2)
INSERT INTO Tratamiento_Enfermedad (tratamiento_id, enfermedad_id)
VALUES (
    (SELECT id FROM Tratamiento WHERE nombre_medicamento = 'Levotiroxina'),
    (SELECT id FROM Enfermedades WHERE nombre_enfermedad = 'Hipotiroidismo')
);

-- Bitácora de acceso (id = 2)
INSERT INTO Bitacora_Acceso (usuario_persona_id)
VALUES (
    (SELECT id FROM Usuario_Persona WHERE correo = 'cristina.soliz@email.com')
);