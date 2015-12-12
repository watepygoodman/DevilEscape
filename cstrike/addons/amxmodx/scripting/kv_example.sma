
	new szFileDir[128]
	get_localinfo("amxx_configsdir", szFileDir, charsmax(szFileDir));
	formatex(szFileDir, charsmax(szFileDir), "%s/data/test.ini", szFileDir)
	new kv = kv_create("test")
	server_print("aa:%s", kv)
	kv_set_string(kv, "test", "test")
	kv_save_to_file(kv, szFileDir)
	kv_delete(kv);