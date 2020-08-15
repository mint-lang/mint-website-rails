
<p align="center">
  <img src="https://github.com/Multimegamander/mint-website-rails/blob/master/banner.png?raw=true" alt="mint website></img>
</p>         

<p align="center"> 

<a href="https://gitter.im/mint-lang/Lobby" target="_blank">
	<img src="https://img.shields.io/gitter/room/7d924c483d0d9dff10763921aea2038e660e1252/68747470733a2f2f6261646765732e6769747465722e696d2f67697474657248512f6769747465722e737667" />
</a>

<a href="https://discord.gg/NXFUJs2" target="_blank">
	<img src="https://img.shields.io/discord/698214718241767445?color=7289DA&label=Discord&style=plastic" />
</a>
</p>

<p align="center">
	This is the source code for the website <a href="www.mint-lang.com" target="_blank">www.mint-lang.com</a>. Along with the API for <a href="sandbox.mint-lang.com" target="_blank">sandbox.mint-lang.com</a>
</p>

<p align="center">
	Written by <a href="https://github.com/mint-lang/mint-website-rails/graphs/contributors" target="blank">these</a> lovely people! ❤️
</p>


## Requirements

The website is a [Ruby on Rails](https://rubyonrails.org/) application.

To get up and running you will need:

-   [Ruby](https://www.ruby-lang.org/en/)  (2.6.3) installed
-   [PostgreSQL](https://www.postgresql.org/)  installed, including  `libpq-dev`

## Setup
-   Install Rails and Bundler
    -   `$ gem install rails bundler`
-   Install project dependencies
    -   `$ bundle install`

## Starting the server

You will need to:

-   Create a database  `rails db:create`
-   Migrate the database  `rails db:migrate`
-   Start the server  `rails s`

## [](https://github.com/Multimegamander/mint-website-rails#why-ruby)Why Ruby?

Mint is designed for writing SPAs, but this website is mostly static and cacheable, therefore it makes little sense to build it as a SPA. It's all about picking the right tool for the job.
