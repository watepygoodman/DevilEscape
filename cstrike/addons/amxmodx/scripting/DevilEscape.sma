/*=============================================================
	
	DevilEscape mode
		For Counter-Strike 1.6
		
	Coding by watepy	in 15/12/7
	
log:
	15/12/7 : start coding
	
=============================================================*/

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <fun>
#include <xs>
#include <dhudmessage>
#include <keyvalues>
#include <bitset>
#include <engine>
#include <devilescape>

#define PLUGIN_NAME "DevilEscape"
#define PLUGIN_VERSION "0.0"
#define PLUGIN_AUTHOR "w&a"

/* ==================
	
				 常量

================== */

#define g_NeedXp[%1] (g_Level[%1]*g_Level[%1]*100)
#define is_user_valid_connected(%1) (1 <= %1 <= g_MaxPlayer && get_bit(g_isConnect, %1))

#define Game_Description "[魔王 Alpha]"

#define SHOTGUN_AIMING 32

//弹药类型武器
new const AMMOWEAPON[] = { 0, CSW_AWP, CSW_SCOUT, CSW_M249, 
			CSW_AUG, CSW_XM1014, CSW_MAC10, CSW_FIVESEVEN, CSW_DEAGLE, 
			CSW_P228, CSW_ELITE, CSW_FLASHBANG, CSW_HEGRENADE, 
			CSW_SMOKEGRENADE, CSW_C4 }

//弹药名
new const AMMOTYPE[][] = { "", "357sig", "", "762nato", "", "buckshot", "", "45acp", "556nato", "", "9mm", "57mm", "45acp",
		"556nato", "556nato", "556nato", "45acp", "9mm", "338magnum", "9mm", "556natobox", "buckshot",
			"556nato", "9mm", "762nato", "", "50ae", "556nato", "762nato", "", "57mm" }

new const WEAPONCSWNAME[/*CSW_ID*/][] = { "", "P228", "", "Scout", "", "XM1014", 
			"", "MAC10", "Aug", "Smoke", "Elite", "Fiveseven", 
			"UMP45", "SG550", "Galil", "Famas", "USP", "Glock18", 
			"AWP", "MP5", "M249", "M3", "M4A1", "TMP", "G3SG1", 
			"", "Desert Eagle", "SG552", "AK47", "Knife", "P90" }			

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

enum(+= 66)
{
	TASK_BOTHAM = 100, TASK_USERLOGIN, TASK_PWCHANGE,
	TASK_ROUNDSTART, TASK_BALANCE, TASK_SHOWHUD, TASK_PLRSPAWN, 
	TASK_GODMODE_LIGHT, TASK_GODMODE_OFF,TASK_CRITICAL, TASK_SCARE_OFF, 
	TASK_AUTOSAVE, TASK_BLIND_OFF, TASK_DEVILMANA_RECO, TASK_NVISION, TASK_RANK,
	TASK_SPEC_NVISION
}

enum{
	Round_Start=0,			
	Round_Running,
	Round_End
}

enum(+=10){
	ADMIN_SELECT_BOSS = 32, ADMIN_GIVE, ADMIN_GIVE_COIN, ADMIN_GIVE_GASH, ADMIN_GIVE_XP, ADMIN_GIVE_LEVEL = 82
}

new const g_RemoveEnt[][] = {
	"func_hostage_rescue", "info_hostage_rescue", "func_bomb_target", "info_bomb_target",
	"hostage_entity", "info_vip_start", "func_vip_safetyzone", "func_escapezone"
}

//资源
new const mdl_player_devil1[] = "models/player/devil1/devil1.mdl"

new const mdl_v_devil1[] = "models/v_devil_hand1.mdl"

new const snd_human_win[] = "DevilEscape/Human_Win.wav"
new const snd_devil_win[] = "DevilEscape/Devil_Win.wav"
new const snd_noone_win[] = "DevilEscape/Noone_Win.wav"

new const snd_claw_miss[][] = {
	"DevilEscape/Claw_Miss1.wav", "DevilEscape/Claw_Miss2.wav"}
new const snd_claw_strike[][] = {
	"DevilEscape/Claw_Strike1.wav", "DevilEscape/Claw_Strike2.wav", "DevilEscape/Claw_Strike3.wav"}
new const snd_boss_die[][] = {
	"DevilEscape/Boss_Death1.wav", "DevilEscape/Boss_Death2.wav"}
new const snd_boss_pain[][] = {
	"DevilEscape/Boss_Pain1.wav", "DevilEscape/Boss_Pain2.wav"}
new const snd_boss_scare[] = "DevilEscape/Boss_Scare.wav"
new const snd_boss_tele[] = "DevilEscape/Boss_Teleport.wav"
new const snd_boss_god[] = "DevilEscape/Boss_God.wav"
new const snd_boss_ljump[] = "DevilEscape/Boss_Longjump.wav"

new const snd_crit_shoot[] = "DevilEscape/Crit_Shoot.wav"
new const snd_crit_hit[] = "DevilEscape/Crit_Hit.wav"
new const snd_crit_received[] = "DevilEscape/Crit_Received.wav"
new const snd_minicrit_hit[] = "DevilEscape/MiniCrit_Hit.wav"

new const spr_ring[] = "sprites/shockwave.spr"

new const spr_crit[] = "sprites/DevilEscape/Crit.spr"
new const spr_minicrit[] = "sprites/DevilEscape/MiniCrit.spr"

new const spr_scare[] = "sprites/DevilEscape/Boss_Scare.spr"

const KEYSMENU = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9)

new const InvalidChars[]= { "/", "\", "*", ":", "?", "^"", "<", ">", "|", " " }
new const g_fog_color[] = "128 128 128";
new const g_fog_denisty[] = "0.002";

new const g_WpnFreeFrist[][] = {"weapon_tmp", "weapon_mp5navy", "weapon_p90", "weapon_famas", "weapon_galil", 
				"weapon_ak47", "weapon_m4a1", "weapon_sg552"}
new const g_WpnFreeSec[][] = {"weapon_aug", "weapon_sg550", "weapon_g3sg1", "weapon_awp", "weapon_m249"}

new const g_WpnFreeFrist_CSW[] = {CSW_TMP, CSW_MP5NAVY, CSW_P90, CSW_FAMAS, CSW_GALIL, CSW_AK47, 
				CSW_M4A1, CSW_SG552}
new const g_WpnFreeSec_CSW[] = {CSW_AUG, CSW_SG550, CSW_G3SG1, CSW_AWP, CSW_M249}

new const g_WpnFreeFrist_Name[][] = {"TMP", "MP5", "P90", "Famas", "Galil", "AK47", "M4A1", "SG552"}
new const g_WpnFreeSec_Name[][] = {"AUG", "SG550", "G3SG1", "AWP", "M249"}

//Hud
#define DHUD_MSG_X -1.0
#define DHUD_MSG_Y 0.20

/* ================== 

				Vars
				
================== */

#define MAX_PACKSLOT 16

//Cvar
new cvar_MapBright, cvar_DmgReward, cvar_LoginTime, cvar_LoginRetryMax, cvar_AutosaveTime , cvar_DevilHea, cvar_DevilSpeed, cvar_DevilGravity, cvar_DevilRecoManaTime, cvar_DevilRecoManaNum, cvar_DevilManaMax, 
cvar_DevilSlashDmgMulti,  cvar_DevilDisappearTime, cvar_DevilScareTime,cvar_DevilGodTime, cvar_DevilBlindTime, cvar_DevilLongjumpDistance, 
cvar_DevilScareRange, cvar_DevilBlindRange, cvar_DevilLongjumpCost, cvar_DevilDisappearCost , cvar_DevilScareCost, cvar_DevilBlindCost, cvar_DevilGodCost, 
cvar_DevilTeleCost, cvar_RewardCoin, cvar_RewardXp, cvar_SpPreLv, cvar_HumanCritMulti, cvar_HumanCritPercent, cvar_HumanMiniCritMulti, cvar_AbilityHeaCost, 
cvar_AbilityAgiCost, cvar_AbilityStrCost, cvar_AbilityGraCost, cvar_AbilityHeaMax, cvar_AbilityAgiMax, cvar_AbilityStrMax, cvar_AbilityGraMax,
cvar_AbilityHeaAdd, cvar_AbilityAgiAdd, cvar_AbilityStrAdd, cvar_AbilityGraAdd ,cvar_BaseWpnNeedLv, cvar_BaseWpnPreLv, cvar_RewardWpnXp,
cvar_WpnLvAddDmg, cvar_WpnLvNeedXp, cvar_WpnLvMax, cvar_DevilWinGetBaseXp, cvar_DevilWinGetBaseCoin, cvar_HumanWinGetXp, cvar_HumanWinGetCoin,
cvar_NooneWinGetXp, cvar_NooneWinGetCoin, cvar_ConvertCoinToGash, cvar_ConvertGashToCoin, cvar_ItemOpen, cvar_NvgColor_Human[3], cvar_NvgColor_Boss[3]

// new cvar_Wpn_PlasmagunPrice, cvar_Wpn_ThunderboltPrice, cvar_Wpn_SalamanderPrice, cvar_Wpn_WatercannonPrice, cvar_Wpn_M4A1BKPrice, cvar_Wpn_QBS09Price

//Spr
new g_spr_ring;
new g_spr_crit;
new g_spr_minicrit;
new g_spr_scare;

//Game
new g_isRegister;
new g_isLogin;
new g_isConnect;
new g_isChangingPW;
new g_isModeled;
new g_isNoDamage
new g_isCrit;
new g_isMiniCrit;
new g_isBuyWpnMain;
new g_isBuyWpnSec;
// new g_isPressingData;
// new g_DataPress;
new g_isSemiclip;
new g_isSolid;
new g_isNvision;
new g_isAlive;
new g_hasNvision;

new g_whoBoss;
new g_MaxPlayer;
new g_Online;
new g_PlayerInGame;
new g_RoundStatus;
new bool:g_hasBot;
new bool:g_RoundNeedStart;

new g_Level[33];
new g_Coin[33];
new g_Gash[33];
new g_Xp[33];
new g_Sp[33];
new g_Abi_Hea[33]
new g_Abi_Str[33];
new g_Abi_Agi[33];
new g_Abi_Gra[33];

new g_Pack[33][MAX_PACKSLOT+1];
new g_Pack_Select[33]
new bool:g_Pack_SpWpn[33][32];
new bool:g_Pack_GashWpn[33][32]

new g_WpnXp[33][31]	//武器熟练度经验 1-30 P228-P90
new g_WpnLv[33][31]	//武器熟练度等级 1-30 P228-P90

new Float:g_Dmg[33];
new Float:g_DmgDealt[33]
new Float:g_AttackCooldown[33];
new g_BossMana;
new g_LoginTime[33];
new g_LoginRetry[33];
new g_UsersAmmo[33];
new g_UsersWeapon[33];

//Menu
new g_Menu_WpnFree_Page[33];
new g_Menu_Admin_Select[33];
new g_Menu_Admin_Select_PlrKey[33][33];

//Admin
new g_Admin_Select_Boss
new g_Admin_Select_Plr[33]
new g_Admin_Input[33]

new g_savesDir[128];

new g_PlayerEffect[33];
new g_PlayerTeam[33];
new g_PlayerPswd[33][12];
new g_PlayerModel[33][32];
new Float:g_PlayerOrg[33][3];

// new Float:g_PlrOrg[33][3]
new Float:g_TSpawn[32][3];
new Float:g_CTSpawn[32][3];
new g_TSpawnCount;
new g_CTSpawnCount;

//Rank
new Float:g_1st_Dmg, Float:g_2nd_Dmg, Float:g_3rd_Dmg
new g_1st_ID, g_2nd_ID, g_3rd_ID

//Hud
new g_Hud_Center, g_Hud_Status, g_Hud_Reward, g_Hud_Rank;

//Msg
new g_Msg_VGUI, g_Msg_ShowMenu;

//Forward Handle
new g_fwSpawn;

//Array
new Array:g_SpWpn_Name
new Array:g_SpWpn_Price
new Array:g_GashWpn_Name
new Array:g_GashWpn_Price
new Array:g_SecondWpn_Name
new Array:g_SecondWpn_Lv
new Array:g_Item_Name
new Array:g_Item_Info
new Array:g_Shop_Item_Name
new Array:g_Shop_Item_Price
new Array:g_Shop_Item_Max

new g_SpWpn_Num, g_GashWpn_Num, g_SecondWpn_Num, g_Item_Num, g_Shop_Item_Num

new g_Shop_Item_Times[33][32]

//Forward Handles
new g_fwSpWpnSelect, g_fwGashWpnSelect, g_fwSecondWpnSelect, g_fwItemSelect, g_fwShopItemSelect, g_fwDummyResult

public plugin_natives()
{
	register_native("de_register_sp_wpn", "native_register_sp_wpn", 1)
	register_native("de_register_gash_wpn", "native_register_gash_wpn", 1)
	register_native("de_register_second_wpn", "native_register_second_wpn", 1)
	register_native("de_register_item", "native_register_item", 1)
	register_native("de_register_shop_item", "native_register_shop_item", 1)
	register_native("de_set_user_nightvision", "native_set_user_nightvision", 1)
}

