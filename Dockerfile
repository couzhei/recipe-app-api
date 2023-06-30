FROM python:3.9-alpine3.13
LABEL maintainer="couzhei"

ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    rm -rf /tmp && \
    adduser \
    --disabled-password \
    --no-create-home \
    django-user
# we could use RUN for each of these commands but that would not be
# an efficient Dockerfile, we want to make it lightweight so avoiding
# creating additional image layers (what?) so it's single RUN compiled
# on alpine image when we're building our image

# many believe it's not very useful to create an venv in the first
# line of the RUN command, but in any case upgrade the pip
# and finally install the requirements

# note that we then removed /tmp, because we don't want any extra
# dependencies once it's being created. It's best practice to
# keep Docker images as lightweight as possible so if there's no
# needed file that you don't need on the actual image
# please remember to delete it afterward so it saves space and therefore
# speed

# next we created a user inside our image (remember any docker image
# is a tiny linux machine) which is considered best practice not to
# use the root user, since if we didn't specify this the the only
# user available inside the alpine image would be the root user

# The lightweight nature of Docker images is due to their layered 
# file system architecture. Docker images use a copy-on-write  
# approach, where each layer represents a change or addition to
# the previous layer. When you start a container based on a Docker 
# image, it uses only the layers that are necessary for the 
# application, making the image efficient in terms of disk space
# and download times. 

ENV PATH="/py/bin:$PATH"

# this is will make python executable

USER django-user
# until this line everything was running as the root user
# but now it switches to the new user django-user