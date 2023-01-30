define Device/FitImage
	KERNEL_SUFFIX := -fit-uImage.itb
	KERNEL = kernel-bin | gzip | fit gzip $$(KDIR)/image-$$(DEVICE_DTS).dtb
	KERNEL_NAME := Image
endef

define Device/FitImageLzma
	KERNEL_SUFFIX := -fit-uImage.itb
	KERNEL = kernel-bin | lzma | fit lzma $$(KDIR)/image-$$(DEVICE_DTS).dtb
	KERNEL_NAME := Image
endef

define Device/FitzImage
	KERNEL_SUFFIX := -fit-zImage.itb
	KERNEL = kernel-bin | fit none $$(KDIR)/image-$$(DEVICE_DTS).dtb
	KERNEL_NAME := zImage
endef

define Device/UbiFit
	KERNEL_IN_UBI := 1
	IMAGES := nand-factory.ubi nand-sysupgrade.bin
	IMAGE/nand-factory.ubi := append-ubi
	IMAGE/nand-sysupgrade.bin := sysupgrade-tar | append-metadata
endef

define Device/cp01-c1
	$(call Device/FitImage)
	DEVICE_VENDOR := Test
	DEVICE_MODEL := C3PO
	SOC := ipq6018
endef
TARGET_DEVICES += cp01-c1

define Device/eap610-outdoor
	$(call Device/FitImage)
	DEVICE_VENDOR := TP-Link
	DEVICE_MODEL := EAP610-Outdoor
	SOC := ipq6018
endef
TARGET_DEVICES += eap610-outdoor

define Device/glinet_gl-ax1800
	$(call Device/FitImage)
	$(call Device/UbiFit)
	DEVICE_VENDOR := GL-iNet
	DEVICE_MODEL := GL-AX1800
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	DEVICE_DTS_CONFIG := config@cp03-c1
	SOC := ipq6018
	IMAGE/nand-factory.ubi := append-ubi | qsdk-ipq-factory-nand
	DEVICE_PACKAGES := ipq-wifi-glinet_gl-ax1800
endef
TARGET_DEVICES += glinet_gl-ax1800

define Device/linksys_mr7350
	$(call Device/FitImage)
	$(call Device/UbiFit)
	DEVICE_VENDOR := Linksys
	DEVICE_MODEL := MR7350
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	SOC := ipq6018
	DEVICE_PACKAGES := kmod-leds-pca963x \
		kmod-usb3 kmod-usb-dwc3 kmod-usb-dwc3-qcom \
		ipq-wifi-linksys_mr7350
endef
TARGET_DEVICES += linksys_mr7350

define Device/netgear_sxk30
	$(call Device/FitImage)
	$(call Device/UbiFit)
	DEVICE_VENDOR := Netgear
	DEVICE_MODEL := SXK30
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	DEVICE_DTS_CONFIG := config@cp03-c1
	SOC := ipq6018
	DEVICE_PACKAGES := ipq-wifi-netgear_sxk30
endef
TARGET_DEVICES += netgear_sxk30

define Device/netgear_wax610
	$(call Device/FitImage)
	$(call Device/UbiFit)
	DEVICE_VENDOR := Netgear
	DEVICE_MODEL := WAX610
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	DEVICE_DTS_CONFIG := config@cp03-c1
	SOC := ipq6018
	DEVICE_PACKAGES := ipq-wifi-netgear_wax610
endef
TARGET_DEVICES += netgear_wax610
