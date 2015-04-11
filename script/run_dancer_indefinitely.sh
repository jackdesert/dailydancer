#! /bin/bash

# this script is just a wrapper around daily_lager so that it
# will start up again immediately if it ever dies
# Kind of like what a unicorn server would do
#
# The proper way to invoke this script is to call
#   nohup script/run_daily_lager_indefinitely.sh &

# This reminder only displays in the terminal if you forget to invoke with 'nohup'
echo "REMINDER: call this with 'nohup' and a trailing '&'"

while true; do
  cd /home/dev/dancer
  rm -r cache
  bundle install
  RACK_ENV=production bundle exec rackup config-dancer.ru -p 8852
  sleep 2
  echo "dancer restarted `date`" >> log/dancer_restart.log
done


