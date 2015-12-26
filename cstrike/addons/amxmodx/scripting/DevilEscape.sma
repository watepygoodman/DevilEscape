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

#define bit_id (id-1)
#define g_NeedXp[%1] (g_Level[%1]*g_Level[%1]*100)
#define is_user_valid_connected(%1) (1 <= %1 <= g_MaxPlayer && get_bit(g_isConnect, %1-1))

#define Game_Description "魔王 Alpha"

//弹药类型武器
new const AMMOWEAPON[] = { 0, CSW_AWP, CSW_SCOUT, CSW_M249, 
			CSW_AUG, CSW_XM1014, CSW_MAC10, CSW_FIVESEVEN, CSW_DEAGLE, 
			CSW_P228, CSW_ELITE, CSW_FLASHBANG, CSW_HEGRENADE, 
			CSW_SMOKEGRENADE, CSW_C4 }

//弹药名
new const AMMOTYPE[][] = { "", "357sig", "", "762nato", "", "buckshot", "", "45acp", "556nato", "", "9mm", "57mm", "45acp",
		"556nato", "556nato", "556nato", "45acp", "9mm", "338magnum", "9mm", "556natobox", "buckshot",
			"556nato", "9mm", "762nato", "", "50ae", "556nato", "762nato", "", "57mm" }
			
//最大后背弹药
new const MAXBPAMMO[] = { -1, 52, -1, 90, 1, 32, 1, 100, 90, 1, 120, 100, 100, 90, 90, 90, 100, 120,
				30, 120, 200, 32, 90, 120, 90, 2, 35, 90, 90, -1, 100 }

enum
{
	FM_CS_TEAM_UNASSIGNED = 0,
	FM_CS_TEAM_T,
	FM_CS_TEAM_CT,
	FM_CS_TEAM_SPECTATOR
}

enum(+=40)
{
	TASK_BOTHAM = 100, TASK_USERLOGIN, TASK_PWCHANGE,
	TASK_ROUNDSTART, TASK_BALANCE, TASK_SHOWHUD, TASK_PLRSPAWN
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
new cvar_DmgReward, cvar_LoginTime, cvar_DevilHea, cvar_DevilSlashDmg, cvar_RewardCoin, cvar_RewardXp, cvar_SpPreLv;

//Game
new g_plrTeam;
new g_isRegister;
new g_isLogin;
new g_isConnect;
new g_isChangingPW;
new g_isModeled;
// new g_isSemiclip;
// new g_isSolid;
new g_whoBoss;
new g_MaxPlayer;
new g_Online;
new bool:g_hasBot;

new g_Level[33];
new g_Coin[33];
new g_Gash[33];
new g_Xp[33];
new g_Sp[33];
new Float:g_Dmg[33];
new Float:g_DmgDealt[33]
new g_LoginTime[33];

new g_savesDir[128];
new g_PlayerModel[33][32]

// new Float:g_PlrOrg[33][3]
new Float:g_TSpawn[32][3]
new Float:g_CTSpawn[32][3]

//Hud
new g_Hud_Center, g_Hud_Status

//Msg
new g_Msg_VGUI, g_Msg_ShowMenu;

//Forward Handle
new g_fwSpawn;


public plugin_precache()
{
	//载入
	gm_create_fog();
	gm_init_spawnpoint();
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
	cvar_DmgReward = register_cvar("de_human_dmg_reward", "1500")
	cvar_RewardCoin = register_cvar("de_reward_coin", "1")
	cvar_RewardXp = register_cvar("de_reward_xp", "200")
	cvar_SpPreLv = register_cvar("de_sp_per_lv", "2")
	cvar_LoginTime = register_cvar("de_logintime","120")
	cvar_DevilHea = register_cvar("de_devilbasehea","2046")
	cvar_DevilSlashDmg = register_cvar("de_devilslashdmg", "50")
	
	
}

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	register_dictionary("devilescape.txt");
	
	//Event
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0");
	register_event("AmmoX", "event_ammo_x", "be");
	register_logevent("event_round_end", 2, "1=Round_End");
	
	//Forward
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink");
	register_forward(FM_PlayerPostThink, "fw_PlayerPostThink");
	register_forward(FM_ClientCommand, "fw_ClientCommand") ;
	register_forward(FM_ClientDisconnect, "fw_ClientDisconnect");
	register_forward(FM_SetClientKeyValue, "fw_SetClientKeyValue");
	register_forward(FM_ClientUserInfoChanged,"fw_ClientUserInfoChanged")
	register_forward(FM_GetGameDescription, "fw_GetGameDescription")
	register_forward(FM_AddToFullPack, "fw_AddToFullPack_Post", 1 );
	
