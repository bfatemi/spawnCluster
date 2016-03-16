#!/bin/bash
RunProgress(){

    run=true
    while $run; do

      # Set the background and draw the clock
      
      if tput bce; then # Paint the screen the easy way if bce is supported
        clear
      else # Do it the hard way
        tput home
        echo -n "$blank_screen"
      fi
      tput cup $clock_row $clock_col
      display_art
      
      # Draw a black progress bar then fill it in white
      tput cup $progress_row $progress_col
      echo -n ${FG_BLACK}
      echo -n "###########################################################"
      tput cup $progress_row $progress_col
      echo -n ${FG_WHITE}

      # Advance the progress bar every second until a minute is used up
      for ((i = $(date +%S);i < 60; ++i)); do
        echo -n "#"
        sleep 1
      done
    done
}
