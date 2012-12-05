require "rubygems"
require "grok-pure"
require "pp"
g = Grok.new

# Load our patterns
Dir["/etc/logstash/patterns/*"].each { |p| g.add_patterns_from_file(p) }
#g.logmask = (1<<31)-1

logline= "ma logline"


$stdin.each do |pattern|
  pattern.chomp!
  puts "Line: #{logline}"
  puts "Pattern: #{pattern}"
  g.compile(pattern)
  match = g.match(logline)
  if match
    puts "Resulting capture:"
    pp match.captures
  end
  puts "#####################################"

end

