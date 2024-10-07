#!/bin/bash

NC='\033[0m' # No Color
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'

function info() {
    echo -e ">>\t${CYAN}[INFO]${NC} $(date +"%Y-%m-%dT%H:%M:%S.%3NZ"): $*"
}

function warn() {
    echo -e ">>\t[${ORANGE}WARN${NC}] $(date +"%Y-%m-%dT%H:%M:%S.%3NZ"): $*"
}

function error() {
    echo -e ">>\t[${RED}ERROR${NC}] $(date +"%Y-%m-%dT%H:%M:%S.%3NZ"): $*"
}

function success() {
    echo -e ">>\t${GREEN}SUCCESS${NC} $(date +"%Y-%m-%dT%H:%M:%S.%3NZ"): $*"
}

function fail() {
    echo -e ">>\t${RED}FAIL${NC} $(date +"%Y-%m-%dT%H:%M:%S.%3NZ"): $*" && exit 1
}