#!/usr/bin/env bash
# Run Nextcloud All-in-One master container
docker run -d \
  --name nextcloud-aio-mastercontainer \
  --restart unless-stopped \
  -p 8080:8080 \
  -e APACHE_PORT=11000 \
  -e APACHE_IP_BINDING=0.0.0.0 \
  -e NEXTCLOUD_MOUNT=/mnt \
  -v nextcloud_aio_mastercontainer:/mnt/docker-aio-config \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v /mnt:/mnt \
  -v /mnt/nextcloud:/mnt/nextcloud \
  nextcloud/all-in-one:latest
