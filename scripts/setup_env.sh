#!/bin/bash

# TBD: honor system pre-defined property/variable files from 
# /etc/hadoop/ and other /etc config for spark, hdfs, hadoop, etc

if [ "x${JAVA_HOME}" = "x" ] ; then
  export JAVA_HOME=/usr/java/default
fi
if [ "x${ANT_HOME}" = "x" ] ; then
  export ANT_HOME=/opt/apache-ant
fi
if [ "x${MAVEN_HOME}" = "x" ] ; then
  export MAVEN_HOME=/opt/apache-maven
fi
if [ "x${M2_HOME}" = "x" ] ; then
  export M2_HOME=/opt/apache-maven
fi
if [ "x${M2}" = "x" ] ; then
  export M2=${M2_HOME}/bin
fi
if [ "x${MAVEN_OPTS}" = "x" ] ; then
  export MAVEN_OPTS="-Xmx2048m -XX:MaxPermSize=1024m"
fi
if [ "x${SCALA_HOME}" = "x" ] ; then
  export SCALA_HOME=/opt/scala
fi

export PATH=$PATH:$M2_HOME/bin:$SCALA_HOME/bin:$ANT_HOME/bin:$JAVA_HOME/bin

if [ "x${LLVM_VERSION}" = "x" ] ; then
  export LLVM_VERSION=3.3
fi




