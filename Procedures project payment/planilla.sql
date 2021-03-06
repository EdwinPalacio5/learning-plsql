/* Procedimiento para realizar el pago de planilla
 * @parametro: id de la unidad a pagar planilla (Parametro de entrada)
 * @parametro: mensaje que indica el resultado de la ejecuci�n del procedimiento (Parametro de salida)
 * Realizado por: Edwin Palacios
 * Fecha de creaci�n 18/06/2020
 * Ultima modificaci�n: 29/06/2020
 * */

CREATE OR REPLACE PROCEDURE PAGO_PLANILLA
    (p_id_unidad IN NUMBER, p_message OUT varchar2) -- parametros
    IS
    
    -- obtenemos las planillas sobre las que se calcular� el salario neto 
    CURSOR cur_planillas (p_id_unidad NUMBER) IS  
        SELECT p.*, e.salario_base_mensual, e.horas_trabajo
        FROM unidades_organizacionales u 
        JOIN empleados_puestos_unidades epu ON (u.id_unidad_organizacional = epu.id_unidad_organizacional)
        JOIN empleados e ON (epu.id_empleado=e.id_empleado)
        JOIN planillas p ON (e.id_empleado=p.id_empleado)
        JOIN periodos  pe ON (p.id_periodo = pe.id_periodo)
        WHERE (u.id_unidad_organizacional= p_id_unidad AND e.empleado_habilitado = 1 AND epu.fecha_fin IS NULL AND pe.activo = 1 AND p.fecha_emision IS NULL);
    
    -- declaracion de variables
    
    v_periodos_rec          periodos%rowtype;    -- registro para manejar los periodos (actual para cerrarlo y siguiente para abrirlo)
    v_periodicidad          anios_laborales.periodicidad%TYPE;  -- el tipo de periodicidad: si es mensual(30) o quincenal (15)
    v_presupuesto_unidad    centros_costos.presupuesto_asignado%TYPE := 0;  -- presupuesto actual de la unidad
    v_id_centro_costo       centros_costos.id_centro_costo%TYPE;
    v_num_unidades_faltantes    number;
    
    -- Por empleado
    v_salario_base          empleados.salario_base_mensual%type := 0; -- Salario base con el que cuenta el empleado
    v_plan_ingreso          empleados.salario_base_mensual%type := 0; -- monto de plan de ingreso (si cuenta con uno)
    v_plan_descuento        empleados.salario_base_mensual%type := 0; -- monto de plan descuento (si cuenta con uno)
    v_salario_devengado     empleados.salario_base_mensual%type := 0; -- salario base + ingresos(ingresos comunes, horas extra, comision, dias festivos, plan de ingreso, etc)
    v_aportacion_patronal   empleados.salario_base_mensual%type := 0; -- sumatoria de isss patronal, afp patronal y otros movimientos patronales  
    v_descuentos_empleado   empleados.salario_base_mensual%type := 0; -- sumatoria de isss + afp + renta + plan de descuentos + otros descuentos  
    v_valor_neto_a_pagar    empleados.salario_base_mensual%type := 0; -- salario devengado - descuentos de empleado
    
    -- Global
    v_total_pago_planilla   empleados.salario_base_mensual%type := 0; -- Es el gasto patronal: (valor neto a pagar + aportacion patronal) por cada empleado
