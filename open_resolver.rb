#!/usr/bin/ruby
# This script will attempt to discover whether or not an IP address will answer
# arbitrary DNS queries. This indicates that the server is likely an Open Resolver.
# For more information about Open Resolvers, visit: http://openresolverproject.org

require 'resolv'
require 'timeout'
require 'ipaddr' 

begin 
  dns_server = IPAddr.new(ARGV[0].chomp).to_s
rescue IPAddr::InvalidAddressError
  puts "'#{ARGV[0]}' is not a valid IP address."
  exit 1
end

begin
  Timeout::timeout(3){
    Resolv::DNS.open({:nameserver=>[dns_server]}) do |r|
      r.getaddress("surkatty.org")
      puts "#{dns_server}: open resolver"
    end
  }
rescue Resolv::ResolvError
  puts "#{dns_server}: maybe non-open"
rescue Timeout::Error
  puts "#{dns_server}: timeout"
end
