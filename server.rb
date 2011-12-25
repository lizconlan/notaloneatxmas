require './models/pin'

before do
  env = ENV["RACK_ENV"] ? ENV["RACK_ENV"] : "development"
  ActiveRecord::Base.establish_connection(YAML::load(File.open('config/database.yml'))[env])
end

get "/" do
  pins = Pin.all
  postcodes = pins.collect{ |x| %Q|{"postcode":"#{x.postcode}","tname":"#{x.name}", "message":"#{x.message}"}| }
  @postcodes = %Q|{"postcodes": [#{postcodes.join(",")}]}|
  @api_key = ENV["gmaps_key"] ? ENV["gmaps_key"] : ""
  erb :index
end