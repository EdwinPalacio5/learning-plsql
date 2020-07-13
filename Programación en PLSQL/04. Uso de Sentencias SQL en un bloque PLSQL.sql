-- Uso de Sentencias SQL en un bloque PL/SQL

SET SERVEROUTPUT ON;

-- Utilizando PL/SQL para la Manipulación de datos 

/*
 Hacer cambios en las tablas de bases de datos mediante el uso de comandos DML:
 
 - INSERT
 - UPDATE
 - DELETE
 - MERGE
 
*/

-- INSERT

BEGIN
    INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, job_id, salary)
    VALUES(employees_seq.NEXTVAL, 'Edwin', 'Palacios', 'edwin@gmail.com', CURRENT_DATE, 'AD_ASST', 4000);
END;
/
Select * From employees;

-- UPDATE

Declare 
    v_incremento_salario    employees.salary%type := 800;
Begin
    Update employees 
    set salary = salary + v_incremento_salario
    Where job_id = 'ST_CLERK';
End;
/
-- Como se puede observar el SQL se trabaja de forma igual, Asimismo con eliminar, merge, commit, rollback y savepoint

-- Cursor SQL

/*
Un cursor es un puntero a la zona de memoria privada asignada por el servidor Oracle. Se utiliza para manejar el conjunto de resultados de una sentencia SELECT

Hay dos tipos de cursores: implícitos y explícitos.
– Implícito: Creado y gestionado internamente por el servidor Oracle para procesar sentencias SQL
– Explícita: Declarado explícitamente por el programador 
*/

-- Atributos de Cursor

/*
| Atributo | Descripción |
|   ---          |                              ---                         |
| SQL%FOUND      |    Atributo booleano que se evalúa como TRUE si la última sentencia SQL afectó al menos una fila |
| SQL%NOTFOUND   |   Atributo booleano que se evalúa como TRUE si la última sentencia SQL no afectó ni una fila |
| SQL%ROWCOUNT   |    Un valor entero que representa el número de filas afectadas por la última sentencia SQL |
*/

-- Ejemplo de ROWCOUNT
SET SERVEROUTPUT ON;
Declare 
    v_disminucion_salario    employees.salary%type := 800;
Begin
    Update employees 
    set salary = salary - v_disminucion_salario
    Where job_id = 'ST_CLERK';
    DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' filas afectadas');
End;

