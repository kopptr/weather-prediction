# scrape.jl

# expects a directory raw-weather-data/ to exist as a git repository
# clones raw-weather-data/ to raw-weather-data-update/
# updates the raw-weather-data-update repository and

using Requests
using JSON

lat = ENV["LAT"]
lon = ENV["LON"]
n_cities = ENV["N_CITIES"]
api_key = ENV["API_KEY"]

data_git_dir = "raw-weather-data"
out_dir = "raw-weather-data-out"
filename = "$(lat)-$(lon)-$(n_cities).json"

data_file = "$(data_git_dir)/$(filename)"

# Using an indent reduces the diff size,
# so git stores the data more efficiently
indent = 1

url_base = "https://api.openweathermap.org/data/2.5"
query = "find"
qparams = Dict(
    "lat" => lat,
    "lon" => lon,
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

open(data_file, "w") do f
    JSON.print(f, weather_data, indent)
end

path = pwd()
cd(data_git_dir)
run(`git config --global user.email "tkopp@pivotal.io"`)
run(`git config --global user.name "Tim Kopp via Concourse"`)
run(`git add $(filename)`)
run(`git commit -m "Scrape. Auto-commit"`)
cd(path)
mv(data_git_dir, out_dir)
