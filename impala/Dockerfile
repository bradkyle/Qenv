FROM gcr.io/deeplearning-platform-release/pytorch-gpu as base
RUN pip install --upgrade gym gym[atari] atari_py paddlepaddle parl qpython
RUN mkdir -p /home/impala
WORKDIR /home/impala
ADD . /home/impala 
RUN chmod +x /home/impala/entrypoint.sh
RUN ls
RUN ls /home/impala
CMD ["/bin/bash"]

