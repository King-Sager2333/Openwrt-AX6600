#!/bin/bash
cat << 'ERROR_LOG' | grep -i "error"
2026-08-08T13:22:33.4863690Z ERROR: luci-app-athena-led-1.0-r20260610: trying to overwrite etc/config/athena_led owned by athena-led-2.4.0-r1.
2026-08-08T13:22:33.4864942Z ERROR: luci-app-athena-led-1.0-r20260610: trying to overwrite etc/init.d/athena_led owned by athena-led-2.4.0-r1.
2026-08-08T13:22:34.5181032Z 1 error; 482.1 MiB in 484 packages
2026-08-08T13:22:34.5193756Z make[2]: *** [package/Makefile:100: package/install] Error 1
2026-08-08T13:22:34.5205617Z make[2]: Leaving directory '/mnt/build_wrt'
2026-08-08T13:22:34.5249562Z make[1]: *** [package/Makefile:193: /mnt/build_wrt/staging_dir/target-aarch64_cortex-a53_musl/stamp/.package_install] Error 2
2026-08-08T13:22:34.5259072Z make[1]: Leaving directory '/mnt/build_wrt'
2026-08-08T13:22:34.5266122Z make: *** [/mnt/build_wrt/include/toplevel.mk:233: world] Error 2
2026-08-08T13:22:34.5294109Z ##[error]Process completed with exit code 2.
ERROR_LOG
