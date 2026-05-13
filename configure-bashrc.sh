#! /bin/bash

if [[ ! -f "$(echo $HOME)/.container_setup.sh" ]]; then
	cp ./.container_setup.sh ~/.container_setup.sh
	chmod +x ~/.container_setup.sh;
fi

USR_SHELL=$(echo $SHELL | awk -F  '/' '{print $NF}')

if [[ -z $(grep "source ~/.container_setup.sh" "$(echo $HOME)/.$(echo $USR_SHELL)rc") ]]; then 
	echo "" >> ~/.bashrc # Newline
	echo "# For distrobox container setup:" >> ~/.bashrc
	echo "source ~/.container_setup.sh" >> ~/.bashrc;
fi
