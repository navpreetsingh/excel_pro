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


SELECT * FROM `bse4_trends`
inner join bse_stocks
on bse_stocks.id = bse4_trends.bse_stock_id
inner join bse_stocks_details
on bse_stocks_details.bse_stock_id = bse4_trends.bse_stock_id
where bse4_trends.d7_t > 0
and bse4_trends.d3_t > 0 
and bse_stocks_details.DATE =  "2014-06-24"
and bse_stocks_details.bs_signal = 1
order by bse4_trends.avg_high desc



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
bse_stocks_details.date in ("2013-10-21", "2013-10-18") and
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

# to delete stocks having volume less than 3
delete `bse_stocks_details` FROM `bse_stocks_details`
left join bse_stocks on
bse_stocks.id = bse_stocks_details.bse_stock_id
where bse_stocks.vol_category < 3

mysqldump --opt --user=root --password=waheguru13 indian_stocks bse_stocks_details  --where="date='2014-07-14'" > bse_stocks_details.sql
mysqldump --opt --user=root --password=waheguru13 indian_stocks nse_dumps  --where="date='2014-08-05'" > nse_dumps.sql
mysqldump --opt --user=root --password=waheguru13 indian_stocks nse_stocks_details  --where="date='2014-08-05'" > nse_stocks_details.sql

#to know the stock which is not updated
SELECT *, count(*) as cn FROM `bse_stocks_details`
left join bse_stocks on
bse_stocks.id = bse_stocks_details.bse_stock_id
group by bse_stocks_details.bse_stock_id 
having cn < 32

#to bring new data from dump in stock details
INSERT INTO `nse_stocks_details` (nse_stock_id, date, open, high, low, close, volume, turnover) 
SELECT nse_stock_id, date, open, high, low, close, volume, turnover FROM `nse_dumps`
where nse_dumps.nse_stock_id in (27, 185, 633, 672, 826, 938, 1049, 1106) AND
nse_dumps.date >= "2014-06-03"

INSERT INTO `bse_stocks_details` (bse_stock_id, date, open, high, low, close, volume, no_of_trades, total_turnover) 
SELECT bse_stock_id, date, open, high, low, close, volume, no_of_trades, total_turnover FROM `bse_dumps`
where bse_dumps.bse_stock_id in (411, 667, 696, 719, 905, 947, 1017, 1703, 1812, 1870, 2007, 2135, 2154, 2198, 2277, 2651, 2656, 2674, 2696, 2767, 2839, 3020, 3080, 3124) AND
bse_dumps.date >= "2014-06-03"

#to delete stocks havin vol < 3
delete FROM `bse_stocks_details`
where bse_stock_id in


INSERT INTO `nse_year_details` (nse_stock_id, year, open, high, low, close, volume)
SELECT nse_stock_id, DATE_FORMAT(date, "%Y") as year, 
SUBSTRING_INDEX( GROUP_CONCAT( CAST( OPEN AS CHAR ) ORDER BY DATE ) ,  ',', 1 ) AS OPEN, 
max(high) AS high, min(low) AS low, 
SUBSTRING_INDEX(GROUP_CONCAT(CAST(close AS CHAR) ORDER BY date DESC), ',', 1) AS close, 
sum(volume) AS volume 
FROM `nse_dumps` 
WHERE nse_stock_id in (
SELECT id FROM `nse_stocks`
where vol_category >= 2
and useless_stock=1
)  
GROUP BY DATE_FORMAT(date, "%Y"),
nse_stock_id 
ORDER by nse_stock_id ASC

update `nse_month_details`
set oh_diff = (((high - open) / open) * 100),
ol_diff = (((low - open) / open) * 100),
oc_diff = (((close - open) / open) * 100),
bs_signal = 1 where close > open


INSERT INTO `nse_month_details` (nse_stock_id, date, open, high, low, close, volume, date1)
SELECT nse_stock_id, DATE_FORMAT(date, "%M, %Y") as date, 
SUBSTRING_INDEX( GROUP_CONCAT( CAST( OPEN AS CHAR ) ORDER BY DATE ) ,  ',', 1 ) AS OPEN, 
max(high) AS high, min(low) AS low, 
SUBSTRING_INDEX(GROUP_CONCAT(CAST(close AS CHAR) ORDER BY date DESC), ',', 1) AS close, 
sum(volume) AS volume,
MAX(date) AS date1 
FROM `nse_dumps` 
WHERE nse_stock_id in (
SELECT id FROM `nse_stocks`
where vol_category >= 2
and useless_stock=1
)  
GROUP BY DATE_FORMAT(date, "%M, %Y"),
nse_stock_id 
ORDER by nse_stock_id, date1 asc



INSERT INTO `nse_week_details` (nse_stock_id, date, open, high, low, close, volume, date1)
SELECT nse_stock_id, DATE_FORMAT(date, "%X Week: %V") as date, 
SUBSTRING_INDEX( GROUP_CONCAT( CAST( OPEN AS CHAR ) ORDER BY DATE ) ,  ',', 1 ) AS OPEN, 
max(high) AS high, min(low) AS low, 
SUBSTRING_INDEX(GROUP_CONCAT(CAST(close AS CHAR) ORDER BY date DESC), ',', 1) AS close, 
sum(volume) AS volume,
MAX(date) AS date1 
FROM `nse_dumps` 
WHERE nse_stock_id in (
SELECT id FROM `nse_stocks`
where vol_category >= 2
and useless_stock=1
)  
GROUP BY DATE_FORMAT(date, "%X Week: %V"),
nse_stock_id 
ORDER by nse_stock_id, date1 asc


SELECT * FROM `nse_week_details`
left join nse_stocks on
nse_stocks.id = nse_week_details.nse_stock_id
where  nse_week_details.date = "2014 Week: 31"
order by  nse_week_details.oc_diff desc


SELECT * FROM `nse_week_details` n1
left join nse_stocks n2 on 
n1.nse_stock_id = n2.id
where n1.date1 = "2014-08-08"
order by n1.oc_diff desc

#TOP WEEKLY STOCKS
SELECT nse_stock_id, sum(bs_signal), n2.stock_name FROM `nse_week_details` n1
left join nse_stocks n2 on 
n1.nse_stock_id = n2.id
where n1.date1 > "2014-06-27"
group by n1.nse_stock_id
ORDER BY sum(bs_signal)  DESC

#TOP MONTHLY STOCKS
SELECT nse_stock_id, sum(bs_signal), n2.stock_name FROM `nse_month_details` n1
left join nse_stocks n2 on 
n1.nse_stock_id = n2.id
where n1.date1 > "2014-04-30"
group by n1.nse_stock_id
ORDER BY sum(bs_signal)  DESC


