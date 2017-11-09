require 'rubygems'
require 'bundler'
Bundler.require
require_all 'models/*.rb'

pid = fork do
  require './consumer.rb'
end

Signal.trap("TERM") {
  puts 'shutting down the process #{pid}'
  Process.kill "TERM", pid
  exit
}
Signal.trap("INT") {
  puts 'shutting down the process #{pid}'
  Process.kill "INT", pid
  exit
}
require './app.rb'
run Sinatra::Application
