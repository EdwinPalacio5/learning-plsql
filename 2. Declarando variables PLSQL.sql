-- Declarando Variables PL/SQL

/*
Sintaxis

identifier  [CONSTANT]  datatype  [NOT NULL] [:= | DEFAULT expr];

*/

-- Ejemplos
SET SERVEROUTPUT ON;
DECLARE 
  v_myname  varchar(20);
  v_mycity  varchar(20) := 'San Martin';
BEGIN
  v_myname := 'Edwin';
  DBMS_OUTPUT.PUT_LINE('Mi nombre es: ' || v_myname);
  DBMS_OUTPUT.PUT_LINE('Vivo en: ' || v_mycity);
END;

/*
Resultado: 

  Procedimiento PL/SQL terminado correctamente.
  Mi nombre es: Edwin
  Vivo en: San Martin
*/

-- Tipos de Variables

/*
- PL/SQL variables
  - Escalar: Sostiene un solo valor, no tiene componentes internos (Boolean, text, integer, date, varchar, char, binary_float, bynary_double, pls_integer, binary_integer, timestamp, interval)
  - Referencia: 
  - Objetos largos(LOB: Oracle no va a tratar de interpretarlo, solo lo almacena): 
    - Libros: CLOB, 
    - Photo: BLOB, 
    - MOVIE: BFILE (Se almacena fuera de la base de datos), 
    - Caracteres especiales: NCLOB
  - Compuestos: 
    - Colecciones, 
    - Registro

- Variables No-PL/SQL: 
  - Bind variables (enlazadas) o lenguaje principal
  

|   Estructura PL/SQL                 |   Convención      |    Ejemplo        |
|   ---                               |   ---             |     ---           |
| Variable v_variable_name v_rate     | v_variable_name   | v_rate            |
| Constante c_constant_name c_rate    | c_constant_name   | c_rate            |
| Parámetro de subprograma            | p_parameter_name  | p_id              |
| Bind (host) variable                | b_bind_name       | b_salary          | 
| Cursor                              | cur_cursor_name   | cur_emp           |
| Registro                            | rec_record_name   | rec_emp           |
| Tipo                                | type_name_type    | ename_table_type  |
| Excepción                           | e_exception_name  | e_products_invalid|
| Archivo                             | f_file_handle_name| f_file            |

Declarando variables con el atributo %type

*/

DECLARE
  v_emp_lname employees.last_name%TYPE;
BEGIN
  SELECT last_name INTO v_emp_lname
  FROM  employees
  WHERE employee_id = 100;
  DBMS_OUTPUT.PUT_LINE('Mi apellido es: ' || v_emp_lname);
END;

/*
Resultado:
  Procedimiento PL/SQL terminado correctamente.
  Mi apellido es: King
*/

-- Ejemplo de variables Bind o enlazadas
--variable bind
VARIABLE b_emp_salary NUMBER;

BEGIN
  SELECT  salary  INTO  :b_emp_salary
  FROM    employees
  WHERE   employee_id=100;
END;
/
PRINT b_emp_salary;

SELECT  first_name
FROM    employees
WHERE salary = :b_emp_salary;

/*
Resultado: 
  Procedimiento PL/SQL terminado correctamente.
  
  B_EMP_SALARY
  ------------
  24000
  
  FIRST_NAME         
  --------------------
  Steven   
*/

-- AUTOPRINT con BIND Variables

VARIABLE b_emp_salary NUMBER
SET AUTOPRINT ON

DECLARE
  v_empno NUMBER(6) := &empno;
BEGIN
  SELECT salary into :b_emp_salary
  FROM employees
  WHERE employee_id = v_empno;
END;
/
/*
  Antiguo:DECLARE
  v_empno NUMBER(6) := &empno;
  BEGIN
    SELECT salary into :b_emp_salary
    FROM employees
    WHERE employee_id = v_empno;
  END;
  
  Nuevo:DECLARE
    v_empno NUMBER(6) := 140;
  BEGIN
    SELECT salary into :b_emp_salary
    FROM employees
    WHERE employee_id = v_empno;
  END;
  
  Procedimiento PL/SQL terminado correctamente.
  B_EMP_SALARY
  ----
  2500
*/

