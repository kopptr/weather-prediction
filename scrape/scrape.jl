# scrape.jl

Pkg.add("Requests")
Pkg.add("JSON")

# expects a directory raw-weather-data/ to exist as a git repository
# clones raw-weather-data/ to raw-weather-data-update/
# updates the raw-weather-data-update repository and

using Requests
using JSON

lat = ENV["LAT"]
lon = ENV["LON"]
n_cities = ENV["N_CITIES"]
api_key = ENV["API_KEY"]

in_data_file = "raw-weather-data/$(lat)-$(lon)-$(n_cities).json"
out_data_file = "raw-weather-data-updated-(lat)-$(lon)-$(n_cities).json"

# Using an indent reduces the diff size,
# so git stores the data more efficiently
indent = 1

url_base = "https://api.openweathermap.org/data/2.5"
query = "find"
qparams = Dict(
    "lat" => lat,
    "lon" => long,
    "cnt" => n_cities,
    "APPID" => api_key
)

weather_data = try
        JSON.parsefile(in_data_file)
    catch
        []
    end

response = Requests.get("$url_base/$query", query = qparams)
json_response = Requests.json(response)

if statuscode(response) != 200
	JSON.print(Base.STDERR, json_response)
	exit(1)
end

append!(weather_data, json_response["list"])

open(out_data_file, "w") do f
    JSON.print(f, weather_data, indent)
end
