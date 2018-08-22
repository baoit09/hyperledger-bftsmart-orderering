#!/bin/bash

usage() { echo "Usage: $0 [-n <replicaNumber>]" 1>&2; exit 1; }
while getopts ":n:" o; do
    case "${o}" in
        n)
            n=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

shift $((OPTIND-1))
if [ -z "${n}" ] ; then
    usage
fi

mkdir -p data
mkdir -p data/logs
if [ -f ./config/currentView ] ; then
rm ./config/currentView
fi
$GOPATH/src/github.com/hyperledger/hyperledger-bftsmart-orderering/startReplica.sh ${n} > ./data/logs/replica-${n}.out 2>&1 &
