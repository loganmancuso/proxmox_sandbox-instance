#!/usr/bin/python3
##############################################################################
#
# Author: Logan Mancuso
# Created: 11.10.2023
#
##############################################################################
import logging
import platform
import psutil
import datetime
import subprocess

log_path_ = "/var/log/terraform/bootstrap.log"

logging.basicConfig(format="%(asctime)s [%(levelname)s] %(message)s", level=logging.INFO)

# Write the start time of the log to the log
logging.info(f'Log started at {datetime.datetime.now()}')

# Write some basic information about the system to the log
logging.info('System information:')
logging.info('-------------------')
logging.info(f'Hostname: {platform.node()}')
logging.info(f'CPU usage: {psutil.cpu_percent()}%')
logging.info(f'Memory usage: {psutil.virtual_memory().percent}%')

# TODO: Add other commands here


# Write the end time of the log to the log
logging.info(f'Log ended at {datetime.datetime.now()}')

# Close the log
logging.shutdown()




# Startup and intial check for cloud init finish. 

  # - [ sh, -c, "echo $(date) ': ==== START 45 Drive Download ===='" ]
  # - [ sh, -c, wget https://github.com/45Drives/cockpit-file-sharing/releases/download/v3.2.9/cockpit-file-sharing_3.2.9-2focal_all.deb -O /opt/cockpit-file-sharing_3.2.9-2focal_all.deb ]
  # - [ sh, -c, wget https://github.com/45Drives/cockpit-navigator/releases/download/v0.5.10/cockpit-navigator_0.5.10-1focal_all.deb -O /opt/cockpit-navigator_0.5.10-1focal_all.deb ]
  # - [ sh, -c, wget https://github.com/45Drives/cockpit-identities/releases/download/v0.1.12/cockpit-identities_0.1.12-1focal_all.deb -O /opt/cockpit-identities_0.1.12-1focal_all.deb ]
  # - [ sh, -c, dpkg -i /opt/*.deb ]
  # - [ sh, -c, "echo $(date) ': ==== END 45 Drive Download ===='" ]
  # - [ sh, -c, "echo $(date) ': ==== START ZFS Pool Import ===='" ]
  # - [ sh, -c, git clone https://github.com/45drives/cockpit-zfs-manager.git /opt/cockpit-zfs-manager ]
  # - [ sh, -c, cp -r /opt/cockpit-zfs-manager/zfs /usr/share/cockpit ]
  # - [ sh, -c, zpool import rust -f ]
  # - [ sh, -c, "echo $(date) ': ==== END ZFS Pool Import ===='" ]
  # - [ sh, -c, "echo $(date) ': Post Install Steps'" ]
  # - [ sh, -c, net conf import /etc/samba/smb.conf ]