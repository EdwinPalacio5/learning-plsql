/* Procedimiento que permite recalcular isss, afp y renta de una planilla
 * @parametro: p_id_planilla
 * @parametro: p_periodicidad. 15 si es quincenal, 30 si es mensual
 * Realizado por: Edwin Palacios
 * Fecha de creación 27/06/2020
 * Ultima modificación: 27/06/2020
 * */
CREATE OR REPLACE PROCEDURE RECALCULAR_IMPUESTOS(p_id_planilla  planillas.id_planilla%TYPE, p_periodicidad anios_laborales.periodicidad%TYPE) 
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
                AND tm.id_movimiento IN (500,501,502,503)
                AND p.id_planilla = p_id_planilla); 
    
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
                IF rec_impuestos.id_movimiento IN (500,502) THEN
                    v_impuesto_isss_afp := v_impuesto_isss_afp + ((rec_impuestos.monto_maximo*rec_impuestos.porcentaje_movimiento)/100);
                END IF;
                UPDATE planilla_movimientos 
                SET monto_movimiento = ((rec_impuestos.monto_maximo*rec_impuestos.porcentaje_movimiento)/100)
                WHERE id_planilla_movimiento = rec_impuestos.id_planilla_movimiento;
            ELSE
                IF rec_impuestos.id_movimiento IN (500,502) THEN
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
    --COMMIT;
END;