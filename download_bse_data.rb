require 'csv'
require 'open-uri'

bhav_copy = Array.new
i = 0

CSV.foreach("EQ180614.CSV") do |row| 
	if row[3] == "Q"
		bhav_copy[i] = row		
		i = i + 1
	end
end

bhav_copy.each do |sc|
	file = open("http://www.bseindia.com/stockinfo/stockprc2_excel.aspx?scripcd=#{sc[0]}&FromDate=01/01/2009&ToDate=06/19/2014&OldDMY=D")
	contents = file.read
	CSV.open("#{sc[1].split(" ").first}.csv", "wb") do |csv|
		i = 0
		CSV.parse(contents) do |row|
			csv << row			
			i = i+1
		end	
	end
end
