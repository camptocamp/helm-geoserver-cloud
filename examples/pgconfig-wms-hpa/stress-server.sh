#!/bin/bash

WMS_URL="http://gscloud.local/geoserver-cloud/wms?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&FORMAT=image%2Fpng&TRANSPARENT=true&STYLES&LAYERS=hpa-test%3Ach.bafu.grundwasserkoerper&exceptions=application%2Fvnd.ogc.se_inimage&SRS=EPSG%3A2056&WIDTH=769&HEIGHT=359&BBOX=2628297.2396917907%2C1161127.5666655225%2C2745623.985655881%2C1215846.1146757442"

for _ in {1..1000}
do
  curl -s "$WMS_URL" > /dev/null &
done

wait
