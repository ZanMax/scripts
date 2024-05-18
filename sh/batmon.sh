#!/bin/bash

# Install brightness
# brew install brightness

while true
do
  if [[ $(pmset -g ps | head -1) =~ "AC Power" ]]; then
    clear
    echo "AC"
    sleep 180
  else
    BATPERSENT=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
    clear
    echo $BATPERSENT
    if [[ $BATPERSENT > 90 ]]; then
      brightness 0.5
    elif [[ $BATPERSENT > 70 ]] && [[ $BATPERSENT < 90 ]]; then
      brightness 0.4
    elif [[ $BATPERSENT > 50 ]] && [[ $BATPERSENT < 70 ]]; then
      brightness 0.3
    elif [[ $BATPERSENT > 30 ]] && [[ $BATPERSENT < 50 ]]; then
      brightness 0.2
    elif [[ $BATPERSENT > 10 ]] && [[ $BATPERSENT < 30 ]]; then
      brightness 0.15
    elif [[ $BATPERSENT < 10 ]]; then
      brightness 0.1
    fi
    sleep 30
  fi
done