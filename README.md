# distroless-azul-jre

This project creates a distroless Azul JRE docker image (for a headless java runtime)

It's based on Azul Java JRE as runtime and the needed glibc libraries which are taken from latest Debian-Slim image.

## How it was created:

The Dockerfile has 4 sections:
1. Download the latest Azul Java JRE (for GLIBC based distros) and unpack it - (helper layer 1)
2. Get latest Debian slim docker image - (helper layer 2)
3. Create a distroless base layer by taking out only x86/64 linux libraries, locales and a release version info (important for vulnerability scanners) from helper layer 2 - (helper layer 3)
4. Create the final image based on the results of helper layer 1 (unpacked Azul java) and helper layer 3 (distroless base)
5. Make sure the default user of the image is not a root user. (UID 1001)

## Important to know:

The image has a predefined entrypoint which is important for final usage:

`ENTRYPOINT [ "/usr/bin/java" ]`

The default user of this image has the UID `1001`.

## How to use:

Simplest scenario is to create an own image by using this image as a base and add the compiled Java application (.JAR) as another layer.
An example Dockerfile would look like this:

```
FROM distroless-azul-jre:latest
WORKDIR /usr/app
ADD myjava-application.jar /usr/app/myjava-application.jar
CMD [ "-jar", "/usr/app/myjava-application.jar" ]
```

An alternative is to overwrite the entrypoint like this:

`ENTRYPOINT [ "/usr/bin/java", "-jar" , "/usr/app/myjava-application.jar" ]`
