#!/bin/bash
source /opt/ros/jazzy/setup.bash
source /uros_ws/install/setup.bash

# avoid double-launching if it's already running
if ! pgrep -f "micro_ros_agent micro_ros_agent" > /dev/null; then
    # matches the /dev/ttyUSB0 device you're already passing through
    ros2 run micro_ros_agent micro_ros_agent serial --dev /dev/ttyUSB0 -D -R \
        > /tmp/microros-agent.log 2>&1 &
fi