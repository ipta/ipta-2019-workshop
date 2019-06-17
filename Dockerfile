FROM ipta/ipta-2019:17062019

COPY . ${HOME}
USER root
RUN chown -R jovyan ${HOME}
USER jovyan
