DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
 OrderId int,
 order_date string,
 UserId int,
 UserName string,
 Gender string,
 OrderTotal int,
 itemlist string
) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t';

LOAD DATA LOCAL INPATH 'shop.tsv' OVERWRITE INTO TABLE orders;
