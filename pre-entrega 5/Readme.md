# Análisis Avanzado de Ventas con SQL

Este repositorio contiene la pre-entrega del curso de SQL. El objetivo es aplicar CTEs (Common Table Expressions), Window Functions y lógica condicional sobre un dataset de ventas en PostgreSQL.

## 🛠️ ¿Qué incluye el script?
1. **Creación de Entorno (DDL / DML):** Genera la base de datos, tablas relacionales (`categorias`, `productos`, `ventas`) y datos de prueba distribuidos en varios meses.
2. **CTE `ventas_mensuales`:** Normaliza las fechas por mes utilizando `DATE_TRUNC` y agrupa las ventas totales por categoría.
3. **CTE `metricas_ventana`:** Aplica funciones de ventana avanzadas:
   - `RANK()` para obtener el ranking de categorías por mes.
   - `SUM() OVER` para calcular el acumulado histórico (*Running Total*).
   - `AVG() OVER` para obtener el promedio de ventas por categoría.
4. **Consulta Final:** Integra un `CASE WHEN` para evaluar el desempeño mensual frente al promedio histórico ("Exitoso" o "Bajo el promedio").

## 🚀 ¿Cómo ejecutarlo?
1. Abre tu gestor de PostgreSQL (pgAdmin o DBeaver).
2. Ejecuta el bloque inicial para crear y conectarte a la base de datos `analisis_ventas_db`.
3. Ejecuta el resto del script de corrido para crear las tablas, insertar los datos de prueba y visualizar el reporte final.

