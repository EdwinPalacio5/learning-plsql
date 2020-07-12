/* Funcion que permite calcular la renta en base al monto imponible de renta y la periodicidad
 * @parametro: p_monto
 * @parametro: p_periodicidad. 15 si es quincenal, 30 si es mensual
 * Realizado por: Edwin Palacios
 * Fecha de creación 27/06/2020
 * Ultima modificación: 27/06/2020
 * */
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