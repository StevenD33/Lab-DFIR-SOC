#!/bin/bash

#< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-64};echo;
openssl rand -base64 1000 | tr -cd "[:alnum:]" | tr -d "lo" | cut -c 1-64
