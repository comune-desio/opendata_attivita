require "rubygems"
require "bundler/setup"
require "json"

def read_json(path:)
  JSON.parse(File.read(path, encoding: "bom|utf-8"))
end

def write_json(path:, content:)
  File.write(path, JSON.pretty_generate(content))
end

def blank?(value)
  value == "" || value == nil
end

def value_or_fallback_if_blank(value, fallback)
  if blank?(value)
    fallback
  else
    value
  end
end

def build_geojson_feature(record:)
  {
    "type": "Feature",
    "geometry": {
      "type": "Point",
      "coordinates": [
        record["Longitude"],
        record["Latitude"]
      ]
    },
    "properties": {
      "UUID": record["UUID"],
      "category": value_or_fallback_if_blank(record["Categoria"], record["Categoria catastale"]),
      "title": value_or_fallback_if_blank(record["Nome Visualizzato"], record["Ragione Sociale"]),
      "address": record["Indirizzo"],
      "url": record["Sito"],
      "e-mail": record["e-mail"],
      "telephone": record["Telefono"],
      "marker-symbol": "marker",
      "marker-color": "#000000",
      "marker-size": "medium",
      "ragione-sociale": record["Ragione Sociale"],
      "Facebook ID": record["Facebook ID"],
      "Facebook URL": record["Facebook URL"],
      "Google Place ID": record["Google Place ID"],
      "Google Place URL": record["Google Place URL"],
      "Categoria catastale": record["Categoria catastale"],
    }.reject do |key, value|
      value == "" || value == nil
    end
  }
end

def write_geojson(path:, content:)
  geojson_content = {
    "type" => "FeatureCollection",
    "features" => content.map do |record|
      build_geojson_feature(record: record)
    end
  }
  write_json(path: path, content: geojson_content)
end
geocode_dictionary = read_json(path: "data/geocode_dictionary.json")
activities_path = "activities"
master = read_json(path: "master.json")
geojson_records = []
not_found_records = []
records = master.map do |item|
  record = read_json(path: File.join(activities_path, "#{item["UUID"]}.json"))
  if !blank?(record["Latitude"]) && !blank?(record["Longitude"])
    geojson_records << record
  else
    geocoding_info = geocode_dictionary[record["Indirizzo"].downcase]
    if geocoding_info
      record["Indirizzo"] = geocoding_info["formatted_address"]
      record["Latitude"] = geocoding_info["location"]["lat"].to_s
      record["Longitude"] = geocoding_info["location"]["lng"].to_s
      record["Google Place ID"] = geocoding_info["place_id"]
      geojson_records << record
    else
      not_found_records << record
    end
  end
  record
end
build_path = "build"
FileUtils.mkdir_p(build_path)
puts "Records: #{records.count}"
write_json(path: File.join(build_path, "bundle.json"), content: records)
puts "Records with GPS coordinates: #{geojson_records.count}"
write_geojson(path: File.join(build_path, "bundle.geojson"), content: geojson_records)
puts "Records without GPS coordinates: #{not_found_records.count}"
write_geojson(path: File.join(build_path, "not_found.json"), content: not_found_records)
