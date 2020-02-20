all: setperm install
setperm:
	chmod  +x api/*
	chmod  +x cli/*
install:
	mkdir -p $(DESTDIR)/usr/libexec/bakkal/api
	mkdir -p $(DESTDIR)/usr/libexec/bakkal/cli
	install bakkal.sh $(DESTDIR)/usr/bin/bakkal
	cp -prfv api/* $(DESTDIR)/usr/libexec/bakkal/api/
	cp -prfv cli/* $(DESTDIR)/usr/libexec/bakkal/cli/
