-- Funciones

SET SERVEROUTPUT ON;
/*
Sintaxis:

CREATE [OR REPLACE] FUNCTION function_name
    [(argument1 [mode1] datatype1,
    argument2 [mode2] datatype2,
    . . .)]
RETURN datatype
IS|AS
function_body;

*/

-- Ejemplo: Crearemos un funcion la cual permita calcular el ISSS de un empleado
CREATE OR REPLACE FUNCTION calcular_isss
    (p_salary   employees.salary%TYPE) --parametro
    
    RETURN  employees.salary%TYPE -- return
    IS
    -- variables y/o constantes
    c_porcentaje_isss   CONSTANT NUMBER(9,2) := 0.03;               
    c_monto_maximo      CONSTANT employees.salary%TYPE := 1000;
    v_monto_isss        employees.salary%TYPE := 0;
BEGIN
    IF p_salary IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'El salario no es valido, tiene valor null');
    ELSE
        IF p_salary > c_monto_maximo THEN
            v_monto_isss := c_monto_maximo*c_porcentaje_isss;
        ELSE
            v_monto_isss := p_salary*c_porcentaje_isss;
        END IF;
    END IF;  
    RETURN v_monto_isss;
END;
/  
-- Invocamos la funcion mediante el siguiente bloque anonimo
BEGIN
    dbms_output.put_line('El calculo del ISSS es: $' || calcular_isss(100));
END;