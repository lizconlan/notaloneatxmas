require 'rubygems'
require 'bundler'
Bundler.load
require 'sinatra'
require 'active_record'
 
disable :run

require './server.rb'

run Sinatra::Application