##############################################################################
#
# Author: Logan Mancuso
# Created: 07.30.2023
#
##############################################################################

variable "instance" {
  description = "instance parameters"
  type = object({
    ip = string
    id = number
  })
  default = {
    ip = "192.168.10.245/24"
    id = 10245
  }
}