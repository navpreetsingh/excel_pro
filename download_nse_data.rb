require 'csv'
require 'open-uri'

bhav_copy = Array.new
i = 0
puts i
CSV.foreach("nse_bhav_copy.csv") do |row| 
	if row[1] == "EQ"
		bhav_copy[i] = row	
		#puts "#{i}: #{bhav_copy[i]}"	
		i = i + 1
	end
end

bhav_copy.each do |sc|
	file = open("http://www.nseindia.com/live_market/dynaContent/live_watch/get_quote/getHistoricalData.jsp?symbol=#{sc[0]}&fromDate=01-Jan-2009&toDate=19-Jun-2014&datePeriod=unselected&hiddDwnld=true")
	contents = file.read
	#puts contents
	CSV.open("nse_stocks/#{sc[0].split(" ").first}.csv", "wb") do |csv|
		i = 0
		CSV.parse(contents) do |row|
			# puts row.class
			# puts row
			# sleep 2			
			csv << row unless row.empty?			
			i = i+1
		end	
	end
end
