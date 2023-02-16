# distroless-azul-jre

This project creates a distroless Azul JRE docker image (for a headless java runtime)

It's based on Azul Java JRE as runtime and the needed glibc libraries which are taken distroless-base-image.

## How it was created

The Dockerfile was reduced to 3 sections:

1. Get latest Debian slim docker image, download and unpack Azul JRE - (jre layer)
2. Merge content of "distroless layer" and "jre layer" into a new blank image
3. Make sure the default user of the image is not a root user. (UID 1001)

## Important to know

The image has a predefined entrypoint which is important for final usage:

`ENTRYPOINT [ "/usr/bin/java" ]`

The default user of this image has the UID `1001`.

## How to use

Simplest scenario is to create an own image by using this image as a base and add the compiled Java application (.JAR) as another layer.
An example Dockerfile would look like this:

```Dockerfile
FROM distroless-azul-jre:11
WORKDIR /usr/app
COPY myjava-application.jar /usr/app/myjava-application.jar
CMD [ "-jar", "/usr/app/myjava-application.jar" ]
```

An alternative is to overwrite the entrypoint like this:

`ENTRYPOINT [ "/usr/bin/java", "-jar" , "/usr/app/myjava-application.jar" ]`
