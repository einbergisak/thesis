FROM postgres:17.4

# Copy the SQL files into the container
COPY /pagila/pagila-schema.sql /docker-entrypoint-initdb.d/
COPY /pagila/pagila-data.sql /docker-entrypoint-initdb.d/

ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=password
ENV POSTGRES_DB=postgres

EXPOSE 5432


