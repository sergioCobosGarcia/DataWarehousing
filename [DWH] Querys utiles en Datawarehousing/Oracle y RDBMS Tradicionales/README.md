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
