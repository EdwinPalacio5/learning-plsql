CREATE OR REPLACE PROCEDURE SHOW_MENSAJE_PROCEDURE
    (p_message IN varchar2, p_message_completo OUT varchar2) -- parametros
    IS
    p_message_date  DATE := sysdate;
BEGIN
    p_message_completo := 'Message: ' 
                          || p_message 
                          || ' Fecha: ' 
                          || p_message_date;
END;
/

DECLARE
    v_message_completo varchar2(200);
BEGIN
    SHOW_MENSAJE_PROCEDURE('hola a todos',v_message_completo);
    DBMS_OUTPUT.PUT_LINE( v_message_completo);
END;




SET SERVEROUTPUT ON;
ROLLBACK;


CREATE OR REPLACE FUNCTION show_message
    (v_message varchar2) -- parametros
    RETURN  varchar2
    
    IS
    v_message_date      DATE := sysdate;
    v_message_completo   varchar2(200);
BEGIN
    v_message_completo := 'Message: ' 
                          || v_message 
                          || ' Fecha: ' 
                          || v_message_date;
    RETURN v_message_completo;
END;
/



DECLARE
    v_message_completo varchar2(200);
BEGIN
    v_message_completo := show_message('hola a todo');
    DBMS_OUTPUT.PUT_LINE( v_message_completo);
END;

