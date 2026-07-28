
-- PRE-ENTREGA MÓDULO 4
----------------------------------------------

-- Consulta 1: Resumen ejecutivo mensual

SELECT
    EXTRACT(MONTH FROM fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY EXTRACT(MONTH FROM fecha_venta)
ORDER BY mes;


-- Consulta 2: Ranking de productos

SELECT
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC
LIMIT 5;


-- Consulta 3: Clientes recurrentes

SELECT
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;


-- Consulta 4: Meses por encima o por debajo del promedio

WITH facturacion_mensual AS (
    SELECT
        EXTRACT(MONTH FROM fecha_venta) AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY EXTRACT(MONTH FROM fecha_venta)
)
SELECT
    mes,
    total_facturado,
    CASE
        WHEN total_facturado > (
            SELECT AVG(total_facturado)
            FROM facturacion_mensual
        ) THEN 'MAYOR AL PROMEDIO'

        WHEN total_facturado < (
            SELECT AVG(total_facturado)
            FROM facturacion_mensual
        ) THEN 'MENOR AL PROMEDIO'

        ELSE 'IGUAL AL PROMEDIO'
    END AS comparacion_promedio
FROM facturacion_mensual
ORDER BY mes;

-- En esta consigna me quedó la duda de si deberia tener registros de ventas basadas 
-- en meses anteriores para comparar los promedios, ya que al tener registros solamente
-- de marzo no puedo hacer una comparacion real y el resultado obviamente va a dar
-- siempre "IGUAL AL PROMEDIO"




-- HALLAZGOS:

-- 1) En marzo se registraron 10 pedidos, con una facturación total
--   de $6.444 y un ticket promedio de $644,40.

-- 2) El producto con ID 1 fue el de mayor facturación: generó $3.600,
--   equivalentes al 55,87% de la facturación total, con solo 3 unidades vendidas.

-- 3) El producto con ID 2 fue el de mayor volumen, con 13 unidades vendidas,
--    pero generó solamente $364. Esto demuestra que una mayor cantidad
--    de unidades vendidas no necesariamente implica una mayor facturación.

-- 4) Los productos con ID 1 y 3 generaron conjuntamente $4.950,
--    lo que representa el 76,82% de la facturación total.

-- 5) Los clientes con ID 1 y 5 concentraron $4.740 en compras,
--    equivalentes al 73,56% de la facturación total.