-- Vista para instrumentos con información completa
CREATE VIEW vista_instrumentos_completos AS
SELECT 
    ip.id_instrumento,
    ip.numero_protocolo,
    ip.lugar_otorgamiento,
    ip.fecha_otorgamiento,
    n.nombre AS nombre_notario,
    n.apellidos AS apellidos_notario,
    n.colegio_notarial,
    COUNT(DISTINCT c.id_comparecencia) AS total_comparecientes,
    COUNT(DISTINCT i.id_intervencion) AS total_intervenciones
FROM INSTRUMENTO_PUBLICO ip
JOIN NOTARIO n ON ip.id_notario = n.id_notario
LEFT JOIN COMPARECENCIA c ON ip.id_instrumento = c.id_instrumento
LEFT JOIN INTERVENCION i ON ip.id_instrumento = i.id_instrumento
GROUP BY ip.id_instrumento;

-- Vista para personas con sus roles en instrumentos
CREATE VIEW vista_personas_roles AS
SELECT 
    pf.id_persona,
    pf.dni_nie,
    pf.nombre,
    pf.apellido1,
    pf.apellido2,
    c.rol,
    COUNT(DISTINCT c.id_instrumento) AS total_instrumentos,
    GROUP_CONCAT(DISTINCT ip.numero_protocolo ORDER BY ip.fecha_otorgamiento DESC SEPARATOR ', ') AS protocolos
FROM PERSONA_FISICA pf
LEFT JOIN COMPARECENCIA c ON pf.id_persona = c.id_persona
LEFT JOIN INSTRUMENTO_PUBLICO ip ON c.id_instrumento = ip.id_instrumento
GROUP BY pf.id_persona, c.rol;

-- Vista para representaciones verificadas
CREATE VIEW vista_representaciones_verificadas AS
SELECT 
    r.id_representacion,
    r.tipo,
    r.documento_apoyo,
    n.nombre AS nombre_notario,
    n.apellidos AS apellidos_notario,
    pf_rep.nombre AS nombre_representante,
    pf_rep.apellido1 AS apellido1_representante,
    CASE 
        WHEN i.tipo_sujeto = 'fisica' THEN CONCAT(pf_rep.nombre, ' ', pf_rep.apellido1)
        WHEN i.tipo_sujeto = 'juridica' THEN pj.denominacion_social
    END AS sujeto_representado,
    i.id_instrumento,
    ip.numero_protocolo
FROM REPRESENTACION r
JOIN NOTARIO n ON r.id_notario_verificador = n.id_notario
JOIN INTERVENCION i ON r.id_representacion = i.id_representacion
JOIN PERSONA_FISICA pf_rep ON i.id_representante = pf_rep.id_persona
LEFT JOIN PERSONA_FISICA pf_repd ON i.id_representado_fisico = pf_repd.id_persona AND i.tipo_sujeto = 'fisica'
LEFT JOIN PERSONA_JURIDICA pj ON i.id_representado_juridico = pj.id_juridica AND i.tipo_sujeto = 'juridica'
JOIN INSTRUMENTO_PUBLICO ip ON i.id_instrumento = ip.id_instrumento;
3.5 Procedimientos Almacenados
-- Procedimiento para registrar nuevo instrumento
DELIMITER //
CREATE PROCEDURE sp_registrar_instrumento(
    IN p_numero_protocolo VARCHAR(20),
    IN p_lugar_otorgamiento VARCHAR(255),
    IN p_fecha_otorgamiento DATE,
IN p_hora_otorgamiento TIME,
    IN p_id_notario INT,
    OUT p_id_instrumento INT
)
BEGIN
    INSERT INTO INSTRUMENTO_PUBLICO (
        numero_protocolo,
        lugar_otorgamiento,
        fecha_otorgamiento,
        hora_otorgamiento,
        id_notario
    ) VALUES (
        p_numero_protocolo,
        p_lugar_otorgamiento,
        p_fecha_otorgamiento,
        p_hora_otorgamiento,
        p_id_notario
    );
    
    SET p_id_instrumento = LAST_INSERT_ID();
    
    -- Crear encabezamiento automáticamente
    INSERT INTO ENCABEZAMIENTO (id_instrumento) VALUES (p_id_instrumento);
END //
DELIMITER ;

-- Procedimiento para registrar comparecencia
DELIMITER //
CREATE PROCEDURE sp_registrar_comparecencia(
    IN p_id_instrumento INT,
    IN p_dni_nie VARCHAR(20),
    IN p_rol ENUM('otorgante', 'representante', 'testigo', 'traductor', 'tecnico'),
    IN p_detalles_rol TEXT,
    OUT p_id_comparecencia INT
)
BEGIN
    DECLARE v_id_persona INT;
    
    -- Obtener ID de persona
    SELECT id_persona INTO v_id_persona FROM PERSONA_FISICA WHERE dni_nie = p_dni_nie;
    
    IF v_id_persona IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Persona no encontrada';
    END IF;
    
    -- Insertar comparecencia
    INSERT INTO COMPARECENCIA (
        id_instrumento,
        id_persona,
        rol,
        detalles_rol
    ) VALUES (
        p_id_instrumento,
        v_id_persona,
        p_rol,
        p_detalles_rol
    );
    
    SET p_id_comparecencia = LAST_INSERT_ID();
END //
DELIMITER ;

-- Procedimiento para evaluar capacidad
DELIMITER //
CREATE PROCEDURE sp_evaluar_capacidad(
    IN p_id_instrumento INT,
    IN p_dni_nie VARCHAR(20),
    IN p_id_notario INT,
    IN p_capacidad_natural BOOLEAN,
    IN p_legitimacion BOOLEAN,
    IN p_observaciones TEXT,
    OUT p_id_juicio INT
)
BEGIN
    DECLARE v_id_persona INT;
    
    -- Obtener ID de persona
    SELECT id_persona INTO v_id_persona FROM PERSONA_FISICA WHERE dni_nie = p_dni_nie;
    
    IF v_id_persona IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Persona no encontrada';
    END IF;
    
    -- Insertar evaluación
    INSERT INTO JUICIO_CAPACIDAD (
        id_instrumento,
        id_persona,
        id_notario,
        capacidad_natural,
        legitimacion,
        observaciones,
        fecha_evaluacion
    ) VALUES (
        p_id_instrumento,
        v_id_persona,
        p_id_notario,
        p_capacidad_natural,
        p_legitimacion,
        p_observaciones,
        CURDATE()
    );
    
    SET p_id_juicio = LAST_INSERT_ID();
END //
DELIMITER ;
