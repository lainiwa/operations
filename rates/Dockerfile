# syntax=docker/dockerfile:1.4

FROM python:3.10.8-slim-buster

RUN apt-get update && \
    apt-get install -yqq --no-install-recommends build-essential python-dev
RUN pip install "poetry==1.2.2"

RUN groupadd --system user && useradd --system --gid=user --home-dir=/app user
USER user:user

WORKDIR /app

COPY --chown=user:user poetry.lock pyproject.toml src /app/

RUN --mount=type=cache,target=/root/.cache/pypoetry/cache \
    --mount=type=cache,target=/root/.cache/pypoetry/artifacts \
    poetry install --only main

# Link this package to a repository
LABEL org.opencontainers.image.source https://github.com/lainiwa/operations-task

EXPOSE 80

ENTRYPOINT [ "poetry", "run" ]
CMD [ "gunicorn", "-b", ":80", "rates.wsgi"]
