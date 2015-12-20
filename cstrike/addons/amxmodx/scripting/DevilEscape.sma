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

#define Game_Description "魔王 1.0"

/* ==================
	
				 常量

================== */
#define bit_id (id-1)

enum
{
	FM_CS_TEAM_UNASSIGNED = 0,
	FM_CS_TEAM_T,
	FM_CS_TEAM_CT,
	FM_CS_TEAM_SPECTATOR
}

enum(+=100)
{
	TASK_BOTHAM = 100, TASK_USERLOGIN, TASK_PWCHANGE,
	TASK_ROUNDSTART, TASK_BALANCE
}

//offset
const m_CsTeam = 114 				//队伍
const m_MapZone = 235				//所在区域
const m_ModelIndex = 491 				//模型索引

new const InvalidChars[]= { "/", "\", "*", ":", "?", "^"", "<", ">", "|", " " }
new const g_fog_color[] = "128 128 128";
new const g_fog_denisty[] = "0.002";

new const g_RemoveEnt[][] = {
	"func_hostage_rescue", "info_hostage_rescue", "func_bomb_target", "info_bomb_target",
	"hostage_entity", "info_vip_start", "func_vip_safetyzone", "func_escapezone"
}

new const mdl_player_devil1[] = "models/player/devil1/devil1.mdl"

new const mdl_v_devil1[] = "models/v_devil_hand1.mdl"

new const snd_human_win[] = "DevilEscape/Human_Win.wav"
new const snd_devil_win[] = "DevilEscape/Devil_Win.wav"

/* ================== 

				Vars
				
================== */

//Cvar
new cvar_LoginTime, cvar_DevilHea;

//Game
new g_isRegister;
new g_isLogin;
new g_isConnect;
new g_isChangingPW;
new g_isModeled;

new g_whoBoss;
new g_MaxPlayer;
new g_LoginTime[33];
new g_savesDir[128];
new g_PlayerModel[33][64]

new bool:g_hasBot;

//Hud
new g_Hud_Center;

//Msg
new g_Msg_VGUI, g_Msg_ShowMenu;

//Forward Handle
new g_fwSpawn;


public plugin_precache()
{
	//天气
	gm_create_fog();
	engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_rain"));
	//Get saves' dir
	get_localinfo("amxx_configsdir", g_savesDir, charsmax(g_savesDir));
	formatex(g_savesDir, charsmax(g_savesDir), "%s/saves", g_savesDir)
	
	g_fwSpawn = register_forward(FM_Spawn, "fw_Spawn");
	
	engfunc(EngFunc_PrecacheModel, mdl_player_devil1)
	
	engfunc(EngFunc_PrecacheModel, mdl_v_devil1)
	
	engfunc(EngFunc_PrecacheSound, snd_human_win)
	engfunc(EngFunc_PrecacheSound, snd_devil_win)
	
	//Cvar
	cvar_LoginTime = register_cvar("de_logintime","120")
	cvar_DevilHea = register_cvar("de_devilhea","50000")
	
}

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	register_dictionary("devilescape.txt");
	
	//Event
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0");
	register_logevent("event_round_end", 2, "1=Round_End");
	
	//Forward
	register_forward(FM_ClientCommand, "fw_ClientCommand") ;
	register_forward(FM_ClientDisconnect, "fw_ClientDisconnect");
	register_forward(FM_SetClientKeyValue, "fw_SetClientKeyValue");
	register_forward(FM_ClientUserInfoChanged,"fw_ClientUserInfoChanged")
	register_forward(FM_GetGameDescription, "fw_GetGameDescription")
	
	//Ham
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage");
	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1);
	
	//Msg
	g_Msg_VGUI = get_user_msgid("VGUIMenu")
	g_Msg_ShowMenu = get_user_msgid("ShowMenu")
	
	register_message(g_Msg_ShowMenu, "msg_show_menu")
	register_message(g_Msg_VGUI, "msg_vgui_menu")
	register_message(get_user_msgid( "StatusIcon" ), "msg_statusicon");
	register_message(get_user_msgid("Health"), "msg_health")
	register_message(get_user_msgid("TextMsg"), "msg_textmsg")
	register_message(get_user_msgid("SendAudio"), "msg_sendaudio")
	
	//Menu
	register_menucmd(register_menuid("#Team_Select_Spect"), 51, "menu_team_select") 
	
	//Hud
	g_Hud_Center = CreateHudSyncObj();
	
	//Unregister
	unregister_forward(FM_Spawn, g_fwSpawn)
	
	//Vars
	g_MaxPlayer = get_maxplayers()
	
	server_cmd("mp_autoteambalance 0")
}

