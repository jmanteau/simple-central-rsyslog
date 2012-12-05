require "rubygems"
require "grok-pure"
require "pp"
g = Grok.new

# Load our patterns
Dir["grok-patterns/*"].each { |p| g.add_patterns_from_file(p) }
#g.logmask = (1<<31)-1

logline= 'Nov  8 15:44:29 ISE-10MR2 CISE_Passed_Authentications 0000000001 4 0 2012-11-08 15:44:29.198 +00:00 0000000402 5200 NOTICE Passed-Authentication: Authentication succeeded, ConfigVersionId=7, Device IP Address=172.25.80.84, DestinationIPAddress=172.25.80.106, DestinationPort=1812, UserName=Itium, Protocol=Radius, RequestLatency=26, NetworkDeviceName=AvayaERS4550, AuthorizationPolicyMatchedRule=CHU87_Terminaux, User-Name=Itium, NAS-IP-Address=172.25.80.84, NAS-Port=43, Service-Type=Framed, Framed-MTU=1490, State=37CPMSessionID=ac19506a00000001509BD35C\;31SessionID=ISE-10MR2/141763129/2\;, Calling-Station-ID=00-90-DC-A4-E1-8B, NAS-Port-Type=Ethernet, Name=Itium, AcsSessionID=ISE-10MR2/141763129/2, AuthenticationIdentityStore=Internal Users, AuthenticationMethod=MSCHAPV2, SelectedAccessService=Default Network Access, SelectedAuthorizationProfiles=CHU87_Terminaux, IdentityGroup=Endpoint Identity Groups:Unknown, Step=11001, Step=11017, Step=15008, Step=15048, Step=15048, Step=15004, Step=11507, Step=12500,'

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
