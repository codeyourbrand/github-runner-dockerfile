# github-runner-dockerfile
## Fork reason
This repo is dedicated to support github-runners for organizations and supports other platform builds (e.g. arm64). It includes also docker CLI and AWS CLI. To use host docker daemon change **DOCKER_GROUP_ID** arg in dockerfile to match with host docker group id.

## Description
Dockerfile for the creation of a GitHub Actions runner image to be deployed dynamically. [Find the full explanation and tutorial here](https://baccini-al.medium.com/creating-a-dockerfile-for-dynamically-creating-github-actions-self-hosted-runners-5994cc08b9fb).

Credit to [testdriven.io](https://testdriven.io/blog/github-actions-docker/) for the original start.sh script, which I slightly modified to make it work with a regular repository rather than with an enterprise. 

## Build
```shell
docker buildx create --name multi --driver=docker-container 
```
```shell
docker buildx build --load --builder=multi --platform=linux/arm64 -t github-runner .
```
## Run
replace
- **[YOUR-ORG]** with your org name
- **[TOKEN]** with Personal Access Token with `repo`, `workflow`, and `admin:org` scopes.
```shell
docker run -e "ORG=[YOUR-ORG]" -e "TOKEN=[TOKEN]" github-runner
```