public plugin_precache()
{
	//载入
	gm_create_fog();
	//gm_init_spawnpoint(); Bug
	engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_rain"));
	//Get saves' dir
	get_localinfo("amxx_configsdir", g_savesDir, charsmax(g_savesDir));
	formatex(g_savesDir, charsmax(g_savesDir), "%s/saves", g_savesDir)
	
	g_fwSpawn = register_forward(FM_Spawn, "fw_Spawn");
	
	engfunc(EngFunc_PrecacheModel, mdl_player_devil1)
	
	engfunc(EngFunc_PrecacheModel, mdl_v_devil1)
	
	g_spr_ring = engfunc(EngFunc_PrecacheModel, spr_ring)
	g_spr_crit = engfunc(EngFunc_PrecacheModel, spr_crit)
	g_spr_minicrit = engfunc(EngFunc_PrecacheModel, spr_minicrit)
	g_spr_scare = engfunc(EngFunc_PrecacheModel, spr_scare)
	
	new i;
	for(i = 0; i < sizeof snd_claw_miss; i++)
		engfunc(EngFunc_PrecacheSound, snd_claw_miss[i])
	for(i = 0; i < sizeof snd_claw_strike; i++)
		engfunc(EngFunc_PrecacheSound, snd_claw_strike[i])
	for(i = 0; i < sizeof snd_boss_die; i++)
		engfunc(EngFunc_PrecacheSound, snd_boss_die[i])
	for(i = 0; i < sizeof snd_boss_pain; i++)
		engfunc(EngFunc_PrecacheSound, snd_boss_pain[i])
	
	engfunc(EngFunc_PrecacheSound, snd_human_win)
	engfunc(EngFunc_PrecacheSound, snd_devil_win)
	engfunc(EngFunc_PrecacheSound, snd_boss_scare)
	engfunc(EngFunc_PrecacheSound, snd_boss_tele)
	engfunc(EngFunc_PrecacheSound, snd_boss_god)
	engfunc(EngFunc_PrecacheSound, snd_boss_ljump)
	engfunc(EngFunc_PrecacheSound, snd_crit_hit)
	engfunc(EngFunc_PrecacheSound, snd_crit_received)
	engfunc(EngFunc_PrecacheSound, snd_crit_shoot)
	engfunc(EngFunc_PrecacheSound, snd_minicrit_hit)
	
	//Array
	g_SpWpn_Name = ArrayCreate(32, 1)
	g_GashWpn_Name = ArrayCreate(32, 1)
	g_SecondWpn_Name = ArrayCreate(32, 1)
	g_Item_Name = ArrayCreate(32, 1)
	g_Item_Info = ArrayCreate(64, 1)
	g_Shop_Item_Name = ArrayCreate(32, 1)
	
	g_SpWpn_Price = ArrayCreate(1, 1)
	g_GashWpn_Price = ArrayCreate(1, 1)
	g_SecondWpn_Lv = ArrayCreate(1, 1)
	g_Shop_Item_Price = ArrayCreate(1, 1)
	g_Shop_Item_Max = ArrayCreate(1, 1)
	
	//Cvar
	cvar_MapBright = register_cvar("de_map_bright","d")
	cvar_LoginRetryMax = register_cvar("de_login_retry_max","3")
	cvar_LoginTime = register_cvar("de_logintime","120")
	cvar_AutosaveTime = register_cvar("de_autosavetime","120")
	
	cvar_BaseWpnPreLv = register_cvar("de_basewpn_prelv","5")
	cvar_BaseWpnNeedLv = register_cvar("de_basewpn_needlv", "0")
	
	cvar_DmgReward = register_cvar("de_human_dmg_reward", "1500")
	cvar_RewardCoin = register_cvar("de_reward_coin", "1")
	cvar_RewardXp = register_cvar("de_reward_xp", "200")
	cvar_SpPreLv = register_cvar("de_sp_per_lv", "2")
	
	cvar_DevilHea = register_cvar("de_devil_basehea","230000")
	cvar_DevilSpeed = register_cvar("de_devil_basespeed","260.0")
	cvar_DevilGravity = register_cvar("de_devil_basegravity","0.90")
	cvar_DevilRecoManaTime = register_cvar("de_devil_reco_manatime","0.3")
	cvar_DevilRecoManaNum = register_cvar("de_devil_reco_mananum","6")
	cvar_DevilManaMax = register_cvar("de_devil_manamax","999")
	cvar_DevilSlashDmgMulti = register_cvar("de_devil_slashdmg_multi", "1.5")
	cvar_DevilScareRange = register_cvar("de_devil_scarerange", "512.0")
	cvar_DevilBlindRange = register_cvar("de_devil_blindrange", "512.0")
	cvar_DevilLongjumpDistance = register_cvar("de_devil_longjumpdistance", "300.0")
	cvar_DevilDisappearTime = register_cvar("de_devil_disappeartime", "4.5")
	cvar_DevilScareTime = register_cvar("de_devil_scaretime", "4.5")
	cvar_DevilBlindTime = register_cvar("de_devil_blindtime", "4.5")
	cvar_DevilGodTime = register_cvar("de_devil_godtime", "7.5")
	cvar_DevilLongjumpCost = register_cvar("de_devil_longjumpcost", "333")
	cvar_DevilDisappearCost = register_cvar("de_devil_disappearcost", "555")
	cvar_DevilScareCost = register_cvar("de_devil_scarecost", "666")
	cvar_DevilBlindCost = register_cvar("de_devil_blindcost", "555")
	cvar_DevilGodCost = register_cvar("de_devil_godcost", "777")
	cvar_DevilTeleCost = register_cvar("de_devil_telecost", "555")
	
	cvar_HumanCritPercent = register_cvar("de_crit_percent","3")
	cvar_HumanCritMulti = register_cvar("de_crit_multi","3.0")
	cvar_HumanMiniCritMulti = register_cvar("de_minicrit_multi","1.5")
	
	cvar_AbilityHeaCost = register_cvar("de_ability_hea_cost","1")
	cvar_AbilityAgiCost = register_cvar("de_ability_agi_cost","2")
	cvar_AbilityStrCost = register_cvar("de_ability_str_cost","4")
	cvar_AbilityGraCost = register_cvar("de_ability_gra_cost","8")
	cvar_AbilityHeaMax = register_cvar("de_ability_hea_max","100")
	cvar_AbilityAgiMax = register_cvar("de_ability_agi_max","20")
	cvar_AbilityStrMax = register_cvar("de_ability_str_max","50")
	cvar_AbilityGraMax = register_cvar("de_ability_gra_max","4")
	cvar_AbilityHeaAdd = register_cvar("de_ability_hea_add", "1")
	cvar_AbilityAgiAdd = register_cvar("de_ability_agi_add", "1.0")
	cvar_AbilityStrAdd = register_cvar("de_ability_str_add", "0.02")
	cvar_AbilityGraAdd = register_cvar("de_ability_gra_add", "0.1")
	
	cvar_RewardWpnXp = register_cvar("de_wpnxp_reward", "1")
	cvar_WpnLvAddDmg = register_cvar("de_wpnlv_add_dmg", "1.0")
	cvar_WpnLvNeedXp = register_cvar("de_wpnlv_need_xp", "100")
	cvar_WpnLvMax = register_cvar("de_wpnlv_max", "250")
	
	cvar_DevilWinGetBaseXp = register_cvar("de_win_devil_base_getxp", "650")
	cvar_DevilWinGetBaseCoin = register_cvar("de_win_devil_base_getcoin", "2")
	cvar_HumanWinGetXp = register_cvar("de_win_human_getxp", "2000")
	cvar_HumanWinGetCoin = register_cvar("de_win_human_getcoin", "4")
	cvar_NooneWinGetXp = register_cvar("de_win_noone_getxp", "1000")
	cvar_NooneWinGetCoin = register_cvar("de_win_noone_getcoin", "2")
	
	cvar_ConvertCoinToGash = register_cvar("de_convert_coin_to_gash", "100")
	cvar_ConvertGashToCoin = register_cvar("de_convert_gash_to_coin", "95")
	
	cvar_ItemOpen = register_cvar("de_item_open", "1")
	
	cvar_NvgColor_Human[0] = register_cvar("de_nvg_human_color_R", "32")
	cvar_NvgColor_Human[1] = register_cvar("de_nvg_human_color_G", "32")
	cvar_NvgColor_Human[2] = register_cvar("de_nvg_human_color_B", "32")
	cvar_NvgColor_Boss[0] = register_cvar("de_nvg_boss_color_R", "128")
	cvar_NvgColor_Boss[1] = register_cvar("de_nvg_boss_color_G", "32")
	cvar_NvgColor_Boss[2] = register_cvar("de_nvg_boss_color_B", "32")
	
	// cvar_Wpn_PlasmagunPrice = register_cvar("de_wpn_plasmagun_price", "1888")
	// cvar_Wpn_ThunderboltPrice = register_cvar("de_wpn_thunderbolt_price", "2288")
	// cvar_Wpn_SalamanderPrice = register_cvar("de_wpn_salamander_price", "399")
	// cvar_Wpn_WatercannonPrice = register_cvar("de_wpn_watercannon_price", "599")
	// cvar_Wpn_M4A1BKPrice = register_cvar("de_wpn_m4a1bk_price","450")
	// cvar_Wpn_QBS09Price = register_cvar("de_wpn_qbs09_price","50")
}

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	register_dictionary("devilescape.txt");
	
	//Menu
	register_menu("Main Menu", KEYSMENU, "menu_main")
	register_menu("Ability Menu", KEYSMENU, "menu_ability")
	register_menu("Skill Menu", KEYSMENU, "menu_skill")
	register_menu("Bossskill Menu", KEYSMENU, "menu_bossskill")
	register_menu("Weapon Menu", KEYSMENU, "menu_weapon")
	register_menu("WeaponFree Menu", KEYSMENU, "menu_weapon_free")
	register_menu("WeaponSecond Menu", KEYSMENU, "menu_weapon_second")
	register_menu("Shop Menu", KEYSMENU, "menu_shop")
	register_menu("ItemSelect Menu", KEYSMENU, "menu_item_select")
	register_menu("Convert Menu", KEYSMENU, "menu_convert")
	register_menu("Admin Menu", KEYSMENU, "menu_admin")
	register_menu("AdminGive Menu", KEYSMENU, "menu_admin_give")
	
	register_menucmd(register_menuid("#Team_Select_Spect"), 51, "menu_team_select") 
	
	//Event
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0");
	register_event("AmmoX", "event_ammo_x", "be");
	register_logevent("event_round_end", 2, "1=Round_End");
	register_event("CurWeapon","event_shoot","be","1=1");
	
	//Forward
	register_forward(FM_CmdStart,"fw_CmdStart")
	register_forward(FM_EmitSound, "fw_EmitSound");
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
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage_Post",1);
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
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
	
	//Hud
	g_Hud_Center = CreateHudSyncObj();
	g_Hud_Status = CreateHudSyncObj();
	g_Hud_Reward = CreateHudSyncObj();
	g_Hud_Rank = CreateHudSyncObj();
	
	//Unregister
	unregister_forward(FM_Spawn, g_fwSpawn)
	
	//Multi Forward
	g_fwSpWpnSelect = CreateMultiForward("de_spwpn_select", ET_CONTINUE, FP_CELL, FP_CELL)
	g_fwGashWpnSelect = CreateMultiForward("de_gashwpn_select", ET_CONTINUE, FP_CELL, FP_CELL)
	g_fwSecondWpnSelect = CreateMultiForward("de_secondwpn_select", ET_CONTINUE, FP_CELL, FP_CELL)
	g_fwItemSelect = CreateMultiForward("de_item_select", ET_CONTINUE, FP_CELL, FP_CELL)
	g_fwShopItemSelect = CreateMultiForward("de_shop_item_select", ET_CONTINUE, FP_CELL, FP_CELL)
	//Vars
	g_MaxPlayer = get_maxplayers()
	server_cmd("mp_autoteambalance 0")
}


/* =====================

			  Event
			 
===================== */

//Round_Start
public event_round_start()
{
	if(!g_Online || !fnGetAlive())
	{
		g_RoundNeedStart = true
		return
	}
	static LightStyle[2]
	get_pcvar_string(cvar_MapBright, LightStyle, 1) 
	
	g_RoundStatus = Round_Start;
	//Light
	engfunc(EngFunc_LightStyle, 0, LightStyle[0])
	
	
	gm_reset_vars()
	remove_task(TASK_BALANCE)
	set_task(0.2, "task_balance", TASK_BALANCE)
	set_task(1.0, "task_show_rank", TASK_RANK, _ ,_ ,"b")
	
	set_dhudmessage( 255, 255, 255, DHUD_MSG_X, DHUD_MSG_Y, 1, 3.0, 1.0, 0.1, 1.0 );
	show_dhudmessage( 0, " %L", LANG_PLAYER, "DHUD_ROUND_START" );
	
	remove_task(TASK_ROUNDSTART)
	set_task(10.0, "task_round_start", TASK_ROUNDSTART)
}

//Round_End
public event_round_end()
{
	g_RoundStatus = Round_End;
	remove_task(TASK_DEVILMANA_RECO)
	remove_task(TASK_BALANCE)
	set_task(0.2, "task_balance", TASK_BALANCE)
	
	new GetXp, GetCoin
	
	if(g_RoundNeedStart)
		return
	
	if(!fnGetHumans())
	{
		GetXp = get_pcvar_num(cvar_DevilWinGetBaseXp) * g_PlayerInGame
		GetCoin = get_pcvar_num(cvar_DevilWinGetBaseCoin) * g_PlayerInGame
		set_dhudmessage( 255, 0, 0, DHUD_MSG_X, DHUD_MSG_Y, 1, 3.0, 1.0, 0.1, 1.0 );
		show_dhudmessage( 0, " %L", LANG_PLAYER, "DHUD_BOSS_WIN" );
		client_color_print(0, "^x04[DevilEscape]^x03%L%L",  LANG_PLAYER, "DHUD_BOSS_WIN", LANG_PLAYER, "WIN_GET_CHAT", GetXp, GetCoin)
		PlaySound(snd_devil_win)
		g_Xp[g_whoBoss] += GetXp
		g_Coin[g_whoBoss] += GetCoin
	}
	else if(!is_user_alive(g_whoBoss))
	{
		GetXp = get_pcvar_num(cvar_HumanWinGetXp)
		GetCoin = get_pcvar_num(cvar_HumanWinGetCoin)
		set_dhudmessage( 0, 255, 0,  DHUD_MSG_X, DHUD_MSG_Y, 1, 3.0, 1.0, 0.1, 1.0 );
		show_dhudmessage( 0, " %L", LANG_PLAYER, "DHUD_HUMAN_WIN" );
		client_color_print(0, "^x04[DevilEscape]^x03%L%L",  LANG_PLAYER, "DHUD_HUMAN_WIN", LANG_PLAYER, "WIN_GET_CHAT", GetXp, GetCoin)
		PlaySound(snd_human_win)
		for(new i = 1; i <= g_MaxPlayer; i++)
		{
			if(i == g_whoBoss || !is_user_valid_connected(i))
				continue
			g_Xp[i] += GetXp
			g_Coin[i] += GetCoin
		}
	}
	else
	{
		GetXp = get_pcvar_num(cvar_NooneWinGetXp)
		GetCoin = get_pcvar_num(cvar_NooneWinGetCoin)
		set_dhudmessage( 255, 255, 255, DHUD_MSG_X, DHUD_MSG_Y, 1, 3.0, 1.0, 0.1, 1.0 );
		show_dhudmessage( 0, " %L", LANG_PLAYER, "DHUD_NOONE_WIN" );
		client_color_print(0, "^x04[DevilEscape]^x03%L%L",  LANG_PLAYER, "DHUD_NOONE_WIN", LANG_PLAYER, "WIN_GET_CHAT", GetXp, GetCoin)
		PlaySound(snd_noone_win)
		for(new i = 1; i <= g_MaxPlayer; i++)
		{
			if(!is_user_valid_connected(i))
				continue
			g_Xp[i] += GetXp
			g_Coin[i] += GetCoin
		}
		
	}
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

public event_shoot(id)
{
	new ammo = read_data(3), weapon = read_data(2);
	if(g_UsersAmmo[id] > ammo && ammo >= 0 && g_UsersWeapon[id] == weapon)
	{
		new vec1[3], vec2[3];
		get_user_origin(id, vec1, 1);
		get_user_origin(id, vec2, 4);
		if(weapon==CSW_M3 || weapon==CSW_XM1014)
		{
			msg_trace(vec1,vec2,get_bit(g_isCrit, id));

			vec2[0]+=SHOTGUN_AIMING;
			msg_trace(vec1,vec2,get_bit(g_isCrit, id));
			vec2[1]+=SHOTGUN_AIMING;
			msg_trace(vec1,vec2,get_bit(g_isCrit, id));
			vec2[2]+=SHOTGUN_AIMING;
			msg_trace(vec1,vec2,get_bit(g_isCrit, id));
			vec2[0]-=SHOTGUN_AIMING; // Repeated substraction is faster then multiplication !
			vec2[0]-=SHOTGUN_AIMING; // Repeated substraction is faster then multiplication !
			msg_trace(vec1,vec2,get_bit(g_isCrit, id));
			vec2[1]-=SHOTGUN_AIMING; // Repeated substraction is faster then multiplication !
			vec2[1]-=SHOTGUN_AIMING; // Repeated substraction is faster then multiplication !
			msg_trace(vec1,vec2,get_bit(g_isCrit, id));
			vec2[2]-=SHOTGUN_AIMING; // Repeated substraction is faster then multiplication !
			vec2[2]-=SHOTGUN_AIMING; // Repeated substraction is faster then multiplication !
			msg_trace(vec1,vec2,get_bit(g_isCrit, id));
		}
		else
			msg_trace(vec1,vec2,get_bit(g_isCrit, id));
		g_UsersAmmo[id]=ammo;
		if(get_bit(g_isCrit, id))
			engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_crit_shoot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
    }
	else
	{
        g_UsersWeapon[id]=weapon;
        g_UsersAmmo[id]=ammo;
    }
	return PLUGIN_HANDLED;
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
		}
	}
	new Float:originF[3]
	if(equal(classname, "info_player_start") && g_CTSpawnCount < sizeof g_CTSpawn)
	{
		pev(entity, pev_origin, originF)
		g_CTSpawn[g_CTSpawnCount][0] = originF[0]
		g_CTSpawn[g_CTSpawnCount][1] = originF[1]
		g_CTSpawn[g_CTSpawnCount][2] = originF[2]
		g_CTSpawnCount++ 
		
	}
	if(equal(classname, "info_player_deathmatch") && g_TSpawnCount < sizeof g_TSpawn)
	{
		pev(entity, pev_origin, originF)
		g_TSpawn[g_TSpawnCount][0] = originF[0]
		g_TSpawn[g_TSpawnCount][1] = originF[1]
		g_TSpawn[g_TSpawnCount][2] = originF[2]
		g_TSpawnCount++ 
	}
	return FMRES_IGNORED;
}

