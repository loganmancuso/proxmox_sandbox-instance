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
import os
import subprocess
import argparse

parser = argparse.ArgumentParser(description='Bootstrap Script for Thoth.')
parser.add_argument('--smb_password', type=str, required=True, help='SMB password to set for the user')
args = parser.parse_args()

logging.basicConfig(format="%(asctime)s [%(levelname)s] %(message)s", level=logging.DEBUG, filename='/var/log/tofu/bootstrap.log', filemode='w')
logging.getLogger().addHandler(logging.StreamHandler())

# Write the start time of the log to the log
logging.info(f'Log started at {datetime.datetime.now()}')

# Write some basic information about the system to the log
logging.info('System information:')
logging.info(f'Hostname: {platform.node()}')
logging.debug(f'CPU usage: {psutil.cpu_percent()}%')
logging.debug(f'Memory usage: {psutil.virtual_memory().percent}%')
logging.info('-------------------')

# TODO: Add other commands here
def install_packages():
  logging.info("START\tinstall_packages")
  try:
    install_cmnd = "sudo apt install -y cockpit zfsutils-linux samba samba-common-bin nfs-kernel-server winbind attr coreutils libc-bin systemd gawk;"
    output = subprocess.check_output(
      install_cmnd, stderr=subprocess.STDOUT, shell=True, timeout=240,
      universal_newlines=True)
  except subprocess.CalledProcessError as exc:
    logging.info("Status : FAIL", exc.returncode, exc.output)
  else:
    logging.info("Output: \n{}\n".format(output))
  logging.info("END\tinstall_packages")

def install_cockpit_plugins():
  logging.info("START\tinstall_cockpit_plugins")
  try:
    install_cmnd = (
      "sudo mkdir --parents /opt/tofu/cockpit/; sudo chown -R root:$USER /opt/tofu/cockpit; sudo chmod -R u+rwx,g+rwx /opt/tofu/cockpit;"
      "sudo wget https://github.com/45Drives/cockpit-file-sharing/releases/download/v3.2.9/cockpit-file-sharing_3.2.9-2focal_all.deb -O /opt/tofu/cockpit/cockpit-file-sharing_3.2.9-2focal_all.deb;"
      "sudo wget https://github.com/45Drives/cockpit-navigator/releases/download/v0.5.10/cockpit-navigator_0.5.10-1focal_all.deb -O /opt/tofu/cockpit/cockpit-navigator_0.5.10-1focal_all.deb;"
      "sudo wget https://github.com/45Drives/cockpit-identities/releases/download/v0.1.12/cockpit-identities_0.1.12-1focal_all.deb -O /opt/tofu/cockpit/cockpit-identities_0.1.12-1focal_all.deb;"
      "sudo dpkg -i /opt/tofu/cockpit/*.deb;"
      "git clone https://github.com/45drives/cockpit-zfs-manager.git /opt/tofu/cockpit/cockpit-zfs-manager;"
      "sudo cp -r /opt/tofu/cockpit/cockpit-zfs-manager/zfs /usr/share/cockpit;"
      "sudo zpool import rust -f;"
    )
    output = subprocess.check_output(
      install_cmnd, stderr=subprocess.STDOUT, shell=True, timeout=240,
      universal_newlines=True)
  except subprocess.CalledProcessError as exc:
    logging.info("Status : FAIL", exc.returncode, exc.output)
  else:
    logging.info("Output: \n{}\n".format(output))
  logging.info("END\tinstall_cockpit_plugins")