	//Ham
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage");
	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1);
	RegisterHam(Ham_Touch, "weapon_hegrenade", "fw_TouchWeapon")
	RegisterHam(Ham_Touch, "weaponbox", "fw_TouchWeapon")
	RegisterHam(Ham_Touch, "armoury_entity", "fw_TouchWeapon")
	
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
	g_Hud_Status = CreateHudSyncObj();
	
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
	engfunc(EngFunc_LightStyle, 0, 'f')
	
	gm_reset_vars()
	remove_task(TASK_BALANCE)
	set_task(0.2, "task_balance", TASK_BALANCE)
	
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

public event_ammo_x(id)
{
	//Human only
	if(id == g_whoBoss)
		return;
	
	static type
	type = read_data(1)
	
	// Unknown ammo type
	if (type >= sizeof AMMOWEAPON)
		return;
	
	// Get weapon's id
	static weapon
	weapon = AMMOWEAPON[type]
	
	// Primary and secondary only
	if (MAXBPAMMO[weapon] <= 2)
		return;
	
	// Get ammo amount
	static amount
	amount = read_data(2)
	
	if (amount < MAXBPAMMO[weapon])
	{
	// The BP Ammo refill code causes the engine to send a message, but we
	// can't have that in this forward or we risk getting some recursion bugs.
	// For more info see: https://bugs.alliedmods.net/show_bug.cgi?id=3664
		static args[1]
		args[0] = weapon
		set_task(0.1, "task_refill_bpammo", id, args, sizeof args)
	}
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
	static team
	team = fm_cs_get_user_team(id)
	switch(team)
	{
		case FM_CS_TEAM_CT:
			set_bit(g_plrTeam, bit_id)
		case FM_CS_TEAM_T:
			delete_bit(g_plrTeam, bit_id)
	}
	set_task(0.2, "task_plrspawn", id+TASK_PLRSPAWN)
	set_task(1.0, "task_showhud", id+TASK_SHOWHUD, _ ,_ ,"b")
	
}


//PreThink
public fw_PlayerPreThink(id)
{
	// fw_SetPlayerSoild(id)
	while(g_Xp[id] >= g_NeedXp[id])
	{
		g_Xp[id] -= g_NeedXp[id]
		g_Level[id] ++
		g_Sp[id] += get_pcvar_num(cvar_SpPreLv)
		client_print(id, print_center, "此处应HUD升级信息")
	}
}

//Post Think
// public fw_PlayerPostThink(id)
// {
	// static plr
	// for(plr = 1; plr<= g_MaxPlayer; plr++)
	// {
		// if(get_bit(g_isSemiclip, plr-1))
		// {
			// set_pev(plr, pev_solid, SOLID_SLIDEBOX)
			// delete_bit(g_isSemiclip, plr-1)
		// }
	// }
// }

//Damage
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	if( (get_bit(g_plrTeam, victim-1) && get_bit(g_plrTeam, attacker-1)) || 
	!((get_bit(g_plrTeam, victim-1) || get_bit(g_plrTeam, attacker-1))) || victim == attacker)
		return FMRES_IGNORED;
		
	if(g_whoBoss == attacker)
		SetHamParamFloat(4, get_pcvar_float(cvar_DevilSlashDmg))
		
	g_Dmg[attacker] += damage;
	g_DmgDealt[attacker] += damage;
	
	if(g_DmgDealt[attacker] > get_pcvar_num(cvar_DmgReward))
	{
		new i = 0;
		while(g_DmgDealt[attacker] > get_pcvar_num(cvar_DmgReward))
		{
			i ++;
			g_DmgDealt[attacker] -= get_pcvar_num(cvar_DmgReward);
			g_Coin[attacker] += get_pcvar_num(cvar_RewardCoin);
			g_Xp[attacker] += get_pcvar_num(cvar_RewardXp);
		}
		client_print(attacker, print_center, "这里应该是HUD提示%i*1500经验 %i Coin", i, i)
	}
	
	//这里应该是HUD提示
	
	return FMRES_IGNORED;
}

public fw_TouchWeapon(weapon, id)
{
	if(!is_user_valid_connected(id))
		return HAM_IGNORED;
	
	if(id == g_whoBoss)
		return HAM_SUPERCEDE;
	
	return HAM_IGNORED;
}

