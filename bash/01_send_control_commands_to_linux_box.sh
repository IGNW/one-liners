#!/bin/bash

printf 'show bgp \x09\x09\x15' | bash -i 2>&1

# This was used to send commands via ansible to type `show bgp` then the tab key twice, 
# followed by ctrl-u to clear the command line input  before ansible hits the enter key