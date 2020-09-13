FROM ruby:2.6.3
RUN apt-get update; \
		apt-get install -y chromium
