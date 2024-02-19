#!/bin/bash

# Start Caddy in the background
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &

# Start Grafana in the foreground
/run.sh
