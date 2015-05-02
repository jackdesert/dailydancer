DailyDancer
===========

Daily Dancer is a Sinatra app that accepts emails via HTTP POST from a
provider such as http://cloudmailin.com, stores them in an sqlite database,
decides which emails represent *events*, and displays those events on a
calendar.

Daily Dancer also uses nokogiri to pull recurring events from a website
and incorporates them with slightly different styling into the calendar.


Working Example
---------------

The original site is in use at http://pdxdailydancer.com


Running the Tests
-----------------

    bundle exec rspec


Manually Firing Emails via HTTP
-------------------------------

You can use `bin/http_agent.rb` to fire emails at your server using the expected format.


Pry Console
--------------

This script will load models for you and give you a pry console

    $ ./inspect.sh


Migrations
----------

You will need to migrate the development and production databases manually.
(The test database calls migrations from spec/spec_helper automatically)

To run a specific migration against a particular environment:

    RACK_ENV=<environment> bundle exec pry
    [1] pry(main)> require './helper'
    [1] pry(main)> require './db/migrations/<name_of_migration>'


Running the server in Development Mode
--------------------------------------

    bundle exec rerun 'rackup config-dancer.ru -o 0.0.0.0' --background --pattern '*.rb'

Note the -o 0.0.0.0 is only necessary if you are running inside a VM


Running the server in Production Mode
-------------------------------------

First, install this patched version of nginx, which leaves weak etags intact:

  http://github.com/jackdesert/nginx

Add a symlink in nginx' sites-enabled directory that points to config/dancer-nginx.conf

    cd /path/to/sites-enabled
    sudo ln -s /home/<user>/dancer/config/dancer-nginx.conf
    sudo nginx -s reload

Install redis-server

    sudo apt-get install redis-server

Copy config/smtp.yml-EXAMPLE to config/smtp.yml and put in appropriate values for user_name and password

Then migrate a database with rack env set to production (see above)

Test that is starts

    RACK_ENV=production bundle exec rackup config-dancer.ru

Test that you can send mail by setting a breakpoint right before the mail is sent,
and send the mail. You may need to visit https://accounts.google.com/b/0/DisplayUnlockCaptcha to convince
google that your app is legit and owned by you.

Then shut if off and start it with this long-running script that will restart it if it
stops for any reason:

    nohup script/run_dancer_indefinitely.sh &


Deployments
-----------

* ssh into the production server
* cd to the dancer/ directory
* fetch new content from github
* `ps aux | grep dancer` to find the current sinatra (thin) process
* `kill <pid>` to kill that process. The long-running script will start another in two seconds


Viewing Logs
------------

Check log/event_load.log to make sure recurring events are being pulled correctly.


Setting up your mailing list
----------------------------

Sign up for an account at cloudmailin.com. Get a cloudmailin email address. Make sure your production
server is up and running. Subscribe your cloudmailin email address to your mailing list, then go into the
sqlite database using the "Inspect" instructions above to retrieve the verification link so you can prove
to your list serve that it's really your address. Then it's ready to go.


Viewing All Messages in Reverse Chronological Order
---------------------------------------------------

This view, while not intended for public consumption, lets you
sanity check that messages with dates in them show up on the correct day

    localhost:9292/admin/messages


Viewing Duplicates
------------------

This view shows duplicates in a different color so you can see what is being filtered out

    localhost:9292/?admin=true


Manually Hiding Messages
------------------------

    Message.find(id: <id>).hide('<reason>')


Credits
-------

Thank you to Nicholas for initial inspiration, and for all the times
we've hashed over what's actually important.
Thank you to Jennifer for noticing all the things it does and doesn't do.


Roadmap
--------------