def cockpit_fileshare_nfs():
  logging.info("START\tcockpit_fileshare_nfs")
  file_name = "cockpit-file-sharing.exports"
  file_path = "/etc/exports.d"
  content = (
    "\"/rust/nfs-shares/homeassistant\" 192.168.3.3(sec=sys,rw,crossmnt,no_subtree_check,no_root_squash)\n"
    "\"/rust/nfs-shares/octoprint\" 192.168.3.4(sec=sys,rw,crossmnt,no_subtree_check,no_root_squash)\n"
    "\"/rust/nfs-shares/k3s-postgres\" 192.168.3.4(sec=sys,rw,crossmnt,no_subtree_check,no_root_squash)\n"
  )

  try:
    with open(file_name, 'w') as f:
      f.write(content)
    logging.info("Exporting NFS Shares \n" + content)
    install_cmnd = "sudo mkdir --parents " + file_path + "; sudo mv ./" + file_name + " " + file_path + "/" + file_name + " ; sudo chown -R root:$USER " + file_path + "/" + file_name + "; sudo chmod -R u+rwx,g+rx " + file_path + "/" + file_name
    logging.debug(install_cmnd)
    output = subprocess.check_output(
      install_cmnd, stderr=subprocess.STDOUT, shell=True, timeout=5,
      universal_newlines=True)
  except subprocess.CalledProcessError as exc:
    logging.info("Status : FAIL", exc.returncode, exc.output)
  else:
    logging.info("Output: \n{}\n".format(output))
  logging.info("END\tcockpit_fileshare_nfs")

def cockpit_fileshare_smb():
  logging.info("START\tcockpit_fileshare_smb")
  file_name = "smb.conf"
  file_path = "/etc/samba"
  content = """
      [global]
        server string = Thoth SMB Server
        workgroup = THOTH
        log level = 2
        # include = /etc/cockpit/zfs/shares.conf

      [Backups]
        path = /rust/smb-share/backups
        comment = collection of backups
        read only = no
        inherit permissions = yes
        guest ok = no
        force group = instance-user
        valid users = "@instance-user"
        browseable = no

      [Documents]
        path = /rust/smb-share/documents
        comment = personal document storage
        read only = no
        inherit permissions = yes
        guest ok = no
        force group = instance-user
        valid users = "@instance-user"
        browseable = no

      [Source]
        path = /rust/smb-share/source
        comment = git source control files
        read only = no
        inherit permissions = Yes
        guest ok = no
        force group = instance-user
        valid users = "@instance-user"
        browseable = no
  """
  try:
    with open(file_name, 'w') as f:
      f.write(content)
    logging.info("Exporting SMB Shares \n" + content)
    cmnd = "sudo mkdir --parents " + file_path + "; sudo mv ./" + file_name + " " + file_path + "/" + file_name + " ; sudo chown -R root:$USER " + file_path + "/" + file_name + "; sudo chmod -R u+rwx,g+rx " + file_path + "/" + file_name
    logging.debug(cmnd)
    output = subprocess.check_output(
      cmnd, stderr=subprocess.STDOUT, shell=True, timeout=5,
      universal_newlines=True)
    # import smb config
    install_cmnd = "sudo net conf import " + file_path + "/" + file_name
    logging.debug(install_cmnd)
    output = subprocess.check_output(
      install_cmnd, stderr=subprocess.STDOUT, shell=True, timeout=5,
      universal_newlines=True)
    # set user smb password
    # echo -e "your_password\nyour_password" | sudo smbpasswd -s -a username
    smb_cmnd = "echo \"" + args.smb_password + "\\n" + args.smb_password + "\\n\"" + " | sudo smbpasswd -s -a $USER"
    logging.debug(smb_cmnd)
    output = subprocess.check_output(
      smb_cmnd, stderr=subprocess.STDOUT, shell=True, timeout=5,
      universal_newlines=True)
  except subprocess.CalledProcessError as exc:
    logging.info("Status : FAIL", exc.returncode, exc.output)
  else:
    logging.info("Output: \n{}\n".format(output))
  logging.info("END\tcockpit_fileshare_smb")

logging.info("Main")
install_packages()
install_cockpit_plugins()
cockpit_fileshare_nfs()
cockpit_fileshare_smb()

# Write the end time of the log to the log
logging.info(f'Log ended at {datetime.datetime.now()}')

# Close the log
logging.shutdown()