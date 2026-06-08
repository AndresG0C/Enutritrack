-- public.alimentos definition

-- Drop table
-- DROP TABLE public.alimentos;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

DO $$ BEGIN
    CREATE TYPE tipo_cuenta_enum AS ENUM ('admin', 'doctor', 'usuario');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE registro_comida_tipo_enum AS ENUM ('desayuno', 'almuerzo', 'cena', 'merienda');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE alergia_severidad_enum AS ENUM ('leve', 'moderada', 'severa');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE condicion_medica_severidad_enum AS ENUM ('leve', 'moderada', 'severa');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE nivel_actividad_enum AS ENUM ('sedentario', 'moderado', 'activo', 'muy_activo');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;


CREATE TABLE public.alimentos (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	nombre varchar(200) NOT NULL,
	descripcion text NULL,
	calorias_por_100g numeric(8, 2) NOT NULL,
	proteinas_g_por_100g numeric(8, 2) NOT NULL,
	carbohidratos_g_por_100g numeric(8, 2) NOT NULL,
	grasas_g_por_100g numeric(8, 2) NOT NULL,
	fibra_g_por_100g numeric(8, 2) NULL,
	categoria varchar(50) NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "PK_da5d1df2a12881071a1c6cf367d" PRIMARY KEY (id),
	CONSTRAINT "UQ_6d0ac6179e6f1df3d917750b0bb" UNIQUE (nombre)
);


-- public.categorias_alerta definition

-- Drop table

-- DROP TABLE public.categorias_alerta;

CREATE TABLE public.categorias_alerta (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	nombre varchar(50) NOT NULL,
	descripcion text NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "PK_7547d469a6ab3e08d8c32c4c393" PRIMARY KEY (id),
	CONSTRAINT "UQ_593ecf93b88b0749e62e40236e1" UNIQUE (nombre)
);


-- public.cuentas definition

-- Drop table

-- DROP TABLE public.cuentas;

CREATE TABLE public.cuentas (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	email varchar(255) NOT NULL,
	email_1 varchar(255) NULL,
	email_2 varchar(255) NULL,
	password_hash varchar(255) NOT NULL,
	tipo_cuenta tipo_cuenta_enum NOT NULL,
	activa bool DEFAULT true NOT NULL,
	ultimo_acceso timestamp NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "PK_1176afa6e483a49bee4ad8d543e" PRIMARY KEY (id),
	CONSTRAINT "UQ_01efc035e062d3c6968c4a3186a" UNIQUE (email)
);


-- public.especialidades definition

-- Drop table

-- DROP TABLE public.especialidades;

CREATE TABLE public.especialidades (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	nombre varchar(100) NOT NULL,
	descripcion text NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	CONSTRAINT especialidades_nombre_key UNIQUE (nombre),
	CONSTRAINT especialidades_pkey PRIMARY KEY (id)
);


-- public.estados_alerta definition

-- Drop table

-- DROP TABLE public.estados_alerta;

CREATE TABLE public.estados_alerta (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	nombre varchar(50) NOT NULL,
	descripcion text NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "PK_fbb86e7d1e8ca71fdb1c110c6bd" PRIMARY KEY (id),
	CONSTRAINT "UQ_48f1d53f81d2418900c126e99b4" UNIQUE (nombre)
);


-- public.estados_cita definition

-- Drop table

-- DROP TABLE public.estados_cita;

CREATE TABLE public.estados_cita (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	nombre varchar(50) NOT NULL,
	descripcion text NULL,
	es_final bool DEFAULT false NOT NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "PK_15f2a87ed8e42274b373bc0cf74" PRIMARY KEY (id),
	CONSTRAINT "UQ_bedaadbbe90c436986228b19856" UNIQUE (nombre)
);


-- public.generos definition

-- Drop table

-- DROP TABLE public.generos;

CREATE TABLE public.generos (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	nombre varchar(50) NOT NULL,
	descripcion text NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	CONSTRAINT generos_nombre_key UNIQUE (nombre),
	CONSTRAINT generos_pkey PRIMARY KEY (id)
);


-- public.niveles_prioridad_alerta definition

-- Drop table

-- DROP TABLE public.niveles_prioridad_alerta;

CREATE TABLE public.niveles_prioridad_alerta (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	nombre varchar(50) NOT NULL,
	descripcion text NULL,
	nivel_numerico int4 NOT NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "PK_e4eff5cee0fb24bcdba478560fd" PRIMARY KEY (id),
	CONSTRAINT "UQ_2518c9044ae31719413faed65e2" UNIQUE (nivel_numerico),
	CONSTRAINT "UQ_af84dc399f1e0792035c4d43f98" UNIQUE (nombre)
);


-- public.tipos_actividad definition

-- Drop table

-- DROP TABLE public.tipos_actividad;

CREATE TABLE public.tipos_actividad (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	nombre varchar(100) NOT NULL,
	descripcion text NULL,
	met_value numeric(4, 2) NOT NULL,
	categoria varchar(50) NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "PK_a493a03e0d088e01765aa7a199b" PRIMARY KEY (id),
	CONSTRAINT "UQ_169b6499943a3894ec3ac6b6abe" UNIQUE (nombre)
);


-- public.tipos_consulta definition

-- Drop table

-- DROP TABLE public.tipos_consulta;

CREATE TABLE public.tipos_consulta (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	nombre varchar(100) NOT NULL,
	descripcion text NULL,
	duracion_minutos int4 DEFAULT 30 NOT NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "PK_9ef912671a1d544cb4bcf68c1a4" PRIMARY KEY (id),
	CONSTRAINT "UQ_fd095eb5764cecbe7f17a9a2edb" UNIQUE (nombre)
);


-- public.tipos_recomendacion definition

-- Drop table

-- DROP TABLE public.tipos_recomendacion;

CREATE TABLE public.tipos_recomendacion (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	nombre varchar(100) NOT NULL,
	descripcion text NULL,
	categoria varchar(50) NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "PK_6b6b97fff92c45d8252d0e5b77b" PRIMARY KEY (id),
	CONSTRAINT "UQ_e8b206326f9b87611cfbcce8fe1" UNIQUE (nombre)
);


-- public.perfil_admin definition

-- Drop table

-- DROP TABLE public.perfil_admin;

CREATE TABLE public.perfil_admin (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	cuenta_id uuid NOT NULL,
	nombre varchar(100) NOT NULL,
	departamento varchar(100) NULL,
	telefono varchar(20) NULL,
	telefono_1 varchar(20) NULL,
	telefono_2 varchar(20) NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "PK_a035099194558ceead04c222118" PRIMARY KEY (id),
	CONSTRAINT "REL_99c562ad0ebe05d51d8f559ea1" UNIQUE (cuenta_id),
	CONSTRAINT "FK_99c562ad0ebe05d51d8f559ea1e" FOREIGN KEY (cuenta_id) REFERENCES public.cuentas(id)
);


-- public.perfil_doctor definition

-- Drop table

-- DROP TABLE public.perfil_doctor;

CREATE TABLE public.perfil_doctor (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	cuenta_id uuid NOT NULL,
	admin_id uuid NULL,
	nombre varchar(100) NOT NULL,
	especialidad_id uuid NULL,
	cedula_profesional varchar(50) NULL,
	telefono varchar(20) NULL,
	telefono_1 varchar(20) NULL,
	telefono_2 varchar(20) NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "PK_f0a6462f0cf92007e3a01ea24ae" PRIMARY KEY (id),
	CONSTRAINT "REL_a2a8cfb93315e3c0deae75e9b0" UNIQUE (cuenta_id),
	CONSTRAINT "UQ_fb2ae662957eebcda09a30878f6" UNIQUE (cedula_profesional),
	CONSTRAINT "FK_5472a6f4631a965d0b363fb56f4" FOREIGN KEY (admin_id) REFERENCES public.perfil_admin(id),
	CONSTRAINT "FK_5a0bfd40cda201eaca540116fa3" FOREIGN KEY (especialidad_id) REFERENCES public.especialidades(id),
	CONSTRAINT "FK_a2a8cfb93315e3c0deae75e9b02" FOREIGN KEY (cuenta_id) REFERENCES public.cuentas(id)
);


-- public.perfil_usuario definition

-- Drop table

-- DROP TABLE public.perfil_usuario;

