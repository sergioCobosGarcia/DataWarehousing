--Desde usuario SYSTEM o usuario con rol SYSDBA

grant create any procedure to SCHEMAXXXXX;		 
grant execute any procedure to SCHEMAXXXXX;

--Creación de la tabla en SCHEMAXXXXX

drop table DIM_TIEMPO;
create table DIM_TIEMPO
(
    FechaSK number not null,
    Fecha date not null PRIMARY KEY,
    Año number not null,
    Trimestre number not null,
    Mes number not null,
    Semana number not null,
    Dia number not null,
    DiaSemana number not null,
    NTrimestre varchar2(7) not null,
    NMes varchar2(15) not null,
    NMes3L varchar2(3) not null,
    NSemana varchar2(10) not null,
    NDia varchar2(6) not null,
    NDiaSemana varchar2(10) not null
   
);

--Procedimiento

CREATE OR REPLACE PROCEDURE CARGADIMTIEMPO19892040 IS
tmpVar NUMBER;
FechaDesde date;
FechaHasta date;
FechaDesdeStr VARCHAR2(8);
err_num NUMBER;
err_msg VARCHAR2(255);
BEGIN
tmpVar := 0;
FechaDesde := TO_DATE('19891231','YYYYMMDD');
FechaHasta := TO_DATE('20401231','YYYYMMDD');
WHILE FechaDesde <= FechaHasta LOOP
FechaDesdeStr := to_char( FechaDesde, 'YYYYMMDD') ;
INSERT INTO DIM_TIEMPO
(
FechaSK,
Fecha,
Año,
Trimestre,
Mes,
Semana,
Dia,
DiaSemana,
NTrimestre,
NMes,
NMes3L,
NSemana,
NDia,
NDiaSemana
)
VALUES
(
to_char(TO_DATE( FechaDesdeStr,'YYYYMMDD') ,'YYYYMMDD'),
FechaDesde,
to_char(TO_DATE( FechaDesdeStr,'YYYYMMDD'),'YYYY'),
to_char(TO_DATE( FechaDesdeStr,'YYYYMMDD'), 'Q'),
to_char(TO_DATE( FechaDesdeStr,'YYYYMMDD'),'MM'),
to_char(TO_DATE( FechaDesdeStr,'YYYYMMDD'),'WW'),
to_char(TO_DATE( FechaDesdeStr,'YYYYMMDD'),'DD'),
to_char(TO_DATE( FechaDesdeStr,'YYYYMMDD'),'D'),
'T'||to_char(TO_DATE( FechaDesdeStr,'YYYYMMDD'), 'Q')||'/'||to_char(TO_DATE( FechaDesdeStr,'YYYYMMDD'),'YY'),
to_char(TO_DATE( FechaDesdeStr,'YYYYMMDD'),'MONTH'),
to_char(TO_DATE( FechaDesdeStr,'YYYYMMDD'),'MON'),
'Sem '||to_char(TO_DATE( FechaDesdeStr,'YYYYMMDD'),'WW')||'/'||to_char(TO_DATE( FechaDesdeStr,'YYYYMMDD'),'YY'),
to_char(TO_DATE( FechaDesdeStr,'YYYYMMDD'),'DD MON'),
to_char(TO_DATE( FechaDesdeStr,'YYYYMMDD'),'DAY')

);
-- Incremento del bucle
commit ;
FechaDesde := FechaDesde + 1;
END LOOP;
EXCEPTION
WHEN NO_DATA_FOUND THEN
NULL;
WHEN OTHERS THEN
-- Consider logging the error and then re-raise
err_num := SQLCODE;
err_msg := SQLERRM;
DBMS_OUTPUT.put_line('Error Problemas :'||TO_CHAR(err_num) || ' ' || err_msg );
DBMS_OUTPUT.put_line(err_msg);
END CARGADIMTIEMPO19892040;


--compilar

--ejecutar

--comprobar
