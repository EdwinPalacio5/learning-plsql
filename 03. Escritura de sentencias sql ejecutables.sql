-- Escritura de Sentencias SQL Ejecutables

-- Antes de todo, Habilitamos la salida en SQL Developer
SET SERVEROUTPUT ON;

-- Uso de Comentarios y Funciones de una sola fila

DECLARE 
    --declaramos variable de salario anual
    v_salario_anual   NUMBER(9, 2);
    v_last_name       employees.last_name%TYPE;
    v_hire_date       employees.hire_date%TYPE;
BEGIN
    /* asignamos valor de salario anual: se consulta el 
       salario mensual y se multiplica por 12
     */
    SELECT salary * 12, last_name, hire_date
    INTO v_salario_anual, v_last_name, v_hire_date
    FROM employees
    WHERE employee_id = 100;
    
    --se imprime variable de salario anual

    dbms_output.put_line('Salario anual: ' || v_salario_anual);
    
    /* uso de variable de una sola fila: 
       mostrar la cantidad de caracteres de last_name
    */
    
    dbms_output.put_line('Tamano de last_name: '
                         || v_last_name
                         || ' '
                         || length(v_last_name));
    
    /* uso de variable de una sola fila:
       para determinar la cantidad de dias desde su contratación
    */

    dbms_output.put_line('cantidad de dias desde contratacion: ' 
                         || months_between(sysdate, v_hire_date));
END;
/

/*
    Salario anual: 288000
    Tamano de last_name: King 4
    cantidad de dias desde contratacion: 203.67

    Procedimiento PL/SQL terminado correctamente.

*/

-- Bloques anidados

DECLARE
    v_externa VARCHAR2(20) := 'VARIABLE EXTERNA';
BEGIN
    DECLARE
        v_interna VARCHAR2(20) := 'VARIABLE INTERNA';
    BEGIN
        dbms_output.put_line(v_externa);
        dbms_output.put_line(v_interna);
    END;

    dbms_output.put_line(v_externa);
    -- DBMS_OUTPUT.PUT_LINE(v_interna); variable interna no se encuentra en el alcance
END;
/
/*
Resultados: 

    VARIABLE EXTERNA
    VARIABLE INTERNA
    VARIABLE EXTERNA

    Procedimiento PL/SQL terminado correctamente.
*/

-- Nombramientos por bloque 

/* Son cualificadores o etiquetas que permiten identificar explicitamente 
   de que ambito se encuentra la variable a la que se hace referencia
*/

BEGIN <<externo>>
DECLARE
    v_variable VARCHAR2(20) := 'VARIABLE EXTERNA';
BEGIN
    DECLARE
        v_variable VARCHAR2(20) := 'VARIABLE INTERNA';
    BEGIN
        dbms_output.put_line(v_variable);
        --Si agregamos el nombramiento, se hace referencia no a la variable interna sino a la externa
        dbms_output.put_line(externo.v_variable);
    END;

    dbms_output.put_line(v_variable);
    -- DBMS_OUTPUT.PUT_LINE(v_interna); variable interna no se encuentra en el alcance
END;
END externo;
/
/*
Resultados: 
    
    VARIABLE INTERNA
    VARIABLE EXTERNA
    VARIABLE EXTERNA

    Procedimiento PL/SQL terminado correctamente.
*/

