require 'csv'
require 'mysql'

stock = Array.new
stock_data = Array.new
db = Mysql.new 'localhost', 'root', 'waheguru13', 'indian_stocks'

CSV.foreach("nse_bhav_copy.csv", :headers => true) do |row| 
	if row[1] == "EQ"
		stock = row[0]
		stock_split = stock.split(" ").first
		db.prepare("INSERT INTO NSE_stocks (
			stock_name)			
		VALUES (?)").execute(
			stock_split)

		CSV.foreach("nse_stocks/#{stock_split}.csv", :headers => true) do |r|
			stock_data << r
		end
		stock_data = stock_data.reverse
		stock_id = db.prepare("SELECT id FROM NSE_stocks WHERE stock_name = ?").execute(stock_split).fetch[0]
		stock_data.each do |s|
			db.prepare("INSERT INTO NSE_stocks_details (
				NSE_stock_id,
				date,
				open,
				high,
				low,
				close,
				volume, 
				turnover)
			VALUES (? , ?, ?, ?, ?, ?, ?, ?)").execute(
				stock_id,
				Date.parse(s[0]).to_s,
				s[1],
				s[2],
				s[3],
				s[5],
				s[6],
				s[7])
		end 		
	end
end