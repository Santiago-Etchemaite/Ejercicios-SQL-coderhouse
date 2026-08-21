
-- SCRIPT DE PREPARACIÓN 

-- 1. Creación de tablas
CREATE TABLE categorias (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE productos (
    id SERIAL PRIMARY KEY,
    categoria_id INT REFERENCES categorias(id),
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE ventas (
    id SERIAL PRIMARY KEY,
    producto_id INT REFERENCES productos(id),
    fecha_venta DATE NOT NULL,
    monto NUMERIC(10, 2) NOT NULL
);

-- 2. Población de datos (Mock data)
INSERT INTO categorias (nombre) VALUES ('Electrónica'), ('Hogar'), ('Indumentaria');

INSERT INTO productos (categoria_id, nombre) VALUES 
(1, 'Smartphone'), (1, 'Laptop'), 
(2, 'Sofá'), (2, 'Lámpara'), 
(3, 'Camiseta'), (3, 'Pantalón');

-- Ventas distribuidas en 3 meses distintos para probar las Window Functions
INSERT INTO ventas (producto_id, fecha_venta, monto) VALUES
-- Enero
(1, '2024-01-10', 1500.00), (3, '2024-01-15', 800.00), (5, '2024-01-20', 200.00),
(2, '2024-01-25', 2000.00),
-- Febrero
(1, '2024-02-05', 1600.00), (4, '2024-02-12', 150.00), (6, '2024-02-18', 350.00),
(5, '2024-02-22', 250.00),
-- Marzo
(2, '2024-03-05', 2100.00), (3, '2024-03-10', 850.00), (6, '2024-03-15', 400.00),
(1, '2024-03-25', 1400.00);


-- Análisis avanzado de ventas usando CTEs y Window Functions.
-- CTE 1: ventas_mensuales
-- Propósito: Limpiar las fechas, normalizarlas por mes y agrupar las ventas por categoría.
WITH ventas_mensuales AS (
    SELECT 
        DATE_TRUNC('month', v.fecha_venta)::DATE AS mes, -- Normaliza la fecha al primer día del mes
        c.nombre AS categoria,
        SUM(v.monto) AS total_ventas
    FROM ventas v
    JOIN productos p ON v.producto_id = p.id
    JOIN categorias c ON p.categoria_id = c.id
    GROUP BY 
        DATE_TRUNC('month', v.fecha_venta)::DATE, 
        c.nombre
),

-- CTE 2: metricas_ventana
-- Propósito: Calcular rankings, acumulados y el promedio histórico utilizando Window Functions.
metricas_ventana AS (
    SELECT 
        mes,
        categoria,
        total_ventas,
        
        -- Ranking: Posición de la categoría dentro del mismo mes (el 1 es el que más vendió)
        RANK() OVER (PARTITION BY mes ORDER BY total_ventas DESC) AS ranking_mes,
        
        -- Acumulado (Running Total): Suma progresiva de ventas por categoría a lo largo de los meses
        SUM(total_ventas) OVER (PARTITION BY categoria ORDER BY mes) AS acumulado_categoria,
        
        -- Promedio histórico: Promedio de ventas de la categoría sin importar el mes
        -- (Se usará luego para la comparativa)
        AVG(total_ventas) OVER (PARTITION BY categoria) AS promedio_historico_categoria

    FROM ventas_mensuales
)


-- CONSULTA FINAL
-- Propósito: Traer los datos calculados y agregar la lógica de negocio condicional.
SELECT 
    mes AS "Mes de la Venta",
    categoria AS "Categoría del Producto",
    total_ventas AS "Venta Total del Mes",
    ranking_mes AS "Ranking del Mes",
    acumulado_categoria AS "Ventas Acumuladas",
    
	-- Agregamos el promedio a la vista para dar chequear que no haya errores
    ROUND(promedio_historico_categoria, 2) AS "Promedio Histórico",
    
    -- Comparativa usando CASE WHEN
    CASE 
        WHEN total_ventas > promedio_historico_categoria THEN 'Exitoso (Por encima del promedio)'
        WHEN total_ventas < promedio_historico_categoria THEN 'Bajo el promedio'
        ELSE 'Igual al promedio'
    END AS "Desempeño vs Promedio Histórico"
    
FROM metricas_ventana
ORDER BY 
    mes ASC, 
    ranking_mes ASC;