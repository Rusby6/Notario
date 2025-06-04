CREATE INDEX idx_persona_nombre ON PERSONA_FISICA(nombre, apellido1, apellido2);
CREATE INDEX idx_juridica_denominacion ON PERSONA_JURIDICA(denominacion_social);
CREATE INDEX idx_instrumento_fecha ON INSTRUMENTO_PUBLICO(fecha_otorgamiento);
CREATE INDEX idx_instrumento_notario ON INSTRUMENTO_PUBLICO(id_notario, fecha_otorgamiento);

-- Índices para claves foráneas
CREATE INDEX idx_comparecencia_persona ON COMPARECENCIA(id_persona);
CREATE INDEX idx_intervencion_representante ON INTERVENCION(id_representante);
CREATE INDEX idx_intervencion_representado_fisico ON INTERVENCION(id_representado_fisico);
CREATE INDEX idx_intervencion_representado_juridico ON INTERVENCION(id_representado_juridico);
CREATE INDEX idx_titular_real_persona ON TITULAR_REAL(id_persona);

-- Índices para campos únicos
CREATE UNIQUE INDEX idx_persona_dni ON PERSONA_FISICA(dni_nie);
CREATE UNIQUE INDEX idx_persona_nif ON PERSONA_FISICA(nif);
CREATE UNIQUE INDEX idx_juridica_nif ON PERSONA_JURIDICA(nif);