CREATE TABLE public.perfil_usuario (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	cuenta_id uuid NOT NULL,
	doctor_id uuid NULL,
	nombre varchar(100) NOT NULL,
	fecha_nacimiento date NOT NULL,
	genero_id uuid NOT NULL,
	altura numeric(5, 2) NOT NULL,
	telefono varchar(20) NULL,
	telefono_1 varchar(20) NULL,
	telefono_2 varchar(20) NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "PK_98ee297aeb0462f198211eb02e5" PRIMARY KEY (id),
	CONSTRAINT "REL_b2e9b7b68478168ed3ea558bf3" UNIQUE (cuenta_id),
	CONSTRAINT "FK_08bab94dbbd104e8409848d9744" FOREIGN KEY (genero_id) REFERENCES public.generos(id),
	CONSTRAINT "FK_6027dbb0e202da594f040a2024e" FOREIGN KEY (doctor_id) REFERENCES public.perfil_doctor(id),
	CONSTRAINT "FK_b2e9b7b68478168ed3ea558bf3c" FOREIGN KEY (cuenta_id) REFERENCES public.cuentas(id)
);


-- public.registro_comida definition

-- Drop table

-- DROP TABLE public.registro_comida;

CREATE TABLE public.registro_comida (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	usuario_id uuid NOT NULL,
	fecha timestamp DEFAULT now() NOT NULL,
	tipo_comida registro_comida_tipo_enum NOT NULL,
	notas text NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "PK_5f8657df1e85e5f7e31a00c19f5" PRIMARY KEY (id),
	CONSTRAINT "FK_666cd9ce7847214c1ad5ffa582b" FOREIGN KEY (usuario_id) REFERENCES public.perfil_usuario(id)
);


-- public.registro_comida_items definition

-- Drop table

-- DROP TABLE public.registro_comida_items;

CREATE TABLE public.registro_comida_items (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	registro_comida_id uuid NOT NULL,
	alimento_id uuid NOT NULL,
	cantidad_gramos numeric(8, 2) NOT NULL,
	calorias numeric(8, 2) NOT NULL,
	proteinas_g numeric(8, 2) NOT NULL,
	carbohidratos_g numeric(8, 2) NOT NULL,
	grasas_g numeric(8, 2) NOT NULL,
	fibra_g numeric(8, 2) NULL,
	notas text NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "PK_5edca3607b2ae6f554d8eade4dd" PRIMARY KEY (id),
	CONSTRAINT "FK_3b3c27ad1d1501aaa2ba2a8925a" FOREIGN KEY (registro_comida_id) REFERENCES public.registro_comida(id),
	CONSTRAINT "FK_58d8436695881921f761c86762a" FOREIGN KEY (alimento_id) REFERENCES public.alimentos(id)
);


-- public.tipos_alerta definition

-- Drop table

-- DROP TABLE public.tipos_alerta;

CREATE TABLE public.tipos_alerta (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	nombre varchar(100) NOT NULL,
	descripcion text NULL,
	categoria_id uuid NOT NULL,
	es_automatica bool DEFAULT false NOT NULL,
	config_validacion jsonb NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "PK_d0d5f5870b021f676cdaa386d24" PRIMARY KEY (id),
	CONSTRAINT "UQ_a7dff40b43b67f81fb79ca90a1f" UNIQUE (nombre),
	CONSTRAINT "FK_ef237a89d7c3ed5ded6e0f24556" FOREIGN KEY (categoria_id) REFERENCES public.categorias_alerta(id)
);


-- public.actividad_fisica definition

-- Drop table

-- DROP TABLE public.actividad_fisica;

CREATE TABLE public.actividad_fisica (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	usuario_id uuid NOT NULL,
	tipo_actividad_id uuid NOT NULL,
	duracion_min int4 NOT NULL,
	calorias_quemadas numeric(8, 2) NOT NULL,
	intensidad varchar(50) NULL,
	notas text NULL,
	fecha timestamp DEFAULT now() NOT NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "PK_22112f74e38238962be3a1683d3" PRIMARY KEY (id),
	CONSTRAINT "FK_5cd33e5df91e8cbf19b59f2fb08" FOREIGN KEY (tipo_actividad_id) REFERENCES public.tipos_actividad(id),
	CONSTRAINT "FK_5eaaa8423dccf49cdf0a2abb6d5" FOREIGN KEY (usuario_id) REFERENCES public.perfil_usuario(id)
);


-- public.alergias definition

-- Drop table

-- DROP TABLE public.alergias;

CREATE TABLE public.alergias (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	usuario_id uuid NOT NULL,
	tipo varchar(100) NULL,
	nombre varchar(200) NOT NULL,
	severidad alergia_severidad_enum NOT NULL,
	reaccion text NULL,
	notas text NULL,
	activa bool DEFAULT true NOT NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "PK_1fe78413c55fb2188ec202e723e" PRIMARY KEY (id),
	CONSTRAINT "FK_121b8e5b55c97ba255fb807b3f3" FOREIGN KEY (usuario_id) REFERENCES public.perfil_usuario(id)
);


-- public.citas_medicas definition

-- Drop table

-- DROP TABLE public.citas_medicas;

CREATE TABLE public.citas_medicas (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	usuario_id uuid NOT NULL,
	doctor_id uuid NOT NULL,
	tipo_consulta_id uuid NOT NULL,
	estado_cita_id uuid NOT NULL,
	fecha_hora_programada timestamp NOT NULL,
	fecha_hora_inicio timestamp NULL,
	fecha_hora_fin timestamp NULL,
	motivo text NULL,
	observaciones text NULL,
	diagnostico text NULL,
	tratamiento_recomendado text NULL,
	proxima_cita_sugerida date NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "PK_3ed9dd628e6c786153af09aca97" PRIMARY KEY (id),
	CONSTRAINT "FK_44a66c3ea3b56302dc057fa9ac9" FOREIGN KEY (tipo_consulta_id) REFERENCES public.tipos_consulta(id),
	CONSTRAINT "FK_83a6de0ddd9c85d657ac6413fe8" FOREIGN KEY (usuario_id) REFERENCES public.perfil_usuario(id),
	CONSTRAINT "FK_bf18f0511002ab123226a3fb2ec" FOREIGN KEY (estado_cita_id) REFERENCES public.estados_cita(id),
	CONSTRAINT "FK_fb7562a1a92f3159c0fe13bfe7e" FOREIGN KEY (doctor_id) REFERENCES public.perfil_doctor(id)
);


-- public.citas_medicas_documentos definition

-- Drop table

-- DROP TABLE public.citas_medicas_documentos;

CREATE TABLE public.citas_medicas_documentos (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	cita_medica_id uuid NOT NULL,
	nombre_archivo varchar(255) NOT NULL,
	tipo_documento varchar(100) NULL,
	ruta_archivo varchar(500) NOT NULL,
	tamano_bytes int8 NULL,
	notas text NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "PK_c5a9860ccd780e26352a88859f7" PRIMARY KEY (id),
	CONSTRAINT "FK_a240d2180feacacbf4d2c398929" FOREIGN KEY (cita_medica_id) REFERENCES public.citas_medicas(id)
);


-- public.citas_medicas_vitales definition

-- Drop table

-- DROP TABLE public.citas_medicas_vitales;

CREATE TABLE public.citas_medicas_vitales (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	cita_medica_id uuid NOT NULL,
	peso numeric(5, 2) NULL,
	altura numeric(5, 2) NULL,
	tension_arterial_sistolica int4 NULL,
	tension_arterial_diastolica int4 NULL,
	frecuencia_cardiaca int4 NULL,
	temperatura numeric(4, 2) NULL,
	saturacion_oxigeno int4 NULL,
	notas text NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "PK_a167c4fe42a2da0c9a134a9892f" PRIMARY KEY (id),
	CONSTRAINT "FK_0627dc763376d504884075696bb" FOREIGN KEY (cita_medica_id) REFERENCES public.citas_medicas(id)
);


-- public.condiciones_medicas definition

-- Drop table

-- DROP TABLE public.condiciones_medicas;

CREATE TABLE public.condiciones_medicas (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	usuario_id uuid NOT NULL,
	nombre varchar(200) NOT NULL,
	severidad condicion_medica_severidad_enum NULL,
	fecha_diagnostico date NULL,
	notas text NULL,
	activa bool DEFAULT true NOT NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "PK_72eefd0a8c6c7734a76d948814c" PRIMARY KEY (id),
	CONSTRAINT "FK_db64b75e181f2fb759dcd128f72" FOREIGN KEY (usuario_id) REFERENCES public.perfil_usuario(id)
);


-- public.configuracion_alertas_automaticas definition

-- Drop table

-- DROP TABLE public.configuracion_alertas_automaticas;

