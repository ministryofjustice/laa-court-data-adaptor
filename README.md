# LAA Court Data Adaptor

This application acts as a proxy between the HMCTS Common Platform and LAA systems.

Its main functions will be data translation / adaptation, and queueing of requests.

As the Common Platform API is not yet live to us, we have also created a Mock of it, which can be found [here](https://github.com/ministryofjustice/hmcts-common-platform-mock-api/)

Run this in parallel to the Court Data Adaptor to mock the Common Platform API.

## Set up

This is a standard 6 Rails API application. Using Postgres 12.1 as a database.

Clone the repo, then run:

```
$ bundle exec install
$ rails db:setup
```

You can then start the application server by running:

```
$ rails s
```


### Git hooks for robocop

Rubocop can be set up to run pre-commits.

Please see this [PR](https://github.com/ministryofjustice/laa-court-data-adaptor/pull/12)
