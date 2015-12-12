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
#include <bitset>

#define PLUGIN_NAME "DevilEscape"
#define PLUGIN_VERSION "0.0"
#define PLUGIN_AUTHOR "w&a"

new const g_fog_color[] = "128 128 128"
new const g_fog_denisty[] = "0.002"

new test = 0;

public plugin_precache()
{
	//Fog
	fm_create_fog()
	//Rain
	engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_rain"))
}

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	register_dictionary("bossvshuman.txt");
	
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0");
	
	register_logevent("logevent_round_end", 2, "1=Round_End");
	
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage");
}

public event_round_start()
{
	//Light
	engfunc(EngFunc_LightStyle, 0, 'h')
}

fm_create_fog()
{
	static ent 
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_fog"))
	if (pev_valid(ent))
	{
		fm_set_kvd(ent, "density", g_fog_denisty, "env_fog")
		fm_set_kvd(ent, "rendercolor", g_fog_color, "env_fog")
	}
}

stock fm_set_kvd(entity, const key[], const value[], const classname[])
{
	set_kvd(0, KV_ClassName, classname)
	set_kvd(0, KV_KeyName, key)
	set_kvd(0, KV_Value, value)
	set_kvd(0, KV_fHandled, 0)

	dllfunc(DLLFunc_KeyValue, entity, 0)
}