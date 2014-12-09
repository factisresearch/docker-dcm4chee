#
# DCM4CHEE - Open source picture archive and communications server (PACS)
#
FROM ubuntu:12.04
MAINTAINER AI Analysis, Inc <admin@aianalysis.com>

# Install dependencies
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y curl zip mysql-client openjdk-6-jdk vim less


# Configure environment
ENV DCM4CHEE_HOME /opt/dcm4chee
RUN mkdir -p $DCM4CHEE_HOME
WORKDIR $DCM4CHEE_HOME

# Download the binary packages
RUN curl -G http://colocrossing.dl.sourceforge.net/project/jboss/JBoss/JBoss-4.2.3.GA/jboss-4.2.3.GA-jdk6.zip -o jboss-4.2.3.GA-jdk6.zip
RUN curl -G http://colocrossing.dl.sourceforge.net/project/dcm4che/dcm4chee/2.17.1/dcm4chee-2.17.1-mysql.zip -o dcm4chee-2.17.1-mysql.zip
RUN curl -G http://colocrossing.dl.sourceforge.net/project/dcm4che/dcm4chee-arr/3.0.11/dcm4chee-arr-3.0.11-mysql.zip -o dcm4chee-arr-3.0.11-mysql.zip
RUN curl -L http://download.java.net/media/jai-imageio/builds/release/1.1/jai_imageio-1_1-lib-linux-amd64.tar.gz | tar xz

# Extract the binary packages
RUN find -name "*.zip" -exec unzip {} \; -delete
RUN find -type d -exec chmod 755 {} \;

# Configure environment
ENV JAVA_HOME   /usr/lib/jvm/java-6-openjdk-amd64
ENV JBOSS_DIR   $DCM4CHEE_HOME/jboss-4.2.3.GA
ENV DCM_DIR     $DCM4CHEE_HOME/dcm4chee-2.17.1-mysql
ENV ARR_DIR     $DCM4CHEE_HOME/dcm4chee-arr-3.0.11-mysql

# The ARR setup script needs to be patched
RUN sed -i 's/type=/engine=/g' $ARR_DIR/sql/dcm4chee-arr-mysql.ddl

# Copy files from JBoss and Audit Record Repository (ARR) to dcm4chee
RUN $DCM_DIR/bin/install_jboss.sh jboss-4.2.3.GA
RUN $DCM_DIR/bin/install_arr.sh dcm4chee-arr-3.0.11-mysql

# Install native ImageIO C-Library
RUN cp -v jai_imageio-1_1/lib/libclib_jiio.so $DCM_DIR/bin/native/

# Patch datasource of ARR and PACS to connect to the mysql host
RUN sed -i 's/localhost:3306/mysql:3306/g' $DCM_DIR/server/default/deploy/pacs-mysql-ds.xml
RUN sed -i 's/localhost:3306/mysql:3306/g' $DCM_DIR/server/default/deploy/arr-mysql-ds.xml

# Patch storage default locations
RUN sed -i 's#"archive"#"/opt/storage/archive"#g' $DCM_DIR/server/default/conf/xmdesc/dcm4chee-storescp-xmbean.xml
RUN sed -i 's#"archive"#"/opt/storage/archive"#g' $DCM_DIR/server/default/conf/xmdesc/dcm4chee-fsmgt-online-xmbean.xml
RUN sed -i 's#"wadocachedata"#"/opt/storage/wadocachedata"#g' $DCM_DIR/server/default/conf/xmdesc/dcm4chee-wado-xmbean.xml
RUN sed -i 's#"wadocachejournal"#"/opt/storage/wadocachejournal"#g' $DCM_DIR/server/default/conf/xmdesc/dcm4chee-wado-xmbean.xml

# Configure storage volumes
VOLUME \
/opt/storage/archive \
/opt/storage/wadocachedata \
/opt/storage/wadocachejournal

# Load the stage folder, which contains the setup scripts.
COPY stage/ $DCM4CHEE_HOME
RUN chmod 755 $DCM4CHEE_HOME/*.bash

