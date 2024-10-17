#!/bin/bash

GEOSERVER_URL="http://gscloud.local/geoserver-cloud"
USER="admin"
PASSWORD="geoserver"

WORKSPACE="hpa-test"
DATASTORE="swisstopo_wms"
WMS_URL="https://wms.geo.admin.ch/?SERVICE=WMS&amp;VERSION=1.3.0&amp;REQUEST=GetCapabilities"
LAYER_NAME="ch.bafu.grundwasserkoerper"

echo -e "\n------------------------------------"
echo -e "Preparing initialization process ..."
curl -u $USER:$PASSWORD -X DELETE "$GEOSERVER_URL/rest/workspaces/$WORKSPACE?recurse=true"

echo -e "------------------------------------"
echo -e "Creating workspace '$WORKSPACE'..."
if ! curl -u $USER:$PASSWORD -X POST -H "Content-Type: text/xml" -d "<workspace><name>$WORKSPACE</name></workspace>" $GEOSERVER_URL/rest/workspaces --fail; then
  echo -e "Error creating workspace\n"
  exit 1
fi

echo -e "\n------------------------------------"
echo -e "Creating WMS datastore '$DATASTORE'..."
if ! curl -u $USER:$PASSWORD -X POST -H "Content-Type: text/xml" -d "<wmsStore><type>WMS</type><name>$DATASTORE</name><workspace>$WORKSPACE</workspace><capabilitiesURL>$WMS_URL</capabilitiesURL><enabled>true</enabled></wmsStore>" $GEOSERVER_URL/rest/workspaces/$WORKSPACE/wmsstores --fail; then
  echo -e "\nError creating datastore"
  exit 1
fi

echo -e "\n------------------------------------"
echo -e "Publishing layer '$LAYER_NAME' from datastore '$DATASTORE'..."
if ! curl -u $USER:$PASSWORD -X POST -H "Content-Type: text/xml" -d "<wmsLayer><name>$LAYER_NAME</name><defaultStyle><name>raster</name></defaultStyle></wmsLayer>" $GEOSERVER_URL/rest/workspaces/$WORKSPACE/wmsstores/$DATASTORE/wmslayers --fail; then
  echo -e "Error publishing layer\n"
  exit 1
fi

echo -e "\n------------------------------------"
echo -e "Catalog initialized successfully.\n"