CREATE TABLE public.configuracion_alertas_automaticas (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	usuario_id uuid NOT NULL,
	tipo_alerta_id uuid NOT NULL,
	doctor_id uuid NULL,
	esta_activa bool DEFAULT true NOT NULL,
	umbral_configuracion jsonb NULL,
	frecuencia_verificacion_horas int4 DEFAULT 24 NOT NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "PK_6dce5feb5a4585f336d980b373e" PRIMARY KEY (id),
	CONSTRAINT "UQ_73c764764f6f702eed55c3a3d3f" UNIQUE (usuario_id, tipo_alerta_id),
	CONSTRAINT "FK_00fa26d3e57ee9e79ee91572a74" FOREIGN KEY (doctor_id) REFERENCES public.perfil_doctor(id),
	CONSTRAINT "FK_54cec835688b352d72c164903f0" FOREIGN KEY (usuario_id) REFERENCES public.perfil_usuario(id),
	CONSTRAINT "FK_900e4d5bc795212772d322ee584" FOREIGN KEY (tipo_alerta_id) REFERENCES public.tipos_alerta(id)
);


-- public.historial_peso definition

-- Drop table

-- DROP TABLE public.historial_peso;

CREATE TABLE public.historial_peso (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	usuario_id uuid NOT NULL,
	peso numeric(5, 2) NOT NULL,
	fecha_registro timestamp DEFAULT now() NOT NULL,
	notas text NULL,
	CONSTRAINT "PK_2cf496a0438b114efe098d16a6c" PRIMARY KEY (id),
	CONSTRAINT "FK_54df7ae97f5aa5f7db5b44f31f1" FOREIGN KEY (usuario_id) REFERENCES public.perfil_usuario(id)
);


-- public.medicamentos definition

-- Drop table

-- DROP TABLE public.medicamentos;

CREATE TABLE public.medicamentos (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	usuario_id uuid NOT NULL,
	nombre varchar(200) NOT NULL,
	dosis varchar(100) NULL,
	frecuencia varchar(100) NULL,
	fecha_inicio date NOT NULL,
	fecha_fin date NULL,
	notas text NULL,
	activo bool DEFAULT true NOT NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "PK_3985b0c130d1322e867f7ad5ee9" PRIMARY KEY (id),
	CONSTRAINT "FK_8b1ba412db1986c0a58d18b0e6e" FOREIGN KEY (usuario_id) REFERENCES public.perfil_usuario(id)
);


-- public.objetivo_usuario definition

-- Drop table

-- DROP TABLE public.objetivo_usuario;

CREATE TABLE public.objetivo_usuario (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	usuario_id uuid NOT NULL,
	peso_objetivo numeric(5, 2) NULL,
	nivel_actividad nivel_actividad_enum NOT NULL,
	fecha_establecido timestamp DEFAULT now() NOT NULL,
	vigente bool DEFAULT true NOT NULL,
	CONSTRAINT "PK_5ad83df62ac6c122a895484fa24" PRIMARY KEY (id),
	CONSTRAINT "FK_e5222ed919493b0dcdd99fbf540" FOREIGN KEY (usuario_id) REFERENCES public.perfil_usuario(id)
);


-- public.alertas definition

-- Drop table

-- DROP TABLE public.alertas;

CREATE TABLE public.alertas (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	usuario_id uuid NOT NULL,
	doctor_id uuid NULL,
	tipo_alerta_id uuid NOT NULL,
	nivel_prioridad_id uuid NOT NULL,
	estado_alerta_id uuid NOT NULL,
	titulo varchar(200) NOT NULL,
	mensaje text NOT NULL,
	recomendacion_id uuid NULL,
	fecha_deteccion timestamp DEFAULT now() NOT NULL,
	fecha_resolucion timestamp NULL,
	resuelta_por uuid NULL,
	notas_resolucion text NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	updated_at timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "PK_b474c4021f8d6e4e13383ef1106" PRIMARY KEY (id)
);


-- public.alertas_acciones definition

-- Drop table

-- DROP TABLE public.alertas_acciones;

CREATE TABLE public.alertas_acciones (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	alerta_id uuid NOT NULL,
	doctor_id uuid NOT NULL,
	accion_tomada varchar(200) NOT NULL,
	descripcion text NULL,
	fecha_accion timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "PK_71fb53d077fdb60ffdf0c28b706" PRIMARY KEY (id)
);


-- public.recomendacion definition

-- Drop table

-- DROP TABLE public.recomendacion;

CREATE TABLE public.recomendacion (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	usuario_id uuid NOT NULL,
	tipo_recomendacion_id uuid NOT NULL,
	contenido text NOT NULL,
	fecha_generacion timestamp DEFAULT now() NOT NULL,
	vigencia_hasta timestamp NULL,
	activa bool DEFAULT true NOT NULL,
	prioridad varchar(20) NULL,
	cita_medica_id uuid NULL,
	alerta_generadora_id uuid NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "PK_ced84b453db88ea00867301fbb0" PRIMARY KEY (id)
);


-- public.recomendacion_datos definition

-- Drop table

-- DROP TABLE public.recomendacion_datos;

CREATE TABLE public.recomendacion_datos (
	id uuid DEFAULT uuid_generate_v4() NOT NULL,
	recomendacion_id uuid NOT NULL,
	clave varchar(100) NOT NULL,
	valor text NOT NULL,
	tipo_dato varchar(50) NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "PK_d2165b1bf25e37a47ee3107fa63" PRIMARY KEY (id)
);


-- public.alertas foreign keys

ALTER TABLE public.alertas ADD CONSTRAINT "FK_5f92fb7bb6b5a3c49f32b22abff" FOREIGN KEY (usuario_id) REFERENCES public.perfil_usuario(id);
ALTER TABLE public.alertas ADD CONSTRAINT "FK_70b7e0c54a22efd4aec47ae072c" FOREIGN KEY (doctor_id) REFERENCES public.perfil_doctor(id);
ALTER TABLE public.alertas ADD CONSTRAINT "FK_8260a14e7c073d7c96d38d1756c" FOREIGN KEY (estado_alerta_id) REFERENCES public.estados_alerta(id);
ALTER TABLE public.alertas ADD CONSTRAINT "FK_b46dcd39a0d1a22318c948c2ac6" FOREIGN KEY (nivel_prioridad_id) REFERENCES public.niveles_prioridad_alerta(id);
ALTER TABLE public.alertas ADD CONSTRAINT "FK_d532813cb0a83f84265c993d0b7" FOREIGN KEY (resuelta_por) REFERENCES public.perfil_doctor(id);
ALTER TABLE public.alertas ADD CONSTRAINT "FK_e341cd09064bf8b7deff9118a05" FOREIGN KEY (recomendacion_id) REFERENCES public.recomendacion(id);
ALTER TABLE public.alertas ADD CONSTRAINT "FK_f5e9275a4a23adbbc191aef2de3" FOREIGN KEY (tipo_alerta_id) REFERENCES public.tipos_alerta(id);


-- public.alertas_acciones foreign keys

ALTER TABLE public.alertas_acciones ADD CONSTRAINT "FK_2afc3c376563ad3a719bd05f552" FOREIGN KEY (alerta_id) REFERENCES public.alertas(id);
ALTER TABLE public.alertas_acciones ADD CONSTRAINT "FK_93cf745cd337662e4131fc32bb3" FOREIGN KEY (doctor_id) REFERENCES public.perfil_doctor(id);


-- public.recomendacion foreign keys

ALTER TABLE public.recomendacion ADD CONSTRAINT "FK_1b25a114b9d651060f5a5a0bf81" FOREIGN KEY (tipo_recomendacion_id) REFERENCES public.tipos_recomendacion(id);
ALTER TABLE public.recomendacion ADD CONSTRAINT "FK_1f9f8d536ec2da7c41088a58928" FOREIGN KEY (alerta_generadora_id) REFERENCES public.alertas(id);
ALTER TABLE public.recomendacion ADD CONSTRAINT "FK_59ead48536b1a42fa28af62e565" FOREIGN KEY (cita_medica_id) REFERENCES public.citas_medicas(id);
ALTER TABLE public.recomendacion ADD CONSTRAINT "FK_e010e191ea1cc786cc71eb3e56e" FOREIGN KEY (usuario_id) REFERENCES public.perfil_usuario(id);


-- public.recomendacion_datos foreign keys

ALTER TABLE public.recomendacion_datos ADD CONSTRAINT "FK_ef275625a6238e0131c0f7e8fc1" FOREIGN KEY (recomendacion_id) REFERENCES public.recomendacion(id);
-- Modificar tabla recomendacion para agregar nuevos campos
ALTER TABLE recomendacion ADD COLUMN IF NOT EXISTS cita_medica_id UUID REFERENCES citas_medicas(id);
ALTER TABLE recomendacion ADD COLUMN IF NOT EXISTS alerta_generadora_id UUID REFERENCES alertas(id);

