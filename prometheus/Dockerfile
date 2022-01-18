FROM prom/prometheus
EXPOSE 9090
ADD rules.yaml /etc/prometheus/
ADD prometheus.yaml /etc/prometheus/
#VOLUME ./prometheus.yaml /etc/prometheus/prometheus.yaml
CMD [ "--config.file=/etc/prometheus/prometheus.yaml" ]
