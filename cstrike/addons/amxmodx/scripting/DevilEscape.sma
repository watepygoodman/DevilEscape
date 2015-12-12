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

//====参数=====
new const g_fog_color[] = "128 128 128";
new const g_fog_denisty[] = "0.002";

//====变量====
new g_isRegister;
new g_isLogin;

public plugin_precache()
{
	//天气
	game_create_fog();
	engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_rain"));
}

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	register_dictionary("devilescape.txt");
	
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0");
	
	register_logevent("logevent_round_end", 2, "1=Round_End");
	
	register_forward(FM_ClientCommand, "fw_ClientCommand") ;
	
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage");
	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1);
	
	
}

//回合开始
public event_round_start()
{
	//Light
	engfunc(EngFunc_LightStyle, 0, 'h')
}

//客户端命令
public fw_ClientCommand(id)
{
	new szCommand[24], szText[32]
	read_argv(0, szCommand, charsmax(szCommand))
	read_argv(1, szText, charsmax(szText))
	
	if(!strcmp(szCommand, "chooseteam") || !strcmp(szCommand, "jointeam")) 
	{ 
		new team
		team = fm_cs_get_user_team(id)
	
		// 当此人为观察者可以换队
		if (team == FM_CS_TEAM_SPECTATOR || team == FM_CS_TEAM_UNASSIGNED)
			return FMRES_IGNORED;
		
		//show_menu_main(id)
		return FMRES_SUPERCEDE;
	} 
}
/* =====================

			 Game
			 
===================== */
game_create_fog()
{
	static ent 
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_fog"))
	if (pev_valid(ent))
	{
		fm_set_kvd(ent, "density", g_fog_denisty, "env_fog")
		fm_set_kvd(ent, "rendercolor", g_fog_color, "env_fog")
	}
}

game_user_register(id, const password[])
{
	
}

/* =====================

			 Getter
			 
===================== */
stock fm_cs_get_user_team(id)
{
	return get_pdata_int(id, 114);
}

stock fm_cs_set_user_team(id, team)
{
	set_pdata_int(id, 114, team)
	fm_cs_set_user_team_msg(id)
}

/* =====================

			 Setter
			 
===================== */

stock fm_cs_set_user_team_msg(id)
{
	new const team_names[][] = { "UNASSIGNED", "TERRORIST", "CT", "SPECTATOR" }
	message_begin(MSG_ALL, get_user_msgid("TeamInfo"))
	write_byte(id) // player
	write_string(team_names[fm_cs_get_user_team(id)]) // team
	message_end()
}

/* =====================

			 Entity
			 
===================== */

stock fm_set_kvd(entity, const key[], const value[], const classname[])
{
	set_kvd(0, KV_ClassName, classname)
	set_kvd(0, KV_KeyName, key)
	set_kvd(0, KV_Value, value)
	set_kvd(0, KV_fHandled, 0)

	dllfunc(DLLFunc_KeyValue, entity, 0)
}