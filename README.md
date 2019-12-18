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

Create a user account through the rails console:
```
user = User.create(name: 'System User', auth_token: '<SUPER_SECRET_TOKEN>')
# or generate a random token
user = User.create(name: 'System User', auth_token: User.generate_unique_secure_token)
```

Note that the `auth_token` is stored as a password digest, and cannot be retrieved if lost.

Now you can make authenticated request by passing an authorisation header in the request payload. The header should look like:
```
Authorization: Bearer <SUPER_SECRET_TOKEN>, user_id=<USER-UUID>
```

### Git hooks for Rubocop

Rubocop can be set up to run pre-commits.

Please see this [PR](https://github.com/ministryofjustice/laa-court-data-adaptor/pull/12)