-- Insertar datos de catálogos básicos

-- Tipos de consulta
INSERT INTO tipos_consulta (id, nombre, descripcion, duracion_minutos, created_at)
VALUES 
    (uuid_generate_v4(), 'Consulta General', 'Consulta médica general de rutina', 30, CURRENT_TIMESTAMP),
    (uuid_generate_v4(), 'Primera Vez', 'Primera consulta con el médico', 45, CURRENT_TIMESTAMP),
    (uuid_generate_v4(), 'Control de Seguimiento', 'Consulta de seguimiento y control', 20, CURRENT_TIMESTAMP),
    (uuid_generate_v4(), 'Urgencia', 'Consulta médica de urgencia', 60, CURRENT_TIMESTAMP),
    (uuid_generate_v4(), 'Nutrición', 'Consulta especializada en nutrición', 45, CURRENT_TIMESTAMP)
ON CONFLICT (nombre) DO NOTHING;

-- Estados de cita
INSERT INTO estados_cita (id, nombre, descripcion, es_final, created_at)
VALUES 
    (uuid_generate_v4(), 'Programada', 'Cita programada y pendiente', false, CURRENT_TIMESTAMP),
    (uuid_generate_v4(), 'En Proceso', 'Consulta en desarrollo', false, CURRENT_TIMESTAMP),
    (uuid_generate_v4(), 'Completada', 'Consulta completada exitosamente', true, CURRENT_TIMESTAMP),
    (uuid_generate_v4(), 'Cancelada', 'Cita cancelada por el paciente o médico', true, CURRENT_TIMESTAMP),
    (uuid_generate_v4(), 'No Asistió', 'Paciente no se presentó a la cita', true, CURRENT_TIMESTAMP),
    (uuid_generate_v4(), 'Reprogramada', 'Cita reprogramada para otra fecha', false, CURRENT_TIMESTAMP)
ON CONFLICT (nombre) DO NOTHING;

-- Categorías de alerta
INSERT INTO categorias_alerta (id, nombre, descripcion, created_at)
VALUES 
    (uuid_generate_v4(), 'Peso', 'Alertas relacionadas con cambios de peso', CURRENT_TIMESTAMP),
    (uuid_generate_v4(), 'Nutrición', 'Alertas relacionadas con hábitos nutricionales', CURRENT_TIMESTAMP),
    (uuid_generate_v4(), 'Actividad Física', 'Alertas relacionadas con actividad física', CURRENT_TIMESTAMP),
    (uuid_generate_v4(), 'Medicamentos', 'Alertas relacionadas con medicamentos', CURRENT_TIMESTAMP),
    (uuid_generate_v4(), 'Salud General', 'Alertas generales de salud', CURRENT_TIMESTAMP)
ON CONFLICT (nombre) DO NOTHING;

-- Niveles de prioridad de alerta
INSERT INTO niveles_prioridad_alerta (id, nombre, descripcion, nivel_numerico, created_at)
VALUES 
    (uuid_generate_v4(), 'Baja', 'Alerta de prioridad baja', 1, CURRENT_TIMESTAMP),
    (uuid_generate_v4(), 'Media', 'Alerta de prioridad media', 2, CURRENT_TIMESTAMP),
    (uuid_generate_v4(), 'Alta', 'Alerta de prioridad alta', 3, CURRENT_TIMESTAMP),
    (uuid_generate_v4(), 'Crítica', 'Alerta de prioridad crítica', 4, CURRENT_TIMESTAMP)
ON CONFLICT (nombre) DO NOTHING;

-- Estados de alerta
INSERT INTO estados_alerta (id, nombre, descripcion, created_at)
VALUES 
    (uuid_generate_v4(), 'Pendiente', 'Alerta detectada, pendiente de revisión', CURRENT_TIMESTAMP),
    (uuid_generate_v4(), 'En Revisión', 'Alerta siendo revisada por el médico', CURRENT_TIMESTAMP),
    (uuid_generate_v4(), 'Resuelta', 'Alerta resuelta por el médico', CURRENT_TIMESTAMP),
    (uuid_generate_v4(), 'Descarte', 'Alerta descartada como falsa alarma', CURRENT_TIMESTAMP)
ON CONFLICT (nombre) DO NOTHING;

-- Tipos de alerta (dependen de categorias_alerta)
INSERT INTO tipos_alerta (nombre, descripcion, categoria_id, es_automatica, config_validacion, created_at)
SELECT 
    'Pérdida de Peso Abrupta',
    'Alerta cuando se detecta pérdida de peso significativa en poco tiempo',
    ca.id,
    true,
    '{"condiciones":[{"tabla":"historial_peso","campos_evaluacion":["peso"],"operacion":"calcular_perdida_porcentual","parametros":{"umbral_porcentaje":5.0,"periodo_dias":7,"minimo_registros":2}}],"mensaje_template":"Se ha detectado una pérdida de peso del {porcentaje}% en los últimos {dias} días","nivel_prioridad_default":"alta"}'::jsonb,
    CURRENT_TIMESTAMP
FROM categorias_alerta ca WHERE ca.nombre = 'Peso'
ON CONFLICT (nombre) DO NOTHING;

INSERT INTO tipos_alerta (nombre, descripcion, categoria_id, es_automatica, config_validacion, created_at)
SELECT 
    'Falta de Registro Nutricional',
    'Alerta cuando no se registra ingesta de alimentos por más de 3 días',
    ca.id,
    true,
    '{"condiciones":[{"tabla":"registro_comida","campos_evaluacion":["fecha_registro"],"operacion":"verificar_falta_registro","parametros":{"dias_limite":3}}],"mensaje_template":"No se han registrado alimentos en los últimos {dias} días","nivel_prioridad_default":"media"}'::jsonb,
    CURRENT_TIMESTAMP
FROM categorias_alerta ca WHERE ca.nombre = 'Nutrición'
ON CONFLICT (nombre) DO NOTHING;

-- ========================================
-- TIPOS DE ACTIVIDAD FÍSICA
-- ========================================

