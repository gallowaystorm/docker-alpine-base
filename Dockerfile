#this is the latest version as of 2/2/2021
FROM alpine:3.13.1

#update all packages
RUN apk update --no-cache


#set envrionment variables

#user apps should be using
ENV APP_USER = app
#home directory
ENV APP_HOME_DIR = '/${APP_USER}''
#where persistent data should be stored
ENV DATA_DIR = '${APP_HOME_DIR}/data'
#where configuration should be stored
ENV CONF_DIR = '/${APP_HOME_DIR}/conf'


#create less privelaged user and its corresponding data and conf dirs then add correct permissions
RUN addgroup -S app && \
    addgroup -S -G app app && \
    mkdir '${DATA_DIR}' '${CONF_DIR}' && \
    chown -R '${APP_USER}' '${DATA_DIR}' '${CONF_DIR}' && \
    chmod 700 '${APP_HOME_DIR}' '${DATA_DIR}' '${CONF_DIR}'


#remove cron jobs
RUN rm -fr /var/spool/cron && \
	rm -fr /etc/crontabs && \
	rm -fr /etc/periodic


