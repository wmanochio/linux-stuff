The script lacks verification for the existence of paths and commands issued. Make adjustments as needed for your linux.

Testing done for old versions (green web user interface) of TP-Link Archer C7.

It will probably work with others TP-Link that uses the same green web ui.

The green interface:
https://emulator.tp-link.com/Archer%20C7_2.0/Index.htm

![green web ui](https://github.com/wmanochio/linux-stuff/blob/23ecc41df646b93194f935d3b1c28d19f641780b/reboot%20tp-link%20archer%20c7/green-web-ui.jpg)

output sample:
```
tplink_router_user                    : username
tplink_router_pass_md5                : e5acd34333e3dae3c772d1dbaf23c92c
tplink_router_base64_user_passmd5     : ZTVhY2QzNDMzM2UzZGFlM2M3NzJkMWRiYWYyM2M5MmM=
tplink_router_cookie_content_for_send : Authorization=Basic%ZTVhY2QzNDMzM2UzZGFlM2M3NzJkMWRiYWYyM2M5MmM%3D

# Trying to connect : http://192.168.x.x/
# Requesting  login : http://192.168.x.x/userRpm/LoginRpm.htm?Save=Save
# URL's dynamic key : ABCDEFGHIJKLMNOP
# Requesting reboot : http://192.168.x.x/ABCDEFGHIJKLMNOP/userRpm/SysRebootRpm.htm?Reboot=Reboot
- Device is restarting... Good bye =)
```

cron job (`crontab -e`) every day @ 4:10am
```
10 4 * * * /root/zscript/reboot-archer-c7.sh > /root/zscript/log/reboot-archer-c7.log 2>&1
```
