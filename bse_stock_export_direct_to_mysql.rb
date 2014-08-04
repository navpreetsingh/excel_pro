require 'csv'
require 'mysql'
require 'open-uri'

stock = Array.new
db = Mysql.new 'localhost', 'root', 'waheguru13', 'indian_stocks'
stock_id = 1
#ss_id = 1
CSV.foreach("bse_bhav_copy.csv", :headers => true) do |row| 
	if row[3] == "Q" 
		t = Time.now
		stock = row
		# stock_split = stock[1].split(" ").first
		# db.prepare("INSERT INTO BSE_stocks (
		# 	stock_name, 
		# 	stock_full_name) 
		# VALUES (?, ?)").execute(
		# 	stock_split, 
		# 	stock[1])
		file = open("http://www.bseindia.com/stockinfo/stockprc2_excel.aspx?scripcd=#{stock[0]}&FromDate=06/25/2014&ToDate=07/12/2014&OldDMY=D")
		stock_data = file.read	
		stock_data = CSV.parse(stock_data)
		stock_data.delete([])
		stock_data.delete_at(0)
		stock_data = stock_data.reverse		
		stock_data.each do |s|
			db.prepare("INSERT INTO bse_stocks_details (
				bse_stock_id,
				date,
				open,
				high,
				low,
				close,
				volume, 
				no_of_trades,
				total_turnover)
			VALUES (? , ?, ?, ?, ?, ?, ?, ?, ?)").execute(
				stock_id,
				Date.parse(s[0]).to_s,
				s[1],
				s[2],
				s[3],
				s[4],
				s[6],
				s[7],
				s[8])
		end
		stock_id += 1 		
		puts "#{stock[1]}: #{Time.now - t}"
	end
	#ss_id += 1
end