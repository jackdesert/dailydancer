Dancer
======


Inspect
=======

    $ be ruby pry
    > require './helper'

Running the Tests
-----------------

    bundle exec rspec


Migrations
----------

To run a specific migration against a particular environment:

    RACK_ENV=<environment> bundle exec pry
    [1] pry(main)> require './helper'
    [1] pry(main)> require './db/migrations/<name_of_migration>'


Running the server in Development Mode
--------------------------------------

    bundle exec rerun 'rackup config-dancer.ru -o 0.0.0.0' --background

If you are running it in a VM and can't access it from the host OS,
add

    -o 0.0.0.0

to the command

Running the server in Production Mode
-------------------------------------

    nohup script/run_dancer_indefinitely.sh &

Roadmap
--------------

Completed:

  *

LAUNCH PLAN
-----------

POINTS    VALUE   ITEM
1         4       Subscribe ($9/month)
2         4       Responsive
2         10      Minimized
2         6       About Page
1         2       Support Page
2         10      Letter to List
3         2       Better Filters (a way to test them??)
8         8       Artwork (communication, pick best design, CSS to match)
1         2       Letter to Jenya
2         1       Load Testing (expected load?)

Backlog:

  * Purchase cloudmailin subscription
  * Redirect from www to naked domain
  * Identify false positives.
  * Identify missing negatives
  * Correctly identify date when for Re: and Fw: in conjunction with 'on Friday, Nov 6 at 12:29pm so and so wrote ...'
  * Decide if one week is the ideal amount of events to display
  * Get www to redirect in production
  * Staging site
  * Uptime Monitor
  * Hyperlinks


Icebox:

  *


