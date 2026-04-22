#! /bin/bash

if [[ ! -d "~/.container_setup.sh" ]]; then
	cp ./.container_setup.sh ~/.container_setup.sh
	chmod +x ~/.container_setup.sh;
fi

if [[ -z $(grep "source $(echo $HOME)/.container_setup.sh" "$(echo $HOME)/.bashrc") ]]; then 
	echo "" >> ~/.bashrc # Newline
	echo "# For distrobox container setup:" >> ~/.bashrc
	echo "source ~/.container_setup.sh" >> ~/.bashrc;
fi
