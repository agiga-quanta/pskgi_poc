####################
# set base image (host OS)
#
FROM python:3.8-slim

WORKDIR /
COPY / .
EXPOSE 8001

####################
# Start the server
#
CMD ["python", "http-server.py"]
