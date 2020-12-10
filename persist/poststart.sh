while getopts k:b:m: flag
do
    case "${flag}" in
        k) keyfile=${OPTARG};;
        b) bucket=${OPTARG};;
        m) mount=${OPTARG};;
    esac
done

gcloud auth activate-service-account --key-file $keyfile
gcsfuse --implicit-dirs -o nonempty $bucket $mount
