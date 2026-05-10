grep -qe '[\s\t]*CREATE_MAIL_SPOOL=' /etc/default/useradd && \
	sed -i -e '/CREATE_MAIL_SPOOL/s/^/#/' -e '$ a\CREATE_MAIL_SPOOL=no' /etc/default/useradd

