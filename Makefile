include $(AEROS_ROOT)/build/ahcommonpre.mk
AH_SQUID_VERSION=3.5.16
AH_SQUIDGUARD_VERSION=1.4
#AH_ZLIB_VERSION=1.2.8
AH_SQUID_SUBDIR=squid-$(AH_SQUID_VERSION)
AH_SQUIDGUARD_SUBDIR=squidGuard-$(AH_SQUIDGUARD_VERSION)
#AH_PCRE_ZIP=$(AH_PCRE_SUBDIR).tar.gz
#AH_ZLIB_SUBDIR=zlib-$(AH_ZLIB_VERSION)
AH_SRC_SQUID_DIR=$(CURDIR)/$(AH_SQUID_SUBDIR)
AH_BUILD_SQUID_DIR=$(AH_CURRENT_BUILD_PATH)/$(AH_SQUID_SUBDIR)
echo "AH_BUILD_SQUID_DIR=$AH_BUILD_SQUID_DIR"
AH_EXPORT_LDFLAGS += -lah_event -lah -lah_mpi -lah_sys -lpthread -lah_top -lah_tpa -lgdbm -lah_db -lah_rmc_db -lah_dcd -lah_cli
ifeq ($(AH_SUPPORT_SWITCH), yes)
AH_EXPORT_LDFLAGS += -lah_hw -lah_swd 
endif
DEPDIRS = $(AEROS_ROOT)/app/openssl 
ifeq ($(AH_SUPPORT_HOSTAPD_072), yes)
DEPDIRS += $(AEROS_ROOT)/app/auth2/libs/rmc_lib
else
DEPDIRS += $(AEROS_ROOT)/app/auth/rmc_lib
endif
define CfgSquid
		echo "AH_EXPORT_LDFLAGS=$(AH_EXPORT_LDFLAGS)"
        if [ ! -f $(AH_BUILD_SQUID_DIR)/Makefile ]; then \
                cd $(AH_BUILD_SQUID_DIR) && lndir -silent $(AH_SRC_SQUID_DIR); \
                ./configure \
				--target=$(AH_CFG_TARGET) \
				--build=x86_64-unknown-linux-gnu --host=$(AH_CFG_TARGET) \
				--cache-file=squid_cache \
		        --with-cc-opt="-I$(AEROS_ROOT)/include/share \
                                  -I$(AEROS_ROOT)/include/user \
                                  -I$(AEROS_ROOT)/include/boot \
				  				  -I$(AH_BUILD_TREE_ROOT)/include/boot \
                                  -I$(AH_BUILD_TREE_ROOT)/include/share \
                                  -I$(AH_BUILD_TREE_ROOT)/include/user" ; \
        fi;
endef

header:
ifneq ($(DEPDIRS),)
	@$(MkDepDirs)
endif
	@$(InitAhInst)
	@$(AH_MKDIR) $(AH_BUILD_SQUID_DIR)
	#$(AH_CP) -rf $(AH_SQUID_SUBDIR)/* $(AH_BUILD_SQUID_DIR)/
	#$(AH_CP) -rpf $(AH_SQUIDGUARD_SUBDIR)/ $(AH_CURRENT_BUILD_PATH)/$(AH_SQUIDGUARD_SUBDIR)/
	#$(AH_CP) -rf $(AH_ZLIB_SUBDIR)/ $(AH_CURRENT_BUILD_PATH)/$(AH_ZLIB_SUBDIR)/
	$(CfgSquid)
	$(AH_MAKE) -C $(AH_BUILD_SQUID_DIR)
	$(AH_MAKE) -C $(AH_BUILD_SQUID_DIR) DESTDIR=$(AH_ROOTFS_DIR)/squid install
	$(AH_MKDIR) $(AH_ROOTFS_DIR)/opt/ah/bin
	$(AH_MKDIR) $(AH_ROOTFS_DIR)/usr/local/squid
	$(AH_MV) $(AH_ROOTFS_DIR)/squid/usr/local/squid/sbin/squid $(AH_ROOTFS_DIR)/opt/ah/bin/ah_squid
	$(AH_CP) -rf $(AH_ROOTFS_DIR)/squid/usr/local/squid/var/ $(AH_ROOTFS_DIR)/usr/local/
	#$(AH_MV) $(AH_ROOTFS_DIR)/nginx/var/log/ $(AH_ROOTFS_DIR)/var/log/nginx/
	$(AH_TARGET_STRIP) $(AH_ROOTFS_DIR)/opt/ah/bin/ah_squid
	$(AH_RMDIR) $(AH_ROOTFS_DIR)/squid
lib:

bin:

kmod: 

install:
	$(AH_MAKE) -C $(AH_BUILD_SQUID_DIR) DESTDIR=$(AH_ROOTFS_DIR)/squid install
	$(AH_MKDIR) $(AH_ROOTFS_DIR)/opt/ah/bin
	$(AH_MKDIR) $(AH_ROOTFS_DIR)/usr/local/squid
	$(AH_MV) $(AH_ROOTFS_DIR)/squid/usr/local/squid/sbin/squid $(AH_ROOTFS_DIR)/opt/ah/bin/ah_squid
	$(AH_CP) -rfp $(AH_ROOTFS_DIR)/squid/usr/local/squid/var/ $(AH_ROOTFS_DIR)/usr/local/squid/
	#$(AH_MV) $(AH_ROOTFS_DIR)/nginx/var/log/ $(AH_ROOTFS_DIR)/var/log/nginx/
	#$(AH_MV) $(AH_ROOTFS_DIR)/nginx/var/log/ $(AH_ROOTFS_DIR)/var/log/nginx/
	$(AH_TARGET_STRIP) $(AH_ROOTFS_DIR)/opt/ah/bin/ah_squid
	$(AH_RMDIR) $(AH_ROOTFS_DIR)/squid
clean:
	if [ -f $(AH_BUILD_SQUID_DIR)/Makefile ]; then \
		$(AH_MAKE) -C $(AH_BUILD_SQUID_DIR) clean; \
	fi;
instclean:
	@$(CleanAhInst)

.PHONY: header lib bin install clean instclean
