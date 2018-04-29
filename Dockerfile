FROM ruby:2.3.1

RUN apt-get update -qq && apt-get install -y build-essential nodejs memcached

RUN mkdir /around_us_blog

WORKDIR /around_us_blog

COPY Gemfile /around_us_blog/Gemfile
COPY Gemfile.lock /around_us_blog/Gemfile.lock

RUN gem install bundler
RUN bundle install

COPY . /around_us_blog

# RUN chmod +x /around_us_blog/copy_sample_files.sh

# RUN /around_us_blog/copy_sample_files.sh

#RUN bundle exec rails db:migrate

#RUN bundle exec rails swagger:docs