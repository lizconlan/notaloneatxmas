require 'rubygems'
require 'bundler'
Bundler.load
require 'sinatra'
require 'twitter'
require 'activerecord'
 
disable :run

require 'server'

run Sinatra::Application