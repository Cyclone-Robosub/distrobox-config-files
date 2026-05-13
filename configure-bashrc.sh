#! /bin/bash

if [[ ! -f "$(echo $HOME)/.container-setup.sh" ]]; then
	cp ./.container-setup.sh ~/.container-setup.sh
	chmod +x ~/.container-setup.sh;
fi

USR_SHELL=$(echo $SHELL | awk -F  '/' '{print $NF}')

if [[ -z $(grep "source ~/.container-setup.sh" "$(echo $HOME)/.$(echo $USR_SHELL)rc") ]]; then 
	echo "" >> ~/.bashrc # Newline
	echo "# For distrobox container setup:" >> ~/.bashrc
	echo "source ~/.container-setup.sh" >> ~/.bashrc;
fi