BEGIN

    -- Obtenemos el periodo actual
    SELECT p.* 
    INTO v_periodos_rec
    FROM anios_laborales a
         JOIN periodos p ON (a.id_anio_laboral = p.id_anio_laboral)
    WHERE p.activo = 1; 
    -- Si existe periodo
    IF (SQL%ROWCOUNT > 0) THEN
        -- Obtenemos el presupuesto actual de la unidad y la periodicidad 
        SELECT (c.presupuesto_asignado - c.presupuesto_devengado) as "presupuesto_actual", a.periodicidad, c.id_centro_costo
        INTO v_presupuesto_unidad, v_periodicidad, v_id_centro_costo
        FROM unidades_organizacionales u
            JOIN centros_costos c ON (u.id_unidad_organizacional = c.id_unidad_organizacional)
            JOIN anios_laborales a ON (c.id_anio = a.id_anio_laboral)
        WHERE u.id_unidad_organizacional = p_id_unidad AND a.anio_laboral = TO_CHAR(SYSDATE,'yyyy');
        
        -- recorremos las planillas para verificar si el presupuesto es suficiente 
        FOR rec_planilla IN cur_planillas(p_id_unidad)
        LOOP
            -- definimos el salario base seg�n periodicidad
            IF (v_periodicidad = 30) THEN
                v_salario_base := rec_planilla.salario_base_mensual;
            ELSE
                v_salario_base := rec_planilla.salario_base_mensual/2;
            END IF;
            
            v_plan_ingreso := obtener_plan(rec_planilla.id_empleado,v_periodicidad ,0); 
            v_plan_descuento := obtener_plan(rec_planilla.id_empleado,v_periodicidad ,1);       
            v_salario_devengado :=  + v_salario_base  
                                    + v_plan_ingreso
                                    + rec_planilla.monto_comision
                                    + rec_planilla.monto_horas_extra
                                    + rec_planilla.monto_dias_festivos
                                    + rec_planilla.total_ingresos;
                                    
            -- consultamos aportes patronales
            SELECT nvl(SUM(pm.monto_movimiento),0) 
            INTO v_aportacion_patronal
            FROM planilla_movimientos pm
            JOIN tipos_movimiento tm ON (pm.id_movimiento = tm.id_movimiento)
            Where pm.id_planilla = rec_planilla.id_planilla AND tm.es_patronal = 1;                        
            
            v_descuentos_empleado := rec_planilla.renta 
                                    + rec_planilla.total_descuentos
                                    + v_plan_descuento;
            
            v_valor_neto_a_pagar := v_salario_devengado - v_descuentos_empleado; 
                                   
            v_total_pago_planilla := v_total_pago_planilla 
                                    + v_salario_devengado
                                    + v_aportacion_patronal;
                                    
            -- actualizamos la planilla del empleado
            UPDATE planillas SET fecha_emision = SYSDATE, salario_neto = v_valor_neto_a_pagar
            WHERE id_planilla = rec_planilla.id_planilla;  
                             
            -- Si el presupuesto no es suficiente se sale del ciclo
            -- EXIT WHEN (v_total_pago_planilla > v_presupuesto_unidad);
        END LOOP;

         -- Despues de recorrer todas las planillas se valida si el presupuesto fue suficiente para pagar planilla
        IF (v_total_pago_planilla > v_presupuesto_unidad) THEN
            p_message := 'Presupuesto no suficiente. El presupuesto actual es de '
                         || to_char(v_presupuesto_unidad,'$99,999.99') 
                         || ' y el pago requerido es de '
                         || to_char(v_total_pago_planilla,'$99,999.99'); 
            ROLLBACK;
        ELSE
            -- actualizamos el centro de costo de la planilla
            UPDATE centros_costos SET presupuesto_devengado= presupuesto_devengado + v_total_pago_planilla
            WHERE id_centro_costo = v_id_centro_costo;
            
            -- Consultamos si existe una unidad mas que falte de pagar
            SELECT COUNT(*)
            INTO v_num_unidades_faltantes
            FROM unidades_organizacionales uo
            NATURAL JOIN empleados_puestos_unidades epu
            NATURAL JOIN empleados e
            NATURAL JOIN planillas p
            WHERE epu.fecha_fin IS NULL AND e.empleado_habilitado = 1 AND p.fecha_emision IS NULL;
            
            -- si no hay mas unidades que falten por pagar
            IF(v_num_unidades_faltantes = 0) THEN
                -- Cerramos el periodo actual
                UPDATE periodos SET activo = 0
                WHERE id_periodo = v_periodos_rec.id_periodo;
                -- Abrimos el periodo siguiente 
                UPDATE periodos SET activo = 1
                WHERE id_periodo = (v_periodos_rec.id_periodo + 1);
            END IF;
            
            p_message := 'Pago realizado de manera exitosa. El presupuesto actual es de '
                         || to_char((v_presupuesto_unidad - v_total_pago_planilla),'$99,999.99')
                         || ' El cobro realizado fue de '
                         || to_char(v_total_pago_planilla,'$99,999.99');
                         
            COMMIT;
        END IF;
    ELSE
        p_message := 'No existe un periodo activo. Por favor revisar';
    END IF;
END;