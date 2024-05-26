FROM gcr.io/distroless/base-debian12

ARG BINARY_PATH
ARG PORT=8080
ENV PORT=${PORT}

COPY $BINARY_PATH bin/main

USER nonroot
EXPOSE ${PORT}
CMD ["main"]
