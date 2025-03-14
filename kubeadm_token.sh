#!/bin/env bash

set -e

if [ "cat /etc/hostname" = "node1" ]
  then
    sudo kubeadm token create --print-join-command
fi

<<-EOT
    set -e
    if [ "cat /etc/hostname" = "node1" ]
      then
        sudo kubeadm token create --print-join-command
    fi
EOT