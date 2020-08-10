FROM centos:latest

WORKDIR /embulk_digdag

# install java8
RUN yum update -y && yum install -y \
    java-1.8.0-openjdk \
    java-1.8.0-openjdk-devel

# install the other component
RUN yum -y install vim gcc make openssl openssl-devel readline-devel bzip2

# install embulk and plugins
RUN curl --create-dirs -o ~/.embulk/bin/embulk -L "https://dl.embulk.org/embulk-latest.jar" &&\
    chmod +x ~/.embulk/bin/embulk && \
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc && \
    echo 'export PATH="/$HOME/bin:/$HOME/.embulk/bin:$PATH"' >> ~/.bashrc && \
    source ~/.bashrc && \
    embulk gem install embulk-input-mysql embulk-input-s3 embulk-output-s3 embulk-filter-column embulk-filter-add_time embulk-input-gcs embulk-input-google_analytics embulk-input-td embulk-input-bigquery_extract_files embulk-output-bigquery embulk-output-td embulk-output-sftp embulk-output-gcs && \
    embulk gem install google-cloud-env -v 1.0.5 && \ 
    embulk gem install google-cloud-core -v 1.3.0 && \ 
    embulk gem install embulk-input-bigquery

# install digdag
RUN curl -o ~/bin/digdag --create-dirs -L "https://dl.digdag.io/digdag-latest" && \
    chmod +x ~/bin/digdag

# configure digdag server properties
RUN mkdir -p ~/.config/digdag/config && \
    cd ~/.config/digdag/config && \
    touch /root/.config/digdag/config/digdag-server.properties && \
    echo -n '16_bytes_phrase!' | openssl base64 | awk '{print "digdag.secret-encryption-key = " $1}' >> /root/.config/digdag/config/digdag-server.properties

# expose the digdag web server port
EXPOSE 80

# execute the digdag server when the container run
CMD exec /root/bin/digdag server -n 80 -o /var/db/digdag --bind 0.0.0.0 -O /var/log/digdag -c /root/.config/digdag/config/digdag-server.properties
