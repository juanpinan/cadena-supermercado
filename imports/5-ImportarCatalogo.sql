/*

Entrega 4 - Grupo 10 - Pi�an, Monardo, Matter, Natario

"
Se requiere que importe toda la informaci�n antes mencionada a la base de datos:
� Genere los objetos necesarios (store procedures, funciones, etc.) para importar los
archivos antes mencionados. Tenga en cuenta que cada mes se recibir�n archivos de
novedades con la misma estructura, pero datos nuevos para agregar a cada maestro.
� Considere este comportamiento al generar el c�digo. Debe admitir la importaci�n de
novedades peri�dicamente.
� Cada maestro debe importarse con un SP distinto. No se aceptar�n scripts que
realicen tareas por fuera de un SP.
� La estructura/esquema de las tablas a generar ser� decisi�n suya. Puede que deba
realizar procesos de transformaci�n sobre los maestros recibidos para adaptarlos a la
estructura requerida.
� Los archivos CSV/JSON no deben modificarse. En caso de que haya datos mal
cargados, incompletos, err�neos, etc., deber� contemplarlo y realizar las correcciones
en el fuente SQL. (Ser�a una excepci�n si el archivo est� malformado y no es posible
interpretarlo como JSON o CSV). 

"

*/

GO
USE Com2900G10;
GO

-- SP para la importar datos de clasificacion de productos
GO
CREATE OR ALTER PROCEDURE ImportarCatalogo
AS
BEGIN
	CREATE TABLE #importacion_catalogo(id INT, categoria VARCHAR(200), nombre VARCHAR(200), precio DECIMAL(6,2), precio_referencia DECIMAL(6,2), unidad_referencia VARCHAR(10), fecha DATETIME)

	-- subo los datos en crudo
	BULK INSERT #importacion_catalogo
    FROM 'C:\Users\lucas\OneDrive\Escritorio\repositories\unlam-bdda-supermercado\DataFiles\Productos\catalogo.csv'
    WITH
    (
		FIRSTROW = 2,
		 CODEPAGE = '65001',
		FIELDTERMINATOR = ',',  --CSV field delimiter
		ROWTERMINATOR = '\n',   --Use to shift the control to next row
        FORMAT = 'CSV',
        FIELDQUOTE = '"',
		TABLOCK
    )

	-- Sanitizo
	UPDATE #importacion_catalogo SET categoria = importacion.sanitizar_y_reemplazar(categoria,'');

	-- Agrego una columna para cruzar los ID de cateogira
	ALTER TABLE #importacion_catalogo ADD id_categoria SMALLINT;
	
	-- Actualizo el ID de Categoria
	UPDATE i 
	SET i.id_categoria = c.id_categoria_producto
	FROM #importacion_catalogo i
		INNER JOIN producto.categoria_producto c ON c.nombre_categoria = i.categoria

	-- Inserto los productos validando de no repetir nombre
	INSERT INTO producto.producto(id_categoria_producto, nombre_producto, precio_unitario, moneda)
	SELECT i.id_categoria, i.nombre, i.precio, 'ARS'
	FROM #importacion_catalogo i
		LEFT JOIN producto.producto p ON i.nombre = p.nombre_producto
	WHERE p.id_producto IS NULL

	
END;

/* SELECT * FROM producto.producto;
DELETE FROM producto.producto
EXEC ImportarCatalogo;
SELECT * FROM producto.producto; */
