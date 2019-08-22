#!/bin/bash
# sleep until instance is ready
until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 1
done
sudo cp /home/ubuntu/workspace/navvis-demo-daemon.service /etc/systemd/system/navvis-demo-daemon.service
sudo apt-get -y update 
sudo apt-get install -y default-jdk
sudo chmod +x /home/ubuntu/workspace/demo-0.0.1-SNAPSHOT.jar
sudo chmod +x /home/ubuntu/workspace/navvis-demo-script
sudo systemctl daemon-reload
sudo systemctl enable navvis-demo-daemon.service
sudo systemctl start navvis-demo-daemon
sudo systemctl status navvis-demo-daemon --no-pager