/* =====================

			  Event
			 
===================== */

//Round_Strat
public event_round_start()
{
	//Light
	engfunc(EngFunc_LightStyle, 0, 'h')
	
	set_dhudmessage( 255, 255, 255, -1.0, 0.25, 1, 6.0, 3.0, 0.1, 1.5 );
	show_dhudmessage( 0, " %L", LANG_PLAYER, "DHUD_ROUND_START" );
	
	remove_task(TASK_ROUNDSTART)
	set_task(10.0, "task_round_start", TASK_ROUNDSTART)
}

//Round_End
public event_round_end()
{
	remove_task(TASK_BALANCE)
	set_task(0.2, "task_balance", TASK_BALANCE)
}

/* =====================

			 Forward
			 
===================== */

//Entity Spawn
public fw_Spawn(entity)
{
	// Invalid entity
	if (!pev_valid(entity)) return FMRES_IGNORED;
	new classname[32]
	// Get classname
	pev(entity, pev_classname, classname, charsmax(classname))
	for(new i = 0; i < sizeof g_RemoveEnt; i ++)
	{
		if(equal(classname, g_RemoveEnt[i]))
		{
			//Remove Ent
			engfunc(EngFunc_RemoveEntity, entity)
			return FMRES_SUPERCEDE;
		}
	}
	return FMRES_IGNORED;
}

//Player Spawn Post
public fw_PlayerSpawn_Post(id)
{
	fm_strip_user_weapons(id)
	give_item( id, "weapon_knife")
	fm_reset_user_model(id)
}


//Damage
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	
}

//Disconnect
public fw_ClientDisconnect(id)
{
	delete_bit(g_isConnect, bit_id)
}

