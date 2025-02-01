# StaysSearch
To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## REST API
The REST API to find accommodations by city.

### Example request
`GET /api/staysSearch?city=México`

    http://localhost:4000/api/StaysSearch?city=México
    http://localhost:4000/api/staysSearch?city=mexico&amenities=%5B%22Wi-Fi%22%5D
    http://localhost:4000/api/staysSearch?city=mexico&maxPrice=2000&ratings=4.5
    http://localhost:4000/api/staysSearch?city=mexico&amenities=%5B%22Wi-Fi%22%5D&maxPrice=2000&minPrice=200.5&ratings=4.5
    

    
##### Parameters

> | name      |  type     | data type               | description                                                           |
> |-----------|-----------|-------------------------|-----------------------------------------------------------------------|
> | city      |  required | String   | Name of the city  |
> | ratings   |  optional | String   | rating overall  |
> | priceMin  |  optional | String   | Min price per nitght  |
> | priceMax  |  optional | String   | Max price per night  |
> | amenities  |  optional | String   | List of amenities, example: ["Televisón", ""Espacios al aire libre""]  |

### Docker 🐳
Build image
```bash
docker build -t stay_docker_app . 
```

It was necessary to generate a secret_key to run the docker.
```bash
mix phx.gen.secret
```

Run docker
```bash
docker run -d -p 4000:4000 -e SECRET_KEY_BASE="enter secret key" stay_docker_app
```

### Example of props using Claude.ai
First, context was provided about the application that was being attempted to be generated, in order to generate more accurate responses.

```
I need to compare two string in Elixir, for example "Léon" vs "leon" is the same city, I need a function to compare this strings. Give me some options
```
Generate function to parse number
```
Give me a function in Elixir to parse a string into an integer or float
```

Generate Dockerfile
```
Give me a example docker file to run an application in elixir:1.17-otp-25-alpine
```
