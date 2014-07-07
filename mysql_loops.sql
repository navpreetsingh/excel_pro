SELECT AVG(VOLUME) FROM `BSE_stocks_details`
WHERE BSE_stock_id = 3161 
ORDER BY date ASC
LIMIT 5

#to calculate volume of last 2 days
SELECT avg(volume) FROM 
(SELECT VOLUME FROM `BSE_stocks_details`
WHERE BSE_stock_id = 3161
ORDER BY date DESC
LIMIT 2) S

#Loop for high vol. stocks
DROP PROCEDURE IF EXISTS BSE_volume;
DELIMITER //
CREATE PROCEDURE BSE_volume()
   	BEGIN
    	DECLARE a INT Default 1 ;
    	DECLARE c INT DEFAULT 1;
    	DECLARE average INT DEFAULT 1;    	
    	SELECT COUNT(*) FROM  `BSE_stocks`;
    	SET c = COUNT(*);
    	WHILE a < c DO
	        SELECT avg(volume) FROM 
				(SELECT VOLUME FROM `BSE_stocks_details`
				WHERE BSE_stock_id = a
				ORDER BY date DESC
				LIMIT 30) S;
			SET average = avg(volume);
			IF average > 10000 THEN         
	        	insert into BSE_stocks (vol_category) values (1);
	        END IF;
	        SET a=a+1;	         
   		END WHILE;
	END//

	#Loop for high vol. stocks
	DROP PROCEDURE IF EXISTS ll;
	DELIMITER //
	CREATE PROCEDURE indian_stocks.ll()
	   	BEGIN
	    	DECLARE a INT Default 1 ;
	    	DECLARE c INT DEFAULT 1;	    	
	    	SELECT COUNT(*) FROM  `BSE_stocks`;
	    	SET c = COUNT(*);
	    	WHILE a < c DO
		        	update BSE_stocks set lp = a + 1 where id = a;		        
		        SET a=a+1;	         
	   		END WHILE;
		END//


SHOW PROCEDURE STATUS;
SHOW FUNCTION STATUS;

SELECT * FROM `bse_stocks_details`
INNER JOIN bse_stocks
on bse_stocks.id = bse_stocks_details.bse_stock_id
where bse_stocks_details.bse_stock_id in (384,365, 162, 343, 651, 2398, 2857, 1987, 554, 983) and
bse_stocks_details.date = "2013-10-21"

#going up for last 3 days
SELECT * FROM `bse4p_trends` 
where d3_t = 3 and
date = "2013-10-18" 
order by avg_high desc
limit 10

#t7 & t3 r +ive and current day is also positive
SELECT * FROM `bse4p_trends` 
inner join bse_stocks_details on
bse_stocks_details.bse_stock_id = bse4p_trends.bse_stock_id
where bse4p_trends.d3_t > 0 and
bse4p_trends.d7_t > 0 and 
bse4p_trends.date = "2013-10-18" and
bse_stocks_details.date = "2013-10-18" and
bse_stocks_details.bs_signal = 1
order by bse4p_trends.avg_high desc
limit 10

#t7 & t3 r +ive and current day is negative
SELECT * FROM `bse4p_trends` 
inner join bse_stocks_details on
bse_stocks_details.bse_stock_id = bse4p_trends.bse_stock_id
where bse4p_trends.d3_t > 0 and
bse4p_trends.d7_t > 0 and 
bse4p_trends.date = "2013-10-18" and
bse_stocks_details.date = "2013-10-18" and
bse_stocks_details.bs_signal = -1
order by bse4p_trends.avg_high desc
limit 10


