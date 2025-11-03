Files put in this directory are copied into the docker context when building the docker image.
If there are a lot of files here, `docker build` will be slow. Files that are put here, should
be files that are needed to aid the building of the docker images.