# VERSION 1.0.0
# AUTHOR: puckel from https://github.com/puckel/docker-airflow
# DESCRIPTION: ubi8, Python3.8, Apache Airflow 2.9.0
# DOCKER_HUB_REPOSITORY: eveanwarl0ck/airflow_2.9.0_ubi8
# SOURCE: 

FROM docker.io/redhat/ubi8:latest
LABEL maintainer="0zymandia5"
# Python
ARG PYTHON_VERSION=3.8.8
ARG PIP_VERSION=3.8
ARG PYTHON_DEPS=""
# Airflow
ARG AIRFLOW_VERSION=2.9.0
ARG AIRFLOW_USER_HOME=/usr/local/airflow
ARG AIRFLOW_DEPS=""
#User 'airflow' creation
RUN useradd -ms /bin/bash -d ${AIRFLOW_USER_HOME} airflow 

RUN dnf update -y && dnf upgrade -y && dnf install \
    make \
    systemd-libs \
    systemd-udev \
    systemd-pam \
    gcc \
    gcc-c++ \
    openssl-devel \
    bzip2-devel \
    nano \
    nc \
    wget \
    sudo \
    git \
    libffi-devel \
    mariadb-connector-c-devel \
    cyrus-sasl-devel \
    cyrus-sasl-lib \
    sqlite-devel \
    xz-devel \
    sqlite-libs -y

RUN wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && tar xzf Python-${PYTHON_VERSION}.tgz && cd Python-${PYTHON_VERSION} && ./configure --enable-optimizations --enable-loadable-sqlite-extensions && \
    make -j 8 && \
    make altinstall

# Python Cleanup
RUN rm -rf Python-${PYTHON_VERSION}.tgz Python-${PYTHON_VERSION}

RUN pip${PIP_VERSION} install --upgrade pip

# Airflow and its dependencies installation
RUN pip${PIP_VERSION} install 'apache-airflow=='${AIRFLOW_VERSION} \
    && pip${PIP_VERSION} install 'apache-airflow[crypto,celery,postgres,hive,jdbc,mysql]' \ 
    && pip${PIP_VERSION} install 'redis==3.5.3' \
    && pip${PIP_VERSION} install 'importlib-metadata==4.13.0' \
    && pip${PIP_VERSION} install "celery[redis]"  \
    && pip${PIP_VERSION} install "Flask-Session==0.5.0" \
    && pip${PIP_VERSION} install "apache-airflow-providers-celery>=3.3.0"

RUN echo "airflow ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

COPY script/entrypoint.sh /entrypoint.sh
RUN chmod +x entrypoint.sh
COPY config/airflow.cfg ${AIRFLOW_USER_HOME}/airflow.cfg
RUN mkdir ${AIRFLOW_USER_HOME}/dags
COPY /dags/tuto.py ${AIRFLOW_USER_HOME}/dags/

RUN chown -R airflow: ${AIRFLOW_USER_HOME}
RUN chown airflow ${AIRFLOW_USER_HOME}
RUN chmod 755 -R ${AIRFLOW_USER_HOME}
RUN chmod 755 ${AIRFLOW_USER_HOME}

EXPOSE 8080 5555 8793

USER airflow
WORKDIR ${AIRFLOW_USER_HOME}
ENTRYPOINT ["/entrypoint.sh"]
