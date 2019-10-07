#Build applications using node image
FROM node:10.13-alpine as builder

RUN apk update && apk add --no-cache make git
#We do so in separate steps because this way we can take advantage of Docker caching each step (also called layer).
#That way subsequent builds of the image will be faster, in case the package.json did not change.
COPY ./package.json /opt/avana-equalseat/
RUN cd /opt/avana-equalseat && npm set progress=false && npm install
COPY ./ /opt/avana-equalseat
RUN cd /opt/avana-equalseat && npm run build

#Prepare applications runtime
FROM nginx:alpine

COPY --from=builder /opt/avana-equalseat/dist/angular-io-quickstart /opt/avana-equalseat
COPY ./conf/default.conf /etc/nginx/conf.d/
CMD ["nginx", "-g", "daemon off;"]