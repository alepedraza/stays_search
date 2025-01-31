FROM elixir:1.17-otp-25-alpine
ARG PORT=4000
ARG MIX_ENV=prod
ENV MIX_ENV=${MIX_ENV}
ENV MIX_HOME=/root/.mix/
WORKDIR /app

COPY . .

RUN set -xe \
    && mix local.hex --force \
    && mix local.rebar --force \
    && mix deps.get --only ${MIX_ENV} \
    && mix deps.compile \
    && mix local.hex --force \
    && mix local.rebar --force \
    && mix deps.get --only ${MIX_ENV} \
    && mix deps.compile \
    && mix compile \
    && mix phx.digest
EXPOSE ${PORT}

HEALTHCHECK --interval=10m --timeout=3s CMD netstat -tln | grep -q ${PORT}
CMD ["mix", "phx.server"]