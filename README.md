[![CircleCI](https://circleci.com/gh/ministryofjustice/laa-court-data-adaptor.svg?style=shield)](https://app.circleci.com/pipelines/github/ministryofjustice/laa-court-data-adaptor?branch=master)

[![repo standards badge](https://img.shields.io/badge/dynamic/json?color=green&style=for-the-badge&logo=github&label=MoJ%20Compliant&query=%24.data%5B%3F%28%40.name%20%3D%3D%20%22laa-court-data-adaptor%22%29%5D.status&url=https%3A%2F%2Foperations-engineering-reports.cloud-platform.service.justice.gov.uk%2Fgithub_repositories)](https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/github_repositories#laa-court-data-adaptor "Link to report")

# LAA Court Data Adaptor

This application is an adaptor or anti-corruption layer that connects to HMCTS’ Common Platform and transmits data between HMCTS Common Platform and various LAA systems.

Its main function is data translation / adaptation, and queueing of requests.

The application is commonly referred to by its acronym "CDA".

## Table of Contents
- [**Contact the team**](#contact-the-team)
- [**Architecture Diagrams**](#architecture-diagram)
- [**Environments**](#environments)
- [**Dependencies**](#dependencies)
- [**Set up**](#set-up)
- [**API Authentication**](#api-authentication)
- [**API Schema**](#api-schema)
- [**Deployment**](#deployment)
- [**Dev: running locally**](#dev-running-locally)
- [**Stage**](#stage)
- [**UAT**](#uat)
- [**Monitoring and Debugging**](#monitoring-and-debugging)
- [**Pre-commit Hooks**](#pre-commit-hooks)
- [**Contributing**](#contributing)

## Contact the team

Court Data Adaptor is maintained by staff in the Legal Aid Agency. If you need support, you can contact the team on our Slack channel:
- [#laa-crime-apps-core](https://mojdt.slack.com/archives/CT0Q47YCQ) on MOJ Digital & Technology

## Architecture Diagram

View the [architecture diagram](https://structurizr.com/share/55246/diagrams#cda-container) for this project.
It's defined as code and [can be edited](https://github.com/ministryofjustice/laa-architecture-as-code/blob/main/src/main/kotlin/model/CDA.kt) by anyone.

## Dependencies

* Ruby version
    * Ruby version 3.0.4
      To install various ruby versions, install a Ruby Version Manager.
      Two popular are [RVM](https://rvm.io/) and [asdf](https://asdf-vm.com/).

    * Rails 6.1.6.1

* System dependencies
    * postgres 14.3
    * redis

Install dependencies with bundler:
```
bundle install
```
## Set up

To set up  CDA in your local machine, you can run the following services manually:
- Rails (the application server)
- Postgres
- Redis and Sidekiq

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
```
rails console
```
```ruby
application = Doorkeeper::Application.create(name: 'HMCTS Common Platform')
```
The client credentials are available against the `application` as `application.uid` and `application.secret`
Use these credentials to generate an `access_token` by making a call to the OAuth endpoint described in the [schema](https://github.com/ministryofjustice/laa-court-data-adaptor/blob/master/schema/schema.md#oauth-endpoints-authentication).


### Making authenticated requests:
Send the `access_token` provided by the OAuth endpoint as a Bearer Token.
eg:
```curl
curl --get \
--url 'https://API_HOST/api/internal/v1/prosecution_cases' \
--data-urlencode 'filter[name]=Boris Lubowitz' \
--data-urlencode 'filter[date_of_birth]=1981-08-22' \
--data-urlencode 'include=defendants' \
--header 'Authorization: Bearer <access_token>'
```

## API Schema

We use [rswag](https://github.com/rswag/rswag) to document with [swagger](https://swagger.io/) the endpoints that are being exposed.

To view the API documentation, start the rails server locally using `rails s` and then browse to http://localhost:3000/api-docs/index.html.

To use the 'Try it out' functionality, you need to have first created an oAuth user in your local database. See [here](https://github.com/ministryofjustice/laa-court-data-adaptor#api-authentication) for details.

To add a new endpoint, run `rails generate rspec:swagger <controller_name>` to generate a request spec. Add appropriate tests and content to the spec, then run `rake rswag`. The new endpoint should now appear in the Swagger UI interface.

## Deployment

The build is triggered in [CircleCI](https://circleci.com/gh/ministryofjustice/laa-court-data-adaptor) upon merging to master but requires manual approval through all environments to deploy to production.

## Dev: running locally
As the Common Platform API does not have a sandbox to independently create test data in, we have also created a Mock of it to use when working in local development, which can be found [here](https://github.com/ministryofjustice/hmcts-common-platform-mock-api/)

Add the following to `.env.development.local`
```
COMMON_PLATFORM_URL=http://localhost:3001
SHARED_SECRET_KEY=super-secret-key
LAA_DEV_API_URL=http://localhost:3000
LAA_DEV_OAUTH_URL=http://localhost:3000/v1/oauth/token
```

Run the `hmcts-common-platform-mock-api` in parallel to the Court Data Adaptor on port 3001 to mock the Common Platform API.

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


## Contributing

Bug reports and pull requests are welcome.

1. Fork the project (https://github.com/ministryofjustice/laa-court-data-adaptor/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit until you are happy with your contribution (`git commit -am 'Add some feature'`)
4. Push the branch (`git push origin my-new-feature`)
5. Make sure your changes are covered by tests, so that we don't break it unintentionally in the future.
6. Create a new pull request.