//Player Spawn Post
public fw_PlayerSpawn_Post(id)
{
	g_PlayerTeam[id] = fm_cs_get_user_team(id)
	
	if(g_PlayerTeam[id] == FM_CS_TEAM_SPECTATOR || g_PlayerTeam[id] == FM_CS_TEAM_UNASSIGNED)
		return
	
	if(g_RoundNeedStart)
	{
		server_cmd("sv_restart 1")
		g_RoundNeedStart = false
	}

	set_user_gravity(id, 1.0-get_pcvar_float(cvar_AbilityGraAdd)*g_Abi_Gra[id])
	fm_set_user_health(id, 100+g_Abi_Hea[id]*get_pcvar_num(cvar_AbilityHeaAdd))
	
	set_bit(g_isAlive, id)
	new Float:test[3]
	pev(id, pev_origin, test)
	set_task(0.2, "task_plrspawn", id+TASK_PLRSPAWN)
	if(!is_user_bot(id))
		set_task(1.0, "task_showhud", id+TASK_SHOWHUD, _ ,_ ,"b")
}

public fw_PlayerKilled(victim, attacker, shouldgib)
{
	delete_bit(g_isAlive, victim)
	set_task(0.1, "task_spec_nvision", victim+TASK_SPEC_NVISION)
	
	if(victim == attacker || !is_user_alive(attacker))
		return HAM_IGNORED
	
	return HAM_IGNORED
}

//PreThink
public fw_PlayerPreThink(id)
{
	if(g_AttackCooldown[id] > get_gametime())
	{
		if(is_user_alive(id))
		{
			set_pev(id, pev_button, pev(id,pev_button) & ~IN_ATTACK );
			set_pev(id, pev_button, pev(id,pev_button) & ~IN_ATTACK2 );
		}
	}else set_view(id,CAMERA_NONE)
		
	if(g_Xp[id] >= g_NeedXp[id])
	{
		while(g_Xp[id] >= g_NeedXp[id])
		{
			g_Xp[id] -= g_NeedXp[id]
			g_Level[id] ++
			g_Sp[id] += get_pcvar_num(cvar_SpPreLv)
		}
		set_hudmessage(192, 0, 0, -1.0, -1.0, 1, 6.0, 1.5, 0.3, 0.3, 0)
		ShowSyncHudMsg(id, g_Hud_Center, "%L" , LANG_PLAYER, "HUD_LEVEL_UP", g_Level[id])
	}
	if(id != g_whoBoss)
		set_pev(id, pev_maxspeed, 250.0+ g_Abi_Agi[id] * get_pcvar_float(cvar_AbilityAgiAdd))
	else set_pev(id, pev_maxspeed, get_pcvar_float(cvar_DevilSpeed))
	
	//穿人
	static LastSemiThink
	if( LastSemiThink > id )
		fw_SemiClipThink()
	LastSemiThink = id
	
	if(get_bit(g_isSolid, id))
	{
		for(new i = 1; i <= g_MaxPlayer; i++)
		{
			if(!get_bit(g_isSolid, i) || id == i) continue
			if(g_PlayerTeam[id] == g_PlayerTeam[i])
			{
				set_pev(i, pev_solid, SOLID_NOT)
				set_bit(g_isSemiclip, i)
			}
		}
	}
	
	return FMRES_HANDLED;
}

//Post Think
public fw_PlayerPostThink(id)
{
	static plr
	for(plr = 1; plr<= g_MaxPlayer; plr++)
	{
		if(get_bit(g_isSemiclip, plr))
		{
			set_pev(plr, pev_solid, SOLID_SLIDEBOX)
			delete_bit(g_isSemiclip, plr)
		}
	}
}

public fw_SemiClipThink()
{
	for(new i = 1; i <= g_MaxPlayer; i++)
	{
		if(!is_user_alive(i))
		{
			delete_bit(g_isSolid, i)
			continue
		}
		
		if(pev(i, pev_solid) == SOLID_SLIDEBOX) 
			set_bit(g_isSolid, i)
		else delete_bit(g_isSolid, i)
		
		pev(i, pev_origin, g_PlayerOrg[i])
	}
}

//Damage
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	static Vic_team, Att_Team
	Vic_team = fm_cs_get_user_team(victim)
	Att_Team = fm_cs_get_user_team(attacker)
		
	if(Vic_team == Att_Team)
		return HAM_IGNORED
		
	//无敌
	if(get_bit(g_isNoDamage, victim))
		return HAM_SUPERCEDE;
	
	new Float:TrueDamage = damage;
	
	if(g_whoBoss == attacker)
	{
		TrueDamage *= get_pcvar_float(cvar_DevilSlashDmgMulti)
		SetHamParamFloat(4, TrueDamage)
		return HAM_HANDLED;
	}

	//Str
	TrueDamage =  TrueDamage * (1.0 + g_Abi_Str[attacker]*get_pcvar_float(cvar_AbilityStrAdd))
	
	//Crit
	if(get_bit(g_isCrit, attacker))
	{
		TrueDamage *= get_pcvar_float(cvar_HumanCritMulti)
		msg_create_crit(attacker,victim,1)
	}
	
	//MiniCrit
	else if(get_bit(g_isMiniCrit, attacker))
	{
		TrueDamage *= get_pcvar_float(cvar_HumanMiniCritMulti)
		msg_create_crit(attacker,victim,2)
	}
	//WpnLv
	if(damage_type != DE_DMG_ROCKET)
		TrueDamage += get_pcvar_float(cvar_WpnLvAddDmg) * g_WpnLv[attacker][g_UsersWeapon[attacker]]
	
	SetHamParamFloat(4, TrueDamage)
		
	return HAM_HANDLED;
}

public fw_TakeDamage_Post(victim, inflictor, attacker, Float:damage, damage_type)
{
	static Vic_team, Att_Team
	Vic_team = fm_cs_get_user_team(victim)
	Att_Team = fm_cs_get_user_team(attacker)
		
	if(Vic_team == Att_Team || victim == attacker)
		return HAM_IGNORED
	
	g_Dmg[attacker] += damage;
	g_DmgDealt[attacker] += damage;
	
	if(g_DmgDealt[attacker] > get_pcvar_num(cvar_DmgReward))
	{
		new i = 0;
		while(g_DmgDealt[attacker] > get_pcvar_num(cvar_DmgReward))
		{
			i ++;
			g_DmgDealt[attacker] -= get_pcvar_num(cvar_DmgReward);
		}
		
		g_Coin[attacker] += get_pcvar_num(cvar_RewardCoin) * i;
		g_Xp[attacker] += get_pcvar_num(cvar_RewardXp) * i;
		if(g_WpnLv[attacker][g_UsersWeapon[attacker]] < get_pcvar_num(cvar_WpnLvMax))
		{
			set_hudmessage(192, 0, 0, -1.0, 0.75, 1, 6.0, 1.5, 0.3, 0.3, 0)
			ShowSyncHudMsg(attacker, g_Hud_Reward, "+%d xp ^n +%d coin ^n +%d %s Exp" , i * get_pcvar_num(cvar_RewardXp), i * get_pcvar_num(cvar_RewardCoin), i*get_pcvar_num(cvar_RewardWpnXp), WEAPONCSWNAME[g_UsersWeapon[attacker]])
			g_WpnXp[attacker][g_UsersWeapon[attacker]] += get_pcvar_num(cvar_RewardWpnXp) * i
			
			new WpnLvNeedXp = get_pcvar_num(cvar_WpnLvNeedXp)
			if(g_WpnXp[attacker][g_UsersWeapon[attacker]] >= WpnLvNeedXp)
			{	
				while(g_WpnXp[attacker][g_UsersWeapon[attacker]] >= WpnLvNeedXp)
				{
					g_WpnXp[attacker][g_UsersWeapon[attacker]] -= WpnLvNeedXp
					g_WpnLv[attacker][g_UsersWeapon[attacker]] ++
				}
				set_hudmessage(192, 0, 0, -1.0, 0.55, 1, 6.0, 1.5, 0.3, 0.3, 0)
				ShowSyncHudMsg(attacker, g_Hud_Center, "%L" , LANG_PLAYER, "HUD_WPN_LEVEL_UP", WEAPONCSWNAME[g_UsersWeapon[attacker]] ,g_WpnLv[attacker][g_UsersWeapon[attacker]])
			}
		}
		else
		{
			set_hudmessage(192, 0, 0, -1.0, 0.75, 1, 6.0, 1.5, 0.3, 0.3, 0)
			ShowSyncHudMsg(attacker, g_Hud_Reward, "+%d xp ^n +%d coin ^n %s Lv.Max" , i * get_pcvar_num(cvar_RewardXp), i * get_pcvar_num(cvar_RewardCoin), WEAPONCSWNAME[g_UsersWeapon[attacker]])
		}			
	}
	
	if(attacker != g_whoBoss && is_user_valid_connected(attacker))
	{
		if(g_Dmg[attacker] >= g_1st_Dmg)
		{
			if(attacker != g_1st_ID)
			{
				if(g_2nd_ID == attacker)
				{
					g_2nd_ID = g_1st_ID 
					g_2nd_Dmg = g_1st_Dmg 	//交换2和1不管3
				}
				else	//从其他到1 (3或以下)
				{
					g_3rd_Dmg = g_2nd_Dmg; g_3rd_ID = g_2nd_ID	//2到3
					g_2nd_Dmg = g_1st_Dmg; g_2nd_ID = g_1st_ID	//1到2
				}
				g_1st_ID = attacker	//1变
			}
			g_1st_Dmg = g_Dmg[attacker]; //刷新
		}
		else if(g_Dmg[attacker] >= g_2nd_Dmg)
		{
			if(attacker != g_1st_ID && attacker != g_2nd_ID) //自己本来不是1或2
			{
				g_3rd_Dmg = g_2nd_Dmg;g_3rd_ID = g_2nd_ID	//2到3
				g_2nd_ID = attacker	//2变
			}
			g_2nd_Dmg = g_Dmg[attacker];	//刷新
		}
		else if(g_Dmg[attacker] >= g_3rd_Dmg)
		{
			g_3rd_Dmg = g_Dmg[attacker]	//直接当3
			g_3rd_ID = attacker
		}
	}
	return HAM_IGNORED
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
	delete_bit(g_isConnect, id)
	g_Online --
	if(!g_Online)
		g_RoundNeedStart = true
	
	remove_task(id+TASK_AUTOSAVE)
}

//Command
public fw_CmdStart(id,uc_handle,seed)
{
	new button = get_uc(uc_handle, UC_Buttons);
	// new old_button = pev(id,pev_oldbuttons);
	
	if(button&IN_USE)
	{
		if(id != g_whoBoss)
			return FMRES_IGNORED
		show_menu_bossskill(id)
		return FMRES_SUPERCEDE
	}
	
	return FMRES_IGNORED
}

//Emit Sound
public fw_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
	if (!is_user_valid_connected(id))
		return FMRES_IGNORED;
	
	if(id == g_whoBoss)
	{
		if (sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't')
		{
			emit_sound(id, channel, snd_boss_pain[random_num(0, 1)], volume, attn, flags, pitch)
			return FMRES_SUPERCEDE;
		}
		if (sample[8] == 'k' && sample[9] == 'n' && sample[10] == 'i')
		{
			//Slash
			if (sample[14] == 's' && sample[15] == 'l' && sample[16] == 'a') 
			{
				emit_sound(id, channel, snd_claw_miss[random_num(0, 1)], volume, attn, flags, pitch)
				return FMRES_SUPERCEDE;
			}
			//击中(轻)
			if (sample[14] == 'h' && sample[15] == 'i' && sample[16] == 't') 
			{
				emit_sound(id, channel, snd_claw_strike[random_num(0, 1)], volume, attn, flags, pitch)
				return FMRES_SUPERCEDE;
			}
			
			//击中(重)
			if (sample[14] == 's' && sample[15] == 't' && sample[16] == 'a')
			{
				emit_sound(id, channel, snd_claw_strike[2], volume, attn, flags, pitch)
				return FMRES_SUPERCEDE;
			}
		}
		// Boss 挂掉
		if (sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a')))
		{
			emit_sound(id, channel, snd_boss_die[random_num(0, 1)], volume, attn, flags, pitch)
			return FMRES_SUPERCEDE;
		}
	}
	return FMRES_IGNORED;
}

//客户端命令
public fw_ClientCommand(id)
{
	new szCommand[24], szText[32];
	read_argv(0, szCommand, charsmax(szCommand));
	read_argv(1, szText, charsmax(szText));
	
	//未登录时
	if(!get_bit(g_isLogin, id))
	{
		if(!strcmp(szCommand, "say"))
		{
			//注册与登录
			if(!get_bit(g_isRegister, id))
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
			set_bit(g_isChangingPW, id)
			return FMRES_SUPERCEDE;
		}
		if(get_bit(g_isChangingPW, id))
		{
			gm_user_register(id, szText)
			return FMRES_SUPERCEDE;
		}
		
		new AdminPut = g_Menu_Admin_Select[id]
		if(AdminPut == ADMIN_GIVE_COIN || AdminPut == ADMIN_GIVE_GASH || AdminPut == ADMIN_GIVE_XP || AdminPut == ADMIN_GIVE_LEVEL)
		{
			if(!is_str_num(szText))
				client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "ADMIN_INPUT_ERROR");
			else
			{
				g_Admin_Input[id] = str_to_num(szText)
				
				//为0
				if(!g_Admin_Input[id])
				{
					g_Menu_Admin_Select[id] = 0
					return FMRES_SUPERCEDE;
				}
				
				gm_admin_give(id)
			}
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
		
		if(get_bit(g_isLogin,id))
			show_menu_main(id)
		
		return FMRES_SUPERCEDE;
	}
	
	if(!strcmp(szCommand, "nightvision"))
	{
		if(get_bit(g_hasNvision, id))
		{
			if(get_bit(g_isNvision, id)) native_set_user_nightvision(id, 0)
			else native_set_user_nightvision(id, 1)
		}
	}
	
	return FMRES_IGNORED;
}

public fw_AddToFullPack_Post(es, e, ent, host, hostflags, player, pSet)
{
	if(player)
	{
		if(get_bit(g_isSolid, host) && get_bit(g_isSolid, ent) && g_PlayerTeam[host] == g_PlayerTeam[ent])
		{
			if(get_distance_f(g_PlayerOrg[host], g_PlayerOrg[ent]) <= 200.0)
			{
				set_es(es, ES_Solid, SOLID_NOT)
				set_es(es, ES_RenderMode, kRenderTransAlpha)
				set_es(es, ES_RenderAmt, 85)
			}
			else
				set_es(es, ES_RenderMode, kRenderNormal)
		}
	}
}
public fw_ClientUserInfoChanged(id)
{
	//玩家是否使用自定义模型
	if(!get_bit(g_isModeled, id))
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
	if (get_bit(g_isModeled, id) && equal(key, "model"))
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
	if(!g_Online || g_RoundNeedStart)
	{
		server_cmd("sv_restart 1")
		g_RoundNeedStart = false
	}
	
	set_bit(g_isConnect, id)
	g_Online ++
	
	if(is_user_bot(id))
	{
		if(!g_hasBot)
			set_task(0.1, "task_bots_ham", id+TASK_BOTHAM)
		
		//强行登陆
		set_bit(g_isRegister, id)
		set_bit(g_isLogin, id)
		return
	}
	
	g_LoginTime[id] = get_pcvar_num(cvar_LoginTime)
	g_LoginRetry[id] = 0
	delete_bit(g_isRegister, id)
	delete_bit(g_isLogin, id)
	gm_user_load(id)
	set_task(1.0, "task_user_login", id+TASK_USERLOGIN, _, _, "b")
}

public client_weapon_shoot(id)//MOUSE1
{
	
}

/* =====================

			 Tasks
			 
===================== */
public task_autosave(id)
{
	id -= TASK_AUTOSAVE
	gm_user_save(id)
	// client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "AUTOSAVE_SUCCESS");
}

