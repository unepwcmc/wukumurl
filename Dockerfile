FROM ruby:2.2.3
RUN apt-get update && apt-get -y install build-essential libpq-dev nodejs
RUN gem install bundler -v '~>1'
RUN mkdir /wcmcio
WORKDIR /wcmcio
ADD Gemfile /wcmcio/Gemfile
ADD Gemfile.lock /wcmcio/Gemfile.lock
RUN bundle install

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Configure the main process to run when running the image
CMD ["rails", "server", "-b", "0.0.0.0"]
