--NOMBRES                                    CARNET
--Alfredo Joselito Vicente Garcia          1490-22-13637
--Kevin Fernando Ambrocio Alvarez          1490-22-11527
--Kevin Eduardo Coxaj Ixcayau              1490-22-18758
--Beatriz Vicente Jiménez                  1490-16-2739
--José Manuel Coxaj Pelicó                 1490-22-11545

--QUERY PARA MOSTRAR INFORMACIÓN DE LOS CLIENTES
SELECT C.CLIENTE_ID,
       TC.NOMBRE,
       C.DPI,
       C.NIT,
       RTRIM(NVL2(C.PRIMER_NOMBRE,C.PRIMER_NOMBRE||' ','')||
       NVL2(C.SEGUNDO_NOMBRE,C.SEGUNDO_NOMBRE||' ','')||
       NVL2(C.TERCER_NOMBRE,C.TERCER_NOMBRE||' ','') ||
       NVL2(C.PRIMER_APELLIDO,C.PRIMER_APELLIDO||' ','')||
       NVL2(C.SEGUNDO_APELLIDO,C.SEGUNDO_APELLIDO||' ','')||
       NVL2(C.APELLIDO_CASADA,C.APELLIDO_CASADA||' ','')) AS NOMBRE_COMPLETO,
       C.EMAIL,
       C.TELEFONO,
       CASE C.GENERO
       WHEN 'M' THEN 'Masculino'
       WHEN 'F' THEN 'Femenino' END AS GENERO
  FROM CLIENTES C
  INNER JOIN TIPOS_CLIENTES TC ON C.TIPO_CLIENTE_ID = TC.TIPO_CLIENTE_ID

--QUERY PARA MOSTRAR LA INFORMACIÓN DE LAS FACTURAS O VENTAS QUE SE REALIZAN
--Y EN CASO DE QUE SE SELECCIONE ALGUNA OPCIÓN PARA FILTRAR, ESTA SE APLICA
DECLARE
    l_filter varchar2(100 CHAR) := '';
    l_order_by varchar2(50 CHAR) := ' ORDER BY F.UPDATED DESC';
BEGIN

IF :P4_ESTADOS IS NOT NULL THEN
    l_filter := ' WHERE F.FACTURA_ESTADO_ID = :P4_ESTADOS ';
END IF;

return q'~
SELECT
    F.FACTURA_ID,
    RTRIM(
        NVL2(C.PRIMER_NOMBRE,C.PRIMER_NOMBRE||' ','')||
        NVL2(C.SEGUNDO_NOMBRE,C.SEGUNDO_NOMBRE||' ','')||
        NVL2(C.TERCER_NOMBRE,C.TERCER_NOMBRE||' ','')||
        NVL2(C.PRIMER_APELLIDO,C.PRIMER_APELLIDO||' ','')||
        NVL2(C.SEGUNDO_APELLIDO,C.SEGUNDO_APELLIDO||' ','')||
        NVL2(C.APELLIDO_CASADA,C.APELLIDO_CASADA||' ','')
    ) AS NOMBRE_CLIENTE,
    C.NIT,
    RTRIM(
        NVL2(E.PRIMER_NOMBRE,E.PRIMER_NOMBRE||' ','')||
        NVL2(E.SEGUNDO_NOMBRE,E.SEGUNDO_NOMBRE||' ','')||
        NVL2(E.TERCER_NOMBRE,E.TERCER_NOMBRE||' ','')||
        NVL2(E.PRIMER_APELLIDO,E.PRIMER_APELLIDO||' ','')||
        NVL2(E.SEGUNDO_APELLIDO,E.SEGUNDO_APELLIDO||' ','')||
        NVL2(E.APELLIDO_CASADA,E.APELLIDO_CASADA||' ','')
    ) AS NOMBRE_EMPLEADO,
    TO_CHAR(F.FECHA,'DD/MM/YYYY') AS FECHA,
    FE.NOMBRE AS ESTADO_FACTURA,
    FT.NAME AS TIPO_FACTURA,
    CASE
    WHEN FE.IS_EDITABLE = 1 THEN
    '<button class="t-Button t-Button--icon t-Button--tinny" style="border: none; background: none;" type="button"
    onclick="editSale('||F.FACTURA_ID||','||C.CLIENTE_ID||')">
    <img src="#APEX_FILES#app_ui/img/icons/apex-edit-pencil.png" alt="Edit"
    style="width: 16px; height: 16px;"/>
    </button>'
    WHEN FE.IS_EDITABLE = 0 THEN '' END AS Editar
