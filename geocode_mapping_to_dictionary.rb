require "json"

geocode_mapping = JSON.parse(File.read("data/geocode_mapping.json"))
geocode_dictionary = {}

geocode_mapping.each do |record|
  data = record["result"]["results"][0]
  address = record["address"].downcase
  geocode_dictionary[address] = {
    formatted_address: data["formatted_address"],
    location: data["geometry"]["location"],
    place_id: data["place_id"],
  }
end

File.write("data/geocode_dictionary.json", JSON.pretty_generate(geocode_dictionary))
