
-- Pre - Entrega MODULO 5
-- Base de datos: Ventas_Tech_DB


-- IMPORTANTE: PASO PREVIO A LAS CONSULTAS:
-- Primero se crean nuevas tablas necesarias en esta BD para la correcta solucion del enunciado.
-- Las tablas a crear son: "canales" y "segmentos", datos que pide el enunciado para la consulta n°1
-- que no se encuentran en la BD de Ventas_tech, por otro lado, el dato de "territorio" que tambien
-- pide el enunciado en la primer consulta no tendra una propia tabla, será reemplazado por el registro
-- de la columna "ciudad" en la tabla de clientes.

-- Tabla de canales de venta
CREATE TABLE canales (
    id_canal INT PRIMARY KEY,
    canal VARCHAR(20) NOT NULL UNIQUE
);

-- Registros de canales
INSERT INTO canales (id_canal, canal)
VALUES
    (1, 'online'),
    (2, 'presencial');


-- Tabla de segmentos de clientes
CREATE TABLE segmentos (
    id_segmento INT PRIMARY KEY,
    segmento VARCHAR(20) NOT NULL UNIQUE
);

-- Registros de segmentos
INSERT INTO segmentos (id_segmento, segmento)
VALUES
    (1, 'particular'),
    (2, 'pyme'),
    (3, 'corporativo');


-- Verificación de los registros cargados
SELECT *
FROM canales
ORDER BY id_canal;

SELECT *
FROM segmentos
ORDER BY id_segmento;



-- PASO 2: Relacionar nuevas tablas con las existentes
-- Agrego las columnas que funcionarán como claves foráneas
ALTER TABLE clientes
    ADD COLUMN id_segmento INT;

ALTER TABLE ventas
    ADD COLUMN id_canal INT;

-- En este caso yo voy a clasificar a todos los clientes dentro del segmento "Particular"
-- y a todas las ventas dentro del canal "Online"

UPDATE clientes
SET id_segmento = 1;

UPDATE ventas
SET id_canal = 1;

-- Creo las relaciones mediante forgein keys
ALTER TABLE clientes
    ADD CONSTRAINT fk_clientes_segmentos
    FOREIGN KEY (id_segmento)
    REFERENCES segmentos (id_segmento);

ALTER TABLE ventas
    ADD CONSTRAINT fk_ventas_canales
    FOREIGN KEY (id_canal)
    REFERENCES canales (id_canal);
	

-- Verificacion de clientes y segmentos:
SELECT
    c.id_cliente,
    c.nombre,
    c.ciudad,
    c.id_segmento,
    s.segmento
FROM clientes AS c
INNER JOIN segmentos AS s
    ON c.id_segmento = s.id_segmento
ORDER BY c.id_cliente;

-- Verificacion de ventas y canales:
SELECT
    v.id_venta,
    v.fecha_venta,
    v.id_cliente,
    v.id_producto,
    v.id_canal,
    ca.canal
FROM ventas AS v
INNER JOIN canales AS ca
    ON v.id_canal = ca.id_canal
ORDER BY v.id_venta;

-- Una vez verificadas las nuevas tablas, relaciones y registros correctamente se puede
-- avanzar hacia la primer consulta...

-- --------------------------------------------------------

-- CONSULTA 1: VISTA BASE DEL PROYECTO (INNER JOIN)
-- Se utiliza la ciudad del cliente como región, ya que Ventas_Tech_DB
-- no contiene una tabla de territorios.
-- Esta consulta integra la información de ventas, clientes, segmentos,
-- productos, categorías y canales para generar la fuente principal de Power BI.

SELECT
    v.fecha_venta AS fecha,
    c.nombre AS nombre_cliente,
    s.segmento,
    c.ciudad AS region,
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario AS total_venta,
    ca.canal
FROM ventas AS v
INNER JOIN clientes AS c
    ON v.id_cliente = c.id_cliente
INNER JOIN segmentos AS s
    ON c.id_segmento = s.id_segmento
INNER JOIN productos AS p
    ON v.id_producto = p.id_producto
INNER JOIN categorias AS cat
    ON p.id_categoria = cat.id_categoria
INNER JOIN canales AS ca
    ON v.id_canal = ca.id_canal
ORDER BY
    v.fecha_venta,
    v.id_venta;

-- -----------------------------------------------

-- CONSULTA 2: CLIENTES SIN VENTAS (LEFT JOIN)
-- Se conservan todos los clientes y se identifican aquellos que no tienen
-- ninguna venta asociada mediante WHERE v.id_venta IS NULL.

SELECT
    c.nombre AS nombre_cliente,
    c.email,
    c.fecha_registro
FROM clientes AS c
LEFT JOIN ventas AS v
    ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL
ORDER BY
    c.fecha_registro,
    c.nombre;

-- Esta consulta da como resultado que todos los 5 clientes tienen al menos una venta asociada, 
-- lo cual es correcto ya que cada cliente tiene 2 ventas asociadas.

-- --------------------------------------------

-- CONSULTA 3: PRODUCTOS SIN VENTAS (LEFT JOIN)
-- Se conservan todos los productos del catálogo y se identifican aquellos
-- que no tienen ninguna venta asociada mediante WHERE v.id_venta IS NULL.

SELECT
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM productos AS p
INNER JOIN categorias AS cat
    ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas AS v
    ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL
ORDER BY
    cat.nombre_categoria,
    p.nombre_producto;
	
-- Esta consulta da como resultado que todos los productos del catálogo estan  
-- asociados a al menos una venta

-- ----------------------------------------------------

-- CONSULTA 4: CONSOLIDADO DE VENTAS POR CANAL (UNION ALL)
-- Se separan las ventas online y presenciales, se combinan mediante UNION ALL
-- y finalmente se calcula la facturación total de cada canal.

WITH ventas_consolidadas AS (

    -- Ventas realizadas por el canal online
    SELECT
        v.id_venta,
        v.fecha_venta,
        v.cantidad * v.precio_unitario AS total_venta,
        'online' AS canal
    FROM ventas AS v
    INNER JOIN canales AS ca
        ON v.id_canal = ca.id_canal
    WHERE ca.canal = 'online'

    UNION ALL

-- Ventas realizadas por el canal presencial
	SELECT
        v.id_venta,
        v.fecha_venta,
        v.cantidad * v.precio_unitario AS total_venta,
        'presencial' AS canal
    FROM ventas AS v
    INNER JOIN canales AS ca
        ON v.id_canal = ca.id_canal
    WHERE ca.canal = 'presencial'
)

SELECT
    canal,
    SUM(total_venta) AS total_por_canal
FROM ventas_consolidadas
GROUP BY canal
ORDER BY canal;

-- Esta consulta da como resultado que el canal "online" tuvo un total de 6444.00
-- facturado en ventas, es decir el 100%, ya que como mencioné anteriormente
-- en este caso clasifiqué todas las ventas como hechas por canal online
