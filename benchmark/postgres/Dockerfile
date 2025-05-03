FROM postgres:17.4

# Add the database schema and data
ADD https://raw.githubusercontent.com/devrimgunduz/pagila/5ba5a57aeb159f75f02aca2432d3c262186d13d3/pagila-schema.sql /docker-entrypoint-initdb.d/10_pagila-schema.sql
ADD https://raw.githubusercontent.com/devrimgunduz/pagila/5ba5a57aeb159f75f02aca2432d3c262186d13d3/pagila-data.sql /docker-entrypoint-initdb.d/20_pagila-data.sql

# Add the license, as required by the license
ADD https://raw.githubusercontent.com/devrimgunduz/pagila/5ba5a57aeb159f75f02aca2432d3c262186d13d3/LICENSE.txt /docker-entrypoint-initdb.d/

# postgres user needs permission to read the files
RUN chown postgres:postgres /docker-entrypoint-initdb.d/*

ENV POSTGRES_PASSWORD=password

EXPOSE 5432