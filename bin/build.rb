require "rubygems"
require "bundler/setup"
require "json"

def read_json(path:)
  JSON.parse(File.read(path, encoding: "bom|utf-8"))
end

def write_json(path:, content:)
  File.write(path, JSON.pretty_generate(content))
end

master = read_json(path: "../master.json")
records = master.map do |item|
  read_json(path: "../#{item["UUID"]}.json")
end
write_json(path: "bundle.json", content: records)
