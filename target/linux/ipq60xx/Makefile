include $(TOPDIR)/rules.mk

ARCH:=aarch64
BOARD:=ipq60xx
BOARDNAME:=Qualcomm Atheros IPQ60xx
FEATURES:=squashfs ramdisk fpu nand rtc emmc
KERNELNAME:=Image dtbs
CPU_TYPE:=cortex-a53
SUBTARGETS:=generic

KERNEL_PATCHVER:=5.15
KERNEL_TESTING_PATCHVER:=6.1

include $(INCLUDE_DIR)/target.mk
DEFAULT_PACKAGES += \
	kmod-leds-gpio kmod-gpio-button-hotplug \
	libwolfsslcpu-crypto kmod-qca-nss-dp \
	ath11k-firmware-ipq6018 kmod-ath11k-ahb \
	wpad-basic-wolfssl uboot-envtools

$(eval $(call BuildTarget))
