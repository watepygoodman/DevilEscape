/*=============================================================
	
	DevilEscape mode
		For Counter-Strike 1.6
		
	Coding by watepy	in 15/12/7
	
log:
	15/12/7 : start coding
	
=============================================================*/

#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <dhudmessage>
#include <keyvalues>

#define PLUGIN_NAME "DevilEscape"
#define PLUGIN_VERSION "0.0"
#define PLUGIN_AUTHOR "w&a"

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0");
}

public event_round_start()
{
	//test
	new szFileDir[128]
	get_localinfo("amxx_configsdir", szFileDir, charsmax(szFileDir));
	formatex(szFileDir, charsmax(szFileDir), "%s/data/test.ini", szFileDir)
	new kv = kv_create("test")
	server_print("aa:%s", kv)
	kv_set_string(kv, "test", "test")
	kv_save_to_file(kv, szFileDir)
	kv_delete(kv);
}