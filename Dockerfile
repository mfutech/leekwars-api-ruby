FROM alpine:3.3
MAINTAINER Mfu Tech <mfutech@gmail.com>

## working TimeZone
ENV TZ Europe/Zurich

## required package for ruby and gems dependencies
ENV RUBY_PACKAGES ruby ruby-bundler ruby-io-console ruby-bigdecimal ruby-json

## first update to lastest version
RUN apk update && \
    apk upgrade && \
	# correct timezone (we will use crontab)
	apk add tzdata && \
	cp /usr/share/zoneinfo/Europe/Zurich  /etc/localtime && \
    echo "$TZ" > /etc/timezone && \
	apk del tzdata && \
	# add ruby package
	apk add $RUBY_PACKAGES && \
	rm -rf /var/cache/apk/*

## create working environment
RUN mkdir /usr/app 
WORKDIR /usr/app

COPY Gemfile /usr/app/ 
COPY Gemfile.lock /usr/app/ 

RUN apk --update add --virtual build_deps \
    build-base ruby-dev libc-dev linux-headers \
    openssl-dev postgresql-dev libxml2-dev libxslt-dev && \
    bundle install && \
    apk del build_deps

COPY . /usr/app

VOLUME /usr/app/config
ENTRYPOINT ruby /usr/app/scheduler.rb
