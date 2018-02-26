# around_us
A Social network like application with Rails-Postgresql.

## Clone
Clone from the repository

```sh
git clone https://github.com/msv300/around_us
```

## Setup

# Copy all sample files
```
cp config/app_settings.yml.sample config/app_settings.yml
cp config/cable.yml.sample config/cable.yml
cp config/dalli.yml.sample config/dalli.yml
cp config/database.yml.sample config/database.yml
cp config/mailer.yml.sample config/mailer.yml
cp config/paperclip.yml.sample config/paperclip.yml
cp config/secrets.yml.sample config/secrets.yml
```

Edit the following files in the `config/` folder as per your settings
* app_settings.yml
* dalli.yml
* mailer.yml
* database.yml
* paperclip.yml

Once you are done with the settings do the following,

* install the dependent gems - `bundle install`
* create database with `rails db:create`
* generate swagger json files with `rails swagger:docs`
* start the server with `rails s`
* navigate to `http://localhost:3000` to see the swagger documentation

## Upcoming

* Unit test cases
* Dockerization
* ... more yet to come

## License
MIT License (MIT).

