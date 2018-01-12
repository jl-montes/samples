#!/bin/bash
apps=(
	'mon-dynamicfw'
	'mon-fr-monitor'
	'mon-pipework'
	'mon-poller'
	'mon-quagga'
	)

output="frontend_versions"
echo "versions:" > $output
for name in "${apps[@]}"
do
	tag=$(curl mon-version-police.marathon.mesos:20300/v1/version/$name)
	echo "  $name: $tag" >> $output
done


