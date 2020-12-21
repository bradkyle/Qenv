#! /bin/bash

syncfn() {
    path="${1}${3}";
    mkdir -p ${path} 
    echo ${path};
    echo ${2}
    gsutil -m rsync -r -d "${2}" ${path}
} 

# cat ${1} | gsutil -m cp -R -I ${2}
# for i in cat ${1} ; do IFS=","; set $i; echo $1 $2; done
while IFS=, read -r field1 field2
do
    if [ $(jobs -r | wc -l) -ge 3 ]; then
        wait $(jobs -r -p | head -1)
    fi

    syncfn ${2} ${field1} ${field2} &
done < ${1}

wait
echo "All files are downloaded."

q ingest.q