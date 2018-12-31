ifeq ($(PREFIX),)
	PREFIX := /usr/local
endif

ifeq ($(SYSTEMD_PREFIX),)
	SYSTEMD_PREFIX := /etc/systemd
endif

install:
	install -d $(PREFIX)/share/prison-guard
	install -m 755 add_tun_route.sh $(PREFIX)/share/prison-guard/add_tun_route.sh
	install -m 755 del_tun_route.sh $(PREFIX)/share/prison-guard/del_tun_route.sh
	install -m 755 scripts/interface-setup.sh $(PREFIX)/share/prison-guard/interface-setup.sh

	install -m 644 prisonguard.target $(SYSTEMD_PREFIX)/system/prisonguard.target
	install -m 644 prison-ns.service $(SYSTEMD_PREFIX)/system/prison-ns.service
	install -m 644 guard-ns.service $(SYSTEMD_PREFIX)/system/guard-ns.service
	install -m 644 prisonguard-interface.service $(SYSTEMD_PREFIX)/system/prisonguard-interface.service
	install -m 644 prisonguard-openvpn@.service $(SYSTEMD_PREFIX)/system/prisonguard-openvpn@.service
