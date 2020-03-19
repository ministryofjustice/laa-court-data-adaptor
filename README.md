# LAA Court Data Adaptor

This application acts as a proxy between the HMCTS Common Platform and LAA systems.

Its main functions will be data translation / adaptation, and queueing of requests.

As the Common Platform API is not yet live to us, we have also created a Mock of it, which can be found [here](https://github.com/ministryofjustice/hmcts-common-platform-mock-api/)

Run this in parallel to the Court Data Adaptor to mock the Common Platform API.


## Set up

This is a standard 6 Rails API application. Using Postgres 12.1 as a database.

Clone the repo, then run:

```
$ bundle install
$ rails db:setup
```

You can then start the application server by running:

```
$ rails s
```


### API Authentication

Create an OAuth Application for each system that needs to authenticate to the adaptor via the console.
```ruby
application = Doorkeeper::Application.create(name: 'HMCTS Common Platform')
```
The client credentials are available against the `application` as `application.uid` and `application.secret`
Use these credentials to generate an `access_token` by making a call to the OAuth endpoint described in the [schema](https://github.com/ministryofjustice/laa-court-data-adaptor/blob/master/schema/schema.md#oauth-endpoints-authentication).


##### Making authenticated requests:
Send the `access_token` provided by the OAuth endpoint as a Bearer Token.
eg:
```curl
curl --get \
--url 'https://API_HOST/api/internal/v1/prosecution_cases' \
--data-urlencode 'filter[first_name]=Boris' \
--data-urlencode 'filter[last_name]=Lubowitz' \
--data-urlencode 'filter[date_of_birth]=1981-08-22' \
--data-urlencode 'include=defendants' \
--header 'Authorization: Bearer <access_token>'
```

### Git hooks for Rubocop

Rubocop can be set up to run pre-commits.

Please see this [PR](https://github.com/ministryofjustice/laa-court-data-adaptor/pull/12)

### API Schema

We use [rswag](https://github.com/rswag/rswag) to document with [swagger](https://swagger.io/) the endpoints that are being exposed.

To view the API documentation, start the rails server locally using `rails s` and then browse to http://localhost:3000/api-docs/index.html.

To use the 'Try it out' functionality, you need to have first created an oAuth user in your local database. See [here](https://github.com/ministryofjustice/laa-court-data-adaptor#api-authentication) for details.

To add a new endpoint, run `rails generate rspec:swagger <controller_name>` to generate a request spec. Add appropriate tests and content to the spec, then run `rake rswag`. The new endpoint should now appear in the Swagger UI interface.