public task_round_start()
{
	if(g_RoundStatus != Round_Start)
		return 
	
	new id
	if(g_Admin_Select_Boss)
		id = g_Admin_Select_Boss
	else id = gm_choose_boss()
	
	g_whoBoss = id
	for(new i = 1; i <= g_MaxPlayer; i++)
	{
		if(!is_user_valid_connected(i))
			continue;
		new team = fm_cs_get_user_team(i)
		if(team == FM_CS_TEAM_SPECTATOR || team == FM_CS_TEAM_UNASSIGNED)
			continue
		g_PlayerInGame ++;
	}
	//get_pcvar_num(cvar_DevilHea) + (((760.8 + g_PlayerInGame) * (g_PlayerInGame - 1))
	new addhealth = floatround(get_pcvar_float(cvar_DevilHea) * g_PlayerInGame * 1.45)
	fm_set_user_health(id, addhealth)
	fm_cs_set_user_team(id, FM_CS_TEAM_T)
	
	fm_strip_user_weapons(id)
	give_item( id, "weapon_knife")

	set_pev(id, pev_viewmodel2, "models/v_devil_hand1.mdl")
	set_pev(id, pev_weaponmodel2, "")
	set_user_gravity(id, get_pcvar_float(cvar_DevilGravity))
	
	fm_set_user_model(id, "devil1")
	
	native_set_user_nightvision(id, 1)
	
	static hull
	for(new i = 0; i < sizeof g_TSpawnCount; i++)
	{
		hull = (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN
		
		if(is_hull_vacant(g_TSpawn[i], hull))
		{
			engfunc(EngFunc_SetOrigin, id, g_TSpawn[i])
			break
		}
	}
	
	if(!is_user_bot(id))
	{
		set_dhudmessage( 255, 0, 0, DHUD_MSG_X, DHUD_MSG_Y, 1, 3.0, 1.0, 0.1, 1.0 );
		show_dhudmessage( id, " %L", LANG_PLAYER, "DHUD_YOU_BECOME_BOSS" );
	}
	set_task(get_pcvar_float(cvar_DevilRecoManaTime), "task_devilmana_reco", TASK_DEVILMANA_RECO, _, _, "b")
	
	g_RoundStatus = Round_Running;
	remove_task(TASK_ROUNDSTART)
}

public task_balance()
{
	new team
	for(new id = 1; id <= g_MaxPlayer; id++)
	{
		if(!get_bit(g_isConnect, id))
			continue
		
		team = fm_cs_get_user_team(id)
		if(team == FM_CS_TEAM_SPECTATOR || team == FM_CS_TEAM_UNASSIGNED)
			continue
		fm_cs_set_user_team(id, FM_CS_TEAM_CT)
		
	}
}

public task_show_rank()
{
	static PlrName_1[20], PlrName_2[20], PlrName_3[20]
	
	if(!g_1st_ID) formatex(PlrName_1, 19, "暂无")
	else get_user_name(g_1st_ID, PlrName_1, charsmax(PlrName_1))
	if(!g_2nd_ID) formatex(PlrName_2, 19, "暂无")
	else get_user_name(g_2nd_ID, PlrName_2, charsmax(PlrName_2))
	if(!g_3rd_ID) formatex(PlrName_3, 19, "暂无")
	else get_user_name(g_3rd_ID, PlrName_3, charsmax(PlrName_3))
	
	static RankInfo[188]
	formatex(RankInfo, charsmax(RankInfo), "%L", LANG_PLAYER, "RANK_INFO", PlrName_1, g_1st_Dmg, PlrName_2, g_2nd_Dmg, PlrName_3, g_3rd_Dmg)
	set_hudmessage(255, 255, 255, 0.87, -1.0, 1, 1.0, 1.0, 0.0, 0.0, 0)
	ShowSyncHudMsg(0, g_Hud_Rank, RankInfo)
}

public task_showhud(id)
{
	id -= TASK_SHOWHUD
	
	if(!get_bit(g_isAlive, id))
	{
		static specid
		specid = pev(id, pev_iuser2)
		set_hudmessage(255, 255, 25, 0.625, 0.78, 1, 1.0, 1.0, 0.0, 0.0, 0)
		ShowSyncHudMsg(id, g_Hud_Status, "%L", LANG_PLAYER, "SPEC_HUD_INFO", pev(specid, pev_health), g_Coin[specid], g_Gash[specid], 
		g_Level[specid], g_Xp[specid], g_NeedXp[specid], g_Sp[specid], g_Dmg[specid])
	}
	else
	{
		set_hudmessage(25, 255, 25, 0.625, 0.78, 1, 1.0, 1.0, 0.0, 0.0, 0)
		ShowSyncHudMsg(id, g_Hud_Status, "%L", LANG_PLAYER, "HUD_INFO",
		pev(id, pev_health), g_Coin[id], g_Gash[id], g_Level[id], g_Xp[id], g_NeedXp[id], g_Sp[id],
		WEAPONCSWNAME[g_UsersWeapon[id]], g_WpnLv[id][g_UsersWeapon[id]] , WEAPONCSWNAME[g_UsersWeapon[id]], 
		g_WpnXp[id][g_UsersWeapon[id]], get_pcvar_num(cvar_WpnLvNeedXp) ,g_Dmg[id])
	}
}

public task_plrspawn(id)
{
	id -= TASK_PLRSPAWN
	fm_reset_user_model(id)
	fm_strip_user_weapons(id)
	fm_give_item(id, "weapon_knife")
	
	if(is_user_bot(id))
	{
		switch(random_num(0, 3))
		{
			case 0: fm_give_item(id, g_WpnFreeFrist[random_num(0, (sizeof g_WpnFreeFrist) -1)])
			case 1: ExecuteForward(g_fwGashWpnSelect, g_fwDummyResult, id, random_num(0, g_GashWpn_Num-1))
			case 2: ExecuteForward(g_fwSpWpnSelect, g_fwDummyResult, id, random_num(0, g_SpWpn_Num-1))
		}
	}
	show_menu_weapon(id)
	remove_task(id+TASK_PLRSPAWN);
}

public task_user_login(id)
{
	id-=TASK_USERLOGIN
	g_LoginTime[id] --
	msg_screen_fade(id, 0, 0, 0, 255)
	
	if(get_bit(g_isLogin, id))
	{
		msg_screen_fade(id, 255, 255, 255, 0)
		remove_task(id+TASK_USERLOGIN)
	}
	
	if(!get_bit(g_isRegister, id))
	{
		set_hudmessage(25, 255, 25, -1.0, -1.0, 1, 1.0, 1.0, 1.0, 1.0, 0)
		ShowSyncHudMsg(id, g_Hud_Center, "%L", LANG_PLAYER, "HUD_NO_REGISTER", g_LoginTime[id])
	}
	else
	{
		set_hudmessage(25, 255, 25, -1.0, -1.0, 1, 1.0, 1.0, 1.0, 1.0, 0)
		ShowSyncHudMsg(id, g_Hud_Center, "%L", LANG_PLAYER, "HUD_NO_LOGIN", g_LoginTime[id], g_LoginRetry[id], get_pcvar_num(cvar_LoginRetryMax))
	}
	
	if(g_LoginTime[id] <= 0)
	{
		new Name[32]
		get_user_name(id, Name, charsmax(Name))
		server_cmd("kick %s", Name)
		remove_task(id+TASK_USERLOGIN)
	}
	
	if(g_LoginRetry[id] >= get_pcvar_num(cvar_LoginRetryMax))
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
	if(!get_bit(g_isChangingPW, id))
	{
		msg_screen_fade(id, 255, 255, 255, 0)
		remove_task(id+TASK_PWCHANGE)
	}
		
}

public task_bots_ham(id)
{
	id-=TASK_BOTHAM
	if (!get_bit(g_isConnect, id) || g_hasBot)
		return;
	
	RegisterHamFromEntity(Ham_Spawn, id, "fw_PlayerSpawn_Post", 1)
	RegisterHamFromEntity(Ham_TakeDamage, id, "fw_TakeDamage")
	RegisterHamFromEntity(Ham_TakeDamage, id, "fw_TakeDamage_Post", 1)
	RegisterHamFromEntity(Ham_Killed, id, "fw_PlayerKilled")
	g_hasBot = true
	
	// If the bot has already spawned, call the forward manually for him
	if (is_user_alive(id)) fw_PlayerSpawn_Post(id)
}

public task_refill_bpammo(const args[], id)
{
	if (!is_user_alive(id) || id == g_whoBoss)
		return;
	
	set_msg_block(get_user_msgid("AmmoPickup"), BLOCK_ONCE)
	ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[args[0]], AMMOTYPE[args[0]], MAXBPAMMO[args[0]])
}

public task_devilmana_reco()
{
	if(g_BossMana + get_pcvar_num(cvar_DevilRecoManaNum) > get_pcvar_num(cvar_DevilManaMax))
		g_BossMana = get_pcvar_num(cvar_DevilManaMax)
	else g_BossMana += get_pcvar_num(cvar_DevilRecoManaNum)
	
	if(!is_user_bot(g_whoBoss))
		client_print(g_whoBoss, print_center, "MP:%d/%d", g_BossMana, get_pcvar_num(cvar_DevilManaMax))
}

public task_godmode_light()
{
	static origin[3]
	get_user_origin(g_whoBoss, origin)
	
	// Colored Aura
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_DLIGHT) // TE id
	write_coord(origin[0]) // x
	write_coord(origin[1]) // y
	write_coord(origin[2]) // z
	write_byte(20) // radius
	write_byte(255) // r
	write_byte(5) // g
	write_byte(5) // b
	write_byte(2) // life
	write_byte(0) // decay rate
	message_end()
}

public task_longjump_off()
{
	delete_bit(g_isNoDamage, g_whoBoss)
	fm_set_rendering(g_whoBoss,kRenderFxNone, 0,0,0, kRenderNormal, 0)
	set_pev(g_whoBoss, pev_takedamage, 2.0)
}

public task_godmode_off()
{
	set_pev(g_whoBoss, pev_takedamage, 2.0)
	delete_bit(g_isNoDamage, g_whoBoss)
	fm_set_rendering(g_whoBoss,kRenderFxNone, 0,0,0, kRenderNormal, 0)
	remove_task( TASK_GODMODE_LIGHT )
}

public task_scare_off(id)
{
	id -= TASK_SCARE_OFF
	fm_set_rendering(id,kRenderFxNone, 0,0,0, kRenderNormal, 0)
	remove_task( id+TASK_SCARE_OFF )
}

public task_blind_off(id)
{
	id -= TASK_BLIND_OFF
	msg_screen_fade(id, 255, 255, 255, 0)
	fm_set_rendering(id,kRenderFxNone, 0,0,0, kRenderNormal, 0)
	remove_task( id+TASK_BLIND_OFF )
}

public task_disappear_off()
{
	set_pev(g_whoBoss, pev_rendermode, kRenderNormal)
	set_pev(g_whoBoss, pev_effects, g_PlayerEffect[g_whoBoss])
}

public task_set_user_nvision(id)
{
	id -= TASK_NVISION
	static origin[3]
	get_user_origin(id, origin)
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, id)
	write_byte(TE_DLIGHT) // TE id
	write_coord(origin[0]) // x
	write_coord(origin[1]) // y
	write_coord(origin[2]) // z
	write_byte(80)
	
	if(id == g_whoBoss)
	{
		write_byte(get_pcvar_num(cvar_NvgColor_Boss[0]))
		write_byte(get_pcvar_num(cvar_NvgColor_Boss[1]))
		write_byte(get_pcvar_num(cvar_NvgColor_Boss[2]))
	}
	else
	{
		write_byte(get_pcvar_num(cvar_NvgColor_Human[0]))
		write_byte(get_pcvar_num(cvar_NvgColor_Human[1]))
		write_byte(get_pcvar_num(cvar_NvgColor_Human[2]))
	}
	
	write_byte(2) // life
	write_byte(0) // decay rate
	message_end()
}

public task_spec_nvision(id)
{
	id -= TASK_SPEC_NVISION
	
	if(!is_user_valid_connected(id) || get_bit(g_isAlive, id) || is_user_bot(id))
		return;
	
	native_set_user_nightvision(id, 1)
}

public func_critical(taskid)
{
	static id
	if(taskid > g_MaxPlayer)
		id = taskid-TASK_CRITICAL
	else
		id = taskid
	
	if(g_whoBoss == id)
	{
		remove_task(taskid)
		delete_bit(g_isCrit, id)
		return;
	}
	
	if(get_bit(g_isCrit, id))
	{
		delete_bit(g_isCrit, id)
		func_critical(id)
		return;
	}
	
	new percent = random_num(1,100)
	
	if(percent <= get_pcvar_num(cvar_HumanCritPercent))
	{
		set_bit(g_isCrit, id)
		set_task(1.0,"func_critical",id+TASK_CRITICAL)
		return;
	}
	
	set_task(2.0,"func_critical",id+TASK_CRITICAL)
}

/* =====================

			 Menu
			 
===================== */
public show_menu_main(id)
{
	new Menu[256],Len;
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, Game_Description)
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "^n^n")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r1. \w%L^n", id, "MENU_WEAPON")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r2. \w%L^n", id, "MENU_ABILITY")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r3. \w%L^n", id, "MENU_PACK")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r4. \w%L^n", id, "MENU_EQUIP")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r5. \w%L^n", id, "MENU_SHOP")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r6. \y%L^n", id, "MENU_CONVERT")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r9. \w%L^n", id, "MENU_ADMIN")
	
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "^n^n\r0.\w %L", id, "MENU_EXIT")
	
	show_menu(id, KEYSMENU, Menu, -1, "Main Menu")
	return PLUGIN_HANDLED
}

public menu_main(id, key)
{
	switch(key)
	{
		case 0: show_menu_weapon(id)
		case 1: show_menu_ability(id)
		case 2: show_menu_pack(id)
		case 3: show_menu_equip(id)
		case 4: show_menu_shop(id)
		case 5: show_menu_convert(id)
		case 8: show_menu_admin(id)
	}
	
	return PLUGIN_HANDLED;
}

public show_menu_weapon(id)
{
	new Menu[128],Len;
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "%L^n^n", id, "MENU_WEAPON")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r1. \w%L^n",id,"MENU_WEAPON_FREE")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r2. \w%L^n",id,"MENU_WEAPON_GASH")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r3. \w%L^n",id,"MENU_WEAPON_SPECIAL")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r4. \w%L^n",id,"MENU_WEAPON_SECOND")
	
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "^n^n\r0.\w %L", id, "MENU_EXIT")
	show_menu(id, KEYSMENU, Menu,-1,"Weapon Menu")
	
	return PLUGIN_HANDLED;
}

public menu_weapon(id, key)
{
	if(id==g_whoBoss)
	{
		client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "NOT_HUMAN");
		return PLUGIN_HANDLED;
	}
	
	switch(key)
	{
		case 0: show_menu_weapon_free(id)
		case 1: show_menu_weapon_gash(id)
		case 2: show_menu_weapon_special(id)
		case 3: show_menu_weapon_second(id)
	}
	return PLUGIN_HANDLED;
}

public show_menu_weapon_free(id)
{
	if(id==g_whoBoss)
	{
		client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "NOT_HUMAN");
		return PLUGIN_HANDLED;
	}
	
	new Menu[512],Len;
	
	new BaseLvNeed = get_pcvar_num(cvar_BaseWpnNeedLv)
	new LvPreWpn = get_pcvar_num(cvar_BaseWpnPreLv)
	new NeedLv = BaseLvNeed
	
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "%L^n^n", id, "MENU_WEAPON_FREE")
	if(g_Menu_WpnFree_Page[id] == 0)
	{
		for(new i = 0; i < sizeof g_WpnFreeFrist_Name; i++)
		{
			if(g_Level[id] < NeedLv)
				Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r%d. \d%s %L^n", i+1, g_WpnFreeFrist_Name[i] ,id, "HOW_MANY_LV_NEED", NeedLv)
			else Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r%d. \w%s \d%L^n", i+1, g_WpnFreeFrist_Name[i] ,id, "HOW_MANY_LV_NEED", NeedLv)
			NeedLv += LvPreWpn
		}
	}
	else if(g_Menu_WpnFree_Page[id] == 1)
	{
		NeedLv += sizeof g_WpnFreeFrist_Name * LvPreWpn
		for(new i = 0; i < sizeof g_WpnFreeSec_Name; i++)
		{
			if(g_Level[id] < NeedLv)
				Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r%d. \d%s %L^n", i+1, g_WpnFreeSec_Name[i] ,id, "HOW_MANY_LV_NEED", NeedLv)
			else Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r%d. \w%s \d%L^n", i+1, g_WpnFreeSec_Name[i] ,id, "HOW_MANY_LV_NEED", NeedLv)
			NeedLv += LvPreWpn
		}
	}
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "^n^n\r9. \w%L/%L^n", id, "MENU_NEXT", id, "MENU_BACK")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r0.\w %L", id, "MENU_EXIT")
	show_menu(id,KEYSMENU,Menu,-1,"WeaponFree Menu")
	return PLUGIN_HANDLED;
}

