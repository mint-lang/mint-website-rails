# Mint Website

[![Gitter chat](https://badges.gitter.im/gitterHQ/gitter.svg)](https://gitter.im/mint-lang/Lobby)
[![Join the community on Spectrum](https://withspectrum.github.io/badge/badge.svg)](https://spectrum.chat/mint-lang)
[![Discord](https://discord.com/assets/f8389ca1a741a115313bede9ac02e2c0.svg)](https://discord.gg/NXFUJs2)

---

This repository hosts the code for the website of the Mint programming language
www.mint-lang.com

Also it hosts the API for the sandbox site sandbox.mint-lang.com

## Requirements

The website is a [Ruby on Rails](https://rubyonrails.org/) application.

To get up and running you will need:

- [Ruby](https://www.ruby-lang.org/en/) (2.6.3) installed
- [PostgreSQL](https://www.postgresql.org/) installed, including `libpq-dev`

## Setup

- Install Rails and Bundler
  - `$ gem install rails bundler`
- Install project dependencies
  - `$ bundle install`

## Starting the server

You will need to:

- Create a database `rails db:create`
- Migrate the database `rails db:migrate`
- Start the server `rails s`

## Why Ruby?

Mint is designed for writing SPAs, but this website is mostly static and cacheable, therefore it makes little sense to build it as a SPA. It's all about picking the right tool for the job.