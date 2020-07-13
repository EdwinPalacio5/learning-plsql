-- Estructuras de Control en bloque PLSQL

SET SERVEROUTPUT ON;

-- IF - THEN - ELSIF - ELSE - END IF

-- Sintaxis

/*
    IF  condition THEN
        statements;
    [ELSIF  condition THEN
        statements;]
    [ELSE
        statements;]
    END IF;
*/

-- Ejemplo
DECLARE
    v_edad  number  := 185;
BEGIN
    IF (v_edad < 18) THEN
    DBMS_OUTPUT.PUT_LINE('Menor de edad');
    ELSIF (v_edad < 60 AND v_edad >= 18) THEN
    DBMS_OUTPUT.PUT_LINE('Mayor de edad');
    ELSIF (v_edad < 100 AND v_edad >= 60) THEN
    DBMS_OUTPUT.PUT_LINE('Adulto mayor');
    ELSE
    DBMS_OUTPUT.PUT_LINE('Wow');
    END IF;
END;
/

-- Sentencias Case
-- Selecciona un resultado y lo devuelve
-- Sintaxis

/*
CASE selector
    WHEN expression1 THEN result1
    [WHEN expression2 THEN result2
    ...
    WHEN expressionN THEN resultN]
    [ELSE resultN+1]
END;
*/
 
-- Ejemplo

DECLARE
   v_nota   number(9,2) := 8;
   v_valoracion varchar2(20);
BEGIN
    v_valoracion := CASE v_nota
                        WHEN 10 THEN 'Excelente'
                        WHEN 9  THEN 'Muy bueno'
                        WHEN 8  THEN 'Bueno'
                        ELSE 'Esfuerzate mas'
                    END;
    DBMS_OUTPUT.PUT_LINE('Valoracion obtenida mediante sentencia CASE: ' || v_valoracion);
END;
/

-- o bien mediante expresiones CASE de busqueda, la cual ofrece una mejor libertad

DECLARE
   v_nota   number(9,2) := 7.5;
   v_valoracion varchar2(20);
BEGIN
    v_valoracion := CASE 
                        WHEN (v_nota >= 9 AND v_nota <= 10) THEN 'Excelente'
                        WHEN (v_nota >= 7 AND v_nota < 9)  THEN 'Muy bueno'
                        WHEN (v_nota >= 6 AND v_nota < 7)  THEN 'Bueno'
                        ELSE 'Esfuerzate mas'
                    END;
    DBMS_OUTPUT.PUT_LINE('Valoracion obtenida mediante expresiones CASE: ' || v_valoracion);
END;
/

-- Insertando SQL en case

/* En el siguiente ejercicio trata sobre un aumento de salario, 
   si es el departamento de codigo 100, sus empleados aumentaran 
   en un 10% su salario y los demás departamentos en un 5%
*/

DECLARE
    v_department_id departments.department_id%type  := 100;
BEGIN
    CASE v_department_id
        WHEN  100    THEN   UPDATE employees
                            SET salary = salary*1.1
                            WHERE department_id = v_department_id;
        ELSE  UPDATE employees
              SET salary = salary*1.05
              WHERE department_id = v_department_id;
    END CASE;
    DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' empleados beneficiados');
END;
/

-- Sentencias de bucle

-- LOOP

-- Sintaxis

/*
    LOOP
        statements1;
        ...
        EXIT [WHEN condition];
    END LOOP;
*/

-- Ejemplo

DECLARE
    v_count number:= 0;
BEGIN
    LOOP
        DBMS_OUTPUT.PUT_LINE('Valor de contador en LOOP Basico: ' || v_count);
        -- incremento de contador
        v_count := v_count + 1;
        EXIT WHEN v_count > 4;
    END LOOP;
END;
/
/*
Resultado: 

    Valor de contador en LOOP Basico: 0
    Valor de contador en LOOP Basico: 1
    Valor de contador en LOOP Basico: 2
    Valor de contador en LOOP Basico: 3
    Valor de contador en LOOP Basico: 4
    
    Procedimiento PL/SQL terminado correctamente.
*/

-- While
-- Repite mientras la condición sea true
/*
    WHILE condition
    LOOP
        statements1;
        statements2;
        ...
    END LOOP;
*/

-- ejemplo

DECLARE
    v_count number:= 0;
BEGIN
    WHILE (v_count <= 4)
    LOOP
        DBMS_OUTPUT.PUT_LINE('Valor de contador en WHILE: ' || v_count);
        -- incremento de contador
        v_count := v_count + 1;
    END LOOP;
END;
/
/*
Resultado: 

    Valor de contador en WHILE: 0
    Valor de contador en WHILE: 1
    Valor de contador en WHILE: 2
    Valor de contador en WHILE: 3
    Valor de contador en WHILE: 4
    
    Procedimiento PL/SQL terminado correctamente.
*/

-- FOR

-- El contador (counter) se declara implicitamente

/*
    FOR counter IN [REVERSE] lower_bound..upper_bound
    LOOP
        statements1;
        statements2;
        ...
    END LOOP;
*/

BEGIN
    FOR i IN 0..4
    LOOP
        DBMS_OUTPUT.PUT_LINE('Valor de contador en FOR: ' || i);
    END LOOP;
END;
/
/*
Resultado: 

    Valor de contador en FOR: 0
    Valor de contador en FOR: 1
    Valor de contador en FOR: 2
    Valor de contador en FOR: 3
    Valor de contador en FOR: 4
    
    Procedimiento PL/SQL terminado correctamente.
    */

-- For REVERSE

-- Observar que el rango siempre se agrega de manera ascendete
BEGIN
    FOR i IN REVERSE 0..4
    LOOP
        DBMS_OUTPUT.PUT_LINE('Valor de contador en FOR ENVERSE: ' || i);
    END LOOP;
END;
/
/*
Resultado:
    Valor de contador en FOR ENVERSE: 4
    Valor de contador en FOR ENVERSE: 3
    Valor de contador en FOR ENVERSE: 2
    Valor de contador en FOR ENVERSE: 1
    Valor de contador en FOR ENVERSE: 0
    
    Procedimiento PL/SQL terminado correctamente.
*/

-- LOOPS anidados y etiquetas

-- ejemplo

DECLARE
    v_contador_externo  number  := 0;
    v_contador_interno  number  := 0;
BEGIN
    <<loop_externo>>
    LOOP
        v_contador_interno := 0;
        
        <<loop_interno>>
        LOOP
            DBMS_OUTPUT.PUT_LINE(v_contador_externo || v_contador_interno);
            v_contador_interno := v_contador_interno +1;
            EXIT loop_interno WHEN v_contador_interno > 2;
        END LOOP loop_interno;
        
        v_contador_externo := v_contador_externo +1;
        EXIT loop_externo WHEN v_contador_externo > 2;
        
    END LOOP loop_externo;
END;

/*
Resultado: 

    00
    01
    02
    10
    11
    12
    20
    21
    22
    
    Procedimiento PL/SQL terminado correctamente.
*/