-- Crear tabla tipos_actividad si no existe (para compatibilidad)
CREATE TABLE IF NOT EXISTS tipos_actividad (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(100) UNIQUE NOT NULL,
    descripcion TEXT,
    met_value NUMERIC(4,2) NOT NULL,
    categoria VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar tipos de actividad física con MET values (basados en Compendium of Physical Activities)
-- Categoría: Cardio/Resistencia
INSERT INTO tipos_actividad (id, nombre, descripcion, met_value, categoria, created_at)
VALUES 
    -- Actividades de alta intensidad
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567801', 'Correr (10 km/h)', 'Correr a velocidad moderada', 11.50, 'Cardio', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567802', 'Correr (12 km/h)', 'Correr a velocidad rápida', 13.50, 'Cardio', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567803', 'Correr (14 km/h)', 'Correr a velocidad muy rápida', 15.00, 'Cardio', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567804', 'Correr (8 km/h)', 'Trote moderado', 9.80, 'Cardio', CURRENT_TIMESTAMP),
    
    -- Caminar
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567805', 'Caminar (4 km/h)', 'Caminata lenta', 3.30, 'Cardio', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567806', 'Caminar (5 km/h)', 'Caminata normal', 3.80, 'Cardio', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567807', 'Caminar (6 km/h)', 'Caminata rápida', 5.00, 'Cardio', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567808', 'Caminar (7 km/h)', 'Caminata muy rápida', 6.30, 'Cardio', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567809', 'Caminar cuesta arriba', 'Caminata en pendiente', 8.00, 'Cardio', CURRENT_TIMESTAMP),
    
    -- Ciclismo
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567810', 'Ciclismo (16 km/h)', 'Pedaleo moderado', 6.00, 'Cardio', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567811', 'Ciclismo (20 km/h)', 'Pedaleo rápido', 8.00, 'Cardio', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567812', 'Ciclismo (24 km/h)', 'Pedaleo muy rápido', 10.00, 'Cardio', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567813', 'Bicicleta estática', 'Ejercicio en bicicleta fija', 8.50, 'Cardio', CURRENT_TIMESTAMP),
    
    -- Natación
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567814', 'Natación (crol)', 'Estilo libre de natación', 9.80, 'Cardio', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567815', 'Natación (espalda)', 'Nado de espalda', 7.00, 'Cardio', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567816', 'Natación (pecho)', 'Nado de pecho', 7.50, 'Cardio', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567817', 'Aquagym', 'Ejercicios acuáticos', 5.30, 'Cardio', CURRENT_TIMESTAMP),
    
    -- Elíptica y escaleras
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567818', 'Máquina elíptica', 'Ejercicio en elíptica', 7.00, 'Cardio', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567819', 'Subir escaleras', 'Ascenso de escaleras', 8.80, 'Cardio', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567820', 'Escaladora', 'Máquina escaladora', 12.00, 'Cardio', CURRENT_TIMESTAMP),
    
    -- Cinta y aeróbicos
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567821', 'Cinta de correr (5 km/h)', 'Caminar en cinta', 3.80, 'Cardio', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567822', 'Cinta de correr (8 km/h)', 'Trotar en cinta', 9.80, 'Cardio', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567823', 'Aeróbicos (bajo impacto)', 'Ejercicios aeróbicos suaves', 5.00, 'Cardio', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567824', 'Aeróbicos (alto impacto)', 'Ejercicios aeróbicos intensos', 7.50, 'Cardio', CURRENT_TIMESTAMP),
    
    -- Fuerza y Resistencia
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567825', 'Pesas (entrenamiento moderado)', 'Levantamiento de pesas moderado', 5.00, 'Fuerza', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567826', 'Pesas (entrenamiento intenso)', 'Levantamiento de pesas intenso', 6.00, 'Fuerza', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567827', 'Calistenia', 'Ejercicios con peso corporal', 8.00, 'Fuerza', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567828', 'Yoga', 'Práctica de yoga', 3.00, 'Flexibilidad', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567829', 'Pilates', 'Ejercicios de pilates', 3.50, 'Flexibilidad', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567830', 'Estiramiento', 'Ejercicios de estiramiento', 2.50, 'Flexibilidad', CURRENT_TIMESTAMP),
    
    -- Deportes
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567831', 'Fútbol', 'Jugar fútbol', 8.00, 'Deportes', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567832', 'Básquetbol', 'Jugar básquetbol', 8.00, 'Deportes', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567833', 'Tenis (individual)', 'Jugar tenis individual', 8.00, 'Deportes', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567834', 'Tenis (dobles)', 'Jugar tenis dobles', 6.00, 'Deportes', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567835', 'Voleibol', 'Jugar voleibol', 3.00, 'Deportes', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567836', 'Pádel', 'Jugar pádel', 6.00, 'Deportes', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567837', 'Badminton', 'Jugar badminton', 5.50, 'Deportes', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567838', 'Squash', 'Jugar squash', 12.00, 'Deportes', CURRENT_TIMESTAMP),
    
    -- Actividades al aire libre
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567839', 'Senderismo', 'Caminar en montaña', 6.00, 'Aire Libre', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567840', 'Montañismo', 'Escalada de montaña', 8.00, 'Aire Libre', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567841', 'Rafting', 'Descenso en río', 5.00, 'Aire Libre', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567842', 'Remo', 'Remo en bote', 7.00, 'Aire Libre', CURRENT_TIMESTAMP),
    
    -- Danza y movimiento
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567843', 'Baile (ritmo lento)', 'Baile suave', 3.50, 'Danza', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567844', 'Baile (ritmo rápido)', 'Baile intenso', 6.80, 'Danza', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567845', 'Zumba', 'Clase de zumba', 7.30, 'Danza', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567846', 'Baile latino', 'Bailes latinos', 5.50, 'Danza', CURRENT_TIMESTAMP),
    
    -- Artes marciales
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567847', 'Boxeo (entrenamiento)', 'Entrenamiento de boxeo', 12.00, 'Artes Marciales', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567848', 'Kickboxing', 'Kickboxing', 10.30, 'Artes Marciales', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567849', 'Karate', 'Práctica de karate', 10.30, 'Artes Marciales', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567850', 'Taekwondo', 'Práctica de taekwondo', 10.30, 'Artes Marciales', CURRENT_TIMESTAMP),
    
    -- Actividades recreativas
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567851', 'Golf (caminando)', 'Golf caminando el campo', 5.30, 'Recreación', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567852', 'Bolos', 'Jugar bolos', 3.00, 'Recreación', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567853', 'Jardinería', 'Trabajo de jardinería', 4.00, 'Recreación', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567854', 'Limpieza pesada', 'Limpieza intensa del hogar', 3.50, 'Recreación', CURRENT_TIMESTAMP),
    
    -- Crossfit y HIIT
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567855', 'Crossfit', 'Entrenamiento crossfit', 12.00, 'Crossfit', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567856', 'HIIT', 'Entrenamiento de alta intensidad', 11.00, 'Crossfit', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567857', 'Bootcamp', 'Entrenamiento bootcamp', 10.00, 'Crossfit', CURRENT_TIMESTAMP),
    
    -- Actividades específicas
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567858', 'Spinning', 'Clase de spinning', 8.50, 'Cardio', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567859', 'Rowing (remo máquina)', 'Remo en máquina', 7.00, 'Cardio', CURRENT_TIMESTAMP),
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567860', 'Escalada (muro)', 'Escalada en muro', 8.00, 'Fuerza', CURRENT_TIMESTAMP)
ON CONFLICT (nombre) DO NOTHING;

