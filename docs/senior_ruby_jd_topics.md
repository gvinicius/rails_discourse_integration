# Senior Ruby JD Topics

This repo is centered on Discourse integration, but it also demonstrates broader Senior Ruby Developer expectations.

## Rails application design

The app uses Rails API mode with focused layers:

- controllers in `app/controllers`
- models in `app/models`
- service objects in `app/services`
- external clients in `app/clients`
- background jobs in `app/jobs`
- RSpec coverage in `spec`

The main pattern is: controller receives HTTP, service owns workflow, model owns persistence rules, job owns retryable async work.

## API integration

`app/clients/discourse/client.rb` wraps `DiscourseApi::Client`.

This avoids spreading third-party API details across the app and gives one place for:

- credentials
- error mapping
- rate-limit handling
- future logging and metrics

## BDD/TDD

Specs are organized by behavior:

- `spec/clients/discourse/client_spec.rb`
- `spec/services/discourse/*`
- `spec/requests/discourse/webhooks_spec.rb`
- `spec/jobs/discourse/deliver_webhook_to_snowflake_job_spec.rb`

The tests focus on contracts, not Rails internals.

## PostgreSQL and data integrity

The sample uses SQLite locally, but the migrations model production-style PostgreSQL concerns:

- unique external IDs
- unique webhook event IDs
- indexed lookup fields
- explicit not-null constraints
- local status fields for failed syncs

The same migration ideas apply to PostgreSQL in production.

## Unix, Docker, and operations

The generated Rails app includes Docker-related files:

- `Dockerfile`
- `.dockerignore`
- `bin/docker-entrypoint`

Operationally, the integration should expose:

- health checks
- structured logs
- failed job visibility
- replay tasks for failed webhook delivery
- documented environment variables

## Kubernetes readiness

In Kubernetes, this app would normally run as separate workloads:

- Rails web pods for SSO and webhook requests
- worker pods for sync and Snowflake delivery jobs
- PostgreSQL as managed database
- Redis or Solid Queue backend for jobs

Keep web requests fast and move slow integration work to jobs.

## TCP/IP and debugging

For production integration issues, debug layer by layer:

1. DNS resolution for Discourse or Okta.
2. Port reachability.
3. TLS certificate validity.
4. HTTP status.
5. Authentication or API key validity.
6. Application logs and job failures.

Useful commands:

```bash
curl -v https://forum.example.org
nc -vz forum.example.org 443
openssl s_client -connect forum.example.org:443 -servername forum.example.org
```

## Snowflake and analytics delivery

`app/jobs/discourse/deliver_webhook_to_snowflake_job.rb` models the safe data-delivery pattern.

The app should not block webhook requests on Snowflake. Instead:

1. verify webhook
2. store event locally
3. enqueue delivery
4. transform payload
5. deliver asynchronously
6. mark delivered or failed
7. replay failed events later

`app/clients/snowflake/client.rb` is intentionally a boundary, because the real organization may use Snowpipe, staging buckets, Kafka, or an internal ingestion API.

## AI-enabled Rails features

The same architecture applies to AI features:

- keep LLM calls behind client classes
- use service objects for workflows
- enforce authorization before retrieval
- log prompt versions and source documents
- process long document workflows in jobs
- test prompt assembly and failure behavior

The key interview point:

> Treat LLMs as external services, not trusted business logic.

## Production support

For support tickets:

1. reproduce the issue
2. inspect logs and data
3. classify root cause
4. add or update a regression spec
5. fix narrowly
6. deploy safely
7. document the resolution

This repo gives practical examples of failures being stored locally, especially sync failures and Snowflake delivery failures.

