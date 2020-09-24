docker run -it -v /home/thorad/Core/Projects/Qenv:/home/kx/qenv --expose 8080 -p 8080:8080 gcr.io/practice-275123/kdbml:v1.6
docker run -i -t -p 8888:8888 continuumio/anaconda3 /bin/bash -c "/opt/conda/bin/conda install jupyter -y --quiet && mkdir /opt/notebooks && /opt/conda/bin/jupyter notebook --notebook-dir=/opt/notebooks --ip='*' --port=8888 --no-browser"
