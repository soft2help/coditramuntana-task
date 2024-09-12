Setting.set("api", "realm", "Public Api Token")

# if you repeat ip in both settings block is prioritary

Setting.set("api", "throttling_ip_block_list", ["192.168.1.1"])
Setting.set("api", "throttling_ip_allow_list", ["127.0.0.1", "::1"])

Setting.set("api", "threshold_block_on_firewall", 200)
