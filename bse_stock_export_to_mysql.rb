require 'csv'
require 'mysql'

stock = Array.new
stock_data = Array.new
db = Mysql.new 'localhost', 'root', 'waheguru13', 'indian_stocks'

CSV.foreach("bse_bhav_copy.csv", :headers => true) do |row| 
	if row[3] == "Q"
		stock = row[1]
		stock_split = stock.split(" ").first
		db.prepare("INSERT INTO BSE_stocks (
			stock_name, 
			stock_full_name) 
		VALUES (?, ?)").execute(
			stock_split, 
			stock)
		CSV.foreach("bse_stocks/#{stock_split}.csv", :headers => true) do |r|
			stock_data << r
		end
		stock_data = stock_data.reverse
		stock_id = db.prepare("SELECT id FROM BSE_stocks WHERE stock_name = ?").execute(stock_split).fetch[0]
		stock_data.each do |s|
			db.prepare("INSERT INTO BSE_stocks_details (
				BSE_stock_id,
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
	end
end