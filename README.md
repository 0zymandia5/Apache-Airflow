# Podman-Airflow-Celery

**Key Features:**

* Celery
* Python 3.8
* Apache airflow 2.9.0
* Ubi8 container base image (RHEL 8)

## Requirements

* [Podman](https://podman.io/docs/installation)
* [Podman-Compose](https://github.com/containers/podman-compose)

## Build Steps

```
podman build -t tag_name:version .
```

## Execution Steps

Create the db containers first:

```
podman-compose -f podman-compose-CeleryExecutor.yml up redis postgres
```

Create the Apache Airflow containers:

```
podman-compose -f podman-compose-CeleryExecutor.yml up webserver flower scheduler worker
```

Kill the Apache Airflow containers

```
podman-compose -f podman-compose-CeleryExecutor.yml kill webserver flower scheduler worker
```