INSERT INTO especialidades (id, nombre, descripcion, created_at)
VALUES 
    ('4f671de1-075a-4842-ac74-817b5b974652', 'Medicina General', 'Atencion medica general y preventiva', CURRENT_TIMESTAMP),
    ('8861e869-93de-4209-bbc6-5b79f6e605aa', 'Nutricion', 'Especialidad en nutricion y dietetica', CURRENT_TIMESTAMP),
    ('581313fb-683b-41ca-b66a-907e99e7ee2a', 'Endocrinologia', 'Trastornos del sistema endocrino', CURRENT_TIMESTAMP),
    ('6ce306f7-2ed3-4540-bf23-f5bdf1b59dd6', 'Cardiologia', 'Enfermedades del corazon y sistema cardiovascular', CURRENT_TIMESTAMP),
    ('ac7e8a61-82bf-4c51-840c-88170d2238d8', 'Pediatria', 'Atencion medica para ninos y adolescentes', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

INSERT INTO generos (id, nombre, descripcion, created_at)
VALUES 
    ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Masculino', 'Genero masculino', CURRENT_TIMESTAMP),
    ('b2c3d4e5-f6a7-8901-bcde-f12345678901', 'Femenino', 'Genero femenino', CURRENT_TIMESTAMP),
    ('c3d4e5f6-a7b8-9012-cdef-123456789012', 'Otro', 'Otro genero no especificado', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

-- Crear cuenta de administrador por defecto
-- Contraseña: admin123 (ya hasheada con bcrypt)
INSERT INTO cuentas (id, email, email_1, email_2, password_hash, tipo_cuenta, activa, created_at, updated_at)
VALUES (
  uuid_generate_v4(),
  'admin@enutritrack.com',
  NULL,
  NULL,
  '$2b$10$maEqA0.WZZU7LzvTDQ8CWOmzosuH.KqMcR2WpdFQinFNXUpa/CYxi',
  'admin',
  true,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
)
ON CONFLICT (email) DO NOTHING;

-- Crear perfil de admin por defecto
INSERT INTO perfil_admin (id, cuenta_id, nombre, departamento, telefono, telefono_1, telefono_2, created_at, updated_at)
SELECT 
  uuid_generate_v4(),
  c.id,
  'Administrador',
  'TI',
  NULL,
  NULL,
  NULL,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
FROM cuentas c
WHERE c.email = 'admin@enutritrack.com'
  AND NOT EXISTS (
    SELECT 1 FROM perfil_admin pa WHERE pa.cuenta_id = c.id
  );

-- Insertar datos de ejemplo completos: 5 doctores con 4 pacientes cada uno
-- Password para doctores: doctor123 (ya hasheada con bcrypt)
-- Password para usuarios: usuario123 (ya hasheada con bcrypt)

-- Crear 5 cuentas de doctores
INSERT INTO cuentas (id, email, email_1, email_2, password_hash, tipo_cuenta, activa, created_at, updated_at)
VALUES 
  (uuid_generate_v4(), 'dr.perez@enutritrack.com', NULL, NULL, '$2a$12$tCP.x1BGcTkbfgbum7pjre6doqpUc5fwN6D8yw.7rFYE9fkUS6Fwa', 'doctor', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (uuid_generate_v4(), 'dr.garcia@enutritrack.com', NULL, NULL, '$2a$12$tCP.x1BGcTkbfgbum7pjre6doqpUc5fwN6D8yw.7rFYE9fkUS6Fwa', 'doctor', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (uuid_generate_v4(), 'dr.lopez@enutritrack.com', NULL, NULL, '$2a$12$tCP.x1BGcTkbfgbum7pjre6doqpUc5fwN6D8yw.7rFYE9fkUS6Fwa', 'doctor', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (uuid_generate_v4(), 'dr.martinez@enutritrack.com', NULL, NULL, '$2a$12$tCP.x1BGcTkbfgbum7pjre6doqpUc5fwN6D8yw.7rFYE9fkUS6Fwa', 'doctor', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (uuid_generate_v4(), 'dr.rodriguez@enutritrack.com', NULL, NULL, '$2a$12$tCP.x1BGcTkbfgbum7pjre6doqpUc5fwN6D8yw.7rFYE9fkUS6Fwa', 'doctor', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (email) DO NOTHING;

-- Crear perfiles de doctores
INSERT INTO perfil_doctor (id, cuenta_id, admin_id, nombre, especialidad_id, cedula_profesional, telefono, telefono_1, telefono_2, created_at, updated_at)
SELECT 
  uuid_generate_v4(),
  c.id,
  pa.id,
  CASE 
    WHEN c.email = 'dr.perez@enutritrack.com' THEN 'Dr. Juan Carlos Perez'
    WHEN c.email = 'dr.garcia@enutritrack.com' THEN 'Dra. Maria Elena Garcia'
    WHEN c.email = 'dr.lopez@enutritrack.com' THEN 'Dr. Carlos Alberto Lopez'
    WHEN c.email = 'dr.martinez@enutritrack.com' THEN 'Dra. Ana Sofia Martinez'
    WHEN c.email = 'dr.rodriguez@enutritrack.com' THEN 'Dr. Luis Fernando Rodriguez'
  END,
  CASE 
    WHEN c.email = 'dr.perez@enutritrack.com' THEN '8861e869-93de-4209-bbc6-5b79f6e605aa'::uuid  -- Nutricion
    WHEN c.email = 'dr.garcia@enutritrack.com' THEN '4f671de1-075a-4842-ac74-817b5b974652'::uuid  -- Medicina General
    WHEN c.email = 'dr.lopez@enutritrack.com' THEN '581313fb-683b-41ca-b66a-907e99e7ee2a'::uuid  -- Endocrinologia
    WHEN c.email = 'dr.martinez@enutritrack.com' THEN '6ce306f7-2ed3-4540-bf23-f5bdf1b59dd6'::uuid  -- Cardiologia
    WHEN c.email = 'dr.rodriguez@enutritrack.com' THEN 'ac7e8a61-82bf-4c51-840c-88170d2238d8'::uuid  -- Pediatria
  END,
  CASE 
    WHEN c.email = 'dr.perez@enutritrack.com' THEN '12345678'
    WHEN c.email = 'dr.garcia@enutritrack.com' THEN '23456789'
    WHEN c.email = 'dr.lopez@enutritrack.com' THEN '34567890'
    WHEN c.email = 'dr.martinez@enutritrack.com' THEN '45678901'
    WHEN c.email = 'dr.rodriguez@enutritrack.com' THEN '56789012'
  END,
  CASE 
    WHEN c.email = 'dr.perez@enutritrack.com' THEN '555-1001'
    WHEN c.email = 'dr.garcia@enutritrack.com' THEN '555-1002'
    WHEN c.email = 'dr.lopez@enutritrack.com' THEN '555-1003'
    WHEN c.email = 'dr.martinez@enutritrack.com' THEN '555-1004'
    WHEN c.email = 'dr.rodriguez@enutritrack.com' THEN '555-1005'
  END,
  NULL,
  NULL,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
FROM cuentas c
CROSS JOIN perfil_admin pa
WHERE c.tipo_cuenta = 'doctor'
  AND NOT EXISTS (
    SELECT 1 FROM perfil_doctor pd WHERE pd.cuenta_id = c.id
  );

-- Crear 20 cuentas de usuarios (4 por doctor)
INSERT INTO cuentas (id, email, email_1, email_2, password_hash, tipo_cuenta, activa, created_at, updated_at)
VALUES 
  (uuid_generate_v4(), 'maria.garcia@enutritrack.com', NULL, NULL, '$2a$12$T1FZf5k0I6V.mfWb7XQjZ.ebUWZF7hQvMzkU9QhsKw2rWYRbLdkky', 'usuario', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (uuid_generate_v4(), 'juan.rodriguez@enutritrack.com', NULL, NULL, '$2a$12$T1FZf5k0I6V.mfWb7XQjZ.ebUWZF7hQvMzkU9QhsKw2rWYRbLdkky', 'usuario', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (uuid_generate_v4(), 'ana.lopez@enutritrack.com', NULL, NULL, '$2a$12$T1FZf5k0I6V.mfWb7XQjZ.ebUWZF7hQvMzkU9QhsKw2rWYRbLdkky', 'usuario', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (uuid_generate_v4(), 'carlos.martinez@enutritrack.com', NULL, NULL, '$2a$12$T1FZf5k0I6V.mfWb7XQjZ.ebUWZF7hQvMzkU9QhsKw2rWYRbLdkky', 'usuario', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (uuid_generate_v4(), 'lucia.fernandez@enutritrack.com', NULL, NULL, '$2a$12$T1FZf5k0I6V.mfWb7XQjZ.ebUWZF7hQvMzkU9QhsKw2rWYRbLdkky', 'usuario', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (uuid_generate_v4(), 'pedro.gonzalez@enutritrack.com', NULL, NULL, '$2a$12$T1FZf5k0I6V.mfWb7XQjZ.ebUWZF7hQvMzkU9QhsKw2rWYRbLdkky', 'usuario', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (uuid_generate_v4(), 'sofia.herrera@enutritrack.com', NULL, NULL, '$2a$12$T1FZf5k0I6V.mfWb7XQjZ.ebUWZF7hQvMzkU9QhsKw2rWYRbLdkky', 'usuario', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (uuid_generate_v4(), 'diego.torres@enutritrack.com', NULL, NULL, '$2a$12$T1FZf5k0I6V.mfWb7XQjZ.ebUWZF7hQvMzkU9QhsKw2rWYRbLdkky', 'usuario', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (uuid_generate_v4(), 'isabella.morales@enutritrack.com', NULL, NULL, '$2a$12$T1FZf5k0I6V.mfWb7XQjZ.ebUWZF7hQvMzkU9QhsKw2rWYRbLdkky', 'usuario', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (uuid_generate_v4(), 'mateo.jimenez@enutritrack.com', NULL, NULL, '$2a$12$T1FZf5k0I6V.mfWb7XQjZ.ebUWZF7hQvMzkU9QhsKw2rWYRbLdkky', 'usuario', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (uuid_generate_v4(), 'valentina.ramirez@enutritrack.com', NULL, NULL, '$2a$12$T1FZf5k0I6V.mfWb7XQjZ.ebUWZF7hQvMzkU9QhsKw2rWYRbLdkky', 'usuario', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (uuid_generate_v4(), 'santiago.castro@enutritrack.com', NULL, NULL, '$2a$12$T1FZf5k0I6V.mfWb7XQjZ.ebUWZF7hQvMzkU9QhsKw2rWYRbLdkky', 'usuario', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (uuid_generate_v4(), 'camila.ortiz@enutritrack.com', NULL, NULL, '$2a$12$T1FZf5k0I6V.mfWb7XQjZ.ebUWZF7hQvMzkU9QhsKw2rWYRbLdkky', 'usuario', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (uuid_generate_v4(), 'alejandro.vargas@enutritrack.com', NULL, NULL, '$2a$12$T1FZf5k0I6V.mfWb7XQjZ.ebUWZF7hQvMzkU9QhsKw2rWYRbLdkky', 'usuario', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (uuid_generate_v4(), 'natalia.delgado@enutritrack.com', NULL, NULL, '$2a$12$T1FZf5k0I6V.mfWb7XQjZ.ebUWZF7hQvMzkU9QhsKw2rWYRbLdkky', 'usuario', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (uuid_generate_v4(), 'sebastian.flores@enutritrack.com', NULL, NULL, '$2a$12$T1FZf5k0I6V.mfWb7XQjZ.ebUWZF7hQvMzkU9QhsKw2rWYRbLdkky', 'usuario', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (uuid_generate_v4(), 'valeria.gutierrez@enutritrack.com', NULL, NULL, '$2a$12$T1FZf5k0I6V.mfWb7XQjZ.ebUWZF7hQvMzkU9QhsKw2rWYRbLdkky', 'usuario', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (uuid_generate_v4(), 'daniel.ruiz@enutritrack.com', NULL, NULL, '$2a$12$T1FZf5k0I6V.mfWb7XQjZ.ebUWZF7hQvMzkU9QhsKw2rWYRbLdkky', 'usuario', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (uuid_generate_v4(), 'emma.aguilar@enutritrack.com', NULL, NULL, '$2a$12$T1FZf5k0I6V.mfWb7XQjZ.ebUWZF7hQvMzkU9QhsKw2rWYRbLdkky', 'usuario', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  (uuid_generate_v4(), 'maximiliano.medina@enutritrack.com', NULL, NULL, '$2a$12$T1FZf5k0I6V.mfWb7XQjZ.ebUWZF7hQvMzkU9QhsKw2rWYRbLdkky', 'usuario', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (email) DO NOTHING;

-- Crear perfiles de usuarios (4 por doctor)
INSERT INTO perfil_usuario (id, cuenta_id, doctor_id, nombre, fecha_nacimiento, genero_id, altura, telefono, telefono_1, telefono_2, created_at, updated_at)
SELECT 
  uuid_generate_v4(),
  c.id,
  pd.id,
  CASE 
    WHEN c.email = 'maria.garcia@enutritrack.com' THEN 'Maria Garcia'
    WHEN c.email = 'juan.rodriguez@enutritrack.com' THEN 'Juan Rodriguez'
    WHEN c.email = 'ana.lopez@enutritrack.com' THEN 'Ana Lopez'
    WHEN c.email = 'carlos.martinez@enutritrack.com' THEN 'Carlos Martinez'
    WHEN c.email = 'lucia.fernandez@enutritrack.com' THEN 'Lucia Fernandez'
    WHEN c.email = 'pedro.gonzalez@enutritrack.com' THEN 'Pedro Gonzalez'
    WHEN c.email = 'sofia.herrera@enutritrack.com' THEN 'Sofia Herrera'
    WHEN c.email = 'diego.torres@enutritrack.com' THEN 'Diego Torres'
    WHEN c.email = 'isabella.morales@enutritrack.com' THEN 'Isabella Morales'
    WHEN c.email = 'mateo.jimenez@enutritrack.com' THEN 'Mateo Jimenez'
    WHEN c.email = 'valentina.ramirez@enutritrack.com' THEN 'Valentina Ramirez'
    WHEN c.email = 'santiago.castro@enutritrack.com' THEN 'Santiago Castro'
    WHEN c.email = 'camila.ortiz@enutritrack.com' THEN 'Camila Ortiz'
    WHEN c.email = 'alejandro.vargas@enutritrack.com' THEN 'Alejandro Vargas'
    WHEN c.email = 'natalia.delgado@enutritrack.com' THEN 'Natalia Delgado'
    WHEN c.email = 'sebastian.flores@enutritrack.com' THEN 'Sebastian Flores'
    WHEN c.email = 'valeria.gutierrez@enutritrack.com' THEN 'Valeria Gutierrez'
    WHEN c.email = 'daniel.ruiz@enutritrack.com' THEN 'Daniel Ruiz'
    WHEN c.email = 'emma.aguilar@enutritrack.com' THEN 'Emma Aguilar'
    WHEN c.email = 'maximiliano.medina@enutritrack.com' THEN 'Maximiliano Medina'
  END,
  CASE 
    WHEN c.email = 'maria.garcia@enutritrack.com' THEN '1990-05-15'::date
    WHEN c.email = 'juan.rodriguez@enutritrack.com' THEN '1985-08-22'::date
    WHEN c.email = 'ana.lopez@enutritrack.com' THEN '1992-12-03'::date
    WHEN c.email = 'carlos.martinez@enutritrack.com' THEN '1988-03-17'::date
    WHEN c.email = 'lucia.fernandez@enutritrack.com' THEN '1995-07-11'::date
    WHEN c.email = 'pedro.gonzalez@enutritrack.com' THEN '1987-11-28'::date
    WHEN c.email = 'sofia.herrera@enutritrack.com' THEN '1993-04-09'::date
    WHEN c.email = 'diego.torres@enutritrack.com' THEN '1989-09-14'::date
    WHEN c.email = 'isabella.morales@enutritrack.com' THEN '1996-01-25'::date
    WHEN c.email = 'mateo.jimenez@enutritrack.com' THEN '1991-06-18'::date
    WHEN c.email = 'valentina.ramirez@enutritrack.com' THEN '1994-10-07'::date
    WHEN c.email = 'santiago.castro@enutritrack.com' THEN '1986-02-13'::date
    WHEN c.email = 'camila.ortiz@enutritrack.com' THEN '1997-05-30'::date
    WHEN c.email = 'alejandro.vargas@enutritrack.com' THEN '1984-08-16'::date
    WHEN c.email = 'natalia.delgado@enutritrack.com' THEN '1998-12-21'::date
    WHEN c.email = 'sebastian.flores@enutritrack.com' THEN '1983-03-05'::date
    WHEN c.email = 'valeria.gutierrez@enutritrack.com' THEN '1999-07-08'::date
    WHEN c.email = 'daniel.ruiz@enutritrack.com' THEN '1982-11-12'::date
    WHEN c.email = 'emma.aguilar@enutritrack.com' THEN '2000-04-26'::date
    WHEN c.email = 'maximiliano.medina@enutritrack.com' THEN '1981-09-19'::date
  END,
  CASE 
    WHEN c.email IN ('maria.garcia@enutritrack.com', 'ana.lopez@enutritrack.com', 'lucia.fernandez@enutritrack.com', 'sofia.herrera@enutritrack.com', 'isabella.morales@enutritrack.com', 'valentina.ramirez@enutritrack.com', 'camila.ortiz@enutritrack.com', 'natalia.delgado@enutritrack.com', 'valeria.gutierrez@enutritrack.com', 'emma.aguilar@enutritrack.com') THEN 'b2c3d4e5-f6a7-8901-bcde-f12345678901'::uuid  -- Femenino
    ELSE 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'::uuid  -- Masculino
  END,
  CASE 
    WHEN c.email = 'maria.garcia@enutritrack.com' THEN 165.5
    WHEN c.email = 'juan.rodriguez@enutritrack.com' THEN 175.2
    WHEN c.email = 'ana.lopez@enutritrack.com' THEN 162.8
    WHEN c.email = 'carlos.martinez@enutritrack.com' THEN 180.1
    WHEN c.email = 'lucia.fernandez@enutritrack.com' THEN 158.3
    WHEN c.email = 'pedro.gonzalez@enutritrack.com' THEN 177.9
    WHEN c.email = 'sofia.herrera@enutritrack.com' THEN 164.7
    WHEN c.email = 'diego.torres@enutritrack.com' THEN 172.4
    WHEN c.email = 'isabella.morales@enutritrack.com' THEN 160.9
    WHEN c.email = 'mateo.jimenez@enutritrack.com' THEN 178.6
    WHEN c.email = 'valentina.ramirez@enutritrack.com' THEN 163.2
    WHEN c.email = 'santiago.castro@enutritrack.com' THEN 176.8
    WHEN c.email = 'camila.ortiz@enutritrack.com' THEN 159.4
    WHEN c.email = 'alejandro.vargas@enutritrack.com' THEN 181.3
    WHEN c.email = 'natalia.delgado@enutritrack.com' THEN 157.6
    WHEN c.email = 'sebastian.flores@enutritrack.com' THEN 174.7
    WHEN c.email = 'valeria.gutierrez@enutritrack.com' THEN 161.8
    WHEN c.email = 'daniel.ruiz@enutritrack.com' THEN 179.2
    WHEN c.email = 'emma.aguilar@enutritrack.com' THEN 156.9
    WHEN c.email = 'maximiliano.medina@enutritrack.com' THEN 182.1
  END,
  CASE 
    WHEN c.email = 'maria.garcia@enutritrack.com' THEN '555-2001'
    WHEN c.email = 'juan.rodriguez@enutritrack.com' THEN '555-2002'
    WHEN c.email = 'ana.lopez@enutritrack.com' THEN '555-2003'
    WHEN c.email = 'carlos.martinez@enutritrack.com' THEN '555-2004'
    WHEN c.email = 'lucia.fernandez@enutritrack.com' THEN '555-2005'
    WHEN c.email = 'pedro.gonzalez@enutritrack.com' THEN '555-2006'
    WHEN c.email = 'sofia.herrera@enutritrack.com' THEN '555-2007'
    WHEN c.email = 'diego.torres@enutritrack.com' THEN '555-2008'
    WHEN c.email = 'isabella.morales@enutritrack.com' THEN '555-2009'
    WHEN c.email = 'mateo.jimenez@enutritrack.com' THEN '555-2010'
    WHEN c.email = 'valentina.ramirez@enutritrack.com' THEN '555-2011'
    WHEN c.email = 'santiago.castro@enutritrack.com' THEN '555-2012'
    WHEN c.email = 'camila.ortiz@enutritrack.com' THEN '555-2013'
    WHEN c.email = 'alejandro.vargas@enutritrack.com' THEN '555-2014'
    WHEN c.email = 'natalia.delgado@enutritrack.com' THEN '555-2015'
    WHEN c.email = 'sebastian.flores@enutritrack.com' THEN '555-2016'
    WHEN c.email = 'valeria.gutierrez@enutritrack.com' THEN '555-2017'
    WHEN c.email = 'daniel.ruiz@enutritrack.com' THEN '555-2018'
    WHEN c.email = 'emma.aguilar@enutritrack.com' THEN '555-2019'
    WHEN c.email = 'maximiliano.medina@enutritrack.com' THEN '555-2020'
  END,
  NULL,
  NULL,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
FROM cuentas c
CROSS JOIN (
  SELECT pd.id, pd.nombre, ROW_NUMBER() OVER (ORDER BY pd.nombre) as rn
  FROM perfil_doctor pd
) pd
WHERE c.tipo_cuenta = 'usuario'
  AND NOT EXISTS (
    SELECT 1 FROM perfil_usuario pu WHERE pu.cuenta_id = c.id
  )
  AND (
    (c.email IN ('maria.garcia@enutritrack.com', 'juan.rodriguez@enutritrack.com', 'ana.lopez@enutritrack.com', 'carlos.martinez@enutritrack.com') AND pd.rn = 1) OR
    (c.email IN ('lucia.fernandez@enutritrack.com', 'pedro.gonzalez@enutritrack.com', 'sofia.herrera@enutritrack.com', 'diego.torres@enutritrack.com') AND pd.rn = 2) OR
    (c.email IN ('isabella.morales@enutritrack.com', 'mateo.jimenez@enutritrack.com', 'valentina.ramirez@enutritrack.com', 'santiago.castro@enutritrack.com') AND pd.rn = 3) OR
    (c.email IN ('camila.ortiz@enutritrack.com', 'alejandro.vargas@enutritrack.com', 'natalia.delgado@enutritrack.com', 'sebastian.flores@enutritrack.com') AND pd.rn = 4) OR
    (c.email IN ('valeria.gutierrez@enutritrack.com', 'daniel.ruiz@enutritrack.com', 'emma.aguilar@enutritrack.com', 'maximiliano.medina@enutritrack.com') AND pd.rn = 5)
  );

-- Crear registros de historial de peso (peso actual) para cada usuario
INSERT INTO historial_peso (id, usuario_id, peso, fecha_registro, notas)
SELECT 
  uuid_generate_v4(),
  pu.id,
  CASE 
    WHEN c.email = 'maria.garcia@enutritrack.com' THEN 65.5
    WHEN c.email = 'juan.rodriguez@enutritrack.com' THEN 78.2
    WHEN c.email = 'ana.lopez@enutritrack.com' THEN 58.8
    WHEN c.email = 'carlos.martinez@enutritrack.com' THEN 85.1
    WHEN c.email = 'lucia.fernandez@enutritrack.com' THEN 52.3
    WHEN c.email = 'pedro.gonzalez@enutritrack.com' THEN 82.9
    WHEN c.email = 'sofia.herrera@enutritrack.com' THEN 64.7
    WHEN c.email = 'diego.torres@enutritrack.com' THEN 77.4
    WHEN c.email = 'isabella.morales@enutritrack.com' THEN 55.9
    WHEN c.email = 'mateo.jimenez@enutritrack.com' THEN 83.6
    WHEN c.email = 'valentina.ramirez@enutritrack.com' THEN 63.2
    WHEN c.email = 'santiago.castro@enutritrack.com' THEN 81.8
    WHEN c.email = 'camila.ortiz@enutritrack.com' THEN 54.4
    WHEN c.email = 'alejandro.vargas@enutritrack.com' THEN 86.3
    WHEN c.email = 'natalia.delgado@enutritrack.com' THEN 52.6
    WHEN c.email = 'sebastian.flores@enutritrack.com' THEN 79.7
    WHEN c.email = 'valeria.gutierrez@enutritrack.com' THEN 56.8
    WHEN c.email = 'daniel.ruiz@enutritrack.com' THEN 84.2
    WHEN c.email = 'emma.aguilar@enutritrack.com' THEN 51.9
    WHEN c.email = 'maximiliano.medina@enutritrack.com' THEN 87.1
  END,
  CURRENT_TIMESTAMP,
  'Peso inicial registrado'
FROM perfil_usuario pu
JOIN cuentas c ON pu.cuenta_id = c.id
WHERE c.tipo_cuenta = 'usuario';

-- Crear objetivos de usuario para cada usuario
INSERT INTO objetivo_usuario (id, usuario_id, peso_objetivo, nivel_actividad, fecha_establecido, vigente)
SELECT 
  uuid_generate_v4(),
  pu.id,
  -- Peso objetivo
  CASE 
    WHEN c.email = 'maria.garcia@enutritrack.com' THEN 60.0
    WHEN c.email = 'juan.rodriguez@enutritrack.com' THEN 75.0
    WHEN c.email = 'ana.lopez@enutritrack.com' THEN 55.0
    WHEN c.email = 'carlos.martinez@enutritrack.com' THEN 80.0
    WHEN c.email = 'lucia.fernandez@enutritrack.com' THEN 50.0
    WHEN c.email = 'pedro.gonzalez@enutritrack.com' THEN 78.0
    WHEN c.email = 'sofia.herrera@enutritrack.com' THEN 62.0
    WHEN c.email = 'diego.torres@enutritrack.com' THEN 75.0
    WHEN c.email = 'isabella.morales@enutritrack.com' THEN 52.0
    WHEN c.email = 'mateo.jimenez@enutritrack.com' THEN 80.0
    WHEN c.email = 'valentina.ramirez@enutritrack.com' THEN 60.0
    WHEN c.email = 'santiago.castro@enutritrack.com' THEN 78.0
    WHEN c.email = 'camila.ortiz@enutritrack.com' THEN 52.0
    WHEN c.email = 'alejandro.vargas@enutritrack.com' THEN 82.0
    WHEN c.email = 'natalia.delgado@enutritrack.com' THEN 50.0
    WHEN c.email = 'sebastian.flores@enutritrack.com' THEN 76.0
    WHEN c.email = 'valeria.gutierrez@enutritrack.com' THEN 54.0
    WHEN c.email = 'daniel.ruiz@enutritrack.com' THEN 80.0
    WHEN c.email = 'emma.aguilar@enutritrack.com' THEN 49.0
    WHEN c.email = 'maximiliano.medina@enutritrack.com' THEN 83.0
  END,
  -- Nivel de actividad
  CASE 
    WHEN c.email IN ('maria.garcia@enutritrack.com', 'carlos.martinez@enutritrack.com', 'sofia.herrera@enutritrack.com', 'mateo.jimenez@enutritrack.com', 'alejandro.vargas@enutritrack.com') THEN 'sedentario'::nivel_actividad_enum
    WHEN c.email IN ('juan.rodriguez@enutritrack.com', 'lucia.fernandez@enutritrack.com', 'diego.torres@enutritrack.com', 'valentina.ramirez@enutritrack.com', 'natalia.delgado@enutritrack.com') THEN 'moderado'::nivel_actividad_enum
    WHEN c.email IN ('ana.lopez@enutritrack.com', 'pedro.gonzalez@enutritrack.com', 'isabella.morales@enutritrack.com', 'santiago.castro@enutritrack.com', 'sebastian.flores@enutritrack.com') THEN 'activo'::nivel_actividad_enum
    WHEN c.email IN ('camila.ortiz@enutritrack.com', 'valeria.gutierrez@enutritrack.com', 'daniel.ruiz@enutritrack.com', 'emma.aguilar@enutritrack.com', 'maximiliano.medina@enutritrack.com') THEN 'muy_activo'::nivel_actividad_enum
  END,
  CURRENT_TIMESTAMP,
  true
FROM perfil_usuario pu
JOIN cuentas c ON pu.cuenta_id = c.id
WHERE c.tipo_cuenta = 'usuario';

