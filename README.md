# Requirements

* jq
* Docker
* [zap2docker-stable](https://hub.docker.com/r/owasp/zap2docker-stable/)

# Setup 

## Give jenkins permission to use docker
```sudo usermod -a -G docker jenkins```

# Usage

from jenkins shell, call ```run-docker.sh```

Flags:

| Flag | Optional | Description | Default |
| ----------- | ----------- | ----------- | ----------- |
| t | N | Target URL | None |
| r | Y | Output report name (found in pwd/report/) | report.html |
| n | Y | Number of alerts to cause failure. | 0 |
| a | Y | Alert level (High|Medium|Low) | Medium |
| h | Y | Show  help | |

# TODO

- [x] Make configurable
- [] Check requirements are present before running script
- [] Don't rm the container every time