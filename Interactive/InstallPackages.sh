#!/bin/bash
. InitPage.sh

GetNeededSize(){
	local NEEDED size LIST DEPENDENCIES PACKAGE_LIST
        LIST=$1
	
        PACKAGE_LIST=$(dpkg --get-selections | awk '{ print $1 }' | grep -v -e "-dbg" | cut -f1 -d":")

        getsize () {
           size=$(apt-cache --no-all-versions show $1 | grep Installed-Size | awk '{ print $2 }')
           ((NEEDED+=$size))
        }

        for package in $LIST; do
           getsize $package
           DEPENDENCIES=$(apt-cache depends $package | grep Depends | awk '{ print $2 }')
           for dependency in $DEPENDENCIES; do
               if [[ ! $PACKAGE_LIST =~ [^.[:alnum:]-]"$dependency"[^.[:alnum:]-] ]]; then
                  getsize $dependency
               fi
           done
        done

        NEEDED=$((NEEDED * 1000))
	echo $NEEDED
}


InstallPkg(){
	pkg=$1
	
	sBytes=$(GetNeededSize ${!pkg})
	
	sudo apt-get --force-yes --yes -qq install "$pkg" 2> /dev/null | \
	pv -tr -s $sBytes -N "Installing $pkg" --width "80" -l > /dev/null &
	pid=$!

	# If this script is killed, kill the `cp'.
	trap "kill $pid 2> /dev/null" EXIT

	# While copy is running...
	while kill -0 $pid 2> /dev/null; do
		tput cup $((row + 1)) $col
	done

}

UninstallPkg(){
        pkg=$1

        sBytes=$(GetNeededSize ${!pkg})

        sudo apt-get --force-yes --yes -qq autoremove "$pkg" 2> /dev/null | \
        pv -tr -s $sBytes -N "Installing $pkg" --width "80" -l > /dev/null &
        pid=$!

        # If this script is killed, kill the `cp'.
        trap "kill $pid 2> /dev/null" EXIT

        # While copy is running...
        while kill -0 $pid 2> /dev/null; do
                # Do stuff
                tput cup $row $col
		((++row))
        done
}


#UninstallPackages cmatrix



#InitPage
#filepath=../art/packages/inst-java.txt

InitPage ../art/intro.txt
read tmp

DisplayPage "../art/packages/inst-java.txt"
InstallPkg default-jdk

DisplayPage "../art/packages/inst-xml.txt"
InstallPkg xmlstarlet

DisplayPage "../art/packages/inst-cmatrix.txt"
InstallPkg cmatrix

DisplayPage "../art/packages/inst-vim.txt"

DisplayPage "../art/packages/inst-done.txt"
ClearPage