public menu_weapon_free(id, key)
{
	if(id==g_whoBoss)
	{
		client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "NOT_HUMAN");
		return PLUGIN_HANDLED;
	}
	
	if(key == 9) //Exit
	{
		g_Menu_WpnFree_Page[id] = 0;
		return PLUGIN_HANDLED;
	}
	if(key == 8)
	{
		if(g_Menu_WpnFree_Page[id] == 1)
		{
			g_Menu_WpnFree_Page[id] = 0
			show_menu_weapon_free(id)
		}
		else
		{
			g_Menu_WpnFree_Page[id] = 1
			show_menu_weapon_free(id)
		}
		return PLUGIN_HANDLED
	}
	if(get_bit(g_isBuyWpnMain, id))
	{
		client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "HAVE_MAIN_WPN");
		return PLUGIN_HANDLED
	}
	
	new BaseLvNeed = get_pcvar_num(cvar_BaseWpnNeedLv)
	new LvPreWpn = get_pcvar_num(cvar_BaseWpnPreLv)
	new NeedLv = BaseLvNeed
	new args[1]
	
	
	if(g_Menu_WpnFree_Page[id] == 0)
	{
		if(NeedLv + LvPreWpn*key > g_Level[id])
		{
			client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "NO_LEVEL");
			return PLUGIN_HANDLED
		}
		client_color_print(id, "^x04[DevilEscape]^x01%L%s", LANG_PLAYER, "YOU_CHOOSE_THIS_WPN", g_WpnFreeFrist_Name[key]);
		fm_give_item(id, g_WpnFreeFrist[key])
		args[0] = g_WpnFreeFrist_CSW[key]
	}
	else
	{
		if(NeedLv + LvPreWpn*(key+7) > g_Level[id])
		{
			client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "NO_LEVEL");
			return PLUGIN_HANDLED
		}
		client_color_print(id, "^x04[DevilEscape]^x01%L%s", LANG_PLAYER, "YOU_CHOOSE_THIS_WPN", g_WpnFreeSec_Name[key]);
		fm_give_item(id, g_WpnFreeSec[key])
		args[0] = g_WpnFreeSec_CSW[key]
	}
	task_refill_bpammo(args[0], id)
	set_bit(g_isBuyWpnMain, id)
	g_Menu_WpnFree_Page[id] = 0;
	
	return PLUGIN_HANDLED
}

public show_menu_weapon_gash(id)
{
	if(id==g_whoBoss)
	{
		client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "NOT_HUMAN");
		return PLUGIN_HANDLED;
	}
	new Menuitem[64], Menu, CharNum[3]
	formatex(Menuitem, charsmax(Menuitem), "\w%L", LANG_PLAYER, "MENU_WEAPON_GASH")
	Menu = menu_create(Menuitem, "menu_weapon_gash")
	for(new i = 0; i < g_GashWpn_Num; i++)
	{
		num_to_str(i+1, CharNum, 2)
		if(g_Pack_GashWpn[id][i])
			ArrayGetString(g_GashWpn_Name, i, Menuitem, charsmax(Menuitem))
		else
		{
			new buffer[32]
			ArrayGetString(g_GashWpn_Name, i, buffer, charsmax(buffer))
			formatex(Menuitem, charsmax(Menuitem), "\d%s", buffer)
		}
		menu_additem(Menu, Menuitem, CharNum)
	}
	formatex(Menuitem, charsmax(Menuitem), "%L", LANG_PLAYER, "MENU_BACK") 
	menu_setprop(Menu, MPROP_BACKNAME, Menuitem)
	formatex(Menuitem, charsmax(Menuitem), "%L", LANG_PLAYER, "MENU_NEXT") 
	menu_setprop(Menu, MPROP_NEXTNAME, Menuitem)
	formatex(Menuitem, charsmax(Menuitem), "%L", LANG_PLAYER, "MENU_EXIT") 
	menu_setprop(Menu, MPROP_EXITNAME, Menuitem)
	
	menu_display(id, Menu)
	
	return PLUGIN_HANDLED
}

public menu_weapon_gash(id, menu, item)
{
	if(id==g_whoBoss)
	{
		client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "NOT_HUMAN");
		return PLUGIN_HANDLED;
	}
	
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	if(get_bit(g_isBuyWpnMain, id))
	{
		client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "HAVE_MAIN_WPN");
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}
	
	new data[6], access, callback;
	menu_item_getinfo(menu, item, access, data,5, _, _, callback);
	new key = str_to_num(data);
	
	if(!g_Pack_GashWpn[id][key-1])	//没这玩意儿
	{
		client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "HAVE_NO_THIS_WPN")
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	ExecuteForward(g_fwGashWpnSelect, g_fwDummyResult, id, key-1)
	
	new buffer[32]
	ArrayGetString(g_GashWpn_Name, key-1, buffer, charsmax(buffer))
	client_color_print(id, "^x04[DevilEscape]^x01%L^x03%s", LANG_PLAYER, "YOU_CHOOSE_THIS_WPN", buffer);
	set_bit(g_isBuyWpnMain, id)
	menu_destroy(menu);
	return PLUGIN_HANDLED;
	
}

public show_menu_weapon_special(id)
{
	if(id==g_whoBoss)
	{
		client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "NOT_HUMAN");
		return PLUGIN_HANDLED;
	}
	
	new Menuitem[64], Menu, CharNum[3]
	formatex(Menuitem, charsmax(Menuitem), "\w%L", LANG_PLAYER, "MENU_WEAPON_SPECIAL")
	Menu = menu_create(Menuitem, "menu_weapon_special")
	
	for(new i = 0; i < g_SpWpn_Num; i++)
	{
		num_to_str(i+1, CharNum, 2)
		if(g_Pack_SpWpn[id][i])
			ArrayGetString(g_SpWpn_Name, i, Menuitem, charsmax(Menuitem))
		else
		{
			new buffer[32]
			ArrayGetString(g_SpWpn_Name, i, buffer, charsmax(buffer))
			formatex(Menuitem, charsmax(Menuitem), "\d%s", buffer)
		}
		
		menu_additem(Menu, Menuitem, CharNum)
	}
	
	formatex(Menuitem, charsmax(Menuitem), "%L", LANG_PLAYER, "MENU_BACK") 
	menu_setprop(Menu, MPROP_BACKNAME, Menuitem)
	formatex(Menuitem, charsmax(Menuitem), "%L", LANG_PLAYER, "MENU_NEXT") 
	menu_setprop(Menu, MPROP_NEXTNAME, Menuitem)
	formatex(Menuitem, charsmax(Menuitem), "%L", LANG_PLAYER, "MENU_EXIT") 
	menu_setprop(Menu, MPROP_EXITNAME, Menuitem)
	
	menu_display(id, Menu)
	
	return PLUGIN_HANDLED
}

public menu_weapon_special(id, menu, item)
{
	if(id==g_whoBoss)
	{
		client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "NOT_HUMAN");
		return PLUGIN_HANDLED;
	}
	
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	if(get_bit(g_isBuyWpnMain, id))
	{
		client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "HAVE_MAIN_WPN");
		menu_destroy(menu);
		return PLUGIN_HANDLED
	}
	
	new data[6], access, callback;
	menu_item_getinfo(menu, item, access, data,5, _, _, callback);
	new key = str_to_num(data);
	
	if(!g_Pack_SpWpn[id][key-1])	//没这玩意儿
	{
		client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "HAVE_NO_THIS_WPN")
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	ExecuteForward(g_fwSpWpnSelect, g_fwDummyResult, id, key-1)
	
	new buffer[32]
	ArrayGetString(g_SpWpn_Name, key-1, buffer, charsmax(buffer))
	client_color_print(id, "^x04[DevilEscape]^x01%L^x03%s", LANG_PLAYER, "YOU_CHOOSE_THIS_WPN", buffer);
	set_bit(g_isBuyWpnMain, id)
	// task_refill_bpammo(args[0], id)
	menu_destroy(menu);
	return PLUGIN_HANDLED;
	
}

public show_menu_weapon_second(id)
{
	if(id==g_whoBoss)
	{
		client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "NOT_HUMAN");
		return PLUGIN_HANDLED;
	}
	
	new Menu[60],Len;
	new WpnName[32]
	
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "%L^n^n", id, "MENU_WEAPON_SECOND")
	for(new i = 0; i < g_SecondWpn_Num; i++)
	{
		ArrayGetString(g_SecondWpn_Name, i, WpnName, charsmax(WpnName))
		Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r%d. \w%s \dLv.%d^n", i+1, WpnName, ArrayGetCell(g_SecondWpn_Lv, i))
	}
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "^n^n\r0.\w %L", id, "MENU_EXIT")
	show_menu(id,KEYSMENU,Menu,-1,"WeaponSecond Menu")
	
	return PLUGIN_HANDLED;
}

public menu_weapon_second(id, key)
{
	if(id==g_whoBoss)
	{
		client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "NOT_HUMAN");
		return PLUGIN_HANDLED;
	}
	
	if(get_bit(g_isBuyWpnSec, id))
	{
		client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "HAVE_SEC_WPN");
		return PLUGIN_HANDLED
	}
	if(g_Level[id] >= ArrayGetCell(g_SecondWpn_Lv, key))
	{
		set_bit(g_isBuyWpnSec, id)
		ExecuteForward(g_fwSecondWpnSelect, g_fwDummyResult, id, key)
	}
	else
		client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "NO_LEVEL");
	
	return PLUGIN_HANDLED
}

public show_menu_ability(id)
{
	new Menu[256],Len;
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "%L^n^n",id,"MENU_ABILITY")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r1. \w%L \d%d Sp  %d/%d", id,"ABILITY_HEALTH", get_pcvar_num(cvar_AbilityHeaCost), g_Abi_Hea[id], get_pcvar_num(cvar_AbilityHeaMax))	
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, " [+%d HP]^n", get_pcvar_num(cvar_AbilityHeaAdd)*g_Abi_Hea[id])
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r2. \w%L \d%d Sp  %d/%d", id,"ABILITY_AGILITY", get_pcvar_num(cvar_AbilityAgiCost), g_Abi_Agi[id], get_pcvar_num(cvar_AbilityAgiMax))
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, " [+%d Speed]^n", floatround(get_pcvar_float(cvar_AbilityAgiAdd) * g_Abi_Agi[id]))	
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r3. \w%L \d%d Sp  %d/%d", id,"ABILITY_STRENGTH", get_pcvar_num(cvar_AbilityStrCost), g_Abi_Str[id], get_pcvar_num(cvar_AbilityStrMax))
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, " [+%d%% Dmg]^n", floatround(get_pcvar_float(cvar_AbilityStrAdd) * g_Abi_Str[id] * 100))	
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r4. \w%L \d%d Sp  %d/%d", id,"ABILITY_GRAVITY", get_pcvar_num(cvar_AbilityGraCost), g_Abi_Gra[id], get_pcvar_num(cvar_AbilityGraMax))
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, " [-%d%% g]^n", floatround(get_pcvar_float(cvar_AbilityGraAdd) * g_Abi_Gra[id] * 100))
	
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "^n^n\r0.\w %L", id, "MENU_EXIT")
	show_menu(id, KEYSMENU, Menu,-1,"Ability Menu")
	return PLUGIN_HANDLED
}

public menu_ability(id, key)
{
	if( key > 3 ) return PLUGIN_HANDLED
	
	new Sp_Cost[4]
	Sp_Cost[0] = get_pcvar_num(cvar_AbilityHeaCost); Sp_Cost[1] = get_pcvar_num(cvar_AbilityAgiCost)
	Sp_Cost[2] = get_pcvar_num(cvar_AbilityStrCost);  Sp_Cost[3] = get_pcvar_num(cvar_AbilityGraCost)
	// Abi_Max[0] = get_pcvar_num(cvar_AbilityHeaMax); Abi_Max[1] = get_pcvar_num(cvar_AbilityAgiMax)
	// Abi_Max[2] = get_pcvar_num(cvar_AbilityStrMax); Abi_Max[3] = get_pcvar_num(cvar_AbilityGraMax)
	
	
	if(g_Sp[id] < Sp_Cost[key])
	{
		client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "NO_SP");
		show_menu_ability(id)
		return PLUGIN_HANDLED
	}
			
	switch(key)
	{
		case 0: {
			if(g_Abi_Hea[id] >= get_pcvar_num(cvar_AbilityHeaMax)) 
			{
				client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "SKILL_LEARN_FULL");
				show_menu_ability(id)
				return PLUGIN_HANDLED
			}
			else g_Abi_Hea[id] ++;
		}
		case 1: {
			if(g_Abi_Agi[id] >= get_pcvar_num(cvar_AbilityAgiMax)) 
			{
				client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "SKILL_LEARN_FULL");
				show_menu_ability(id)
				return PLUGIN_HANDLED
			}
			else g_Abi_Agi[id] ++;
		}
		case 2: {
			if(g_Abi_Str[id] >= get_pcvar_num(cvar_AbilityStrMax)) 
			{
				client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "SKILL_LEARN_FULL");
				show_menu_ability(id)
				return PLUGIN_HANDLED
			}
			else g_Abi_Str[id] ++;
		}
		case 3: {
			if(g_Abi_Gra[id] >= get_pcvar_num(cvar_AbilityGraMax)) 
			{
				client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "SKILL_LEARN_FULL");
				show_menu_ability(id)
				return PLUGIN_HANDLED
			}
			else g_Abi_Gra[id] ++;
		}
	}
	
	g_Sp[id] -= Sp_Cost[key]		
	
	client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "SKILL_LEARN_SUCCESS");
	show_menu_ability(id)
	
	return PLUGIN_HANDLED
}

public show_menu_pack(id)
{	
	new Menuitem[32], Menu, CharNum[3]
	new MENU_PROP_EXIT[12], MENU_PROP_BACK[12], MENU_PROP_NEXT[12]
	formatex(MENU_PROP_EXIT, charsmax(MENU_PROP_EXIT),"%L", LANG_PLAYER, "MENU_EXIT") 
	formatex(MENU_PROP_BACK, charsmax(MENU_PROP_BACK),"%L", LANG_PLAYER, "MENU_BACK") 
	formatex(MENU_PROP_NEXT, charsmax(MENU_PROP_NEXT),"%L", LANG_PLAYER, "MENU_NEXT") 
	formatex(Menuitem, charsmax(Menuitem),"\w%L", LANG_PLAYER, "MENU_PACK") 
	Menu = menu_create(Menuitem, "menu_pack")
	
	for(new slot = 1; slot < MAX_PACKSLOT+1; slot++)
	{
		ArrayGetString(g_Item_Name, g_Pack[id][slot], Menuitem, charsmax(Menuitem))
		num_to_str(slot, CharNum, 2)
		menu_additem(Menu, Menuitem, CharNum)
	}
	
	menu_setprop(Menu, MPROP_BACKNAME, MENU_PROP_BACK)
	menu_setprop(Menu, MPROP_NEXTNAME, MENU_PROP_NEXT)
	menu_setprop(Menu, MPROP_EXITNAME, MENU_PROP_EXIT)
	menu_display(id, Menu)
}

public menu_pack(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	if(!get_pcvar_num(cvar_ItemOpen))
		client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "ITEM_CLOSE");
	
	new data[6],iName[64]
	new access, callback;
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	new key = str_to_num(data);
	
	if(!g_Pack[id][key])
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	//Test
	g_Pack_Select[id] = key
	show_menu_item_select(id, g_Pack[id][key])
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
	
}


public show_menu_item_select(id, itemid)
{
	new Menu[128],Len;
	new itemname[32], iteminfo[64]
	ArrayGetString(g_Item_Name, itemid, itemname, charsmax(itemname))
	ArrayGetString(g_Item_Info, itemid, iteminfo, charsmax(iteminfo))
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "^n\y%s^n", itemname)
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\d%s^n^n", iteminfo)
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r1. \w%L^n",id,"MENU_ITEM_CONFIRM")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r2. \w%L^n^n^n",id,"MENU_ITEM_DROP")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r0. \w%L",id,"MENU_EXIT")
	
	show_menu(id, KEYSMENU, Menu,-1,"ItemSelect Menu")
	return PLUGIN_HANDLED
}

