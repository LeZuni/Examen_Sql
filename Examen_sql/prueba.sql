-- Función: fn_CalcularRentabilidadProducto
-- Descripción: Calcula la rentabilidad total de compras de un producto 
--              restando su costo actual al precio unitario o congelacion de venta.

DELIMITER $$

CREATE FUNCTION fn_CalcularRentabilidadProducto (
    p_id_producto INT UNSIGNED
)
RETURNS DECIMAL(14, 2) --En MySQL RETURNS DECIMAL se utiliza en la definición de una función para especificar el tipo de dato que la función devolverá como resultado. 
DETERMINISTIC  --es una palabra clave que se utiliza al crear funciones en MySQL para indicar que la función siempre devuelve el mismo resultado cuando se le proporcionan los mismos argumentos. En otras palabras, una función marcada como DETERMINISTIC no depende de factores externos o del estado de la base de datos que puedan cambiar entre llamadas, como datos en tablas que podrían ser modificados por otras transacciones.

READS SQL DATA
BEGIN
    DECLARE v_rentabilidad_total DECIMAL(14, 2);

    -- Esta calcula la ganancia sumando el precio_unitario_congelado - costo) * cantidad
    SELECT 
        COALESCE(SUM((dv.precio_unitario_congelado - p.costo) * dv.cantidad), 0.00) --En MySQL COALESCE se utiliza para manejar valores nulos (NULL) en las consultas. Su propósito principal es devolver el primer valor no nulo de una lista de expresiones. Si todas las expresiones son nulas, COALESCE devolverá NULL.
    INTO 
        v_rentabilidad_total
    FROM detalle_ventas dv
    INNER JOIN productos p ON dv.id_producto = p.id_producto
    WHERE dv.id_producto = p_id_producto;

    RETURN v_rentabilidad_total;
END$$

DELIMITER ;


SELECT 
    p.id_producto,
    p.nombre,
    p.costo,
    p.precio AS precio_actual,
    fn_CalcularRentabilidadProducto(p.id_producto) AS rentabilidad_acumulada
FROM productos p
ORDER BY rentabilidad_acumulada DESC;


--Ejemplo de uso 

--Para probar la función y obtener la rentabilidad de un producto específico (por ejemplo, con ID 1), ejecuta:

SELECT fn_CalcularRentabilidadProducto(1) AS rentabilidad_total;


--Puntos clave de la implementación:

    --Atiende : Utiliza precio_unitario_congelado de detalle_ventas para reflejar con precisión el valor que se vendió por unidad.

    --Tratamiento de NULL: Se utiliza COALESCE(..., 0.00) para que, en caso de que un producto no tenga ventas registradas aún, retorne 0.00 en lugar de NULL.

    --Compatibilidad con MySQL: Incluye las cláusulas DETERMINISTIC y READS SQL DATA requeridas por MySQL al crear funciones que realizan consultas SELECT.