FROM FACTURAS F
LEFT JOIN CLIENTES C ON F.CLIENTE_ID = C.CLIENTE_ID
LEFT JOIN EMPLEADOS E ON F.EMPLEADO_ID = E.EMPLEADOS_ID
INNER JOIN FACTURA_ESTADOS FE ON F.FACTURA_ESTADO_ID = FE.FACTURA_ESTADO_ID
INNER JOIN FACTURA_TIPOS FT ON F.FACTURA_TIPO_ID = FT.FACTURA_TIPO_ID
~'||l_filter||l_order_by;
END;

--QUERY PARA CREAR UNA NUEVA FACTURA
BEGIN
INSERT INTO FACTURAS(EMPLEADO_ID, FECHA, FACTURA_TIPO_ID, FACTURA_ESTADO_ID)
VALUES(:P4_EMPLEADO, SYSDATE,1,1)
RETURNING FACTURA_ID INTO :P4_FACTURA_ID;
END;

--QUERIES PARA ELIMINAR UNA FACTURA
DELETE FROM FACTURA_DETALLES WHERE FACTURA_ID = :P5_FACTURA_ID AND FACTURA_ID IS NOT NULL;
DELETE FROM PAGOS WHERE FACTURA_ID = :P5_FACTURA_ID AND FACTURA_ID IS NOT NULL;
DELETE FROM FACTURAS WHERE FACTURA_ID = :P5_FACTURA_ID;
COMMIT;

--QUERY PARA ELIMINAR UN DETALLE EN LA FACTURA
--ADICIONALMENTE SE SETEA EL ESTADO DE LA FACTURA A CREADO
DELETE FROM FACTURA_DETALLES
WHERE FACTURA_DETALLE_ID = :P5_FACTURA_DETALLE_SELECCIONADO;

UPDATE FACTURAS
SET FACTURA_ESTADO_ID = 1
WHERE FACTURA_ID = :P5_FACTURA_ID;
COMMIT;

--QUERY PARA ACTUALIZAR EL ESTADO A FACTURADO
UPDATE FACTURAS
SET FACTURA_ESTADO_ID = 6
WHERE FACTURA_ID = :P5_FACTURA_ID;
COMMIT;

--QUERY PARA MOSTRAR LA INFORMACIÓN DE UN CLIENTE
SELECT 
    CLIENTE_ID,
    RTRIM(
        NVL2(PRIMER_NOMBRE,PRIMER_NOMBRE||' ','')||
        NVL2(SEGUNDO_NOMBRE,SEGUNDO_NOMBRE||' ','')||
        NVL2(TERCER_NOMBRE,TERCER_NOMBRE||' ','')||
        NVL2(PRIMER_APELLIDO,PRIMER_APELLIDO||' ','')||
        NVL2(SEGUNDO_APELLIDO,SEGUNDO_APELLIDO||' ','')||
        NVL2(APELLIDO_CASADA,APELLIDO_CASADA||' ','')
    ) AS FULLNAME,
    NIT
FROM CLIENTES;

--QUERY PARA ASIGNAR UN CLIENTE A UNA FACTURA
UPDATE FACTURAS
SET CLIENTE_ID = :P6_CLIENTE_SELECCIONADO
WHERE FACTURA_ID = :P6_FACTURA_ID;

--QUERY PARA MOSTRAR LOS PAGOS DE UNA FACTURA
SELECT
    PAGO_ID,
    FACTURA_ID,
    METODO_PAGO_ID,
    MONTO_PAGAR
FROM PAGOS
WHERE FACTURA_ID = :P7_FACTURA_ID;

