#!/usr/bin/env bash
git config --global user.email "hello@neilellis.me"
git config --global user.name "Neil Ellis"
mvn versions:set -DnewVersion=$(cat .release)
mvn versions:resolve-ranges
mvn versions:lock-snapshots
mvn -T 1C -Dmaven.test.skip=true -Drat.skip=true -DskipEnforcer -Dmaven.javadoc.skip=true -DgenerateReports=false package
mvn -T 2C -Dorg.xml.sax.driver=com.sun.org.apache.xerces.internal.parsers.SAXParser -Dmaven.test.skip=true -Drat.skip=true -DskipEnforcer -Dmaven.javadoc.skip=true -DgenerateReports=false deploy
