FROM grafana/grafana-oss:10.3.3

##################################################################
## CONFIGURATION
##################################################################

## Set Grafana options
ENV GF_ENABLE_GZIP=true
ENV GF_USERS_DEFAULT_THEME=light
ENV GF_PANELS_DISABLE_SANITIZE_HTML=true
ENV GF_EXPLORE_ENABLED=false
ENV GF_ANALYTICS_CHECK_FOR_UPDATES=false

USER root

##################################################################
## INSTALLATION OF CADDY
##################################################################

RUN curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | apt-key add - && \
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list && \
    apt-get update && \
    apt-get install -y caddy

## Copy the Caddyfile
COPY Caddyfile /etc/caddy/Caddyfile

# Copy a custom entrypoint script
COPY custom-entrypoint.sh /custom-entrypoint.sh
RUN chmod +x /custom-entrypoint.sh

##################################################################
## FEATURES
##################################################################

## Set Grafana features
ENV GF_FEATURE_TOGGLES_ENABLE=newVizTooltips,featureHighlights,panelTitleSearch,nestedFolders,dashgpt,transformationsVariableSupport,pdfTables,regressionTransformation,extraThemes,vizAndWidgetSplit,logsExploreTableVisualisation,featureToggleAdminPage,libraryPanelRBAC

##################################################################
## VISUAL
##################################################################

## Replace Favicon and Apple Touch
COPY img/fav32.png /usr/share/grafana/public/img
COPY img/fav32.png /usr/share/grafana/public/img/apple-touch-icon.png

## Replace Logo
COPY img/logo.svg /usr/share/grafana/public/img/grafana_icon.svg

## Update Background
COPY img/background.svg /usr/share/grafana/public/img/g8_login_dark.svg
COPY img/background.svg /usr/share/grafana/public/img/g8_login_light.svg

##################################################################
## HANDS-ON
##################################################################

# Update Title
RUN sed -i 's|<title>\[\[.AppTitle\]\]</title>|<title>AnalytiQ360</title>|g' /usr/share/grafana/public/views/index.html

## Update Title
RUN find /usr/share/grafana/public/build/ -name *.js -exec sed -i 's|AppTitle="Grafana"|AppTitle="AnalytiQ360"|g' {} \;

## Update Login Title
RUN find /usr/share/grafana/public/build/ -name *.js -exec sed -i 's|LoginTitle="Welcome to Grafana"|LoginTitle="Welcome to AnalytiQ360"|g' {} \;

## Remove Documentation, Support, Community in the Footer
RUN find /usr/share/grafana/public/build/ -name *.js -exec sed -i 's|\[{target:"_blank",id:"documentation".*grafana_footer"}\]|\[\]|g' {} \;

## Remove Edition in the Footer
RUN find /usr/share/grafana/public/build/ -name *.js -exec sed -i 's|({target:"_blank",id:"license",.*licenseUrl})|()|g' {} \;

## Remove Version in the Footer
RUN find /usr/share/grafana/public/build/ -name *.js -exec sed -i 's|({target:"_blank",id:"version",.*CHANGELOG.md":void 0})|()|g' {} \;

## Remove News icon
RUN find /usr/share/grafana/public/build/ -name *.js -exec sed -i 's|..createElement(....,{className:.,onClick:.,iconOnly:!0,icon:"rss","aria-label":"News"})|null|g' {} \;

## Remove Open Source icon
RUN find /usr/share/grafana/public/build/ -name *.js -exec sed -i 's|.push({target:"_blank",id:"version",text:`${..edition}${.}`,url:..licenseUrl,icon:"external-link-alt"})||g' {} \;

##################################################################
## CLEANING Remove Native Data Sources
##################################################################

## Time series databases / Graphite
RUN rm -rf /usr/share/grafana/public/app/plugins/datasource/graphite
RUN rm -rf /usr/share/grafana/public/build/graphite*

## Time series databases / OpenTSDB
RUN rm -rf /usr/share/grafana/public/app/plugins/datasource/opentsdb
RUN rm -rf /usr/share/grafana/public/build/opentsdb*

## Time series databases / InfluxDB
RUN rm -rf /usr/share/grafana/public/app/plugins/datasource/influxdb
RUN rm -rf /usr/share/grafana/public/build/influxdb*

## SQL / Microsoft SQL Server
RUN rm -rf /usr/share/grafana/public/app/plugins/datasource/mssql
RUN rm -rf /usr/share/grafana/public/build/mssql*

## SQL / MySQL
RUN rm -rf /usr/share/grafana/public/app/plugins/datasource/mysql
RUN rm -rf /usr/share/grafana/public/build/mysql*

## Distributed tracing / Tempo
RUN rm -rf /usr/share/grafana/public/app/plugins/datasource/tempo
RUN rm -rf /usr/share/grafana/public/build/tempo*

## Distributed tracing / Jaeger
RUN rm -rf /usr/share/grafana/public/app/plugins/datasource/jaeger
RUN rm -rf /usr/share/grafana/public/build/jaeger*

## Distributed tracing / Zipkin
RUN rm -rf /usr/share/grafana/public/app/plugins/datasource/zipkin
RUN rm -rf /usr/share/grafana/public/build/zipkin*

## Cloud / Google Cloud Monitoring
RUN rm -rf /usr/share/grafana/public/app/plugins/datasource/cloud-monitoring
RUN rm -rf /usr/share/grafana/public/build/cloudMonitoring*

## Profiling / Parca
RUN rm -rf /usr/share/grafana/public/app/plugins/datasource/parca
RUN rm -rf /usr/share/grafana/public/build/parca*

## Profiling / Phlare
RUN rm -rf /usr/share/grafana/public/app/plugins/datasource/phlare
RUN rm -rf /usr/share/grafana/public/build/phlare*

## Profiling / Pyroscope
RUN rm -rf /usr/share/grafana/public/app/plugins/datasource/grafana-pyroscope-datasource
RUN rm -rf /usr/share/grafana/public/build/pyroscope*

##################################################################
## CLEANING Remove Native Panels
##################################################################

## Alert list
RUN rm -rf /usr/share/grafana/public/app/plugins/panel/alertlist

## Annotations list
RUN rm -rf /usr/share/grafana/public/app/plugins/panel/annolist

## Dashboard list
RUN rm -rf /usr/share/grafana/public/app/plugins/panel/dashlist

## News
RUN rm -rf /usr/share/grafana/public/app/plugins/panel/news

## Table (old)
RUN rm -rf /usr/share/grafana/public/app/plugins/panel/table-old

## Traces
RUN rm -rf /usr/share/grafana/public/app/plugins/panel/traces

## Flamegraph
RUN rm -rf /usr/share/grafana/public/app/plugins/panel/flamegraph

##################################################################

USER grafana

# Set the custom entrypoint script
ENTRYPOINT ["/custom-entrypoint.sh"]