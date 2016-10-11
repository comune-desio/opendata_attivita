require "uri"
require "open-uri"
require "pp"
require "json"
require "dotenv"
require "fileutils"

Dotenv.load

module Geocoder
  def self.geocode(address:, country: "IT", language: "it", postal_code:, api_key:)
    params = {
      key: api_key,
      address: address,
      language: language,
    }
    components = {
      country: country,
      postal_code: postal_code,
    }
    encoded_components = "components=" + components.map do |key, value|
      "#{key}:#{value}"
    end.join("|")
    encoded_params = (params.map do |key, value|
      "#{key}=#{URI.encode(value)}"
    end + [encoded_components]).join("&")
    format = "json"
    base_address = "https://maps.googleapis.com/maps/api/geocode/#{format}"
    address = "#{base_address}?#{encoded_params}"
    response = open(address).read
    JSON.parse(response)
  end
end

not_found_records = JSON.parse(File.read("build/not_found.json"))

quotas = {
  daily: {
    usage: 0,
    period: 60 * 60 * 24, # 1 day
    limit: 2_500,
    cooldown: nil, # doesn't wait
  },
  per_second: {
    usage: 0,
    period: 1,
    limit: 50,
    cooldown: 0.5,
  },
}

before = Time.now

def quota_exceeded(before:, quota:, now:)
  quota[:usage] >= quota[:limit] && (now - before) <= quota[:period]
end

geocode_mapping = not_found_records["features"].map do |record|
  record["properties"]["address"]
end.map do |address|
  quotas.each do |label, quota|
    if quota_exceeded(before: before, now: Time.now, quota: quota)
      puts ""
      puts "Quota usage exceeded: [#{label}] used = #{quota[:usage]}, limit = #{quota[:limit]}"
      if quota[:cooldown]
        print "Performing cooldowns (#{quota[:cooldown]} secs): "
        begin
          sleep quota[:cooldown]
          print "."
        end while quota_exceeded(before: before, now: Time.now, quota: quota)
        puts ""
        puts "Resetting quota usage [#{label}]"
        quota[:usage] = 0
        before = Time.now
      else
        puts "No cooldown period specified for quota [#{label}], exiting"
      end
    else
      quota[:usage] += 1
    end
  end
  geocode_result = Geocoder.geocode(address: address, country: "IT", language: "it", postal_code: "20832", api_key: ENV["GEOCODER_API_KEY"])
  symbol = if geocode_result["status"] == "OK"
    "+"
  else
    "X"
  end
  print symbol
  result = {
    address: address,
    result: geocode_result,
  }
  result
end

destination_path = "data"
FileUtils.mkdir_p(destination_path)
File.write("#{destination_path}/geocode_mapping.json", JSON.pretty_generate(geocode_mapping))
