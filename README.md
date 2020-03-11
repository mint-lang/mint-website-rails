# Mint Website

[![Gitter chat](https://badges.gitter.im/gitterHQ/gitter.svg)](https://gitter.im/mint-lang/Lobby)
[![Join the community on Spectrum](https://withspectrum.github.io/badge/badge.svg)](https://spectrum.chat/mint-lang)

-------------

This repository hosts the code for the website of the Mint programming language
www.mint-lang.com

Also it hosts the API for the sandbox site sandbox.mint-lang.com

## Setup

The website is a [Ruby on Rails](https://rubyonrails.org/) application.

To get up and running you will need:

- [Ruby](https://www.ruby-lang.org/en/) (2.6.3) installed
- [PostgreSQL](https://www.postgresql.org/) installed

## Starting the server

You will need to:

- Create a database `rails db:create`
- Migrate the database `rails db:migrate`
- Start the server `rails s`
