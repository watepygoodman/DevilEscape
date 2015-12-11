#if !defined __keyvalues__
  #define __keyvalues__
#else
  #endinput
#endif

new handle_num = 0;
new handle = 0;

stock kv_create(const f_name[])
{
	new szFileDir[128], f_dir[128];
	get_localinfo("amxx_configsdir", szFileDir, charsmax(szFileDir));
	formatex(f_dir, charsmax(f_dir), "%s/data", szFileDir);
	if(!dir_exists(f_dir))  mkdir(f_dir)
	formatex(f_dir, charsmax(f_dir), "%s/data/%s.ini", szFileDir, f_name);
	if(!file_exists(f_dir)) write_file(f_dir, "")
	
	new file = fopen(f_dir, "rt")
	fclose(file);
	
	handle_num ++;
	
	if(handle_num > 31)
		server_print("Error: kv handle: %d(out of limit)", handle_num);
	
	return 1 << (handle_num-1);
}

