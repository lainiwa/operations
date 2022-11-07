# Setting Up

## For Local Development
1. `cp .env.template .env` and create the value for `DEV_RATES_DB_PASSWORD` variable
2. Run `./scripts/run_local` to bootstrap the DB and the API
3. `curl "http://127.0.0.1:3000/rates?date_from=2021-01-01&date_to=2021-01-31&orig_code=CNGGZ&dest_code=EETLL"`

## For in-Cloud

### Generate SSH key, if not exists
1. You just need to have a `~/.ssh/id_rsa{,.pub}` keypair. To create it run `ssh-keygen`

### PostgreSQL
1. `cp .env.template .env` and define password `RATES_DB_PASSWORD`

### Get Hetzner Token
1. Log in to Hetzner, go to [cloud console](https://console.hetzner.cloud)
2. Create new project, name it `Xeneta`
3. Go to "Security" -> "API Tokens" and generate a read&write token, describe it as a `terraform token`. Copy the token to `.env` at `HCLOUD_TOKEN=`

### Duckdns
1. Log in to duckdns
2. Add domain `xeneta.duckdns.org` and add to `.env` at `xeneta.duckdns.org`
3. Copy the API token to `.env` at `DUCKDNS_TOKEN=`

### Deploy
1. `terraform init`, then `./scripts/deploy` to (re)deploy the infrastructure
2. The committed code changes at `rates/` would be applied automatically, you only need to redeploy infrastructure changes
3. Production will be available at: `curl "https://rates.xeneta.duckdns.org/"` or `curl "https://rates.xeneta.duckdns.org/rates?date_from=2021-01-01&date_to=2021-01-31&orig_code=CNGGZ&dest_code=EETLL"`
3. Stage will be available at: `curl "https://rates-dev.xeneta.duckdns.org/"` or `curl "https://rates-dev.xeneta.duckdns.org/rates?date_from=2021-01-01&date_to=2021-01-31&orig_code=CNGGZ&dest_code=EETLL"`
