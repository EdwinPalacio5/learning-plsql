SET SERVEROUTPUT ON;

-- Funcion que permite recalcular impuestos
CREATE OR REPLACE PROCEDURE recalcular_impuestos(p_id_planilla  planillas.id_planilla%TYPE, p_periodicidad anios_laborales.periodicidad%TYPE) 
    IS
    -- cursor de impuestos
    CURSOR cur_impuestos 
        (p_id_planilla  planillas.id_planilla%TYPE)  
        IS 
        SELECT pm.id_planilla_movimiento, tm.*
        FROM planillas p
            JOIN planilla_movimientos pm ON (p.id_planilla = pm.id_planilla) 
            JOIN tipos_movimiento tm ON (pm.id_movimiento = tm.id_movimiento)
        WHERE (tm.tipo_movimiento_habilitado = 1 
                AND tm.es_descuento = 1 
                AND tm.movimiento IN ('ISSS', 'ISSS PATRONAL', 'AFP', 'AFP PATRONAL')); 
    
    -- declaracion de variables
    v_planilla_empleado     planillas%ROWTYPE;  
    v_salario_base          empleados.salario_base_mensual%TYPE := 0;
    v_salario_devengado     planillas.salario_neto%TYPE := 0;
    v_impuesto_isss_afp     planilla_movimientos.monto_movimiento%TYPE := 0;
    v_salario_base_renta    planillas.renta%TYPE := 0;
    v_renta                 planillas.renta%TYPE := 0;
    
    
BEGIN
    -- Se obtiene salario base
    SELECT e.salario_base_mensual 
    INTO v_salario_base
    FROM empleados e
    JOIN planillas p ON (e.id_empleado = p.id_empleado)
    WHERE id_planilla = p_id_planilla;
    
    -- Se obtiene la planilla 
    SELECT p.* 
    INTO v_planilla_empleado
    FROM planillas p
    WHERE id_planilla = p_id_planilla;
    
    IF (SQL%ROWCOUNT > 0) THEN
    
        IF p_periodicidad = 15 THEN
           v_salario_base := v_salario_base/2;
        END IF;
        
        -- obtenemos salario devengado
        v_salario_devengado :=  v_salario_base  
                                + v_planilla_empleado.monto_comision
                                + v_planilla_empleado.monto_horas_extra
                                + v_planilla_empleado.monto_dias_festivos
                                + v_planilla_empleado.total_ingresos;
        
        -- se recorre cada uno de los impuestos
        FOR rec_impuestos IN cur_impuestos(p_id_planilla)
        LOOP
            IF v_salario_devengado > rec_impuestos.monto_maximo THEN
                IF rec_impuestos.movimiento IN ('ISSS', 'AFP') THEN
                    v_impuesto_isss_afp := v_impuesto_isss_afp + ((rec_impuestos.monto_maximo*rec_impuestos.porcentaje_movimiento)/100);
                END IF;
                UPDATE planilla_movimientos 
                SET monto_movimiento = ((rec_impuestos.monto_maximo*rec_impuestos.porcentaje_movimiento)/100)
                WHERE id_planilla_movimiento = rec_impuestos.id_planilla_movimiento;
            ELSE
                IF rec_impuestos.movimiento IN ('ISSS', 'AFP') THEN
                    v_impuesto_isss_afp := v_impuesto_isss_afp + ((v_salario_devengado*rec_impuestos.porcentaje_movimiento)/100);
                END IF;
                UPDATE planilla_movimientos 
                SET monto_movimiento = ((v_salario_devengado*rec_impuestos.porcentaje_movimiento)/100)
            WHERE id_planilla_movimiento = rec_impuestos.id_planilla_movimiento;
           END IF;
        END LOOP;
        
        -- calculo de renta
        v_salario_base_renta := v_salario_devengado - v_impuesto_isss_afp;
        
        update planillas set renta = calcular_renta(v_salario_base_renta, p_periodicidad)
        WHERE id_planilla = p_id_planilla;
        
    END IF;
END;
/  

-- Funcion que permite calcular la renta
CREATE OR REPLACE FUNCTION calcular_renta(p_monto  planillas.renta%TYPE, p_periodicidad anios_laborales.periodicidad%TYPE)
    RETURN  empleados.salario_base_mensual%TYPE
    IS
    -- cursor de rangos
    CURSOR cur_rangos_renta 
        (p_periodicidad anios_laborales.periodicidad%TYPE)  
        IS 
        SELECT *
        FROM rangos_renta
        WHERE (periodicidad_renta = p_periodicidad); 
    -- variables
    v_renta     planillas.renta%TYPE := 0;
BEGIN
    FOR rec_rangos_renta IN cur_rangos_renta(p_periodicidad) 
    LOOP
        IF p_monto >= rec_rangos_renta.salario_min AND p_monto <= rec_rangos_renta.salario_max THEN
           v_renta :=  (p_monto - rec_rangos_renta.exceso)*(rec_rangos_renta.porcentaje_renta/100) + rec_rangos_renta.cuota_fija;    
        END IF;
    END LOOP;
    return v_renta;
END;
/  

Declare
    v_monto number;
Begin
    v_monto := calcular_renta(907.50,30);
    DBMS_OUTPUT.PUT_LINE(v_monto);
End;
