# Setting up Postman

## Get credentials 
1. In laa-court-data-adaptor directory, open the rails console from the command line.

```
rails c
```

2. Enter the following command to generate authorization details:
```
application = Doorkeeper::Application.create(name: "HMCTS Common Platform")
```

## Set credentials
1. Open Postman

2. Create a new request

3. On the authorization tab, select `OAuth 2.0` from the TYPE dropdown menu.
In the Configure New Token section, set:

```
* Grant Type: Client Credentials

* Access Token URL: http://localhost:3000/oauth/token

* Client ID: `uid` taken from the rails console output

* Client Secret: `secret` taken from the rails console output
```

## Set local variables 
1. In laa-court-data-adaptor add a file at the root level named `.env.developement.local` and copy in the following variables:
```
COMMON_PLATFORM_URL=http://localhost:3001/
SHARED_SECRET_KEY=super-secret-key
ADMIN_USERNAME=admin
ADMIN_PASSWORD=password
LAA_DEV_API_URL=http://localhost:3001
LAA_DEV_OAUTH_URL=http://localhost:3001/v1/oauth/token
LAA_DEV_CLIENT_ID=
LAA_DEV_CLIENT_SECRET=
DATABASE_URL=postgres://localhost/laa_court_data_adaptor_development
```

## Start the servers
1. In laa-court-data-adaptor directory start the server on port 3000 (this is the default in the repo) from the command line by running:

```
rails s
```

2. In hmcts-common-platform-mock-api directory start the server on port 3001 from the command line by running:

```
rails s -p 3001
```

## Send request and view response
1. In Postman, enter the desired request URL (OpenAPI docs can be seen when running laa-court-data-adaptor server here http://localhost:3000/api-docs/index.html) e.g. http://localhost:3000/api/internal/v1/prosecution_cases?filter[prosecution_case_reference]=TEST12345
2. Generate an access token on the authentication tab, click Get New Access Token, Proceed, Use Token 
3. Press Send
4. Drag up the tab at the bottom of the page to view the response body