-- Tipos de datos compuestos 
SET SERVEROUTPUT ON;

-- Registros

DECLARE
    -- Registro
    TYPE t_rec IS RECORD(
        v_sal       number(8),
        v_minsal    number(8) DEFAULT 1000,
        v_hire_date employees.hire_date%type,
        v_rec1      employees%rowtype -- %rowtype permite definir un elemento con la estructura de la tabla 
        );
    
    v_myrec t_rec; -- Se usa el identificador v_myrec para t_rec
BEGIN
    -- ejemplo de como se puede manipular los elementos del registro
    v_myrec.v_sal := v_myrec.v_minsal + 500;
    
    -- ejemplo de como obtener una fila completa
    SELECT * INTO v_myrec.v_rec1
    FROM employees
    WHERE employee_id = 100;
    
    DBMS_OUTPUT.PUT_LINE('V_SAL: ' || v_myrec.v_sal);
    DBMS_OUTPUT.PUT_LINE('Salario real através de V_REC1: ' 
                            || v_myrec.v_rec1.salary 
                            || ' del empleado: '
                            || v_myrec.v_rec1.first_name);
END;
/
/*
Resultado: 
    V_SAL: 1500
    Salario real através de V_REC1: 24000 del empleado: Steven
    
    Procedimiento PL/SQL terminado correctamente.
*/

-- Arreglos Asociados (llave, valor)

/* el valor bien puede ser escalar, creado bala la deficion de una columna (%type) 
   o mediante la definicion de una tabla o record (%rowtype)
*/


DECLARE
    -- declaración de arreglo asociado de tipo igual a la estructura de la columna LAST_NAME
    TYPE ename_table_type IS TABLE OF employees.last_name%type
        INDEX BY PLS_INTEGER; -- PLS_INTEGER | BINARY_INTEGER
    
    -- declaración de identificador
    ename_table ename_table_type;
    
BEGIN
    --asignamos al arreglo el elemento con index 1
    ename_table(1)  := 'PALACIOS';
    
    IF (ename_table.EXISTS(1)) THEN
        DBMS_OUTPUT.PUT_LINE(ename_table(1));
    END IF;
    
END;
/
/*  Además de EXISTS, los metodos que se pueden utilizar son: 
    - EXISTS
    - COUNT
    - FIRST
    - LAST
    - PRIOR (el previo)
    - NEXT
    - DELETE
*/

-- VARRAY 
/*  Array variables, 
    son de longitud fija
*/

DECLARE
    --Declaramos VARRAY
    TYPE emp_array IS VARRAY(100) OF VARCHAR2(30);
    
    --identificador
    emps emp_array;
BEGIN
    -- agregamos elementos al VARRAY
    emps := emp_array('Scrum', 'XP');
    
    --agregar el espacio de un elemento mas
    emps.extend;
    -- agregamos elemento
    emps(emps.LAST) := 'Kanba';
    
    -- imprimimos elemento
    FOR indice IN emps.FIRST..emps.LAST
    LOOP
        DBMS_OUTPUT.PUT_LINE(emps(indice));
    END LOOP;
END;
/

/*
Resultados:
Scrum
XP
Kanba

Procedimiento PL/SQL terminado correctamente.
*/
-- VARRAY en SQL

Create or replace TYPE emp_array AS VARRAY(100) OF VARCHAR2(30);
Describe emp_array;

/*
    Resultado:
    
    Type EMP_ARRAY compilado
    
    Nombre    ¿Nulo? Tipo                        
    --------- ------ --------------------------- 
    EMP_ARRAY        VARRAY(100) OF VARCHAR2(30)
*/
-- teniendo este VARRAY se puede utilizar como cualquier tipo de dato en ORACLE

-- Consulta de VARRAY en SQL

Select name 
From club
Where 'Gen' IN (SELECT * From table(club.members));

-- Donde members es un campo en la tabla club de tipo VARRAY