# Coffee Books

## Run with Docker

Start the Rails application and PostgreSQL database:

```sh
docker compose up --build
```

The application is available at http://localhost:3000. Rails runs database
preparation automatically when the web container starts. Development seeds
are loaded automatically when no books or readers exist, and are skipped on
later starts once the database has data.

Development containers run `bundle install` at startup, so changes to the
Gemfile are installed into the Bundler volume automatically. Rebuild with
`--build` when changing the Dockerfile or system packages.

Run Rails commands in the web container:

```sh
docker compose run --rm web ./bin/rails console
docker compose run --rm web ./bin/rspec
```

Books created through the Docker API are stored in the Compose PostgreSQL
database. To inspect that same database from your host, connect to
`localhost:5433` with user `postgres`, password `postgres`, and database
`coffee_books_development`, or run:

```sh
DATABASE_URL=postgresql://postgres:postgres@localhost:5433/coffee_books_development \
	bundle exec rails console
```

You can also inspect it without configuring host Rails:

```sh
docker compose exec web ./bin/rails runner 'puts Book.order(:id).last.attributes'
```

## Test API with Swagger

Start the Docker services, then open the Swagger UI:

http://localhost:3000/swagger

Use **Try it out** in Swagger to execute requests and inspect responses. The
available book endpoints are:

- `POST /v1/books` creates a book with `title` and `author`.
- `GET /v1/books` lists books and optionally a `title` or `author` filter. Both
	filters support partial, case-insensitive matching.
- `GET /v1/books/{uuid}` shows one book, including rental and reader history.
- `PATCH /v1/books/{uuid}` changes availability and updates the related rental.
	Borrowing requires `borrowed_at` and either an existing `reader_uuid` or a
	new reader's `full_name` and `email`.
- `DELETE /v1/books/{uuid}` removes an available book only.

After changing API code, restart the web container so the route and Swagger
documentation are refreshed:

```sh
docker compose restart web
```

The Compose stack also starts Redis and a Sidekiq worker. Sidekiq Cron runs
`RentalExpirationJob` every day at 08:00. It checks active rentals due in
three days and due today, then queues reminder emails. Development mail
delivery is configured as non-delivering and reminder payloads are written to
the Rails log. Inspect worker output with:

```sh
docker compose logs -f sidekiq
```

### Test Reminders Manually

The following tests reuse an existing active rental and do not require the
API. Run the setup command for one case, then trigger the job and inspect the
logs or rendered email.

#### Due Soon: Three Days Before

Prepare an active rental for the three-day reminder:

```sh
docker compose exec web ./bin/rails runner \
	'rental = Rental.active.first or abort("No active rental found"); rental.update!(duration_date: Date.current + 3.days, reminder_sent_at: nil); puts rental.id'
```

Trigger the job:

```sh
docker compose exec web ./bin/rails runner \
	'RentalExpirationJob.new.perform(Date.current.to_s)'
```

Inspect the worker output:

```sh
docker compose logs -f sidekiq
```

Preview the due-soon email without delivery:

```sh
docker compose exec web ./bin/rails runner \
	'rental = Rental.active.first or abort("No active rental found"); email = RentalMailer.expiration_reminder(rental, reminder_type: :due_soon); puts email.text_part.body.to_s'
```

#### Due Today

Prepare an active rental for the due-today notification:

```sh
docker compose exec web ./bin/rails runner \
	'rental = Rental.active.first or abort("No active rental found"); rental.update!(duration_date: Date.current, due_reminder_sent_at: nil); puts rental.id'
```

Trigger the job:

```sh
docker compose exec web ./bin/rails runner \
	'RentalExpirationJob.new.perform(Date.current.to_s)'
```

Inspect the worker output:

```sh
docker compose logs -f sidekiq
```

Preview the due-today email without delivery:

```sh
docker compose exec web ./bin/rails runner \
	'rental = Rental.active.first or abort("No active rental found"); email = RentalMailer.expiration_reminder(rental, reminder_type: :due_today); puts email.text_part.body.to_s'
```

Stop the containers with `docker compose down`. Add `-v` to that command when
you also want to remove the PostgreSQL and Bundler volumes.

## Run without Docker

The project uses Ruby 4.0.6 and PostgreSQL. Install dependencies with
`bundle install`, create the database with `bin/rails db:prepare`, and start
Rails with `bin/rails server`.

## Database Models

```mermaid
erDiagram
	BOOKS ||--o{ RENTALS : has
	READERS ||--o{ RENTALS : makes

	BOOKS {
		bigint id PK
		string uuid UK "six numeric digits"
		string title
		string author
		string availability_status "available or borrowed"
	}

	READERS {
		bigint id PK
		string uuid UK "six numeric digits"
		string full_name
		string email UK
	}

	RENTALS {
		bigint id PK
		date duration_date
		datetime borrowed_at
		datetime returned_at
		string reading_status "borrowed or returned"
		bigint book_id FK
		bigint user_id FK
		datetime reminder_sent_at
		datetime due_reminder_sent_at
	}
```

`books.id`, `readers.id`, and `rentals.id` are normal database-generated
primary keys. `books.uuid` and `readers.uuid` are unique six-digit public
identifiers generated by the models; they are separate from internal foreign
keys.

Status values are defined with Active Record enums:

- `Book#availability_status`: `available` or `borrowed`
- `Rental#reading_status`: `borrowed` or `returned`

Indexes support public identifier lookups, unique reader emails, book and
reader rental history, active rental queries, and due-date queries. A partial
unique index allows only one active rental per book.
