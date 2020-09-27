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