public menu_item_select(id, key)
{
	new itemname[32], plrname[32]
	get_user_name(id, plrname, charsmax(plrname))
	ArrayGetString(g_Item_Name, g_Pack[id][g_Pack_Select[id]], itemname, charsmax(itemname))
	
	switch(key)
	{
		case 0:{
			ExecuteForward(g_fwItemSelect, g_fwDummyResult, id, g_Pack[id][g_Pack_Select[id]])
			g_Pack[id][g_Pack_Select[id]] = 0
			client_color_print(0, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "USE_ITEM", plrname, itemname)
		}
		case 1:{
			g_Pack[id][g_Pack_Select[id]] = 0
			client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "DROP_ITEM", itemname)
		}
	}
	
	g_Pack_Select[id] = 0
	return PLUGIN_HANDLED
}

public show_menu_equip(id)
{
}

public menu_equip(id, key)
{
}

public show_menu_shop(id)
{
	new Menu[128],Len;
	
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "%L^n^n", id, "MENU_SHOP")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r1. \w%L^n", id, "MENU_SHOP_ITEM")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r2. \w%L^n", id, "MENU_SHOP_WEAPON_GASH")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r3. \w%L^n", id, "MENU_SHOP_WEAPON_SPECIAL")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "^n^n\r0.\w %L", id, "MENU_EXIT")
	show_menu(id,KEYSMENU,Menu,-1,"Shop Menu")
	
	return PLUGIN_HANDLED;
}

public menu_shop(id, key)
{
	switch(key)
	{
		case 0: show_menu_shop_item(id)
		case 1: show_menu_shop_weapon_gash(id)
		case 2: show_menu_shop_weapon_special(id)
	}
	
	return PLUGIN_HANDLED
}

public show_menu_shop_item(id)
{	
	new Menuitem[32], Menu, CharNum[3]
	formatex(Menuitem, charsmax(Menuitem), "\w%L", LANG_PLAYER, "MENU_SHOP_ITEM")
	Menu = menu_create(Menuitem, "menu_shop_item")
	
	new itemname[29], use_max
	for(new i = 0; i < g_Shop_Item_Num; i++)
	{
		num_to_str(i+1, CharNum, 2)
		ArrayGetString(g_Shop_Item_Name, i, itemname, charsmax(itemname))
		if(!(use_max = ArrayGetCell(g_Shop_Item_Max, i)))
			formatex(Menuitem, charsmax(Menuitem), "%s \d%d %L", itemname, ArrayGetCell(g_Shop_Item_Price, i), LANG_PLAYER, "COIN")
		else formatex(Menuitem, charsmax(Menuitem), "%s [\y%d/%d\w] \d%d %L", itemname, g_Shop_Item_Times[id][i], use_max, ArrayGetCell(g_Shop_Item_Price, i), LANG_PLAYER, "COIN")
		menu_additem(Menu, Menuitem, CharNum)
	}
	
	formatex(Menuitem, charsmax(Menuitem), "%L", LANG_PLAYER, "MENU_BACK") 
	menu_setprop(Menu, MPROP_BACKNAME, Menuitem)
	formatex(Menuitem, charsmax(Menuitem), "%L", LANG_PLAYER, "MENU_NEXT") 
	menu_setprop(Menu, MPROP_NEXTNAME, Menuitem)
	formatex(Menuitem, charsmax(Menuitem), "%L", LANG_PLAYER, "MENU_EXIT") 
	menu_setprop(Menu, MPROP_EXITNAME, Menuitem)
	
	menu_display(id, Menu)
	return PLUGIN_HANDLED;
}

public menu_shop_item(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new data[6], access, callback;
	menu_item_getinfo(menu, item, access, data,5, _, _, callback);
	
	new select = str_to_num(data) - 1
	
	new itemprice = ArrayGetCell(g_Shop_Item_Price, select)
	new itemname[29], itemmax
	
	ArrayGetString(g_Shop_Item_Name, select, itemname, charsmax(itemname))
	itemmax = ArrayGetCell(g_Shop_Item_Max, select)
	if(itemmax <= g_Shop_Item_Times[id][select] && itemmax)
		client_color_print(id, "^x04[Shop]^x01%L", LANG_PLAYER, "SHOP_BUY_MAX")
	else
	{
		if(g_Coin[id] < itemprice)
			client_color_print(id, "^x04[Shop]^x01%L", LANG_PLAYER, "SHOP_BUY_FAILED")
		else{
			if(itemmax)
				g_Shop_Item_Times[id][select] += 1
			g_Coin[id] -= itemprice
			ExecuteForward(g_fwShopItemSelect, g_fwDummyResult, id, select)
			if(!g_fwDummyResult)
				client_color_print(id, "^x04[Shop]^x01%L", LANG_PLAYER, "SHOP_BUY_FAILED")
			else
				client_color_print(id, "^x04[Shop]^x01%L%s", LANG_PLAYER, "SHOP_BUY_SUCCESS", itemname)
		}
	}
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
	
}

public show_menu_shop_weapon_gash(id)
{
	new Menuitem[32], Menu, CharNum[3]
	formatex(Menuitem, charsmax(Menuitem), "\w%L", LANG_PLAYER, "MENU_SHOP_WEAPON_GASH")
	Menu = menu_create(Menuitem, "menu_shop_weapon_gash")
	new buffer[32]
	for(new i = 0; i < g_GashWpn_Num; i++)
	{
		num_to_str(i+1, CharNum, 2)
		ArrayGetString(g_GashWpn_Name, i, buffer, charsmax(buffer))
		formatex(Menuitem, charsmax(Menuitem), "%s \d%d %L", buffer, ArrayGetCell(g_GashWpn_Price, i), id, "GASH")
		menu_additem(Menu, Menuitem, CharNum)
	}
	formatex(Menuitem, charsmax(Menuitem), "%L", LANG_PLAYER, "MENU_BACK") 
	menu_setprop(Menu, MPROP_BACKNAME, Menuitem)
	formatex(Menuitem, charsmax(Menuitem), "%L", LANG_PLAYER, "MENU_NEXT") 
	menu_setprop(Menu, MPROP_NEXTNAME, Menuitem)
	formatex(Menuitem, charsmax(Menuitem), "%L", LANG_PLAYER, "MENU_EXIT") 
	menu_setprop(Menu, MPROP_EXITNAME, Menuitem)
	
	menu_display(id, Menu)
}

public menu_shop_weapon_gash(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], access, callback;
	menu_item_getinfo(menu, item, access, data,5, _, _, callback);
	new key = str_to_num(data);
	
	if(g_Pack_GashWpn[id][key-1])
	{
		client_color_print(id, "^x04[Shop]^x01%L", LANG_PLAYER, "SHOP_HAD_THIS_WPN")
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new GashCost = ArrayGetCell(g_GashWpn_Price, key-1)
	new buffer[32]
	
	if(g_Gash[id] >= GashCost)
	{
		g_Gash[id] -= GashCost
		ArrayGetString(g_GashWpn_Name, key-1, buffer, charsmax(buffer))
		g_Pack_GashWpn[id][key-1] = true
		client_color_print(id, "^x04[Shop]^x01%L%s", LANG_PLAYER, "SHOP_BUY_SUCCESS", buffer)
	}
	else client_color_print(id, "^x04[Shop]^x01%L", LANG_PLAYER, "SHOP_BUY_FAILED")
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public show_menu_shop_weapon_special(id)
{
	new Menuitem[32], Menu, CharNum[3]
	formatex(Menuitem, charsmax(Menuitem), "\w%L", LANG_PLAYER, "MENU_SHOP_WEAPON_SPECIAL")
	Menu = menu_create(Menuitem, "menu_shop_weapon_special")
	
	new buffer[32]
	new size = ArraySize(g_SpWpn_Name)
	for(new i = 0; i < size; i++)
	{
		num_to_str(i+1, CharNum, 2)
		ArrayGetString(g_SpWpn_Name, i, buffer, charsmax(buffer))
		formatex(Menuitem, charsmax(Menuitem), "%s \d%d %L", buffer, ArrayGetCell(g_SpWpn_Price, i), id, "GASH")
		menu_additem(Menu, Menuitem, CharNum)
	}
	
	formatex(Menuitem, charsmax(Menuitem), "%L", LANG_PLAYER, "MENU_BACK") 
	menu_setprop(Menu, MPROP_BACKNAME, Menuitem)
	formatex(Menuitem, charsmax(Menuitem), "%L", LANG_PLAYER, "MENU_NEXT") 
	menu_setprop(Menu, MPROP_NEXTNAME, Menuitem)
	formatex(Menuitem, charsmax(Menuitem), "%L", LANG_PLAYER, "MENU_EXIT") 
	menu_setprop(Menu, MPROP_EXITNAME, Menuitem)
	
	menu_display(id, Menu)
}

public menu_shop_weapon_special(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new data[6], access, callback;
	menu_item_getinfo(menu, item, access, data,5, _, _, callback);
	new key = str_to_num(data);
	if(g_Pack_SpWpn[id][key-1])
	{
		client_color_print(id, "^x04[Shop]^x01%L", LANG_PLAYER, "SHOP_HAD_THIS_WPN")
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new GashCost = ArrayGetCell(g_SpWpn_Price, key-1)
	new buffer[32]
	
	if(g_Gash[id] >= GashCost)
	{
		g_Gash[id] -= GashCost
		ArrayGetString(g_SpWpn_Name, key-1, buffer, charsmax(buffer))
		g_Pack_SpWpn[id][key-1] = true
		client_color_print(id, "^x04[Shop]^x01%L%s", LANG_PLAYER, "SHOP_BUY_SUCCESS", buffer)
	}
	else client_color_print(id, "^x04[Shop]^x01%L", LANG_PLAYER, "SHOP_BUY_FAILED")
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
	
}

public show_menu_skill(id)
{
	new Menu[250],Len;
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "%L^n^n",id,"MENU_HUMANSKILL")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r1. \w%L^n",id,"HUMANSKILL_FASTRUN")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r2. \w%L^n",id,"HUMANSKILL_ONLYHEADSHOT")
	
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "^n^n\r0.\w %L", id, "MENU_EXIT")
	show_menu(id,KEYSMENU,Menu,-1,"Skill Menu")
	return PLUGIN_HANDLED
}

public menu_skill(id,key)
{
	switch(key)
	{
		case 0:
		{
			client_print(0, print_chat, "skillmenu 0")
		}
	}
	return PLUGIN_HANDLED;
}

public show_menu_bossskill(id)
{
	new Menu[250],Len;
	
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\w%L^n^n",id,"MENU_BOSSSKILL")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r1. \w%L \d%dMP^n",id,"BOSSSKILL_LONGJUMP", get_pcvar_num(cvar_DevilLongjumpCost))
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r2. \w%L \d%dMP^n",id,"BOSSSKILL_SCARE", get_pcvar_num(cvar_DevilScareCost))
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r3. \w%L \d%dMP^n",id,"BOSSSKILL_BLIND", get_pcvar_num(cvar_DevilBlindCost))
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r4. \w%L \d%dMP^n",id,"BOSSSKILL_TELEPORT", get_pcvar_num(cvar_DevilTeleCost))
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r5. \w%L \d%dMP^n",id,"BOSSSKILL_GODMODE", get_pcvar_num(cvar_DevilGodCost))
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r6. \w%L \d%dMP^n",id,"BOSSSKILL_DISAPPEAR", get_pcvar_num(cvar_DevilDisappearCost))
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "^n^n\r0.\w %L", id, "MENU_EXIT")
		
	show_menu(id,KEYSMENU,Menu,-1,"Bossskill Menu")
	return PLUGIN_HANDLED
}

public menu_bossskill(id,key)
{
	if(!is_user_valid_connected(id) || !is_user_alive(id) || g_RoundStatus == Round_End) return PLUGIN_HANDLED;
	new name[32], skillname[10]
	get_user_name(id, name, charsmax(name))
	switch(key)
	{
		case 0:
		{
			if(bossskill_longjump())
			{
				formatex(skillname, charsmax(skillname),"%L", LANG_PLAYER, "BOSSSKILL_LONGJUMP")
				g_BossMana -= get_pcvar_num(cvar_DevilLongjumpCost)
				set_dhudmessage( 255, 255, 0,  DHUD_MSG_X, DHUD_MSG_Y, 1, 3.0, 1.0, 0.1, 1.0 );
				show_dhudmessage( 0, " %L", LANG_PLAYER, "DHUD_BOSS_USESKILL", name, skillname);
			}
		}
		case 1:
		{
			if(bossskill_scare(Float:{4000.0,400.0,1200.0},get_pcvar_float(cvar_DevilScareTime),get_pcvar_float(cvar_DevilScareRange)))
			{
				formatex(skillname, charsmax(skillname),"%L", LANG_PLAYER, "BOSSSKILL_SCARE")
				engfunc(EngFunc_EmitSound,g_whoBoss, CHAN_STATIC, snd_boss_scare, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				g_BossMana -= get_pcvar_num(cvar_DevilScareCost)
				set_dhudmessage( 255, 255, 0,  DHUD_MSG_X, DHUD_MSG_Y, 1, 3.0, 1.0, 0.1, 1.0 );
				show_dhudmessage( 0, " %L", LANG_PLAYER, "DHUD_BOSS_USESKILL", name, skillname);
			}
		}
		case 2:
		{
			if(bossskill_blind())
			{
				formatex(skillname, charsmax(skillname),"%L", LANG_PLAYER, "BOSSSKILL_BLIND")
				//音效
				g_BossMana -= get_pcvar_num(cvar_DevilBlindCost)
				set_dhudmessage( 255, 255, 0,  DHUD_MSG_X, DHUD_MSG_Y, 1, 3.0, 1.0, 0.1, 1.0 );
				show_dhudmessage( 0, " %L", LANG_PLAYER, "DHUD_BOSS_USESKILL",name,skillname);
			}
		}
		case 3:
		{
			if(bossskill_teleport())
			{
				formatex(skillname, charsmax(skillname),"%L", LANG_PLAYER, "BOSSSKILL_TELEPORT")
				engfunc(EngFunc_EmitSound,g_whoBoss, CHAN_STATIC, snd_boss_tele, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				g_BossMana -= get_pcvar_num(cvar_DevilTeleCost)
				set_dhudmessage( 255, 255, 0,  DHUD_MSG_X, DHUD_MSG_Y, 1, 3.0, 1.0, 0.1, 1.0 );
				show_dhudmessage( 0, " %L", LANG_PLAYER, "DHUD_BOSS_USESKILL",name,skillname);
			}
		}
		
		case 4:
		{
			if(bossskill_godmode())
			{
				formatex(skillname, charsmax(skillname),"%L", LANG_PLAYER, "BOSSSKILL_GODMODE")
				engfunc(EngFunc_EmitSound,g_whoBoss, CHAN_STATIC, snd_boss_god, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				g_BossMana -= get_pcvar_num(cvar_DevilGodCost)
				set_dhudmessage( 255, 255, 0,  DHUD_MSG_X, DHUD_MSG_Y, 1, 3.0, 1.0, 0.1, 1.0 );
				show_dhudmessage( 0, " %L", LANG_PLAYER, "DHUD_BOSS_USESKILL",name,skillname);
			}
		}
		case 5:
		{
			if(bossskill_disappear())
			{
				formatex(skillname, charsmax(skillname),"%L", LANG_PLAYER, "BOSSSKILL_DISAPPEAR")
				engfunc(EngFunc_EmitSound,g_whoBoss, CHAN_STATIC, snd_boss_god, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				g_BossMana -= get_pcvar_num(cvar_DevilDisappearCost)
				set_dhudmessage( 255, 255, 0,  DHUD_MSG_X, DHUD_MSG_Y, 1, 3.0, 1.0, 0.1, 1.0 );
				show_dhudmessage( 0, " %L", LANG_PLAYER, "DHUD_BOSS_USESKILL",name,skillname);
			}
		}
	}
	
	return PLUGIN_HANDLED;
}

public show_menu_admin(id)
{
	new Menu[250],Len;
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\w%L^n^n",id,"MENU_ADMIN")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r1. \w%L^n",id,"MENU_ADMIN_SELECT_BOSS")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r2. \w%L^n",id,"MENU_ADMIN_GIVE")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r3. \w%L^n",id,"MENU_ADMIN_GIVE_ALL")
	
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "^n^n\r0.\w %L", id, "MENU_EXIT")
		
	show_menu(id,KEYSMENU,Menu,-1,"Admin Menu")
	return PLUGIN_HANDLED
	
}

public menu_admin(id, key)
{
	switch(key)
	{
		case 0:{
			g_Menu_Admin_Select[id] = ADMIN_SELECT_BOSS
			show_menu_plrlist(id)
		}
		case 1:{
			show_menu_admin_give(id)
		}
	}
}

public show_menu_admin_give(id)
{
	new Menu[128], Len;
	
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "%L^n^n",id,"MENU_ADMIN_GIVE")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r1. \w%L^n",id,"COIN")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r2. \w%L^n",id,"GASH")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r3. \w%L^n",id,"LEVEL")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r4. \w%L^n",id,"XP")
	
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "^n^n\r0.\w %L", id, "MENU_EXIT")
	show_menu(id,KEYSMENU,Menu,-1,"AdminGive Menu")
	
	return PLUGIN_HANDLED
}

