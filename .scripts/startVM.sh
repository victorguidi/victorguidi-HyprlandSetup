#!/bin/sh

pkexec virsh start kali

virt-manager -c "qemu:///system" --show-domain-console kali
