FROM radanalyticsio/base-notebook:2.2-latest

USER $NBUSER

ENV SCALA_VERSION=2.11.12 \
    ALMOND_VERSION=0.1.7 \
    CLASSPATH=/opt/spark/jars/ \
    JUPYTER_NOTEBOOK_PASSWORD=jupyter

RUN \
    cd $HOME && \
    curl -L -o coursier https://git.io/vgvpD && chmod +x coursier && \
    ./coursier bootstrap \
        -i user -I user:sh.almond:scala-kernel-api_$SCALA_VERSION:$ALMOND_VERSION \
        sh.almond:scala-kernel_$SCALA_VERSION:$ALMOND_VERSION \
        -o almond && \
    ./almond --install && \
    rm -f almond && \
    chmod a+rwx $HOME && chmod -R a+rwx $HOME/.local

ENTRYPOINT ["/tini", "--"]

CMD ["/entrypoint", "/start.sh"]
