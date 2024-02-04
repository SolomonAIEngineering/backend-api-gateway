# Use Krakend image as the base
FROM devopsfaith/krakend:latest as builder

# # Set default values for environment variables
# ENV ENV=prod \
#     AUTH_DOMAIN=solomon-ai.us.auth0.com \
#     AUTH_AUDIENCE=https://solomon-ai.us.auth0.com/api/v2/

# Install gettext for envsubst
RUN apk add --no-cache gettext

# Copy configuration template and other necessary configs
COPY ./config/krakend.tmpl .
COPY config .

# Generate and check the Krakend configuration
# Use environment variables for dynamic configuration
RUN FC_ENABLE=1 \
    FC_OUT=/krakend.json \
    FC_PARTIALS="/etc/krakend/partials/$ENV" \
    FC_SETTINGS="/etc/krakend/settings" \
    FC_TEMPLATES="/etc/krakend/templates" \
    AUTH_DOMAIN="$AUTH_DOMAIN" \
    AUTH_AUDIENCE="$AUTH_AUDIENCE" \
    krakend check -t -ddd -c krakend.tmpl --lint

# The linting needs the final krakend.json file
RUN krakend check -tlc /krakend.json --lint

# Start a new stage from the base image
FROM devopsfaith/krakend:latest

# Copy the generated configuration from the builder stage
COPY --from=builder --chown=krakend:nogroup /krakend.json .

# Uncomment with Enterprise image:
# COPY LICENSE /etc/krakend/LICENSE

# Expose the necessary ports
EXPOSE 8080
