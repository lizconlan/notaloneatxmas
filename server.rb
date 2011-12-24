require './models/pin'

before do
  env = ENV["RACK_ENV"] ? ENV["RACK_ENV"] : "development"
  ActiveRecord::Base.establish_connection(YAML::load(File.open('config/database.yml'))[env])
end

get "/" do
  pins = Pin.all
  postcodes = pins.collect{ |x| %Q|{"postcode":"#{x.postcode}","message":"<span style='font-family:Verdana,Arial,sans serif'><b>@#{x.name}</b>: #{x.message}</span>"}| }
  @postcodes = %Q|{"postcodes": [#{postcodes.join(",")}]}|
  erb :index
end