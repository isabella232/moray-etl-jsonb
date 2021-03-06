#!/bin/bash

if [ $# != 5 ]
then
        echo "Usage:"
	echo " "
	echo "`basename $0` [regexp] [yyyy/mm/dd/mm] [json manifest] [split file prefix] [disk in GB]"
	echo " "
	echo "e.g:	`basename $0` \"^wf_jobs-\" \"2014/08/01/00\" wf_keys.json wf_jobs 64"
	echo "   	`basename $0` \"^cnapi_servers-\" \"2014/08/01/00\" cnapi_keys.json cnapi_servers 8"
	echo "   	`basename $0` \"^vmapi_vms-\" \"2014/08/01/00\" vmapi_keys.json vmapi_vms 16"
        echo "          `basename $0` \"^ufds_o_smartdc-\" \"2014/08/01/00\" ufds_keys.json ufds_o_sdc 8"
        echo "          `basename $0` \"^sdc_packages-\" \"2014/08/01/00\" papi_keys.json sdc_packages 8"
        echo "          `basename $0` \"^imgapi_images-\" \"2014/08/01/00\" imgapi_keys.json imgapi_images 8"
	echo " " 
        exit 1
fi

REGEXP=$1
DATEPATH=$2
MANIFEST=$3
OUTPUTPREFIX=$4
DISK=$5

MPATH="/${MANTA_USER}/stor/etl/${DATEPATH}/${OUTPUTPREFIX}"

#################################################
#### Process the split files with moraydump_reorg

ASSETS="/assets/$MANTA_USER/stor"

mmkdir -p ${MPATH}/_m
mmkdir -p ${MPATH}/_r
mmkdir -p ${MPATH}/_s


mfind ${MPATH}/split/ | \
mjob create --disk ${DISK} --memory 4096 \
-s /$MANTA_USER/stor/moray-etl-jsonb.tgz \
--init "cd /var/tmp && tar -xzf ${ASSETS}/moray-etl-jsonb.tgz" \
-w -m "/var/tmp/moray-etl-jsonb/lib/moraydump_reorg.js -t /var/tmp/moray-etl-jsonb/lib/${MANIFEST} -o \$(basename \${MANTA_INPUT_FILE}) -f \$(basename \${MANTA_INPUT_FILE}) -p /var/tmp/ && \
mput -f /var/tmp/\$(basename \${MANTA_INPUT_FILE})_s.json ${MPATH}/_s/\$(basename \${MANTA_INPUT_FILE})_s.json && \
mput -f /var/tmp/\$(basename \${MANTA_INPUT_FILE})_r.json ${MPATH}/_r/\$(basename \${MANTA_INPUT_FILE})_r.json && \
mput -f /var/tmp/\$(basename \${MANTA_INPUT_FILE})_m.json ${MPATH}/_m/\$(basename \${MANTA_INPUT_FILE})_m.json"

