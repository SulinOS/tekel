all: setperm install
setperm:
	chmod  +x api/*
	chmod  +x cli/*
install:
	mkdir -p $(DESTDIR)/usr/libexec/tekel/api
	mkdir -p $(DESTDIR)/usr/libexec/tekel/cli
	install tekel.sh $(DESTDIR)/usr/bin/tekel
	cp -prfv api/* $(DESTDIR)/usr/libexec/tekel/api/
	cp -prfv cli/* $(DESTDIR)/usr/libexec/tekel/cli/
