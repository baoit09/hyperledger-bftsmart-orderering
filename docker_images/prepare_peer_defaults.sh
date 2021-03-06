#!/bin/bash

function main () {

	docker pull hyperledger/fabric-peer:x86_64-1.1.1

	docker create --name="peer-temp" "hyperledger/fabric-peer:x86_64-1.1.1" > /dev/null
	id=$(docker ps -aqf "name=peer-temp")

	if [ ! -d ./peer_material ]; then
	    mkdir ./peer_material
	fi

	if [ ! -d ./peer_material/fabric ]; then

		docker cp $id:/etc/hyperledger/fabric/ ./peer_material/

		if [ -f ./peer_material/fabric/configtx.yaml ]; then

			rm ./peer_material/fabric/configtx.yaml

		fi

		if [ -f ./peer_material/fabric/orderer.yaml ]; then

			rm ./peer_material/fabric/orderer.yaml

		fi
	fi

	docker rm -v $id > /dev/null

	echo ""
	echo "Default configuration available at '$PWD/peer_material/'"
	echo "Generate containers with 'create_peer_container.sh <container name>'"
	echo ""
}

parse_yaml() {

   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')

   #echo "------ $fs"

   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" $1 | sed 's/\$/\\\$/g' |
   awk -F$fs '{
      indent = length($1)/4;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

main $@
