# Choose your desired base image
FROM jupyter/scipy-notebook:latest

# Create a Python 2.x environment using conda including at least the ipython kernel
# and the kernda utility. Add any additional packages you want available for use
# in a Python 2 notebook to the first line here (e.g., pandas, matplotlib, etc.)
RUN conda create --quiet --yes -p $CONDA_DIR/envs/python2 python=2.7 ipython ipykernel kernda numpy scipy matplotlib \
 h5py numexpr statsmodels astropy ephem mpi4py line_profiler && \
    conda clean -tipsy

USER root

# Create a global kernelspec in the image and modify it so that it properly activates
# the python2 conda environment.
RUN $CONDA_DIR/envs/python2/bin/python -m ipykernel install && \
$CONDA_DIR/envs/python2/bin/kernda -o -y /usr/local/share/jupyter/kernels/python2/kernel.json

RUN conda install -y h5py numexpr statsmodels astropy ephem mpi4py line_profiler gfortran_linux-64

RUN apt update && apt install -y tightvncserver websockify supervisor xinit xterm xfce4 xfce4-terminal cmake build-essential gfortran pgplot5 tcsh \
    dh-autoreconf pgplot5 libfftw3-dev libcfitsio-dev latex2html \ 
    pkg-config libglib2.0-dev curl imagemagick less dvipng openmpi-common openmpi-bin libgsl-dev vim-gtk3
RUN apt clean
RUN pip install git+https://github.com/ryanlovett/nbnovnc
RUN pip install tornado==5.1.1
RUN pip install git+https://github.com/novnc/websockify
RUN jupyter serverextension enable  --py --sys-prefix nbnovnc
RUN jupyter nbextension     install --py --sys-prefix nbnovnc
RUN jupyter nbextension     enable  --py --sys-prefix nbnovnc
RUN git clone https://github.com/novnc/noVNC /usr/share/novnc
COPY xinitrc /home/jovyan/.xinitrc
COPY jupyter_notebook_config.py /home/jovyan/.jupyter/jupyter_notebook_config.py
# make calceph
RUN wget -q https://www.imcce.fr/content/medias/recherche/equipes/asd/calceph/calceph-2.3.2.tar.gz && \
    tar zxvf calceph-2.3.2.tar.gz && \
    cd calceph-2.3.2 && \
    ./configure --prefix=/usr/local && \
    make && make install && \
    cd .. && rm -rf calceph-2.3.2 calceph-2.3.2.tar.gz

RUN mkdir -p /opt/pulsar && \
    chown jovyan /opt/pulsar

WORKDIR /opt/pulsar

ENV LD_LIBRARY_PATH="/usr/local/lib"

# tempo 
ENV TEMPO=/opt/pulsar/tempo 
ENV PATH=$PATH:/opt/pulsar/tempo/bin

RUN git clone http://git.code.sf.net/p/tempo/tempo

WORKDIR $TEMPO
RUN chmod +x prepare 
RUN head /opt/pulsar/tempo/prepare
RUN /opt/pulsar/tempo/prepare && \
    LDFLAGS="-L/opt/pulsar/miniconda/lib" \
    CPPFLAGS="-I/opt/pulsar/miniconda/include" \
    ./configure --prefix=/opt/pulsar/tempo --with-blas=mkl_rt --with-lapack=mkl_rt&& \
    make && \
    make install && \
    cd util/print_resid && \
    make

