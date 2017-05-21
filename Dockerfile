FROM centos:latest

USER root

ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV PYTHONIOENCODING UTF-8

ENV CONDA_DIR /opt/conda

ENV NB_USER=nbuser
ENV NB_UID=1011
ENV NB_PYTHON_VER=3.5

RUN yum -y install epel-release

RUN yum install -y curl wget java-headless bzip2 gnupg2 sqlite3 nss_wrapper \
    && cd /tmp \
    && wget -q https://repo.continuum.io/miniconda/Miniconda3-4.2.12-Linux-x86_64.sh \
    && echo d0c7c71cc5659e54ab51f2005a8d96f3 Miniconda3-4.2.12-Linux-x86_64.sh | md5sum -c - \
    && bash Miniconda3-4.2.12-Linux-x86_64.sh -b -p $CONDA_DIR \
    && rm Miniconda3-4.2.12-Linux-x86_64.sh \
    && export PATH=/opt/conda/bin:$PATH \
    && yum install -y gcc gcc-c++ glibc-devel \
    && /opt/conda/bin/conda install --quiet --yes python=$NB_PYTHON_VER 'nomkl' \
			    'ipywidgets=5.2*' \
			    'matplotlib=1.5*' \
			    'scipy=0.17*' \
			    'seaborn=0.7*' \
			    'cloudpickle=0.1*' \
			    statsmodels \
			    pandas \
			    'dill=0.2*' \
			    notebook \
			    jupyter \
    && pip install widgetsnbextension \
    && yum erase -y gcc gcc-c++ glibc-devel \
    && yum clean all -y \
    && rm -rf /root/.npm \
    && rm -rf /root/.cache \
    && rm -rf /root/.config \
    && rm -rf /root/.local \
    && rm -rf /root/tmp \
    && useradd -m -s /bin/bash -N -u $NB_UID $NB_USER \
    && usermod -g root $NB_USER \
    && chown -R $NB_USER $CONDA_DIR \
    && conda remove --quiet --yes --force qt pyqt \
    && conda remove --quiet --yes --force --feature mkl ; conda clean -tipsy

ENV PATH /opt/conda/bin:$PATH

# Add a notebook profile.

RUN mkdir /notebooks && chown $NB_UID:root /notebooks && chmod 1777 /notebooks

EXPOSE 8888

RUN mkdir -p -m 700 /home/$NB_USER/.jupyter/ && \
    echo "c.NotebookApp.ip = '*'" >> /home/$NB_USER/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.open_browser = False" >> /home/$NB_USER/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.notebook_dir = '/notebooks'" >> /home/$NB_USER/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.password = ''" >> /home/$NB_USER/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.password_required = False" >> /home/$NB_USER/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.token = ''" >> /home/$NB_USER/.jupyter/jupyter_notebook_config.py && \    
    chown -R $NB_UID:root /home/$NB_USER && \
    chmod g+rwX,o+rX -R /home/$NB_USER

LABEL io.k8s.description="Jupyter-Scala Notebook." \
      io.k8s.display-name="Jupyter-Scala Notebook." \
      io.openshift.expose-services="8888:http"

ENV TINI_VERSION v0.9.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.asc /tini.asc
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 0527A9B7 && gpg --verify /tini.asc
ADD start.sh /start.sh

COPY entrypoint /

RUN chmod +x /tini /start.sh /entrypoint

ENV HOME /home/$NB_USER
USER $NB_UID
WORKDIR /notebooks

ENV JUPYTER_SCALA_VERSION=0.4.2

RUN \
    cd $HOME && \
    wget -q https://github.com/alexarchambault/jupyter-scala/archive/v${JUPYTER_SCALA_VERSION}.tar.gz && \
    tar xzf v${JUPYTER_SCALA_VERSION}.tar.gz && \
    mv jupyter-scala-${JUPYTER_SCALA_VERSION} jupyter-scala && \
    rm v${JUPYTER_SCALA_VERSION}.tar.gz && \
    cd jupyter-scala && ./jupyter-scala && \
    cd $HOME && rm -rf jupyter-scala

RUN chmod a+rwx $HOME && chmod -R a+rwx $HOME/.local $HOME/.coursier

ENTRYPOINT ["/tini", "--"]

CMD ["/entrypoint", "/start.sh"]
