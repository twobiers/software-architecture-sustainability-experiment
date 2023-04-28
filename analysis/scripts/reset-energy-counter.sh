#!/usr/bin/env bash

# This script resets the resettable energy counter of PDU

snmpset -v1 -c private 192.168.178.78 1.3.6.1.4.1.28507.43.1.5.1.2.1.13.1 u 0
