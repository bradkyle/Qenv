cat ${1} | gsutil -m rsync -R -I ${2}
