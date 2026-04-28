if [ -f /opt/ros/jazzy/setup.bash ]; then
    source /opt/ros/jazzy/setup.bash;
fi

if [ -n "$CONTAINER_ID" ] || [ -n "$DISTROBOX_ENTER_PATH" ]; then
    PICO_SCRIPT_PATH=$(find ~ -type d -maxdepth 5 -name Pico-Scripts 2> /dev/null)
    if [ -x /usr/bin/dircolors ]; then
        alias ls='ls --color=auto'
        alias grep='grep --color=auto'
	if [ -v PICO_SCRIPT_PATH ]; then
		alias kill.sh="distrobox-host-exec $PICO_SCRIPT_PATH/kill.sh"
		alias start.sh="distrobox-host-exec $PICO_SCRIPT_PATH/start.sh"
		alias ping.sh="distrobox-host-exec $PICO_SCRIPT_PATH/ping.sh"
		alias status.sh="distrobox-host-exec $PICO_SCRIPT_PATH/status.sh"
		alias stop_thrusters.sh="distrobox-host-exec $PICO_SCRIPT_PATH/stop_thrusters.sh"
		alias thruster_test.sh="distrobox-host-exec $PICO_SCRIPT_PATH/thruster_test.sh"
		alias all_thrusters.sh="distrobox-host-exec $PICO_SCRIPT_PATH/all_thrusters.sh"
	fi
    fi
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
fi
