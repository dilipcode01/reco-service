# syntax = docker/dockerfile:1

FROM ruby:3.2.4

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs yarn

# Set working directory
WORKDIR /app

# Install Rails and Sequent
RUN gem install rails -v '7.1.3' && gem install sequent

# Copy Gemfiles first for caching
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the rest of the app
COPY . .

# Precompile (if needed) and set entrypoint
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"] 