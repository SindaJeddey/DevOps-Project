FROM prom/prometheus
EXPOSE 9090
ADD prometheus.yaml /etc/prometheus/
#VOLUME ./prometheus.yaml /etc/prometheus/prometheus.yaml
CMD [ "--config.file=/etc/prometheus/prometheus.yaml" ]
