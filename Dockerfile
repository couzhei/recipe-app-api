# Use the official Python 3.9 image based on Alpine Linux 3.13 as the base image.
FROM python:3.9-alpine3.13

# Add a maintainer label to the Docker image.
LABEL maintainer="couzhei"

# Set an environment variable to enable unbuffered Python output.
ENV PYTHONUNBUFFERED 1

# Copy the 'requirements.txt' and 'requirements.dev.txt' files from the local context to the '/tmp' directory inside the image.
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt

# Copy the contents of the 'app' directory from the local context to the '/app' directory inside the image.
COPY ./app /app

# Set the working directory inside the image to '/app'.
WORKDIR /app

# Expose port 8000 on the Docker container.
EXPOSE 8000

# Set a build-time argument 'DEV' with a default value of 'false'.
ARG DEV=false 

# Create a Python virtual environment '/py' inside the image and upgrade 'pip'.
# Set the PATH environment variable to include the Python executable inside the virtual environment.
ENV PATH="/py/bin:$PATH"

# Install the packages specified in 'requirements.txt'.
# If the build-time argument 'DEV' is 'true', install the packages specified in 'requirements.dev.txt' as well.
# Remove the '/tmp' directory to clean up after the installations.
# Create a new user 'django-user' inside the image without a password and with no home directory.
RUN python -m venv /py && \
    pip install --upgrade pip && \
    pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    adduser \
    --disabled-password \
    --no-create-home \
    django-user

# Switch the user to 'django-user' to run the container with a non-root user.
USER django-user