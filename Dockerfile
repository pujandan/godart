# Use latest stable channel SDK.
FROM dart:stable AS build

# Add PATH Go Lang & Dart
ENV PATH="/usr/local/go/bin:${PATH}"
#ENV PATH="/usr/lib/dart/bin:${PATH}"
ENV PATH="/root/.pub-cache/bin:${PATH}"

# Update
RUN apt-get update

# Install wget & tar
RUN apt-get install wget -y
RUN apt-get install tar

# Download Go Lang
RUN mkdir download
RUN wget -P /download https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
# Install Go Lang
RUN rm -rf /usr/local/go
RUN tar -C /usr/local -xzf /download/go1.21.5.linux-amd64.tar.gz
# Check Version Go Lang
RUN go version

# Download Dart
#RUN wget -P /download https://storage.googleapis.com/dart-archive/channels/stable/release/latest/linux_packages/dart_3.2.4-1_amd64.deb
# Install Dart
#RUN dpkg -i /download/dart_3.2.4-1_amd64.deb
# Check Version Dart
RUN dart --version

# Activate ffi_lib
RUN dart pub global activate ffi_lib

# Insrall GCC
RUN apt-get install gcc -y
# Check Version GCC
RUN gcc --version



# Resolve app dependencies.
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get
RUN dart pub update

# Copy app source code (except anything in .dockerignore) and AOT compile app.
COPY . .
RUN dart compile exe bin/server.dart -o bin/server
RUN ffi-lib mongo_go


# Start server.
#EXPOSE 8080
#CMD ["/app/bin/server"]
#CMD ["bash", "-c", "while true; do sleep 1; done"]


# Build minimal serving image from AOT-compiled `/server`
# and the pre-built AOT-runtime in the `/runtime/` directory of the base image.
FROM alpine:latest
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/
COPY --from=build /app/bin/mongo_go.so /app/bin/

RUN apk update
RUN apk add go
RUN apk add gcc

# Start server.
EXPOSE 8080
CMD ["/app/bin/server"]