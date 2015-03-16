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

  * Confirmed 12:10 am shows the next day.
  * Hyperlinks
  * Uptime Monitor
  * robots.txt
  * Purchase cloudmailin subscription
  * Move subdomain to dailydancer.jackdesert.com
  * /admin/messages so people know it's intended only for admins

LAUNCH PLAN
-----------

DONE:

1         4       Subscribe ($9/month)
2         4       Responsive
2         10      Minimized

REMAINING:


POINTS    VALUE   ITEM
2         6       About Page
1         2       Support Page
2         10      Letter to List
3         2       Better Filters (a way to test them??)
8         8       Artwork (communication, pick best design, CSS to match)
1         2       Letter to Jenya
2         1       Load Testing (expected load?)

Backlog:

  * Redirect from www to naked domain (sinatra does not see the www)
  * Identify false positives.
  * Identify missing negatives
  * Correctly identify date when for Re: and Fw: in conjunction with 'on Friday, Nov 6 at 12:29pm so and so wrote ...'
  * Confirm that 11:50pm shows the same day (not the next)
  * Cache assets so they do not need requesting again
  * Make the subjects look more like buttons
  * Link for "show me more"
  * Build an interactive thing that displays a message and asks if the correct date has been found, then saves
    the "confirmed_date" so it is easy to test whether they are all correctly identified.
  * Fix so can pull down latest database
  * Add a flag for displaying N number of days
  * Scroll to top whenever page is reloaded && remove super long padding on bottom of footer


Icebox:

  * register pdxdailydancer.com
  * Staging site


