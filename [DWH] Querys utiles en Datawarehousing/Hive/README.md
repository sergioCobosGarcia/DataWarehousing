# [DWH][Hive] Querys utiles en Datawarehousing


#### UUID (en cada ejecución se genera un id distinto)
~~~~
select cast(hash(uuid())as bigint) as IDunicoAleatorio from  basededatos.tabla
~~~~
#### Sysdate en HIVE
~~~~
select FROM_UNIXTIME(UNIX_TIMESTAMP())
~~~~
#### Hash (en cada ejecución generara el mismo id unico marcado por la clave natural de la tabla que es pasado como parámetro)
~~~~
select cast(hash(tabla.campoclave1,tabla.campoclave2)as bigint) as IDunico from  basededatos.tabla
~~~~

#### Create Table
~~~~
CREATE external TABLE IF NOT EXISTS basededatos.tabla (
Id        bigint,
Codigo           varchar (10),
Descripcion varchar (100),
Numero   int,
IndValido     boolean,
Sysdate      STRING)

COMMENT "Comentario descriptivo de la tabla"
STORED AS PARQUET
LOCATION '/ruta/donde/hive/lee/ficheros_parquet_para_poblar_la_tabla'; 
~~~~

#### Simular MINUS en HIVE con Left Join

~~~~
select distinct(a.some_value)
from table_a a, table_b b
where a.id = b.a_id 
and b.some_id = 123
and b.create_date < '2014-01-01' 
and b.create_date >= '2013-12-01'  
MINUS
select distinct(a.some_value)
from table_a a, table_b b
where a.id = b.a_id 
and b.some_id = 123 
and b.create_date < '2013-12-01' 
~~~~


~~~~
SELECT * FROM
(
  select distinct(a.some_value)
  from table_a a, table_b b
  where a.id = b.a_id 
  and b.some_id = 123
  and b.create_date < '2014-01-01' 
  and b.create_date >= '2013-12-01'  
) x
LEFT JOIN 
(
  select distinct(a.some_value)
  from table_a a, table_b b
  where a.id = b.a_id 
  and b.some_id = 123 
  and b.create_date < '2013-12-01'
) y
ON 
  x.some_value = y.some_value
WHERE 
  y.some_value IS NULL
~~~~

#### If
