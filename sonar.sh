#!/usr/bin/env bash
"mvn sonar:sonar     -Dsonar.host.url=https://sonarcloud.io     -Dsonar.organization=sillelien     -Dsonar.login=${SONAR_KEY}"
