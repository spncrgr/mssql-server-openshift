# mssql-server
FROM openshift/base-centos7

### Atomic/OpenShift Labels - https://github.com/projectatomic/ContainerApplicationGenericLabels
LABEL name="microsoft/mssql-server-linux" \
      vendor="Microsoft" \
      version="14.0" \
      release="1" \
      summary="MS SQL Server" \
      description="MS SQL Server is ....." \
### Required labels above - recommended below
      url="https://www.microsoft.com/en-us/sql-server/" \
      io.k8s.description="MS SQL Server is ....." \
      io.k8s.display-name="MS SQL Server" \
      io.openshift.tags="mssql-server-runtime,sqlserver"

ENV ACCEPT_EULA=Y

# Install latest mssql-server packages
RUN curl -sSLo /etc/yum.repos.d/mssql-server.repo https://packages.microsoft.com/config/rhel/7/mssql-server-2017.repo && \
    curl -sSLo /etc/yum.repos.d/msprod.repo https://packages.microsoft.com/config/rhel/7/prod.repo && \
    INSTALL_PKGS="mssql-server mssql-tools unixODBC-devel mssql-server-fts" && \
    yum install -y -q --setopt=tsflags=nodocs $INSTALL_PKGS && \
    yum clean all -y -q && \
    rm -rf /var/cache/yum/*

COPY uid_entrypoint /opt/mssql-tools/bin/
RUN chmod +x /opt/mssql-tools/bin/uid_entrypoint

# Add executables to PATH
ENV PATH=${PATH}:/opt/mssql/bin:/opt/mssql-tools/bin
RUN mkdir -p /var/opt/mssql/data && \
    chmod -R g=u /var/opt/mssql /etc/passwd

# TODO (optional): Copy the builder files into /opt/app-root
# COPY ./<builder_folder>/ /opt/app-root/

# TODO: Copy the S2I scripts to /usr/libexec/s2i, since openshift/base-centos7 image
# sets io.openshift.s2i.scripts-url label that way, or update that label
# COPY ./s2i/bin/ /usr/libexec/s2i

# TODO: Drop the root user and make the content of /opt/app-root owned by user 1001
# RUN chown -R 1001:1001 /opt/app-root

# This default user is created in the openshift/base-centos7 image
USER 1001

# Default SQL Server TCP/Port
EXPOSE 1433

VOLUME /var/opt/mssql/data

### user name recognition at runtime w/ an arbitrary uid - for OpenShift deployments
ENTRYPOINT [ "uid_entrypoint" ]
# Run SQL Server process
CMD sqlservr
