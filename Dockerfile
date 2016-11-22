FROM alpine:3.3
MAINTAINER Mfu Tech <mfutech@gmail.com>

## required package for ruby and gems dependencies
ENV RUBY_PACKAGES ruby ruby-bundler ruby-io-console ruby-bigdecimal ruby-json

## first update to lastest version
RUN apk update && \
    apk upgrade && \
	# correct timezone (we will use crontab)
	apk add tzdata && \
	cp /usr/share/zoneinfo/Europe/Zurich  /etc/localtime && \
    echo "Europe/Zurich" > /etc/timezone && \
	apk del tzdata && \
	# add ruby package
	apk add $RUBY_PACKAGES && \
	rm -rf /var/cache/apk/*

## create working environment
RUN mkdir /usr/app 
WORKDIR /usr/app

COPY Gemfile /usr/app/ 
COPY Gemfile.lock /usr/app/ 
RUN bundle install

COPY . /usr/app

VOLUME /usr/app/config
ENTRYPOINT ruby /usr/app/scheduler.rb