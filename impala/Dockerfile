FROM gcr.io/deeplearning-platform-release/pytorch-gpu as base

# Install system packages.
RUN apt-get update
RUN apt-get install -y curl
# ...

# Install gcsfuse.
RUN echo "deb http://packages.cloud.google.com/apt gcsfuse-bionic main" | tee /etc/apt/sources.list.d/gcsfuse.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN apt-get update
RUN apt-get install -y gcsfuse

# Install gcloud.
RUN apt-get install -y apt-transport-https
RUN apt-get install -y ca-certificates
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
RUN apt-get update
RUN apt-get install -y google-cloud-sdk

RUN pip install --upgrade gym gym[atari] atari_py paddlepaddle parl qpython

FROM base as run
RUN mkdir -p /home/impala
WORKDIR /home/impala
ADD . /home/impala 
RUN chmod +x /home/impala/entrypoint.sh
CMD ["/bin/bash"]

