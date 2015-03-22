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

COMPLETED:

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
  * Create a link to the FAQ page
  * Confirm that 11:50pm shows the same day (not the next)
  * Use subject, author, and plain to determine duplicates, and only show latest if duplicate


PASSIONATE ABOUT:
  * Beautiful rendering of email content (possibly using html and parsing out custom styles)


PRETTY WARM ABOUT:
  * If two dates in body, choose the first one AFTER received-at
  * Make a way to manually hide a message (this requires less effor than building a perfect system)
  * Do not display "Move in as soon as May 1st." as an event
  * Advertise it among friends
  * Advertise on facebook list
  * Improve FAQ to include what it includes / doesn't include
  * Improve FAQ to include "What is this again?"
  * Spot-on styling and positioning on Android and iPhone (especially nav tabs)
  * Complete Rationale idea

SEEMS LIKE A GOOD IDEA:

  * Blacklist the AstrologyNow Forecast
  * Ask HEBA to design the FAQ page for me
  * Link for "show me more"
  * Fix so can pull down latest database
  * Redirect from www to naked domain (sinatra does not see the www)
  * Return the id when creating a message so cloudin can see it
  * Cache assets so they do not need requesting again
  * Test in IE8
  * Make response times faster (0.25 seconds with 120 entries)
  * Add to readme how to set up cloudmailin

NOT SO SURE ABOUT:

  * Add a url parameter for displaying N number of days
  * Scroll to top whenever page is reloaded
  * Inline scripts and stylesheets in production mode so only one network hit
  * Make a /jack page that tells about the author, and link to it instead of giving a mailto
  * Make sure received-at is converted to the correct day (Pacific time) when used to parse relative dates in subjects
  * (Jennifer, Nicholas) What about putting posting guidelines in the FAQ how to make sure the event is found?
  * register pdxdailydancer.com
  * Staging site
  * Build an interactive thing that displays a message and asks if the correct date has been found, then saves
    the "confirmed_date" so it is easy to test whether they are all correctly identified.
  * Investigate Zepto
  * Load Testing
  * Using the artwork from one of the fiverr artists (in /doc/artwork)

NEEDS PRIORITIZATION

  * Allow google to index either the faq page or the main page (without events)

Notes from Jennifer:
  * Can it bring in things from the facebook list too?
  * What about the weekly things? Why isn't next wednesday's dance on here yet?
  * Can we put the first four lines of the body?
  * How do I know who posted this? It makes a big difference to me.
  * Location, time? Are those hard?
  * I notice that a four-day event only shows up on the first day of that event...
  * How about a note, "automatically culled from..."
  * Votes for ten days' worth
  * If button for "show more", then can it be a big button?
  * If two emails for same event, how can I know which one is more recent?
  * What about really juicy events that are announced six weeks ahead and that will fill up fast? Do
    I want that to show up in DD?
  * When show-more button opens, can it go ALL THE WAY into the future.
