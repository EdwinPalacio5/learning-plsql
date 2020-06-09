-- Procedimientos

-- Sintaxis

/*
    CREATE [OR REPLACE] PROCEDURE procedure_name
        [(argument1 [mode1] datatype1,
          argument2 [mode2] datatype2,
        . . .)]
    IS|AS
    procedure_body;
    
*/

-- Ejemplo 

--creamos procedimiento
CREATE OR REPLACE PROCEDURE p_show_message
    (v_message  varchar2) -- parametros
    IS
    v_message_date  DATE := sysdate;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Message: ' 
                          || v_message 
                          || ' Fecha: ' 
                          || v_message_date);
END;
/
-- finde creacion de procedimiento


-- invocamos procedimiento en un bloque anonimo y le pasamos por parametro
BEGIN
    p_show_message('Este es un mensaje creado mediante un storage procedure ');
END;


/*
Resultado: 

    Procedure P_SHOW_MESSAGE compilado
    
    Message: Este es un mensaje creado mediante un storage procedure  Fecha: 08/06/20
    
    Procedimiento PL/SQL terminado correctamente.
*/
