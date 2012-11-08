require "rubygems"
require "grok-pure"

g = Grok.new

# Load our patterns
Dir["/home/expert/patterns/grok-patterns/*"].each { |p| g.add_patterns_from_file(p) }
#g.logmask = (1<<31)-1

$stdin.each do |line|
  line.chomp!
  puts "Line: #{line}" 
  pattern = g.discover(line)
  puts "Pattern: #{pattern}"
  g.compile(pattern)
  puts g.match(line).captures.inspect
end
