#!/bin/bash

set -e

function print_help {
  # Print the help message
  echo 'Usage $0 [OPTIONS]'
  echo ''
  echo 'Runs a workload'
  echo ''
  echo 'Options:'
  echo '   --help      shows this help message'
  echo '   --debug     shows this commands executed'
}

function setup_kubeburner {
  mkdir -p ../bin/
  mkdir -p ./tmp
  (cd tmp
    wget https://github.com/cloud-bulldozer/kube-burner/releases/download/v1.2/kube-burner-1.2-Linux-x86_64.tar.gz
    tar -zxvf kube-burner-1.2-Linux-x86_64.tar.gz
    cp kube-burner ../../bin/
  )
  rm -rf ./tmp
}

function run_workload {
  mkdir -p ~/.kube/
  sudo microk8s config > ~/.kube/config
  (cd ../workloads/api-intensive
    while true ; do
      ../../bin/kube-burner init -c api-intensive.yml
    done
  )
}

PARSED=$(getopt --options=dh --longoptions=debug,help -- "$@")
eval set -- "$PARSED"
while true; do
    case "$1" in
        -h|--help)
            print_help
            exit 0
            ;;
        -d|--debug)
            set -x
            ;;
        --)
            break
            ;;
        *)
            echo "invalid option -- $1"
            exit 1
    esac
    shift
done


echo "Setting up kube-burner"
setup_kubeburner

echo "Running workload"
run_workload
