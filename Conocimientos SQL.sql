--CREACIÓN DE ESQUEMA Y OTORGAR TODOS LOS PERMISOS
CREATE USER ESQUEMA1 IDENTIFIED BY "PASSWORD";
ALTER USER ESQUEMA1 QUOTA UNLIMITED ON SYSTEM;
GRANT ALL PRIVILEGES TO ESQUEMA1;

--Otorgar el privilegio REFERENCES en todas las tablas de ESQUEMA1 al esquema ESQUEMA2
BEGIN
    FOR t IN (SELECT table_name FROM all_tables WHERE owner = 'ESQUEMA1') LOOP
    EXECUTE IMMEDIATE 'GRANT REFERENCES ON ESQUEMA1.' || t.table_name || ' TO ESQUEMA2';
    END LOOP;
END;

--Creación de Tabla QUOTES(Maestro) y QUOTE_ITEMS(DETALLE)
CREATE TABLE QUOTES(
    QUOTE_ID NUMBER PRIMARY KEY,
    CUSTOMER_ID NUMBER CONSTRAINT FK_QUOTES_CUSTOMER_ID REFERENCES CUSTOMERS,
    EMPLOYEE_ID NUMBER CONSTRAINT FK_QUOTES_EMPLOYEE_ID REFERENCES EMPLOYEES,
    CREATED TIMESTAMP NOT NULL,
    CREATED_BY VARCHAR2(255 CHAR) NOT NULL,
    UPDATED TIMESTAMP NOT NULL,
    UPDATED_BY VARCHAR2(255 CHAR) NOT NULL
);

CREATE TABLE QUOTE_ITEMS(
    QUOTE_ITEM_ID NUMBER PRIMARY KEY,
    QUOTE_ID NUMBER CONSTRAINT FK_QUOTE_ITEMS_QUOTE_ID REFERENCES QUOTES,
    PRODUCT_ID NUMBER CONSTRAINT FK_QUOTE_ITEMS_PRODUCT_ID REFERENCES PRODUCTS,
    QUANTITY NUMBER,
    PRICE NUMBER,
    CREATED TIMESTAMP NOT NULL,
    CREATED_BY VARCHAR2(255 CHAR) NOT NULL,
    UPDATED TIMESTAMP NOT NULL,
    UPDATED_BY VARCHAR2(255 CHAR) NOT NULL
)

-- Creación de Trigger para auditoría en tablas y en aplicación de Oracle APEX
-- Quién y cuándo hizo una inserción
-- Quién y cuándo hizo una actualización
create or replace trigger quotes_biu
    before insert or update 
    on quotes
    for each row
begin
    if inserting then
        :new.created := systimestamp;
        :new.created_by := coalesce(sys_context('APEX$SESSION','APP_USER'),user);
    end if;
    :new.updated := systimestamp;
    :new.updated_by := coalesce(sys_context('APEX$SESSION','APP_USER'),user);
end quotes_biu;
/

--Consultas con join
SELECT
    Q.QUOTE_ID,
    QI.QUOTE_ITEM_ID,
    QI.PRODUCT_ID
FROM QUOTES Q
INNER JOIN QUOTE_ITEMS QI ON Q.QUOTE_ID = QI.QUOTE_ID;