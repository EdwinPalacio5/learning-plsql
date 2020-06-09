-- Triggers
/*
CREATE [OR REPLACE] TRIGGER trigger_name
    {BEFORE | AFTER} 
    {DELETE | INSERT | UPDATE [OF col1, col2, ... , colN]
    [OR {DELETE | INSERT | UPDATE [OF col1, col2, ... , colN]
    ...]}
    ON tabla_name
    
    [FOR EACH ROW [WHEN condition]]

[DECLARE]
    -- variables locales
BEGIN
    -- sentencias
[EXCEPTION]
    -- Sentencias control de exception
END trigger_name;
*/

-- Ejemplo de trigger: al modificar el salario se modificará el hire_date a la fecha actual

CREATE OR REPLACE TRIGGER  trigger_au_reset_fecha
    BEFORE
    UPDATE OF salary ON employees
    
    FOR EACH ROW
BEGIN
    :NEW.hire_date := sysdate; -- se actualiza la fecha de contratacion del registro afectado
END;
/

-- provocamos que se active el trigger
UPDATE employees SET salary = 40000
    Where employee_id = 100;
    
-- verificamos que se haya ejecutado de manera correcta
Select employee_id, salary, hire_date
From employees
Where employee_id = 100;

/*
Resultado:
    
    Trigger TRIGGER_AU_RESET_FECHA compilado


    1 fila actualizadas.
    
    
    EMPLOYEE_ID     SALARY HIRE_DAT
    ----------- ---------- --------
            100      40000 08/06/20
            
Nota:   Observar que este es un caso especial, dado que se desea actualizar la misma tabla que ya se está actualizando, 
        por lo que es necesario tener el cuidado de que se ejecute antes (BEFORE) y solo trabajar actualizar los :NEW (como es evidente)
*/