//Disconnect
public fw_ClientDisconnect(id)
{
	delete_bit(g_isConnect, bit_id)
	g_Online --;
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
	g_Online ++
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

public client_weapon_shoot(id)//MOUSE1
{
	
}

/* =====================

			 Tasks
			 
===================== */
public task_round_start()
{
	new id = gm_choose_boss()
	g_whoBoss = id
	for(new id = 1; id <= g_MaxPlayer; id++)
	{
		if(!get_bit(g_isConnect, bit_id) || g_whoBoss == id)
			continue
	}
	//get_pcvar_num(cvar_DevilHea) + (((760.8 + g_Online) * (g_Online - 1))
	new addhealth = floatround(floatpower(((760.8 + g_Online)*(g_Online - 1)), 1.0341) + get_pcvar_float(cvar_DevilHea))
	fm_set_user_health(id, addhealth)
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

public task_showhud(id)
{
	id -= TASK_SHOWHUD
	
	set_hudmessage(25, 255, 25, 0.60, 0.80, 1, 1.0, 1.0, 0.0, 0.0, 0)
	ShowSyncHudMsg(id, g_Hud_Status, "HP:%d  |  Level:%d  |  Coin:%d  |  Gash:%d^n累计伤害:%f  |  XP:%d/%d^nBossHP:%d  |  g_Online:%d",
	pev(id, pev_health), g_Level[id], g_Coin[id], g_Gash[id], g_Dmg[id], g_Xp[id], g_NeedXp[id],get_user_health(g_whoBoss),g_Online)
}

public task_plrspawn(id)
{
	id -= TASK_PLRSPAWN
	fm_reset_user_model(id)
	fm_strip_user_weapons(id)
	fm_give_item(id, "weapon_knife")
	remove_task(id+TASK_PLRSPAWN);
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

public task_refill_bpammo(const args[], id)
{
	if (!is_user_alive(id) || id == g_whoBoss)
		return;
	
	set_msg_block(get_user_msgid("AmmoPickup"), BLOCK_ONCE)
	ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[args[0]], AMMOTYPE[args[0]], MAXBPAMMO[args[0]])
}

/* =====================

			 Game Function
			 
===================== */

//选BOSS
gm_choose_boss()
{
	new id
	while(!is_user_alive(id) || !get_bit(g_isConnect, bit_id))
		id = random_num(1, g_MaxPlayer)
	
	return id
}

//重设变量
gm_reset_vars()
{
	g_whoBoss = 0;
	for(new i = 1 ; i <= g_MaxPlayer; i++)
	{
		g_Dmg[i] = 0.0;
	}
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


gm_init_spawnpoint()
{
	new SpawnCount, ent
	while ((engfunc(EngFunc_FindEntityByString, ent, "classname", "info_player_start")) != 0)
	{
		pev(ent, pev_origin, g_CTSpawn[SpawnCount]);
		SpawnCount ++
		if(SpawnCount > sizeof g_CTSpawn) break;
	}
	while ((engfunc(EngFunc_FindEntityByString, ent, "classname", "info_player_deathmatch")) != 0)
	{
		pev(ent, pev_origin, g_TSpawn[SpawnCount]);
		SpawnCount ++
		if(SpawnCount > sizeof g_TSpawn) break;
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
	switch(team)
	{
		case FM_CS_TEAM_CT:
			set_bit(g_plrTeam, bit_id)
		case FM_CS_TEAM_T:
			delete_bit(g_plrTeam, bit_id)
	}
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

//设置渲染
stock fm_set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16)
{
	static Float:color[3]
	color[0] = float(r)
	color[1] = float(g)
	color[2] = float(b)
	
	set_pev(entity, pev_renderfx, fx)
	set_pev(entity, pev_rendercolor, color)
	set_pev(entity, pev_rendermode, render)
	set_pev(entity, pev_renderamt, float(amount))
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

stock fm_give_item(id, const item[])
{
	static ent
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, item))
	if (!pev_valid(ent)) return;
	
	static Float:originF[3]
	pev(id, pev_origin, originF)
	set_pev(ent, pev_origin, originF)
	set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN)
	dllfunc(DLLFunc_Spawn, ent)
	
	static save
	save = pev(ent, pev_solid)
	dllfunc(DLLFunc_Touch, ent, id)
	if (pev(ent, pev_solid) != save)
		return;
	
	engfunc(EngFunc_RemoveEntity, ent)
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

stock fm_get_entity_index(owner,entclassname[])
{
	new ent = 0
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", entclassname))!=0 )
	{
		if(pev(ent,pev_owner)==owner)
		{
			return ent
		}
	}
	return 0
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

stock msg_trace(const Float:idorigin[3],const Float:targetorigin[3]){
	new id[3],target[3]
	FVecIVec(idorigin,id)
	FVecIVec(targetorigin,target)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(6)//TE_TRACER
	write_coord(id[0])
	write_coord(id[1])
	write_coord(id[2])
	write_coord(target[0])
	write_coord(target[1])
	write_coord(target[2])
	message_end()
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

