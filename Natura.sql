
CREATE DATABASE jardineria;


CREATE TABLE gama_producto (
    gama VARCHAR(50) PRIMARY KEY,
    descripcion_texto TEXT,
    descripcion_html TEXT,
    imagen VARCHAR(255)
);

CREATE TABLE oficina (
    codigo_oficina VARCHAR(20) PRIMARY KEY,
    ciudad VARCHAR(50),
    pais VARCHAR(50),
    region VARCHAR(50),
    codigo_postal VARCHAR(20),
    telefono VARCHAR(30),
    linea_direccion1 VARCHAR(100),
    linea_direccion2 VARCHAR(100)
);

CREATE TABLE empleado (
    codigo_empleado INT PRIMARY KEY,
    nombre VARCHAR(50),
    apellido1 VARCHAR(50),
    apellido2 VARCHAR(50),
    extension VARCHAR(10),
    email VARCHAR(100),
    codigo_oficina VARCHAR(20),
    codigo_jefe INT,
    puesto VARCHAR(50),
    CONSTRAINT fk_empleado_oficina
        FOREIGN KEY (codigo_oficina)
        REFERENCES oficina(codigo_oficina),
    CONSTRAINT fk_empleado_jefe
        FOREIGN KEY (codigo_jefe)
        REFERENCES empleado(codigo_empleado)
);

CREATE TABLE cliente (
    codigo_cliente INT PRIMARY KEY,
    nombre_cliente VARCHAR(100),
    nombre_contacto VARCHAR(50),
    apellido_contacto VARCHAR(50),
    telefono VARCHAR(30),
    fax VARCHAR(30),
    linea_direccion1 VARCHAR(100),
    linea_direccion2 VARCHAR(100),
    ciudad VARCHAR(50),
    region VARCHAR(50),
    pais VARCHAR(50),
    codigo_postal VARCHAR(20),
    codigo_empleado_rep_ventas INT,
    limite_credito DECIMAL(15,2),
    CONSTRAINT fk_cliente_empleado
        FOREIGN KEY (codigo_empleado_rep_ventas)
        REFERENCES empleado(codigo_empleado)
);

CREATE TABLE producto (
    codigo_producto VARCHAR(20) PRIMARY KEY,
    nombre VARCHAR(100),
    gama VARCHAR(50),
    dimensiones VARCHAR(50),
    proveedor VARCHAR(100),
    descripcion TEXT,
    cantidad_en_stock INT,
    precio_venta DECIMAL(15,2),
    precio_proveedor DECIMAL(15,2),
    CONSTRAINT fk_producto_gama
        FOREIGN KEY (gama)
        REFERENCES gama_producto(gama)
);

CREATE TABLE pedido (
    codigo_pedido INT PRIMARY KEY,
    fecha_pedido DATE,
    fecha_esperada DATE,
    fecha_entrega DATE,
    estado VARCHAR(30),
    comentarios TEXT,
    codigo_cliente INT,
    CONSTRAINT fk_pedido_cliente
        FOREIGN KEY (codigo_cliente)
        REFERENCES cliente(codigo_cliente)
);

CREATE TABLE pago (
    codigo_cliente INT,
    forma_pago VARCHAR(40),
    id_transaccion VARCHAR(50),
    fecha_pago DATE,
    total DECIMAL(15,2),
    PRIMARY KEY (codigo_cliente, id_transaccion),
    CONSTRAINT fk_pago_cliente
        FOREIGN KEY (codigo_cliente)
        REFERENCES cliente(codigo_cliente)
);

CREATE TABLE detalle_pedido (
    codigo_pedido INT,
    codigo_producto VARCHAR(20),
    cantidad INT,
    precio_unidad DECIMAL(15,2),
    numero_linea SMALLINT,
    PRIMARY KEY (codigo_pedido, codigo_producto),
    CONSTRAINT fk_detalle_pedido
        FOREIGN KEY (codigo_pedido)
        REFERENCES pedido(codigo_pedido),
    CONSTRAINT fk_detalle_producto
        FOREIGN KEY (codigo_producto)
        REFERENCES producto(codigo_producto)
);

--administrativo
GRANT ALL PRIVILEGES ON TABLE
gama_producto,
oficina,
empleado,
cliente,
producto,
pedido,
pago,
detalle_pedido
TO Administrativo;

--director

GRANT SELECT ON TABLE
gama_producto,
oficina,
empleado,
cliente,
producto,
pedido,
pago,
detalle_pedido
TO Director;

--supervisor 

GRANT SELECT, INSERT, UPDATE ON TABLE
gama_producto,
oficina,
empleado,
cliente,
producto,
pedido,
pago,
detalle_pedido
TO Supervisor;

-- cajero 
GRANT SELECT ON TABLE
cliente,
producto
TO Cajero;

GRANT SELECT, INSERT, UPDATE ON TABLE
pedido,
pago
TO Cajero;

CREATE USER kary
WITH PASSWORD 'Admin123';

CREATE USER juan
WITH PASSWORD 'Director123';

CREATE USER maria
WITH PASSWORD 'Supervisor123';

CREATE USER pedro
WITH PASSWORD 'Cajero123';

GRANT Administrativo TO kary;

GRANT Director TO juan;

GRANT Supervisor TO maria;

GRANT Cajero TO pedro;

ALTER USER kary
WITH PASSWORD 'NuevaClave123';

SELECT *
FROM pg_shadow;

--director 
SET ROLE Director;

SELECT * FROM cliente;
INSERT INTO cliente
VALUES (...);

--supervisar
SET ROLE Supervisor;

UPDATE producto
SET precio_venta = 50
WHERE codigo_producto='FR-1';

--cajero
SET ROLE Cajero;

INSERT INTO pago
VALUES
(1,'Efectivo','TR001','2026-07-20',50);
DELETE FROM producto
WHERE codigo_producto='FR-1';
SET ROLE Administrativo;

DELETE FROM cliente
WHERE codigo_cliente=10;