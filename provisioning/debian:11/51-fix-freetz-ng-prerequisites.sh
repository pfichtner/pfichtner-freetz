# .prerequisites: program     xml2-config            FREETZ_PACKAGE_GNTPSEND FREETZ_PACKAGE_ASTERISK
# program     javac                  FREETZ_PACKAGE_CLASSPATH
# ecj depends on java-wrappers but ths dependency is missing in ecj, https://salsa.debian.org/java-team/ecj/-/commit/f7d6cae26fbde9b146d02affe08da534f801a0f7
apt-get -y install libxml2-dev java-wrappers

