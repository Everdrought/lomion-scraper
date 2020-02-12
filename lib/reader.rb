module Reader
  def self.read bot = 0
    list = YAML.load File.read "monster_list.yml"

    loop do

      begin
        print "Monster name: "
        monster = YAML.load File.read list[gets.chomp.downcase]
        puts monster[:title]
        puts monster[:table]
        print "Monster Description y/n: "
        puts monster[:text] if gets.chomp.downcase == "y"      
      rescue
        puts "No such monster here"
      end
    end
  end

end