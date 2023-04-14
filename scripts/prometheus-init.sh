#!/bin/sh
# Prometheus refuses to use environment vars.
# We can use this init script to do the replacement for us.
for i in $(env); do
    KEY=$(echo "$i" | sed "s/^\([A-Z]*\)\=\(.*$\)/\1/")
    VALUE=$(echo "$i" | sed "s/^\([A-Z]*\)\=\(.*$\)/\2/")
    sed -i "s/\${${KEY}}/${VALUE}/g" /etc/prometheus/prometheus.yml
done

exec /bin/prometheus "$@"
