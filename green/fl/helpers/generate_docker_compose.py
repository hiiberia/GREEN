import random
import argparse
import pandas as pd

parser = argparse.ArgumentParser(description="Generated Docker Compose")

parser.add_argument(
    "--num_rounds", type=int, default=100, help="Number of FL rounds (default: 100)"
)


def create_docker_compose(args):
    # cpus is used to set the number of CPUs available to the container as a fraction of the total number of CPUs on the host machine.
    # mem_limit is used to set the memory limit for the container.

    docker_compose_content = f"""
version: '3'
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - 9090:9090
    deploy:
      restart_policy:
        condition: on-failure
    command:
      - --config.file=/etc/prometheus/prometheus.yml
    volumes:
      - ./config/prometheus.yml:/etc/prometheus/prometheus.yml:ro
     # - /tmp/prometheus:/prometheus
    depends_on:
      - cadvisor

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:v0.47.2
    container_name: cadvisor
    privileged: true
    deploy:
      restart_policy:
        condition: on-failure
    ports:
      - "9080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro
      - /var/run/docker.sock:/var/run/docker.sock  
    devices:
      - /dev/kmsg

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - 3000:3000
    environment:
      - "GF_SERVER_ROOT_URL=http://192.168.26.202:3000/fl/"
      - "GF_SERVER_SERVE_FROM_SUB_PATH=true"
    deploy:
      restart_policy:
        condition: on-failure
    volumes:
      - grafana-storage:/var/lib/grafana
      - ./config/grafana.ini:/etc/grafana/grafana.ini
      - ./config/provisioning/datasources:/etc/grafana/provisioning/datasources
      - ./config/provisioning/dashboards:/etc/grafana/provisioning/dashboards
    depends_on:
      - prometheus
      - cadvisor
    command:
      - --config=/etc/grafana/grafana.ini

  server_fast:
    container_name: server_fast
    build:
      context: .
      dockerfile: Dockerfile
    command: python server_cs_fast.py --number_of_rounds={args.num_rounds}
    environment:
      FLASK_RUN_PORT: 5999
      DOCKER_HOST_IP: host.docker.internal
    volumes:
      - .:/app
      - /var/run/docker.sock:/var/run/docker.sock      
    ports:
      - "5999:5999"
      - "8265:8265"
      - "8000:8000"
    depends_on:
      - prometheus
      - grafana
      
  server_slow:
    container_name: server_slow
    build:
      context: .
      dockerfile: Dockerfile
    command: python server_cs_slow.py --number_of_rounds={args.num_rounds}
    environment:
      FLASK_RUN_PORT: 6000
      DOCKER_HOST_IP: host.docker.internal
    volumes:
      - .:/app
      - /var/run/docker.sock:/var/run/docker.sock      
    ports:
      - "6000:6000"
      - "8266:8265"
      - "8001:8001"
    depends_on:
      - prometheus
      - grafana
"""

    # Add client services
    data_path = 'helpers/Bcn_dayE.csv'

    all_data = pd.read_csv(data_path)
    CSs = all_data.columns.values
    for i in range(1, len(CSs) - 1):
        if CSs[i][0:10] == 'Power_PdRR':
            port_server = 'server_fast:8080'
        else:
            port_server = 'server_slow:8081'
        aux = CSs[i].replace(":", "")
        docker_compose_content += f"""
  client{i}:
    container_name: client{i}
    build:
      context: .
      dockerfile: Dockerfile
    command: python client.py --server_address={port_server} --client_id={i} --number_of_rounds={args.num_rounds} --CS_data="{aux}" 
    volumes:
      - .:/app
      - /var/run/docker.sock:/var/run/docker.sock
    ports:
      - "{6000 + i}:{6000 + i}"
    depends_on:
      - {port_server.split(":")[0]}
    extra_hosts:
        - "api-gateway-green-hf-service.hi-iberia.es:192.168.24.225"
    environment:
      FLASK_RUN_PORT: {6000 + i}
      container_name: client{i}
      API_KEY: your-api-key-here
      DOCKER_HOST_IP: host.docker.internal
"""

    docker_compose_content += "volumes:\n  grafana-storage:\n"

    with open("docker-compose.yml", "w") as file:
        file.write(docker_compose_content)


if __name__ == "__main__":
    args = parser.parse_args()
    create_docker_compose(args)