COMPLETED:

  * Confirmed Util.current-date-in-portland works correctly before and after midnight
  * Hyperlinks are clickable
  * robots.txt opts out of search engines
  * /admin/messages allows a view into which messages are being picked up
  * Add negative lookahead expression that knows "march 2010" is not an event.
  * Correctly identify date when for Re: and Fw: in conjunction with 'on Friday, Nov 6 at 12:29pm so and so wrote ...'
  * Animations when clicking on subject
  * Text still selectable without activating animation
  * FAQ page with link to it
  * Responsive design using lightweight tools
  * Recognize "This Friday" in subject as an event
  * Use subject, author, and plain to determine duplicates, and only show latest if duplicate
  * Manual hiding of messages using the :hidden database colum
  * Pulling recurring events from pdxecstaticdance.com
  * Displaying author's name
  * Now using a CDN to host jQuery for faster download times and re-use
  * Link for "More Events" that shows three additional weeks
  * Now using pdxdailydancer.com
  * All user-agents see Events; Only browsers see Messages. This means we can be indexed by Google
  * collect unique IP addresses via (redis?) by date
  * Health check endpoint with monitor.us checking
  * Allow google to index either the faq page or the main page (without events)
  * Supply an etag for '/' and '/?xhr=true' so users can refresh without downloading code


PASSIONATE ABOUT:


  * Allow site to function even if redis-server is down
  * Beautiful rendering of email content (possibly using html and parsing out custom styles)


PRETTY WARM ABOUT:

  * Better posting guidelines: Nicholas suggests "put the date at the top". Jack suggests: "Spell out the date, and put it near the top"
  * If two dates in body, choose the first one AFTER received-at
  * Do not display "Move in as soon as May 1st." as an event
  * Advertise it among friends
  * Advertise on facebook list
  * Improve FAQ to include what it includes / doesn't include
  * Improve FAQ to include "What is this again?"
  * Spot-on styling and positioning on Android and iPhone (especially nav tabs)
  * Do not show "register by April 1"
  * Teach it to ignore "until May 20th"
  * Teach it to ignore "due May 20th"
  * Teach it to ignore "approximately May 20th"
  * negative lookbehind for "until <date>" and "before <date>"

SEEMS LIKE A GOOD IDEA:

  * Blacklist the AstrologyNow Forecast
  * Ask HEBA to design the FAQ page for me
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
  * Build an interactive thing that displays a message and asks if the correct date has been found, then saves
    the "confirmed_date" so it is easy to test whether they are all correctly identified.
  * Load Testing
  * Using the artwork from one of the fiverr artists (in /doc/artwork)

NEEDS PRIORITIZATION

  * Set up automatic database archiving
  * Print out slips of cardstock that have daily dancer address
  * Talk with Abigail about ways to get more mindshare around DailyDancer
  * Only load messages that arrived within the last 30 days. (And use an index on received at)
  * Make it faster (loading in 0.6 seconds). index on hidden? store parsed date? Memcached?
  * Search in subject + plain for date
  * Make sure digital ocean is set for automatic backups
  * Fix bug where when in UTC time it is a new month, but in Portland it is still the old month, and daily dancer
    assigns events to *Next Year* when it should assign them to this year
  * Get double line breaks from plain to display correctly. Use dailydancer promo as an example.
  * Add to FAQ: How do I post an event on DAily Dancer? "Post to sacredcircle listserve, and spell out the month when you list the event's date, like this: "There's a great party at my house on March 15th"
  * Canonical site---redirect anything that uses a subdomain to pdxdailydancer.com
  * 2" x 3.5" cards artfully designed (or not) with pdxdailydancer.com on it (and my name as creator/webmaster)
  * Disable button which fetching AJAX (at least for two seconds)
  * Find out how to get author email address
  * remove event-id column from Message since we don't link to it
  * nginx caching of dancer.js and style.css and reset.css
  * Get email addresses to show up in "from" above body. (now we have name)
  * Get better formatting of "from" when it's one of those weird ones
  * CTRL-z
  * Offer a way to send people "perma"links to events
  * Ensure the gzip is operating for all mime types via nginx
  * Make sure that for those who have caching disabled (like curl) that the
    cached response is still given
  * Note ids 409 - 449 inclusive were manually added using script


Notes from my Sweetheart:
  * ctrl-z to hide additional messages
  * Can it bring in things from the facebook list too?
  * Can we put the first four lines of the body?
  * Location, time? Are those hard?
  * I notice that a four-day event only shows up on the first day of that event...
  * What about really juicy events that are announced six weeks ahead and that will fill up fast? Do
    I want that to show up in DD?
  * When show-more button opens, can it go ALL THE WAY into the future.