# make tempo2
WORKDIR /opt/pulsar/src
ENV TEMPO2 /opt/pulsar/share/tempo2
RUN git clone https://bitbucket.org/psrsoft/tempo2 && \
    cd tempo2 && \
    ./bootstrap && \
    ./configure --prefix=/opt/pulsar --with-calceph=/usr/local && \
    make && make install && make plugins && make plugins-install && \
    mkdir -p /opt/pulsar/share/tempo2 && \
    cp -Rp T2runtime/* /opt/pulsar/share/tempo2/. && \
    cd .. && rm -rf tempo2

ENV TEMPO2=/opt/pulsar/share/tempo2
RUN rm -rf tempo2


COPY MultiNest_v3.11.tar.gz ./
RUN tar xvfz MultiNest_v3.11.tar.gz
COPY Makefile MultiNest_v3.11/Makefile
COPY Makefile.polychord /var/tmp/Makefile
RUN cd MultiNest_v3.11 && make && make libnest3.so && cp libnest3* /usr/lib

RUN bash -c "source activate python2 && git clone https://github.com/LindleyLentati/TempoNest.git && \
              cd TempoNest && ./autogen.sh && CPPFLAGS=\"-I/opt/pulsar/include\" \
                LDFLAGS=\"-L/opt/pulsar/lib\" ./configure --prefix=/opt/pulsar && cd PolyChord && \
                cp /var/tmp/Makefile Makefile && make \
                 && make libchord.so && cp src/libchord* /usr/lib && cd ../ && make && make install"

# get extra ephemeris
RUN cd /opt/pulsar/share/tempo2/ephemeris && \
    wget -q https://data.nanograv.org/static/data/ephem/de435t.bsp && \
    wget -q https://data.nanograv.org/static/data/ephem/de436t.bsp 

RUN wget -q http://faculty.cse.tamu.edu/davis/SuiteSparse/SuiteSparse-5.1.0.tar.gz && \
    tar -xzf SuiteSparse-5.1.0.tar.gz && \
    cd SuiteSparse && \
    make install INSTALL=/usr/local \
      BLAS="-L/opt/conda/lib -lopenblas" \
      LAPACK="-L/opt/conda/lib -lopenblas" && \
    cd .. && rm -rf SuiteSparse/ SuiteSparse-5.1.0.tar.gz


RUN pip install healpy jplephem corner 
RUN /bin/bash -c "source activate python2 && pip install healpy jplephem corner" 
RUN pip install --install-option='--with-tempo2=/opt/pulsar' git+https://github.com/vallis/libstempo 
RUN /bin/bash -c "source activate python2 && conda install cython && pip install --install-option='--with-tempo2=/opt/pulsar' git+https://github.com/vallis/libstempo "

RUN pip install --global-option=build_ext --global-option="-L/usr/local/lib" scikit-sparse 
RUN /bin/bash -c "source activate python2 && pip install --global-option=build_ext --global-option="-L/usr/local/lib" scikit-sparse"

RUN pip install git+https://github.com/dfm/acor.git@master
RUN /bin/bash -c "source activate python2 && pip install git+https://github.com/dfm/acor.git@master"

RUN pip install git+https://github.com/jellis18/PTMCMCSampler@master
RUN /bin/bash -c "source activate python2 && pip install git+https://github.com/jellis18/PTMCMCSampler@master"

RUN pip install git+https://github.com/mtlam/PyPulse.git
RUN /bin/bash -c "source activate python2 && pip install git+https://github.com/mtlam/PyPulse.git"

RUN pip install git+https://github.com/nanograv/PINT.git
RUN /bin/bash -c "source activate python2 && pip install git+https://github.com/nanograv/PINT.git"

RUN pip install git+https://github.com/nanograv/enterprise
RUN /bin/bash -c "source activate python2 && pip install git+https://github.com/nanograv/enterprise"


RUN pip install git+https://github.com/stevertaylor/enterprise_extensions
RUN /bin/bash -c "source activate python2 && pip install git+https://github.com/stevertaylor/enterprise_extensions"


ENV PGPLOT_DIR=/usr/lib/pgplot5 
ENV PGPLOT_FONT=/usr/lib/pgplot5/grfont.dat 
ENV PGPLOT_INCLUDES=/usr/include 
ENV PGPLOT_BACKGROUND=white 
ENV PGPLOT_FOREGROUND=black 
ENV PGPLOT_DEV=/xs

ENV PSRHOME=/opt/pulsar

ENV PRESTO=$PSRHOME/presto 
ENV PATH=$PATH:$PRESTO/bin 
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PRESTO/lib 
ENV PYTHONPATH=$PYTHONPATH:$PRESTO/lib/python

WORKDIR /opt/pulsar
RUN git clone https://github.com/scottransom/presto.git

WORKDIR $PRESTO/src
RUN make prep && \
    make && make makewisdom
WORKDIR $PRESTO/python
RUN /bin/bash -c "source activate python2 && make" 

WORKDIR /opt/pulsar/src
ENV PATH=$PATH:$PSRHOME/bin 

RUN git clone git://git.code.sf.net/p/psrchive/code psrchive
WORKDIR /opt/pulsar/src/psrchive 
RUN conda install swig && /bin/bash -c "source activate python2 && conda install swig"
RUN /bin/bash -c 'source activate python2; \
    ./bootstrap; \
    ./configure F77=gfortran --prefix=$PSRHOME --enable-shared CFLAGS="-fPIC" FFLAGS="-fPIC";\
    ./packages/epsic.csh;\
    ./configure F77=gfortran --prefix=$PSRHOME --enable-shared CFLAGS="-fPIC" FFLAGS="-fPIC";\
    make && make install && make clean;'

RUN chown -R jovyan /home/jovyan
RUN apt clean
RUN conda clean -a
WORKDIR /home/jovyan
USER $NB_USER