--QUERY PARA MOSTRAR INFORMACIÓND DE PRODUCTOS
SELECT
    P.UPC,
    CP.NOMBRE AS CATEGORIA,
    P.NOMBRE AS PRODUCTO,
    P.PRECIO_VENTA,
    P.MARCA,
    P.MODELO,
    P.CANTIDAD AS STOCK
FROM PRODUCTOS P
INNER JOIN CATEGORIA_PRODUCTOS CP ON P.CATEGORIA_PRODUCTO_ID = CP.CATEGORIA_PRODUCTO_ID

--QUERY PARA VALIDAR EL STOCK DE INVENTARIO ANTES DE ASIGNAR UN PRODUCTO A UNA FACTURA
DECLARE
    v_validate_stock number;
    v_precio number;
    v_impuesto number;
    EX_CANTIDAD EXCEPTION;
BEGIN

SELECT CANTIDAD INTO v_validate_stock
FROM PRODUCTOS
WHERE UPC = :P8_UPC;

IF v_validate_stock > :P8_CANTIDAD THEN
    SELECT PRECIO_VENTA, ROUND((PRECIO_VENTA/1.12)*0.12,4)
    INTO v_precio, v_impuesto
    FROM PRODUCTOS
    WHERE UPC = :P8_UPC;

    v_precio := v_precio - v_impuesto;
    INSERT INTO FACTURA_DETALLES
    (FACTURA_ID,UPC,CANTIDAD,PRECIO,IMPUESTO)
    VALUES (:P8_FACTURA_ID, :P8_UPC, :P8_CANTIDAD,v_precio,v_impuesto)
    RETURNING FACTURA_DETALLE_ID INTO :P8_FACTURA_DETALLE_ID;

    UPDATE FACTURAS
    SET FACTURA_ESTADO_ID = 1
    WHERE FACTURA_ID = :P8_FACTURA_ID;
    COMMIT;
ELSE
    RAISE EX_CANTIDAD;
END IF;

EXCEPTION
WHEN EX_CANTIDAD THEN
    ROLLBACK;
    apex_error.add_error(
    p_message           =>'La cantidad no debe ser mayor a la cantidad en stock',
    p_display_location  => apex_error.c_inline_in_notification,
    p_page_item_name    => 'P8_CANTIDAD'
);       
END;

--QUERY PARA MOSTRAR LA INFORMACIÓN DE LOS EMPLEADOS
SELECT E.EMPLEADOS_ID,
       D.NOMBRE_DEPARTAMENTO,
       E.DPI,
       E.NIT,
       RTRIM(NVL2(E.PRIMER_NOMBRE,E.PRIMER_NOMBRE||' ','')||
       NVL2(E.SEGUNDO_NOMBRE,E.SEGUNDO_NOMBRE||' ','')||
       NVL2(E.TERCER_NOMBRE,E.TERCER_NOMBRE||' ','')) AS NOMBRES,
       RTRIM(NVL2(E.PRIMER_APELLIDO,E.PRIMER_APELLIDO||' ','')||
       NVL2(E.SEGUNDO_APELLIDO,E.SEGUNDO_APELLIDO||' ','')||
       NVL2(E.APELLIDO_CASADA,E.APELLIDO_CASADA||' ','')) AS APELLIDOS,
       E.CORREO_ELECTRONICO,
       E.FECHA_CONTRATACION,
       E.FECHA_NACIMIENTO,
       E.TELEFONO
FROM EMPLEADOS E
INNER JOIN DEPARTAMENTOS D ON E.DEPARTAMENTO_ID = D.DEPARTAMENTO_ID

--QUERY PARA MOSTRAR LAS CATEGORÍAS DE PRODUCTOS
SELECT
    CATEGORIA_PRODUCTO_ID,
    NOMBRE,
    DESCRIPCION
FROM CATEGORIA_PRODUCTOS;

--QUERY PARA MOSTRAR LA INFORMACIÓN DE PROVEEDORES
SELECT
    PROVEEDOR_ID,
    NOMBRE,
    TELEFONO,
    EMAIL,
    DESCRIPCION,
    TIPO_PROVEEDOR,
    FECHA_REGISTRO,
    ESTADO
FROM PROVEEDORES;

