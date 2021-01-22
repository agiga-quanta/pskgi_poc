####################
# set base image (host OS)
#
FROM python:3.8-slim AS base

####################
# Use `base` image
# - install Python Dependencies to /install directory
#
FROM base AS python-deps
RUN mkdir /install
COPY requirements.txt ./
RUN pip3 install --prefix=/install -r /requirements.txt --no-warn-script-location

####################
# Reuse `base` image
# - preload EN stanza resources to /root/stanza_resources
#
FROM base AS stanza-resources
RUN apt-get update && apt-get install -y unzip wget
RUN wget https://raw.githubusercontent.com/stanfordnlp/stanza-resources/master/resources_1.1.0.json -P /root/stanza_resources
RUN wget https://nlp.stanford.edu/software/stanza/1.1.0/en/default.zip -P /root/stanza_resources/en
RUN unzip /root/stanza_resources/en/default.zip -d /root/stanza_resources/en/
RUN rm /root/stanza_resources/en/default.zip
RUN mv /root/stanza_resources/resources_1.1.0.json /root/stanza_resources/resources.json

####################
# Reuse `base` image
# - copy over only the necessary files from /install and /root/stanza_resources
# - ignore all other temporary files and directories
#
FROM base
COPY --from=python-deps /install /usr/local
COPY --from=stanza-resources /root/stanza_resources /root/stanza_resources/

####################
# Complete installation
# - set the working directory in the container
# - copy the content of the local src directory to the working directory
# - expose port 8000 so that can be accessible from outside of the container
#
WORKDIR /
COPY src/ .
EXPOSE 8000

####################
# Start the server
#
CMD ["uvicorn", "--reload", "webapp:app", "--host", "0.0.0.0", "--port", "8000"]