public menu_admin_give(id, key)
{
	switch(key)
	{
		case 0: g_Menu_Admin_Select[id] = ADMIN_GIVE_COIN
		case 1: g_Menu_Admin_Select[id] = ADMIN_GIVE_GASH
		case 2: g_Menu_Admin_Select[id] = ADMIN_GIVE_LEVEL
		case 3: g_Menu_Admin_Select[id] = ADMIN_GIVE_XP
		default: return PLUGIN_HANDLED;
	}
	show_menu_plrlist(id)
	return PLUGIN_HANDLED;
}

public show_menu_plrlist(id)
{	
	new Menuitem[32], Menu
	new MENU_PROP_EXIT[12], MENU_PROP_BACK[12], MENU_PROP_NEXT[12]
	formatex(MENU_PROP_EXIT, charsmax(MENU_PROP_EXIT),"%L", LANG_PLAYER, "MENU_EXIT") 
	formatex(MENU_PROP_BACK, charsmax(MENU_PROP_BACK),"%L", LANG_PLAYER, "MENU_BACK") 
	formatex(MENU_PROP_NEXT, charsmax(MENU_PROP_NEXT),"%L", LANG_PLAYER, "MENU_NEXT") 
	
	switch(g_Menu_Admin_Select[id])
	{
		case ADMIN_SELECT_BOSS: formatex(Menuitem, charsmax(Menuitem),"\w%L", LANG_PLAYER, "MENU_ADMIN_SELECT_BOSS") 
		case ADMIN_GIVE: formatex(Menuitem, charsmax(Menuitem),"\w%L", LANG_PLAYER, "MENU_ADMIN_GIVE") 
	}
	if(g_Menu_Admin_Select[id] >= ADMIN_GIVE && g_Menu_Admin_Select[id] <= ADMIN_GIVE_LEVEL)
		formatex(Menuitem, charsmax(Menuitem),"\w%L", LANG_PLAYER, "MENU_ADMIN_GIVE") 
	
	Menu = menu_create(Menuitem, "menu_plrlist")
	
	new Count, PlrName[28], Char_Count[3]
	for(new i = 1; i < g_MaxPlayer; i++)
	{
		if(!get_bit(g_isConnect, i))
			continue;
		
		get_user_name(i, PlrName, charsmax(PlrName))
		
		if(g_Menu_Admin_Select[id] == ADMIN_SELECT_BOSS)
		{
			if(is_user_alive(id)) formatex(Menuitem, charsmax(Menuitem), "%s", PlrName)
			else formatex(Menuitem, charsmax(Menuitem), "\d%s", PlrName)
		}
		else
			 formatex(Menuitem, charsmax(Menuitem), "%s", PlrName)
		 
		Count++
		num_to_str(Count, Char_Count, 3)
		menu_additem(Menu, Menuitem, Char_Count)
		g_Menu_Admin_Select_PlrKey[id][Count] = i
	}
	
	menu_setprop(Menu, MPROP_BACKNAME, MENU_PROP_BACK)
	menu_setprop(Menu, MPROP_NEXTNAME, MENU_PROP_EXIT)
	menu_setprop(Menu, MPROP_EXITNAME, MENU_PROP_EXIT)
	menu_display(id, Menu)
}

public menu_plrlist(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	
	new data[6],iName[64]
	new access, callback;
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	new key = str_to_num(data);
	
	new AdminName[18], PlrName[18]
	get_user_name(id, AdminName, charsmax(AdminName))
	get_user_name(g_Menu_Admin_Select_PlrKey[id][key], PlrName, charsmax(PlrName))
	
	new AdminPut = g_Menu_Admin_Select[id]
	switch(AdminPut)
	{
		case ADMIN_SELECT_BOSS:
		{
			if(!is_user_alive(g_Menu_Admin_Select_PlrKey[id][key]))
				client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "ADMIN_PLAYER_MUST_ALIVE");
			else
			{
				if(g_RoundStatus != Round_Start)
					client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "ADMIN_ROUND_HAD_START");
				else
				{
					client_color_print(0, "^x04[ADMIN]^x03%L", LANG_PLAYER, "ADMIN_CHOOSE_BOSS", AdminName, PlrName)
					g_Admin_Select_Boss = g_Menu_Admin_Select_PlrKey[id][key]
					task_round_start()
				}
			}
		}
	}
	if(AdminPut >= ADMIN_GIVE && AdminPut <= ADMIN_GIVE_LEVEL) // 42-82
	{
		g_Admin_Select_Plr[id] = g_Menu_Admin_Select_PlrKey[id][key]
		set_hudmessage(192, 0, 0, -1.0, -1.0, 1, 6.0, 1.5, 0.3, 0.3, 0)
		ShowSyncHudMsg(id, g_Hud_Center, "%L" , LANG_PLAYER, "ADMIN_INPUT_MSG")
	}
	
	menu_destroy(menu);
	//test
	
	return PLUGIN_HANDLED;
}

public show_menu_convert(id)
{
	new Menu[256], Len;
	new Coin2Gash = get_pcvar_num(cvar_ConvertCoinToGash)
	new Gash2Coin = get_pcvar_num(cvar_ConvertGashToCoin)
	
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "%L^n^n",id,"MENU_CONVERT")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r1. \w%d %L = 1 %L^n", Coin2Gash, id, "COIN", id, "GASH")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r2. \w%d %L = 10 %L^n", Coin2Gash * 10, id, "COIN", id, "GASH")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r3. \w%d %L = 100 %L^n", Coin2Gash * 100, id, "COIN", id, "GASH")
	
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r4. \w1 %L = %d %L^n", id, "GASH", Gash2Coin, id, "COIN")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r5. \w10 %L = %d %L^n", id, "GASH", Gash2Coin*10, id, "COIN")
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "\r6. \w100 %L = %d %L^n", id, "GASH", Gash2Coin*100, id, "COIN")
	
	Len += formatex(Menu[Len], sizeof Menu - Len - 1, "^n^n\r0.\w %L", id, "MENU_EXIT")
	show_menu(id,KEYSMENU,Menu,-1,"Convert Menu")
	
	return PLUGIN_HANDLED
}

public menu_convert(id, key)
{
	if(key <= 2)
	{
		new Coin2Gash = get_pcvar_num(cvar_ConvertCoinToGash)
		new mul = 1
		for(new i = 0; i < key; i++)
			mul *= 10
		
		Coin2Gash *= mul
		if(g_Coin[id] < Coin2Gash)	client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "CONVERT_FAILED");
		else{
			g_Coin[id] -= Coin2Gash; g_Gash[id] += mul
			client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "CONVERT_SUCCESS");
		}
		
		return PLUGIN_HANDLED
	}
	
	if(key >= 3 && key <= 5)
	{
		new mul = 1
		new Gash2Coin = get_pcvar_num(cvar_ConvertGashToCoin)
		for(new i = 0; i < key - 3; i++)
			mul *= 10
		
		Gash2Coin *= mul
		if(g_Gash[id] < mul) client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "CONVERT_FAILED");
		else {
			g_Gash[id] -= mul; g_Coin[id] += Gash2Coin
			client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "CONVERT_SUCCESS");
		}
			
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_HANDLED
}
/* =====================

			 Game Function
			 
===================== */

//选BOSS
gm_choose_boss()
{
	new id
	while(!is_user_alive(id) || !get_bit(g_isConnect, id))
		id = random_num(1, g_MaxPlayer)
	
	return id
}

