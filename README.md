[![CircleCI](https://circleci.com/gh/ministryofjustice/laa-court-data-adaptor.svg?style=shield)](https://app.circleci.com/pipelines/github/ministryofjustice/laa-court-data-adaptor?branch=master)

[![repo standards badge](https://img.shields.io/badge/dynamic/json?color=green&style=for-the-badge&logo=github&label=MoJ%20Compliant&query=%24.data%5B%3F%28%40.name%20%3D%3D%20%22laa-court-data-adaptor%22%29%5D.status&url=https%3A%2F%2Foperations-engineering-reports.cloud-platform.service.justice.gov.uk%2Fgithub_repositories)](https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/github_repositories#laa-court-data-adaptor "Link to report")

# LAA Court Data Adaptor

This application is an adaptor or anti-corruption layer that connects to HMCTS’ Common Platform and transmits data between HMCTS Common Platform and various LAA systems.

Its main function is data translation / adaptation, and queueing of requests.

The application is commonly referred to by its acronym "CDA".

## Table of Contents <!-- omit from toc -->

- [LAA Court Data Adaptor](#laa-court-data-adaptor)
  - [Contact the team](#contact-the-team)
  - [Architecture Diagram](#architecture-diagram)
  - [Dependencies](#dependencies)
  - [Set up](#set-up)
    - [docker-compose](#docker-compose)
    - [Decrypt the env files](#decrypt-the-env-files)
    - [Run the application server](#run-the-application-server)
  - [API Authentication](#api-authentication)
    - [Making authenticated requests:](#making-authenticated-requests)
  - [Postman collection](#postman-collection)
  - [API Schema](#api-schema)
  - [Deployment](#deployment)
  - [Dev: running locally](#dev-running-locally)
    - [Connect to hmcts-common-platform-mock-api](#connect-to-hmcts-common-platform-mock-api)
  - [Environments](#environments)
  - [Monitoring and Debugging](#monitoring-and-debugging)
  - [Pre-commit Hooks](#pre-commit-hooks)
  - [Sidekiq UI](#sidekiq-ui)
  - [Contributing](#contributing)

## Contact the team

Court Data Adaptor is maintained by staff in the Legal Aid Agency. If you need support, you can contact the team on our Slack channel:
- [#laa-crime-apps-core](https://mojdt.slack.com/archives/CT0Q47YCQ) on MOJ Digital & Technology

## Architecture Diagram

View the [architecture diagram](https://structurizr.com/share/55246/diagrams#cda-container) for this project.
It's defined as code and [can be edited](https://github.com/ministryofjustice/laa-architecture-as-code/blob/main/src/main/kotlin/model/CDA.kt) by anyone.

## Dependencies

* Ruby
  It is desirable to install a Ruby Version Manager.
  Two popular are [RVM](https://rvm.io/) and [asdf](https://asdf-vm.com/).

  Check the Ruby version in the file `.ruby-version`

* System dependencies
  * postgres 14.3
  * redis

* Ruby on Rails and the other Ruby Gems

  They are specified in the `Gemfile`.

  Use bundler to install them:
  ```
  bundle install
  ```
## Set up

To set up  CDA in your local machine, you can run the following services manually:
* Rails (the application server)
* Postgres
  * [Brew formula for PostgreSQL@14](https://formulae.brew.sh/formula/postgresql@14#default)
  * Docker - `docker run -d --name cda-db -e POSTGRES_USER postgres -e POSTGRES_PASSWORD <PASSWORD> -p 5432:5432 cimg/postgres:14`
* Redis and Sidekiq

or you can use docker-compose.

### docker-compose

A faster way is to use `docker-compose`, which uses the `docker-compose.yaml`.
On your shell run:
```
$ docker-compose up --build
```
---

### Decrypt the env files
The env files has been encrypted with [git-crypt.md](docs/git-crypt.md).
This requires your **gpg key** to have been added to git-crypt. Liaise with another developer to action the steps in [git-crypt.md](docs/git-crypt.md)

Once the pull request has been merged, re-pull master and run:

```
git-crypt unlock
```

Create an `.env.test.local` file at the root

To get the tests running you will need to set the following value:
```
DATABASE_URL=postgres://postgres:postgres@localhost:5432/laa_court_data_adaptor_test
```
Then run:

```
$ RAILS_ENV=test rails db:setup
$ rspec
```

### Run the application server

Create an `.env.development.local` file at the root. You can copy it from `.env` and then change it based on your needs.

To get the localhost running you will need to set the following value:
```
DATABASE_URL=postgres://postgres:postgres@localhost:5432/laa_court_data_adaptor_development
```

Now you can manually run Rails and Redis/Sidekiq.

```
$ RAILS_ENV=development rails db:setup
$ bin/rails s
```

To run background jobs, You also need to start sidekiq and redis in separate terminal windows:

```
redis-server
```

```
$ bundle exec sidekiq
```

**Alternatively**, to process jobs inline in `.env.development.local` set:
 ```
 INLINE_SIDEKIQ: true
 ```

The other way run the services is by using docker-compose: `docker-compose up --build`

## API Authentication

Create an OAuth Application for each system that needs to authenticate to the adaptor via the console.

1. Access Rails console:

```
rails console
```

2. Create a new application entry:

```ruby
application = Doorkeeper::Application.create(name: 'My CDA Client')
```

The client credentials are available in `application.uid` and `application.secret`.

3. Call POST `/oauth/token` to generate an `access_token`

Use the `application.uid` and `application.secret` (see step 2)

```
$ curl -n -X POST https://dev.court-data-adaptor.service.justice.gov.uk/oauth/token \
  -d '{
  "grant_type": "client_credentials",
  "client_id": <application.uid>,
  "client_secret": <application.secret>
}' \
  -H "Content-Type: application/json"
```

the response contains <access_token> (see [schema](https://github.com/ministryofjustice/laa-court-data-adaptor/blob/master/schema/schema.md#oauth-endpoints-authentication) for more details)

### Making authenticated requests:
Now that you have the `access_token` you can use it as a Bearer token to call CDA APIs:

For example:

```curl
curl --get \
--url 'https://API_HOST/api/internal/v1/prosecution_cases' \
--data-urlencode 'filter[name]=Boris Lubowitz' \
--data-urlencode 'filter[date_of_birth]=1981-08-22' \
--data-urlencode 'include=defendants' \
--header 'Authorization: Bearer <access_token>'
```

In CDA the authentication process is handled by the gem [doorkeeper](https://github.com/doorkeeper-gem/doorkeeper)

## Postman collection
To simplify manual API calling and testing, the team created a Postman collection: https://dsdmoj.atlassian.net/wiki/spaces/AAC/pages/3713859603/Using+Postman#CDA-Collections

## API Schema

We use [rswag](https://github.com/rswag/rswag) to document with [swagger](https://swagger.io/) the endpoints that are being exposed.

To view the API documentation, start the rails server locally using `rails s` and then browse to http://localhost:3000/api-docs/index.html.

To use the 'Try it out' functionality, you need to have first created an oAuth user in your local database. See [here](https://github.com/ministryofjustice/laa-court-data-adaptor#api-authentication) for details.

To add a new endpoint, run `rails generate rspec:swagger <controller_name>` to generate a request spec. Add appropriate tests and content to the spec, then run `rake rswag`. The new endpoint should now appear in the Swagger UI interface.

## Deployment

The build is triggered in [CircleCI](https://circleci.com/gh/ministryofjustice/laa-court-data-adaptor) upon merging to master but requires manual approval through all environments to deploy to production.

## Dev: running locally

### Connect to hmcts-common-platform-mock-api
Since Common Platform API is deployed only on production, to assist the development and testing of CDA, we created a Common Platform Mock.
ACD team is committed to keep the API interface in sync.
To know more check out ([hmcts-common-platform-mock-api](https://github.com/ministryofjustice/hmcts-common-platform-mock-api/).

To run CP Mock locally:

- Add the following to `.env.development.local`
  ```
  COMMON_PLATFORM_URL=http://localhost:3001
  SHARED_SECRET_KEY=super-secret-key
  LAA_DEV_API_URL=http://localhost:3000
  LAA_DEV_OAUTH_URL=http://localhost:3000/v1/oauth/token
  ```

- Run the `hmcts-common-platform-mock-api` in parallel to the Court Data Adaptor on port 3001 to mock the Common Platform API.

## Environments
Information about other environments can be found on [this](https://dsdmoj.atlassian.net/wiki/spaces/ASLST/pages/2811068434/Environments) Confluence page

## Monitoring and Debugging
Kibana logs for production can be found [here](https://kibana.cloud-platform.service.justice.gov.uk/_plugin/kibana/app/kibana#/discover?_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:now-7d,to:now))&_a=(columns:!(kubernetes.namespace_id,log),filters:!(),index:d4959120-0186-11ec-8311-8b9e5a9c1db5,interval:auto,query:(language:lucene,query:'kubernetes.namespace_name:%20%22laa-court-data-adaptor-prod%22%20'),sort:!(!('@timestamp',desc))))

Sentry errors for production can be found [here](https://sentry.io/organizations/ministryofjustice/issues/?environement=prod&project=5375870)

To monitor the worker jobs execution you can access pods by running:
```
kubectl get pods --namespace laa-court-data-adaptor-[ENV]
kubectl exec --stdin --tty -n laa-court-data-adaptor-[ENV]] [POD-NAME]  -- bin/rails c
require 'sidekiq/api'
rs = Sidekiq::RetrySet.new
```
Further details can be found on [this](https://dsdmoj.atlassian.net/wiki/spaces/ASLST/pages/2697232715/How+to+access+different+environments+-+dev+test+uat+stage+production) confluence page.

## Pre-commit Hooks

Rubocop can be set up to run pre-commits.

Please see this [PR](https://github.com/ministryofjustice/laa-court-data-adaptor/pull/12)

## Sidekiq UI

There is a user interface for monitoring the sidekiq workers each environment. The credentials can be found in the helm values files.

- [Dev](https://laa-court-data-adaptor-dev.apps.live-1.cloud-platform.service.justice.gov.uk/sidekiq)
- [Test](https://laa-court-data-adaptor-test.apps.live-1.cloud-platform.service.justice.gov.uk/sidekiq)
- [UAT](https://laa-court-data-adaptor-uat.apps.live-1.cloud-platform.service.justice.gov.uk/sidekiq)
- [Staging](https://laa-court-data-adaptor-stage.apps.live-1.cloud-platform.service.justice.gov.uk/sidekiq)
- [Prod](https://laa-court-data-adaptor.apps.live-1.cloud-platform.service.justice.gov.uk/sidekiq)

## Contributing

Bug reports and pull requests are welcome.

1. Fork the project (https://github.com/ministryofjustice/laa-court-data-adaptor/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit until you are happy with your contribution (`git commit -am 'Add some feature'`)
4. Push the branch (`git push origin my-new-feature`)
5. Make sure your changes are covered by tests, so that we don't break it unintentionally in the future.
6. Create a new pull request.
