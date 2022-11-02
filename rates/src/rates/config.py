import os

DB = {
    "name": os.getenv("RATES_DB_NAME", default="rates"),
    "user": os.getenv("RATES_DB_USER", default="admin"),
    "host": os.getenv("RATES_DB_HOST", default="localhost"),
    "password": os.getenv("RATES_DB_PASSWORD", default="password"),
}
