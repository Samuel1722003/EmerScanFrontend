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

-- Tabla de tokens para acceso a información médica de emergencia
CREATE TABLE IF NOT EXISTS medical_tokens (
  id SERIAL PRIMARY KEY,
  user_id TEXT REFERENCES usuario_persona(id),
  token TEXT UNIQUE NOT NULL,
  expira_en TIMESTAMP WITH TIME ZONE NOT NULL,
  creado_en TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  es_activo BOOLEAN DEFAULT TRUE
);

CREATE POLICY "Usuarios autenticados pueden upsert" 
ON medical_tokens
FOR INSERT, UPDATE
USING (auth.uid() = user_id);

ALTER TABLE medical_tokens
ADD CONSTRAINT unique_user_id UNIQUE (user_id);

-- Índice para búsquedas rápidas por token
CREATE INDEX IF NOT EXISTS idx_medical_tokens_token ON medical_tokens(token);

-- Índice para búsquedas por usuario
CREATE INDEX IF NOT EXISTS idx_medical_tokens_user_id ON medical_tokens(user_id);

-- Tabla para contactos de emergencia (si no existe)
CREATE TABLE IF NOT EXISTS contactos_emergencia (
  id SERIAL PRIMARY KEY,
  usuario_id UUID REFERENCES usuario_persona(id),
  nombre TEXT NOT NULL,
  telefono TEXT NOT NULL,
  relacion TEXT,
  es_primario BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Política RLS para permitir acceso público a la información médica con token
ALTER TABLE medical_tokens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Permitir acceso público a tokens" ON medical_tokens
  FOR SELECT 
  USING (true);

-- Política para permitir que el usuario cree/actualice sus propios tokens
CREATE POLICY "Usuarios pueden crear sus propios tokens" ON medical_tokens
  FOR INSERT
  WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Usuarios pueden actualizar sus propios tokens" ON medical_tokens
  FOR UPDATE
  USING (auth.uid()::text = user_id::text);