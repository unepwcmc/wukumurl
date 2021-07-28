FROM ruby:2.2.3
RUN apt-get update && apt-get -y install build-essential libpq-dev nodejs
RUN gem install bundler -v '~>1'
RUN mkdir /wcmcio
WORKDIR /wcmcio
ADD Gemfile /wcmcio/Gemfile
ADD Gemfile.lock /wcmcio/Gemfile.lock
RUN bundle install

ADD . /wcmcio


