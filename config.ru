require 'rubygems'
require 'bundler'
Bundler.require
require_all 'models/*.rb'

require './app.rb'
run Sinatra::Application
