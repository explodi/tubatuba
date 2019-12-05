FROM debian:stretch
RUN apt-get update -qq
RUN apt-get install -y curl build-essential libpq-dev apt-transport-https ruby ruby-dev libxslt-dev libxml2-dev libgmp3-dev imagemagick libmagic-dev libmagickwand-dev ffmpeg jpegoptim optipng
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