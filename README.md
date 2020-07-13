# learning-PLSQL Oracle 12c

- [Estructura de Bloque PL/SQL](#estructura-de-bloque-plsql).
- [Tipos de Bloque](#tipos-de-bloque)
- [Declarando Variables PL/SQL](#declarando-variables-plsql)
   - [Tipos de Variables](#tipos-de-variables)
   - [Declarando variables con el atributo %type](#declarando-variables-con-el-atributo-type)
   - [Variables Bind o enlazadas](#variables-bind-o-enlazadas)
   - [AUTOPRINT con BIND Variables](#autoprint-con-bind-variables)

## Estructura de Bloque PL/SQL

```
DECLARE (opcional)
– Variables, cursores, excepciones definida por usuario
BEGIN (mandatorio)
– Setencias SQL
– Sentencias PL/SQL
EXCEPTION (opcional)
– Acciones a desarrollar cuando ocurre una excepción
END; (mandatorio)
```

## Tipos de Bloque

Anónimo
```
  [DECLARE]
  BEGIN
    --sentencias
  [EXCEPTION]
  END;
```

Procedimiento
```
  PROCEDURE nombre
  IS
  BEGIN
    --sentencias
  [EXCEPTION]
  END;
```
Función

```
  FUNCTION nombre
  RETURN tipoDato
  IS
  BEGIN
    --sentencias
    RETURN valor;
  [EXCEPTION]
  END;
```

**Ejemplo Bloque Anonimo:**

```
-- Para habilitar la salida en SQL Developer
SET SERVEROUTPUT ON;

DECLARE
  v_fname VARCHAR(20);
BEGIN
  SELECT  first_name INTO v_fname
  FROM    employees
  WHERE   employee_id=100;

--paquete predefinido Oracle (DBMS_OUTPUT)y su procedimiento (PUT_LINE) 
  DBMS_OUTPUT.PUT_LINE('El primer nombre del empleado es ' || v_fname);
END;
```

Resultado:
```
  Procedimiento PL/SQL terminado correctamente.
  El primer nombre del empleado es Steven
```

## Declarando Variables PL/SQL

Sintaxis

```
identifier  [CONSTANT]  datatype  [NOT NULL] [:= | DEFAULT expr];
```

Ejemplos:

```
DECLARE 
  v_myname  varchar(20);
  v_mycity  varchar(20) := 'San Martin';
BEGIN
  v_myname := 'Edwin';
  DBMS_OUTPUT.PUT_LINE('Mi nombre es: ' || v_myname);
  DBMS_OUTPUT.PUT_LINE('Vivo en: ' || v_mycity);
END;
```


Resultado:
```
  Procedimiento PL/SQL terminado correctamente.
  Mi nombre es: Edwin
  Vivo en: San Martin
 ```

### Tipos de Variables

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
  
### Convención de nombres de variables  
  
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

### Declarando variables con el atributo %type

```
DECLARE
  v_emp_lname employees.last_name%TYPE;
BEGIN
  SELECT last_name INTO v_emp_lname
  FROM  employees
  WHERE employee_id = 100;
  DBMS_OUTPUT.PUT_LINE('Mi apellido es: ' || v_emp_lname);
END;
```

Resultado:
```
  Procedimiento PL/SQL terminado correctamente.
  Mi apellido es: King
```

### Variables Bind o enlazadas

```
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
```

Resultado: 
```
  Procedimiento PL/SQL terminado correctamente.
  
  B_EMP_SALARY
  ------------
  24000
  
  FIRST_NAME         
  --------------------
  Steven   
```

## AUTOPRINT con BIND Variables

```
VARIABLE b_emp_salary NUMBER
SET AUTOPRINT ON

DECLARE
  v_empno NUMBER(6) := &empno;
BEGIN
  SELECT salary into :b_emp_salary
  FROM employees
  WHERE employee_id = v_empno;
END;
```

Resultado: 
```
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
```


## Escritura de Sentencias SQL Ejecutables

Antes de todo, Habilitamos la salida en SQL Developer
```
SET SERVEROUTPUT ON;
```

### Uso de Comentarios y Funciones de una sola fila

```
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

Resultado:

    Salario anual: 288000
    Tamano de last_name: King 4
    cantidad de dias desde contratacion: 203.67

    Procedimiento PL/SQL terminado correctamente.
```
### Bloques anidados

```
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

Resultados: 

    VARIABLE EXTERNA
    VARIABLE INTERNA
    VARIABLE EXTERNA

    Procedimiento PL/SQL terminado correctamente.
```

### Nombramientos por bloque 

Son cualificadores o etiquetas que permiten identificar explicitamente de que ambito se encuentra la variable a la que se hace referencia

```
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

Resultados: 
    
    VARIABLE INTERNA
    VARIABLE EXTERNA
    VARIABLE EXTERNA

    Procedimiento PL/SQL terminado correctamente.
```

## Uso de Sentencias SQL en un bloque PL/SQL

SET SERVEROUTPUT ON;

Utilizando PL/SQL para la Manipulación de datos. Hacer cambios en las tablas de bases de datos mediante el uso de comandos DML:
 
 - INSERT
 - UPDATE
 - DELETE
 - MERGE
 
### INSERT
```
BEGIN
    INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, job_id, salary)
    VALUES(employees_seq.NEXTVAL, 'Edwin', 'Palacios', 'edwin@gmail.com', CURRENT_DATE, 'AD_ASST', 4000);
END;
/
```

### UPDATE

```
Declare 
    v_incremento_salario    employees.salary%type := 800;
Begin
    Update employees 
    set salary = salary + v_incremento_salario
    Where job_id = 'ST_CLERK';
End;
/
```
**Nota:** Como se puede observar el SQL se trabaja de forma igual, Asimismo con eliminar, merge, commit, rollback y savepoint

### Cursor SQL

Un cursor es un puntero a la zona de memoria privada asignada por el servidor Oracle. Se utiliza para manejar el conjunto de resultados de una sentencia SELECT

Hay dos tipos de cursores: implícitos y explícitos.

– Implícito: Creado y gestionado internamente por el servidor Oracle para procesar sentencias SQL.

– Explícita: Declarado explícitamente por el programador. 


#### Atributos de Cursor


| Atributo | Descripción |
|   ---          |                              ---                         |
| SQL%FOUND      |    Atributo booleano que se evalúa como TRUE si la última sentencia SQL afectó al menos una fila |
| SQL%NOTFOUND   |   Atributo booleano que se evalúa como TRUE si la última sentencia SQL no afectó ni una fila |
| SQL%ROWCOUNT   |    Un valor entero que representa el número de filas afectadas por la última sentencia SQL |

Ejemplo de ROWCOUNT
```
SET SERVEROUTPUT ON;
Declare 
    v_disminucion_salario    employees.salary%type := 800;
Begin
    Update employees 
    set salary = salary - v_disminucion_salario
    Where job_id = 'ST_CLERK';
    DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' filas afectadas');
End;
```

## Estructuras de Control en bloque PLSQL

SET SERVEROUTPUT ON;

### IF - THEN - ELSIF - ELSE - END IF

Sintaxis

```
    IF  condition THEN
        statements;
    [ELSIF  condition THEN
        statements;]
    [ELSE
        statements;]
    END IF;
```

Ejemplo

```
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
```
### Sentencias Case 

Selecciona un resultado y lo devuelve
Sintaxis

```
CASE selector
    WHEN expression1 THEN result1
    [WHEN expression2 THEN result2
    ...
    WHEN expressionN THEN resultN]
    [ELSE resultN+1]
END;
```
 
Ejemplo

```
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
```
#### Expresiones CASE de busqueda

La cual ofrece una mejor libertad

```
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
```
#### Insertando SQL en case

En el siguiente ejercicio trata sobre un aumento de salario, si es el departamento de codigo 100, sus empleados aumentaran en un 10% su salario y los demás departamentos en un 5%

```
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
```

### Sentencias de bucle

#### LOOP

Sintaxis

```
    LOOP
        statements1;
        ...
        EXIT [WHEN condition];
    END LOOP;
```

Ejemplo

```
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

Resultado: 

    Valor de contador en LOOP Basico: 0
    Valor de contador en LOOP Basico: 1
    Valor de contador en LOOP Basico: 2
    Valor de contador en LOOP Basico: 3
    Valor de contador en LOOP Basico: 4
    
    Procedimiento PL/SQL terminado correctamente.
```

#### While

Repite mientras la condición sea true

```
    WHILE condition
    LOOP
        statements1;
        statements2;
        ...
    END LOOP;
```

ejemplo

```
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

Resultado: 

    Valor de contador en WHILE: 0
    Valor de contador en WHILE: 1
    Valor de contador en WHILE: 2
    Valor de contador en WHILE: 3
    Valor de contador en WHILE: 4
    
    Procedimiento PL/SQL terminado correctamente.
```

#### FOR

El contador (counter) se declara implicitamente

```
    FOR counter IN [REVERSE] lower_bound..upper_bound
    LOOP
        statements1;
        statements2;
        ...
    END LOOP;
```

```
BEGIN
    FOR i IN 0..4
    LOOP
        DBMS_OUTPUT.PUT_LINE('Valor de contador en FOR: ' || i);
    END LOOP;
END;
/

Resultado: 

    Valor de contador en FOR: 0
    Valor de contador en FOR: 1
    Valor de contador en FOR: 2
    Valor de contador en FOR: 3
    Valor de contador en FOR: 4
    
    Procedimiento PL/SQL terminado correctamente.
```

#### For REVERSE

Observar que el rango siempre se agrega de manera ascendete

```
BEGIN
    FOR i IN REVERSE 0..4
    LOOP
        DBMS_OUTPUT.PUT_LINE('Valor de contador en FOR ENVERSE: ' || i);
    END LOOP;
END;
/

Resultado:
    Valor de contador en FOR ENVERSE: 4
    Valor de contador en FOR ENVERSE: 3
    Valor de contador en FOR ENVERSE: 2
    Valor de contador en FOR ENVERSE: 1
    Valor de contador en FOR ENVERSE: 0
    
    Procedimiento PL/SQL terminado correctamente.
```

#### LOOPS anidados y etiquetas

ejemplo

```
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
```

## Tipos de datos compuestos 
SET SERVEROUTPUT ON;

### Registros

```
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

Resultado: 
    V_SAL: 1500
    Salario real através de V_REC1: 24000 del empleado: Steven
    
    Procedimiento PL/SQL terminado correctamente.
```

### Arreglos Asociados (llave, valor)

El valor bien puede ser escalar, creado bajo la deficion de una columna (%type) o mediante la definicion de una tabla o record (%rowtype)

```
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
```

Además de EXISTS, los metodos que se pueden utilizar son: EXISTS, COUNT, FIRST, LAST, PRIOR (el previo), NEXT, DELETE

### VARRAY 

Array variables, son de longitud fija

```
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

Resultados:
Scrum
XP
Kanba

Procedimiento PL/SQL terminado correctamente.
```

### VARRAY en SQL

```
Create or replace TYPE emp_array AS VARRAY(100) OF VARCHAR2(30);
Describe emp_array;


    Resultado:
    
    Type EMP_ARRAY compilado
    
    Nombre    ¿Nulo? Tipo                        
    --------- ------ --------------------------- 
    EMP_ARRAY        VARRAY(100) OF VARCHAR2(30)
```
**Nota:** teniendo este VARRAY se puede utilizar como cualquier tipo de dato en ORACLE

### Consulta de VARRAY en SQL

```
Select name 
From club
Where 'Gen' IN (SELECT * From table(club.members));

```

Donde members es un campo en la tabla club de tipo VARRAY

## Cursores Explicitos

SET SERVEROUTPUT ON;

Sintaxis

```
    CURSOR cursor_name IS
        select_estatements:
```

Ejemplo 

```
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
```

### Cursores y registros

En este caso se crea un variable record con la estructura del cursor

```
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
```

### Cursor con bucle FOR (RECOMENDADO)

Se recomienda esta practica, dado que:

   - El cursor bucle FOR es un atajo para procesar cursores explicitos.
   
   - se evita hacer: OPEN, FETCH, EXIT Y CLOSE.
   
   - el registro es implicitamente declarado.

```
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
```

```
Resultado de los tres ejemplos anteriores: 

114 Raphaely
115 Khoo
116 Baida
117 Tobias
118 Himuro
119 Colmenares
119 Colmenares

Procedimiento PL/SQL terminado correctamente.
```

### Atributos de cursores


| Atributo  | Tipo          |               Descripción                 |
|   ---     |   ---         |                   ---                     |
|%ISOPEN    | Boolean       |Evalua a TRUE si el cursor esta abierto    |
|%NOTFOUND  | Boolean       |Evalua a TRUE si la más reciente recuperación no retorna una fila|
|%FOUND     | Boolean       |Evalua a TRUE si la más reciente recuperación retorna una fila; complemento de %NOTFOUND|
|%ROWCOUNT  | Number        |Evalua el número de filas que han sido recuperadas. |


### CURSOR FOR LOOPS utilizando Subconsultas

De esta manera se evita declarar el cursor
```
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
```

```
Resultado:
    114 Raphaely
    115 Khoo
    116 Baida
    117 Tobias
    118 Himuro
    119 Colmenares
    
    Procedimiento PL/SQL terminado correctamente.
```

### Cursor con parametros

```
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
```

```
Resultado:

    Empleados del deptno 10
    200 Whalen
    Empleados del deptno 20
    201 Hartstein
    202 Fay
    
    Procedimiento PL/SQL terminado correctamente.
```

### Clausula For Update

Bloqueo explicito para denegar el acceso a otras sesiones durante el tiempo de transacción

```
Select *
From employees
For Update [OF column_reference] [NOWAIT | WAIT n]; 
```

### Clausula WHERE CURRENT OF

Utilizado para referenciar la fila actual desde un cursor explicito con el objetivo de editar o eliminar una fila a través del cursor.

Sintaxis:

```
WHERE CURRENT OF cursor_name;
```

ejemplo:

```
UPDATE  employees
    SET salary = ...
    WHERE CURRENT OF c_emp_cursor;
```

**Recomendaciones con cursores:** Utilizar FOR UPDATE en las filas que se desea bloquear o borrar, esto con el objetivo de bloquear el acceso mediante otras sesiones permitiendo que la información se encuentre consistente


## Excepciones

Sintaxis para atrapar excepciones

```
EXCEPTION
    WHEN exception1 [OR exception2 ... ] THEN
        statements1;
        statements2;
        ...
    [WHEN exception3 [OR exception4 ... ] THEN
        statements1;
        statements2;
        ...]        
    [WHEN OTHERS THEN
        statements1;
        statements2;
        ...]
```       
Excepciones predefinidas de ejemplo:

- NO_DATA_FOUND : no encuentra datos en la consulta.

- TOO_MANY_ROWS : devuelve mas de las filas esperadas.

- INVALID_CURSOR : Cursor invalido.

- ZERO_DIVIDE : division entre cero.

- DUP_VAL_ON_INDEX: Cuando se quiere duplicar una llave primaria.


### Excepciones No predefinidas

Ejemplo: se desea atrapar la excepcion de querer registrar un valor null

```
DECLARE
    e_insert_exception  EXCEPTION; -- declaracion de exception
    PRAGMA EXCEPTION_INIT(e_insert_exception, -01400); -- se coloca el codigo del servidor oracle cuando no se pueden editar valores nulos
BEGIN
    INSERT INTO departments (department_id, department_name)
    VALUES (280, NULL);
EXCEPTION
    WHEN e_insert_exception THEN -- referencia de la exception en el when
    DBMS_OUTPUT.PUT_LINE('OPERACION DE INSERCION FALLIDA');
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/
```

```
Resultado:
    OPERACION DE INSERCION FALLIDA
    ORA-01400: no se puede realizar una inserción NULL en ("HR"."DEPARTMENTS"."DEPARTMENT_NAME")
    
    Procedimiento PL/SQL terminado correctamente.
```

### Funciones para atrapar Errores


- SQLCODE: Devuelve el valor numérico para el código de error.

- SQLERRM: Devuelve el mensaje asociado con el número de error.

```
...
EXCEPTION
   ...
   WHEN OTHERS THEN
   error_code := SQLCODE;
   error_message := SQLRRM;
   ...
END;

```

### Atrapando funciones definidas por el usuario (RAISE)

Utilizando RAISE se pueden atrapar excepciones definidas por el usuario.
    
    - Detiene la ejecución normal de un bloque PL / SQL o subprograma y transfiere el control a un controlador de excepciones.
    
    - Explícitamente plantea excepciones predefinidas o excepciones definidas por el usuario.
    
En el siguiente ejemplo se dispara una excepcion para indicar que el usuario debe ser mayor de edad.

```
DECLARE
    v_edad  NUMBER := 27;
    e_restriccion_edad_exception    EXCEPTION; 
BEGIN
    IF v_edad > 18 THEN
        DBMS_OUTPUT.PUT_LINE('Bienvenid@');
    ELSE
        RAISE e_restriccion_edad_exception; -- activamos la excepcion de restriccion de edad
    END IF;
EXCEPTION
    WHEN e_restriccion_edad_exception THEN
       DBMS_OUTPUT.PUT_LINE('Acceso denegado, debes ser mayor de edad'); 
END;
/
```

### Procedure RAISE_APPLICATION_ERROR

Puede usar este procedimiento para emitir mensajes de error definidos por el usuario de subprogramas almacenados.
Puede reportar errores en su aplicación y evitar volver excepciones no controladas.

Se utiliza en dos lugares diferentes:

      – sección ejecutable.
      
      – sección de excepción.
      
Devuelve condiciones de error al usuario de una manera consistente con otros errores de Oracle Server

Sintaxis

```
raise_application_error (error_number,
    message[, {TRUE | FALSE}]);
```

Ejemplo: utilizando en el BEGIN

```
DECLARE
    v_edad  NUMBER := 17;
BEGIN
    IF v_edad > 18 THEN
        DBMS_OUTPUT.PUT_LINE('Bienvenid@');
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Acceso denegado, debes ser mayor de edad'); -- excepcion de restriccion de edad
    END IF;
END;
/
```

Ejemplo: utilizando en el exception

```
DECLARE
    v_edad  NUMBER := 17;
    e_restriccion_edad_exception    EXCEPTION; 
BEGIN
    IF v_edad > 18 THEN
        DBMS_OUTPUT.PUT_LINE('Bienvenid@');
    ELSE
        RAISE e_restriccion_edad_exception; -- activamos la excepcion de restriccion de edad
    END IF;
EXCEPTION
    WHEN e_restriccion_edad_exception THEN
       RAISE_APPLICATION_ERROR(-20001, 'Acceso denegado, debes ser mayor de edad'); -- excepcion de restriccion de edad 
END;
/
```


**Nota:**   El parámetro final pasado al procedimiento es un Boolean(true/false) que indica al procedimiento que agregue este error a la pila de errores o reemplace todos los errores de la pila con este error. Pasar el valor de 'True' agrega el error a la pila actual, mientras que el valor predeterminado es 'False'.

## Procedimientos

 Sintaxis

```
    CREATE [OR REPLACE] PROCEDURE procedure_name
        [(argument1 [mode1] datatype1,
          argument2 [mode2] datatype2,
        . . .)]
    IS|AS
    procedure_body;
```

Ejemplo 

creamos procedimiento
```
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
```

fin de creacion de procedimiento


invocamos procedimiento en un bloque anonimo y le pasamos por parametro
```
BEGIN
    p_show_message('Este es un mensaje creado mediante un storage procedure ');
END;
```

```
Resultado: 

    Procedure P_SHOW_MESSAGE compilado
    
    Message: Este es un mensaje creado mediante un storage procedure  Fecha: 08/06/20
    
    Procedimiento PL/SQL terminado correctamente.
```

### Funciones

SET SERVEROUTPUT ON;

Sintaxis:

```
CREATE [OR REPLACE] FUNCTION function_name
    [(argument1 [mode1] datatype1,
    argument2 [mode2] datatype2,
    . . .)]
RETURN datatype
IS|AS
function_body;
```

Ejemplo: Crearemos un funcion la cual permita calcular el ISSS de un empleado

```
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
```
Invocamos la funcion mediante el siguiente bloque anonimo
```
BEGIN
    dbms_output.put_line('El calculo del ISSS es: $' || calcular_isss(100));
END;
```
