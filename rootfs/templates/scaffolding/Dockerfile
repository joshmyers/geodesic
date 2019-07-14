FROM {{ getenv "GEODESIC_IMAGE" "getft/geodesic" }}:{{ getenv "GEODESIC_TAG" "latest" }}

ENV DOCKER_IMAGE "{{ getenv "DOCKER_IMAGE" "org/geodesic.example.org" }}"
ENV DOCKER_TAG "{{ getenv "DOCKER_TAG" "latest" }}"

# AWS Region for the cluster
ENV AWS_REGION="{{ getenv "AWS_REGION" "eu-west-1"}}"
ENV REGION="${AWS_REGION}"
ENV AWS_ACCOUNT_ID=""
ENV AWS_ROOT_ACCOUNT_ID=""

# Place configuration in 'conf/' directory
COPY conf/ /conf/

WORKDIR /conf/
