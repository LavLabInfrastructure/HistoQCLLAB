# small little container to test bash scripts
# todo? stat keeping for comparing to pash?
FROM mjbarrett/hqcpipe
WORKDIR /in/testStart/000
ENV LOG_LEVEL INFO
ENV REQUIRED_PIXEL_PERCENTAGE 20
ENV CONVERT_TO_ZARR true
ENV CONVERT_TO_TIFF true
RUN apt update && apt install -y curl
ENTRYPOINT "/docker/_entrypoint.sh"