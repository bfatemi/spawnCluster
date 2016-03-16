#!/bin/bash
DisplayPage() {
	
	clear	
	row=$(((term_rows - banner_rows) / 2))
 	col=$(((term_cols - banner_cols) / 2))

	#tput cup $row $col	
	while IFS='' read -r line || [[ -n "$line" ]]; do
		tput cup $row $col
      		echo -n "$line"
      		((++row))
	done < $filepath
}

ClearPage() {
	read tmp
	tput sgr0; tput cnorm; tput rmcup || clear; return
}


AdjustTerminalSize() {
	term_rows=$(tput lines)
	term_cols=$(tput cols)

        msg="Make Window Larger"
        len=${#msg}	

        row=$((term_rows / 2 + 1))
        col=$(((term_cols - len) / 2))

	echo $term_rows
	echo $term_cols
	exit
	clear
	while [ "$term_rows" -le "$banner_rows" ] || [ "$term_cols" -le "$banner_cols" ]
	do
		tput cup $row $col
		#echo $msg
	done
#	DisplayPage
}

InitPage(){

	filepath=$1

	# tclock - Display a clock in a terminal
	BG_BLUE="$(tput setab 4)"
	FG_BLACK="$(tput setaf 0)"
	FG_WHITE="$(tput setaf 7)"
    
	# Set a trap to restore terminal on Ctrl-c (exit).
	# Reset character attributes, make cursor visible, and restore
	# previous screen contents (if possible).

	trap 'tput sgr0; tput cnorm; tput rmcup || clear; exit 0' SIGINT
	trap 'AdjustTerminalSize' WINCH   # trap when a user has resized the window

	# Save screen contents and make cursor invisible
	tput smcup; tput civis

	# Calculate sizes and positions
	IFS=''
	read -r line < $filepath
   
	banner_cols=${#line}
	banner_rows=$(cat $1 | wc -l)

	term_rows=$(tput lines)
	term_cols=$(tput cols)

	# Set the foreground and background colors and go!
	echo -n ${BG_BLUE}${FG_WHITE}
	AdjustTerminalSize
}






