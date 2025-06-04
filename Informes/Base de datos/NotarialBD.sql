-- Creación de la base de datos
CREATE DATABASE notarial_db CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci;

USE notarial_db;

-- Tabla NOTARIO
CREATE TABLE NOTARIO (
    id_notario INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    colegio_notarial VARCHAR(100) NOT NULL,
    datos_habilitacion TEXT,
    datos_sustitucion TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Tabla INSTRUMENTO_PUBLICO
CREATE TABLE INSTRUMENTO_PUBLICO (
    id_instrumento INT PRIMARY KEY AUTO_INCREMENT,
    numero_protocolo VARCHAR(20) NOT NULL UNIQUE,
    lugar_otorgamiento VARCHAR(255) NOT NULL,
    fecha_otorgamiento DATE NOT NULL,
    hora_otorgamiento TIME,
    id_notario INT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_notario) REFERENCES NOTARIO(id_notario) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Tabla ENCABEZAMIENTO
CREATE TABLE ENCABEZAMIENTO (
    id_encabezamiento INT PRIMARY KEY AUTO_INCREMENT,
    id_instrumento INT UNIQUE NOT NULL,
    detalles_adicionales TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_instrumento) REFERENCES INSTRUMENTO_PUBLICO(id_instrumento) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Tabla PERSONA_FISICA
CREATE TABLE PERSONA_FISICA (
    id_persona INT PRIMARY KEY AUTO_INCREMENT,
    dni_nie VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    apellido1 VARCHAR(100) NOT NULL,
    apellido2 VARCHAR(100),
    fecha_nacimiento DATE,
    estado_civil ENUM('soltero', 'casado', 'separado', 'viudo', 'divorciado'),
    profesion VARCHAR(100),
    nif VARCHAR(20) NOT NULL UNIQUE,
    nacionalidad VARCHAR(50),
    vecindad_civil VARCHAR(100),
    es_residente BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Tabla PERSONA_JURIDICA
CREATE TABLE PERSONA_JURIDICA (
    id_juridica INT PRIMARY KEY AUTO_INCREMENT,
    denominacion_social VARCHAR(255) NOT NULL UNIQUE,
    fecha_constitucion DATE NOT NULL,
    lugar_constitucion VARCHAR(255) NOT NULL,
    objeto_social TEXT NOT NULL,
    codigo_cnae VARCHAR(10),
    nif VARCHAR(20) NOT NULL UNIQUE,
    numero_registro VARCHAR(50) NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Tabla DOMICILIO
CREATE TABLE DOMICILIO (
    id_domicilio INT PRIMARY KEY AUTO_INCREMENT,
    id_persona INT,
    id_juridica INT,
    tipo ENUM('fisica', 'juridica') NOT NULL,
    pais VARCHAR(100) NOT NULL,
    provincia VARCHAR(100),
    municipio VARCHAR(100) NOT NULL,
    tipo_via ENUM('calle', 'avenida', 'paseo', 'plaza', 'otro') NOT NULL,
    nombre_via VARCHAR(200) NOT NULL,
    numero VARCHAR(20) NOT NULL,
    bloque VARCHAR(20),
    escalera VARCHAR(20),
    planta VARCHAR(20),
    puerta VARCHAR(20),
    email VARCHAR(100),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_persona) REFERENCES PERSONA_FISICA(id_persona) ON DELETE CASCADE,
    FOREIGN KEY (id_juridica) REFERENCES PERSONA_JURIDICA(id_juridica) ON DELETE CASCADE,
    CHECK ((id_persona IS NOT NULL AND id_juridica IS NULL AND tipo = 'fisica') OR 
          (id_persona IS NULL AND id_juridica IS NOT NULL AND tipo = 'juridica'))
) ENGINE=InnoDB;

-- Tabla REPRESENTACION
CREATE TABLE REPRESENTACION (
    id_representacion INT PRIMARY KEY AUTO_INCREMENT,
    tipo ENUM('voluntaria', 'organica', 'legal') NOT NULL,
    documento_apoyo VARCHAR(255) NOT NULL,
    veracidad BOOLEAN NOT NULL,
    vigencia BOOLEAN NOT NULL,
    suficiencia BOOLEAN NOT NULL,
    fecha_verificacion DATE NOT NULL,
    id_notario_verificador INT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_notario_verificador) REFERENCES NOTARIO(id_notario) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Tabla COMPARECENCIA
CREATE TABLE COMPARECENCIA (
    id_comparecencia INT PRIMARY KEY AUTO_INCREMENT,
    id_instrumento INT NOT NULL,
    id_persona INT NOT NULL,
    rol ENUM('otorgante', 'representante', 'testigo', 'traductor', 'tecnico') NOT NULL,
    detalles_rol TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_instrumento) REFERENCES INSTRUMENTO_PUBLICO(id_instrumento) ON DELETE CASCADE,
    FOREIGN KEY (id_persona) REFERENCES PERSONA_FISICA(id_persona) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Tabla INTERVENCION
CREATE TABLE INTERVENCION (
    id_intervencion INT PRIMARY KEY AUTO_INCREMENT,
    id_instrumento INT NOT NULL,
    id_representacion INT NOT NULL,
    id_representante INT NOT NULL,
    id_representado_fisico INT,
    id_representado_juridico INT,
    tipo_sujeto ENUM('fisica', 'juridica') NOT NULL,
    detalles TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_instrumento) REFERENCES INSTRUMENTO_PUBLICO(id_instrumento) ON DELETE CASCADE,
    FOREIGN KEY (id_representacion) REFERENCES REPRESENTACION(id_representacion) ON DELETE RESTRICT,
    FOREIGN KEY (id_representante) REFERENCES PERSONA_FISICA(id_persona) ON DELETE RESTRICT,
    FOREIGN KEY (id_representado_fisico) REFERENCES PERSONA_FISICA(id_persona) ON DELETE RESTRICT,
    FOREIGN KEY (id_representado_juridico) REFERENCES PERSONA_JURIDICA(id_juridica) ON DELETE RESTRICT,
    CHECK ((tipo_sujeto = 'fisica' AND id_representado_fisico IS NOT NULL AND id_representado_juridico IS NULL) OR
          (tipo_sujeto = 'juridica' AND id_representado_fisico IS NULL AND id_representado_juridico IS NOT NULL))
) ENGINE=InnoDB;

-- Tabla TITULAR_REAL
CREATE TABLE TITULAR_REAL (
    id_titular_real INT PRIMARY KEY AUTO_INCREMENT,
    id_juridica INT NOT NULL,
    id_persona INT NOT NULL,
    porcentaje_participacion DECIMAL(5,2),
    fecha_designacion DATE NOT NULL,
    detalles_control TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_juridica) REFERENCES PERSONA_JURIDICA(id_juridica) ON DELETE CASCADE,
    FOREIGN KEY (id_persona) REFERENCES PERSONA_FISICA(id_persona) ON DELETE RESTRICT,
    UNIQUE KEY (id_juridica, id_persona)
) ENGINE=InnoDB;

-- Tabla JUICIO_CAPACIDAD
CREATE TABLE JUICIO_CAPACIDAD (
    id_juicio INT PRIMARY KEY AUTO_INCREMENT,
    id_instrumento INT NOT NULL,
    id_persona INT NOT NULL,
    id_notario INT NOT NULL,
    capacidad_natural BOOLEAN NOT NULL,
    legitimacion BOOLEAN NOT NULL,
    observaciones TEXT,
    fecha_evaluacion DATE NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_instrumento) REFERENCES INSTRUMENTO_PUBLICO(id_instrumento) ON DELETE CASCADE,
    FOREIGN KEY (id_persona) REFERENCES PERSONA_FISICA(id_persona) ON DELETE RESTRICT,
    FOREIGN KEY (id_notario) REFERENCES NOTARIO(id_notario) ON DELETE RESTRICT
) ENGINE=InnoDB;
