require 'open-uri'
require 'rubygems'
require 'json'
require 'matrix'
require 'radix'

puts "quakecon clan counts as of #{Time.now.strftime("%m/%d/%Y %H:%M")}"

#string = "https://registration.quakecon.org/?action=byoc_data&response_type=json"
string = "2014.json"

parsed = JSON.parse(open(string).read)

seats = parsed["data"]["seats"]
tags = parsed["data"]["tags"]

b62 = Radix::Base.new(('A'..'Z').to_a + ('a'..'z').to_a + ('0'..'9').to_a)
b10 = Radix::Base.new(Radix::BASE::B10)

i = 0
colA = Matrix.build(74,10) {|row, col| i += 1 }
colB = Matrix.build(74,22) {|row, col| i += 1 }
colC = Matrix.build(64,12) {|row, col| i += 1 }
colU = Matrix.build(12,10) {|row, col| i += 1 }

attendees = {}
clans = {}

tags.each do |tag|
    hash  = tag[0]
    clan  = tag[1]
    count = 0
    list  = {}

    clans[hash] = {clan: clan, count: count, list: list}
end

clans["no clan listed"] = {clan: "No Clan Listed", count: 0, list: {}}

seats.each do |seat|

    seatLoc = ''

    seatNum = b10.convert(seat[0], b62).to_i + 1

    if colA.index(seatNum) != nil
        seatLoc << 'A' + sprintf('%02d',((colA.index(seatNum)[0]) + 1)) + '-' + sprintf('%02d',((colA.index(seatNum)[1]) + 1))
    elsif colB.index(seatNum) != nil
        seatLoc << 'B' + sprintf('%02d',((colB.index(seatNum)[0]) + 1)) + '-' + sprintf('%02d',((colB.index(seatNum)[1]) + 1))
    elsif colC.index(seatNum) != nil
        seatLoc << 'C' + sprintf('%02d',((colC.index(seatNum)[0]) + 1)) + '-' + sprintf('%02d',((colC.index(seatNum)[1]) + 1))
    elsif colU.index(seatNum) != nil
        num = seatNum - 3137
        table = (num/10).floor + 1
        row = (num%10).floor + 1

        digit = 13 - table + (10 - row)

        if row == 1
            digit += 2 * (table - 1)
        end

        seatLoc << 'UAC-' + sprintf('%02d', digit)
    end

    if seat[1][0] == ":"
        clan = "no clan listed"
    else
        clanSplit = seat[1].split(":",2)
        clan = clanSplit[0]
    end

    if seat[1][-1,1] == ":"
        handle = 'Reserved'
    else
        handleSplit = seat[1].split(":",2)
        handle = handleSplit[1]
    end

    clans[clan][:count] = clans[clan][:count] + 1
    clans[clan][:list][seatLoc] = handle       
end

sorted = clans.sort_by { |k, v| [-v[:count],v[:clan]] }

sorted.each do |sort|
    if  sort[1][:count] > 0 && sort[0] != "no clan listed"
        puts sort[1][:clan] + " --- " + sort[1][:count].to_s

        sorted_list = sort[1][:list].sort

        sorted_list.each do |list|
            puts "     " + list[0] + " " + list[1]
        end
    end
end

puts clans["no clan listed"][:clan] + " --- " + clans["no clan listed"][:count].to_s

sorted_list = clans["no clan listed"][:list].sort

sorted_list.each do |list|
    puts "     " + list[0] + " " + list[1]
end
