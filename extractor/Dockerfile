####################
# set base image (host OS)
#
FROM python:3.8-slim

COPY requirements.txt ./
RUN pip3 install -r /requirements.txt

WORKDIR /
COPY src/ .
EXPOSE 8002

####################
# Start the server
#
CMD ["uvicorn", "--reload", "webapp:app", "--host", "0.0.0.0", "--port", "8002"]
