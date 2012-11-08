require "rubygems"
require "grok-pure"

g = Grok.new

# Load our patterns
Dir["/home/expert/patterns/grok-patterns/*"].each { |p| g.add_patterns_from_file(p) }
#g.logmask = (1<<31)-1

logline= 'Oct 22 16:22:36 172.25.79.254 SSG140-1: NetScreen device_id=SSG140-1  [Root]system-notification-00257(traffic): start_time="2012-10-22 16:22:40" duration=0 policy_id=119 service=gre proto=47 src zone=Global dst zone=Global action=Deny sent=0 rcvd=72 src=172.17.0.1 dst=172.18.0.151 session_id=0'

$stdin.each do |pattern|
  pattern.chomp!
  puts "Line: #{logline}" 
  puts "Pattern: #{pattern}"
  g.compile(pattern)
  puts g.match(logline).captures
end
