ARG BASE_TAG="develop"
ARG BASE_IMAGE="core-rockylinux-9"
FROM kasmweb/$BASE_IMAGE:$BASE_TAG

USER root

ENV DISTRO=rockylinux9
ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
WORKDIR $HOME

### Envrionment config
ENV SKIP_CLEAN=true \
    KASM_RX_HOME=$STARTUPDIR/kasmrx \
    DONT_PROMPT_WSL_INSTALL="No_Prompt_please" \
    INST_DIR=$STARTUPDIR/install \
    INST_SCRIPTS="/oracle/install/tools/install_tools_deluxe.sh \
                  /oracle/install/misc/install_tools.sh \
                  /ubuntu/install/chrome/install_chrome.sh \
                  /oracle/install/sublime_text/install_sublime_text.sh \
                  /ubuntu/install/remmina/install_remmina.sh \
                  /oracle/install/only_office/install_only_office.sh \
                  /ubuntu/install/cleanup/cleanup.sh"

# Copy install scripts
COPY ./src/ $INST_DIR

# Run installations
RUN \
  for SCRIPT in $INST_SCRIPTS; do \
    bash ${INST_DIR}${SCRIPT}; \
  done && \
  $STARTUPDIR/set_user_permission.sh $HOME && \
  rm -f /etc/X11/xinit/Xclients && \
  chown 1000:0 $HOME && \
  mkdir -p /home/kasm-user && \
  chown -R 1000:0 /home/kasm-user && \
  rm -Rf ${INST_DIR}

# Userspace Runtime
ENV HOME /home/kasm-user
WORKDIR $HOME
USER 1000

CMD ["--tail-log"]
