#!/bin/sh
#
# i3blocks integration with dunst.
# Author: Vivien Didelot <vivien.didelot@gmail.com>
#
# dunst caches a notification and signals i3blocks.
# i3blocks catches the signal and prints the cached notification.
#
# Put this rule at the end of your ~/.config/dunst/dunstrc:
#
#     [i3blocks]
#         summary = "*"
#         script = FULL_PATH_OF_THIS_SCRIPT
#
# Add this block in your ~/.i3blocks.conf:
#
#     [dunst]
#     command=THIS_SCRIPT
#     signal=12

CACHE=~/.cache/i3blocks/notification

# Ensure the cache exists
mkdir -p `dirname $CACHE`
touch $CACHE

if env | grep -q BLOCK_
then # called by i3blocks

  # clear notification on click
  test $BLOCK_BUTTON -ne 0 && cp /dev/null $CACHE

  # source the notification
  . $CACHE

  FULL_TEXT="$SUMMARY $BODY"
  SHORT_TEXT="$SUMMARY"

  case $URGENCY in
    LOW)
      COLOR=#FFFFFF
      CODE=0
      ;;
    NORMAL)
      COLOR=#00FF00
      CODE=0
      ;;
    CRITICAL)
      COLOR=#FF0000
      CODE=33
      ;;
    *)
      # unknown urgency, certainly empty notification
      exit 0
      ;;
  esac

  # Output the status block
  echo $FULL_TEXT
  echo $SHORT_TEXT
  echo $COLOR
  exit $CODE

else # called by dunst

  # store the notification
  cat << dunst > $CACHE
APPNAME="$1"
SUMMARY="$2"
BODY="$3"
ICON="$4"
URGENCY="$5"
dunst

  # signal i3blocks that there is a new notification
  pkill -RTMIN+12 i3blocks
  exit

fi

# vim: ts=2 sw=2 et