//客户端命令
public fw_ClientCommand(id)
{
	new szCommand[24], szText[32];
	read_argv(0, szCommand, charsmax(szCommand));
	read_argv(1, szText, charsmax(szText));
	
	//未登录时
	if(!get_bit(g_isLogin, bit_id))
	{
		if(!strcmp(szCommand, "say"))
		{
			//注册与登录
			if(!get_bit(g_isRegister, bit_id))
				gm_user_register(id, szText);
			else
				gm_user_login(id, szText);
		}
		return FMRES_SUPERCEDE;
	}
	
	if(!strcmp(szCommand, "say"))
	{
		if(equal(szText, "/pwchange"))
		{
			set_task(1.0, "task_pw_change", id+TASK_PWCHANGE, _, _, "b")
			set_bit(g_isChangingPW, bit_id)
			return FMRES_SUPERCEDE;
		}
		if(get_bit(g_isChangingPW, bit_id))
		{
			gm_user_register(id, szText)
			return FMRES_SUPERCEDE;
		}
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

public fw_ClientUserInfoChanged(id)
{
	//玩家是否使用自定义模型
	if(!get_bit(g_isModeled, bit_id))
		return FMRES_IGNORED;
	
	static RightModel[32]
	fm_get_user_model(id, RightModel, sizeof RightModel - 1)
	
	if(!equal(g_PlayerModel[id], RightModel))
		fm_set_user_model(id,g_PlayerModel[id])
	
	return FMRES_IGNORED;
}

public fw_SetClientKeyValue(id, const infobuffer[], const key[])
{
	// 阻止CS换模型
	if (get_bit(g_isModeled, bit_id) && equal(key, "model"))
		return FMRES_SUPERCEDE;
	
	return FMRES_IGNORED;
}

public fw_GetGameDescription()
{
	forward_return(FMV_STRING, Game_Description)
	return FMRES_SUPERCEDE;
}

/* =====================

			 Client
			 
===================== */

//进入服务器
public client_putinserver(id)
{
	set_bit(g_isConnect, bit_id)
	if(is_user_bot(id) && !g_hasBot)
	{
			set_task(0.1, "task_bots_ham", id+TASK_BOTHAM)
			return
	}
	g_LoginTime[id] = get_pcvar_num(cvar_LoginTime)
	delete_bit(g_isRegister, bit_id)
	delete_bit(g_isLogin, bit_id)
	gm_user_load(id)
	set_task(1.0, "task_user_login", id+TASK_USERLOGIN, _, _, "b")
}

/* =====================

			 Tasks
			 
===================== */
public task_round_start()
{
	new id = gm_choose_boss()
	g_whoBoss = id
	
	fm_set_user_health(id, get_pcvar_num(cvar_DevilHea))
	fm_cs_set_user_team(id, FM_CS_TEAM_T)
	
	fm_strip_user_weapons(id)
	give_item( id, "weapon_knife")

	set_pev(id, pev_viewmodel2, "models/v_devil_hand1.mdl")
	set_pev(id, pev_weaponmodel2, "")
	
	fm_set_user_model(id, "devil1")
}

public task_balance()
{
	new team
	for(new id = 1; id <= g_MaxPlayer; id++)
	{
		if(!get_bit(g_isConnect, bit_id))
			continue
		
		team = fm_cs_get_user_team(id)
		if(team == FM_CS_TEAM_SPECTATOR || team == FM_CS_TEAM_UNASSIGNED)
			continue
		
		fm_cs_set_user_team(id, FM_CS_TEAM_CT)
	}
}

public task_user_login(id)
{
	id-=TASK_USERLOGIN
	g_LoginTime[id] --
	msg_screen_fade(id, 0, 0, 0, 255)
	
	if(get_bit(g_isLogin, bit_id))
	{
		msg_screen_fade(id, 255, 255, 255, 0)
		remove_task(id+TASK_USERLOGIN)
	}
	
	if(!get_bit(g_isRegister, bit_id))
	{
		set_hudmessage(25, 255, 25, -1.0, -1.0, 1, 1.0, 1.0, 1.0, 1.0, 0)
		ShowSyncHudMsg(id, g_Hud_Center, "%L", LANG_PLAYER, "HUD_NO_REGISTER", g_LoginTime[id])
	}
	else
	{
		set_hudmessage(25, 255, 25, -1.0, -1.0, 1, 1.0, 1.0, 1.0, 1.0, 0)
		ShowSyncHudMsg(id, g_Hud_Center, "%L", LANG_PLAYER, "HUD_NO_LOGIN", g_LoginTime[id])
	}
	
	if(g_LoginTime[id] <= 0)
	{
		new Name[32]
		get_user_name(id, Name, charsmax(Name))
		server_cmd("kick %s", Name)
		remove_task(id+TASK_USERLOGIN)
	}
	
}

public task_pw_change(id)
{
	id-=TASK_PWCHANGE
	msg_screen_fade(id, 0, 0, 0, 255)
	set_hudmessage(25, 255, 25, -1.0, -1.0, 1, 1.0, 1.0, 1.0, 1.0, 0)
	ShowSyncHudMsg(id, g_Hud_Center, "%L", LANG_PLAYER, "HUD_CHANGING_PW")
	if(!get_bit(g_isChangingPW, bit_id))
	{
		msg_screen_fade(id, 255, 255, 255, 0)
		remove_task(id+TASK_PWCHANGE)
	}
		
}

public task_bots_ham(id)
{
	id-=TASK_BOTHAM
	if (!get_bit(g_isConnect, bit_id))
		return;
	
	RegisterHamFromEntity(Ham_Spawn, id, "fw_PlayerSpawn_Post", 1)
	RegisterHamFromEntity(Ham_TakeDamage, id, "fw_TakeDamage")
}

/* =====================

			 Game Function
			 
===================== */

gm_choose_boss()
{
	new id
	while(!is_user_alive(id) || !get_bit(g_isConnect, bit_id))
		id = random_num(1, g_MaxPlayer)
	
	return id
}

gm_user_register(id, const password[])
{
	msg_change_team_info(id, "SPECTATOR")
	new iteam[10]
	get_user_team(id, iteam, 9)
	
	new pw_len = strlen(password)
	if( pw_len > 12 || pw_len < 6)
	{
		client_color_print(id, "^x04[DevilEscape]^x03%L", LANG_PLAYER, "REGISTER_OUTOFLEN");
		return;
	}
	
	for(new i = 0; i < pw_len; i ++)
	{
		for(new j = 0; i < charsmax(InvalidChars); i++)
		{
			if( password[i] == InvalidChars[j])
			{
				client_color_print(id, "^x04[DevilEscape]^x03%L", LANG_PLAYER, "REGISTER_INVAILDCHAR");
				return;
			}
		}
	}
	
	//重要的事情说三遍
	client_color_print(id, "^x04[DevilEscape]%L^x03%s",  LANG_PLAYER, "REGISTER_SUCCESS", password)
	client_color_print(id, "^x04[DevilEscape]%L^x03%s",  LANG_PLAYER, "REGISTER_SUCCESS", password)
	client_color_print(id, "^x04[DevilEscape]%L^x03%s",  LANG_PLAYER, "REGISTER_SUCCESS", password)
	msg_change_team_info(id, iteam)
	
	set_bit(g_isRegister, bit_id)
	delete_bit(g_isChangingPW, bit_id)
	
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
	static iteam[10]
	get_user_team(id, iteam, 9)
	msg_change_team_info(id, "SPECTATOR")
	
	if(equal(save_pw, password))
	{
		client_color_print(id, "^x04[DevilEscape]^x03%L",  LANG_PLAYER, "LOGIN_SUCCESS")
		client_color_print(id, "^x04[DevilEscape]^x03%L",  LANG_PLAYER, "LOGIN_SUCCESS")
		client_color_print(id, "^x04[DevilEscape]^x03%L",  LANG_PLAYER, "LOGIN_SUCCESS")
		set_bit(g_isLogin, bit_id)
		client_cmd(id, "chooseteam")
	}
	else
		client_color_print(id, "^x04[DevilEscape]^x03%L",  LANG_PLAYER, "LOGIN_FAILED")
	
	msg_change_team_info(id, iteam)
}

gm_user_load(id)
{
	new szUserName[32], szFileDir[128]
	get_user_name(id, szUserName, charsmax(szUserName))
	formatex(szFileDir, charsmax(szFileDir), "%s/%s.ini", g_savesDir, szUserName)
	new kv = kv_create();
	kv_load_from_file(kv, szFileDir)
	kv_find_key(kv, szUserName)
	
	//检测是否注册
	if(!kv_is_empty(kv))
		set_bit(g_isRegister, bit_id)
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

			 Message
			 
===================== */
public msg_health(msg_id, msg_dest, msg_entity)
{
	// Get player's health
	static health
	health = get_msg_arg_int(1)
	
	// Don't bother
	if (health < 256) return;
	
	// Check if we need to fix it
	if (health % 256 == 0)
		fm_set_user_health(msg_entity, pev(msg_entity, pev_health) + 1)
	
	// HUD can only show as much as 255 hp
	set_msg_arg_int(1, get_msg_argtype(1), 255)
}

// 阻止一些textmsg
public msg_textmsg()
{
	static textmsg[32]
	get_msg_arg_string(2, textmsg, sizeof textmsg - 1)
	
	if (equal(textmsg, "#Hostages_Not_Rescued") || equal(textmsg, "#Round_Draw") || equal(textmsg, "#Terrorists_Win") || equal(textmsg, "#CTs_Win") || 
	equal(textmsg, "#C4_Arming_Cancelled") || equal(textmsg, "#C4_Plant_At_Bomb_Spot") || equal(textmsg, "#Killed_Hostage") || equal(textmsg, "#Game_will_restart_in") )
		return PLUGIN_HANDLED
		
	return PLUGIN_CONTINUE;
}

//阻止cs胜利/失败音效
public msg_sendaudio()
{
	static audio[17]
	get_msg_arg_string(2, audio, charsmax(audio))
	
	if(equal(audio[7], "terwin") || equal(audio[7], "ctwin") || equal(audio[7], "rounddraw"))
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

public msg_statusicon(msgid, dest, id)
{
	static szMsg[8]
	static const BuyMsg[] = "buyzone"
	get_msg_arg_string(2, szMsg, 7)
	
	if(equal(szMsg, BuyMsg))
	{
		set_pdata_int(id, m_MapZone, get_pdata_int(id, m_MapZone)& ~( 1<<0 ));
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}


public msg_show_menu(msgid, dest, id)
{
	static team_select[] = "#Team_Select_Spect"
	static menu_text_code[sizeof team_select]
	get_msg_arg_string(4, menu_text_code, sizeof menu_text_code - 1)
	
	client_print(id, print_center, "%s", menu_text_code)
	
	if (!equal(menu_text_code, team_select))
		return PLUGIN_CONTINUE
	
	return PLUGIN_HANDLED
}

public msg_vgui_menu(msgid, dest, id)
{
	if (get_msg_arg_int(1) != 2)
		return PLUGIN_CONTINUE
	
	show_menu(id, 51, "#Team_Select_Spect", -1)
	return PLUGIN_HANDLED
}

public menu_team_select(id, key)
{
	switch(key)
	{
		case 0:	//T
		{
			team_join(id,"2")
			return PLUGIN_HANDLED;
		}
		case 4:	//Auto
		{
			team_join(id,"2")
			return PLUGIN_HANDLED;
		}
	}
	return PLUGIN_CONTINUE;
}


/* ==========================

					[Stocks]
			 
==========================*/


/* =====================

			 Getter
			 
===================== */
stock fm_cs_get_user_team(id)
{
	return get_pdata_int(id, m_CsTeam);
}

stock fm_get_user_model(id, model[], len)
{
	return engfunc(EngFunc_InfoKeyValue, engfunc(EngFunc_GetInfoKeyBuffer, id), "model", model, len)
}

/* =====================

			 Setter
			 
===================== */
stock fm_cs_set_user_team(id, team)
{
	set_pdata_int(id, m_CsTeam, team)
	fm_cs_set_user_team_msg(id)
}

stock fm_cs_set_user_team_msg(id)
{
	new const team_names[][] = { "UNASSIGNED", "TERRORIST", "CT", "SPECTATOR" }
	message_begin(MSG_ALL, get_user_msgid("TeamInfo"))
	write_byte(id) // player
	write_string(team_names[fm_cs_get_user_team(id)]) // team
	message_end()
}

stock fm_set_user_health(id, health)
{
	if(get_bit(g_isConnect, bit_id))
		(health > 0 ) ? set_pev(id, pev_health, float(health)) : dllfunc(DLLFunc_ClientKill, id);
	else return;
}

//设定模型
stock fm_cs_set_user_model(id, const model[])
{
	set_user_info(id, "model", model)
}

//设定模型2
stock fm_set_user_model(id, const model[])
{
	set_bit(g_isModeled, bit_id)
	engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "model", model)
	copy(g_PlayerModel[id], sizeof g_PlayerModel[] - 1, model)
	
	// static ModelPath[64]
	// formatex(ModelPath, charsmax(ModelPath), "models/player/%s", model)
	// set_pdata_int(id, m_ModelIndex, engfunc(EngFunc_ModelIndex, ModelPath))
}

//重置模型
stock fm_reset_user_model(id)
{
	if (!get_bit(g_isConnect, bit_id))
		return

	delete_bit(g_isModeled, bit_id)
	dllfunc(DLLFunc_ClientUserInfoChanged, id, engfunc(EngFunc_GetInfoKeyBuffer, id))
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

stock fm_strip_user_weapons( index )
{
   new iEnt = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "player_weaponstrip" ) );
   if( !pev_valid( iEnt ) )
      return 0;

   dllfunc( DLLFunc_Spawn, iEnt );
   dllfunc( DLLFunc_Use, iEnt, index );
   engfunc( EngFunc_RemoveEntity, iEnt );

   return 1;
}

/* =====================

			 Msg
			 
===================== */
stock msg_screen_fade(id, red, green, blue, alpha)
{
	message_begin(MSG_ONE, get_user_msgid("ScreenFade"), _, id)
	write_short(0)// Duration
	write_short(0)// Hold time
	write_short(( 1<<0 ) | ( 1<<2 ) )// Fade type
	write_byte (red)// Red
	write_byte (green)// Green
	write_byte (blue)// Blue
	write_byte (alpha)// Alpha
	message_end()
}

stock msg_change_team_info(id, team[])
{
	message_begin (MSG_ONE, get_user_msgid ("TeamInfo"), _, id)	// Tells to to modify teamInfo (Which is responsable for which time player is)
	write_byte (id)				// Write byte needed
	write_string (team)				// Changes player's team
	message_end()					// Also Needed
}
/* =====================

			 Other
			 
===================== */

stock client_color_print(target,  const message[], any:...)
{
	static buffer[512], i, argscount
	argscount = numargs()
	// 发送给所有人
	if (!target)
	{
		static player
		for (player = 1; player <= g_MaxPlayer; player++)
		{
			// 断线
			if (!get_bit(g_isConnect, player-1))
				continue;
			
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

team_join(id, team[] = "5")
{
	new msg_block = get_msg_block(g_Msg_ShowMenu)
	set_msg_block(g_Msg_ShowMenu, BLOCK_SET)
	engclient_cmd(id, "jointeam", team)
	set_msg_block(g_Msg_ShowMenu, msg_block)
}
