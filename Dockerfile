FROM debian:latest
RUN apt-get update && apt-get install -y \
	apt-transport-https \
	ca-certificates \
	curl \
	gnupg \
	--no-install-recommends \
	&& curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
	&& echo "deb https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
	&& apt-get update && apt-get install -y \
	google-chrome-beta \
	fontconfig \
	fonts-ipafont-gothic \
	fonts-wqy-zenhei \
	fonts-thai-tlwg \
	fonts-kacst \
	fonts-symbola \
	fonts-noto \
	fonts-freefont-ttf \
	--no-install-recommends \
	&& apt-get purge --auto-remove -y curl gnupg \
	&& rm -rf /var/lib/apt/lists/*
RUN apt-get update -qq
RUN apt-get install -y curl build-essential ruby ruby-dev patch zlib1g-dev liblzma-dev libpq-dev libfreetype6 libfreetype6-dev google-chrome-beta fontconfig fonts-freefont-ttf xvfb
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
EXPOSE 3000
CMD env && rake db:migrate && bundle exec puma -C config/puma.rb