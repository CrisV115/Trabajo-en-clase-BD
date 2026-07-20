

BEGIN;

/* =========================================================
   TABLAS PRINCIPALES
   ========================================================= */

CREATE TABLE IF NOT EXISTS matriz (
    id_matriz INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(200) NOT NULL
);

CREATE TABLE IF NOT EXISTS sucursal (
    id_sucursal INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    num_local VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    ciudad VARCHAR(100) NOT NULL,
    direccion VARCHAR(200) NOT NULL,
    telefono VARCHAR(20),
    id_matriz INTEGER NOT NULL,
    CONSTRAINT fk_sucursal_matriz
        FOREIGN KEY (id_matriz)
        REFERENCES matriz(id_matriz)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS empleado (
    id_empleado INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cedula VARCHAR(10) NOT NULL UNIQUE,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    correo VARCHAR(150) UNIQUE,
    cargo VARCHAR(50) NOT NULL,
    fecha_contratacion DATE DEFAULT CURRENT_DATE,
    estado BOOLEAN DEFAULT TRUE,
    id_sucursal INTEGER NOT NULL,
    CONSTRAINT ck_empleado_cedula
        CHECK (cedula ~ '^[0-9]{10}$'),
    CONSTRAINT fk_empleado_sucursal
        FOREIGN KEY (id_sucursal)
        REFERENCES sucursal(id_sucursal)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS ventanilla (
    id_ventanilla INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    numero INTEGER NOT NULL CHECK (numero > 0),
    id_sucursal INTEGER NOT NULL,
    CONSTRAINT uq_ventanilla_sucursal
        UNIQUE (id_sucursal, numero),
    CONSTRAINT fk_ventanilla_sucursal
        FOREIGN KEY (id_sucursal)
        REFERENCES sucursal(id_sucursal)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS categoria (
    id_categoria INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_categoria VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS laboratorio (
    id_laboratorio INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    tipo VARCHAR(50),
    telefono VARCHAR(20),
    correo VARCHAR(150),
    direccion VARCHAR(200),
    estado BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS producto (
    codigo_barras VARCHAR(50) PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    unidad_comercializacion VARCHAR(50),
    precio_unitario NUMERIC(12,2) NOT NULL DEFAULT 0,
    registro_sanitario VARCHAR(100) UNIQUE,
    requiere_receta BOOLEAN DEFAULT FALSE,
    estado BOOLEAN DEFAULT TRUE,
    id_categoria INTEGER NOT NULL,
    id_laboratorio INTEGER,
    CONSTRAINT ck_producto_precio
        CHECK (precio_unitario >= 0),
    CONSTRAINT fk_producto_categoria
        FOREIGN KEY (id_categoria)
        REFERENCES categoria(id_categoria)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_producto_laboratorio
        FOREIGN KEY (id_laboratorio)
        REFERENCES laboratorio(id_laboratorio)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS lote_producto (
    id_lote INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo_barras VARCHAR(50) NOT NULL,
    numero_lote VARCHAR(50) NOT NULL,
    fecha_elaboracion DATE,
    fecha_vencimiento DATE NOT NULL,
    CONSTRAINT uq_lote_producto
        UNIQUE (codigo_barras, numero_lote),
    CONSTRAINT ck_lote_fechas
        CHECK (
            fecha_elaboracion IS NULL
            OR fecha_vencimiento > fecha_elaboracion
        ),
    CONSTRAINT fk_lote_producto
        FOREIGN KEY (codigo_barras)
        REFERENCES producto(codigo_barras)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS proveedor (
    ruc_proveedor VARCHAR(13) PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    telefono VARCHAR(20),
    direccion VARCHAR(200),
    correo VARCHAR(150) UNIQUE,
    tipo_proveedor VARCHAR(50),
    estado BOOLEAN DEFAULT TRUE,
    CONSTRAINT ck_proveedor_ruc
        CHECK (ruc_proveedor ~ '^[0-9]{13}$')
);

CREATE TABLE IF NOT EXISTS proveedor_producto (
    id_proveedor_producto INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ruc_proveedor VARCHAR(13) NOT NULL,
    codigo_barras VARCHAR(50) NOT NULL,
    precio_referencia NUMERIC(12,2) NOT NULL DEFAULT 0,
    CONSTRAINT uq_proveedor_producto
        UNIQUE (ruc_proveedor, codigo_barras),
    CONSTRAINT ck_proveedor_producto_precio
        CHECK (precio_referencia >= 0),
    CONSTRAINT fk_pp_proveedor
        FOREIGN KEY (ruc_proveedor)
        REFERENCES proveedor(ruc_proveedor)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_pp_producto
        FOREIGN KEY (codigo_barras)
        REFERENCES producto(codigo_barras)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS inventario (
    id_inventario INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_sucursal INTEGER NOT NULL,
    codigo_barras VARCHAR(50) NOT NULL,
    cantidad_disponible INTEGER NOT NULL DEFAULT 0,
    stock_minimo INTEGER NOT NULL DEFAULT 0,
    stock_maximo INTEGER,
    fecha_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_inventario_sucursal_producto
        UNIQUE (id_sucursal, codigo_barras),
    CONSTRAINT ck_inventario_cantidad
        CHECK (cantidad_disponible >= 0),
    CONSTRAINT ck_inventario_stock_minimo
        CHECK (stock_minimo >= 0),
    CONSTRAINT ck_inventario_stock_maximo
        CHECK (
            stock_maximo IS NULL
            OR stock_maximo >= stock_minimo
        ),
    CONSTRAINT fk_inventario_sucursal
        FOREIGN KEY (id_sucursal)
        REFERENCES sucursal(id_sucursal)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_inventario_producto
        FOREIGN KEY (codigo_barras)
        REFERENCES producto(codigo_barras)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS clientes (
    identificacion VARCHAR(13) PRIMARY KEY,
    tipo_identificacion VARCHAR(20) DEFAULT 'CEDULA',
    tipo_cliente VARCHAR(20) DEFAULT 'NATURAL',
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100),
    telefono VARCHAR(20),
    direccion VARCHAR(200),
    correo VARCHAR(150) UNIQUE,
    fecha_nacimiento DATE,
    estado BOOLEAN DEFAULT TRUE,
    CONSTRAINT ck_clientes_identificacion
        CHECK (identificacion ~ '^[0-9]{10,13}$'),
    CONSTRAINT ck_clientes_tipo_identificacion
        CHECK (tipo_identificacion IN ('CEDULA', 'RUC', 'PASAPORTE'))
);

CREATE TABLE IF NOT EXISTS medico (
    id_medico INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombres VARCHAR(150) NOT NULL,
    especialidad VARCHAR(100),
    telefono VARCHAR(20),
    correo VARCHAR(150),
    numero_registro VARCHAR(50) UNIQUE,
    estado BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS aseguradora (
    id_aseguradora INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ruc VARCHAR(13) UNIQUE,
    nombre VARCHAR(150) NOT NULL UNIQUE,
    descripcion VARCHAR(200),
    telefono VARCHAR(20),
    correo VARCHAR(150),
    direccion VARCHAR(200),
    estado BOOLEAN DEFAULT TRUE,
    CONSTRAINT ck_aseguradora_ruc
        CHECK (ruc IS NULL OR ruc ~ '^[0-9]{13}$')
);

CREATE TABLE IF NOT EXISTS plan_salud (
    id_plan_salud INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(250),
    frecuencia VARCHAR(100),
    porcentaje_cobertura NUMERIC(5,2) DEFAULT 0,
    valor_mensual NUMERIC(12,2) DEFAULT 0,
    id_aseguradora INTEGER,
    estado BOOLEAN DEFAULT TRUE,
    CONSTRAINT uq_plan_salud
        UNIQUE (id_aseguradora, nombre),
    CONSTRAINT ck_plan_salud_cobertura
        CHECK (porcentaje_cobertura BETWEEN 0 AND 100),
    CONSTRAINT ck_plan_salud_valor
        CHECK (valor_mensual >= 0),
    CONSTRAINT fk_plan_salud_aseguradora
        FOREIGN KEY (id_aseguradora)
        REFERENCES aseguradora(id_aseguradora)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS cliente_plan_salud (
    identificacion VARCHAR(13) NOT NULL,
    id_plan_salud INTEGER NOT NULL,
    numero_poliza VARCHAR(100) UNIQUE,
    fecha_inicio DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_fin DATE,
    estado BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (identificacion, id_plan_salud),
    CONSTRAINT ck_cliente_plan_fechas
        CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),
    CONSTRAINT fk_cliente_plan_cliente
        FOREIGN KEY (identificacion)
        REFERENCES clientes(identificacion)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_cliente_plan_salud
        FOREIGN KEY (id_plan_salud)
        REFERENCES plan_salud(id_plan_salud)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS tipo_pago (
    id_tipo_pago INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    descripcion VARCHAR(50) NOT NULL UNIQUE,
    estado BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS compra (
    id_compra INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    numero_compra VARCHAR(30) UNIQUE,
    fecha_compra TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ruc_proveedor VARCHAR(13) NOT NULL,
    id_sucursal INTEGER NOT NULL,
    id_empleado INTEGER,
    id_tipo_pago INTEGER,
    subtotal NUMERIC(12,2) NOT NULL DEFAULT 0,
    iva NUMERIC(12,2) NOT NULL DEFAULT 0,
    total NUMERIC(12,2) NOT NULL DEFAULT 0,
    estado VARCHAR(20) NOT NULL DEFAULT 'REGISTRADA',
    CONSTRAINT ck_compra_valores
        CHECK (subtotal >= 0 AND iva >= 0 AND total >= 0),
    CONSTRAINT ck_compra_estado
        CHECK (estado IN ('REGISTRADA', 'ANULADA', 'PENDIENTE')),
    CONSTRAINT fk_compra_proveedor
        FOREIGN KEY (ruc_proveedor)
        REFERENCES proveedor(ruc_proveedor)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_compra_sucursal
        FOREIGN KEY (id_sucursal)
        REFERENCES sucursal(id_sucursal)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_compra_empleado
        FOREIGN KEY (id_empleado)
        REFERENCES empleado(id_empleado)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT fk_compra_tipo_pago
        FOREIGN KEY (id_tipo_pago)
        REFERENCES tipo_pago(id_tipo_pago)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS compra_detalle (
    id_compra_detalle INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_compra INTEGER NOT NULL,
    codigo_barras VARCHAR(50) NOT NULL,
    cantidad INTEGER NOT NULL,
    precio_compra NUMERIC(12,2) NOT NULL,
    subtotal NUMERIC(12,2)
        GENERATED ALWAYS AS (cantidad * precio_compra) STORED,
    CONSTRAINT uq_compra_detalle
        UNIQUE (id_compra, codigo_barras),
    CONSTRAINT ck_compra_detalle_cantidad
        CHECK (cantidad > 0),
    CONSTRAINT ck_compra_detalle_precio
        CHECK (precio_compra >= 0),
    CONSTRAINT fk_compra_detalle_compra
        FOREIGN KEY (id_compra)
        REFERENCES compra(id_compra)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_compra_detalle_producto
        FOREIGN KEY (codigo_barras)
        REFERENCES producto(codigo_barras)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS factura (
    id_factura INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    numero_factura VARCHAR(30) NOT NULL UNIQUE,
    fecha_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_sucursal INTEGER NOT NULL,
    id_empleado INTEGER NOT NULL,
    identificacion_cliente VARCHAR(13),
    id_tipo_pago INTEGER NOT NULL,
    id_aseguradora INTEGER,
    id_plan_salud INTEGER,
    id_medico INTEGER,
    subtotal NUMERIC(12,2) NOT NULL DEFAULT 0,
    descuento NUMERIC(12,2) NOT NULL DEFAULT 0,
    iva NUMERIC(12,2) NOT NULL DEFAULT 0,
    total NUMERIC(12,2) NOT NULL DEFAULT 0,
    estado VARCHAR(20) NOT NULL DEFAULT 'EMITIDA',
    CONSTRAINT ck_factura_valores
        CHECK (
            subtotal >= 0
            AND descuento >= 0
            AND iva >= 0
            AND total >= 0
        ),
    CONSTRAINT ck_factura_estado
        CHECK (estado IN ('EMITIDA', 'ANULADA', 'PENDIENTE')),
    CONSTRAINT fk_factura_sucursal
        FOREIGN KEY (id_sucursal)
        REFERENCES sucursal(id_sucursal)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_factura_empleado
        FOREIGN KEY (id_empleado)
        REFERENCES empleado(id_empleado)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_factura_cliente
        FOREIGN KEY (identificacion_cliente)
        REFERENCES clientes(identificacion)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT fk_factura_tipo_pago
        FOREIGN KEY (id_tipo_pago)
        REFERENCES tipo_pago(id_tipo_pago)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_factura_aseguradora
        FOREIGN KEY (id_aseguradora)
        REFERENCES aseguradora(id_aseguradora)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT fk_factura_plan_salud
        FOREIGN KEY (id_plan_salud)
        REFERENCES plan_salud(id_plan_salud)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT fk_factura_medico
        FOREIGN KEY (id_medico)
        REFERENCES medico(id_medico)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS factura_detalle (
    id_factura_detalle INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_factura INTEGER NOT NULL,
    codigo_barras VARCHAR(50) NOT NULL,
    id_sucursal_origen INTEGER NOT NULL,
    cantidad INTEGER NOT NULL,
    precio_venta NUMERIC(12,2) NOT NULL,
    descuento NUMERIC(12,2) NOT NULL DEFAULT 0,
    subtotal NUMERIC(12,2)
        GENERATED ALWAYS AS (
            (cantidad * precio_venta) - descuento
        ) STORED,
    CONSTRAINT uq_factura_detalle
        UNIQUE (id_factura, codigo_barras, id_sucursal_origen),
    CONSTRAINT ck_factura_detalle_cantidad
        CHECK (cantidad > 0),
    CONSTRAINT ck_factura_detalle_precio
        CHECK (precio_venta >= 0),
    CONSTRAINT ck_factura_detalle_descuento
        CHECK (descuento >= 0),
    CONSTRAINT fk_factura_detalle_factura
        FOREIGN KEY (id_factura)
        REFERENCES factura(id_factura)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_factura_detalle_producto
        FOREIGN KEY (codigo_barras)
        REFERENCES producto(codigo_barras)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_factura_detalle_sucursal
        FOREIGN KEY (id_sucursal_origen)
        REFERENCES sucursal(id_sucursal)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS transferencia (
    id_transferencia INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sucursal_origen INTEGER NOT NULL,
    sucursal_destino INTEGER NOT NULL,
    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(20) NOT NULL DEFAULT 'REGISTRADA',
    CONSTRAINT ck_transferencia_sucursales
        CHECK (sucursal_origen <> sucursal_destino),
    CONSTRAINT fk_transferencia_origen
        FOREIGN KEY (sucursal_origen)
        REFERENCES sucursal(id_sucursal)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_transferencia_destino
        FOREIGN KEY (sucursal_destino)
        REFERENCES sucursal(id_sucursal)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS detalle_transferencia (
    id_detalle_transferencia INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_transferencia INTEGER NOT NULL,
    codigo_barras VARCHAR(50) NOT NULL,
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    CONSTRAINT uq_detalle_transferencia
        UNIQUE (id_transferencia, codigo_barras),
    CONSTRAINT fk_dt_transferencia
        FOREIGN KEY (id_transferencia)
        REFERENCES transferencia(id_transferencia)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_dt_producto
        FOREIGN KEY (codigo_barras)
        REFERENCES producto(codigo_barras)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

/* =========================================================
   AUDITORÍA
   ========================================================= */

CREATE TABLE IF NOT EXISTS auditoria (
    id_auditoria BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tabla_afectada VARCHAR(100) NOT NULL,
    operacion VARCHAR(10) NOT NULL,
    usuario_bd VARCHAR(100) NOT NULL DEFAULT CURRENT_USER,
    fecha_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    datos_anteriores JSONB,
    datos_nuevos JSONB
);

/* =========================================================
   FUNCIONES Y TRIGGERS DE INVENTARIO
   ========================================================= */

CREATE OR REPLACE FUNCTION fn_ingresar_inventario_compra()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_sucursal INTEGER;
BEGIN
    SELECT id_sucursal
    INTO v_id_sucursal
    FROM compra
    WHERE id_compra = NEW.id_compra;

    INSERT INTO inventario (
        id_sucursal,
        codigo_barras,
        cantidad_disponible,
        fecha_actualizacion
    )
    VALUES (
        v_id_sucursal,
        NEW.codigo_barras,
        NEW.cantidad,
        CURRENT_TIMESTAMP
    )
    ON CONFLICT (id_sucursal, codigo_barras)
    DO UPDATE SET
        cantidad_disponible =
            inventario.cantidad_disponible + EXCLUDED.cantidad_disponible,
        fecha_actualizacion = CURRENT_TIMESTAMP;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_ingreso_inventario_compra
ON compra_detalle;

CREATE TRIGGER trg_ingreso_inventario_compra
AFTER INSERT ON compra_detalle
FOR EACH ROW
EXECUTE FUNCTION fn_ingresar_inventario_compra();


CREATE OR REPLACE FUNCTION fn_validar_stock_factura()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_stock INTEGER;
BEGIN
    SELECT cantidad_disponible
    INTO v_stock
    FROM inventario
    WHERE id_sucursal = NEW.id_sucursal_origen
      AND codigo_barras = NEW.codigo_barras
    FOR UPDATE;

    IF v_stock IS NULL THEN
        RAISE EXCEPTION
            'No existe inventario para el producto % en la sucursal %',
            NEW.codigo_barras,
            NEW.id_sucursal_origen;
    END IF;

    IF v_stock < NEW.cantidad THEN
        RAISE EXCEPTION
            'Stock insuficiente. Disponible: %, solicitado: %',
            v_stock,
            NEW.cantidad;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_validar_stock_factura
ON factura_detalle;

CREATE TRIGGER trg_validar_stock_factura
BEFORE INSERT OR UPDATE OF cantidad, codigo_barras, id_sucursal_origen
ON factura_detalle
FOR EACH ROW
EXECUTE FUNCTION fn_validar_stock_factura();


CREATE OR REPLACE FUNCTION fn_descontar_inventario_factura()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE inventario
    SET cantidad_disponible =
            cantidad_disponible - NEW.cantidad,
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE id_sucursal = NEW.id_sucursal_origen
      AND codigo_barras = NEW.codigo_barras;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_descontar_inventario_factura
ON factura_detalle;

CREATE TRIGGER trg_descontar_inventario_factura
AFTER INSERT ON factura_detalle
FOR EACH ROW
EXECUTE FUNCTION fn_descontar_inventario_factura();


/* =========================================================
   FUNCIÓN GENERAL DE AUDITORÍA
   ========================================================= */

CREATE OR REPLACE FUNCTION fn_registrar_auditoria()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria (
            tabla_afectada,
            operacion,
            datos_nuevos
        )
        VALUES (
            TG_TABLE_NAME,
            TG_OP,
            to_jsonb(NEW)
        );

        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria (
            tabla_afectada,
            operacion,
            datos_anteriores,
            datos_nuevos
        )
        VALUES (
            TG_TABLE_NAME,
            TG_OP,
            to_jsonb(OLD),
            to_jsonb(NEW)
        );

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria (
            tabla_afectada,
            operacion,
            datos_anteriores
        )
        VALUES (
            TG_TABLE_NAME,
            TG_OP,
            to_jsonb(OLD)
        );

        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS trg_auditoria_empleado ON empleado;
CREATE TRIGGER trg_auditoria_empleado
AFTER INSERT OR UPDATE OR DELETE ON empleado
FOR EACH ROW
EXECUTE FUNCTION fn_registrar_auditoria();

DROP TRIGGER IF EXISTS trg_auditoria_producto ON producto;
CREATE TRIGGER trg_auditoria_producto
AFTER INSERT OR UPDATE OR DELETE ON producto
FOR EACH ROW
EXECUTE FUNCTION fn_registrar_auditoria();

DROP TRIGGER IF EXISTS trg_auditoria_compra ON compra;
CREATE TRIGGER trg_auditoria_compra
AFTER INSERT OR UPDATE OR DELETE ON compra
FOR EACH ROW
EXECUTE FUNCTION fn_registrar_auditoria();

DROP TRIGGER IF EXISTS trg_auditoria_factura ON factura;
CREATE TRIGGER trg_auditoria_factura
AFTER INSERT OR UPDATE OR DELETE ON factura
FOR EACH ROW
EXECUTE FUNCTION fn_registrar_auditoria();

DROP TRIGGER IF EXISTS trg_auditoria_inventario ON inventario;
CREATE TRIGGER trg_auditoria_inventario
AFTER INSERT OR UPDATE OR DELETE ON inventario
FOR EACH ROW
EXECUTE FUNCTION fn_registrar_auditoria();

/* =========================================================
   ÍNDICES
   ========================================================= */

CREATE INDEX IF NOT EXISTS idx_sucursal_matriz
    ON sucursal(id_matriz);

CREATE INDEX IF NOT EXISTS idx_empleado_sucursal
    ON empleado(id_sucursal);

CREATE INDEX IF NOT EXISTS idx_ventanilla_sucursal
    ON ventanilla(id_sucursal);

CREATE INDEX IF NOT EXISTS idx_producto_categoria
    ON producto(id_categoria);

CREATE INDEX IF NOT EXISTS idx_producto_laboratorio
    ON producto(id_laboratorio);

CREATE INDEX IF NOT EXISTS idx_lote_producto_codigo
    ON lote_producto(codigo_barras);

CREATE INDEX IF NOT EXISTS idx_pp_proveedor
    ON proveedor_producto(ruc_proveedor);

CREATE INDEX IF NOT EXISTS idx_pp_producto
    ON proveedor_producto(codigo_barras);

CREATE INDEX IF NOT EXISTS idx_inventario_sucursal
    ON inventario(id_sucursal);

CREATE INDEX IF NOT EXISTS idx_inventario_producto
    ON inventario(codigo_barras);

CREATE INDEX IF NOT EXISTS idx_plan_salud_aseguradora
    ON plan_salud(id_aseguradora);

CREATE INDEX IF NOT EXISTS idx_cliente_plan_salud
    ON cliente_plan_salud(id_plan_salud);

CREATE INDEX IF NOT EXISTS idx_compra_proveedor
    ON compra(ruc_proveedor);

CREATE INDEX IF NOT EXISTS idx_compra_sucursal
    ON compra(id_sucursal);

CREATE INDEX IF NOT EXISTS idx_compra_empleado
    ON compra(id_empleado);

CREATE INDEX IF NOT EXISTS idx_compra_tipo_pago
    ON compra(id_tipo_pago);

CREATE INDEX IF NOT EXISTS idx_compra_detalle_compra
    ON compra_detalle(id_compra);

CREATE INDEX IF NOT EXISTS idx_compra_detalle_producto
    ON compra_detalle(codigo_barras);

CREATE INDEX IF NOT EXISTS idx_factura_sucursal
    ON factura(id_sucursal);

CREATE INDEX IF NOT EXISTS idx_factura_empleado
    ON factura(id_empleado);

CREATE INDEX IF NOT EXISTS idx_factura_cliente
    ON factura(identificacion_cliente);

CREATE INDEX IF NOT EXISTS idx_factura_tipo_pago
    ON factura(id_tipo_pago);

CREATE INDEX IF NOT EXISTS idx_factura_aseguradora
    ON factura(id_aseguradora);

CREATE INDEX IF NOT EXISTS idx_factura_plan_salud
    ON factura(id_plan_salud);

CREATE INDEX IF NOT EXISTS idx_factura_medico
    ON factura(id_medico);

CREATE INDEX IF NOT EXISTS idx_factura_detalle_factura
    ON factura_detalle(id_factura);

CREATE INDEX IF NOT EXISTS idx_factura_detalle_producto
    ON factura_detalle(codigo_barras);

CREATE INDEX IF NOT EXISTS idx_factura_detalle_sucursal
    ON factura_detalle(id_sucursal_origen);

CREATE INDEX IF NOT EXISTS idx_transferencia_origen
    ON transferencia(sucursal_origen);

CREATE INDEX IF NOT EXISTS idx_transferencia_destino
    ON transferencia(sucursal_destino);

CREATE INDEX IF NOT EXISTS idx_detalle_transferencia
    ON detalle_transferencia(id_transferencia);

CREATE INDEX IF NOT EXISTS idx_auditoria_tabla
    ON auditoria(tabla_afectada);

CREATE INDEX IF NOT EXISTS idx_auditoria_fecha
    ON auditoria(fecha_hora);

COMMIT;

/* =========================================================
   DATOS BÁSICOS OPCIONALES
   ========================================================= */

INSERT INTO tipo_pago (descripcion)
VALUES
    ('EFECTIVO'),
    ('TARJETA DE CRÉDITO'),
    ('TARJETA DE DÉBITO'),
    ('TRANSFERENCIA')
ON CONFLICT (descripcion) DO NOTHING;

-- Crear grupos
CREATE ROLE Administrativo NOLOGIN;
CREATE ROLE Director NOLOGIN;
CREATE ROLE Supervisor NOLOGIN;
CREATE ROLE Cajero NOLOGIN;

--administrativo

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO Administrativo;

GRANT ALL PRIVILEGES
ON ALL SEQUENCES IN SCHEMA public
TO Administrativo;

-- directivo
GRANT SELECT ON ALL TABLES IN SCHEMA public TO Director;

--supervisor
GRANT ALL ON proveedor TO Supervisor;
GRANT ALL ON producto TO Supervisor;
GRANT ALL ON laboratorio TO Supervisor;
GRANT ALL ON inventario TO Supervisor;
GRANT ALL ON compra TO Supervisor;
GRANT ALL ON compra_detalle TO Supervisor;
GRANT ALL ON plan_salud TO Supervisor;
GRANT ALL ON aseguradora TO Supervisor;
GRANT ALL ON tipo_pago TO Supervisor;

GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO Supervisor;

--cajero

GRANT SELECT, INSERT, UPDATE ON clientes TO Cajero;

GRANT SELECT, INSERT, UPDATE ON factura TO Cajero;

GRANT SELECT, INSERT, UPDATE ON factura_detalle TO Cajero;

GRANT SELECT ON producto TO Cajero;

GRANT SELECT ON inventario TO Cajero;

GRANT SELECT ON plan_salud TO Cajero;

GRANT SELECT ON aseguradora TO Cajero;

GRANT SELECT ON tipo_pago TO Cajero;

GRANT SELECT ON auditoria TO Cajero;

GRANT USAGE, SELECT
ON ALL SEQUENCES IN SCHEMA public
TO Cajero;

--crear usuarios
-- DBA
CREATE USER administrador
WITH PASSWORD 'Admin123';

ALTER USER administrador WITH SUPERUSER;

-- Administrativo
CREATE USER maria
WITH PASSWORD 'Maria123';

GRANT Administrativo TO maria;

-- Director
CREATE USER carlos
WITH PASSWORD 'Carlos123';

GRANT Director TO carlos;

-- Supervisor
CREATE USER andres
WITH PASSWORD 'Andres123';

GRANT Supervisor TO andres;

-- Cajero
CREATE USER sofia
WITH PASSWORD 'Sofia123';

GRANT Cajero TO sofia;

ALTER USER maria
WITH PASSWORD 'NuevaClave123';

SELECT *
FROM pg_shadow;

SELECT * FROM producto;

SELECT * FROM clientes;

SELECT * FROM factura;

INSERT INTO producto(
codigo_barras,
nombre,
precio_unitario,
id_categoria)
VALUES(
'1001',
'Prueba',
10,
1);

INSERT INTO laboratorio(
nombre)
VALUES(
'Laboratorio Prueba');

UPDATE producto
SET precio_unitario=15
WHERE codigo_barras='1001';

DELETE FROM empleado
WHERE id_empleado=1;

INSERT INTO factura(
numero_factura,
id_sucursal,
id_empleado,
id_tipo_pago,
subtotal,
iva,
total)
VALUES(
'FAC001',
1,
1,
1,
100,
15,
115);

SELECT *
FROM inventario;

INSERT INTO producto(
codigo_barras,
nombre,
precio_unitario,
id_categoria)
VALUES(
'5000',
'Medicamento',
20,
1);

INSERT INTO empleado(...);

UPDATE producto
SET precio_unitario=20;

DELETE FROM proveedor
WHERE ruc_proveedor='1799999999001';

SELECT *
FROM auditoria;