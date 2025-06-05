/*Creación de base de datos*/
DROP DATABASE IF EXISTS notarial_db;
CREATE DATABASE IF NOT EXISTS notarial_db
DEFAULT CHARACTER SET utf8mb4
COLLATE utf8mb4_general_ci;

USE notarial_db;

/*Tabla: ESTADO_CIVIL*/
CREATE TABLE ESTADO_CIVIL (
    id TINYINT PRIMARY KEY,
    descripcion VARCHAR(20) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Tabla: REGIMEN_MATRIMONIAL*/
CREATE TABLE REGIMEN_MATRIMONIAL (
    id TINYINT PRIMARY KEY,
    nombre ENUM('SOCIEDAD_GANANCIALES', 'SEPARACION_BIENES') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Tabla: PERSONA_FISICA*/
CREATE TABLE PERSONA_FISICA (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    nie VARCHAR(20) UNIQUE,
    dni VARCHAR(20) UNIQUE, 
    nombre VARCHAR(50) NOT NULL,
    primer_apellido VARCHAR(50) NOT NULL,
    segundo_apellido VARCHAR(50),
    genero VARCHAR(20),
    fecha_nacimiento DATE NOT NULL,
    profesion VARCHAR(100),
    profesion_riesgo BOOLEAN DEFAULT FALSE,
    estado_civil_id TINYINT NOT NULL,
    CONSTRAINT fk_estado_civil FOREIGN KEY (estado_civil_id)
        REFERENCES ESTADO_CIVIL(id)
        ON DELETE RESTRICT
    -- NOTA: Eliminado CHECK con CURDATE() (MySQL no lo permite en versiones anteriores a 8.0.16)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Tabla: DIRECCION*/
CREATE TABLE DIRECCION (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    persona_id BIGINT NOT NULL,
    tipo_via VARCHAR(20) NOT NULL,
    nombre_via VARCHAR(100) NOT NULL,
    numero VARCHAR(10) NOT NULL,
    escalera VARCHAR(10),
    piso VARCHAR(10),
    puerta VARCHAR(10),
    municipio VARCHAR(50) NOT NULL,
    provincia VARCHAR(50) NOT NULL,
    codigo_postal CHAR(5) NOT NULL,
    pais VARCHAR(50),
    CONSTRAINT fk_direccion_persona FOREIGN KEY (persona_id)
        REFERENCES PERSONA_FISICA(id)
        ON DELETE CASCADE,
    CONSTRAINT chk_codigo_postal CHECK (CHAR_LENGTH(codigo_postal) = 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Tabla: DOCUMENTO_IDENTIDAD*/
CREATE TABLE DOCUMENTO_IDENTIDAD (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    persona_id BIGINT NOT NULL,
    tipo_documento ENUM('NIF','NIE','PASAPORTE') NOT NULL,
    numero VARCHAR(20) NOT NULL UNIQUE,
    fecha_expedicion DATE NOT NULL,
    CONSTRAINT fk_documento_persona FOREIGN KEY (persona_id)
        REFERENCES PERSONA_FISICA(id)
        ON DELETE CASCADE,
    CONSTRAINT chk_documento_formato CHECK (
        (tipo_documento = 'NIF' AND numero REGEXP '^[0-9]{8}[A-Z]$') OR
        (tipo_documento = 'NIE' AND numero REGEXP '^[XYZ][0-9]{7}[A-Z]$')
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Tabla: MATRIMONIO*/
CREATE TABLE MATRIMONIO (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    persona_id BIGINT NOT NULL,
    conyuge_id BIGINT NOT NULL,
    fecha_matrimonio DATE NOT NULL,
    regimen_id TINYINT NOT NULL,
    CONSTRAINT fk_persona_matrimonio FOREIGN KEY (persona_id)
        REFERENCES PERSONA_FISICA(id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_conyuge_matrimonio FOREIGN KEY (conyuge_id)
        REFERENCES PERSONA_FISICA(id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_matrimonio_regimen FOREIGN KEY (regimen_id)
        REFERENCES REGIMEN_MATRIMONIAL(id)
        ON DELETE RESTRICT,
    CONSTRAINT chk_conyuge_distinto CHECK (persona_id <> conyuge_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Tabla: PODER*/
CREATE TABLE PODER (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    tipo ENUM('GENERAL','ESPECIAL') NOT NULL,
    documento_digital VARCHAR(255) NOT NULL,
    fecha_otorgamiento DATE NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Tabla: REPRESENTACION*/
CREATE TABLE REPRESENTACION (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    representante_id BIGINT NOT NULL,
    representado_id BIGINT NOT NULL,
    tipo ENUM('LEGAL','NOTARIAL') NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    poder_id BIGINT,
    CONSTRAINT fk_representante FOREIGN KEY (representante_id)
        REFERENCES PERSONA_FISICA(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_representado FOREIGN KEY (representado_id)
        REFERENCES PERSONA_FISICA(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_poder FOREIGN KEY (poder_id)
        REFERENCES PODER(id)
        ON DELETE SET NULL,
    CONSTRAINT chk_distintos CHECK (representante_id <> representado_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Tabla: FORMULARIO*/
CREATE TABLE FORMULARIO (
    id_formulario BIGINT PRIMARY KEY AUTO_INCREMENT,
    tipo ENUM('1-A','1-B') NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('BORRADOR','VALIDADO','ARCHIVADO') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

/*Tabla: OTORGANTE*/
CREATE TABLE OTORGANTE (
    formulario_id BIGINT NOT NULL,
    persona_id BIGINT NOT NULL,
    PRIMARY KEY (formulario_id, persona_id),
    FOREIGN KEY (formulario_id) REFERENCES FORMULARIO(id_formulario)
        ON DELETE CASCADE,
    FOREIGN KEY (persona_id) REFERENCES PERSONA_FISICA(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
