require 'concurrent-ruby'
require 'nokogiri'
require 'httparty'
require 'yaml'
require_relative 'reader'

class Lomion

  class << self
    def scraper
      base_url = "https://web.archive.org/web/20180818101608/http://lomion.de/cmm/"
      url = "https://web.archive.org/web/20180818101608/http://lomion.de/cmm/_index.php"
      pool = Concurrent::FixedThreadPool.new(8)
      parsed_page = parse url
      monsters = parsed_page.css("td")
      parsed_monsters = {}

      monsters.each do |monster|

        #skips all the monsters who don't have a valid link (be it that they don't contain
        # a valid <a> tag or 'href' attribute
        next if monster.css('a')[0].nil? || monster.css('a')[0].attributes['href'].nil?

        link = monster.css('a')[0].attributes['href'].value
        parsed_monsters["#{monster.text}"] = "#{link}" 
      end

      #Generate a directory and a monster list if they were deleted or if the script is ran for
      #the first time
      Dir.mkdir "scrap" unless Dir.exist? "scrap"
      creature_list(parsed_monsters) unless File.exists? "monster_list.yml"

      parsed_monsters.each do |key,value|
        filename = file_dir value
        next if File.exists? filename
        pool.post do
          url = base_url + value
          parsed_page = parse url
          table = parsed_page.css("table").text
          text = parsed_page.css("p")[2..-5].text #2..5 to remove navbars

          monster = { title: key, table: table, text: text }

          File.open( filename, "w" ) do  |file|
            file.write monster.to_yaml
          end

          puts "saved #{filename}"

        end
      end
      pool.wait_for_termination
    end

    private

    def parse url
      unparsed_page = HTTParty.get(url)
      Nokogiri::HTML(unparsed_page)
    end

    def file_dir value
      "scrap\/" + value.sub(".php",".yml")
    end

    def creature_list creatures
      monster_list = {}

      creatures.each do |key,value|
        monster_list[key.downcase] = file_dir value
      end

      File.open "monster_list.yml", "w" do |file|
        file.write monster_list.to_yaml
      end

      puts "Saved monster_list.yml"
    end
  end

end

puts "Do you wish to?"
puts "------------------"
puts "(1) Scrape"
puts "(2) Read the data"
print "Input: "

case gets.chomp
when "1"
  Lomion.scraper
when "2"
  Reader::read
else
  puts "invalid input, shutting down"
end