//重设变量
gm_reset_vars()
{
	g_whoBoss = -1;
	g_BossMana = 0;
	g_PlayerInGame = 0;
	g_isNoDamage = 0;
	g_isCrit = 0;
	g_isMiniCrit = 0;
	g_isBuyWpnMain = 0;
	g_isBuyWpnSec = 0;
	g_isNvision = 0;
	g_isAlive = 0;
	g_hasNvision = 0;
	g_Admin_Select_Boss = 0
	
	g_1st_Dmg = 0.0
	g_1st_ID = 0
	g_2nd_Dmg = 0.0
	g_2nd_ID = 0
	g_3rd_Dmg = 0.0
	g_3rd_ID = 0
	
	remove_task(TASK_DEVILMANA_RECO)
	remove_task(TASK_GODMODE_LIGHT)
	remove_task(TASK_RANK)
	for(new i = 1 ; i <= g_MaxPlayer; i++)
	{
		g_Dmg[i] = 0.0;
		g_AttackCooldown[i] = 0.0;
		remove_task(i+TASK_CRITICAL)
		remove_task(i+TASK_NVISION)
		func_critical(i);
		for(new j = 0; j < g_Shop_Item_Num; j ++)
			g_Shop_Item_Times[i][j] = 0
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
	if(get_bit(g_isChangingPW, id))
	{
		client_color_print(id, "^x04[DevilEscape]%L^x03%s",  LANG_PLAYER, "CHANGEPASSWORD_SUCCESS", password)
		client_color_print(id, "^x04[DevilEscape]%L^x03%s",  LANG_PLAYER, "CHANGEPASSWORD_SUCCESS", password)
		client_color_print(id, "^x04[DevilEscape]%L^x03%s",  LANG_PLAYER, "CHANGEPASSWORD_SUCCESS", password)
	}
	else
	{
		client_color_print(id, "^x04[DevilEscape]%L^x03%s",  LANG_PLAYER, "REGISTER_SUCCESS", password)
		client_color_print(id, "^x04[DevilEscape]%L^x03%s",  LANG_PLAYER, "REGISTER_SUCCESS", password)
		client_color_print(id, "^x04[DevilEscape]%L^x03%s",  LANG_PLAYER, "REGISTER_SUCCESS", password)
	}
	msg_change_team_info(id, iteam)
	set_bit(g_isRegister, id)
	delete_bit(g_isChangingPW, id)
	
	//储存密码
	new szFileDir[128], szUserName[32];
	get_user_name(id, szUserName, charsmax(szUserName))
	formatex(szFileDir, charsmax(szFileDir), "%s/%s.ini", g_savesDir, szUserName)
	copy(g_PlayerPswd[id], 11, password)
	gm_user_save(id)
	
}

gm_user_login(id, const password[])
{	
	static iteam[10]
	get_user_team(id, iteam, 9)
	msg_change_team_info(id, "SPECTATOR")
	
	if(equal(g_PlayerPswd[id], password))
	{
		client_color_print(id, "^x04[DevilEscape]^x03%L",  LANG_PLAYER, "LOGIN_SUCCESS")
		client_color_print(id, "^x04[DevilEscape]^x03%L",  LANG_PLAYER, "LOGIN_SUCCESS")
		client_color_print(id, "^x04[DevilEscape]^x03%L",  LANG_PLAYER, "LOGIN_SUCCESS")
		set_bit(g_isLogin, id)
		client_cmd(id, "chooseteam")
		set_task(get_pcvar_float(cvar_AutosaveTime), "task_autosave", id+TASK_AUTOSAVE, _, _, "b")
	}
	else
	{
		client_color_print(id, "^x04[DevilEscape]^x03%L",  LANG_PLAYER, "LOGIN_FAILED")
		g_LoginRetry[id] ++
	}
	
	msg_change_team_info(id, iteam)
}

gm_user_save(id)
{
	new szUserName[32], szFileDir[128]
	get_user_name(id, szUserName, charsmax(szUserName))
	formatex(szFileDir, charsmax(szFileDir), "%s/%s.ini", g_savesDir, szUserName)
	
	new kv = kv_create(szUserName)
	kv_set_string(kv, "Password", g_PlayerPswd[id]);
	
	new sta = kv_create("Status");
	kv_set_int(sta, "Sp", g_Sp[id]); kv_set_int(sta, "Level", g_Level[id]);
	kv_set_int(sta, "Coin", g_Coin[id]); kv_set_int(sta, "Gash", g_Gash[id]);
	kv_set_int(sta, "Xp", g_Xp[id]);
	kv_add_sub_key(kv, sta)
	
	new abi = kv_create("Ability");
	kv_set_int(abi, "Hea", g_Abi_Hea[id]); kv_set_int(abi, "Agi", g_Abi_Agi[id]);
	kv_set_int(abi, "Str", g_Abi_Str[id]); kv_set_int(abi, "Gra", g_Abi_Gra[id]);
	kv_add_sub_key(kv, abi)
	
	new wpnlv = kv_create("WeaponLv");
	for(new i = 1; i < sizeof g_WpnLv[]; i++)
		kv_set_int(wpnlv, WEAPONCSWNAME[i], g_WpnLv[id][i])
	kv_add_sub_key(kv, wpnlv)
	
	new wpnxp = kv_create("WeaponXp");
	for(new i = 1; i < sizeof g_WpnXp[]; i++)
		kv_set_int(wpnxp, WEAPONCSWNAME[i], g_WpnXp[id][i])
	kv_add_sub_key(kv, wpnxp)
	
	new pack = kv_create("Pack");
	new pack_slotname[8];
	for(new i = 1; i < sizeof g_Pack[]; i++)
	{
		formatex(pack_slotname, charsmax(pack_slotname), "Slot %d", i)
		kv_set_int(pack, pack_slotname, g_Pack[id][i])
	}
	kv_add_sub_key(kv, pack)
	
	new spwpnpack = kv_create("SpWpn Pack");
	new buffer[32]
	for(new i = 0; i < g_SpWpn_Num; i++)
	{
		ArrayGetString(g_SpWpn_Name, i, buffer, charsmax(buffer))
		
		if(g_Pack_SpWpn[id][i])
			kv_set_int(spwpnpack, buffer, 1)
		else
			kv_set_int(spwpnpack, buffer, 0)
	}
	kv_add_sub_key(kv, spwpnpack)
	
	new gashwpnpack = kv_create("GashWpn Pack");
	for(new i = 0; i < g_GashWpn_Num; i++)
	{
		ArrayGetString(g_GashWpn_Name, i, buffer, charsmax(buffer))
		
		if(g_Pack_GashWpn[id][i])
			kv_set_int(gashwpnpack, buffer, 1)
		else
			kv_set_int(gashwpnpack, buffer, 0)
	}
	kv_add_sub_key(kv, gashwpnpack)
	
	kv_save_to_file(kv, szFileDir);
	kv_delete(kv);
	
	client_color_print(id, "^x04[DevilEscape]^x01%L", LANG_PLAYER, "SAVE_SUCCESS");
	
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
	{
		kv_get_string(kv, "Password", g_PlayerPswd[id], 11)
		set_bit(g_isRegister, id)
	}
	
	new sta = kv_find_key(kv, "Status")
	g_Sp[id] = kv_get_int(sta, "Sp"); g_Level[id] = kv_get_int(sta, "Level")
	g_Coin[id] = kv_get_int(sta, "Coin"); g_Gash[id] = kv_get_int(sta, "Gash")
	g_Xp[id] = kv_get_int(sta, "Xp")
	
	new abi = kv_find_key(kv, "Ability")
	g_Abi_Hea[id] = kv_get_int(abi, "Hea"); g_Abi_Agi[id] = kv_get_int(abi, "Agi")
	g_Abi_Str[id] = kv_get_int(abi, "Str"); g_Abi_Gra[id] = kv_get_int(abi, "Gra")
	
	new i
	new wpnlv = kv_find_key(kv, "WeaponLv");
	for(i = 1; i < sizeof g_WpnLv[]; i++)
		g_WpnLv[id][i] = kv_get_int(wpnlv, WEAPONCSWNAME[i])
	
	new wpnxp = kv_find_key(kv, "WeaponXp");
	for(i = 1; i < sizeof g_WpnXp[]; i++)
		g_WpnXp[id][i] = kv_get_int(wpnxp, WEAPONCSWNAME[i])
	
	new pack = kv_find_key(kv, "Pack")
	new buffer[32]
	new pack_slotname[8]
	for(i = 1; i < sizeof g_Pack[]; i++)
	{
		formatex(pack_slotname, charsmax(pack_slotname), "Slot %d", i)
		g_Pack[id][i] = kv_get_int(pack, pack_slotname)
	}
	
	new spwpnpack = kv_find_key(kv,"SpWpn Pack");
	for(i = 0; i < g_SpWpn_Num; i++)
	{
		ArrayGetString(g_SpWpn_Name, i, buffer, charsmax(buffer))
		if(kv_get_int(spwpnpack, buffer))
			g_Pack_SpWpn[id][i] = true
		else g_Pack_SpWpn[id][i] = false
	}
	
	new gashwpnpack = kv_find_key(kv,"GashWpn Pack");
	for(i = 0; i < g_GashWpn_Num; i++)
	{
		ArrayGetString(g_GashWpn_Name, i, buffer, charsmax(buffer))
		if(kv_get_int(gashwpnpack, buffer))
			g_Pack_GashWpn[id][i] = true
		else g_Pack_GashWpn[id][i] = false
	}
	
	kv_delete(kv)
}

gm_admin_give(id)
{
	new PlrName[22], AdminName[22]
	get_user_name(id, AdminName, charsmax(AdminName))
	get_user_name(g_Admin_Select_Plr[id], PlrName, charsmax(PlrName))
	switch(g_Menu_Admin_Select[id])
	{
		case ADMIN_GIVE_COIN:
		{
			g_Coin[g_Admin_Select_Plr[id]] += g_Admin_Input[id]
			client_color_print(0, "^x04[ADMIN]^x03%L%L",  LANG_PLAYER, "ADMIN_GIVE_ITEM", AdminName, PlrName, g_Admin_Input[id], LANG_PLAYER, "COIN")
		}
		case ADMIN_GIVE_GASH:
		{
			g_Gash[g_Admin_Select_Plr[id]] += g_Admin_Input[id]
			client_color_print(0, "^x04[ADMIN]^x03%L%L",  LANG_PLAYER, "ADMIN_GIVE_ITEM", AdminName, PlrName, g_Admin_Input[id], LANG_PLAYER, "GASH")
		}
		case ADMIN_GIVE_LEVEL:
		{
			g_Level[g_Admin_Select_Plr[id]] += g_Admin_Input[id]
			g_Sp[g_Admin_Select_Plr[id]] += g_Admin_Input[id] * get_pcvar_num(cvar_SpPreLv)
			client_color_print(0, "^x04[ADMIN]^x03%L%L",  LANG_PLAYER, "ADMIN_GIVE_ITEM", AdminName, PlrName, g_Admin_Input[id], LANG_PLAYER, "LEVEL")
		}
		case ADMIN_GIVE_XP:
		{
			g_Xp[g_Admin_Select_Plr[id]] += g_Admin_Input[id]
			client_color_print(0, "^x04[ADMIN]^x03%L%L",  LANG_PLAYER, "ADMIN_GIVE_ITEM", AdminName, PlrName, g_Admin_Input[id], LANG_PLAYER, "XP")
		}
	}
	gm_user_save(g_Admin_Select_Plr[id]) //保存一下
	g_Admin_Select_Plr[id] = 0
	g_Menu_Admin_Select[id] = 0
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
	if(!get_bit(g_isLogin, id))
	return PLUGIN_HANDLED;
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

/* =====================

			 Skill
			 
===================== */
public bossskill_longjump()
{
	if(g_BossMana <= get_pcvar_num(cvar_DevilLongjumpCost))
		return 0
	
	new Float:velocity[3]
	velocity_by_aim(g_whoBoss, 800, velocity)
	velocity[2] = get_pcvar_float(cvar_DevilLongjumpDistance)
	set_pev(g_whoBoss, pev_velocity, velocity)
	engfunc(EngFunc_EmitSound, g_whoBoss, CHAN_VOICE, snd_boss_ljump, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	set_bit(g_isNoDamage, g_whoBoss)
	set_pev(g_whoBoss, pev_takedamage, 0.0)
	fm_set_rendering(g_whoBoss,kRenderFxGlowShell, 255, 25, 25, kRenderNormal, 32);
	set_task(1.0, "task_longjump_off")
	
	return 1
}

public bossskill_scare(Float:force[3],Float:dealytime,Float:radius)
{
	if(g_BossMana <= get_pcvar_num(cvar_DevilScareCost))
		return 0
	
	new Float:idorg[3]
	pev(g_whoBoss,pev_origin,idorg)
	msg_create_lightring(idorg, radius, {128, 28, 28})

	new target
	while(0<(target=engfunc(EngFunc_FindEntityInSphere,target,idorg,radius))<=g_MaxPlayer)
	{
		if(target==g_whoBoss || !is_user_alive(target)) continue;
		
		fm_set_rendering(target,kRenderFxGlowShell, 255, 255, 255, kRenderNormal, 32);
		g_AttackCooldown[target] = get_gametime() + dealytime
		msg_show_scare(target)
		set_task(dealytime, "task_scare_off", target+TASK_SCARE_OFF);
		if(!is_user_bot(target)) set_view(target,CAMERA_3RDPERSON);
	}
	return 1;
}

public bossskill_blind()
{
	if(g_BossMana <= get_pcvar_num(cvar_DevilBlindCost))
		return 0
	
	new Float:idorg[3]
	pev(g_whoBoss,pev_origin,idorg)
	new Float:radius = get_pcvar_float(cvar_DevilBlindRange)
	msg_create_lightring(idorg, radius, {128, 128, 128})
	
	new target
	while(0<(target=engfunc(EngFunc_FindEntityInSphere,target,idorg,radius))<=g_MaxPlayer)
	{
		if(target==g_whoBoss || !is_user_valid_connected(target)) continue;
		fm_set_rendering(target,kRenderFxGlowShell, 128, 255, 128, kRenderNormal, 32);
		set_task(get_pcvar_float(cvar_DevilBlindTime), "task_blind_off", target+TASK_BLIND_OFF);
		if(is_user_bot(target))
		{
			g_AttackCooldown[target] = get_gametime() + get_pcvar_float(cvar_DevilBlindTime)
			continue
		}
		msg_screen_fade(target, 0, 0, 0, 255)
	}
	
	return 1
}

public bossskill_teleport()
{
	if(g_BossMana <= get_pcvar_num(cvar_DevilTeleCost))
		return 0
	
	new target
	while(!is_user_alive(target) || g_whoBoss == target)
		target = random_num(1, g_MaxPlayer)
	
	new idorg[3]
	
	get_user_origin(target,idorg)
	idorg[2] = idorg[2] + 10
	set_user_origin(g_whoBoss,idorg)
	
	g_AttackCooldown[g_whoBoss] = get_gametime() + 1.5
	
	return 1;
}

public bossskill_godmode()
{
	if(g_BossMana <= get_pcvar_num(cvar_DevilGodCost))
		return 0
	
	set_pev(g_whoBoss, pev_takedamage, 0.0)
	set_bit(g_isNoDamage, g_whoBoss)
	fm_set_rendering(g_whoBoss,kRenderFxGlowShell,250,0,0, kRenderNormal);
	set_task(0.1, "task_godmode_light", TASK_GODMODE_LIGHT, _, _, "b")
	set_task(get_pcvar_float(cvar_DevilGodTime), "task_godmode_off", TASK_GODMODE_OFF)
	
	return 1;
}

public bossskill_disappear()
{
	if(g_BossMana <= get_pcvar_num(cvar_DevilDisappearCost))
		return 0
	
	for(new i = 1; i <= g_MaxPlayer; i++)
	{
		//Bot
		if(is_user_bot(i))
			g_AttackCooldown[i] = get_gametime() + get_pcvar_num(cvar_DevilDisappearTime)
	}
	// set_pev(g_whoBoss, pev_rendermode, kRenderTransAlpha)
	// set_pev(g_whoBoss, pev_renderamt, 0) //隐
	g_PlayerEffect[g_whoBoss] = pev(g_whoBoss, pev_effects)
	set_pev(g_whoBoss, pev_effects, EF_NODRAW)
	set_task(get_pcvar_float(cvar_DevilDisappearTime), "task_disappear_off")
	return 1
}

/* ==========================

					[Natives]
			 
==========================*/

public native_register_sp_wpn(const name[], const cost)
{
	param_convert(1)
	ArrayPushString(g_SpWpn_Name, name)
	ArrayPushCell(g_SpWpn_Price, cost)
	g_SpWpn_Num ++
	return g_SpWpn_Num-1
}

public native_register_gash_wpn(const name[], const cost)
{
	param_convert(1)
	ArrayPushString(g_GashWpn_Name, name)
	ArrayPushCell(g_GashWpn_Price, cost)
	
	g_GashWpn_Num ++
	return g_GashWpn_Num-1
}

public native_register_second_wpn(const name[], const lvneed)
{
	param_convert(1)
	ArrayPushString(g_SecondWpn_Name, name)
	ArrayPushCell(g_SecondWpn_Lv, lvneed)
	
	g_SecondWpn_Num++
	return g_SecondWpn_Num-1
}

public native_register_item(const name[], const info[])
{
	param_convert(1)
	param_convert(2)
	ArrayPushString(g_Item_Name, name)
	ArrayPushString(g_Item_Info, info)
	
	g_Item_Num ++
	return g_Item_Num-1
}

public native_register_shop_item(const name[], const price, const max)
{
	param_convert(1)
	ArrayPushString(g_Shop_Item_Name, name)
	ArrayPushCell(g_Shop_Item_Price, price)
	ArrayPushCell(g_Shop_Item_Max, max)
	
	g_Shop_Item_Num ++
	return g_Shop_Item_Num-1
}

public native_set_user_nightvision(id, set)
{
	if(set)
	{
		set_bit(g_hasNvision, id)
		set_bit(g_isNvision, id)
		remove_task(id+TASK_NVISION)
		set_task(0.1, "task_set_user_nvision", id+TASK_NVISION, _, _, "b")
	}
	else
	{
		remove_task(id + TASK_NVISION)
		delete_bit(g_isNvision, id)
	}
}


/* public native_get_sp_wpn_id(const name[])
{
	
}

public native_get_gash_wpn_id(const name[])
{
	
}
 */
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
	g_PlayerTeam[id] = team
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
	if(get_bit(g_isConnect, id))
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
	set_bit(g_isModeled, id)
	engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "model", model)
	copy(g_PlayerModel[id], sizeof g_PlayerModel[] - 1, model)
	
	// static ModelPath[64]
	// formatex(ModelPath, charsmax(ModelPath), "models/player/%s", model)
	// set_pdata_int(id, m_ModelIndex, engfunc(EngFunc_ModelIndex, ModelPath))
}

//重置模型
stock fm_reset_user_model(id)
{
	if (!get_bit(g_isConnect, id))
		return

	delete_bit(g_isModeled, id)
	delete_bit(g_isModeled, id)
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

stock fm_get_speed_vector(origin1[3],origin2[3],Float:force, new_velocity[3]){
    new_velocity[0] = origin2[0] - origin1[0]
    new_velocity[1] = origin2[1] - origin1[1]
    new_velocity[2] = origin2[2] - origin1[2]
    new Float:num = floatsqroot(force*force / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
    new_velocity[0] *= floatround(num)
    new_velocity[1] *= floatround(num)
    new_velocity[2] *= floatround(num)

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

stock msg_trace(idorigin[3],targetorigin[3],crit){
	if(crit){
		new velfloat[3]
		fm_get_speed_vector(idorigin, targetorigin, 4000.0, velfloat)
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_USERTRACER)
		write_coord(idorigin[0])
		write_coord(idorigin[1])
		write_coord(idorigin[2])
		write_coord(velfloat[0])
		write_coord(velfloat[1])
		write_coord(velfloat[2])
		write_byte(12)
		write_byte(3)
		write_byte(25)
		message_end()
	}else{
		// message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		// write_byte(6);
		// write_coord(idorigin[0]);
		// write_coord(idorigin[1]);
		// write_coord(idorigin[2]);
		// write_coord(targetorigin[0]);
		// write_coord(targetorigin[1]);
		// write_coord(targetorigin[2]);
		// message_end();
	}
}

stock msg_create_lightring(const Float:originF[3], const Float:radius = 100.0, rgb[3] = {100, 100, 100})
{
	// Smallest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+ radius) // z axis
	write_short(g_spr_ring) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(15) // width
	write_byte(0) // noise
	write_byte(rgb[0]) // red
	write_byte(rgb[1]) // green
	write_byte(rgb[2]) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()

}

stock msg_create_crit(id, target,type){
	if(!is_user_alive(id) || !is_user_alive(target) || id == target) return;
	if(type == 1)	//大暴击
	{
		engfunc(EngFunc_EmitSound,id, CHAN_STATIC,snd_crit_hit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		engfunc(EngFunc_EmitSound,target, CHAN_STATIC,snd_crit_received, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		new iorigin[3], Float:forigin[3]
		pev(target, pev_origin, forigin)
		FVecIVec(forigin, iorigin)
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BUBBLES)
		write_coord(iorigin[0])//位置
		write_coord(iorigin[1])
		write_coord(iorigin[2] + 16)
		write_coord(iorigin[0])//位置
		write_coord(iorigin[1])
		write_coord(iorigin[2] + 32)
		write_coord(192)
		write_short(g_spr_crit)
		write_byte(1)
		write_coord(30)
		message_end()
	}
	else	//小暴击
	{
		engfunc(EngFunc_EmitSound,id, CHAN_STATIC,snd_minicrit_hit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		engfunc(EngFunc_EmitSound,target, CHAN_STATIC,snd_minicrit_hit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		new iorigin[3], Float:forigin[3]
		pev(target, pev_origin, forigin)
		FVecIVec(forigin, iorigin)
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BUBBLES)
		write_coord(iorigin[0])//位置
		write_coord(iorigin[1])
		write_coord(iorigin[2] + 16)
		write_coord(iorigin[0])//位置
		write_coord(iorigin[1])
		write_coord(iorigin[2] + 32)
		write_coord(192)
		write_short(g_spr_minicrit)
		write_byte(1)
		write_coord(30)
		message_end()
	}
}

stock msg_show_scare(id)
{
	message_begin( MSG_ALL, SVC_TEMPENTITY );
	write_byte(TE_PLAYERATTACHMENT);
	write_byte(id);
	write_coord(45);
	write_short(g_spr_scare); 
	write_short(50);
	message_end();
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
			if (!get_bit(g_isConnect, player))
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

stock is_hull_vacant(Float:origin[], hull)
{
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, 0, 0)
	
	if (!get_tr2(0, TraceResult:TR_StartSolid) && !get_tr2(0, TraceResult:TR_AllSolid) && get_tr2(0, TraceResult:TR_InOpen))
		return true;
	
	return false;
}
team_join(id, team[] = "5")
{
	new msg_block = get_msg_block(g_Msg_ShowMenu)
	set_msg_block(g_Msg_ShowMenu, BLOCK_SET)
	engclient_cmd(id, "jointeam", team)
	set_msg_block(g_Msg_ShowMenu, msg_block)
}

// Plays a sound on clients
PlaySound(const sound[])
{
	client_cmd(0, "spk ^"%s^"", sound)
}

//~Return alive human number
fnGetHumans()
{
	static iHuman, id
	iHuman = 0
	for (id = 1; id <= g_MaxPlayer; id++)
	{
		if (is_user_alive(id) && id != g_whoBoss)
			iHuman++
	}
	return iHuman
}

//~Return alive player number
fnGetAlive()
{
	static iAlive, id
	iAlive = 0
	for (id = 1; id <= g_MaxPlayer; id++)
	{
		if (is_user_alive(id))
			iAlive++
	}
	return iAlive
}
