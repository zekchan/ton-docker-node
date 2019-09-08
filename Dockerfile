FROM ubuntu:latest as base
WORKDIR /ton
RUN apt update && apt upgrade -y
RUN apt install libssl-dev gperf zlib1g  -y

FROM base as build
RUN apt install clang make cmake libssl-dev zlib1g-dev -y
COPY source ./source
RUN mkdir build && cd build && cmake /ton/source && make
RUN cd /ton/build && mkdir result && \
  mv ./validator-engine/validator-engine \
  ./validator-engine-console/validator-engine-console \
  ./utils/generate-random-id \
  ./utils/json2tlo \
  ./result/

FROM base
EXPOSE 6302
EXPOSE 6300
RUN mkdir /var/ton-work
COPY --from=build /ton/build/result .
CMD [ "/ton/validator-engine", "--db", "/var/ton-work/db", "--ip", "localhost:6302", "-C", "/var/ton-work/etc/ton-global.config.json"]