FROM ruby:2.6.6
RUN apt-get update; \
		apt-get install -y chromium
