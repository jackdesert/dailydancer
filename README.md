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
  * Add negative lookahead expression that knows "march 2010" is not an event.
  * Correctly identify date when for Re: and Fw: in conjunction with 'on Friday, Nov 6 at 12:29pm so and so wrote ...'
  * Make it so you can select text AND so it's easy to minimize things.
  * Inertial transitions when events expand/contract.
  * Make a FAQ page
  * Make the subjects look more like buttons
  * Display "This Friday" as an event

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

  * Ask HEBA to design the FAQ page for me
  * Create a link to the FAQ page
  * Make a /jack page that tells about the author, and link to it instead of giving a mailto
  * Link for "show me more"

  * Confirm that 11:50pm shows the same day (not the next)
  * Fix so can pull down latest database
  * Add a parameter for displaying N number of days
  * Scroll to top whenever page is reloaded && remove super long padding on bottom of footer
  * Return the id when creating a message so cloudin can see it
  * Redirect from www to naked domain (sinatra does not see the www)
  * Inline scripts and stylesheets in production mode so only one network hit
  * Cache assets so they do not need requesting again
  * Test in IE8

  * Ask heba to show minimized versions
  * Do not display "Move in as soon as May 1st." as an event
  * Make sure received-at is converted to the correct day (Pacific time) when used to parse relative dates in subjects
  * Make response times faster (0.25 seconds with 120 entries)
  * Add to readme how to set up cloudmailin
  * Provide a "Contact" link (because that's what users expect)
  * Add to README the rationale behind the architectural decisions made


Icebox:

  * register pdxdailydancer.com
  * Staging site
  * Build an interactive thing that displays a message and asks if the correct date has been found, then saves
    the "confirmed_date" so it is easy to test whether they are all correctly identified.
  * Identify false positives.
  * Identify missing negatives
  * Cache assets so they do not need requesting again
  * Make a support page and put the link to it at the bottom (with a big arrow for BACK)
  * Make an about page and put the link to it in the footer (with a big arrow for BACK)
  * Investigate Zepto
  * Blacklist the AstrologyNow Forecast
  * Find a way to hide duplicates (even if it's manually)
  * Hide duplicates if same subject
  * If two dates in body, choose the first one AFTER received-at

Notes from Jennifer:
*** Can it bring in things from the facebook list too?
* What about the weekly things? Why isn't next wednesday's dance on here yet?
* Can we put the first four lines of the body?
* How do I know who posted this? It makes a big difference to me.
* Location, time? Are those hard?
* I notice that a four-day event only shows up on the first day of that event...
* How about a note, "automatically culled from..."
* Votes for ten days' worth
* If button for "show more", then can it be a big button?
* It sounds like you are calling yourself Daily Dancer
* What about putting posting guidelines in the FAQ how to make sure the event is found?
* If two emails for same event, how can I know which one is more recent?
* What about really juicy events that are announced six weeks ahead and that will fill up fast? Do
  I want that to show up in DD?
* Are you going to put in FAQ, "Who is Jack Desert?"

Last Call: When show-more button opens, can it go ALL THE WAY into the future.
