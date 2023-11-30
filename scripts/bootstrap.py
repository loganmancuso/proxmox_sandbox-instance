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

logging.basicConfig(format="%(asctime)s [%(levelname)s] %(message)s", level=logging.INFO, filename='/var/log/tofu/bootstrap.log', filemode='w')

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