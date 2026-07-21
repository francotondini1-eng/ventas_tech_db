
-- SECCION 1: DEFINICION DEL ESQUEMA (DDL)
-- Eliminar primero las tablas dependientes y luego las tablas referenciadas.

DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS categorias;

CREATE TABLE categorias (
    id_categoria      INT          PRIMARY KEY,
    nombre_categoria  VARCHAR(50)  NOT NULL,
    descripcion       VARCHAR(200)
);

CREATE TABLE clientes (
    id_cliente      INT           PRIMARY KEY,
    nombre          VARCHAR(100)  NOT NULL,
    email           VARCHAR(100)  UNIQUE,
    ciudad          VARCHAR(50),
    fecha_registro  DATE          NOT NULL
);

CREATE TABLE productos (
    id_producto     INT            PRIMARY KEY,
    nombre_producto VARCHAR(100)   NOT NULL,
    id_categoria    INT            NOT NULL,
    precio          DECIMAL(10,2)  NOT NULL,
    stock           INT            DEFAULT 0,
    activo          SMALLINT       DEFAULT 1
);

CREATE TABLE ventas (
    id_venta         INT            PRIMARY KEY,
    id_cliente       INT            NOT NULL,
    id_producto      INT            NOT NULL,
    cantidad         INT            NOT NULL,
    precio_unitario  DECIMAL(10,2)  NOT NULL,
    fecha_venta      DATE           NOT NULL
);



-- SECCION 2: RESTRICCIONES DE INTEGRIDAD

-- Clave foranea: cada producto debe referenciar una categoria existente.
ALTER TABLE productos
    ADD CONSTRAINT fk_productos_categorias
    FOREIGN KEY (id_categoria)
    REFERENCES categorias (id_categoria);

-- Claves foraneas: cada venta solo puede referenciar clientes y productos previamente registrados.
ALTER TABLE ventas
    ADD CONSTRAINT fk_ventas_clientes
    FOREIGN KEY (id_cliente)
    REFERENCES clientes (id_cliente);

ALTER TABLE ventas
    ADD CONSTRAINT fk_ventas_productos
    FOREIGN KEY (id_producto)
    REFERENCES productos (id_producto);

-- Controles adicionales de consistencia para cantidades, importes y estados.
ALTER TABLE productos
    ADD CONSTRAINT chk_productos_precio
        CHECK (precio >= 0),
    ADD CONSTRAINT chk_productos_stock
        CHECK (stock >= 0),
    ADD CONSTRAINT chk_productos_activo
        CHECK (activo IN (0, 1));

ALTER TABLE ventas
    ADD CONSTRAINT chk_ventas_cantidad
        CHECK (cantidad > 0),
    ADD CONSTRAINT chk_ventas_precio_unitario
        CHECK (precio_unitario >= 0);



-- SECCION 3: CARGA INICIAL DE LOS DATOS (DML) Y VALIDACION

-- 3.1 Categorias: tabla independiente.
INSERT INTO categorias (id_categoria, nombre_categoria, descripcion)
VALUES
    (1, 'Computación',    'Laptops, PCs y monitores'),
    (2, 'Accesorios',     'Periféricos y complementos'),
    (3, 'Audio',          'Auriculares y parlantes'),
    (4, 'Almacenamiento', 'Discos y memorias');

-- 3.2 Clientes: tabla independiente.
INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro)
VALUES
    (1, 'María López',  'maria@mail.com',  'Buenos Aires', DATE '2024-01-05'),
    (2, 'Carlos Ruiz',  'carlos@mail.com', 'Córdoba',      DATE '2024-01-10'),
    (3, 'Ana Gómez',    'ana@mail.com',    'Rosario',      DATE '2024-02-01'),
    (4, 'Pedro Sanz',   'pedro@mail.com',  'Mendoza',      DATE '2024-02-15'),
    (5, 'Laura Torres', 'laura@mail.com',  'Tucumán',      DATE '2024-03-01');

-- 3.3 Productos: se cargan despues de categorias por su clave foranea.
INSERT INTO productos
    (id_producto, nombre_producto, id_categoria, precio, stock, activo)
VALUES
    (1, 'Laptop Pro 15',      1, 1200.00, 15, 1),
    (2, 'Mouse Inalámbrico',  2,   28.00, 80, 1),
    (3, 'Monitor 4K 27"',     1,  450.00, 12, 1),
    (4, 'Auriculares BT Pro', 3,  120.00, 35, 1),
    (5, 'SSD Externo 1TB',    4,  130.00, 18, 1),
    (6, 'Teclado Mecánico',   2,   95.00, 40, 1);

-- 3.4 Ventas: se cargan al final porque dependen de clientes y productos.
INSERT INTO ventas
    (id_venta, id_cliente, id_producto, cantidad, precio_unitario, fecha_venta)
VALUES
    (1,  1, 1, 2, 1200.00, DATE '2024-03-05'),
    (2,  2, 2, 5,   28.00, DATE '2024-03-06'),
    (3,  3, 3, 1,  450.00, DATE '2024-03-07'),
    (4,  1, 4, 2,  120.00, DATE '2024-03-08'),
    (5,  4, 5, 3,  130.00, DATE '2024-03-10'),
    (6,  2, 6, 4,   95.00, DATE '2024-03-11'),
    (7,  5, 1, 1, 1200.00, DATE '2024-03-12'),
    (8,  3, 2, 8,   28.00, DATE '2024-03-13'),
    (9,  4, 4, 1,  120.00, DATE '2024-03-14'),
    (10, 5, 3, 2,  450.00, DATE '2024-03-15');


-- 3.5 Consultas de validacion solicitadas.
SELECT * FROM categorias ORDER BY id_categoria;
SELECT * FROM clientes ORDER BY id_cliente;
SELECT * FROM productos ORDER BY id_producto;
SELECT * FROM ventas ORDER BY id_venta;

-- Debe devolver exactamente 10.
SELECT COUNT(*) AS total_ventas
FROM ventas;

-- Comprobacion adicional de las relaciones: debe devolver 10 filas completas.
SELECT
    v.id_venta,
    v.fecha_venta,
    c.nombre AS cliente,
    p.nombre_producto AS producto,
    cat.nombre_categoria AS categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario AS total_venta
FROM ventas AS v
INNER JOIN clientes AS c
    ON c.id_cliente = v.id_cliente
INNER JOIN productos AS p
    ON p.id_producto = v.id_producto
INNER JOIN categorias AS cat
    ON cat.id_categoria = p.id_categoria
ORDER BY v.id_venta;