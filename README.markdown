Overview
========

Blood On The Tracks is a post-request inspection / debugging API for
Rails, along with a Firebug extension that can use this debugger.

This is *super-duper-pre-alpha software!!!*.

* It probably won't work for you.
* You should probably not even attempt to install this unless
  you are a Rails developer and you have some familiarity with Firefox
  extensions.
* Don't run this in production.
* This leaks memory like a sieve.
* This gives the entire internet shell access to your boxen.
* This will delete all the data in your DB as well as all your
  backups (okay, probably not, but you never know).

Installation
============

If you're still here, here's how to get started:

    script/plugin install git://github.com/bradleybuda/bloodonthetracks.git

Then edit `config/environments/development.rb` and make
sure these lines are present:

    config.middleware.use "BloodOnTheTracks::Server"
    config.cache_classes = true

Restart Rails. Then open Firefox and visit
`/blood_on_the_tracks/install` on your Rails app to install
the Firefox plugin (you'll need to install Firebug first).

After restarting Firefox, visit your Rails app and pop open Firebug.
You should see a "Rails" tab with some information on the current
controller and action, instance variables in scope, and a console.

Troubleshooting
===============

* Check the Rails logs
* Check the Firefox error console

Hacking / TODOs
===============

I'm still working on a list of TODOs, but they are many and
plentiful.  The big picture TODOs are:

* Allow the plugin to run with reloaded classes in development mode
  (need to persist objects as JSON or Marshal to handle class reloading)
* Make the Rails plugin safer, more secure, less memory-leaky, and
  less likely to crash your app.
* Instrument more things in Rails (views / layouts / templates,
  performance, logs, etc).
* Make the Firebug plugin pretty.
* Make the Firebug console not suck.
* Add an API to render a page using modified instance variables.
* Allow the eval API to keep local variables around in scope.
