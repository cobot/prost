## General

This app displays a simple button to pay for a drink. When clicked it uses the [cobot](http://cobot.me) API to charge the user for the drink. The charges will appear on the user's next invoice.

Users log in with their cobot accounts. In order to use the app they have to be a member of a space on cobot.

Right now the app charges one unit of whatever currency the user's plan has, so in the U.S. it would charge $1 per drink. In the future this should be configurable.

## Installation

This is a standard Rails app that uses Postresql as its database, so:

    bundle
    rake db:create
    rake db:migrate
    rake # run tests
