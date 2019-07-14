FROM {{ getenv "GEODESIC_IMAGE" "getft/geodesic" }}:{{ getenv "GEODESIC_TAG" "latest" }}

ENV DOCKER_IMAGE "{{ getenv "DOCKER_IMAGE" "org/geodesic.example.org" }}"
ENV DOCKER_TAG "{{ getenv "DOCKER_TAG" "latest" }}"

# Default AWS Profile name
ENV AWS_DEFAULT_PROFILE="{{ getenv "AWS_DEFAULT_PROFILE" "ops" }}"

# AWS Region for the cluster
ENV AWS_REGION="{{ getenv "AWS_REGION" "us-west-2"}}"

# Instance sizes
ENV BASTION_MACHINE_TYPE "{{ getenv "BASTION_MACHINE_TYPE" "t2.medium" }}"

# Terraform
ENV TF_BUCKET ""
ENV TF_BUCKET_REGION "{{ getenv "AWS_REGION" "eu-west-1"}}"
ENV TF_DYNAMODB_TABLE ""

# Place configuration in 'conf/' directory
COPY conf/ /conf/

WORKDIR /conf/

RUN build-kops-manifest
