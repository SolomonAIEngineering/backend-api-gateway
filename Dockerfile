FROM devopsfaith/krakend:latest as builder
ARG ENV=prod
ARG AUTH_DOMAIN=solomon-ai.us.auth0.com
ARG AUTH_AUDIENCE=https://solomon-ai.us.auth0.com/api/v2/

# Install gettext for envsubst
RUN apk add --no-cache gettext

COPY ./config/krakend.tmpl .
COPY config .

## Save temporary file to /tmp to avoid permission errors
RUN FC_ENABLE=1 \
    FC_OUT=/tmp/krakend.json \
    FC_PARTIALS="/etc/krakend/partials/$ENV" \
    FC_SETTINGS="/etc/krakend/settings" \
    FC_TEMPLATES="/etc/krakend/templates" \
    AUTH_DOMAIN="$AUTH_DOMAIN" \
    AUTH_AUDIENCE="$AUTH_AUDIENCE" \
    envsubst < krakend.tmpl > /tmp/krakend.json && \
    krakend check -d -t -c /tmp/krakend.json --lint

# The linting needs the final krakend.json file
RUN krakend check -c /tmp/krakend.json --lint

FROM devopsfaith/krakend:latest
COPY --from=builder --chown=krakend:nogroup /tmp/krakend.json .
# Uncomment with Enterprise image:
# COPY LICENSE /etc/krakend/LICENSE

EXPOSE 8080