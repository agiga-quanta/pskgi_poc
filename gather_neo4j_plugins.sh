#!/bin/bash

####################
# Download for neo4j into plugins/ directory following libraries
# - neo4j-apoc-procedures
# - graph-data-science
# - Apache POI and related libaries for xls(x) processing
####################

NEO4J_VERSION=4.2.2

GDS_LIB_VERSION=1.4.1
APOC_LIB_VERSION=4.2.0.1
GITHUB_GDS_URI=https://github.com/neo4j/graph-data-science/releases/download
GITHUB_APOC_URI=https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download
APACHE_MAVEN=https://repo1.maven.org/maven2/org/apache/
APACHE_GITHUB=https://repo1.maven.org/maven2/com/github/
APACHE_POI=poi-3.17.jar
APACHE_POI_OOXML=poi-ooxml-3.17.jar
APACHE_POI_OOXML_SCHEMAS=poi-ooxml-schemas-3.17.jar
COMMON_COLLECTIONS=commons-collections4-4.1.jar
CURVES_API=curvesapi-1.04.jar
XML_BEANS=xmlbeans-2.6.0.jar

NEO4J_GDS_URI=${GITHUB_GDS_URI}/${GDS_LIB_VERSION}/neo4j-graph-data-science-${GDS_LIB_VERSION}-standalone.jar
NEO4J_APOC_URI=${GITHUB_APOC_URI}/${APOC_LIB_VERSION}/apoc-${APOC_LIB_VERSION}-all.jar
APACHE_POI_URI=${APACHE_MAVEN}poi/poi/3.17/${APACHE_POI}
APACHE_POI_OOXML_URI=${APACHE_MAVEN}poi/poi-ooxml/3.17/${APACHE_POI_OOXML}
APACHE_POI_OOXML_SCHEMAS_URI=${APACHE_MAVEN}poi/poi-ooxml-schemas/3.17/${APACHE_POI_OOXML_SCHEMAS}
COMMON_COLLECTIONS_URI=${APACHE_MAVEN}commons/commons-collections4/4.1/${COMMON_COLLECTIONS}
CURVES_API_URI=${APACHE_GITHUB}virtuald/curvesapi/1.04/${CURVES_API}
XML_BEANS_URI=${APACHE_MAVEN}xmlbeans/xmlbeans/2.6.0/${XML_BEANS}

curl -C- --progress-bar --location ${NEO4J_GDS_URI} --output plugins/neo4j-graph-data-science-${GDS_LIB_VERSION}-standalone.jar
curl -C- --progress-bar --location ${NEO4J_APOC_URI} --output plugins/apoc-${APOC_LIB_VERSION}-all.jar
curl -C- --progress-bar --location ${APACHE_POI_URI} --output plugins/${APACHE_POI}
curl -C- --progress-bar --location ${APACHE_POI_OOXML_URI} --output plugins/${APACHE_POI_OOXML}
curl -C- --progress-bar --location ${APACHE_POI_OOXML_SCHEMAS_URI} --output plugins/${APACHE_POI_OOXML_SCHEMAS}
curl -C- --progress-bar --location ${COMMON_COLLECTIONS_URI} --output plugins/${COMMON_COLLECTIONS}
curl -C- --progress-bar --location ${CURVES_API_URI} --output plugins/${CURVES_API}
curl -C- --progress-bar --location ${XML_BEANS_URI} --output plugins/${XML_BEANS}
echo 'Done.'
