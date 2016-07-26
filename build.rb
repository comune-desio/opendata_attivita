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

master = read_json(path: "master.json")
geojson_records = []
records = master.map do |item|
  record = read_json(path: "#{item["UUID"]}.json")
  if !blank?(record["Latitude"]) && !blank?(record["Longitude"])
    geojson_records << record
  end
  record
end
build_path = "build"
FileUtils.mkdir_p(build_path)
write_json(path: File.join(build_path, "bundle.json"), content: records)
write_geojson(path: File.join(build_path, "bundle.geojson"), content: geojson_records)
