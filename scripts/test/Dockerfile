# small little container to test bash scripts
# todo? stat keeping for comparing to pash?
FROM mjbarrett/hqcPipe
WORKDIR /test
RUN curl -Lo /tmp/.zip -X GET https://services.cancerimagingarchive.net/services/v4/TCIA/query/getImage?SeriesInstanceUID=C3L-03727-21 
RUN /scripts/watchDir.sh /test
RUN unzip -qod /test /tmp/.zip....