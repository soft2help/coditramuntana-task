user = User.create

api_key = ApiKey.create(bearer: user)
api_key.raw_token

api_key.access_control_rules = {
  ip: [
    {type: "ip", value: "172.25.94.167"},
    {type: "cidr", value: "172.25.94.0/24"},
    {type: "hostname", value: "localhost"}
  ],
  header: [
    {name: "X-Custom-Header", value: "ExpectedValue"},
    {name: "X-Required-Header", value: nil} # Presence check only
  ]
}

api_key.save

# SWAGGER_ENV="development" RSWAG_DRY_RUN=0  rails rswag

# exclude from specs rswag tag
# specs spec --tag ~@rswag
