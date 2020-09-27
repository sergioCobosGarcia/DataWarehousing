# [DWH][Oracle] Querys utiles en Datawarehousing


#### Modificar tipo de dato
~~~~
ALTER TABLE table_name
MODIFY column_name datatype;
~~~~
#### Renombrar Columnas
~~~~
ALTER TABLE table_name 
RENAME COLUMN old_name to new_name;
~~~~

#### Añadir Columna

~~~~
ALTER TABLE table_name 
ADD column_name Varchar2(35 CHAR);
~~~~
#### Borrar Columna
~~~~
ALTER TABLE table_name 
drop COLUMN column_name;
~~~~
#### Hacer Campo Nullable
~~~~
alter table
   nombre_tabla
modify
   (nom_columna NULL);
~~~~
#### Borrar FK
~~~~
delete from schema.table_name
WHERE CONS_NAME='constraint'
~~~~
#### Borrado columnas ocultas en tablas particionadas

~~~~

-- 1. Comprobación de que las tablas tienen diferente estructuras
 
 
Select a.COLUMN_NAME
  , a.DATA_TYPE, b.DATA_TYPE
  , a.data_length, b.data_length
  , a.data_precision, b.data_precision
  , a.data_scale, b.data_scale
  , a.nullable, b.nullable
  , a.default_length, b.default_length
from ALL_TAB_COLUMNS a
full outer join ALL_TAB_COLUMNS b on a.column_name=b.column_name
 and b.owner=user and b.table_name='table2'
 where  a.owner=user and a.table_name='table1'  
 and (
    nvl(a.data_type,'#')!=nvl(b.data_type,'#')
    or nvl(a.data_length,-1)!=nvl(b.data_length,-1)
    or nvl(a.data_precision,-100)!=nvl(b.data_precision,-100)
    or nvl(a.data_scale,-100)!=nvl(b.data_scale,-100)
    or nvl(a.nullable,'#')!=nvl(b.nullable,'#')
    or nvl(a.default_length,-1)!=nvl(b.default_length,-1)
   ) ;
 
 
 
 
-- 2. Comprobación si la tabla tiene columnas ocultas
 
SELECT * FROM user_tab_cols WHERE table_name = :NOMBRE_TABLA AND hidden_column = 'YES';
 
-- 3. Movemos las particiones de lugar (ejecutar sentencias resultado de la consulta)
 
SELECT 'alter table '   || t.table_name ||
       ' move partition ' || t.partition_name ||
       ' nocompress;' as res
FROM    user_tab_partitions t
WHERE   t.table_name = :NOMBRE_TABLA;
 
-- 3.b. Si la tabla está subparticionada, buscamos las subparticiones que tiene compresion
SELECT 'alter table '   || t.table_name ||
       ' move subpartition ' || t.subpartition_name ||
       ' nocompress;' as res
FROM    user_tab_subpartitions t
WHERE   t.table_name = :NOMBRE_TABLA and t.compression!='DISABLED';
 
 
-- 4. Borrado de columnas
 
ALTER TABLE nombre_tabla DROP UNUSED COLUMNS ;
 
-- 5. Regenerar índice (ejecutar sentencias resultado de la consulta)
 
SELECT  'ALTER INDEX ' || uip.index_name || ' REBUILD PARTITION ' || uip.partition_name || ';' AS res
  FROM    user_tab_partitions   utp
         ,user_ind_partitions   uip
  WHERE   utp.partition_name    = uip.partition_name
    AND   utp.table_name        = :NOMBRE_TABLA;

~~~~

#### Procedimiento reconstrucción Index para tablas particionadas y subparticionadas

~~~~
create or replace PROCEDURE P_REBUILD_INDEXES(

      p_owner      VARCHAR2,

      p_table_name VARCHAR2)

  IS

    v_stmt        VARCHAR2(4000) ;

  BEGIN

 

  /* p_rebuild_tab_unusable_indexes */

  

  

    FOR i_unusable_part IN

    (SELECT table_owner,

      table_name,

      index_name,

      partition_name,

      subpartition_name,

      status

    FROM

      (SELECT table_owner,

        table_name,

        index_name,

        NULL partition_name,

        NULL subpartition_name,

        status

      FROM all_indexes

      WHERE 1         =1

      AND table_owner =p_owner

      AND table_name  = p_table_name

      AND partitioned = 'NO'

      UNION

      SELECT i.table_owner,

        i.table_name table_name,

        ip.index_name,

        ip.partition_name,

        NULL subpartition_name,

        ip.status

      FROM all_ind_partitions ip,

        all_indexes i

      WHERE ip.index_name =I.INDEX_NAME

      AND ip.INDEX_OWNER  =i.OWNER

      AND I.TABLE_OWNER   =p_owner

      AND I.TABLE_NAME    =p_table_name

      UNION

      SELECT i.table_owner,

        i.table_name table_name,

        isp.index_name,

        NULL partition_name,

        isp.subpartition_name,

        isp.status

      FROM all_ind_subpartitions isp,

        all_indexes i

      WHERE isp.index_name =I.INDEX_NAME

      AND isp.INDEX_OWNER  =i.OWNER

      AND I.TABLE_OWNER    =p_owner

      AND I.TABLE_NAME     =p_table_name

      )

    WHERE status='UNUSABLE'

    ORDER BY partition_name nulls FIRST,

      index_name

    )

  

    LOOP

      IF (i_unusable_part.partition_name IS NULL AND i_unusable_part.subpartition_name IS NULL ) THEN

        v_stmt                           :='ALTER INDEX '||i_unusable_part.table_owner||'.'||i_unusable_part.index_name ||' REBUILD PARALLEL (DEGREE 2)';

        DBMS_OUTPUT.PUT_LINE (v_stmt);

        EXECUTE immediate v_Stmt;

      elsif (i_unusable_part.subpartition_name IS NULL ) THEN

        v_stmt                                 :='ALTER INDEX '||i_unusable_part.table_owner||'.'||i_unusable_part.index_name ||' REBUILD PARTITION '||i_unusable_part.partition_name;

        DBMS_OUTPUT.PUT_LINE (v_stmt);

       EXECUTE immediate v_Stmt;

     ELSE

        v_stmt :='ALTER INDEX '||i_unusable_part.table_owner||'.'||i_unusable_part.index_name ||' REBUILD SUBPARTITION '||i_unusable_part.subpartition_name;

        DBMS_OUTPUT.PUT_LINE (v_stmt);

        EXECUTE immediate v_Stmt;

      END IF;

    END LOOP;

  END;
~~~~

#### Estadisticas particiones

~~~~
BEGIN DBMS_STATS.GATHER_TABLE_STATS (OWNNAME => 'schema', TABNAME => 'tabla', GRANULARITY => 'PARTITION', PARTNAME=> 'nombreparticion', degree=> 4); END;
~~~~

#### Query DataProfiling
~~~~
SELECT 'schema.tabla' AS Tabla,
'campo' AS Campo, count(*) AS Registros,
SUM(CASE WHEN campo IS NULL THEN 1 ELSE 0 END) AS Nulos,
SUM(CASE WHEN REGEXP_INSTR('NUMBER(5,0)','VARCHAR2')=1 THEN CASE WHEN campo IS NULL THEN 1 ELSE 0 END ELSE 0 END) AS Blancos
,SUM(CASE WHEN REGEXP_INSTR('NUMBER(5,0)','NUMBER')=1 THEN CASE WHEN campo =0 THEN 1 ELSE 0 END ELSE 0 END) AS Ceros
FROM schema.Tabla;
~~~~