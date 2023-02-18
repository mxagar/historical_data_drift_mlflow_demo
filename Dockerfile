# We can modify image/python version with
# docker build --build-arg IMAGE=python:3.8
# Otherwise, default: python:3.9.16
ARG IMAGE=python:3.9.16
FROM $IMAGE

# Create the user that will run the app
RUN adduser --disabled-password --gecos '' ml-user

# Create directory IN container and change to it
WORKDIR /opt/historical_data_drift

# Copy folder contents (unless the ones from .dockerignore) TO container
ADD . /opt/historical_data_drift/
# Install requirements
RUN pip install --upgrade pip
RUN pip install -r /opt/historical_data_drift/requirements.txt --no-cache-dir

# Change permissions
RUN chmod +x /opt/historical_data_drift/run.sh
RUN chown -R ml-user:ml-user ./

# Change user to the one created
USER ml-user

# Expose port
EXPOSE 5000

# Run web server, started by run.sh
# python expo.py & mlflow ui
CMD ["bash", "./run.sh"]

# Build the Dockerfile to create the image
# docker build -t <image_name[:version]> <path/to/Dockerfile>
#   docker build -t historical_data_drift:latest .
# 
# Check the image is there: watch the size (e.g., ~1GB)
#   docker image ls
#
# Run the container locally from a built image
# Recall to: forward ports (-p) and pass PORT env variable (-e)
# Optional: 
# -d to detach/get the shell back,
# --name if we want to choose conatiner name (else, one randomly chosen)
# --rm: automatically remove container after finishing (irrelevant in our case, but...)
#   docker run -d --rm -p 5001:5000 --name historical_data_drift historical_data_drift:latest
#
# Check the API locally: open the browser
#   http://127.0.0.1:5001
#   Use the web interface
# 
# Check the running containers: check the name/id of our container,
# e.g., census_model_app
#   docker container ls
#   docker ps
#
# Get a terminal into the container: in general, BAD practice
# docker exec -it <id|name> sh
#   docker exec -it historical_data_drift sh
#   (we get inside)
#   cd /opt/historical_data_drift
#   ls
#   exit
#
# Stop container and remove it (erase all files in it, etc.)
# docker stop <id/name>
# docker rm <id/name>
#   docker stop historical_data_drift
#   docker rm historical_data_drift