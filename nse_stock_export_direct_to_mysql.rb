require 'csv'
require 'mysql'
require 'open-uri'

stock = Array.new
stock_data = Array.new
db = Mysql.new 'localhost', 'root', 'waheguru13', 'indian_stocks'
stock_id = 1
CSV.foreach("nse_bhav_copy.csv", :headers => true) do |row| 
	if row[1] == "EQ" && stock_id < 1001
		t = Time.now
		stock = row[0]
		db.prepare("INSERT INTO NSE_stocks (
			stock_name)			
		VALUES (?)").execute(
			stock)
		stock = stock.gsub("&", "%26") if stock.include?("&")
		file = open("http://www.nseindia.com/live_market/dynaContent/live_watch/get_quote/getHistoricalData.jsp?symbol=#{stock}&fromDate=01-Jan-2009&toDate=24-Jun-2014&datePeriod=unselected&hiddDwnld=true")
		stock_data = file.read	
		stock_data = CSV.parse(stock_data)
		stock_data.delete([]) 
		stock_data.delete_at(0)
		stock_data = stock_data.reverse	
		# puts "1. #{stock_data.first}"
		# puts "2. #{stock_data.last}"
		
		stock_data.each do |s|
			begin
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
			rescue Exception => e
				puts e.message
				puts "Stock: #{stock_split}"
				puts "Data: #{s}"
			end
		end 
		stock_id += 1	
		puts "#{stock}: #{Time.now - t}"	
	end		
end


#http://www.nseindia.com/marketinfo/sym_map/symbolMapping.jsp?dataType=priceVolume&symbol=3iinfotech&segmentL=ALL&dateink=3&symbolCount=1&seriesRange=day&fromDate=01-07-2014&toDate=17-07-2014