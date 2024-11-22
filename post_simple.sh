#!/bin/bash

systemctl start NetworkManager.service
systemctl enable NetworkManager.service

sed -i '/%wheel ALL=(ALL:ALL) ALL/s/^#//' /etc/sudoers