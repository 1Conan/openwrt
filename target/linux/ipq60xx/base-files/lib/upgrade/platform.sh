PART_NAME=firmware
REQUIRE_IMAGE_METADATA=1

RAMFS_COPY_BIN='fw_printenv fw_setenv'
RAMFS_COPY_DATA='/etc/fw_env.config /var/lock/fw_printenv.lock'

remove_oem_ubi_volume() {
	local oem_volume_name="$1"
	local oem_ubivol
	local mtdnum
	local ubidev

	mtdnum=$(find_mtd_index "$CI_UBIPART")
	if [ ! "$mtdnum" ]; then
		return
	fi

	ubidev=$(nand_find_ubi "$CI_UBIPART")
	if [ ! "$ubidev" ]; then
		ubiattach --mtdn="$mtdnum"
		ubidev=$(nand_find_ubi "$CI_UBIPART")
	fi

	if [ "$ubidev" ]; then
		oem_ubivol=$(nand_find_volume "$ubidev" "$oem_volume_name")
		[ "$oem_ubivol" ] && ubirmvol "/dev/$ubidev" --name="$oem_volume_name"
	fi
}

linksys_get_boot_part() {
	local cur_boot_part
	local args

	# Try to find rootfs from kernel arguments
	read -r args < /proc/cmdline
	for arg in $args; do
		local ubi_mtd_arg=${arg#ubi.mtd=}
		case "$ubi_mtd_arg" in
		rootfs|alt_rootfs)
			echo "$ubi_mtd_arg"
			return
		;;
		esac
	done

	# Fallback to u-boot env (e.g. when running sysfs)
	cur_boot_part="$(/usr/sbin/fw_printenv -n boot_part)"
	case $cur_boot_part in
	1)
		echo rootfs
		;;
	2|*)
		echo alt_rootfs
		;;
	esac
}

linksys_do_upgrade() {
	local new_boot_part

	case $(linksys_get_boot_part) in
	rootfs)
		CI_UBIPART="alt_rootfs"
		CI_KERNPART="alt_kernel"
		new_boot_part=2
	;;
	alt_rootfs)
		CI_UBIPART="rootfs"
		CI_KERNPART="kernel"
		new_boot_part=1
	;;
	esac
	echo "Updating mtd=$CI_UBIPART, boot_part=$new_boot_part"

	fw_setenv -s - <<-EOF
		boot_part $new_boot_part
		auto_recovery yes
	EOF

	remove_oem_ubi_volume squashfs
	nand_do_upgrade "$1"
}

tplink_get_boot_part() {
	local cur_boot_part
	local args

	# Try to find rootfs from kernel arguments
	read -r args < /proc/cmdline
	for arg in $args; do
		local ubi_mtd_arg=${arg#ubi.mtd=}
		case "$ubi_mtd_arg" in
		rootfs|rootfs_1)
			echo "$ubi_mtd_arg"
			return
		;;
		esac
	done

	# Fallback to u-boot env (e.g. when running initramfs)
	cur_boot_part="$(/usr/sbin/fw_printenv -n tp_boot_idx)"
	case $cur_boot_part in
	1)
		echo rootfs_1
		;;
	0|*)
		echo rootfs
		;;
	esac
}

tplink_do_upgrade() {
	local new_boot_part

	case $(tplink_get_boot_part) in
	rootfs)
		CI_UBIPART="rootfs_1"
		new_boot_part=1
	;;
	rootfs_1)
		CI_UBIPART="rootfs"
		new_boot_part=0
	;;
	esac

	fw_setenv -s - <<-EOF
		tp_boot_idx $new_boot_part
	EOF

	remove_oem_ubi_volume ubi_rootfs
	nand_do_upgrade "$1"
}

platform_check_image() {
	# ath11k has a TX queue flush issue, so until that is resolved
	# lets workaround the issue by calling wpad stop before sysupgrade
	# attempts to first SIGTERM and then SIGKILL hostapd which will fail
	# as ath11k TX flush has not yet timed out.
	# This in turn would cause sysupgrade to fail and leave old version on
	# the boards.
	service wpad stop
	return 0;
}

platform_do_upgrade() {
	case "$(board_name)" in
	linksys,mr7350)
		linksys_do_upgrade "$1"
		;;
	*)
		default_do_upgrade "$1"
		;;
	esac
}
