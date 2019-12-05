FROM debian:latest
RUN apt-get update -qq
RUN apt-get install -y curl build-essential ruby ruby-dev patch zlib1g-dev liblzma-dev libpq-dev libfreetype6 libfreetype-dev
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN curl --silent --location https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs yarn
RUN gem install bundler
RUN mkdir /tubatuba
WORKDIR /tubatuba
ADD Gemfile /tubatuba/Gemfile
ADD Gemfile.lock /tubatuba/Gemfile.lock
RUN bundle install
ADD package.json /tubatuba/package.json
RUN yarn install --check-files
RUN yarn install
ADD . /tubatuba
RUN bundle exec rails assets:precompile
RUN bundle exec rails webpacker:compile
EXPOSE 3000
CMD env && rake db:migrate && bundle exec puma -C config/puma.rb