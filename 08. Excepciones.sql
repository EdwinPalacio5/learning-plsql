-- Excepciones

-- Sintaxis para atrapar excepciones

/*
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
        
Excepciones predefinidas de ejemplo :

– NO_DATA_FOUND : no encuentra datos en la consulta
– TOO_MANY_ROWS : devuelve mas de las filas esperadas
– INVALID_CURSOR : Cursor invalido
– ZERO_DIVIDE : division entre cero
– DUP_VAL_ON_INDEX: Cuando se quiere duplicar una llave primaria
*/

-- Excepciones No predefinidas

-- Ejemplo: se desea atrapar la excepcion de querer registrar un valor null

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
/*
Resultado:

    OPERACION DE INSERCION FALLIDA
    ORA-01400: no se puede realizar una inserción NULL en ("HR"."DEPARTMENTS"."DEPARTMENT_NAME")
    
    Procedimiento PL/SQL terminado correctamente.
*/

-- Funciones para atrapar Errores

/*

- SQLCODE: Devuelve el valor numérico para el código de error
- SQLERRM: Devuelve el mensaje asociado con el número de error

*/

-- Atrapando funciones definidas por el usuario (RAISE)

/*  Utilizando RAISE se pueden atrapar excepciones definidas por el usuario.

    - Detiene la ejecución normal de un bloque PL / SQL o subprograma y transfiere el control a un controlador de excepciones
    
    - Explícitamente plantea excepciones predefinidas o excepciones definidas por el usuario


    En el siguiente ejemplo se dispara una excepcion para indicar que el usuario 
    debe ser mayor de edad
*/

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

-- Procedure RAISE_APPLICATION_ERROR

/*
Puede usar este procedimiento para emitir mensajes de error definidos por el usuario de subprogramas almacenados.

Puede reportar errores en su aplicación y evitar volver excepciones no controladas.

Se utiliza en dos lugares diferentes:
    – sección ejecutable
    – sección de excepción

Devuelve condiciones de error al usuario de una manera consistente con otros errores de Oracle Server

Sintaxis

raise_application_error (error_number,
    message[, {TRUE | FALSE}]);

Ejemplo: utilizando en el BEGIN
*/

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

-- Ejemplo: utilizando en el exception

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

/*
Nota:   El parámetro final pasado al procedimiento es un Boolean(true/false) que indica al procedimiento que agregue este error a la pila de errores o reemplace todos los errores de la pila con este error. 
        Pasar el valor de 'True' agrega el error a la pila actual, mientras que el valor predeterminado es 'False'.
*/
