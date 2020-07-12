-- Cursores Explicitos

SET SERVEROUTPUT ON;

-- Sintaxis

/*
    CURSOR cursor_name IS
        select_estatements:
*/

-- Ejemplo 

DECLARE
    -- 1. declara cursor
    CURSOR c_emp_cursor IS
        SELECT employee_id, last_name
        FROM employees
        WHERE department_id = 30;
        
    v_emp_id            employees.employee_id%type;
    v_emp_last_name     employees.last_name%type;
    
BEGIN
    -- 2. abrir el cursos
    OPEN c_emp_cursor;
    
    LOOP
        -- 3. fetch, asignar valores dentro de el fetch a variables
        FETCH c_emp_cursor INTO v_emp_id, v_emp_last_name;
        DBMS_OUTPUT.PUT_LINE(v_emp_id || ' ' ||v_emp_last_name);
        
        -- 4. se itera el cursor hasta que ya no exista más tuplas usando la propiedad %NOTFOUND
        EXIT WHEN c_emp_cursor%NOTFOUND;
        
    END LOOP;
    
    -- 5. Close Se cierra el cursor
    CLOSE c_emp_cursor;
END;
/

-- Cursores y registros

-- En este caso se crea un variable record con la estructura del cursor

DECLARE
    -- 1. declara cursor
    CURSOR c_emp_cursor IS
        SELECT employee_id, last_name
        FROM employees
        WHERE department_id = 30;
        
    -- declaración de variable record con la estructura del cursor  
    v_emp_record    c_emp_cursor%rowtype;
    
BEGIN
    -- 2. abrir el cursos
    OPEN c_emp_cursor;
    
    LOOP
        -- 3. fetch, asignar valores dentro de el fetch a variables
        FETCH c_emp_cursor INTO v_emp_record;
        DBMS_OUTPUT.PUT_LINE(v_emp_record.employee_id 
                             || ' ' 
                             ||v_emp_record.last_name);
        
        -- 4. se itera el cursor hasta que ya no exista más tuplas usando la propiedad %NOTFOUND
        EXIT WHEN c_emp_cursor%NOTFOUND;
        
    END LOOP;
    
    -- 5. Close Se cierra el cursor
    CLOSE c_emp_cursor;
END;
/

-- Cursor con bucle FOR (RECOMENDADO)

/* Se recomienda esta practica, dado que:
   - El cursor bucle FOR es un atajo para procesar cursores explicitos
   - se evita hacer: OPEN, FETCH, EXIT Y CLOSE 
   - el registro es implicitamente declarado
*/

DECLARE
    -- 1. declara cursor
    CURSOR c_emp_cursor IS
        SELECT employee_id, last_name
        FROM employees
        WHERE department_id = 30;
    
BEGIN
    -- 2. Se itera el cursor asignando al record v_emp_record (creado implícitamente)
    FOR v_emp_record IN c_emp_cursor
    LOOP
        DBMS_OUTPUT.PUT_LINE(v_emp_record.employee_id 
                             || ' ' 
                             ||v_emp_record.last_name);        
    END LOOP;
END;
/

/*
Resultado de los tres ejemplos anteriores: 

114 Raphaely
115 Khoo
116 Baida
117 Tobias
118 Himuro
119 Colmenares
119 Colmenares

Procedimiento PL/SQL terminado correctamente.
*/

-- Atributos de cursores

/*
| Atributo  | Tipo          |               Descripción                 |
|   ---     |   ---         |                   ---                     |
|%ISOPEN    | Boolean       |Evalua a TRUE si el cursor esta abierto    |
|%NOTFOUND  | Boolean       |Evalua a TRUE si la más reciente recuperación no retorna una fila|
|%FOUND     | Boolean       |Evalua a TRUE si la más reciente recuperación retorna una fila; complemento de %NOTFOUND|
|%ROWCOUNT  | Number        |Evalua el número de filas que han sido recuperadas. |
*/

-- CURSOR FOR LOOPS utilizando Subconsultas

-- De esta manera se evita declarar el cursor

BEGIN
    FOR emp_record IN ( SELECT employee_id, last_name
                        FROM employees
                        WHERE department_id = 30) -- observar que no se utiliza ; 
    LOOP
        DBMS_OUTPUT.PUT_LINE(emp_record.employee_id 
                             || ' ' 
                             ||emp_record.last_name);   
    END LOOP;
    
END;
/
/*
Resultado:
    114 Raphaely
    115 Khoo
    116 Baida
    117 Tobias
    118 Himuro
    119 Colmenares
    
    Procedimiento PL/SQL terminado correctamente.
*/

-- Cursor con parametros

DECLARE
    CURSOR c_emp_cursor (deptno NUMBER) IS  SELECT employee_id, last_name
                                            FROM employees
                                            WHERE department_id = deptno;
BEGIN

    DBMS_OUTPUT.PUT_LINE('Empleados del deptno 10');
    FOR r_emp_record IN c_emp_cursor(10)
    LOOP
        DBMS_OUTPUT.PUT_LINE(r_emp_record.employee_id 
                         || ' ' 
                         ||r_emp_record.last_name);                    
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Empleados del deptno 20');
    
    
    FOR r_emp_record IN c_emp_cursor(20)
    LOOP
        DBMS_OUTPUT.PUT_LINE(r_emp_record.employee_id 
                         || ' ' 
                         ||r_emp_record.last_name);                    
    END LOOP;
    
END;

/*
Resultado:

    Empleados del deptno 10
    200 Whalen
    Empleados del deptno 20
    201 Hartstein
    202 Fay
    
    Procedimiento PL/SQL terminado correctamente.
*/

-- Clausula WHERE CURRENT OF

/*
Utilizado para referenciar la fila actual desde un cursor explicito con el objetivo de editar o eliminar una fila a través del cursor.
Sintaxis:

WHERE CURRENT OF cursor_name;

ejemplo:

UPDATE  employees
    SET salary = ...
    WHERE CURRENT OF c_emp_cursor;


Recomendaciones con cursores

- Utilizar FOR UPDATE en las filas que se desea bloquear o borrar, esto con el objetivo de bloquear el acceso mediante otras sesiones permitiendo que la información se encuentre consistente
*/