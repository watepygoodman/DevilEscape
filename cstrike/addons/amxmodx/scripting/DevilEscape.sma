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

/* ==================
	
				 常量

================== */
enum
{
	FM_CS_TEAM_UNASSIGNED = 0,
	FM_CS_TEAM_T,
	FM_CS_TEAM_CT,
	FM_CS_TEAM_SPECTATOR
}

new const InvalidChars[]= { "/", "\", "*", ":", "?", "^"", "<", ">", "|", " " }
new const g_fog_color[] = "128 128 128";
new const g_fog_denisty[] = "0.002";

/* ================== 

				变量
				
================== */
new g_savesDir[128];
new g_isRegister = 0;
new g_isLogin = 0;


public plugin_precache()
{
	//天气
	gm_create_fog();
	engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_rain"));
	get_localinfo("amxx_configsdir", g_savesDir, charsmax(g_savesDir));
	formatex(g_savesDir, charsmax(g_savesDir), "%s/saves", g_savesDir)
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

//进入服务器
public client_putinserver(id)
{
	delete_bit(g_isRegister, id-1)
	delete_bit(g_isLogin, id-1)
	gm_user_load(id)
}

//回合开始
public event_round_start()
{
	//Light
	engfunc(EngFunc_LightStyle, 0, 'h')
}

public logevent_round_end()
{
	
}

public fw_PlayerSpawn_Post(id)
{
	
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	
}


//客户端命令
public fw_ClientCommand(id)
{
	new szCommand[24], szText[32];
	read_argv(0, szCommand, charsmax(szCommand));
	read_argv(1, szText, charsmax(szText));
	
	if(!get_bit(g_isLogin, id-1))
	{
		if(!strcmp(szCommand, "say"))
		{
			//注册与登录
			if(!get_bit(g_isRegister, id-1))
				gm_user_register(id, szText);
			else
				gm_user_login(id, szText);
			return FMRES_SUPERCEDE;
		}
		return FMRES_IGNORED;
	}
	
	//Chooseteam
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
	
	return FMRES_IGNORED;
}
/* =====================

			 Game
			 
===================== */

gm_user_register(id, const password[])
{
	new pw_len = strlen(password)
	if( pw_len > 12 || pw_len < 6)
	{
		client_color_print(id, "^x04错误:您的密码过长或过短");
		return;
	}
	
	for(new i = 0; i < pw_len; i ++)
	{
		for(new j = 0; i < charsmax(InvalidChars); i++)
		{
			if( password[i] == InvalidChars[j])
			{
				client_color_print(id, "^x04错误:您的密码含有非法字符");
				return;
			}
		}
	}
	
	client_color_print(id, "^x04注册成功,你的密码是:%s", password)
	client_color_print(id, "^x04注册成功,你的密码是:%s", password)
	set_bit(g_isRegister, id-1)
	
	//储存密码
	new szFileDir[128], szUserName[32];
	get_user_name(id, szUserName, charsmax(szUserName))
	formatex(szFileDir, charsmax(szFileDir), "%s/%s.ini", g_savesDir, szUserName)
	
	new kv = kv_create(szUserName)
	kv_set_string(kv, "password", password);
	
	kv_save_to_file(kv, szFileDir);
	kv_delete(kv);
	
}

gm_user_login(id, const password[])
{
	new szUserName[32], szFileDir[128]
	get_user_name(id, szUserName, charsmax(szUserName))
	formatex(szFileDir, charsmax(szFileDir), "%s/%s.ini", g_savesDir, szUserName)
	new kv = kv_create();
	kv_load_from_file(kv, szFileDir)
	
	new save_pw[12]
	kv_find_key(kv, szUserName)
	kv_get_string(kv, "password", save_pw, charsmax(save_pw))
	
	if(equal(save_pw, password))
	{
		client_color_print(id, "^x04登录成功, %s 欢迎回来", szUserName)
		set_bit(g_isLogin, id-1)
	}
	else
		client_color_print(id, "^x04登录失败,密码错误")
}

gm_user_load(id)
{
	new szUserName[32], szFileDir[128]
	get_user_name(id, szUserName, charsmax(szUserName))
	formatex(szFileDir, charsmax(szFileDir), "%s/%s.ini", g_savesDir, szUserName)
	new kv = kv_create();
	kv_load_from_file(kv, szFileDir)
	kv_find_key(kv, szUserName)
	
	if(kv_is_empty(kv))
		return
	
	//检测是否注册
	set_bit(g_isRegister, id-1)
}

gm_create_fog()
{
	static ent 
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_fog"))
	if (pev_valid(ent))
	{
		fm_set_kvd(ent, "density", g_fog_denisty, "env_fog")
		fm_set_kvd(ent, "rendercolor", g_fog_color, "env_fog")
	}
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

/* =====================

			 Other
			 
===================== */

stock client_color_print(target, const message[], any:...)
{
	static buffer[512], i, argscount
	argscount = numargs()
	// 发送给所有人
	if (!target)
	{
		static player
		for (player = 1; player <= get_maxplayers(); player++)
		{
			// 断线
			// if (!g_isconnect[player])
				// continue;
			
			// 记住变化的变量
			static changed[5], changedcount // [5] = max LANG_PLAYER occurencies
			changedcount = 0
			
			// 将player id 取代LANG_PLAYER
			for (i = 2; i < argscount; i++)
			{
				if (getarg(i) == LANG_PLAYER)
				{
					setarg(i, 0, player)
					changed[changedcount] = i
					changedcount++
				}
			}
			
			// Format信息给玩家
			vformat(buffer, charsmax(buffer), message, 3)
			
			// 发送信息
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, player)
			write_byte(player)
			write_string(buffer)
			message_end()
			
			// 将back player id 取代LANG_PLAYER
			for (i = 0; i < changedcount; i++)
				setarg(changed[i], 0, LANG_PLAYER)
		}
	}
	// 发送给指定目标
	else
	{
		vformat(buffer, charsmax(buffer), message, 3)
		message_begin(MSG_ONE, get_user_msgid("SayText"), _, target)
		write_byte(target)
		write_string(buffer)
		message_end()
	}
}
