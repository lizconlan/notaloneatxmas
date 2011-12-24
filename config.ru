require 'rubygems'
require 'bundler'
Bundler.load
require 'sinatra'
require 'twitter'
require 'active_record'
 
disable :run

require 'server'

run Sinatra::Application