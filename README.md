# Coffee Books

## Run with Docker

Start the Rails application and PostgreSQL database:

```sh
docker compose up --build
```

The application is available at http://localhost:3000. Rails runs database
preparation automatically when the web container starts.

Run Rails commands in the web container:

```sh
docker compose run --rm web ./bin/rails console
docker compose run --rm web ./bin/rspec
```

Stop the containers with `docker compose down`. Add `-v` to that command when
you also want to remove the PostgreSQL and Bundler volumes.

## Run without Docker

The project uses Ruby 4.0.6 and PostgreSQL. Install dependencies with
`bundle install`, create the database with `bin/rails db:prepare`, and start
Rails with `bin/rails server`.
