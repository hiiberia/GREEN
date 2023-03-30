FROM python:3

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends git openvpn

RUN mkdir -p /GREEN
# Do not copy all files to avoid copying all the files in data
COPY ./requirements.txt  /GREEN/requirements.txt
COPY ./setup.py  /GREEN/setup.py
COPY ./green  /GREEN/green
WORKDIR /GREEN/
RUN pip install -r requirements.txt
RUN pip install -e .

