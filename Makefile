all: rr mesademos

.PHONY: rr util jpeg mesademos clean

rr: util jpeg

rr util jpeg mesademos:
	cd $@; $(MAKE); cd ..

clean:
	cd rr; $(MAKE) clean; cd ..; \
	cd util; $(MAKE) clean; cd ..; \
	cd jpeg; $(MAKE) clean; cd ..; \
	cd mesademos; $(MAKE) clean; cd ..

TOPDIR=.
include Makerules

##########################################################################
ifeq ($(platform), windows)
##########################################################################

dist: rr
	$(RM) $(EDIR)/$(APPNAME).zip
	zip $(EDIR)/$(APPNAME).zip -j \
		$(EDIR)/rrxclient.exe \
		$(EDIR)/hpjpeg.dll \
		rr/newrrcert.bat \
		rr/rrcert.cnf \
		$(EDIR)/openssl.exe \
		$(EDIR)/pthreadVC.dll

##########################################################################
else
##########################################################################

ifeq ($(subplatform),)
RPMARCH = i386
else
RPMARCH = $(ARCH)
endif

ifeq ($(prefix),)
prefix=/usr/local
endif

RRLAUNCH = rrlaunch
PACKAGENAME = $(APPNAME)
ifeq ($(subplatform), 64)
RRLAUNCH = rrlaunch64
PACKAGENAME = $(APPNAME)64
endif

install: rr
	install -m 755 rr/rrxclient.sh /etc/rc.d/init.d/rrxclient
	install -m 644 rr/rrcert.cnf /etc/rrcert.cnf
	install -m 755 rr/newrrcert $(prefix)/bin/newrrcert
	install -m 755 $(EDIR)/$(RRLAUNCH) $(prefix)/bin/$(RRLAUNCH)
	install -m 755 $(EDIR)/rrxclient $(prefix)/bin/rrxclient
	install -m 755 $(LDIR)/libhpjpeg.so $(prefix)/lib/libhpjpeg.so
	install -m 755 $(LDIR)/librrfaker.so $(prefix)/lib/librrfaker.so
	echo Install complete.

uninstall:
	/etc/rc.d/init.d/rrxclient stop
	chkconfig --del rrxclient
	$(RM) /etc/rc.d/init.d/rrxclient
	$(RM) $(prefix)/bin/newrrcert
	$(RM) $(prefix)/bin/$(RRLAUNCH)
	$(RM) $(prefix)/bin/rrxclient
	$(RM) $(prefix)/lib/libhpjpeg.so
	$(RM) $(prefix)/lib/librrfaker.so
	echo Uninstall complete.

dist: rr rpms/BUILD rpms/RPMS
	rm $(EDIR)/$(PACKAGENAME).$(RPMARCH).rpm; \
	rpmbuild -bb --define "_curdir `pwd`" --define "_topdir `pwd`/rpms" \
		--define "_majver $(MAJVER)" --define "_minver $(MINVER)" --define "_bindir $(EDIR)" \
		--define "_libdir $(LDIR)" --define "_appname $(APPNAME)" --target $(RPMARCH) \
		rr.spec; \
	mv rpms/RPMS/$(RPMARCH)/$(PACKAGENAME)-$(MAJVER)-$(MINVER).$(RPMARCH).rpm $(PACKAGENAME).$(RPMARCH).rpm

rpms/BUILD:
	mkdir -p rpms/BUILD

rpms/RPMS:
	mkdir -p rpms/RPMS

##########################################################################
endif
##########################################################################
