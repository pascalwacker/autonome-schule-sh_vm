#! /bin/sh
# /etc/init.d/mailhog
#
# MailHog init script.
#
# @author Jeff Geerling
# @author Renato Mendes Figueiredo

### BEGIN INIT INFO
# Provides:          mailhog
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start MailHog at boot time.
# Description:       Enable MailHog.
### END INIT INFO

PID=/var/run/mailhog.pid
USER=nobody
MAILHOG_PATH=/opt/mailhog
BIN=$MAILHOG_PATH/mailhog
MAILHOG_OPTS="-auth-file=$MAILHOG_PATH/auth -api-bind-addr=0.0.0.0:8025 -ui-bind-addr=0.0.0.0:8025"

# Carry out specific functions when asked to by the system
case "$1" in
  start)
    echo "Starting mailhog."
    start-stop-daemon --start --pidfile $PID --make-pidfile --user $USER --background --exec $BIN -- $MAILHOG_OPTS
    ;;
  stop)
    if [ -f $PID ]; then
      echo "Stopping mailhog.";
      start-stop-daemon --stop --pidfile $PID
    else
      echo "MailHog is not running.";
    fi
    ;;
  restart)
    echo "Restarting mailhog."
    start-stop-daemon --stop --pidfile $PID
    start-stop-daemon --start --pidfile $PID --make-pidfile --user $USER --background --exec $BIN -- $MAILHOG_OPTS
    ;;
  status)
    if [ -f $PID ]; then
      echo "MailHog is running.";
    else
      echo "MailHog is not running.";
      exit 3
    fi
    ;;
  *)
    echo "Usage: /etc/init.d/mailhog {start|stop|status|restart}"
    exit 1
    ;;
esac

exit 0
