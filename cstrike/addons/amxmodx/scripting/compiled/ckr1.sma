#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <ckrun_const>
#include <xs>

//define 定义定值

//#define AMBIENCE_SOUND//删除本句以禁用环境音效
#define AMBIENCE_RAIN//删除本句以禁用下雨
#define CUSTOM_DEATHSOUND//删除本句以禁用自定义死亡音效
#define CUSTOM_GIBMODEL//删除本句以禁用自定义尸块
#define HUD_REFRESH	0.7//HUD信息刷新间隔
#define CENTER_REFRESH	0.2//屏幕中心目标信息刷新间隔
#define TIMER_REFRESH	0.5//计时器刷新间隔
#define PLAYER_THINK	0.2//Player Think间隔
#define SENTRY_THINK	0.2//Sentry Think间隔
#define DISPENSER_THINK	0.2//Dispenser Think间隔
#define TELEIN_THINK	0.2//TeleporterIn Think间隔
#define TELEOUT_THINK	0.2//TeleporterOut Think间隔
#define PICKUP_DELAY	0.7//捡物品间隔
#define CAPTURE_DELAY	0.6//每占领一点需要的时间
#define CHECK_END	10.0//检测是否应该结束回合
#define TELE_DELAY	0.6//站在传送装置上超过几秒才能传送
#define SPAWN_DELAY	0.2//出生设定需要的时间
#define SAVE_DELAY	60.0//保存数据间隔
#define MAX_GIBTYPE	8//最多有几种尸块
#define STATUS_CHANNEL	1
#define CENTER_CHANNEL	2
#define TIMER_CHANNEL	3
#define BUILD_CHANNEL	4
#define CP_MAXPOINTS	6//最多有6-1=5个占领点

#define BUILD_OWNER		pev_iuser1
#define FLARE_GLOW		pev_iuser1
#define ROCKET_CRITICAL		pev_iuser1
#define ROCKET_REFLECT		pev_iuser2
#define MAP_DISPATCH		pev_iuser1
#define MAP_DISPATCH2		pev_iuser2
#define MAP_DISPATCH3		pev_iuser3
#define MAP_CPNUMS		pev_iuser4
#define MIRROR_MOVE		pev_startpos
#define MAX_MODELID		sizeof mdl_human
#define MAX_ACHIEVEMENT		sizeof ach_menu_name
#define MAX_KNIFEID		sizeof g_knife_formatname

const ACCESS_USER = ADMIN_USER
const ACCESS_ADMIN = ADMIN_BAN//管理员
const ACCESS_VIP = ADMIN_RESERVATION//VIP

//const 定义字符
new const g_primary_allow_scout[] = { CSW_M4A1, CSW_AK47, CSW_AUG, CSW_SG552, CSW_FAMAS, CSW_GALIL, CSW_P90, CSW_M3, CSW_XM1014}
new const g_secondary_allow_scout[] = { CSW_GLOCK18, CSW_USP, CSW_P228, CSW_FIVESEVEN, CSW_ELITE, CSW_DEAGLE}

new const g_primary_allow_heavy[] = { CSW_M3, CSW_XM1014}
new const g_secondary_allow_mg[] = { CSW_GLOCK18, CSW_USP, CSW_P228, CSW_FIVESEVEN, CSW_ELITE, CSW_DEAGLE}

new const g_primary_allow_rpg[] = { CSW_M3, CSW_XM1014}
new const g_secondary_allow_rpg[] = { CSW_GLOCK18, CSW_USP, CSW_P228, CSW_FIVESEVEN, CSW_ELITE, CSW_DEAGLE}

new const g_primary_allow_snipe[] = { CSW_MP5NAVY, CSW_TMP, CSW_UMP45, CSW_MAC10}
new const g_secondary_allow_snipe[] = { CSW_GLOCK18, CSW_USP, CSW_P228, CSW_FIVESEVEN, CSW_ELITE}

new const g_primary_allow_log[] = { CSW_MP5NAVY, CSW_TMP, CSW_UMP45, CSW_MAC10}
new const g_secondary_allow_log[] = { CSW_GLOCK18, CSW_USP, CSW_P228, CSW_FIVESEVEN, CSW_ELITE}

new const g_primary_allow_eng[] = { CSW_M3, CSW_XM1014}
new const g_secondary_allow_eng[] = { CSW_GLOCK18, CSW_USP, CSW_P228, CSW_FIVESEVEN, CSW_ELITE}

new const msg_infect[][] = { "MSG_INFECT_1"}
new const msg_first_zombie[][] = { "MSG_FIRST_ZOMBIE_1"}

new const team_names[][] = {
	"=== Human Team ===",
	"=== Zombie Team ===",
	"=== CT Team ===",
	"=== Terrorist Team ==="
}

new const snd_win_no[][] = { "chickenrun/win_no.wav" }
new const snd_win_human[][] = { "chickenrun/win_human.wav" }
new const snd_win_zombie[][] = { "chickenrun/win_zombie.wav" }

new const mdl_human[][] = { "urban", "gsg9", "sas", "gign", "terror", "leet", "arctic", "guerilla", "vip", "wpx" }//普通玩家模型
new const mdl_human_formatname[][] = { "NAME_MDL_URBAN", "NAME_MDL_GSG9", "NAME_MDL_SAS", "NAME_MDL_GIGN", "NAME_MDL_TERROR", "NAME_MDL_LEET", "NAME_MDL_ARCTIC", "NAME_MDL_GUERILLA", "NAME_MDL_VIP", "NAME_MDL_WPX" }
new const mdl_human_access[] = { ACCESS_USER, ACCESS_USER, ACCESS_USER, ACCESS_USER, ACCESS_USER, ACCESS_USER, ACCESS_USER, ACCESS_USER, ACCESS_VIP, ACCESS_VIP}

new const ach_menu_name[][] = { "MENU_ACH_FAST"}
new const ach_fast_title[][] = { "MOTD_ACH_FAST_1A", "MOTD_ACH_FAST_2A", "MOTD_ACH_FAST_3A", "MOTD_ACH_FAST_4A", "MOTD_ACH_FAST_5A", "MOTD_ACH_FAST_6A", "MOTD_ACH_FAST_7A", "MOTD_ACH_FAST_8A", "MOTD_ACH_FAST_9A", "MOTD_ACH_FAST_10A", "MOTD_ACH_FAST_11A", "MOTD_ACH_FAST_12A", "MOTD_ACH_FAST_13A", "MOTD_ACH_FAST_14A"}
new const ach_fast_text[][] = { "MOTD_ACH_FAST_1B", "MOTD_ACH_FAST_2B", "MOTD_ACH_FAST_3B", "MOTD_ACH_FAST_4B", "MOTD_ACH_FAST_5B", "MOTD_ACH_FAST_6B", "MOTD_ACH_FAST_7B", "MOTD_ACH_FAST_8B", "MOTD_ACH_FAST_9B", "MOTD_ACH_FAST_10B", "MOTD_ACH_FAST_11B", "MOTD_ACH_FAST_12B", "MOTD_ACH_FAST_13B", "MOTD_ACH_FAST_14B"}
new const ach_fast_formatname[][] = { "NAME_ACH_FAST_1", "NAME_ACH_FAST_2", "NAME_ACH_FAST_3", "NAME_ACH_FAST_4", "NAME_ACH_FAST_5", "NAME_ACH_FAST_6", "NAME_ACH_FAST_7", "NAME_ACH_FAST_8", "NAME_ACH_FAST_9", "NAME_ACH_FAST_10", "NAME_ACH_FAST_11", "NAME_ACH_FAST_12", "NAME_ACH_FAST_13", "NAME_ACH_FAST_14"}
new const ach_fast_progress[] = { 0, 512, 50, 20, 0, 5, 5, 1000, 100, 0, 0, 0, 0, 0 }
#define MAX_ACH_FAST	sizeof ach_fast_title
//new const ach_grav_title[][] = { "MENU_ACH_GRAV_1A", "MENU_ACH_GRAV_2A", "MENU_ACH_GRAV_3A", "MENU_ACH_GRAV_4A", "MENU_ACH_GRAV_5A", "MENU_ACH_GRAV_6A", "MENU_ACH_GRAV_7A", "MENU_ACH_GRAV_8A", "MENU_ACH_GRAV_9A", "MENU_ACH_GRAV_10A", "MENU_ACH_GRAV_11A" }
//new const ach_grav_text[][] = { "MENU_ACH_GRAV_1B", "MENU_ACH_GRAV_2B", "MENU_ACH_GRAV_3B", "MENU_ACH_GRAV_4B", "MENU_ACH_GRAV_5B", "MENU_ACH_GRAV_6B", "MENU_ACH_GRAV_7B", "MENU_ACH_GRAV_8B", "MENU_ACH_GRAV_9B", "MENU_ACH_GRAV_10B", "MENU_ACH_GRAV_11B" }

new const admin_menu_name[][] = { "MENU_ADMIN_ZOMBIE", "MENU_ADMIN_HUMAN", "MENU_ADMIN_ZOMBIECLASS", "MENU_ADMIN_HUMANCLASS", "MENU_ADMIN_RESPAWN", "MENU_ADMIN_HEALTH", "MENU_ADMIN_AMMO", "MENU_ADMIN_MODEL" }
new const admin_menu_access[] = { ACCESS_ADMIN, ACCESS_ADMIN, ACCESS_ADMIN, ACCESS_ADMIN, ACCESS_ADMIN, ACCESS_ADMIN, ACCESS_ADMIN, ACCESS_ADMIN}

new const snd_hammer[][] = { "chickenrun/eng_hammer1.wav", "chickenrun/eng_hammer2.wav" }//榔头音效

new const snd_thunder[][] = { "ambience/thunder_clap.wav" }//打雷音效

new const snd_medic_heal[] = { "chickenrun/medic_heal.wav" }//医疗枪医疗音效

new const snd_charge_on[] = { "chickenrun/charge_on.wav" }//电荷启动音效

new const snd_charge_off[] = { "chickenrun/charge_off.wav" }//电荷关闭音效

new const snd_rpg_shoot[] = { "chickenrun/rpg_shoot.wav" }//火箭弹发射音效

new const snd_rpg_exp[] = { "chickenrun/rpg_exp.wav" }//火箭弹爆炸音效

new const snd_rpg_shoot_crit[] = { "chickenrun/rpg_shoot_crit.wav" }//暴击火箭弹发射音效

new const snd_sentry_rocket[] = { "chickenrun/sentry_rocket.wav" }//步哨火箭弹发射音效

new const snd_sentry_shoot[] = { "chickenrun/sentry_shoot.wav" }//步哨攻击音效

new const snd_sentry_scan[] = { "chickenrun/sentry_scan.wav" }//步哨发现敌人音效

new const snd_crit_shoot[] = { "chickenrun/crit_shoot.wav" }//暴击音效

new const snd_dispenser_heal[] = { "chickenrun/dispenser_heal.wav" }//补给器医疗音效

new const snd_minigun_spining[] = { "chickenrun/minigun_spining.wav" }//转轮机枪旋转声

new const snd_minigun_spinup[] = { "chickenrun/minigun_spinup.wav" }//转轮机枪旋转声

new const snd_minigun_spindown[] = { "chickenrun/minigun_spindown.wav" }//转轮机枪旋转声

new const snd_moonstar_mirror[] = { "chickenrun/moonstar_mirror.wav" }//星月斩镜象音效

#if defined AMBIENCE_SOUND
new const snd_ambience[] = { "sound/chickenrun/zombie_ambient.mp3" }
new Float:snd_ambience_duration = 130.0
#endif
#if defined CUSTOM_DEATHSOUND

new const snd_death_custom[][] = { "chickenrun/death_wpx.wav" }
new const snd_death_model[][] = { "wpx" }
#endif

#if defined CUSTOM_GIBMODEL
new const mdl_gib_head[][] = { "models/chickenrun/gib_wpx_head.mdl"}
new const mdl_gib_arm[][] = { "models/chickenrun/gib_wpx_arm.mdl"}
new const mdl_gib_hand[][] = { "models/chickenrun/gib_wpx_hand.mdl"}
new const mdl_gib_leg[][] = { "models/chickenrun/gib_wpx_leg.mdl"}
new const mdl_gib_foot[][] = { "models/chickenrun/gib_wpx_foot.mdl"}

new const mdl_gib_model[][] = { "wpx" }
new mdl_gib_list[5][MAX_GIBTYPE]
#endif
new const mdl_v_hammer[] = { "models/chickenrun/v_hammer.mdl" }//榔头View模型
new const mdl_p_hammer[] = { "models/chickenrun/p_hammer.mdl" }//榔头Player模型

new const mdl_v_minigun[] = { "models/chickenrun/v_minigun.mdl" }//转轮机枪View模型
new const mdl_p_minigun[] = { "models/p_m249.mdl" }//转轮机枪Player模型

new const mdl_v_rpg[] = { "models/chickenrun/v_rpg.mdl" }//火箭炮View模型
new const mdl_p_rpg[] = { "models/chickenrun/p_rpg.mdl" }//火箭炮Player模型
new const mdl_w_rpg[] = { "models/chickenrun/w_rpg.mdl" }//火箭炮World模型

new const mdl_v_medicgun[] = { "models/v_egon.mdl" }//医疗枪View模型
new const mdl_p_medicgun[] = { "models/p_egon.mdl" }//医疗枪Player模型
new const mdl_w_medicgun[] = { "models/w_egon.mdl" }//医疗枪World模型

new const mdl_v_ammopack[] = { "models/chickenrun/v_ammopack.mdl" }//补给包View模型
new const mdl_p_ammopack[] = { "models/chickenrun/p_ammopack.mdl" }//补给包Player模型

new const mdl_v_toolbox[] = { "models/chickenrun/v_toolbox.mdl" }//工具箱View模型
new const mdl_p_toolbox[] = { "models/chickenrun/p_toolbox.mdl" }//工具箱Player模型
new const mdl_w_toolbox[] = { "models/chickenrun/w_toolbox.mdl" }//工具箱World模型

new const mdl_v_pda[] = { "models/chickenrun/v_pda.mdl" }//遥控器View模型
new const mdl_p_pda[] = { "models/chickenrun/p_pda.mdl" }//遥控器Player模型

new const mdl_v_moonstar[] = { "models/chickenrun/v_moonstar.mdl" }//星月View模型
new const mdl_p_moonstar[] = { "models/chickenrun/p_moonstar.mdl" }//星月Player模型

new const mdl_v_knife_stab[] = { "models/chickenrun/v_knife_stab.mdl" }//背刺刀子View模型
new const mdl_v_knife_invis[] = { "models/chickenrun/v_knife_invis.mdl" }//隐形View模型

new const mdl_v_knife[] = { "models/v_knife.mdl" }//刀子View模型
new const mdl_p_knife[] = { "models/p_knife.mdl" }//刀子Player模型

new const mdl_pj_rpgrocket[] = { "models/chickenrun/pj_rpgrocket.mdl" }//火箭弹模型

//new const mdl_pj_gravityball[] = { "models/chickenrun/pj_gravityball.mdl" }//空气弹模型

new const mdl_pj_flare[] = { "models/chickenrun/pj_flare.mdl" }//照明弹模型

new const mdl_w_healthkit[] = { "models/w_medkit.mdl" }//医疗包模型
new const mdl_w_ammobox[] = { "models/chickenrun/w_ammobox.mdl" }//弹药盒模型
new const mdl_w_bugkiller[] = { "models/chick.mdl" }//BUG终结者模型

new const mdl_dispenser[] = { "models/chickenrun/dispenser.mdl" }//补给器模型
new const mdl_teleporter[] = { "models/chickenrun/teleporter.mdl" }//补给器模型

new const mdl_moonstar_mirror[] = { "models/chickenrun/moonstar_mirror.mdl" }//星月斩镜象模型

new const mdl_player_fastzombie[] = { "models/player/fastzombie/fastzombie.mdl" }//闪电僵尸模型
new const mdl_player_classiczombie[] = { "models/player/classiczombie/classiczombie.mdl" }//经典僵尸模型
new const mdl_player_jumpzombie[] = { "models/player/jumpzombie/jumpzombie.mdl" }//跳跃僵尸模型

new const dcl_blood[] = { 190, 191, 192, 193, 194, 195, 196, 197, 204, 205 }
new const dcl_exp[] = { 46, 47, 48 }

new const g_wpn_name[][] = { "worldspawn", "p228", "unknow", "scout", "grenade", "xm1014", "c4", "mac10", "aug", "smokegrenade", "elite", "fiveseven", "ump45", "sg550", "galil", "famas", 
//				0      	     1		2	3	 4	   5         6	    7       8	    9	           10	      11	 12	   13	    14	    15
"usp", "glock18", "awp", "mp5navy", "m249", "m3", "m4a1", "tmp", "g3sg1", "flashbang", "deagle", "sg552", "ak47", "knife", "p90", "vest", "vesthelm", "rpg_rocket", "sentry_rocket",
//16	  17	   18	    19		20    21    22      23	    24		25	  26	   27	    28	    29	    30	    31        32	  33	   	34
"reflect_rocket", "sentry", "flare", "infection", "backstab", "hammer", "moonstar","CKW_INFECT"}
//    35	     36	      37        38	      39	40	    41        42

new const g_wpn_formatname[][] = { "NAME_WEAPON_UNKNOW", "NAME_WEAPON_P228", "NAME_WEAPON_UNKNOW", "NAME_WEAPON_SCOUT", "NAME_WEAPON_HE", "NAME_WEAPON_XM1014", "NAME_WEAPON_C4", "NAME_WEAPON_MAC10", "NAME_WEAPON_AUG", "NAME_WEAPON_SMOKE", "NAME_WEAPON_ELITES", "NAME_WEAPON_57", "NAME_WEAPON_UMP45", "NAME_WEAPON_SG550", "NAME_WEAPON_GALIL", "NAME_WEAPON_FAMAS", 
//				0       1	2	  3	     4	      5	    	6	7	8	    9	      10	  11	   12	   13	    14		15
"NAME_WEAPON_USP45", "NAME_WEAPON_GLOCK18", "NAME_WEAPON_AWP", "NAME_WEAPON_MP5", "NAME_WEAPON_M249", "NAME_WEAPON_M3", "NAME_WEAPON_M4A1", "NAME_WEAPON_TMP", "NAME_WEAPON_G3SG1", "NAME_WEAPON_FLASH", "NAME_WEAPON_DEAGLE", "NAME_WEAPON_SG552", "NAME_WEAPON_AK47", "NAME_WEAPON_KNIFE", "NAME_WEAPON_P90", "NAME_WEAPON_UNKNOW", "NAME_WEAPON_UNKNOW", "NAME_WEAPON_RPG", "NAME_WEAPON_SENTRY",
//16	  17	   18	    19		20    21    22      23	    24		25	  26	   27	    28	    29	    30	    31        32	33(rpg)	   34	
"NAME_WEAPON_REFLECT", "NAME_WEAPON_SENTRY", "NAME_WEAPON_FLARE", "NAME_WEAPON_INFECT", "NAME_WEAPON_BACKSTAB", "NAME_WEAPON_HAMMER", "NAME_WEAPON_MOONSTAR"}
//    35	     36	      37        38	  39	     40

new const g_wpn_classname[][] = { "", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", 
"weapon_mac10", "weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550", 
"weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249", "weapon_m3", 
"weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552", "weapon_ak47", 
"weapon_knife", "weapon_p90", "item_kevlar", "item_assaultsuit", "", "", "", "", "", "", "", "", ""}

new const g_knife_formatname[][] = { "NAME_WEAPON_KNIFE", "NAME_WEAPON_HAMMER", "NAME_WEAPON_MOONSTAR" }
new const g_knife_needname[][] = { "MENU_KNIFE_NORMAL", "MENU_KNIFE_HAMMER", "MENU_KNIFE_MOONSTAR" }


enum (+= 50){
	TASK_RESPAWN = 500,
	TASK_PLAYER_THINK,
	TASK_SNIPE_REGEN,
	TASK_ZOMBIE_SKILL,
	TASK_RPG_GETREADY,
	TASK_RPG_RELOAD,
	TASK_RPGREPEAT,
	TASK_MEDIC,
	TASK_AMMOSUPPLY,
	TASK_SENTRY_ROCKET,
	TASK_SHOWHUD,
	TASK_SHOWMSG,
	TASK_SHOWCENTER,
	TASK_SHOWTIMER,
	TASK_AMBIENCE_SOUND,
	TASK_CRITICAL,
	TASK_PICKUP,
	TASK_CAPTURED,
	TASK_STABDELAY,
	TASK_HIDEMONEY,
	TASK_TELECD,
	TASK_SPAWN,
	TASK_SENTRY_THINK,
	TASK_DISPENSER_THINK,
	TASK_TELEIN_THINK,
	TASK_TELEOUT_THINK,
	TASK_LOADALL,
	DEATHMSG_SENTRY,
	DEATHMSG_DISPENSER,
	DEATHMSG_TELEIN,
	DEATHMSG_TELEOUT
}

enum (+= 1000){
	TASK_RPGTRAIL = 2000,
	TASK_FLARE_THINK
}
const TASK_FIRST_ZOMBIE = 5875
const TASK_ENVIRONMENT = 9527
const TASK_LIGHTNING = 8000
const TASK_CHECK_END = 5438
const TASK_ROUND_TIMER = 8899
#define ID_SPAWN (taskid - TASK_SPAWN)
#define ID_SHOWHUD (taskid - TASK_SHOWHUD)
#define ID_SHOWMSG (taskid - TASK_SHOWMSG)
#define ID_PLAYER_THINK (taskid - TASK_PLAYER_THINK)
#define ID_SHOWCENTER (taskid - TASK_SHOWCENTER)
//#define ID_SHOWTIMER (taskid - TASK_SHOWTIMER)
#define ID_STABDELAY (taskid - TASK_STABDELAY)
#define ID_ZOMBIE_SKILL (taskid - TASK_ZOMBIE_SKILL)
#define ID_RPG_GETREADY (taskid - TASK_RPG_GETREADY)
#define ID_MEDIC (taskid - TASK_MEDIC)
#define ID_AMMOSUPPLY (taskid - TASK_AMMOSUPPLY)
#define ENT_RPGTRAIL (taskid - TASK_RPGTRAIL)

#if cellbits == 32
const OFFSET_CSTEAMS = 114
const OFFSET_CSMONEY = 115
const OFFSET_NVGOGGLES = 129
const OFFSET_ZOOMTYPE = 363
const OFFSET_CSDEATHS = 444
const OFFSET_AWM_AMMO  = 377 
const OFFSET_SCOUT_AMMO = 378
const OFFSET_PARA_AMMO = 379
const OFFSET_FAMAS_AMMO = 380
const OFFSET_M3_AMMO = 381
const OFFSET_USP_AMMO = 382
const OFFSET_FIVESEVEN_AMMO = 383
const OFFSET_DEAGLE_AMMO = 384
const OFFSET_P228_AMMO = 385
const OFFSET_GLOCK_AMMO = 386
const OFFSET_FLASH_AMMO = 387
const OFFSET_HE_AMMO = 388
const OFFSET_SMOKE_AMMO = 389
const OFFSET_C4_AMMO = 390
const OFFSET_CLIPAMMO = 51
#else
const OFFSET_CSTEAMS = 139
const OFFSET_CSMONEY = 140
const OFFSET_NVGOGGLES = 155
const OFFSET_ZOOMTYPE = 402
const OFFSET_CSDEATHS = 493
const OFFSET_AWM_AMMO  = 426
const OFFSET_SCOUT_AMMO = 427
const OFFSET_PARA_AMMO = 428
const OFFSET_FAMAS_AMMO = 429
const OFFSET_M3_AMMO = 430
const OFFSET_USP_AMMO = 431
const OFFSET_FIVESEVEN_AMMO = 432
const OFFSET_DEAGLE_AMMO = 433
const OFFSET_P228_AMMO = 434
const OFFSET_GLOCK_AMMO = 435
const OFFSET_FLASH_AMMO = 46
const OFFSET_HE_AMMO = 437
const OFFSET_SMOKE_AMMO = 438
const OFFSET_C4_AMMO = 439
const OFFSET_CLIPAMMO = 65
#endif

const OFFSET_LINUX = 5
const OFFSET_LINUX_WEAPONS = 4
const OFFSET_MODELINDEX = 491 
const KEYSMENU = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9)
const MENU_KEY_AUTOSELECT = 7
const MENU_KEY_BACK = 7
const MENU_KEY_NEXT = 8
const MENU_KEY_EXIT = 9
const HIDE_MONEY = (1<<5)
//定义spr
new explo,flame,beam,critspr,trail,rpglaunch,rpgsmoke,spr_blood_spray,spr_blood_drop,exp_new1,exp_new2,exp_new3
new mdl_gib_player1,mdl_gib_player2,mdl_gib_player3,mdl_gib_player4,mdl_gib_player5,mdl_gib_player6
new mdl_gib_build1,mdl_gib_build2,mdl_gib_build3,mdl_gib_build4
new giszm[33] //你是僵尸吗?
new gteletimes[33] // 剩余传送次数
new gmodel[33] //玩家模型(数字)
new gcurmodel[33][32] //玩家当前模型(字符串)
new gzombie[33] // 僵尸类型 1=闪电僵尸 2=重力僵尸 3=经典僵尸 4=跳跃僵尸 5=隐形僵尸 默认3
new gwillbezombie[33] // 下局将变成的僵尸类型
new ghuman[33] // 人类兵种 1=侦察兵 2=机枪兵 3=火箭炮兵 4=狙击手 5=后勤 6=工程师 默认1
new gwillbehuman[33] // 下局将变成的兵种类型
new gpower[33] // 辅助电源
new gflame[33] // 燃烧
new gflamer[33] // 燃烧给予者
new gcritkilled[33] // 被暴击杀死 0 = false / 1 = true
new gfrozen[33] // 冰冻
new gkill[33] // 玩家总杀敌数
new gdeath[33] // 玩家总死亡数
new gcurspeed[33] // 玩家即时移动速度
new gorispeed[33] // 玩家正常移动速度
new gaiming[33] // 玩家瞄准对象
new gaiming_a_build[33] // 1 = 步哨 2 = 补给 3 = 传送入口 4 = 传送出口
new glastatk[33] // 最后一次谁打我的?
new glast2atk[33] // 最后一次谁第二个打我的?
new gcritical[33] // 暴击几率 5 = 5%
new glastammo[33] // 最后一次弹药
new glastwpn[33] // 最后一次武器
new gknife[33] //刀类型
new gknifesave_hm[33] //最后一次人类刀类型
new gknifesave_zm[33] //最后一次僵尸刀类型
new bool:gcritical_on[33] // 暴击状态开启
new bool:gjumping[33] // 你跳了吗?
new bool:gcansecondjump[33] // 你松开跳了吗?
new bool:gsecondjump[33] // 你二段跳了吗?
new bool:gprimaryed[33] // 你选主武器了吗?
new bool:gsecondaryed[33] // 你选副武器了吗?
new bool:gpickedup[33] // 现在捡过武器了吗?
new bool:gcaptured[33] // 占领过一次?
new bool:gcorpse_hidden[33] // 隐藏尸体
new bool:gwpntraced[33] // 弹道
new bool:gstabing[33]
new bool:gswitching_name[33]
new bool:gtelecd[33] //传送功能CD
new bool:g_firstkill // First Killed
new g_roundkill[33] // 当前回合内杀敌次数
new g_rounddeath[33] // 当前回合内死亡次数
//成就变量
new bool:g_ach_rocketjump[33] // 成就记录-火箭跳
//成就变量
new gstats[33][4] // 统计：0=僵尸感染/杀人,1=人杀僵尸,2=被僵尸感染/杀,3=被人类杀

new g_menu_data[33][8] // 动态菜单
new g_menuPosition[33]
new g_menuPlayers[33][32]
new g_menuPlayersNum[33]
new g_coloredMenus

new g_hudsync // HUD文字显示-状态
new g_hudcenter // HUD文字显示-中心
new g_hudbuild // HUD文字显示-建筑
new g_hudtimer // HUD文字显示-游戏状态
new g_text1[128]
new g_text2[128]
new g_text3[128]
new g_roundtime // 时间
new g_gametime // 总时间
new g_mapname[64] // 地图名
new g_gamemode // 游戏模式
new g_round // 当前游戏状态 round_setup,start,zombie,end
new g_ctbot // fake team bot
new g_tbot // fake team bot
new g_fwEntitySpawn // Forward-清理实体
new g_fwKeyValue // // Forward-地图接口
new g_spawnCount // 出生点统计
new g_modname[32] // 游戏类型
new g_maxplayers
new g_lightning // 闪电
new g_ItemFile[256]
new g_nametemp[33][32]
new g_wpnametemp[33][32]
new bool:g_zspawned[33]
new Float:g_lastsave[33]
new Float:g_spawntime
//msg
new g_msgTeamInfo
new g_msgScreenShake
new g_msgScoreInfo
new g_msgScoreAttrib
new g_msgRoundTime
new g_msgHideWeapon
new g_msgCrosshair
new g_msgScreenFade
new g_msgSayText
new g_msgCurWeapon
new Float:g_spawns[128][3] // 出生点统计
new const g_load_remove[][] = { "func_bomb_target", "info_bomb_target", "info_vip_start", "func_vip_safetyzone", "func_escapezone", "hostage_entity","monster_scientist", "func_hostage_rescue", "info_hostage_rescue", "func_vehicle", "func_vehiclecontrols", "player_weaponstrip", "game_player_equip", "item_healthkit", "item_battery"}
new const g_round_remove[][] = { "rpg_rocket", "sentry_rocket", "rpg_flare", "rpg_flare_glow", "weaponbox", "moonstar_mirror"}
new g_cp_points[CP_MAXPOINTS]
new g_cp_pointnums
new g_cp_progress[CP_MAXPOINTS]
new g_cp_local
//---机枪---//
new gminigun_spin[33]//0 = 正常 1 = Spin up 2 = Spin down 3 = Spinning
new Float:gspindelay[33]//旋转间隔
//---火箭---//
new bool:grpgready[33]//RPG可以攻击
new grpgrepeat[33]//RPG连发火箭数量 默认=0
new bool:grpgreloading[33]//RPG装弹中
new grpgclip[33]//RPG当前弹药
new grpgammo[33]//RPG弹药
//---后勤---//
new glogmode[33]//后勤模式
new gmedictarget[33]//后勤医疗目标
new gmedicing[33]//后勤医疗中
new gmediced[33]//接受谁的医疗 0=没有

new glogammo[33]//后勤弹药储备
new gammotarget[33]//后勤补给目标
new gammoing[33]//后勤补给中
new gammoed[33]//接受谁的补给 0=没有
new gcharge[33]//能量电荷 full = 1000
new bool:gcharge_shield[33]//电荷启动--无敌
new bool:gcharge_crit[33]//电荷启动--暴击
//---狙击---//
new gsnipecharge[33] // 狙击蓄能
new bool:gsnipecharging[33] // 狙击是否在蓄能

//---工程---//
new gengmetal[33] // 工程师金属储备
new gengmode[33] // 工程师5号武器类型 1 = 工具箱 2 = 遥控器
new gsentry_base[33] // 工程师所拥有步哨枪-底座
new gsentry_turret[33] // 工程师所拥有步哨枪-炮塔
new gsentry_building[33] // 步哨枪建造中
new gsentry_percent[33] // 步哨枪建造进度
new gsentry_firemode[33] // 步哨枪攻击模式 0=正常 1=距离 2=生命 3=速度
new gsentry_level[33] // 步哨枪等级
new gsentry_health[33] // 工程师步哨枪耐久
new gsentry_ammo[33] // 工程师步哨枪弹药
new gsentry_upgrade[33] // 步哨枪升级
new gsentry_time[33] // 步哨枪计时器
new bool:gsentry_rocket[33] // 步哨能否发射火箭弹
new bool:ghavesentry[33] // 工程师是否拥有步哨

new bool:ghavedispenser[33] // 工程师是否拥有补给器
new gdispenser[33] // 工程师所拥有补给器
new gdispenser_building[33] // 补给器建造中
new gdispenser_percent[33] // 补给器建造进度
new gdispenser_upgrade[33] // 补给器升级
new gdispenser_level[33] // 补给器等级
new gdispenser_health[33] // 补给器耐久
new gdispenser_ammo[33] // 补给器弹药
new gdispenser_time[33] // 补给器计时器
new gdispenser_respawn[33] // 补给器弹药重生计时器

new bool:ghavetelein[33] // 工程师是否拥有传送装置入口
new gtelein[33] // 工程师所拥有传送装置入口
new gtelein_building[33] // 传送装置入口建造中
new gtelein_percent[33] // 传送装置入口建造进度
new gtelein_health[33] // 传送装置入口耐久

new bool:ghaveteleout[33] // 工程师是否拥有传送装置出口
new gteleout[33] // 工程师所拥有传送装置出口
new gteleout_building[33] // 传送装置出口建造中
new gteleout_percent[33] // 传送装置出口建造进度
new gteleout_health[33] // 传送装置出口耐久

new gtele_upgrade[33] // 传送装置升级
new gtele_level[33] // 传送装置等级
new gtele_reload[33] // 传送装置重新准备进度
new gtele_stand[33] // 站在传送装置入口上的某人
new Float:gtele_timer[33] // 某人站在传送装置入口上的时间
//---僵尸技能---//
new bool:gskill_ready[33] // 技能释放CD
new bool:gdisguising[33] // 伪装中
new bool:ginvisible[33] // 隐形
new gdisguise_class[33] // 伪装兵种 1~5
new gdisguise_target[33] // 伪装对象
new bool:gdodgeon[33] // 闪避模式开启
new bool:glongjumpon[33] // 长跳模式开启

new Float:gmoonslash_timer[33]
new Float:gmoonslash_angle[33][3] //星月斩角度 类型:实数
new gmoonslash_target[33] //星月斩目标 类型:玩家
new gmoonslash_blink[33]
new gmoonslash_slash[33]
new gmoonslash_canceled[33]

new g_ach_fast[33][MAX_ACH_FAST]
//new g_ach_grav[33][MAX_ACH_GRAV]

//读取CFG中的CVar
new cvar_zm_fast_hp, cvar_zm_gravity_hp, cvar_zm_classic_hp, cvar_zm_jump_hp, cvar_zm_invis_hp//僵尸生命
new cvar_zm_fast_speed, cvar_zm_gravity_speed, cvar_zm_classic_speed, cvar_zm_jump_speed, cvar_zm_invis_speed//僵尸速度
new cvar_zm_fast_kb, cvar_zm_gravity_kb, cvar_zm_classic_kb, cvar_zm_jump_kb, cvar_zm_invis_kb//僵尸抗弹
new cvar_zm_fast_jump, cvar_zm_gravity_jump, cvar_zm_classic_jump, cvar_zm_jump_jump, cvar_zm_invis_jump//僵尸跳跃

new cvar_hm_scout_hp, cvar_hm_heavy_hp, cvar_hm_rpg_hp, cvar_hm_snipe_hp, cvar_hm_log_hp, cvar_hm_eng_hp//人类生命
new cvar_hm_scout_speed, cvar_hm_heavy_speed, cvar_hm_rpg_speed, cvar_hm_snipe_speed, cvar_hm_log_speed, cvar_hm_eng_speed//人类速度,scout_speed=初始速度

new cvar_wpn_multidamage_he, cvar_wpn_slowdown_he, cvar_wpn_multidamage_m249, cvar_wpn_multidamage_awp, cvar_wpn_multidamage_deagle, cvar_wpn_multidamage_default, cvar_wpn_multidamage_knife, cvar_wpn_multidamage_hammer, cvar_wpn_multidamage_shotgun//手雷伤害,减速,武器伤害倍率
new cvar_wpn_awp_charge //AWP蓄能
new cvar_wpn_ammo_m249, cvar_wpn_ammo_awp, cvar_wpn_ammo_deagle, cvar_wpn_ammo_shotgun, cvar_wpn_ammo_default
new cvar_wpn_minigun_backforce, cvar_wpn_minigun_spinup, cvar_wpn_minigun_spindown, cvar_wpn_minigun_spining, cvar_wpn_minigun_slowdown
new cvar_wpn_rpg_damage, cvar_wpn_rpg_radius, cvar_wpn_rpg_multidamage, cvar_wpn_clip_rpg, cvar_wpn_ammo_rpg, cvar_wpn_rpg_rof, cvar_wpn_rpg_force, cvar_wpn_rpg_flare_cost, cvar_wpn_rpg_flare_time, cvar_wpn_rpg_flare_size, cvar_wpn_rpg_reload, cvar_wpn_rpg_repeat_time, cvar_wpn_rpg_repeat_max//火箭弹伤害,爆炸半径,对僵尸的伤害倍率,最大弹药,装弹时间
new cvar_wpn_medic_heal, cvar_wpn_medic_maxhealth, cvar_wpn_medic_charge, cvar_wpn_medic_power
new cvar_wpn_ammopack_percent, cvar_wpn_ammopack_charge, cvar_wpn_ammopack_power, cvar_wpn_charge_rate
//步哨枪
new cvar_build_sentry_hp_lv1, cvar_build_sentry_hp_lv2, cvar_build_sentry_hp_lv3 //步哨枪耐久
new cvar_build_sentry_ammo_lv1, cvar_build_sentry_ammo_lv2, cvar_build_sentry_ammo_lv3 //步哨枪弹药
new cvar_build_sentry_cost_lv1, cvar_build_sentry_cost_lv2, cvar_build_sentry_cost_lv3//步哨枪建造/升级需要金属
new cvar_build_sentry_bullet_lv1, cvar_build_sentry_bullet_lv2, cvar_build_sentry_bullet_lv3//步哨枪子弹伤害
new cvar_build_sentry_radius_lv1, cvar_build_sentry_radius_lv2, cvar_build_sentry_radius_lv3//步哨枪射程
new cvar_build_sentry_rocket_cost, cvar_build_sentry_rocket_reload, cvar_build_repair, cvar_build_sentry_rocket_damage, cvar_build_sentry_rocket_radius, cvar_build_sentry_rescan, cvar_build_sentry_rocket_multi//步哨枪火箭设置

//补给器
new cvar_build_dispenser_hp_lv1, cvar_build_dispenser_hp_lv2, cvar_build_dispenser_hp_lv3 //补给器耐久
new cvar_build_dispenser_ammo_lv1, cvar_build_dispenser_ammo_lv2, cvar_build_dispenser_ammo_lv3 //补给器弹药
new cvar_build_dispenser_cost_lv1, cvar_build_dispenser_cost_lv2, cvar_build_dispenser_cost_lv3//补给器建造/升级需要金属
new cvar_build_dispenser_radius_lv1, cvar_build_dispenser_radius_lv2, cvar_build_dispenser_radius_lv3 //补给器补给半径
new cvar_build_dispenser_heal_lv1, cvar_build_dispenser_heal_lv2, cvar_build_dispenser_heal_lv3, cvar_build_dispenser_supply//补给器医疗速度，补给器补弹量（百分制）
new cvar_build_dispenser_rsp_lv1, cvar_build_dispenser_rsp_lv2, cvar_build_dispenser_rsp_lv3//补给器弹药重生时间（5=1sec）

//传送装置
new cvar_build_telein_hp_lv1, cvar_build_telein_hp_lv2, cvar_build_telein_hp_lv3 //传送装置入口耐久
new cvar_build_teleout_hp_lv1, cvar_build_teleout_hp_lv2, cvar_build_teleout_hp_lv3 //传送装置出口耐久
new cvar_build_telein_cost_lv1, cvar_build_teleout_cost_lv1, cvar_build_tele_cost_lv2, cvar_build_tele_cost_lv3//传送装置建造/升级需要金属
new cvar_build_tele_reload_lv1, cvar_build_tele_reload_lv2, cvar_build_tele_reload_lv3 //传送装置重新准备速度
new cvar_build_tele_trans_lv1, cvar_build_tele_trans_lv2, cvar_build_tele_trans_lv3 //传送装置入口最小可见度 可见度计算公式 y=-2.25x+255 (y=renderamt,x=重装进度)

new cvar_wpn_craw_light, cvar_wpn_craw_heavy, cvar_cp_craw_light, cvar_ctf_craw_light, cvar_pl_craw_light, cvar_cp_craw_heavy, cvar_ctf_craw_heavy, cvar_pl_craw_heavy//僵尸轻刀重刀伤害
new cvar_wpn_moonstar_light, cvar_wpn_moonstar_heavy//星月轻刀/重刀伤害
new cvar_skill_airblast_power, cvar_skill_dodge_power, cvar_skill_dodge_percent, cvar_skill_dodge_slowdown, cvar_skill_disguise_multidamage, cvar_skill_disguise_multiforce, cvar_skill_longjump_force, cvar_skill_longjump_power
new cvar_skill_invisible_multidmg, cvar_skill_invisible_multifc, cvar_skill_invisible_power, cvar_skill_invisible_multisp, cvar_skill_moonstar_power
new cvar_global_crit_multi, cvar_global_crit_percent, cvar_supply_item_healthkit, cvar_supply_item_ammobox, cvar_supply_item_weapon, cvar_global_supply_respawn, cvar_global_gib_amount, cvar_global_gib_time, cvar_global_blood
new cvar_global_light, cvar_global_lightning, cvar_global_crit_tracecolor, cvar_global_crit_tracelen, cvar_global_crit_tracetime, cvar_cp_respawn, cvar_pl_respawn
new cvar_global_tele_cd, cvar_global_respawn, cvar_global_tele
new cvar_roundtime_default, cvar_roundtime_capture, cvar_roundtime_ctflag, cvar_roundtime_payload

const DMG_HEGRENADE = (1<<24)
const PRIMARY_WEAPONS = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
const SECONDARY_WEAPONS = ((1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE))

enum{//rpg,medicgun,supply,toolbox
	anim_c4_idle = 0,
	anim_c4_draw,
	anim_c4_shoot,
	anim_c4_reload
}

enum{//minigun
	anim_m249_idle = 0,
	anim_m249_shoot,
	anim_m249_shoot2,
	anim_m249_reload,
	anim_m249_draw,
	anim_m249_spinup,
	anim_m249_spindown,
	anim_m249_spining
}

enum{//minigun
	minigun_idle = 0,
	minigun_spinup,
	minigun_spindown,
	minigun_spining,
	minigun_shooting
}

enum{
	CS_TEAM_UNASSIGNED = 0,
	CS_TEAM_T,
	CS_TEAM_CT,
	CS_TEAM_SPECTATOR
}

enum{
	win_no = 0,
	win_human,
	win_zombie
}

enum{
	ach_fast_1 = 0,
	ach_fast_2,
	ach_fast_3,
	ach_fast_4,
	ach_fast_5,
	ach_fast_6,
	ach_fast_7,
	ach_fast_8,
	ach_fast_9,
	ach_fast_10,
	ach_fast_11,
	ach_fast_12,
	ach_fast_13,
	ach_fast_14
}


enum{
	round_setup = 0,
	round_start,
	round_zombie,
	round_end
}

enum{
	mode_normal = 0,
	mode_capture,
	mode_ctflag,
	mode_payload
}

enum{
	knife_normal = 0,
	knife_hammer,
	knife_moonstar
}

enum{
	zombie_fast = 1,
	zombie_gravity,
	zombie_classic,
	zombie_jump,
	zombie_invis
}

enum{
	human_scout = 1,
	human_heavy,
	human_rpg,
	human_snipe,
	human_log,
	human_eng
}
new CS_Teams[][] = { "UNASSIGNED", "TERRORIST", "CT", "SPECTATOR" }

//    :: Note :: think_开头循环函数,会被不停运行,大多以set_task来保持循环 :: ckrun_开头一般属于stock函数,一般属于简单指令或返回型函数:: event_开头属于事件函数,一般只被系统触发
//    :: Note :: FX_表示特效,一般无返回值 :: menu_表示菜单 :: fw_表示forward,一般都是fakemeta :: message_表示message函数,一般用于Block信息 :: block_只用于封锁 :: touch_是专门的接触类事件
public plugin_precache(){
	new i, playermodel[100]
	//自定义SPR:788kb --> 355kb
	explo = engfunc(EngFunc_PrecacheModel,"sprites/fexplo1.spr")//游戏自带
	trail = engfunc(EngFunc_PrecacheModel,"sprites/laserbeam.spr")//游戏自带
	flame = engfunc(EngFunc_PrecacheModel,"sprites/chickenrun/flame.spr")//257kb --> 85kb
	beam = engfunc(EngFunc_PrecacheModel,"sprites/chickenrun/medicbeam.spr")//1.81kb
	critspr = engfunc(EngFunc_PrecacheModel,"sprites/chickenrun/ft_critical.spr")//82kb --> 9kb
	rpglaunch = engfunc(EngFunc_PrecacheModel,"sprites/chickenrun/rpglaunch.spr")//28kb
	rpgsmoke = engfunc(EngFunc_PrecacheModel,"sprites/chickenrun/rpgsmoke.spr")//86kb
	exp_new1 = engfunc(EngFunc_PrecacheModel,"sprites/chickenrun/exp_new1.spr")//28kb
	exp_new2 = engfunc(EngFunc_PrecacheModel,"sprites/chickenrun/exp_new2.spr")//28kb
	exp_new3 = engfunc(EngFunc_PrecacheModel,"sprites/chickenrun/exp_new3.spr")//10kb
	spr_blood_spray = engfunc(EngFunc_PrecacheModel,"sprites/bloodspray.spr")//游戏自带
	spr_blood_drop = engfunc(EngFunc_PrecacheModel,"sprites/blood.spr")//游戏自带
	//message型MDL:112kb
	mdl_gib_build1 = engfunc(EngFunc_PrecacheModel,"models/mbarrel.mdl")//游戏自带
	mdl_gib_build2 = engfunc(EngFunc_PrecacheModel,"models/computergibs.mdl")//游戏自带
	mdl_gib_build3 = engfunc(EngFunc_PrecacheModel,"models/metalplategibs.mdl")//游戏自带
	mdl_gib_build4 = engfunc(EngFunc_PrecacheModel,"models/cindergibs.mdl")//游戏自带
	mdl_gib_player1 = engfunc(EngFunc_PrecacheModel,"models/gib_skull.mdl")//游戏自带
	mdl_gib_player2 = engfunc(EngFunc_PrecacheModel,"models/gib_lung.mdl")//游戏自带
	mdl_gib_player3 = engfunc(EngFunc_PrecacheModel,"models/gib_b_gib.mdl")//游戏自带
	mdl_gib_player4 = engfunc(EngFunc_PrecacheModel,"models/gib_b_bone.mdl")//游戏自带
	mdl_gib_player5 = engfunc(EngFunc_PrecacheModel,"models/gib_legbone.mdl")//游戏自带
	mdl_gib_player6 = engfunc(EngFunc_PrecacheModel,"models/gib_b_bone.mdl")//游戏自带

	#if defined CUSTOM_GIBMODEL//112kb
	for (i = 0; i < sizeof mdl_gib_head; i++)
		mdl_gib_list[0][i] = engfunc(EngFunc_PrecacheModel, mdl_gib_head[i])
	for (i = 0; i < sizeof mdl_gib_arm; i++)
		mdl_gib_list[1][i] = engfunc(EngFunc_PrecacheModel, mdl_gib_arm[i])
	for (i = 0; i < sizeof mdl_gib_hand; i++)
		mdl_gib_list[2][i] = engfunc(EngFunc_PrecacheModel, mdl_gib_hand[i])
	for (i = 0; i < sizeof mdl_gib_leg; i++)
		mdl_gib_list[3][i] = engfunc(EngFunc_PrecacheModel, mdl_gib_leg[i])
	for (i = 0; i < sizeof mdl_gib_foot; i++)
		mdl_gib_list[4][i] = engfunc(EngFunc_PrecacheModel, mdl_gib_foot[i])
	#endif

	//人物MDL:3.25MB --> 1.88mb
	engfunc(EngFunc_PrecacheModel, mdl_player_fastzombie)//636kb
	engfunc(EngFunc_PrecacheModel, mdl_player_classiczombie)//451kb
	engfunc(EngFunc_PrecacheModel, mdl_player_jumpzombie)//838kb
	for (i = 0; i < sizeof mdl_human; i++){//1.36mb
		formatex(playermodel, sizeof playermodel - 1, "models/player/%s/%s.mdl", mdl_human[i], mdl_human[i])
		engfunc(EngFunc_PrecacheModel, playermodel)
	}

	//直接调用型MDL:3.2mb --> 1.84mb
	engfunc(EngFunc_PrecacheModel,"models/chick.mdl")//游戏自带

	engfunc(EngFunc_PrecacheModel, "models/p_ak47.mdl")//游戏自带
	engfunc(EngFunc_PrecacheModel, "models/p_knife.mdl")//游戏自带
	engfunc(EngFunc_PrecacheModel, "models/p_awp.mdl")//游戏自带

	engfunc(EngFunc_PrecacheModel, mdl_pj_rpgrocket)//54kb
	//engfunc(EngFunc_PrecacheModel, mdl_pj_flare)//95kb

	engfunc(EngFunc_PrecacheModel, mdl_v_rpg)//463kb --> 222kb
	engfunc(EngFunc_PrecacheModel, mdl_p_rpg)//181kb --> 111kb
	engfunc(EngFunc_PrecacheModel, mdl_w_rpg)//182kb --> 111kb

	engfunc(EngFunc_PrecacheModel, mdl_v_medicgun)//游戏自带(egon)
	engfunc(EngFunc_PrecacheModel, mdl_p_medicgun)//游戏自带(egon)
	engfunc(EngFunc_PrecacheModel, mdl_w_medicgun)//游戏自带(egon)

	engfunc(EngFunc_PrecacheModel, mdl_v_ammopack)//159kb --> 72kb
	engfunc(EngFunc_PrecacheModel, mdl_p_ammopack)//20kb

	engfunc(EngFunc_PrecacheModel, mdl_v_toolbox)//207kb --> 75kb
	engfunc(EngFunc_PrecacheModel, mdl_p_toolbox)//73kb --> 12kb
	engfunc(EngFunc_PrecacheModel, mdl_w_toolbox)//71kb --> 10kb

	engfunc(EngFunc_PrecacheModel, mdl_v_pda)//94kb --> 81kb
	engfunc(EngFunc_PrecacheModel, mdl_p_pda)//44kb

	engfunc(EngFunc_PrecacheModel, mdl_v_hammer)//234kb --> 108kb
	engfunc(EngFunc_PrecacheModel, mdl_p_hammer)//74kb --> 32kb

	engfunc(EngFunc_PrecacheModel, mdl_v_minigun)//671kb --> 188kb
	engfunc(EngFunc_PrecacheModel, mdl_p_minigun)//游戏自带(m249)

	engfunc(EngFunc_PrecacheModel, mdl_v_moonstar)//121kb
	engfunc(EngFunc_PrecacheModel, mdl_p_moonstar)//10kb

	engfunc(EngFunc_PrecacheModel, mdl_v_knife_stab)//436kb -- 346kb
	engfunc(EngFunc_PrecacheModel, mdl_v_knife_invis)//56kb

	engfunc(EngFunc_PrecacheModel, mdl_v_knife)//游戏自带
	engfunc(EngFunc_PrecacheModel, mdl_p_knife)//游戏自带

	engfunc(EngFunc_PrecacheModel, mdl_w_healthkit)//游戏自带(healthkit)
	engfunc(EngFunc_PrecacheModel, mdl_w_ammobox)//51kb
	engfunc(EngFunc_PrecacheModel, mdl_w_bugkiller)//游戏自带(chick.mdl)

	engfunc(EngFunc_PrecacheModel, mdl_dispenser)//102kb
	engfunc(EngFunc_PrecacheModel, mdl_teleporter)//30kb

	engfunc(EngFunc_PrecacheModel, mdl_moonstar_mirror)//70kb

	engfunc(EngFunc_PrecacheModel,"models/sentries/base.mdl")//27kb
	engfunc(EngFunc_PrecacheModel,"models/sentries/sentry1.mdl")//30kb
	engfunc(EngFunc_PrecacheModel,"models/sentries/sentry2.mdl")//34kb
	engfunc(EngFunc_PrecacheModel,"models/sentries/sentry3.mdl")//34kb

	//WTF the map BUG
	engfunc(EngFunc_PrecacheSound,"debris/bustmetal1.wav")//游戏自带
	engfunc(EngFunc_PrecacheSound,"debris/bustmetal2.wav")//游戏自带
	engfunc(EngFunc_PrecacheSound,"weapons/m249-1.wav")//游戏自带
	engfunc(EngFunc_PrecacheGeneric, "events/train.sc")//游戏自带

	//自定义声音:2.28mb -->2.18mb(无环境音1.19mb)
	engfunc(EngFunc_PrecacheSound, snd_rpg_shoot)//64kb
	engfunc(EngFunc_PrecacheSound, snd_rpg_shoot_crit)//69kb
	engfunc(EngFunc_PrecacheSound, snd_crit_shoot)//40kb
	engfunc(EngFunc_PrecacheSound, snd_rpg_exp)//60kb
	engfunc(EngFunc_PrecacheSound, snd_medic_heal)//121kb
	engfunc(EngFunc_PrecacheSound, snd_charge_on)//128kb --> 103kb
	engfunc(EngFunc_PrecacheSound, snd_charge_off)//112kb --> 90kb
	engfunc(EngFunc_PrecacheSound, snd_sentry_rocket)//77kb
	engfunc(EngFunc_PrecacheSound, snd_sentry_shoot)//30kb
	engfunc(EngFunc_PrecacheSound, snd_sentry_scan)//22kb
	engfunc(EngFunc_PrecacheSound, snd_dispenser_heal)//160kb --> 128kb
	engfunc(EngFunc_PrecacheSound, snd_minigun_spining)//20kb
	engfunc(EngFunc_PrecacheSound, snd_minigun_spinup)//34kb
	engfunc(EngFunc_PrecacheSound, snd_minigun_spindown)//46kb
	engfunc(EngFunc_PrecacheSound, snd_moonstar_mirror)//38kb
	engfunc(EngFunc_PrecacheSound,"weapons/dryfire_rifle.wav")//游戏自带
	engfunc(EngFunc_PrecacheSound,"items/gunpickup3.wav")//游戏自带
	engfunc(EngFunc_PrecacheSound,"weapons/knife_stab.wav")//游戏自带

	for (i = 0; i < sizeof snd_hammer; i++)//16kb
		engfunc(EngFunc_PrecacheSound, snd_hammer[i])

	for (i = 0; i < sizeof snd_thunder; i++)//游戏自带
		engfunc(EngFunc_PrecacheSound, snd_thunder[i])

	for (i = 0; i < sizeof snd_win_no; i++)//144kb --> 131kb
		engfunc(EngFunc_PrecacheSound, snd_win_no[i])

	for (i = 0; i < sizeof snd_win_human; i++)//86kb
		engfunc(EngFunc_PrecacheSound, snd_win_human[i])

	for (i = 0; i < sizeof snd_win_zombie; i++)//75kb
		engfunc(EngFunc_PrecacheSound, snd_win_zombie[i])

	#if defined CUSTOM_DEATHSOUND
	for (i = 0; i < sizeof snd_death_custom; i++)//11kb
		engfunc(EngFunc_PrecacheSound, snd_death_custom[i])
	#endif

	#if defined AMBIENCE_SOUND//1mb(mp3)
	if (equal(snd_ambience[strlen(snd_ambience)-4], ".mp3")){
		engfunc(EngFunc_PrecacheGeneric, snd_ambience)
	} else {
		engfunc(EngFunc_PrecacheSound, snd_ambience)
	}
	#endif

	static ent
	#if defined AMBIENCE_FOG
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_fog"))
	if (pev_valid(ent)){
		fm_set_kvd(ent, "density", "0.0005", "env_fog")
		fm_set_kvd(ent, "rendercolor", "0 0 0", "env_fog")
	}
	#endif
	#if defined AMBIENCE_RAIN
		engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_rain"))
	#endif
	g_fwEntitySpawn = register_forward(FM_Spawn, "fw_EntitySpawn")
	g_fwKeyValue = register_forward(FM_KeyValue, "fw_KeyValue")
}

public faketeambot_create(){
	if(!is_user_connected(g_ctbot)){
		g_ctbot = engfunc(EngFunc_CreateFakeClient, team_names[2])
		new ptr2[128]
		dllfunc(DLLFunc_ClientConnect, g_ctbot, team_names[0], "127.0.0.1", ptr2 )
		dllfunc(DLLFunc_ClientPutInServer, g_ctbot)
		fm_set_user_team(g_ctbot, CS_TEAM_CT)
	}
	if(!is_user_connected(g_tbot)){
		g_tbot = engfunc(EngFunc_CreateFakeClient, team_names[3])
		new ptr[128]
		dllfunc(DLLFunc_ClientConnect, g_tbot, team_names[0], "127.0.0.1", ptr )
		dllfunc(DLLFunc_ClientPutInServer, g_tbot)
		fm_set_user_team(g_tbot, CS_TEAM_T)
	}
}

public event_playerdie(){
	new enemy = read_data(1)
	new id = read_data(2)
	//new headshot = read_data(3)
	if(!(1 <= id <= g_maxplayers)) return;
	new wpname[32], bool:validwpn = false
	read_data(4, wpname, 31)

	if(is_user_connected(enemy)) fm_set_user_money(enemy, 0)//防止购买
	set_task(float(get_pcvar_num(cvar_global_respawn)),"respawn", id+TASK_RESPAWN)
	set_task(0.1,"spawn_fix", id)
	set_task(0.1,"check_end")

	if(!giszm[id]){//drop item
		new Float:origin[3]
		pev(id, pev_origin, origin)
		new parm[4]
		ckrun_FVecIVec(origin, parm)
		switch(ghuman[id]){
			case 3:parm[3] = CKI_RPG
			case 5:parm[3] = CKI_MEDICGUN
			case 6:parm[3] = CKI_TOOLBOX
			default: parm[3] = 0//你哪来的包?..
		}
		ckrun_create_item_temp(parm)
	}

	for(new i=0; i <= sizeof g_wpn_name - 1; i++)//有效武器?
		if (equal(wpname, g_wpn_name[i]))
			validwpn = true
	if((!(1 <= enemy <= g_maxplayers) || enemy == id) && validwpn){
		ckrun_fakekill_msg(id, id, wpname, 0)
		return;
	}
	else if(giszm[enemy] && equal(wpname, "knife")){//背刺?
		ckrun_fakekill_msg(id, enemy, g_wpn_name[39], 1)
		return;
	}
	if(enemy != id && validwpn)
		ckrun_fakekill_msg(id, enemy, wpname, gcritkilled[id])
}

public ckrun_fakekill_msg(id, enemy, const wpname[], critical){
	new build
	if(id > g_maxplayers){
		if(is_user_connected(id - DEATHMSG_SENTRY)){
			build = 1
			id -= DEATHMSG_SENTRY
		} else if(is_user_connected(id - DEATHMSG_DISPENSER)){
			build = 2
			id -= DEATHMSG_DISPENSER
		} else if(is_user_connected(id - DEATHMSG_TELEIN)){
			build = 3
			id -= DEATHMSG_TELEIN
		} else if(is_user_connected(id - DEATHMSG_TELEOUT)){
			build = 4
			id -= DEATHMSG_TELEOUT
		} else {
			return;
		}
	} else if(!is_user_connected(id)){
		return;
	}
	if(id == enemy || !(1 <= enemy <= g_maxplayers)){//非玩家杀害
		ckrun_deathmsg(id, 0, id, 0, wpname)
		ckrun_add_user_score(id,0,2)
		return
	}
	if(giszm[id] && !giszm[enemy]){
		gstats[enemy][1] ++
		new assistant = ckrun_get_user_assistance(enemy)
		if(is_user_alive(assistant)){
			ckrun_add_user_score(enemy,2,0)
			ckrun_add_user_score(id,0,2)
			ckrun_add_user_score(assistant, 2, 0)
			ckrun_deathmsg(enemy, assistant, id, critical, wpname)
			if(!g_firstkill){
				g_firstkill = true
			}
		} else if (glastatk[id] == enemy && is_user_alive(glast2atk[id]) && glast2atk[id] != enemy && !giszm[glast2atk[id]]){
			assistant = glast2atk[id]
			ckrun_add_user_score(enemy,2,0)
			ckrun_add_user_score(id,0,2)
			ckrun_add_user_score(assistant, 1, 0)
			ckrun_deathmsg(enemy, assistant, id, critical, wpname)
			if(!g_firstkill){
				g_firstkill = true
			}
		} else if (glast2atk[id] == enemy && is_user_alive(glastatk[id]) && glastatk[id] != enemy && !giszm[glastatk[id]]){
			assistant = glastatk[id]
			ckrun_add_user_score(enemy,2,0)
			ckrun_add_user_score(id,0,2)
			ckrun_add_user_score(assistant, 1, 0)
			ckrun_deathmsg(enemy, assistant, id, critical, wpname)
			if(!g_firstkill){
				g_firstkill = true
			}
		} else {
			ckrun_add_user_score(enemy,2,0)
			ckrun_add_user_score(id,0,2)
			ckrun_deathmsg(enemy, 0, id, 0, wpname)

			if(!g_firstkill){
				g_firstkill = true
				
			}
		}
	} else if (!giszm[id] && giszm[enemy]){
		switch(build){
			case 0: {
				gstats[enemy][0] ++
				gstats[id][2] ++
				ckrun_add_user_score(enemy,2,0)
				ckrun_add_user_score(id,0,2)
				ckrun_deathmsg(enemy, 0, id, critical, wpname)
				check_ach_fast_1(enemy)
				if(ghuman[id] == human_scout) check_ach_fast_3(enemy)
				check_ach_fast_4(enemy)
			}
			case 1: {
				ckrun_add_user_score(enemy,1,0)
				ckrun_add_user_score(id,0,1)
				ckrun_deathmsg(enemy, 0, id + DEATHMSG_SENTRY, critical, wpname)
			}
			case 2: {
				ckrun_add_user_score(enemy,1,0)
				ckrun_add_user_score(id,0,1)
				ckrun_deathmsg(enemy, 0, id + DEATHMSG_DISPENSER, critical, wpname)
			}
			case 3: {
				ckrun_add_user_score(enemy,1,0)
				ckrun_add_user_score(id,0,1)
				ckrun_deathmsg(enemy, 0, id + DEATHMSG_TELEIN, critical, wpname)
			}
			case 4: {
				ckrun_add_user_score(enemy,1,0)
				ckrun_add_user_score(id,0,1)
				ckrun_deathmsg(enemy, 0, id + DEATHMSG_TELEOUT, critical, wpname)
			}
		}
	}
}
public spawn_fix(taskid){
	ckrun_add_user_score(taskid,0,0)
}
public respawn(taskid){
	static id
	if(taskid > g_maxplayers)
		id = taskid - TASK_RESPAWN
	else
		id = taskid
	remove_task(id+TASK_RESPAWN, 0)
	if(g_round == round_end) return;
	if(!(1 <= id <= g_maxplayers)) return;
	if(is_user_alive(id)) return;
	if(fm_get_user_team(id) == CS_TEAM_SPECTATOR || get_user_team(id) == CS_TEAM_UNASSIGNED) return;
	if(g_round != round_zombie){
		set_task(5.0,"respawn",id+TASK_RESPAWN)
		return
	}
	gcorpse_hidden[id] = false
	ExecuteHamB(Ham_CS_RoundRespawn, id)
}
public event_damage(id){
	if(is_user_alive(id)) ckrun_showhud_status(id)
}
public fw_damage_build(id, inf, enemy, Float:damage, damagetype){
	if (!(1 <= enemy <= g_maxplayers))//非玩家伤害
		return HAM_IGNORED
	new classname[24]
	pev(id, pev_classname, classname, 23)

	if(equal(classname,"sentry_base")){
		new wep = get_user_weapon(enemy)
		new owner = pev(id, BUILD_OWNER)
		if(wep != CSW_KNIFE)
			return HAM_SUPERCEDE
		new bool:heavyknife
		if(damage <= 50.0) heavyknife = false
		else heavyknife = true
		if(enemy == owner && ghuman[enemy] == human_eng && !giszm[enemy] && gknife[enemy] == knife_hammer){
			if(!heavyknife)
				ckrun_sentry_repair(enemy,1)
			else
				ckrun_sentry_repair(enemy,2)
		} else if(ghuman[enemy] == human_eng && ghuman[owner] == human_eng && !giszm[enemy] && !giszm[owner] && owner != enemy && gknife[enemy] == knife_hammer){
			if(!heavyknife)
				ckrun_sentry_repair_help(owner,enemy,1)
			else
				ckrun_sentry_repair_help(owner,enemy,2)
		}
		if(!giszm[enemy] || g_round == round_end)
			return HAM_SUPERCEDE
		if(!heavyknife){
			switch(gknife[enemy]){
				case knife_normal: damage = float(get_pcvar_num(cvar_wpn_craw_light))
				case knife_moonstar: damage = float(get_pcvar_num(cvar_wpn_moonstar_light))
			}
		} else {
			switch(gknife[enemy]){
				case knife_normal: damage = float(get_pcvar_num(cvar_wpn_craw_heavy))
				case knife_moonstar: damage = float(get_pcvar_num(cvar_wpn_moonstar_heavy))
			}
		}
		ckrun_fakedamage_build(owner, enemy, floatround(damage), CSW_KNIFE, 1)
		return HAM_SUPERCEDE
	} else if (equal(classname,"dispenser")){
		new wep = get_user_weapon(enemy)
		new owner = pev(id, BUILD_OWNER)
		if(wep != CSW_KNIFE)
			return HAM_SUPERCEDE
		new bool:heavyknife
		if(damage <= 50.0) heavyknife = false
		else heavyknife = true
		if(enemy == owner && ghuman[enemy] == human_eng && !giszm[enemy]){
			if(!heavyknife)
				ckrun_dispenser_repair(enemy,1)
			else
				ckrun_dispenser_repair(enemy,2)
		} else if(ghuman[enemy] == human_eng && ghuman[owner] == human_eng && !giszm[enemy] && !giszm[owner] && owner != enemy){
			if(!heavyknife)
				ckrun_dispenser_repair_help(owner,enemy,1)
			else
				ckrun_dispenser_repair_help(owner,enemy,2)
		}
		if(!giszm[enemy] || g_round == round_end)
			return HAM_SUPERCEDE
		if(!heavyknife){
			switch(gknife[enemy]){
				case knife_normal: damage = float(get_pcvar_num(cvar_wpn_craw_light))
				case knife_moonstar: damage = float(get_pcvar_num(cvar_wpn_moonstar_light))
			}
		} else {
			switch(gknife[enemy]){
				case knife_normal: damage = float(get_pcvar_num(cvar_wpn_craw_heavy))
				case knife_moonstar: damage = float(get_pcvar_num(cvar_wpn_moonstar_heavy))
			}
		}
		ckrun_fakedamage_build(owner, enemy, floatround(damage), CSW_KNIFE, 2)
		return HAM_SUPERCEDE
	} else if (equal(classname,"telein")){
		new wep = get_user_weapon(enemy)
		new owner = pev(id, BUILD_OWNER)
		if(wep != CSW_KNIFE)
			return HAM_SUPERCEDE
		new bool:heavyknife
		if(damage <= 50.0) heavyknife = false
		else heavyknife = true
		if(enemy == owner && ghuman[enemy] == human_eng && !giszm[enemy]){
			if(!heavyknife)
				ckrun_telein_repair(enemy, 1)
			else
				ckrun_telein_repair(enemy, 2)
		} else if(ghuman[enemy] == human_eng && ghuman[owner] == human_eng && !giszm[enemy] && !giszm[owner] && owner != enemy){
			if(!heavyknife)
				ckrun_telein_repair_help(owner, enemy, 1)
			else
				ckrun_telein_repair_help(owner, enemy, 2)
		}
		if(!giszm[enemy] || g_round == round_end)
			return HAM_SUPERCEDE
		if(!heavyknife){
			switch(gknife[enemy]){
				case knife_normal: damage = float(get_pcvar_num(cvar_wpn_craw_light))
				case knife_moonstar: damage = float(get_pcvar_num(cvar_wpn_moonstar_light))
			}
		} else {
			switch(gknife[enemy]){
				case knife_normal: damage = float(get_pcvar_num(cvar_wpn_craw_heavy))
				case knife_moonstar: damage = float(get_pcvar_num(cvar_wpn_moonstar_heavy))
			}
		}
		ckrun_fakedamage_build(owner, enemy, floatround(damage), CSW_KNIFE, 3)
		return HAM_SUPERCEDE
	} else if (equal(classname,"teleout")){
		new wep = get_user_weapon(enemy)
		new owner = pev(id, BUILD_OWNER)
		if(wep != CSW_KNIFE)
			return HAM_SUPERCEDE
		new bool:heavyknife
		if(damage <= 50.0) heavyknife = false
		else heavyknife = true
		if(enemy == owner && ghuman[enemy] == human_eng && !giszm[enemy]){
			if(!heavyknife)
				ckrun_teleout_repair(enemy, 1)
			else
				ckrun_teleout_repair(enemy, 2)
		} else if(ghuman[enemy] == human_eng && ghuman[owner] == human_eng && !giszm[enemy] && !giszm[owner] && owner != enemy){
			if(!heavyknife)
				ckrun_teleout_repair_help(owner, enemy, 1)
			else
				ckrun_teleout_repair_help(owner, enemy, 2)
		}
		if(!giszm[enemy] || g_round == round_end)
			return HAM_SUPERCEDE
		if(!heavyknife){
			switch(gknife[enemy]){
				case knife_normal: damage = float(get_pcvar_num(cvar_wpn_craw_light))
				case knife_moonstar: damage = float(get_pcvar_num(cvar_wpn_moonstar_light))
			}
		} else {
			switch(gknife[enemy]){
				case knife_normal: damage = float(get_pcvar_num(cvar_wpn_craw_heavy))
				case knife_moonstar: damage = float(get_pcvar_num(cvar_wpn_moonstar_heavy))
			}
		}
		ckrun_fakedamage_build(owner, enemy, floatround(damage), CSW_KNIFE, 4)
		return HAM_SUPERCEDE
	}
	return HAM_IGNORED
}

public fw_damage(id, inf, enemy, Float:damage, damagetype){
	if(damagetype & DMG_FALL){
		if((gcharge_shield[gmediced[id]] || gcharge_shield[gammoed[id]]) && ckrun_get_user_assistance(id) != 0)//无敌
			return HAM_SUPERCEDE
		if(gcharge_shield[id])//无敌
			return HAM_SUPERCEDE
		damage /= 2.0
		if(damage > 500.0)
			damage = 500.0
		SetHamParamFloat(4, damage)
		if(floatround(damage) >= get_user_health(id) && is_user_alive(id)) check_ach_fast_5(id)
		return HAM_IGNORED
	}
	if (id == enemy || !(1 <= enemy <= g_maxplayers))//自残或非玩家伤害
		return HAM_IGNORED

	if(id == g_ctbot || id == g_tbot)
		return HAM_SUPERCEDE

	if((gcharge_shield[gmediced[id]] || gcharge_shield[gammoed[id]]) && ckrun_get_user_assistance(id) != 0)//无敌
		return HAM_SUPERCEDE

	if(gcharge_shield[id])//无敌
		return HAM_SUPERCEDE

	if(giszm[enemy] == giszm[id])
		return HAM_SUPERCEDE

	new weapon = get_user_weapon(enemy)
	new bool:crit
	//僵尸感染伤害

	if (!giszm[id] && giszm[enemy]){
		if(gstabing[enemy]){
			if(is_back_face(enemy, id)){
				SetHamParamFloat(4, 9999.0)//背刺
				FX_Critical(enemy, id)
				FX_Gibs(id)
				crit = true
				check_ach_fast_7(enemy)
				return HAM_IGNORED
			}
		}
		if(damage <= 50.0) damage = float(get_pcvar_num(cvar_wpn_craw_light))
		if(damage > 50.0) damage = float(get_pcvar_num(cvar_wpn_craw_heavy))
		if(gfrozen[id]) damage *= 0.1
		SetHamParamFloat(4, damage)
		if(get_user_health(id)-floatround(damage) > 1) return HAM_IGNORED
		//ckrun_fakekill_msg(id, enemy, g_wpn_name[CKW_INFECT], 0)
		ckrun_fakekill_msg(id, enemy, g_wpn_name[CKW_INFECT], 0)
		ckrun_reset_user_deadflag(id)
		if(g_gamemode == mode_normal){
			SetHamParamFloat(4, 0.0)//JS捅不死人的哦囧
			ckrun_set_user_zombie(id)
			new infecter[24], infected[24]
			get_user_name(enemy, infecter, sizeof infecter - 1)
			get_user_name(id, infected, sizeof infected - 1)
			format(g_text3, sizeof g_text3 - 1, "%s", g_text2)
			format(g_text2, sizeof g_text2 - 1, "%s", g_text1)
			format(g_text1, sizeof g_text1 - 1, "%L", LANG_PLAYER, msg_infect[random_num(0, sizeof msg_infect - 1)])
			replace(g_text1, sizeof g_text1 - 1, "$kn", infecter)
			replace(g_text1, sizeof g_text1 - 1, "$vn", infected)
			//成就
			check_ach_fast_2(enemy)//感染2008
			check_ach_fast_7(enemy)
			if(g_ach_rocketjump[id]) check_ach_fast_12(enemy)
			if(ghuman[id] == human_heavy && is_back_face(enemy, id)) check_ach_fast_13(enemy)

			set_task(0.1,"check_end")
		} else { // killed
			check_ach_fast_2(enemy)//感染2008
			check_ach_fast_7(enemy)
			if(g_ach_rocketjump[id]) check_ach_fast_12(enemy)
			if(ghuman[id] == human_heavy && is_back_face(enemy, id)) check_ach_fast_13(enemy)
			SetHamParamFloat(4, damage)
			return HAM_IGNORED
		}
	}
	//人类伤害
	else if(giszm[id] && !giszm[enemy]){
		//燃烧弹
		if(damagetype & DMG_HEGRENADE){
			gflamer[id] = enemy
			if(gflame[id] < 150)
				gflame[id] = 150
			damage *= (float(get_pcvar_num(cvar_wpn_multidamage_he)) / 100.0)
			new critical = random_num(1,100)
			if(critical <= gcritical[enemy] || gcritical_on[enemy]){
				damage *= float(get_pcvar_num(cvar_global_crit_multi)) / 100.0
				FX_Critical(enemy, id)
				crit = true
			}
			if(gdisguising[id])
				damage *= float(get_pcvar_num(cvar_skill_disguise_multidamage)) / 100.0
			else if (ginvisible[id])
				damage *= float(get_pcvar_num(cvar_skill_invisible_multidmg)) / 100.0
			SetHamParamFloat(4, damage)
			return HAM_IGNORED
		}
		//枪类武器
		switch(weapon){
			case CSW_KNIFE: {
				switch(gknife[enemy]){
					case knife_normal:damage *= (float(get_pcvar_num(cvar_wpn_multidamage_knife)) / 100.0)
					case knife_hammer:damage *= (float(get_pcvar_num(cvar_wpn_multidamage_hammer)) / 100.0)
				}
				if(gcritical_on[enemy]){
					damage *= float(get_pcvar_num(cvar_global_crit_multi)) / 100.0
					FX_Critical(enemy,id)
					crit = true
				}
				if(gdisguising[id])
					damage *= float(get_pcvar_num(cvar_skill_disguise_multidamage)) / 100.0
				else if (ginvisible[id])
					damage *= float(get_pcvar_num(cvar_skill_invisible_multidmg)) / 100.0
				SetHamParamFloat(4, damage)
			}
			case CSW_AWP: {
				if(damage > 400){//head shot
					damage *= float(get_pcvar_num(cvar_global_crit_multi)) / 100.0
					FX_Critical(enemy, id)
					FX_ColoredTrace(enemy, id)
					crit = true
				}
				damage *= (float(get_pcvar_num(cvar_wpn_multidamage_awp)) / 100.0)
				if(gsnipecharging[enemy] && gsnipecharge[enemy] > 0)
					damage *= (1.0 + float(gsnipecharge[enemy]) * (float(get_pcvar_num(cvar_wpn_awp_charge)) / 100.0 ) )
				new force = ckrun_get_user_force(id, floatround(damage)) / 2
				if(gdodgeon[id] && gpower[id] >= get_pcvar_num(cvar_skill_dodge_power))
					if(random_num(1,100) <= get_pcvar_num(cvar_skill_dodge_percent)){
						gpower[id] -= get_pcvar_num(cvar_skill_dodge_power)
						force = 0
					}
				if(gdisguising[id]){
					damage *= float(get_pcvar_num(cvar_skill_disguise_multidamage)) / 100.0
					force *= get_pcvar_num(cvar_skill_disguise_multiforce) / 100
				} else if (ginvisible[id]){
					damage *= float(get_pcvar_num(cvar_skill_invisible_multidmg)) / 100.0
					force *= get_pcvar_num(cvar_skill_invisible_multifc) / 100
				}
				SetHamParamFloat(4, damage)
				ckrun_knockback(id,enemy,force,0)//受害者,攻击者,推力
			}
			case CSW_M249: {
				damage *= (float(get_pcvar_num(cvar_wpn_multidamage_m249)) / 100.0)
				if(gcritical_on[enemy]){
					damage *= float(get_pcvar_num(cvar_global_crit_multi)) / 100.0
					FX_Critical(enemy,id)
					crit = true
				}
				new force = ckrun_get_user_force(id, floatround(damage)) / 2
				if(gdodgeon[id] && gpower[id] >= get_pcvar_num(cvar_skill_dodge_power))
					if(random_num(1,100) <= get_pcvar_num(cvar_skill_dodge_percent)){
						gpower[id] -= get_pcvar_num(cvar_skill_dodge_power)
						ckrun_showhud_status(id)
						force = 0
					}
				if(gdisguising[id]){
					damage *= float(get_pcvar_num(cvar_skill_disguise_multidamage)) / 100.0
					force *= get_pcvar_num(cvar_skill_disguise_multiforce) / 100
				} else if (ginvisible[id]){
					damage *= float(get_pcvar_num(cvar_skill_invisible_multidmg)) / 100.0
					force *= get_pcvar_num(cvar_skill_invisible_multifc) / 100
				}
				SetHamParamFloat(4, damage)
				ckrun_knockback(id,enemy,force,0)//受害者,攻击者,推力
			}
			case CSW_DEAGLE: {
				damage *= (float(get_pcvar_num(cvar_wpn_multidamage_deagle)) / 100.0)
				if(gcritical_on[enemy]){
					damage *= float(get_pcvar_num(cvar_global_crit_multi)) / 100.0
					FX_Critical(enemy,id)
					crit = true
				}
				new force = ckrun_get_user_force(id, floatround(damage)) / 2
				if(gdodgeon[id] && gpower[id] >= get_pcvar_num(cvar_skill_dodge_power))
					if(random_num(1,100) <= get_pcvar_num(cvar_skill_dodge_percent)){
						gpower[id] -= get_pcvar_num(cvar_skill_dodge_power)
						ckrun_showhud_status(id)
						force = 0
					}
				if(gdisguising[id]){
					damage *= float(get_pcvar_num(cvar_skill_disguise_multidamage)) / 100.0
					force *= get_pcvar_num(cvar_skill_disguise_multiforce) / 100
				} else if (ginvisible[id]){
					damage *= float(get_pcvar_num(cvar_skill_invisible_multidmg)) / 100.0
					force *= get_pcvar_num(cvar_skill_invisible_multifc) / 100
				}
				SetHamParamFloat(4, damage)
				ckrun_knockback(id,enemy,force,0)//受害者,攻击者,推力
			}
			case CSW_M3, CSW_XM1014: {
				damage *= (float(get_pcvar_num(cvar_wpn_multidamage_shotgun)) / 100.0)
				if(gcritical_on[enemy]){
					damage *= float(get_pcvar_num(cvar_global_crit_multi)) / 100.0
					FX_Critical(enemy,id)
					crit = true
				}
				new force = ckrun_get_user_force(id, floatround(damage)) / 2
				if(gdodgeon[id] && gpower[id] >= get_pcvar_num(cvar_skill_dodge_power))
					if(random_num(1,100) <= get_pcvar_num(cvar_skill_dodge_percent)){
						gpower[id] -= get_pcvar_num(cvar_skill_dodge_power)
						ckrun_showhud_status(id)
						force = 0
					}
				if(gdisguising[id]){
					damage *= float(get_pcvar_num(cvar_skill_disguise_multidamage)) / 100.0
					force *= get_pcvar_num(cvar_skill_disguise_multiforce) / 100
				} else if (ginvisible[id]){
					damage *= float(get_pcvar_num(cvar_skill_invisible_multidmg)) / 100.0
					force *= get_pcvar_num(cvar_skill_invisible_multifc) / 100
				}
				SetHamParamFloat(4, damage)
				ckrun_knockback(id,enemy,force,0)//攻击者，受害者，推力
			}
			default: {
				damage *= (float(get_pcvar_num(cvar_wpn_multidamage_default)) / 100.0)
				if(gcritical_on[enemy]){
					damage *= float(get_pcvar_num(cvar_global_crit_multi)) / 100.0
					FX_Critical(enemy,id)
					crit = true
				}
				new force = ckrun_get_user_force(id, floatround(damage)) / 2
				if(gdodgeon[id] && gpower[id] >= get_pcvar_num(cvar_skill_dodge_power))
					if(random_num(1,100) <= get_pcvar_num(cvar_skill_dodge_percent)){
						gpower[id] -= get_pcvar_num(cvar_skill_dodge_power)
						ckrun_showhud_status(id)
						force = 0
					}
				if(gdisguising[id]){
					damage *= float(get_pcvar_num(cvar_skill_disguise_multidamage)) / 100.0
					force *= get_pcvar_num(cvar_skill_disguise_multiforce) / 100
				} else if (ginvisible[id]){
					damage *= float(get_pcvar_num(cvar_skill_invisible_multidmg)) / 100.0
					force *= get_pcvar_num(cvar_skill_invisible_multifc) / 100
				}
				SetHamParamFloat(4, damage)
				ckrun_knockback(id,enemy,force,0)//攻击者，受害者，推力
			}
		}
		if(!is_user_alive(glastatk[id]) || giszm[glastatk[id]]){
			glastatk[id] = enemy
		} else if (!is_user_alive(glast2atk[id]) || giszm[glast2atk[id]]){
			glast2atk[id] = enemy
		} else if (glastatk[id] != enemy && glast2atk[id] != enemy){
			glast2atk[id] = enemy
		} else if (glastatk[id] != enemy && glast2atk[id] == enemy){
			glast2atk[id] = glastatk[id]
			glastatk[id] = enemy
		}
	}
	if(floatround(damage) >= get_user_health(id) && is_user_alive(id)){
		if(crit){
			gcritkilled[id] = 1
			check_ach_fast_6(id)
		}
	}
	return HAM_IGNORED
}

//特效
stock FX_Smoke(Float:Origin[3]){
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, Origin)
	write_byte(TE_SMOKE)
	engfunc(EngFunc_WriteCoord, Origin[0])
	engfunc(EngFunc_WriteCoord, Origin[1])
	engfunc(EngFunc_WriteCoord, Origin[2])
	write_short(rpgsmoke)
	write_byte(10)
	write_byte(6)
	message_end()
}
stock FX_Explode(Float:Origin[3], anim, scale, rate, flags){//暴击
	new iorigin[3]
	FVecIVec(Origin,iorigin)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	write_coord(iorigin[0])
	write_coord(iorigin[1])
	write_coord(iorigin[2])
	write_short(anim)
	write_byte(scale)
	write_byte(rate)
	write_byte(flags)
	message_end()
}

stock FX_NewExplode(Float:origin[3]){
	new iorigin[3]
	FVecIVec(origin,iorigin)

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_SPARKS)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	message_end()

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, origin[0]+random_float(-5.0, 5.0)) // x
	engfunc(EngFunc_WriteCoord, origin[1]+random_float(-5.0, 5.0)) // y
	engfunc(EngFunc_WriteCoord, origin[2]+random_float(-10.0, 10.0)) // z
	write_short(exp_new1)
	write_byte(random_num(10, 20))
	write_byte(random_num(10, 20))
	write_byte(TE_EXPLFLAG_NOSOUND)
	message_end()

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, origin[0]+random_float(-5.0, 5.0)) // x
	engfunc(EngFunc_WriteCoord, origin[1]+random_float(-5.0, 5.0)) // y
	engfunc(EngFunc_WriteCoord, origin[2]+random_float(-10.0, 10.0)) // z
	write_short(exp_new2)
	write_byte(random_num(10, 20))
	write_byte(random_num(10, 20))
	write_byte(TE_EXPLFLAG_NOSOUND)
	message_end()

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, origin[0]+random_float(-5.0, 5.0)) // x
	engfunc(EngFunc_WriteCoord, origin[1]+random_float(-5.0, 5.0)) // y
	engfunc(EngFunc_WriteCoord, origin[2]+random_float(-10.0, 10.0)) // z
	write_short(exp_new3)
	write_byte(random_num(20, 30))
	write_byte(random_num(10, 20))
	write_byte(TE_EXPLFLAG_NOSOUND)
	message_end()
}


stock FX_DLight(Float:Origin[3], size, r, g, b, time){//暴击
	new iorigin[3]
	FVecIVec(Origin,iorigin)
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_DLIGHT)
	write_coord(iorigin[0])
	write_coord(iorigin[1])
	write_coord(iorigin[2])
	write_byte(size)
	write_byte(r)
	write_byte(g)
	write_byte(b)
	write_byte(time)
	write_byte(60)
	message_end()
}
stock FX_Critical(id, target){//暴击
	if(!is_user_alive(id) || !is_user_alive(target)) return;
	engfunc(EngFunc_EmitSound,id, CHAN_STATIC, "chickenrun/crit_shoot.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	engfunc(EngFunc_EmitSound,target, CHAN_STATIC, "chickenrun/crit_shoot.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
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
	write_short(critspr)
	write_byte(1)
	write_coord(30)
	message_end()
}
stock FX_Flame(id){//燃烧
	if(!is_user_alive(id))
		return 
	new iorigin[3], Float:forigin[3]
	pev(id, pev_origin, forigin)
	FVecIVec(forigin, iorigin)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_SPRITE)
	write_coord(iorigin[0])
	write_coord(iorigin[1])
	write_coord(iorigin[2])
	write_short(flame)
	write_byte(15)
	write_byte(200)
	message_end()
}
stock FX_Healbeam(from, to, r, g, b, time){
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMENTS)
	write_short(from)
	write_short(to)
	write_short(beam)
	write_byte(0)
	write_byte(0)
	write_byte(time)
	write_byte(20)
	write_byte(0)
	write_byte(r)
	write_byte(g)
	write_byte(b)
	write_byte(100)
	write_byte(0)
	message_end()
}
stock FX_Sprite(Float:forigin[3], sprite, scale, bright){
	new iorigin[3]
	FVecIVec(forigin, iorigin)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_SPRITE)
	write_coord(iorigin[0])
	write_coord(iorigin[1])
	write_coord(iorigin[2])
	write_short(sprite) 
	write_byte(scale) 
	write_byte(bright)
	message_end()
}
stock FX_ScreenShake(id){
	message_begin(MSG_ONE, g_msgScreenShake, {0,0,0}, id)  // 屏幕抖动效果
	write_short(1<<14)
	write_short(1<<14)
	write_short(1<<14)
	message_end()
}
stock FX_Gibs(id){//分尸
	if(!is_user_alive(id))
		return
	fm_set_rendering(id,kRenderFxNone, 0,0,0, kRenderTransTexture,0)
	gcorpse_hidden[id] = true
	new i
	new idorigin[3], Float:forigin[3]
	pev(id, pev_origin, forigin)
	FVecIVec(forigin, idorigin)
	#if defined CUSTOM_GIBMODEL
	new x
	for (i = 0; i < sizeof mdl_gib_model; i++){
		if (equal(mdl_gib_model[i], gcurmodel[id])){
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(TE_MODEL)
			write_coord(idorigin[0])
			write_coord(idorigin[1])
			write_coord(idorigin[2])
			write_coord(random_num(-150,150))
			write_coord(random_num(-150,150))
			write_coord(random_num(150,350))
			write_angle(random_num(0,360))
			write_short(mdl_gib_list[0][i])
			write_byte(0) // bounce
			write_byte(get_pcvar_num(cvar_global_gib_time)) // life
			message_end()
			for(x = 1;x <= 2 ;x++){
				message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
				write_byte(TE_MODEL)
				write_coord(idorigin[0])
				write_coord(idorigin[1])
				write_coord(idorigin[2])
				write_coord(random_num(-150,150))
				write_coord(random_num(-150,150))
				write_coord(random_num(150,350))
				write_angle(random_num(0,360))
				write_short(mdl_gib_list[1][i])
				write_byte(0) // bounce
				write_byte(get_pcvar_num(cvar_global_gib_time)) // life
				message_end()

				message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
				write_byte(TE_MODEL)
				write_coord(idorigin[0])
				write_coord(idorigin[1])
				write_coord(idorigin[2])
				write_coord(random_num(-150,150))
				write_coord(random_num(-150,150))
				write_coord(random_num(150,350))
				write_angle(random_num(0,360))
				write_short(mdl_gib_list[2][i])
				write_byte(0) // bounce
				write_byte(get_pcvar_num(cvar_global_gib_time)) // life
				message_end()

				message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
				write_byte(TE_MODEL)
				write_coord(idorigin[0])
				write_coord(idorigin[1])
				write_coord(idorigin[2])
				write_coord(random_num(-150,150))
				write_coord(random_num(-150,150))
				write_coord(random_num(150,350))
				write_angle(random_num(0,360))
				write_short(mdl_gib_list[3][i])
				write_byte(0) // bounce
				write_byte(get_pcvar_num(cvar_global_gib_time)) // life
				message_end()

				message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
				write_byte(TE_MODEL)
				write_coord(idorigin[0])
				write_coord(idorigin[1])
				write_coord(idorigin[2])
				write_coord(random_num(-150,150))
				write_coord(random_num(-150,150))
				write_coord(random_num(150,350))
				write_angle(random_num(0,360))
				write_short(mdl_gib_list[4][i])
				write_byte(0) // bounce
				write_byte(get_pcvar_num(cvar_global_gib_time)) // life
				message_end()
			}
			return;
		}
	}
	#endif
	for(i = 0;i <= get_pcvar_num(cvar_global_gib_amount)-1;i++){
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_MODEL)
		write_coord(idorigin[0])
		write_coord(idorigin[1])
		write_coord(idorigin[2])
		write_coord(random_num(-150,150))
		write_coord(random_num(-150,150))
		write_coord(random_num(150,350))
		write_angle(random_num(0,360))
		write_short(mdl_gib_player1)
		write_byte(0) // bounce
		write_byte(get_pcvar_num(cvar_global_gib_time)) // life
		message_end()
	}
	for(i = 0;i <= get_pcvar_num(cvar_global_gib_amount)-1;i++){
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_MODEL)
		write_coord(idorigin[0])
		write_coord(idorigin[1])
		write_coord(idorigin[2])
		write_coord(random_num(-150,150))
		write_coord(random_num(-150,150))
		write_coord(random_num(150,350))
		write_angle(random_num(0,360))
		write_short(mdl_gib_player2)
		write_byte(0) // bounce
		write_byte(get_pcvar_num(cvar_global_gib_time)) // life
		message_end()
	}
	for(i = 0;i <= get_pcvar_num(cvar_global_gib_amount)-1;i++){
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_MODEL)
		write_coord(idorigin[0])
		write_coord(idorigin[1])
		write_coord(idorigin[2])
		write_coord(random_num(-150,150))
		write_coord(random_num(-150,150))
		write_coord(random_num(150,350))
		write_angle(random_num(0,360))
		write_short(mdl_gib_player3)
		write_byte(0) // bounce
		write_byte(get_pcvar_num(cvar_global_gib_time)) // life
		message_end()
	}
	for(i = 0;i <= get_pcvar_num(cvar_global_gib_amount)-1;i++){
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_MODEL)
		write_coord(idorigin[0])
		write_coord(idorigin[1])
		write_coord(idorigin[2])
		write_coord(random_num(-150,150))
		write_coord(random_num(-150,150))
		write_coord(random_num(150,350))
		write_angle(random_num(0,360))
		write_short(mdl_gib_player4)
		write_byte(0) // bounce
		write_byte(get_pcvar_num(cvar_global_gib_time)) // life
		message_end()
	}
	for(i = 0;i <= get_pcvar_num(cvar_global_gib_amount)-1;i++){
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_MODEL)
		write_coord(idorigin[0])
		write_coord(idorigin[1])
		write_coord(idorigin[2])
		write_coord(random_num(-150,150))
		write_coord(random_num(-150,150))
		write_coord(random_num(150,350))
		write_angle(random_num(0,360))
		write_short(mdl_gib_player5)
		write_byte(0) // bounce
		write_byte(get_pcvar_num(cvar_global_gib_time)) // life
		message_end()
	}
	for(i = 0;i <= get_pcvar_num(cvar_global_gib_amount)-1;i++){
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_MODEL)
		write_coord(idorigin[0])
		write_coord(idorigin[1])
		write_coord(idorigin[2])
		write_coord(random_num(-150,150))
		write_coord(random_num(-150,150))
		write_coord(random_num(150,350))
		write_angle(random_num(0,360))
		write_short(mdl_gib_player6)
		write_byte(0) // bounce
		write_byte(get_pcvar_num(cvar_global_gib_time)) // life
		message_end()
	}
	FX_Blood(id, 3)//max
}
stock FX_Blood(id, level){
	if(level > 3 || level < 1) return;
	new origin[3], Float:forigin[3]
	pev(id, pev_origin, forigin)
	FVecIVec(forigin, origin)
	new x,y,z
	for(new i = 0; i <= level-1; i++) {
		x = random_num(-10,10)
		y = random_num(-10,10)
		z = random_num(0,10)
		for(new j = 0; j < 3; j++) {
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(TE_BLOODSPRITE)
			write_coord(origin[0]+(x*j))
			write_coord(origin[1]+(y*j))
			write_coord(origin[2]+(z*j))
			write_short(spr_blood_spray)
			write_short(spr_blood_drop)
			write_byte(229) // color index
			write_byte(15) // size
			message_end()
		}
	}
}
stock FX_BloodDecal(id){
	new Float:origin[3]
	pev(id, pev_origin, origin)
	if (pev(id, pev_bInDuck))
		origin[2] -= 18.0
	else
		origin[2] -= 36.0
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_WORLDDECAL)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	write_byte(dcl_blood[random_num(0, sizeof dcl_blood - 1)])
	message_end()
}
stock FX_ExpDecal(Float:origin[3]){
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_WORLDDECAL)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	write_byte(dcl_exp[random_num(0, sizeof dcl_exp - 1)])
	message_end()
}
stock FX_Demolish(build){
	if(!pev_valid(build)) return;
	new Float:forigin[3],iorigin[3],i
	pev(build, pev_origin, forigin)
	FVecIVec(forigin,iorigin)

	for(i = 0;i <= get_pcvar_num(cvar_global_gib_amount)-1;i++){
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_MODEL)
		write_coord(iorigin[0])
		write_coord(iorigin[1])
		write_coord(iorigin[2])
		write_coord(random_num(-150,150))
		write_coord(random_num(-150,150))
		write_coord(random_num(150,350))
		write_angle(random_num(0,360))
		write_short(mdl_gib_build1)
		write_byte(0) // bounce
		write_byte(get_pcvar_num(cvar_global_gib_time)) // life
		message_end()
	}
	for(i = 0;i <= get_pcvar_num(cvar_global_gib_amount)-1;i++){
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_MODEL)
		write_coord(iorigin[0])
		write_coord(iorigin[1])
		write_coord(iorigin[2])
		write_coord(random_num(-150,150))
		write_coord(random_num(-150,150))
		write_coord(random_num(150,350))
		write_angle(random_num(0,360))
		write_short(mdl_gib_build2)
		write_byte(0) // bounce
		write_byte(get_pcvar_num(cvar_global_gib_time)) // life
		message_end()
	}
	for(i = 0;i <= get_pcvar_num(cvar_global_gib_amount)-1;i++){
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_MODEL)
		write_coord(iorigin[0])
		write_coord(iorigin[1])
		write_coord(iorigin[2])
		write_coord(random_num(-150,150))
		write_coord(random_num(-150,150))
		write_coord(random_num(150,350))
		write_angle(random_num(0,360))
		write_short(mdl_gib_build3)
		write_byte(0) // bounce
		write_byte(get_pcvar_num(cvar_global_gib_time)) // life
		message_end()
	}
	for(i = 0;i <= get_pcvar_num(cvar_global_gib_amount)-1;i++){
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(TE_MODEL)
		write_coord(iorigin[0])
		write_coord(iorigin[1])
		write_coord(iorigin[2])
		write_coord(random_num(-150,150))
		write_coord(random_num(-150,150))
		write_coord(random_num(150,350))
		write_angle(random_num(0,360))
		write_short(mdl_gib_build4)
		write_byte(0) // bounce
		write_byte(get_pcvar_num(cvar_global_gib_time)) // life
		message_end()
	}
}
stock FX_Trace(const Float:idorigin[3],const Float:targetorigin[3]){
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
stock FX_ColoredTrace(id, target){
	if(!pev_valid(id) || !pev_valid(target)) return;
	new Float:idfloat[3]
	new Float:targetfloat[3]
	new Float:velfloat[3]
	pev(id, pev_origin, idfloat)
	pev(target, pev_origin, targetfloat)
	get_speed_vector(idfloat, targetfloat, 1000.0, velfloat)
	new id[3], vel[3]
	FVecIVec(idfloat,id)
	FVecIVec(velfloat,vel)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_USERTRACER)
	write_coord(id[0])
	write_coord(id[1])
	write_coord(id[2])
	write_coord(vel[0])
	write_coord(vel[1])
	write_coord(vel[2])
	write_byte(get_pcvar_num(cvar_global_crit_tracetime))
	write_byte(get_pcvar_num(cvar_global_crit_tracecolor))
	write_byte(get_pcvar_num(cvar_global_crit_tracelen))
	message_end()
}
stock FX_ColoredTrace_point(const Float:idorigin[3],const Float:targetorigin[3]){
	new Float:velfloat[3]
	get_speed_vector(idorigin, targetorigin, 1000.0, velfloat)
	new id[3], vel[3]
	FVecIVec(idorigin,id)
	FVecIVec(velfloat,vel)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_USERTRACER)
	write_coord(id[0])
	write_coord(id[1])
	write_coord(id[2])
	write_coord(vel[0])
	write_coord(vel[1])
	write_coord(vel[2])
	write_byte(get_pcvar_num(cvar_global_crit_tracetime))
	write_byte(get_pcvar_num(cvar_global_crit_tracecolor))
	write_byte(get_pcvar_num(cvar_global_crit_tracelen))
	message_end()
}
stock FX_UpdateClip(id, wpnid, ammo){
	if(!is_user_alive(id)) return;
	message_begin( MSG_ONE, g_msgCurWeapon, _, id);
	write_byte(1);
	write_byte(wpnid);
	write_byte(max( min( ammo, 254 ), 0 ));
	message_end()
}
public FX_Flare(parm[]){
	new flare = parm[0]
	new time = parm[1]
	remove_task(flare+TASK_FLARE_THINK, 0)
	if (!pev_valid(flare))
		return;
	if (time <= 0){
		new glow = pev(flare, FLARE_GLOW)
		if(pev_valid(glow))
			engfunc(EngFunc_RemoveEntity, glow)
		engfunc(EngFunc_RemoveEntity, flare)
		return;
	}
	new Float:origin[3],bool:stopped = false
	pev(flare, pev_velocity, origin)
	if(origin[0] == 0.0 && origin[1] == 0.0 && origin[2] == 0.0)
		stopped = true
	pev(flare, pev_origin, origin)
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_DLIGHT)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	write_byte(get_pcvar_num(cvar_wpn_rpg_flare_size))
	write_byte(255)
	write_byte(255)
	write_byte(255)

	if(stopped)
	write_byte(11)
	else
	write_byte(2)

	write_byte((time < 2) ? 3 : 0)
	message_end()

	new id = -1
	new enemy = pev(flare, pev_owner)
	while((id = engfunc(EngFunc_FindEntityInSphere, id, origin, float(get_pcvar_num(cvar_wpn_rpg_radius)) ))){
		if(!(0 < id <= global_get(glb_maxClients)) || g_round != round_zombie)
			continue
		if(!is_user_alive(id))
			continue
		if(get_user_team(id) == get_user_team(enemy))
			continue
		if(giszm[id])
			gflame[id] = 50
		else
		gflame[id] = 10
		gflamer[id] = enemy
	}
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_SPARKS)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	message_end()

	if(stopped){
		time --
		parm[1] = time
		set_task(1.0, "FX_Flare", flare+TASK_FLARE_THINK, parm, 2)
	} else {
	set_task(0.1, "FX_Flare", flare+TASK_FLARE_THINK, parm, 2)
	}
}
public fw_blood(id){
	if(gdisguising[id] && giszm[id]){
		SetHamReturnInteger(-1)
		return HAM_SUPERCEDE
	}
	return HAM_IGNORED
}
public check_end(){
	remove_task(TASK_CHECK_END, 0)
	set_task(CHECK_END, "check_end", TASK_CHECK_END)
	if(g_round == round_end) return;
	new hm = get_humans_num()
	new zm = get_zombies_num()
	new pl = get_players_num()
	switch(g_gamemode){
		case mode_normal:{
			if(g_roundtime <= 0){
				end_round(win_human)
				return;
			}
			if(g_round == round_zombie){
				if(hm > 0 && zm < 1){
					end_round(win_human)
					return;
				} else if(hm < 1 && zm > 0){
					end_round(win_zombie)
					return;
				} else if(hm == 0 && zm == 0){
					end_round(win_no)
					return;
				}
			}
			if(hm + zm <= 1 && pl > 1)
				end_round(win_no)
		}
		case mode_capture:{
			if (g_cp_local >= 100)
				end_round(win_human)
			else if (g_roundtime <= 0)
				end_round(win_zombie)
		}
	}
}
public event_weapon(id){
	if (get_user_team(id) == 0 || get_user_team(id) == 3 || !is_user_alive(id)) return;
	new clip,ammo,wep = get_user_weapon(id,clip,ammo)
	if(giszm[id] && wep != CSW_KNIFE){
		drop_weapons(id,1)
		drop_weapons(id,2)
		drop_weapons(id,5)
		new parm[1]
		parm[0] = id
		set_task(0.1,"ckrun_strip_user_weapons",0,parm,1)
		if(gzombie[id] == 5)
			set_pev(id, pev_viewmodel2, mdl_v_knife_stab)
	}
	switch(wep) {
		case CSW_FLASHBANG, CSW_SMOKEGRENADE: ckrun_fakedamage(id, id, CKW_BACKSTAB, 99999, CKD_PUNCH)
		case CSW_M3,CSW_XM1014,CSW_M249,CSW_AWP: return;
		case CSW_KNIFE:{
			if(gzombie[id] == 5 && giszm[id])
				set_pev(id, pev_viewmodel2, mdl_v_knife_stab)
		}
		default:{
			if(clip == glastammo[id] - 1 && glastwpn[id] == wep){
				if(!gwpntraced[id]){
					new Float:idorigin[3],Float:hitorigin[3]
					pev(id, pev_origin, idorigin)
					idorigin[2] += 13.5
					if(pev(id, pev_flags) & FL_DUCKING)
						idorigin[2] -= 8.0
					new lasthit[3]
					get_user_origin(id,lasthit,4)
					IVecFVec(lasthit,hitorigin)
					if(!gcritical_on[id])
						FX_Trace(idorigin, hitorigin)
					else
						FX_ColoredTrace_point(idorigin, hitorigin)
					gwpntraced[id] = true
				} else if(gwpntraced[id]){
					gwpntraced[id] = false
				}
			}
		}
	}
	if(glastwpn[id] != wep || clip < glastammo[id] )
		ckrun_showhud_status(id)
	glastammo[id] = clip
	glastwpn[id] = wep
}
public fw_wpnfire(wpn){
	new id = pev(wpn, pev_owner)
	if(!is_user_alive(id))
		return HAM_IGNORED
	new clip,ammo,wpnid = get_user_weapon(id,clip,ammo)
	new auto = ckrun_is_weapon_auto(wpnid)
	if(auto == -1 || clip == 0)
		return HAM_IGNORED
	return HAM_IGNORED
}
public funcCritical(taskid) {
	static id
	if(taskid > g_maxplayers)
		id = taskid - TASK_CRITICAL
	else
		id = taskid
	if (!(1 <= id <= g_maxplayers)) return;
	if (!is_user_alive(id)) return;
	if(gcritical_on[id]){
		gcritical_on[id] = false
		remove_task(id+TASK_CRITICAL)
		funcCritical(id)
		return;
	}
	new critical = random_num(1,100)
	if(critical <= gcritical[id]){
		gcritical_on[id] = true
		remove_task(id+TASK_CRITICAL)
		set_task(2.0, "funcCritical", id+TASK_CRITICAL)
	} else {
		gcritical_on[id] = false
		remove_task(id+TASK_CRITICAL)
		set_task(10.0, "funcCritical", id+TASK_CRITICAL)
	}
}

public show_menu_main(id){
	static menu[256], len
	len = 0
	len += formatex(menu[len], sizeof menu - len - 1, "\y%L^n^n", id, "MENU_MAIN")
	len += formatex(menu[len], sizeof menu - len - 1, "\r1.\w %L^n", id, "MENU_MAIN_ZOMBIE")//僵尸类型
	len += formatex(menu[len], sizeof menu - len - 1, "\r2.\w %L^n", id, "MENU_MAIN_HUMAN")//人类兵种
	len += formatex(menu[len], sizeof menu - len - 1, "\r3.\w %L^n", id, "MENU_MAIN_WEAPON")//选择武器
	if(g_gamemode == mode_normal)
		len += formatex(menu[len], sizeof menu - len - 1, "\r4.\w %L^n", id, "MENU_MAIN_TELE")//传送
	else
		len += formatex(menu[len], sizeof menu - len - 1, "\r4.\w %L^n", id, "MENU_MAIN_TEAM")//选队
	len += formatex(menu[len], sizeof menu - len - 1, "\r5.\w %L^n", id, "MENU_MAIN_HELP")//帮助
	len += formatex(menu[len], sizeof menu - len - 1, "\r6.\w %L^n", id, "MENU_MAIN_STATS")//帮助
	len += formatex(menu[len], sizeof menu - len - 1, "\r7.\w %L^n", id, "MENU_MAIN_MODEL")//选择模型
	len += formatex(menu[len], sizeof menu - len - 1, "\r8.\w %L^n", id, "MENU_MAIN_ACH")//成就统计
	len += formatex(menu[len], sizeof menu - len - 1, "^n^n\r0.\w %L", id, "EXIT")
	show_menu(id, KEYSMENU, menu, -1, "Main Menu")
	return PLUGIN_HANDLED;
}

public menu_main(id, key){
	switch(key){
		case 0:show_menu_zombie(id)
		case 1:show_menu_human(id)
		case 2:show_menu_weapon(id)
		case 3:{
			if(g_gamemode == mode_normal) clcmd_ztele(id)
			else show_menu_team(id)
		}
		case 4:	show_menu_help(id)
		case 5:	zmstats(id)
		case 6:	show_menu_model(id)
		case 7:	show_menu_achievement(id)
		case 9: return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}

public show_menu_team(id){
	static menu[256], len
	len = 0
	len += formatex(menu[len], sizeof menu - len - 1, "\y%L^n^n", id, "MENU_TEAM")
	len += formatex(menu[len], sizeof menu - len - 1, "\r1.\w %L^n", id, "MENU_TEAM_ZOMBIE")//加入僵尸
	len += formatex(menu[len], sizeof menu - len - 1, "\r2.\w %L^n", id, "MENU_TEAM_HUMAN")//加入人类
	len += formatex(menu[len], sizeof menu - len - 1, "\r3.\w %L^n", id, "MENU_TEAM_SPECTATOR")//加入观察者
	len += formatex(menu[len], sizeof menu - len - 1, "^n^n\r0.\w %L", id, "EXIT")
	show_menu(id, KEYSMENU, menu, -1, "Team Menu")
	return PLUGIN_HANDLED;
}

public menu_team(id, key){
	switch(key){
		case 0:{
			if (!giszm[id]){
				client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_MENU_TEAM_SUCCESS", id, "NAME_ZOMBIE")
				if(is_user_alive(id)) dllfunc(DLLFunc_ClientKill, id)
				giszm[id] = true
				fm_set_user_team(id, CS_TEAM_CT)
				remove_task(id+TASK_RESPAWN, 0)
				set_task(float(get_pcvar_num(cvar_global_respawn)), "respawn", id+TASK_RESPAWN)
			} else if (fm_get_user_team(id) == CS_TEAM_SPECTATOR || fm_get_user_team(id) == CS_TEAM_UNASSIGNED){
				client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_MENU_TEAM_SUCCESS", id, "NAME_ZOMBIE")
				giszm[id] = true
				fm_set_user_team(id, CS_TEAM_CT)
				remove_task(id+TASK_RESPAWN, 0)
				set_task(float(get_pcvar_num(cvar_global_respawn)), "respawn", id+TASK_RESPAWN)
			} else {
				client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_MENU_TEAM_ALREADY", id, "NAME_ZOMBIE")
			}
		}
		case 1:{
			if (giszm[id]){
				client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_MENU_TEAM_SUCCESS", id, "NAME_HUMAN")
				if(is_user_alive(id)) dllfunc(DLLFunc_ClientKill, id)
				giszm[id] = false
				fm_set_user_team(id, CS_TEAM_T)
				remove_task(id+TASK_RESPAWN, 0)
				set_task(float(get_pcvar_num(cvar_global_respawn)), "respawn", id+TASK_RESPAWN)
			} else if (fm_get_user_team(id) == CS_TEAM_SPECTATOR || fm_get_user_team(id) == CS_TEAM_UNASSIGNED){
				client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_MENU_TEAM_SUCCESS", id, "NAME_HUMAN")
				giszm[id] = false
				fm_set_user_team(id, CS_TEAM_T)
				remove_task(id+TASK_RESPAWN, 0)
				set_task(float(get_pcvar_num(cvar_global_respawn)), "respawn", id+TASK_RESPAWN)
			} else {
				client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_MENU_TEAM_ALREADY", id, "NAME_HUMAN")
			}
		}
		case 2:{
			if(fm_get_user_team(id) == CS_TEAM_SPECTATOR){
				client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_MENU_TEAM_ALREADY", id, "NAME_SPECTATOR")
			} else {
				client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_MENU_TEAM_SUCCESS", id, "NAME_SPECTATOR")
				if(is_user_alive(id)) dllfunc(DLLFunc_ClientKill, id)
				fm_set_user_team(id, CS_TEAM_SPECTATOR)
				giszm[id] = false
				remove_task(id+TASK_RESPAWN, 0)
			}
		}
		case 9: return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}

public show_menu_zombie(id) {
	static menu[768], len
	new class[16], nrclass[16]
	ckrun_get_user_classname(id, 1, class, sizeof class - 1)
	ckrun_get_user_classname_willbe(id, 1, nrclass, sizeof nrclass - 1)
	len = 0
	len += formatex(menu[len], sizeof menu - len - 1, "\y%L^n\w%L^n%L^n^n", id, "MENU_ZOMBIE", id, "MENU_ZOMBIE_NOW", class, id, "MENU_RESPAWN_WILLBE", nrclass)
	len += formatex(menu[len], sizeof menu - len - 1, "\r1.\w %L^n", id, "MENU_ZOMBIE_FAST", get_pcvar_num(cvar_zm_fast_hp), get_pcvar_num(cvar_zm_fast_speed), get_pcvar_num(cvar_zm_fast_kb), get_pcvar_num(cvar_zm_fast_jump))//闪电
	len += formatex(menu[len], sizeof menu - len - 1, "\r2.\w %L^n", id, "MENU_ZOMBIE_GRAVITY", get_pcvar_num(cvar_zm_gravity_hp), get_pcvar_num(cvar_zm_gravity_speed), get_pcvar_num(cvar_zm_gravity_kb), get_pcvar_num(cvar_zm_gravity_jump))
	len += formatex(menu[len], sizeof menu - len - 1, "\r3.\w %L^n", id, "MENU_ZOMBIE_CLASSIC", get_pcvar_num(cvar_zm_classic_hp), get_pcvar_num(cvar_zm_classic_speed), get_pcvar_num(cvar_zm_classic_kb), get_pcvar_num(cvar_zm_classic_jump))
	len += formatex(menu[len], sizeof menu - len - 1, "\r4.\w %L^n", id, "MENU_ZOMBIE_JUMP", get_pcvar_num(cvar_zm_jump_hp), get_pcvar_num(cvar_zm_jump_speed), get_pcvar_num(cvar_zm_jump_kb), get_pcvar_num(cvar_zm_jump_jump))
	len += formatex(menu[len], sizeof menu - len - 1, "\r5.\w %L^n", id, "MENU_ZOMBIE_VIS", get_pcvar_num(cvar_zm_invis_hp), get_pcvar_num(cvar_zm_invis_speed), get_pcvar_num(cvar_zm_invis_kb), get_pcvar_num(cvar_zm_invis_jump))
	len += formatex(menu[len], sizeof menu - len - 1, "\r6.\w %L^n", id, "MENU_BACK")
	len += formatex(menu[len], sizeof menu - len - 1, "^n^n\r0.\w %L", id, "EXIT")
	show_menu(id, KEYSMENU, menu, -1, "Zombie Menu")
	return PLUGIN_HANDLED;
}
public menu_zombie(id, key){
	switch(key){
		case 0,1,2,3,4:{
			gwillbezombie[id] = key + 1
			new class[16]
			ckrun_get_user_classname_willbe(id, 1, class, 15)
			client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_WILL_BE", class)
			show_menu_zombie(id)
		}
		case 5: show_menu_main(id)
		case 9: return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}

public show_menu_human(id) {
	static menu[768], len
	new class[16],nrclass[16]
	ckrun_get_user_classname(id,0, class, sizeof class -1)
	ckrun_get_user_classname_willbe(id, 0, nrclass, sizeof nrclass -1)
	len = 0
	len += formatex(menu[len], sizeof menu - len - 1, "\y%L^n\w%L^n%L^n^n", id, "MENU_HUMAN", id, "MENU_HUMAN_NOW", class, id, "MENU_RESPAWN_WILLBE", nrclass)
	len += formatex(menu[len], sizeof menu - len - 1, "\r1.\w %L^n", id, "MENU_HUMAN_SCOUT", get_pcvar_num(cvar_hm_scout_hp), get_pcvar_num(cvar_hm_scout_speed))
	len += formatex(menu[len], sizeof menu - len - 1, "\r2.\w %L^n", id, "MENU_HUMAN_HEAVY", get_pcvar_num(cvar_hm_heavy_hp), get_pcvar_num(cvar_hm_heavy_speed))
	len += formatex(menu[len], sizeof menu - len - 1, "\r3.\w %L^n", id, "MENU_HUMAN_RPG", get_pcvar_num(cvar_hm_rpg_hp), get_pcvar_num(cvar_hm_rpg_speed))
	len += formatex(menu[len], sizeof menu - len - 1, "\r4.\w %L^n", id, "MENU_HUMAN_SNIPE", get_pcvar_num(cvar_hm_snipe_hp), get_pcvar_num(cvar_hm_snipe_speed))
	len += formatex(menu[len], sizeof menu - len - 1, "\r5.\w %L^n", id, "MENU_HUMAN_LOG", get_pcvar_num(cvar_hm_log_hp), get_pcvar_num(cvar_hm_log_speed))
	len += formatex(menu[len], sizeof menu - len - 1, "\r6.\w %L^n", id, "MENU_HUMAN_ENG", get_pcvar_num(cvar_hm_eng_hp), get_pcvar_num(cvar_hm_eng_speed))
	len += formatex(menu[len], sizeof menu - len - 1, "\r7.\w %L^n", id, "MENU_BACK")
	len += formatex(menu[len], sizeof menu - len - 1, "^n^n\r0.\w %L", id, "EXIT")
	show_menu(id, KEYSMENU, menu, -1, "Human Menu")
	return PLUGIN_HANDLED;
}
public menu_human(id, key){
	switch(key){
		case 0,1,2,3,4,5:{
			gwillbehuman[id] = key + 1
			new class[16]
			ckrun_get_user_classname_willbe(id, 0, class, 15)
			client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_WILL_BE", class)
			show_menu_human(id)
		}
		case 6: show_menu_main(id)
		case 9: return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}

public show_menu_weapon(id){
	static menu[256], len
	len = 0
	len += formatex(menu[len], sizeof menu - len - 1, "\y%L^n^n", id, "MENU_WEAPON")
	if(giszm[id] || !is_user_alive(id) || gprimaryed[id]) len += formatex(menu[len], sizeof menu - len - 1, "\r1.\d %L^n", id, "MENU_WEAPON_PRIMARY")
	else len += formatex(menu[len], sizeof menu - len - 1, "\r1.\w %L^n", id, "MENU_WEAPON_PRIMARY")
	if(giszm[id] || !is_user_alive(id) || gsecondaryed[id]) len += formatex(menu[len], sizeof menu - len - 1, "\r2.\d %L^n", id, "MENU_WEAPON_SECONDARY")
	else len += formatex(menu[len], sizeof menu - len - 1, "\r2.\w %L^n", id, "MENU_WEAPON_SECONDARY")
	len += formatex(menu[len], sizeof menu - len - 1, "\r3.\w %L^n", id, "MENU_WEAPON_KNIFE")
	len += formatex(menu[len], sizeof menu - len - 1, "\r4.\w %L^n", id, "MENU_BACK")
	len += formatex(menu[len], sizeof menu - len - 1, "^n^n\r0.\w %L", id, "EXIT")
	show_menu(id, KEYSMENU, menu, -1, "Weapon Menu")
	return PLUGIN_HANDLED;
}
public menu_weapon(id, key){
	switch(key){
		case 0: {
			if(giszm[id] || !is_user_alive(id)){
				show_menu_weapon(id)
				return PLUGIN_HANDLED
			}
			if(gprimaryed[id]){
				show_menu_weapon(id)
				return PLUGIN_HANDLED
			}
			show_menu_primary(id)
		}
		case 1: {
			if(giszm[id] || !is_user_alive(id)){
				show_menu_weapon(id)
				return PLUGIN_HANDLED
			}
			if(gsecondaryed[id]){
				show_menu_weapon(id)
				return PLUGIN_HANDLED
			}
			show_menu_secondary(id)
		}
		case 2: show_menu_knife(id)
		case 3: show_menu_main(id)
		case 9: return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}
public show_menu_knife(id){
	static menu[512], len
	len = 0
	len += formatex(menu[len], sizeof menu - len - 1, "\y%L^n^n", id, "MENU_KNIFE")
	new i, name[32], need[128]
	for (i = g_menu_data[id][2]; i < min(g_menu_data[id][2]+7, MAX_KNIFEID); i++){
		format(name, sizeof name - 1, "%L", id, g_knife_formatname[i])
		format(need, sizeof need - 1, "%L", id, g_knife_needname[i])
		len += formatex(menu[len], sizeof menu - len - 1, "\r%d.\w %s%s^n", i-g_menu_data[id][2]+1, name, need)
	}
	len += formatex(menu[len], sizeof menu - len - 1, "^n^n\r9.\w %L/%L^n^n\r0.\w %L", id, "MORE", id, "BACK", id, "EXIT")

	show_menu(id, KEYSMENU, menu, -1, "Knife Menu")
	return PLUGIN_HANDLED;
}
public menu_knife(id, key){
	if (key >= 8 || g_menu_data[id][2]+key >= MAX_KNIFEID){
		switch (key)
		{
			case 8:{
				if (g_menu_data[id][2]+7 < MAX_KNIFEID)
					g_menu_data[id][2] += 7
				else
					g_menu_data[id][2] = 0
			}
			case 9:	return PLUGIN_HANDLED;
		}
		show_menu_knife(id)
		return PLUGIN_HANDLED;
	}

	g_menu_data[id][4] = g_menu_data[id][2]+key

	select_menu_knife(id, g_menu_data[id][4])
	
	return PLUGIN_HANDLED;
}
public select_menu_knife(id, knife){
	switch(knife){
		case knife_normal: {
			gknife[id] = knife_normal
			client_print_colored(id, "^x04%L^x01%L%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_KNIFE_SELECTED", id, g_knife_formatname[knife])
			if(get_user_weapon(id) == CSW_KNIFE){
				set_pev(id, pev_viewmodel2, mdl_v_knife)
				set_pev(id, pev_weaponmodel2, mdl_p_knife)
			}
		}
		case knife_hammer: {
			if(!giszm[id] && ghuman[id] == human_eng){
				gknife[id] = knife_hammer
				gknifesave_hm[id] = knife_hammer
				client_print_colored(id, "^x04%L^x01%L%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_KNIFE_SELECTED", id, g_knife_formatname[knife])
				if(get_user_weapon(id) == CSW_KNIFE){
					set_pev(id, pev_viewmodel2, mdl_v_hammer)
					set_pev(id, pev_weaponmodel2, mdl_p_hammer)
				}
			}
		}
		case knife_moonstar: {
			if(giszm[id] && gzombie[id] == zombie_fast && g_ach_fast[id][ach_fast_14]){
				gknife[id] = knife_moonstar
				gknifesave_zm[id] = knife_moonstar
				client_print_colored(id, "^x04%L^x01%L%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_KNIFE_SELECTED", id, g_knife_formatname[knife])
				if(get_user_weapon(id) == CSW_KNIFE){
					set_pev(id, pev_viewmodel2, mdl_v_moonstar)
					set_pev(id, pev_weaponmodel2, mdl_p_moonstar)
				}
			}
		}
	}
	if(giszm[id]){
		switch(gzombie[id]){
			case zombie_fast:{
				if(gknife[id] == knife_moonstar){
					set_pev(id, pev_viewmodel2, mdl_v_moonstar)
					set_pev(id, pev_weaponmodel2, mdl_p_moonstar)
				}
			}
			case zombie_invis:{
				if(ginvisible[id])
					set_pev(id, pev_viewmodel2, mdl_v_knife_invis)
				else
					set_pev(id, pev_weaponmodel2, mdl_v_knife_stab)
			}
			default : {
				set_pev(id, pev_viewmodel2, mdl_v_knife)
				set_pev(id, pev_weaponmodel2, mdl_p_knife)
			}
		}
	}
	show_menu_knife(id)
}
public show_menu_primary(id){
	if (giszm[id] || !is_user_alive(id) || gprimaryed[id])
		return PLUGIN_HANDLED;
	static menu[512], len
	len = 0
	len += formatex(menu[len], sizeof menu - len - 1, "\y%L^n^n", id, "MENU_PRIMARY")
	new i, name[32]
	for (i = g_menu_data[id][2]; i < min(g_menu_data[id][2]+7, ckrun_get_primary_maxid(id)); i++){
		ckrun_get_primary_formatname(id, i, name, 31)
		len += formatex(menu[len], sizeof menu - len - 1, "\r%d.\w %s^n", i-g_menu_data[id][2]+1, name)
	}
	len += formatex(menu[len], sizeof menu - len - 1, "^n^n\r9.\w %L/%L^n^n\r0.\w %L", id, "MORE", id, "BACK", id, "EXIT")

	show_menu(id, KEYSMENU, menu, -1, "Primary Menu")
	return PLUGIN_HANDLED;
}

public menu_primary(id, key){
	if (giszm[id] || !is_user_alive(id) || gprimaryed[id])
		return PLUGIN_HANDLED;

	if (key >= 8 || g_menu_data[id][2]+key >= ckrun_get_primary_maxid(id)){
		switch (key)
		{
			case 8:{
				if (g_menu_data[id][2]+7 < ckrun_get_primary_maxid(id))
					g_menu_data[id][2] += 7
				else
					g_menu_data[id][2] = 0
			}
			case 9:	return PLUGIN_HANDLED;
		}
		show_menu_primary(id)
		return PLUGIN_HANDLED;
	}

	g_menu_data[id][4] = g_menu_data[id][2]+key

	select_menu_primary(id, g_menu_data[id][4])
	
	return PLUGIN_HANDLED;
}
public select_menu_primary(id, wpn){
	if (giszm[id] || !is_user_alive(id) || gprimaryed[id]) return;
	static classname[32]
	ckrun_get_primary_classname(id, wpn, classname, 31)
	fm_give_item(id, classname)
	gprimaryed[id] = true
	if(!gsecondaryed[id])
		show_menu_secondary(id)
}
public show_menu_secondary(id){
	if (giszm[id] || !is_user_alive(id) || gsecondaryed[id])
		return PLUGIN_HANDLED;
	static menu[512], len
	len = 0
	len += formatex(menu[len], sizeof menu - len - 1, "\y%L^n^n", id, "MENU_SECONDARY")
	new i, name[32]
	for (i = g_menu_data[id][2]; i < min(g_menu_data[id][2]+7, ckrun_get_secondary_maxid(id)); i++){
		ckrun_get_secondary_formatname(id, i, name, 31)
		len += formatex(menu[len], sizeof menu - len - 1, "\r%d.\w %s^n", i-g_menu_data[id][2]+1, name)
	}
	len += formatex(menu[len], sizeof menu - len - 1, "^n^n\r9.\w %L/%L^n^n\r0.\w %L", id, "MORE", id, "BACK", id, "EXIT")

	show_menu(id, KEYSMENU, menu, -1, "Secondary Menu")
	return PLUGIN_HANDLED;
}

public menu_secondary(id, key){
	if (giszm[id] || !is_user_alive(id) || gsecondaryed[id])
		return PLUGIN_HANDLED;

	if (key >= 8 || g_menu_data[id][2]+key >= ckrun_get_secondary_maxid(id)){
		switch (key)
		{
			case 8:{
				if (g_menu_data[id][2]+7 < ckrun_get_secondary_maxid(id))
					g_menu_data[id][2] += 7
				else
					g_menu_data[id][2] = 0
			}
			case 9:	return PLUGIN_HANDLED;
		}
		show_menu_secondary(id)
		return PLUGIN_HANDLED;
	}

	g_menu_data[id][4] = g_menu_data[id][2]+key

	select_menu_secondary(id, g_menu_data[id][4])
	
	return PLUGIN_HANDLED;
}
public select_menu_secondary(id, wpn){
	if (giszm[id] || !is_user_alive(id) || gsecondaryed[id]) return
	static classname[32]
	ckrun_get_secondary_classname(id, wpn, classname, 31)
	fm_give_item(id, classname)
	gsecondaryed[id] = true
	if(!gprimaryed[id])
		show_menu_primary(id)
}

public show_menu_help(id){
	new title[51];
	format(title, 50, "%L", id, "MENU_HELP");
	new menu = menu_create(title, "menu_help");
	new menuitem_1[16];
	format(menuitem_1, 15, "%L", id, "MENU_HELP_GAMEMODE");
	new menuitem_2[16];
	format(menuitem_2, 15, "%L", id, "MENU_HELP_HUMAN");
	new menuitem_3[16];
	format(menuitem_3, 15, "%L", id, "MENU_HELP_ZOMBIE");
	new menuitem_back[16];
	format(menuitem_back, 15, "%L", id, "MENU_BACK");
	menu_additem(menu, menuitem_1, "1", 0);
	menu_additem(menu, menuitem_2, "2", 0);
	menu_additem(menu, menuitem_3, "3", 0);
	menu_additem(menu, menuitem_back, "4", 0);
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}
public menu_help(id, menu, item){
	if(item == MENU_EXIT) {
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	new data[6], name[64]
	new access, callback
	menu_item_getinfo(menu, item, access, data, 5, name, 63, callback)
	new key = str_to_num(data)
	switch(key){
		case 1:	motd_help_gamemode(id)
		case 2:	motd_help_human(id)
		case 3:	motd_help_zombie(id)
		case 4:	show_menu_main(id)
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public motd_help_gamemode(id){
	static motd[4096], len
	len = 0
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_GAMEMODE_TITLE")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_GAMEMODE_NORMAL")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_GAMEMODE_NORMAL2")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_GAMEMODE_CP")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_GAMEMODE_CP2")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_GAMEMODE_CTF")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_GAMEMODE_CTF2")
	new temp[64]
	num_to_str(get_pcvar_num(cvar_wpn_craw_light), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$wpn_craw_light", temp)
	num_to_str(get_pcvar_num(cvar_wpn_craw_heavy), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$wpn_craw_heavy", temp)
	num_to_str(get_pcvar_num(cvar_global_tele), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$global_tele_times", temp )
	num_to_str(get_pcvar_num(cvar_global_tele_cd), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$global_tele_cd", temp )
	num_to_str(get_pcvar_num(cvar_global_respawn), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$global_respawn_time", temp )
	num_to_str(get_pcvar_num(cvar_cp_craw_light), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$wpn_craw_light", temp )
	num_to_str(get_pcvar_num(cvar_cp_craw_heavy), temp, sizeof temp - 1) 
	replace_all(motd, 4095, "$wpn_craw_heavy", temp )
	num_to_str(get_pcvar_num(cvar_cp_respawn), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$cp_respawn_time", temp )

	num_to_str( 10 , temp, sizeof temp - 1)
	replace_all(motd, 4095, "$ctf_flags_back", temp)//-_-
	num_to_str(get_pcvar_num(cvar_ctf_craw_light) , temp, sizeof temp - 1)
	replace_all(motd, 4095, "$ctf_craw_light", temp )
	num_to_str(get_pcvar_num(cvar_ctf_craw_heavy) , temp, sizeof temp - 1)
	replace_all(motd, 4095, "$ctf_craw_heavy", temp )

	num_to_str( 20 , temp, sizeof temp - 1)
	replace_all(motd, 4095, "$cp_cart_back", temp)//-_-
	num_to_str(get_pcvar_num(cvar_pl_craw_light) , temp, sizeof temp - 1)
	replace_all(motd, 4095, "$pl_craw_light", temp )
	num_to_str(get_pcvar_num(cvar_pl_craw_heavy) , temp, sizeof temp - 1)
	replace_all(motd, 4095, "$pl_craw_heavy", temp )
	num_to_str(get_pcvar_num(cvar_pl_respawn) , temp, sizeof temp - 1)
	replace_all(motd, 4095, "$pl_respawn_time", temp )
	show_motd(id, motd)
}
public motd_help_human(id){
	static motd[4096], len
	len = 0
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_HUMAN_TITLE")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_HUMAN_SCOUT")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_HUMAN_HEAVY")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_HUMAN_RPG")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_HUMAN_SNIPE")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_HUMAN_LOG")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_HUMAN_LOG2")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_HUMAN_ENG")

	new temp[64]
	num_to_str(get_pcvar_num(cvar_hm_scout_hp), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$human_scout_health", temp )
	num_to_str(get_pcvar_num(cvar_hm_scout_speed), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$human_scout_speed", temp )
	num_to_str(get_pcvar_num(cvar_hm_heavy_hp), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$human_heavy_health", temp )
	num_to_str(get_pcvar_num(cvar_hm_heavy_speed), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$human_heavy_speed", temp )
	num_to_str(get_pcvar_num(cvar_hm_rpg_hp), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$human_rpg_health", temp )
	num_to_str(get_pcvar_num(cvar_hm_rpg_speed), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$human_rpg_speed", temp )
	num_to_str(get_pcvar_num(cvar_hm_snipe_hp), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$human_snipe_health", temp )
	num_to_str(get_pcvar_num(cvar_hm_snipe_speed), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$human_snipe_speed", temp )
	num_to_str(get_pcvar_num(cvar_hm_log_hp), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$human_log_health", temp )
	num_to_str(get_pcvar_num(cvar_hm_log_speed), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$human_log_speed", temp )
	num_to_str(get_pcvar_num(cvar_hm_eng_hp), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$human_eng_health", temp )
	num_to_str(get_pcvar_num(cvar_hm_eng_speed), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$human_eng_speed", temp )

	num_to_str(get_pcvar_num(cvar_wpn_ammo_default), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$wpn_ammo_default", temp )
	num_to_str(get_pcvar_num(cvar_wpn_ammo_shotgun), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$wpn_ammo_shotgun", temp )
	num_to_str(get_pcvar_num(cvar_wpn_ammo_awp), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$wpn_ammo_awp", temp )
	num_to_str(get_pcvar_num(cvar_wpn_ammo_m249), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$wpn_ammo_m249", temp )
	num_to_str(get_pcvar_num(cvar_wpn_clip_rpg), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$wpn_clip_rpg", temp )
	num_to_str(get_pcvar_num(cvar_wpn_ammo_rpg), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$wpn_ammo_rpg", temp )

	num_to_str(get_pcvar_num(cvar_wpn_medic_maxhealth), temp, sizeof temp - 1)
	replace(motd, 4095, "$wpn_medic_maxhealth", temp )
	num_to_str(get_pcvar_num(cvar_wpn_awp_charge), temp, sizeof temp - 1)
	replace(motd, 4095, "$wpn_awp_charge", temp )
	show_motd(id, motd)
} 

public motd_help_zombie(id){
	static motd[4096], len
	len = 0
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_ZOMBIE_TITLE")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_ZOMBIE_FAST")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_ZOMBIE_GRAVITY")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_ZOMBIE_CLASSIC")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_ZOMBIE_JUMP")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_ZOMBIE_INVIS")

	new temp[64]
	num_to_str(get_pcvar_num(cvar_zm_fast_hp), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$zombie_fast_health", temp )
	num_to_str(get_pcvar_num(cvar_zm_fast_speed), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$zombie_fast_speed", temp )
	num_to_str(get_pcvar_num(cvar_zm_fast_jump), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$zombie_fast_jump", temp )
	num_to_str(get_pcvar_num(cvar_zm_fast_kb), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$zombie_fast_kb", temp )

	num_to_str(get_pcvar_num(cvar_zm_gravity_hp), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$zombie_gravity_health", temp )
	num_to_str(get_pcvar_num(cvar_zm_gravity_speed), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$zombie_gravity_speed", temp )
	num_to_str(get_pcvar_num(cvar_zm_gravity_jump), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$zombie_gravity_jump", temp )
	num_to_str(get_pcvar_num(cvar_zm_gravity_kb), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$zombie_gravity_kb", temp )

	num_to_str(get_pcvar_num(cvar_zm_classic_hp), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$zombie_classic_health", temp )
	num_to_str(get_pcvar_num(cvar_zm_classic_speed), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$zombie_classic_speed", temp )
	num_to_str(get_pcvar_num(cvar_zm_classic_jump), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$zombie_classic_jump", temp )
	num_to_str(get_pcvar_num(cvar_zm_classic_kb), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$zombie_classic_kb", temp )

	num_to_str(get_pcvar_num(cvar_zm_jump_hp), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$zombie_jump_health", temp )
	num_to_str(get_pcvar_num(cvar_zm_jump_speed), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$zombie_jump_speed", temp )
	num_to_str(get_pcvar_num(cvar_zm_jump_jump), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$zombie_jump_jump", temp )
	num_to_str(get_pcvar_num(cvar_zm_jump_kb), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$zombie_jump_kb", temp )

	num_to_str(get_pcvar_num(cvar_zm_invis_hp), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$zombie_invis_health", temp )
	num_to_str(get_pcvar_num(cvar_zm_invis_speed), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$zombie_invis_speed", temp )
	num_to_str(get_pcvar_num(cvar_zm_invis_jump), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$zombie_invis_jump", temp )
	num_to_str(get_pcvar_num(cvar_zm_invis_kb), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$zombie_invis_kb", temp )

	num_to_str(get_pcvar_num(cvar_skill_longjump_power), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$skill_longjump_power", temp )
	num_to_str(get_pcvar_num(cvar_skill_airblast_power), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$skill_airblast_power", temp )
	num_to_str(get_pcvar_num(cvar_skill_dodge_slowdown), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$skill_dodge_slowdown", temp )
	num_to_str(get_pcvar_num(cvar_skill_dodge_percent), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$skill_dodge_percent", temp )
	num_to_str(get_pcvar_num(cvar_skill_dodge_power), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$skill_dodge_power", temp )
	num_to_str(get_pcvar_num(cvar_skill_invisible_multifc), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$skill_invisible_multifc", temp )
	num_to_str(get_pcvar_num(cvar_skill_invisible_multidmg), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$skill_invisible_multidmg", temp )
	num_to_str(get_pcvar_num(cvar_skill_disguise_multidamage), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$skill_disguise_multidmg", temp )
	num_to_str(get_pcvar_num(cvar_skill_disguise_multiforce), temp, sizeof temp - 1)
	replace_all(motd, 4095, "$skill_disguise_multifc", temp )
	show_motd(id, motd)
}


public show_menu_itemmaker(id){
	if(!(get_user_flags(id) & ACCESS_ADMIN)) return PLUGIN_HANDLED;
	static menu[512], len
	len = 0
	len += formatex(menu[len], sizeof menu - len - 1, "\y%L^n^n", id, "MENU_ITEMMAKER")
	len += formatex(menu[len], sizeof menu - len - 1, "\r1.\w %L^n", id, "MENU_ITEMMAKER_HEALTHKIT", fm_get_entity_num("edit_healthkit"))
	len += formatex(menu[len], sizeof menu - len - 1, "\r2.\w %L^n", id, "MENU_ITEMMAKER_AMMOBOX", fm_get_entity_num("edit_ammobox"))
	len += formatex(menu[len], sizeof menu - len - 1, "\r3.\w %L^n", id, "MENU_ITEMMAKER_BUGKILLER", fm_get_entity_num("edit_bugkiller"))
	len += formatex(menu[len], sizeof menu - len - 1, "\r4.\w %L^n", id, "MENU_ITEMMAKER_REMOVE")
	len += formatex(menu[len], sizeof menu - len - 1, "\r5.\w %L^n", id, "MENU_ITEMMAKER_REMOVEALL")
	len += formatex(menu[len], sizeof menu - len - 1, "\r6.\w %L^n", id, "MENU_ITEMMAKER_LOADALL")
	len += formatex(menu[len], sizeof menu - len - 1, "\r7.\w %L^n", id, "MENU_ITEMMAKER_SAVEALL")
	len += formatex(menu[len], sizeof menu - len - 1, "^n^n\r0.\w %L", id, "EXIT")
	show_menu(id, KEYSMENU, menu, -1, "ItemMaker Menu")
	return PLUGIN_HANDLED;
}
public menu_itemmaker(id, key){
	if(!(get_user_flags(id) & ACCESS_ADMIN)) return PLUGIN_HANDLED;
	switch(key){
		case 0: {
			new Float:origin[3], parm[4]
			pev(id, pev_origin, origin)
			ckrun_FVecIVec(origin, parm)
			parm[3] = CKI_HEALTHKIT
			ckrun_item_create_edit(parm)
		}
		case 1: {
			new Float:origin[3], parm[4]
			pev(id, pev_origin, origin)
			ckrun_FVecIVec(origin, parm)
			parm[3] = CKI_AMMOBOX
			ckrun_item_create_edit(parm)
		}
		case 2: {
			new Float:origin[3], parm[4]
			pev(id, pev_origin, origin)
			ckrun_FVecIVec(origin, parm)
			parm[3] = CKI_BUGKILLER
			ckrun_item_create_edit(parm)
		}
		case 3: ckrun_item_remove(id)
		case 4: ckrun_item_removeall(id)
		case 5: ckrun_item_loadall(id)
		case 6: ckrun_item_saveall(id)
		case 9: return PLUGIN_HANDLED;
	}
	show_menu_itemmaker(id)
	return PLUGIN_HANDLED;
}
public ckrun_item_remove(id){
	new Float:aim_origin[3], classname[32], num
	new ent
	fm_get_aim_origin(id, aim_origin)
	while((ent = engfunc(EngFunc_FindEntityInSphere, ent, aim_origin, 16.0)) != 0){
		pev(ent, pev_classname, classname, sizeof classname - 1)
		if(!equal(classname[0], "edit_", 5)) continue
		engfunc(EngFunc_RemoveEntity, ent)
		num ++
	}
	if(!num){
		client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_EDIT_FOUNDNOTHING")
		return PLUGIN_HANDLED
	}
	client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_EDIT_REMOVED")
	return PLUGIN_HANDLED
}

public ckrun_item_removeall(id){
	new num = fm_get_entity_num("edit_healthkit") + fm_get_entity_num("edit_ammobox")
	if(!num){
		client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", LANG_PLAYER, "MSG_EDIT_FOUNDNOTHING")
		return PLUGIN_HANDLED
	}
	new ent
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "edit_healthkit")) != 0)
		engfunc(EngFunc_RemoveEntity,ent)
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "edit_ammobox")) != 0)
		engfunc(EngFunc_RemoveEntity,ent)
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "edit_bugkiller")) != 0)
		engfunc(EngFunc_RemoveEntity,ent)
	client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", LANG_PLAYER, "MSG_EDIT_REMOVEDALL")
	return PLUGIN_HANDLED
}

public ckrun_item_loadall(id){
	ckrun_item_removeall(id)
	if (file_exists(g_ItemFile)){
		client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", LANG_PLAYER, "MSG_EDIT_LOADED")
		new data[4][6], linedata[256], Float:time = 0.2, file = fopen(g_ItemFile,"rt")
		new parm[4]
		while (file && !feof(file)){
			fgets(file, linedata, sizeof linedata - 1);
			if(!linedata[0] || str_count(linedata,' ') < 2) continue;
			parse(linedata,data[0],5,data[1],5,data[2],5,data[3],5);
			parm[0] = str_to_num(data[0])
			parm[1] = str_to_num(data[1])
			parm[2] = str_to_num(data[2])
			parm[3] = str_to_num(data[3])//物品类型
			set_task(time,"ckrun_item_create_edit", 0, parm, 4)
			time += 0.2
		}
		if (file) fclose(file);
	}
	return PLUGIN_HANDLED
}

public ckrun_item_saveall(id){
	new linedata[256],Float:origin[3],ent
	if (file_exists(g_ItemFile))
		delete_file(g_ItemFile)
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "edit_healthkit")) != 0){
		pev(ent, pev_origin, origin)
		format(linedata, sizeof linedata - 1, "%d %d %d %d", floatround(origin[0]), floatround(origin[1]), floatround(origin[2]), CKI_HEALTHKIT)
		write_file(g_ItemFile, linedata, -1)
		engfunc(EngFunc_RemoveEntity, ent)
	}
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "edit_ammobox")) != 0){
		pev(ent, pev_origin, origin)
		format(linedata, sizeof linedata - 1, "%d %d %d %d", floatround(origin[0]), floatround(origin[1]), floatround(origin[2]), CKI_AMMOBOX)
		write_file(g_ItemFile, linedata, -1)
		engfunc(EngFunc_RemoveEntity, ent)
	}
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "edit_bugkiller")) != 0){
		pev(ent, pev_origin, origin)
		format(linedata, sizeof linedata - 1, "%d %d %d %d", floatround(origin[0]), floatround(origin[1]), floatround(origin[2]), CKI_BUGKILLER)
		write_file(g_ItemFile, linedata, -1)
		engfunc(EngFunc_RemoveEntity, ent)
	}
	client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", LANG_PLAYER, "MSG_EDIT_SAVED")
	return PLUGIN_HANDLED
}


public zmstats(id) {
	new title[51];
	format(title, 50, "%L", id, "MENU_STATS")
	new menu = menu_create(title, "zmstatsHandler");
	new menuitem_1[64];
	format(menuitem_1, 63, "%L", id, "MENU_STATS_1",gstats[id][0],gstats[id][2]);
	new menuitem_2[64];
	format(menuitem_2, 63, "%L", id, "MENU_STATS_2",gstats[id][1],gstats[id][3]);
	new menuitem_3[64];
	format(menuitem_3, 63, "%L", id, "MENU_STATS_3",gkill[id],gdeath[id]);
	new Float:kpd = float(gkill[id]) / float(gdeath[id])
	if(kpd <= 0.0)
		kpd = float(gkill[id]) / 1.0
	new menuitem_4[64];
	format(menuitem_4, 63, "%L", id, "MENU_STATS_4",kpd);
	new menuitem_back[16];
	format(menuitem_back, 15, "%L", id, "MENU_BACK");
	menu_additem(menu, menuitem_1, "1", 0);
	menu_additem(menu, menuitem_2, "2", 0);
	menu_additem(menu, menuitem_3, "3", 0);
	menu_additem(menu, menuitem_4, "4", 0);
	menu_additem(menu, menuitem_back, "5", 0);
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public zmstatsHandler(id, menu, item) {
	if(item == MENU_EXIT) {
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	new data[6], name[64]
	new access, callback
	menu_item_getinfo(menu, item, access, data, 5, name, 63, callback)
	new key = str_to_num(data)
	switch(key){
		case 1:	zmstats(id)
		case 2:	zmstats(id)
		case 3:	zmstats(id)
		case 4:	zmstats(id)
		case 5:	show_menu_main(id)
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public show_menu_model(id){
	static menu[512], len
	len = 0
	len += formatex(menu[len], sizeof menu - len - 1, "\y%L^n\w%L^n", id, "MENU_MODEL", id, "MENU_MODEL_NOW", id, mdl_human_formatname[gmodel[id]])
	new i, flags = get_user_flags(id)
	for (i = g_menu_data[id][2]; i < min(g_menu_data[id][2]+7, MAX_MODELID); i++){
		if(!(flags & mdl_human_access[i]) && !(mdl_human_access[i] & ACCESS_USER))
			len += formatex(menu[len], sizeof menu - len - 1, "\r%d.\d %L^n", i-g_menu_data[id][2]+1, id, mdl_human_formatname[i])
		else
			len += formatex(menu[len], sizeof menu - len - 1, "\r%d.\w %L^n", i-g_menu_data[id][2]+1, id, mdl_human_formatname[i])
	}
	len += formatex(menu[len], sizeof menu - len - 1, "^n^n\r9.\w %L/%L^n^n\r0.\w %L", id, "MORE", id, "BACK", id, "EXIT")

	show_menu(id, KEYSMENU, menu, -1, "Model Menu")
	return PLUGIN_HANDLED;
}

public menu_model(id, key){
	if (!(1 <= id <= g_maxplayers))
		return PLUGIN_HANDLED;

	if (key >= 8 || g_menu_data[id][2]+key >= MAX_MODELID){
		switch (key){
			case 8:{
				if (g_menu_data[id][2]+7 < MAX_MODELID)
					g_menu_data[id][2] += 7
				else
					g_menu_data[id][2] = 0
			}
			case 9:	return PLUGIN_HANDLED
		}
		show_menu_model(id)
		return PLUGIN_HANDLED;
	}
	new flags = get_user_flags(id)
	new rkey = g_menu_data[id][2]+key
	if(!(flags & mdl_human_access[rkey]) && !(mdl_human_access[rkey] & ACCESS_USER)){
		if(mdl_human_access[rkey] & ACCESS_VIP)
			client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_MODEL_ACCESS", id, "NAME_ACCESS_VIP")
		else if(mdl_human_access[rkey] & ACCESS_ADMIN)
			client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_MODEL_ACCESS", id, "NAME_ACCESS_ADMIN")
		show_menu_model(id)
		return PLUGIN_HANDLED;
	}

	g_menu_data[id][4] = rkey

	select_menu_model(id, g_menu_data[id][4])

	return PLUGIN_HANDLED;
}
public select_menu_model(id, modelindex){
	gmodel[id] = modelindex
	client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_MODEL_SELECTED", id, mdl_human_formatname[modelindex])
	show_menu_model(id)

	return PLUGIN_HANDLED;
}

public show_menu_achievement(id){
	static menu[512], len, i
	len = 0
	len += formatex(menu[len], sizeof menu - len - 1, "\y%L^n^n", id, "MENU_ACHIEVEMENT")
	for (i = g_menu_data[id][2]; i < min(g_menu_data[id][2]+7, MAX_ACHIEVEMENT); i++){
		len += formatex(menu[len], sizeof menu - len - 1, "\r%d.\w %L^n", i-g_menu_data[id][2]+1, id, ach_menu_name[i])
	}
	len += formatex(menu[len], sizeof menu - len - 1, "^n^n\r9.\w %L/%L^n^n\r0.\w %L", id, "MORE", id, "BACK", id, "EXIT")
	show_menu(id, KEYSMENU, menu, -1, "Achievement Menu")
	return PLUGIN_HANDLED;
}
public menu_achievement(id, key){
	if (!(1 <= id <= g_maxplayers))
		return PLUGIN_HANDLED;

	if (key >= 8 || g_menu_data[id][2]+key >= MAX_ACHIEVEMENT){
		switch (key){
			case 8:{
				if (g_menu_data[id][2]+7 < MAX_ACHIEVEMENT)
					g_menu_data[id][2] += 7
				else
					g_menu_data[id][2] = 0
			}
			case 9:	return PLUGIN_HANDLED
		}
		show_menu_achievement(id)
		return PLUGIN_HANDLED;
	}
	select_menu_achievement(id, g_menu_data[id][2]+key)
	return PLUGIN_HANDLED;
}
public select_menu_achievement(id, select){
	switch(select){
		case 0:motd_ach_fast(id)
		//case 1:motd_ach_grav(id)
	}
	return PLUGIN_HANDLED;
}

public motd_ach_fast(id){
	static motd[5000], len, i
	len = 0
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_ACH_FAST")
	for(i=0; i < MAX_ACH_FAST; i++){
		if(!ach_fast_progress[i]){
			if(!g_ach_fast[id][i]) len += formatex(motd[len], sizeof motd - 1 - len, "%L%L", id, ach_fast_title[i], id, ach_fast_text[i])
			else len += formatex(motd[len], sizeof motd - 1 - len, "%L%L%L", id, ach_fast_title[i], id, ach_fast_text[i], id, "MOTD_ACH_COMPLETED")
		} else {
			if(g_ach_fast[id][i] >= ach_fast_progress[i]) len += formatex(motd[len], sizeof motd - len - 1, "%L%L(%d / %d)%L", id, ach_fast_title[i], id, ach_fast_text[i], g_ach_fast[id][i], ach_fast_progress[i], id, "MOTD_ACH_COMPLETED")
			else len += formatex(motd[len], sizeof motd - len - 1, "%L%L(%d / %d)", id, ach_fast_title[i], id, ach_fast_text[i], g_ach_fast[id][i], ach_fast_progress[i])
		}
	}
	show_motd(id, motd)
}

public show_menu_build(id){
	if (!(1 <= id <= g_maxplayers))
		return PLUGIN_HANDLED;
	if (giszm[id] || ghuman[id] != human_eng)
		return PLUGIN_HANDLED;
	if (get_user_weapon(id) != CSW_C4 || gengmode[id] != 1)
		return PLUGIN_HANDLED;
	static menu[256], len
	len = 0
	len += formatex(menu[len], sizeof menu - len - 1, "\y%L^n^n", id, "MENU_BUILD")
	if(!ghavesentry[id])
		len += formatex(menu[len], sizeof menu - len - 1, "\r1.\w %L^n", id, "MENU_BUILD_1")//sentry
	else
		len += formatex(menu[len], sizeof menu - len - 1, "\r1.\d %L^n", id, "MENU_BUILD_1")
	if(!ghavedispenser[id])
		len += formatex(menu[len], sizeof menu - len - 1, "\r2.\w %L^n", id, "MENU_BUILD_2")//dispenser
	else
		len += formatex(menu[len], sizeof menu - len - 1, "\r2.\d %L^n", id, "MENU_BUILD_2")
	if(!ghavetelein[id])
		len += formatex(menu[len], sizeof menu - len - 1, "\r3.\w %L^n", id, "MENU_BUILD_3")
	else
		len += formatex(menu[len], sizeof menu - len - 1, "\r3.\d %L^n", id, "MENU_BUILD_3")
	if(!ghaveteleout[id])
		len += formatex(menu[len], sizeof menu - len - 1, "\r4.\w %L^n", id, "MENU_BUILD_4")
	else
		len += formatex(menu[len], sizeof menu - len - 1, "\r4.\d %L^n", id, "MENU_BUILD_4")
	len += formatex(menu[len], sizeof menu - len - 1, "^n^n\r0.\w %L", id, "EXIT")

	show_menu(id, KEYSMENU, menu, -1, "Build Menu")
	return PLUGIN_HANDLED;
}

public menu_build(id, key){
	if (!(1 <= id <= g_maxplayers))
		return PLUGIN_HANDLED;
	if (giszm[id] || ghuman[id] != human_eng)
		return PLUGIN_HANDLED;
	if (get_user_weapon(id) != CSW_C4 || gengmode[id] != 1)
		return PLUGIN_HANDLED;

	switch(key){
		case 0:sentry_build(id)
		case 1:dispenser_build(id)
		case 2:telein_build(id)
		case 3:teleout_build(id)
		case 9:return PLUGIN_HANDLED
	}
	show_menu_build(id)
	return PLUGIN_HANDLED;
}

public show_menu_demolish(id){
	if (!(1 <= id <= g_maxplayers))
		return PLUGIN_HANDLED;
	if (giszm[id] || ghuman[id] != human_eng)
		return PLUGIN_HANDLED;
	if (get_user_weapon(id) != CSW_C4 || gengmode[id] != 2)
		return PLUGIN_HANDLED;
	static menu[256], len
	len = 0
	len += formatex(menu[len], sizeof menu - len - 1, "\y%L^n^n", id, "MENU_DEMOLISH")
	if(ghavesentry[id])
		len += formatex(menu[len], sizeof menu - len - 1, "\r1.\w %L^n", id, "MENU_DEMOLISH_1")//sentry
	else
		len += formatex(menu[len], sizeof menu - len - 1, "\r1.\d %L^n", id, "MENU_DEMOLISH_1")
	if(ghavedispenser[id])
		len += formatex(menu[len], sizeof menu - len - 1, "\r2.\w %L^n", id, "MENU_DEMOLISH_2")//dispenser
	else
		len += formatex(menu[len], sizeof menu - len - 1, "\r2.\d %L^n", id, "MENU_DEMOLISH_2")
	if(ghavetelein[id])
		len += formatex(menu[len], sizeof menu - len - 1, "\r3.\w %L^n", id, "MENU_DEMOLISH_3")
	else
		len += formatex(menu[len], sizeof menu - len - 1, "\r3.\d %L^n", id, "MENU_DEMOLISH_3")
	if(ghaveteleout[id])
		len += formatex(menu[len], sizeof menu - len - 1, "\r4.\w %L^n", id, "MENU_DEMOLISH_4")
	else
		len += formatex(menu[len], sizeof menu - len - 1, "\r4.\d %L^n", id, "MENU_DEMOLISH_4")
	len += formatex(menu[len], sizeof menu - len - 1, "^n^n\r0.\w %L", id, "EXIT")

	show_menu(id, KEYSMENU, menu, -1, "Demolish Menu")
	return PLUGIN_HANDLED;
}

public menu_demolish(id, key){
	if (!(1 <= id <= g_maxplayers))
		return PLUGIN_HANDLED;
	if (giszm[id] || ghuman[id] != human_eng)
		return PLUGIN_HANDLED;
	if (get_user_weapon(id) != CSW_C4 || gengmode[id] != 2)
		return PLUGIN_HANDLED;

	switch(key){
		case 0:{
			if(ghavesentry[id])
				ckrun_sentry_destory(id)
			else
				client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_BUILD_DONTHAVE")
		}
		case 1:	{
			if(ghavedispenser[id])
				ckrun_dispenser_destory(id)
			else
				client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_BUILD_DONTHAVE")
		}
		case 2:	{
			if(ghavetelein[id])
				ckrun_telein_destory(id, 0)
			else
				client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_BUILD_DONTHAVE")
		}
		case 3:	{
			if(ghaveteleout[id])
				ckrun_teleout_destory(id, 0)
			else
				client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_BUILD_DONTHAVE")
		}
		case 9:return PLUGIN_HANDLED
	}
	show_menu_demolish(id)
	return PLUGIN_HANDLED;
}

public show_menu_admin(id){
	static menu[512], len
	len = 0
	len += formatex(menu[len], sizeof menu - len - 1, "\y%L^n\w%L^n", id, "MENU_ADMIN")
	new i, flags = get_user_flags(id)
	for (i = g_menu_data[id][2]; i < min(g_menu_data[id][2]+7, sizeof admin_menu_name); i++){
		if(!(flags & admin_menu_access[i]) && !(admin_menu_access[i] & ACCESS_USER))
			len += formatex(menu[len], sizeof menu - len - 1, "\r%d.\d %L^n", i-g_menu_data[id][2]+1, id, admin_menu_name[i])
		else
			len += formatex(menu[len], sizeof menu - len - 1, "\r%d.\w %L^n", i-g_menu_data[id][2]+1, id, admin_menu_name[i])
	}
	len += formatex(menu[len], sizeof menu - len - 1, "^n^n\r9.\w %L/%L^n^n\r0.\w %L", id, "MORE", id, "BACK", id, "EXIT")

	show_menu(id, KEYSMENU, menu, -1, "Admin Menu")
}

public menu_admin(id, key){
	if (!(1 <= id <= g_maxplayers))
		return PLUGIN_HANDLED;

	if (key >= 8 || g_menu_data[id][2]+key >= sizeof admin_menu_name){
		switch (key){
			case 8:{
				if (g_menu_data[id][2]+7 < sizeof admin_menu_name)
					g_menu_data[id][2] += 7
				else
					g_menu_data[id][2] = 0
			}
			case 9:	return PLUGIN_HANDLED
		}
		show_menu_admin(id)
		return PLUGIN_HANDLED;
	}
	new flags = get_user_flags(id)
	new rkey = g_menu_data[id][2]+key
	if(!(flags & admin_menu_access[rkey]) && !(admin_menu_access[rkey] & ACCESS_USER)){
		if(admin_menu_access[rkey] & ACCESS_VIP)
			client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_NEED_ACCESS", id, "NAME_ACCESS_VIP")
		else if(admin_menu_access[rkey] & ACCESS_ADMIN)
			client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_NEED_ACCESS", id, "NAME_ACCESS_ADMIN")
		show_menu_admin(id)
		return PLUGIN_HANDLED;
	}

	g_menu_data[id][4] = rkey

	select_menu_admin(id, g_menu_data[id][4])

	return PLUGIN_HANDLED;
}

public select_menu_admin(id, key){
	switch(key){
		case 0: client_cmd(id, "ckrun_setzombie")
		case 1: client_cmd(id, "ckrun_sethuman")
		case 2: client_cmd(id, "ckrun_zombieclass")
		case 3: client_cmd(id, "ckrun_humanclass")
		case 4: client_cmd(id, "ckrun_respawn")
		case 5: client_cmd(id, "ckrun_health")
		case 6: client_cmd(id, "ckrun_ammo")
		case 7: client_cmd(id, "ckrun_model")
	}
}

public actionSetZombieMenu(id, key){
	switch(key){
		case 8: displaySetZombieMenu(id, ++g_menuPosition[id])
		case 9: displaySetZombieMenu(id, --g_menuPosition[id])
		default:{
			new player = g_menuPlayers[id][g_menuPosition[id] * 8 + key]
			new name[48]
			get_user_name(player, name, sizeof name - 1)
			if(!is_user_alive(player)){
				client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_SETZM_DEAD", name)
				return PLUGIN_HANDLED
			} else if(giszm[player]){
				client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_SETZM_ALREADY", name)
				return PLUGIN_HANDLED
			} else {
				client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_SETHM_SUCCESS", name)
				ckrun_set_user_zombie(player)
				displaySetZombieMenu(id, g_menuPosition[id])
			}
		}
	}
	return PLUGIN_HANDLED
}

displaySetZombieMenu(id, pos){
	if (pos < 0)
		return

	get_players(g_menuPlayers[id], g_menuPlayersNum[id])

	new menuBody[512]
	new b = 0
	new i
	new name[32]
	new start = pos * 8

	if (start >= g_menuPlayersNum[id])
		start = pos = g_menuPosition[id] = 0

	new len = format(menuBody, 511, g_coloredMenus ? "\y%L\R%d/%d^n\w^n" : "%L %d/%d^n^n", id, "MENU_SETZOMBIE", pos + 1, (g_menuPlayersNum[id] / 8 + ((g_menuPlayersNum[id] % 8) ? 1 : 0)))
	new end = start + 8
	new keys = MENU_KEY_0

	if (end > g_menuPlayersNum[id])
		end = g_menuPlayersNum[id]

	for (new a = start; a < end; ++a)
	{
		i = g_menuPlayers[id][a]
		get_user_name(i, name, 31)

		if (access(i, ADMIN_IMMUNITY) && i != id)
		{
			++b
		
			if (g_coloredMenus)
				len += format(menuBody[len], 511-len, "\d%d. %s^n\w", b, name)
			else
				len += format(menuBody[len], 511-len, "#. %s^n", name)
		} else {
			keys |= (1<<b)
				
			if (is_user_admin(i))
				len += format(menuBody[len], 511-len, g_coloredMenus ? "%d. %s \r*^n\w" : "%d. %s *^n", ++b, name)
			else
				len += format(menuBody[len], 511-len, "%d. %s^n", ++b, name)
		}
	}

	if (end != g_menuPlayersNum[id])
	{
		format(menuBody[len], 511-len, "^n9. %L...^n0. %L", id, "MORE", id, pos ? "BACK" : "EXIT")
		keys |= MENU_KEY_9
	}
	else
		format(menuBody[len], 511-len, "^n0. %L", id, pos ? "BACK" : "EXIT")

	show_menu(id, keys, menuBody, -1, "Set Zombie Menu")
}

public cmdSetZombieMenu(id, level, cid){
	if (cmd_access(id, level, cid, 1))
		displaySetZombieMenu(id, g_menuPosition[id] = 0)

	return PLUGIN_HANDLED
}

public actionSetHumanMenu(id, key){
	switch(key){
		case 8: displaySetHumanMenu(id, ++g_menuPosition[id])
		case 9: displaySetHumanMenu(id, --g_menuPosition[id])
		default:{
			new player = g_menuPlayers[id][g_menuPosition[id] * 8 + key]
			new name[48]
			get_user_name(player, name, sizeof name - 1)
			if(!is_user_alive(player)){
				client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_SETHM_DEAD", name)
				return PLUGIN_HANDLED
			} else if(!giszm[player]){
				client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_SETHM_ALREADY", name)
				return PLUGIN_HANDLED
			} else {
				client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_SETHM_SUCCESS", name)
				ckrun_set_user_human(player)
				displaySetHumanMenu(id, g_menuPosition[id])
			}
		}
	}
	return PLUGIN_HANDLED
}

displaySetHumanMenu(id, pos){
	if (pos < 0)
		return

	get_players(g_menuPlayers[id], g_menuPlayersNum[id])

	new menuBody[512]
	new b = 0
	new i
	new name[32]
	new start = pos * 8

	if (start >= g_menuPlayersNum[id])
		start = pos = g_menuPosition[id] = 0

	new len = format(menuBody, 511, g_coloredMenus ? "\y%L\R%d/%d^n\w^n" : "%L %d/%d^n^n", id, "MENU_SETHUMAN", pos + 1, (g_menuPlayersNum[id] / 8 + ((g_menuPlayersNum[id] % 8) ? 1 : 0)))
	new end = start + 8
	new keys = MENU_KEY_0

	if (end > g_menuPlayersNum[id])
		end = g_menuPlayersNum[id]

	for (new a = start; a < end; ++a)
	{
		i = g_menuPlayers[id][a]
		get_user_name(i, name, 31)

		if (access(i, ADMIN_IMMUNITY) && i != id)
		{
			++b
		
			if (g_coloredMenus)
				len += format(menuBody[len], 511-len, "\d%d. %s^n\w", b, name)
			else
				len += format(menuBody[len], 511-len, "#. %s^n", name)
		} else {
			keys |= (1<<b)
				
			if (is_user_admin(i))
				len += format(menuBody[len], 511-len, g_coloredMenus ? "%d. %s \r*^n\w" : "%d. %s *^n", ++b, name)
			else
				len += format(menuBody[len], 511-len, "%d. %s^n", ++b, name)
		}
	}

	if (end != g_menuPlayersNum[id])
	{
		format(menuBody[len], 511-len, "^n9. %L...^n0. %L", id, "MORE", id, pos ? "BACK" : "EXIT")
		keys |= MENU_KEY_9
	}
	else
		format(menuBody[len], 511-len, "^n0. %L", id, pos ? "BACK" : "EXIT")

	show_menu(id, keys, menuBody, -1, "Set Human Menu")
}

public cmdSetHumanMenu(id, level, cid){
	if (cmd_access(id, level, cid, 1))
		displaySetHumanMenu(id, g_menuPosition[id] = 0)

	return PLUGIN_HANDLED
}

//------------------------------//
public fw_spawn(id){
	if(id == g_tbot || id == g_ctbot){
		set_pev(id, pev_effects, (pev(id, pev_effects) | EF_NODRAW))
		set_pev(id, pev_solid, SOLID_NOT)
		set_pev(id, pev_origin, Float:{8192.0 ,8192.0 ,8192.0})
		return HAM_IGNORED
	}
	if(g_round != round_zombie){
		g_spawntime += SPAWN_DELAY
		if(g_spawntime > 5.0) g_spawntime = 5.0
		remove_task(id+TASK_SPAWN, 0)
		set_task(g_spawntime, "task_spawn", id+TASK_SPAWN)
		if(g_gamemode == mode_normal) giszm[id] = false
	} else {
		task_spawn(id)
	}
	return HAM_IGNORED
}
public task_spawn(taskid){
	static id
	if(taskid > g_maxplayers)
		id = ID_SPAWN
	else
		id = taskid
	if(!is_user_connected(id)) return;
	if(id == g_tbot || id == g_ctbot){
		set_pev(id, pev_effects, (pev(id, pev_effects) | EF_NODRAW))
		set_pev(id, pev_solid, SOLID_NOT)
		set_pev(id, pev_origin, Float:{8192.0 ,8192.0 ,8192.0})
		return
	}
	ckrun_add_user_score(id,0,0)//更新
	check_ach_fast_14(id)
	if(!is_user_alive(id) || fm_get_user_team(id) == CS_TEAM_SPECTATOR) return;
	if (g_round == round_start && g_gamemode == mode_normal) giszm[id] = false
	if (g_round == round_zombie && g_gamemode == mode_normal) giszm[id] = true
	client_cmd(id, "stopsound")
	set_task(0.2, "hide_money", id+TASK_HIDEMONEY)
	g_zspawned[id] = true
	if (!giszm[id]){
		gzombie[id] = gwillbezombie[id]
		ghuman[id] = gwillbehuman[id]
		ckrun_sentry_destory(id)
		ckrun_dispenser_destory(id)
		ckrun_telein_destory(id, 1)
		ckrun_teleout_destory(id, 1)
		ckrun_reset_user_var(id)
		ckrun_reset_user_knife(id)
		#if defined AMBIENCE_SOUND
		set_task(1.0,"FX_AmbienceSound", id+TASK_AMBIENCE_SOUND, _ , _)
		#endif
		remove_task(id+TASK_STABDELAY, 0)
		set_task(HUD_REFRESH, "ckrun_showhud_status", id+TASK_SHOWHUD)
		set_task(CENTER_REFRESH, "ckrun_showhud_center", id+TASK_SHOWCENTER)
		set_task(PLAYER_THINK, "think_Player", id+TASK_PLAYER_THINK)
		set_task(0.1,"spawn_fix",id)
		set_task(1.5, "funcCritical", id+TASK_CRITICAL)
		//set_task(1.0,"funcHealthRegen",id+TASK_HEALTH_REGEN)
		//set_task(1.0,"funcAmmoRegen",id+TASK_AMMO_REGEN)
		fm_set_user_bpammo(id,18,get_pcvar_num(cvar_wpn_ammo_awp))    // awp
		fm_set_user_bpammo(id,20,get_pcvar_num(cvar_wpn_ammo_m249))   // m249
		fm_set_user_bpammo(id,26,get_pcvar_num(cvar_wpn_ammo_deagle)) // deagle
		fm_set_user_bpammo(id,21,get_pcvar_num(cvar_wpn_ammo_shotgun))// m3, xm1014
		fm_set_user_bpammo(id,3,get_pcvar_num(cvar_wpn_ammo_default)) // scout, ak, g3sg1
		fm_set_user_bpammo(id,1,get_pcvar_num(cvar_wpn_ammo_default)) // p228
		fm_set_user_bpammo(id,15,get_pcvar_num(cvar_wpn_ammo_default))// famas, m4a1, aug, sg550, galil, sg552 
		fm_set_user_bpammo(id,16,get_pcvar_num(cvar_wpn_ammo_default))// usp, ump, mac
		fm_set_user_bpammo(id,11,get_pcvar_num(cvar_wpn_ammo_default))// fiveseven, p90
		fm_set_user_bpammo(id,17,get_pcvar_num(cvar_wpn_ammo_default))// glock, mp5, tmp, elites
		client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_INFO_1")
		client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_INFO_2")
		client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_INFO_3")
		client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_INFO_4")
		drop_weapons(id,1)
		drop_weapons(id,2)
		ham_strip_weapon(id, "weapon_c4")
		if(!gzombie[id]){
			gzombie[id] = random_num(1, 5)
			gwillbezombie[id] = gzombie[id]
		}
		if(!ghuman[id]){
			ghuman[id] = random_num(1, 6)
			gwillbehuman[id] = ghuman[id]
		}
		switch(ghuman[id]){
			case 1: {
				fm_give_item(id, "weapon_hegrenade")
				engclient_cmd(id, "weapon_knife")
				gorispeed[id] = get_pcvar_num(cvar_hm_scout_speed)
				gcurspeed[id] = gorispeed[id]
				fm_set_user_health(id,get_pcvar_num(cvar_hm_scout_hp))
			}
			case 2: {
				fm_give_item(id, "weapon_m249")
				engclient_cmd(id, "weapon_knife")
				gorispeed[id] = get_pcvar_num(cvar_hm_heavy_speed)
				gcurspeed[id] = gorispeed[id]
				fm_set_user_health(id,get_pcvar_num(cvar_hm_heavy_hp))
			}
			case 3: {
				fm_give_item(id, "weapon_c4")
				engclient_cmd(id, "weapon_knife")
				gorispeed[id] = get_pcvar_num(cvar_hm_rpg_speed)
				gcurspeed[id] = gorispeed[id]
				fm_set_user_health(id,get_pcvar_num(cvar_hm_rpg_hp))
			}
			case 4: {
				fm_give_item(id, "weapon_awp")
				engclient_cmd(id, "weapon_knife")
				gorispeed[id] = get_pcvar_num(cvar_hm_snipe_speed)
				gcurspeed[id] = gorispeed[id]
				fm_set_user_health(id,get_pcvar_num(cvar_hm_snipe_hp))
				set_task(0.1,"funcSniperRegen",id+TASK_SNIPE_REGEN)
			}
			case 5: {
				fm_give_item(id, "weapon_c4")
				engclient_cmd(id, "weapon_knife")
				gorispeed[id] = get_pcvar_num(cvar_hm_log_speed)
				gcurspeed[id] = gorispeed[id]
				fm_set_user_health(id,get_pcvar_num(cvar_hm_log_hp))
			}
			case 6: {
				fm_give_item(id, "weapon_c4")
				engclient_cmd(id, "weapon_knife")
				gorispeed[id] = get_pcvar_num(cvar_hm_eng_speed)
				gcurspeed[id] = gorispeed[id]
				fm_set_user_health(id,get_pcvar_num(cvar_hm_eng_hp))
			}
		}
		if (is_user_bot(id)){
			gmodel[id] = random_num(4, 7)
			switch(ghuman[id]){
				case human_scout:{
					fm_give_item(id, g_wpn_classname[g_primary_allow_scout[random_num(0, sizeof g_primary_allow_scout-1)]])
					fm_give_item(id, g_wpn_classname[g_secondary_allow_scout[random_num(0, sizeof g_secondary_allow_scout-1)]])
				}
				case human_heavy:{
					fm_give_item(id, g_wpn_classname[g_primary_allow_heavy[random_num(0, sizeof g_primary_allow_heavy-1)]])
					fm_give_item(id, g_wpn_classname[g_secondary_allow_mg[random_num(0, sizeof g_secondary_allow_mg-1)]])
				}
				case human_rpg:{
					fm_give_item(id, g_wpn_classname[g_primary_allow_rpg[random_num(0, sizeof g_primary_allow_rpg-1)]])
					fm_give_item(id, g_wpn_classname[g_secondary_allow_rpg[random_num(0, sizeof g_secondary_allow_rpg-1)]])
				}
				case human_snipe:{
					fm_give_item(id, g_wpn_classname[g_primary_allow_snipe[random_num(0, sizeof g_primary_allow_snipe-1)]])
					fm_give_item(id, g_wpn_classname[g_secondary_allow_snipe[random_num(0, sizeof g_secondary_allow_snipe-1)]])
				}
				case human_log:{
					fm_give_item(id, g_wpn_classname[g_primary_allow_log[random_num(0, sizeof g_primary_allow_log-1)]])
					fm_give_item(id, g_wpn_classname[g_secondary_allow_log[random_num(0, sizeof g_secondary_allow_log-1)]])
				}
				case human_eng:{
					fm_give_item(id, g_wpn_classname[g_primary_allow_eng[random_num(0, sizeof g_primary_allow_eng-1)]])
					fm_give_item(id, g_wpn_classname[g_secondary_allow_eng[random_num(0, sizeof g_secondary_allow_eng-1)]])
				}
			}
		} else {
			show_menu_main(id)
		}
		format(gcurmodel[id], 31, "%s", mdl_human[gmodel[id]])
		fm_set_user_model(id, gcurmodel[id])
		fm_set_rendering(id, kRenderFxNone, 0, 0, 255, kRenderNormal, 255)
	} else {
		gzombie[id] = gwillbezombie[id]
		ghuman[id] = gwillbehuman[id]
		ckrun_set_user_zombie(id)
	}

}
public event_round_start(){
	g_round = round_start
	g_firstkill = false
	faketeambot_create()
	gkill[g_ctbot] = 999
	gkill[g_tbot] = 999
	set_task(1.0, "round_timer", TASK_ROUND_TIMER)
	switch(g_gamemode){
		case mode_normal:{
			g_roundtime = get_pcvar_num(cvar_roundtime_default)
			if(pev_valid(g_ctbot))
				engfunc(EngFunc_SetClientKeyValue, g_ctbot, engfunc(EngFunc_GetInfoKeyBuffer, g_ctbot), "name", team_names[2])
			if(pev_valid(g_tbot))
				engfunc(EngFunc_SetClientKeyValue, g_tbot, engfunc(EngFunc_GetInfoKeyBuffer, g_tbot), "name", team_names[3])
			remove_task(TASK_FIRST_ZOMBIE,0)
			set_task(20.0,"first_zombie",TASK_FIRST_ZOMBIE)
		}
		case mode_capture: {
			g_roundtime = get_pcvar_num(cvar_roundtime_capture)
			g_round = round_zombie
			if(pev_valid(g_ctbot)){
				engfunc(EngFunc_SetClientKeyValue, g_ctbot, engfunc(EngFunc_GetInfoKeyBuffer, g_ctbot), "name", team_names[1])
				fm_set_user_team(g_ctbot, CS_TEAM_CT)
			}
			if(pev_valid(g_tbot)){
				engfunc(EngFunc_SetClientKeyValue, g_tbot, engfunc(EngFunc_GetInfoKeyBuffer, g_tbot), "name", team_names[0])
				fm_set_user_team(g_tbot, CS_TEAM_T)
			}
			new i
			for(i = 0; i < g_cp_pointnums; i++)
				g_cp_progress[i] = 0
 			g_cp_local = 0
		}
		case mode_ctflag:{
			g_roundtime = get_pcvar_num(cvar_roundtime_ctflag)
			if(pev_valid(g_ctbot)){
				engfunc(EngFunc_SetClientKeyValue, g_ctbot, engfunc(EngFunc_GetInfoKeyBuffer, g_ctbot), "name", team_names[1])
				fm_set_user_team(g_ctbot, CS_TEAM_CT)
			}
			if(pev_valid(g_tbot)){
				engfunc(EngFunc_SetClientKeyValue, g_tbot, engfunc(EngFunc_GetInfoKeyBuffer, g_tbot), "name", team_names[0])
				fm_set_user_team(g_tbot, CS_TEAM_T)
			}
		}
		case mode_payload:{
			g_roundtime = get_pcvar_num(cvar_roundtime_payload)
			if(pev_valid(g_ctbot)){
				engfunc(EngFunc_SetClientKeyValue, g_ctbot, engfunc(EngFunc_GetInfoKeyBuffer, g_ctbot), "name", team_names[1])
				fm_set_user_team(g_ctbot, CS_TEAM_CT)
			}
			if(pev_valid(g_tbot)){
				engfunc(EngFunc_SetClientKeyValue, g_tbot, engfunc(EngFunc_GetInfoKeyBuffer, g_tbot), "name", team_names[0])
				fm_set_user_team(g_tbot, CS_TEAM_T)
			}
		}
	}
	static ent,i
	for (i = 0; i < sizeof g_round_remove; i++)
		while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", g_round_remove[i])) != 0)
			engfunc(EngFunc_RemoveEntity, ent)
	format(g_text3, sizeof g_text3 - 1, "")
	format(g_text2, sizeof g_text2 - 1, "")
	format(g_text1, sizeof g_text1 - 1, "")
}
public event_round_end(){
	if(g_round == round_end) return;
	g_round = round_end
	g_cp_local = 0
	g_spawntime = 0.0
	server_cmd("sv_restart 10")
	faketeambot_create()
	set_task(1.0, "round_timer", TASK_ROUND_TIMER)
	for(new i=1;i < g_maxplayers ; i++){
		check_ach_fast_10(i)
		g_roundkill[i] = 0
		g_rounddeath[i] = 0
	}
	switch(g_gamemode){
		case mode_normal:{
			set_task(0.1,"team_balancer")
			if(pev_valid(g_ctbot))
				engfunc(EngFunc_SetClientKeyValue, g_ctbot, engfunc(EngFunc_GetInfoKeyBuffer, g_ctbot), "name", team_names[2])
			if(pev_valid(g_tbot))
				engfunc(EngFunc_SetClientKeyValue, g_tbot, engfunc(EngFunc_GetInfoKeyBuffer, g_tbot), "name", team_names[3])
			remove_task(TASK_FIRST_ZOMBIE,0)
			set_task(20.0,"first_zombie",TASK_FIRST_ZOMBIE)
		}
		case mode_capture: {
			if(pev_valid(g_ctbot)){
				engfunc(EngFunc_SetClientKeyValue, g_ctbot, engfunc(EngFunc_GetInfoKeyBuffer, g_ctbot), "name", team_names[1])
				fm_set_user_team(g_ctbot, CS_TEAM_CT)
			}
			if(pev_valid(g_tbot)){
				engfunc(EngFunc_SetClientKeyValue, g_tbot, engfunc(EngFunc_GetInfoKeyBuffer, g_tbot), "name", team_names[0])
				fm_set_user_team(g_tbot, CS_TEAM_T)
			}
		}
		case mode_ctflag:{
			if(pev_valid(g_ctbot)){
				engfunc(EngFunc_SetClientKeyValue, g_ctbot, engfunc(EngFunc_GetInfoKeyBuffer, g_ctbot), "name", team_names[1])
				fm_set_user_team(g_ctbot, CS_TEAM_CT)
			}
			if(pev_valid(g_tbot)){
				engfunc(EngFunc_SetClientKeyValue, g_tbot, engfunc(EngFunc_GetInfoKeyBuffer, g_tbot), "name", team_names[0])
				fm_set_user_team(g_tbot, CS_TEAM_T)
			}
		}
		case mode_payload:{
			if(pev_valid(g_ctbot)){
				engfunc(EngFunc_SetClientKeyValue, g_ctbot, engfunc(EngFunc_GetInfoKeyBuffer, g_ctbot), "name", team_names[1])
				fm_set_user_team(g_ctbot, CS_TEAM_CT)
			}
			if(pev_valid(g_tbot)){
				engfunc(EngFunc_SetClientKeyValue, g_tbot, engfunc(EngFunc_GetInfoKeyBuffer, g_tbot), "name", team_names[0])
				fm_set_user_team(g_tbot, CS_TEAM_T)
			}
		}
	}
}
public end_round(team){
	if(g_round == round_end) return;
	switch(team){
		case win_no:{
			format(g_text3, sizeof g_text3 - 1, "")
			format(g_text2, sizeof g_text2 - 1, "")
			format(g_text1, sizeof g_text1 - 1, "%L", LANG_PLAYER, "MSG_WIN_NO")
			fm_PlaySound(0, snd_win_no[random_num(0, sizeof snd_win_no - 1)])
		}
		case win_human:{
			format(g_text3, sizeof g_text3 - 1, "")
			format(g_text2, sizeof g_text2 - 1, "")
			format(g_text1, sizeof g_text1 - 1, "%L", LANG_PLAYER, "MSG_WIN_HUMAN")
			fm_PlaySound(0, snd_win_human[random_num(0, sizeof snd_win_human - 1)])
		}
		case win_zombie:{
			format(g_text3, sizeof g_text3 - 1, "")
			format(g_text2, sizeof g_text2 - 1, "")
			format(g_text1, sizeof g_text1 - 1, "%L", LANG_PLAYER, "MSG_WIN_ZOMBIE")
			fm_PlaySound(0, snd_win_zombie[random_num(0, sizeof snd_win_zombie - 1)])
		}
	}
	event_round_end()
}

public first_zombie(){
	if(g_round == round_zombie) return;
	if(get_zombies_num() > 0) return;
	new id = get_random_player(1,0)
	if (!(1 <= id <= g_maxplayers) || !is_user_alive(id) || id == g_ctbot || id == g_tbot){
		remove_task(TASK_FIRST_ZOMBIE,0)
		set_task(1.0,"first_zombie",TASK_FIRST_ZOMBIE)
		return;
	}
	for(new i = 1;i <= g_maxplayers + 1; i++)
		if (is_user_alive(i) && get_user_team(i) == 2 && i != id && i != g_ctbot && i != g_tbot )
			fm_set_user_team(i,CS_TEAM_T)
	g_round = round_zombie
	if(pev_valid(g_ctbot))
		engfunc(EngFunc_SetClientKeyValue, g_ctbot, engfunc(EngFunc_GetInfoKeyBuffer, g_ctbot), "name", team_names[1])
	if(pev_valid(g_tbot))
		engfunc(EngFunc_SetClientKeyValue, g_tbot, engfunc(EngFunc_GetInfoKeyBuffer, g_tbot), "name", team_names[0])
	new name[24]
	get_user_name(id, name, 23)
	format(g_text3, sizeof g_text3 - 1, "%s", g_text2)
	format(g_text2, sizeof g_text2 - 1, "%s", g_text1)
	format(g_text1, sizeof g_text1 - 1, "%L", LANG_PLAYER, msg_first_zombie[random_num(0, sizeof msg_first_zombie - 1)])
	replace(g_text1, sizeof g_text1 - 1, "$name", name)
	ckrun_set_user_zombie(id)
	fm_set_user_health(id, get_user_health(id) * 2)
}
public client_putinserver(id){
	ckrun_reset_user_var(id)
	ckrun_reset_user_knife(id)
	if(!gzombie[id]){
		gzombie[id] = random_num(1,5)
		gwillbezombie[id] = gzombie[id]
	}
	if(!ghuman[id]){
		ghuman[id] = random_num(1,6)
		gwillbehuman[id] = ghuman[id]
	}
	client_cmd(id, "cl_minmodels 0")
	client_cmd(id, "cl_shadows 1")
	set_task(HUD_REFRESH, "ckrun_showhud_status", id+TASK_SHOWHUD)
	set_task(CENTER_REFRESH, "ckrun_showhud_center", id+TASK_SHOWCENTER)
	set_task(PLAYER_THINK, "think_Player", id+TASK_PLAYER_THINK)
}
public client_connect(id){
	set_task(1.0, "funcLoadAll", id+TASK_LOADALL)
	if(!glogmode[id]) glogmode[id] = 1
	if(!gengmode[id]) gengmode[id] = 1
	gkill[id] = 0
	gdeath[id] = 0
	g_roundkill[id] = 0
	g_rounddeath[id] = 0
	g_zspawned[id] = false
	//if(!is_user_bot(id)) client_cmd(id , "bind ^"v^" ^"say !zmenu^"")
}

public client_disconnect(id){
	if(!is_user_bot(id)){
		funcSaveAll(id)
		remove_task(id+TASK_AMBIENCE_SOUND,0)
		client_cmd(id, "mp3 stop; stopsound")
	}
	gkill[id] = 0
	gdeath[id] = 0
	g_zspawned[id] = false
	set_task(0.5, "check_end")
}
public fw_jump(id){
	if(!is_user_alive(id))
		return HAM_IGNORED
	new buttons = pev(id, pev_button)
	new flags = pev(id, pev_flags)
	new Float:velocity[3]
	pev(id, pev_velocity, velocity)
	//增加跳跃
	if(!gjumping[id] && !(flags & FL_ONGROUND)){
		if(giszm[id])
			switch(gzombie[id]){
				case 1:velocity[2] += float(get_pcvar_num(cvar_zm_fast_jump))
				case 2:velocity[2] += float(get_pcvar_num(cvar_zm_gravity_jump))
				case 3:velocity[2] += float(get_pcvar_num(cvar_zm_classic_jump))
				case 4:velocity[2] += float(get_pcvar_num(cvar_zm_jump_jump))
				case 5:velocity[2] += float(get_pcvar_num(cvar_zm_invis_jump))
			}
		set_pev(id, pev_velocity, velocity)
		if(buttons & IN_DUCK)
			zombie_skill_longjump_effect(id)
		gcansecondjump[id] = false
		gjumping[id] = true
	}
	//二段跳
	if(gjumping[id] && !gsecondjump[id] && gcansecondjump[id] && (buttons & IN_JUMP)){
		if(!giszm[id] && ghuman[id] == human_scout){
			new Float:targetOrigin[3], Float:id_origin[3], Float:fw, Float:rg
			pev(id, pev_origin, id_origin)
			if (buttons & IN_FORWARD){//和BACK不会同时运行
				fw += 100.0
			}else if (buttons & IN_BACK){
				fw -= 100.0
			}if (buttons & IN_MOVELEFT){
				rg -= 100.0
			}else if (buttons & IN_MOVERIGHT){
				rg += 100.0
			}
			ckrun_get_user_startpos(id, fw, rg, 0.0, targetOrigin)
			if(rg == 0.0 && fw == 0.0){
				velocity[0] = 0.0
				velocity[1] = 0.0
			} else {
				get_speed_vector(id_origin, targetOrigin, float(gcurspeed[id]), velocity)
			}
			velocity[2] = 256.0
			set_pev(id, pev_velocity, velocity)
			gsecondjump[id] = true
			gcansecondjump[id] = false
		}
	}
	return HAM_IGNORED
}

public fw_CmdStart(id, uc_handle, seed){
	if(!is_user_alive(id))
		return FMRES_IGNORED
	new wpn = get_user_weapon(id)
	new buttons = get_uc(uc_handle, UC_Buttons)
	new oldbuttons = pev(id, pev_oldbuttons)
	if(gfrozen[id]){
		buttons &= ~IN_ATTACK
		buttons &= ~IN_ATTACK2
		set_uc(uc_handle, UC_Buttons, buttons)
	}
	if(wpn == CSW_C4){
		switch(ghuman[id]){//动画修复
			case human_rpg:{
				if(buttons & IN_ATTACK)
					if(grpgready[id])
						rocket_fire(id)
				if(buttons & IN_ATTACK2)
					if(grpgready[id] && grpgrepeat[id] == 0)
						rocket_repeat(id)
				if((buttons & IN_RELOAD) || grpgclip[id] == 0)
					rocket_reload(id)
			}
			case human_log:{
				if(buttons & IN_ATTACK){
					new target, bodypart
					get_user_aiming(id, target, bodypart)
					if(is_user_alive(target)){
						new Float:id_origin[3], Float:target_origin[3]
						pev(id, pev_origin, id_origin)
						pev(target, pev_origin, target_origin)
						new Float:distance = vector_distance(id_origin,target_origin)
						if(distance <= 256.0){
							if(glogmode[id] == 1 && !gmedicing[id] && !giszm[target]){
								gmedictarget[id] = target
								gmedicing[id] = true
								engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_medic_heal, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
								remove_task(id+TASK_MEDIC,0)
								set_task(0.1, "log_medic", id+TASK_MEDIC)
							}else if(glogmode[id] == 2 && !gammoing[id] && !giszm[target]){
								gammotarget[id] = target
								gammoing[id] = true
								engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_medic_heal, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
								remove_task(id+TASK_AMMOSUPPLY,0)
								set_task(0.1, "log_ammo", id+TASK_AMMOSUPPLY)
							}
						}
					}
				}
				if((buttons & IN_ATTACK2) && !(oldbuttons & IN_ATTACK2)){
					log_changemode(id)
				}
			}
			case human_eng:{
				if((buttons & IN_ATTACK2) && !(oldbuttons & IN_ATTACK2))
					eng_changemode(id)
			}
		}
	} else if(wpn == CSW_M249){
		if(buttons & IN_ATTACK){
			switch(gminigun_spin[id]){
				case minigun_idle:{
					buttons &= ~IN_ATTACK
					set_uc(uc_handle, UC_Buttons, buttons)
				}
				case minigun_spinup:{
					buttons &= ~IN_ATTACK
					set_uc(uc_handle, UC_Buttons, buttons)
				}
				case minigun_spindown:{
					buttons &= ~IN_ATTACK
					set_uc(uc_handle, UC_Buttons, buttons)
				}
			}
		}
		if(buttons & IN_ATTACK2){
			switch(gminigun_spin[id]){
				case minigun_idle:{
					gminigun_spin[id] = minigun_spinup
					gspindelay[id] = get_gametime() + get_pcvar_float(cvar_wpn_minigun_spinup)
					fm_set_user_anim(id, anim_m249_spinup)
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_minigun_spinup, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
				case minigun_spinup:{
					if(gspindelay[id] < get_gametime()){
						gminigun_spin[id] = minigun_spining
						fm_set_user_anim(id, anim_m249_spining)
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_minigun_spining, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
				}
				case minigun_spindown:{
					if(gspindelay[id] < get_gametime()){
						gminigun_spin[id] = minigun_idle
						fm_set_user_anim(id, anim_m249_idle)
					}
				}
				case minigun_spining:{
					if(gspindelay[id] < get_gametime()){
						gminigun_spin[id] = minigun_spining
						gspindelay[id] = get_gametime() + get_pcvar_float(cvar_wpn_minigun_spining)
						fm_set_user_anim(id, anim_m249_idle)
						fm_set_user_anim(id, anim_m249_spining)
						engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_minigun_spining, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
				}
			}
		}
	} else if(giszm[id]){
		if ((buttons & IN_ATTACK) && (buttons & IN_ATTACK2)){//左右键同时按下
			if(giszm[id]) zombie_skill(id)
		}
		if(giszm[id] && gzombie[id] == zombie_invis){
			if(gdisguising[id]){
				if(buttons & IN_ATTACK){
					buttons &= ~IN_ATTACK
					set_uc(uc_handle, UC_Buttons, buttons)
				}
				if(buttons & IN_ATTACK2){
					if(gskill_ready[id] && !gstabing[id]){
						fm_set_user_anim(id, 5)
						buttons &= ~IN_ATTACK2
						set_uc(uc_handle, UC_Buttons, buttons)
						gstabing[id] = true
						set_task(0.5, "zombie_stab",id+TASK_STABDELAY)
					} else {
						buttons &= ~IN_ATTACK2
						set_uc(uc_handle, UC_Buttons, buttons)
					}
				}
			} else if (ginvisible[id]){
				if(buttons & IN_ATTACK){
					buttons &= ~IN_ATTACK
					set_uc(uc_handle, UC_Buttons, buttons)
					fm_set_user_anim(id, 0)
				}
				if(buttons & IN_ATTACK2){
					buttons &= ~IN_ATTACK2
					set_uc(uc_handle, UC_Buttons, buttons)
					fm_set_user_anim(id, 0)
					zombie_invisible(id)
				}
			} else if (gstabing[id]){
				if(buttons & IN_ATTACK){
					buttons &= ~IN_ATTACK
					set_uc(uc_handle, UC_Buttons, buttons)
				}
				if(buttons & IN_ATTACK2){
					buttons &= ~IN_ATTACK2
					set_uc(uc_handle, UC_Buttons, buttons)
				}
			} else {
				if(buttons & IN_ATTACK2){
					buttons &= ~IN_ATTACK2
					set_uc(uc_handle, UC_Buttons, buttons)
					fm_set_user_anim(id, 0)
					zombie_invisible(id)
				}
			}
		}
	}
	return FMRES_IGNORED
}
public fw_PreThink(id){
	if(!is_user_alive(id)) return;
	if(id == g_ctbot || id == g_tbot) return;
	new buttons = pev(id, pev_button)
	new flags = pev(id, pev_flags)
	set_pev(id, pev_maxspeed, float(gcurspeed[id]))//保持移动速度
	if (gfrozen[id] > 0){
		set_pev(id, pev_velocity, Float:{0.0,0.0,0.0})
		set_pev(id, pev_maxspeed, 1.0)
	}
	if(flags & FL_ONGROUND){
		gjumping[id] = false
		gsecondjump[id] = false
		gcansecondjump[id] = false
		g_ach_rocketjump[id] = false
	}
	if(gjumping[id]){
		if(!(buttons & IN_JUMP) && !gcansecondjump[id])
			gcansecondjump[id] = true
	}
	if(ghuman[id] == human_heavy && !giszm[id]){
		new wpn = get_user_weapon(id)
		if(wpn != CSW_M249){
			gminigun_spin[id] = minigun_idle;
		} else if(!(buttons & IN_ATTACK2)){
			switch(gminigun_spin[id]){
				case minigun_spining:{
					gminigun_spin[id] = minigun_spindown
					gspindelay[id] = get_gametime() + get_pcvar_float(cvar_wpn_minigun_spindown)
					fm_set_user_anim(id, anim_m249_spindown)
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_minigun_spindown, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
				case minigun_spinup:{
					if(gspindelay[id] < get_gametime()){
						gminigun_spin[id] = minigun_spindown
						gspindelay[id] = get_gametime() + get_pcvar_float(cvar_wpn_minigun_spindown)
						fm_set_user_anim(id, anim_m249_spindown)
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_minigun_spindown, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
				}
				case minigun_spindown:{
					if(gspindelay[id] < get_gametime()){
						gminigun_spin[id] = minigun_idle
						fm_set_user_anim(id, anim_m249_idle)
					}
				}
			}

		}
	} else if(giszm[id] && gzombie[id] == zombie_fast){
		if(!moonslash_check(id)) return
		if(!(buttons & IN_ATTACK) || !(buttons & IN_ATTACK2)){
			moonslash_cancel(id)
			return;
		}
		if(gmoonslash_slash[id]) gmoonslash_slash[id] = 0
		moonslash_neartarget(id)
		if(gmoonslash_blink[id]){
			moonslash_setblink(id)
			moonslash_blink(id)
			gmoonslash_canceled[id] = 0;
		}
	}
}
public log_changemode(id){
	if(pev(id,pev_button) & IN_ATTACK){
		log_charge(id)
		return;
	}
	if(gcharge_shield[id] || gcharge_crit[id]) return;//电荷启动后不能换模式
	switch(glogmode[id]){
		case 1:{
			glogmode[id] = 2
			set_pev(id, pev_viewmodel2, mdl_v_ammopack)
			set_pev(id, pev_weaponmodel2, mdl_p_ammopack)
			engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, "items/gunpickup3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		}
		case 2:{
			glogmode[id] = 1
			set_pev(id, pev_viewmodel2, mdl_v_medicgun)
			set_pev(id, pev_weaponmodel2, mdl_p_medicgun)
			engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, "items/gunpickup3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		}
	}
	gammoing[id] = false
	gmedicing[id] = false
	gmediced[gmedictarget[id]] = 0
	gammoed[gammotarget[id]] = 0
	ckrun_showhud_status(id)
}
public eng_changemode(id){
	if(pev(id, pev_button) & IN_ATTACK) return;
	switch(gengmode[id]){
		case 1:{
			gengmode[id] = 2
			set_pev(id, pev_viewmodel2, mdl_v_pda)
			set_pev(id, pev_weaponmodel2, mdl_p_pda)
			engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, "items/gunpickup3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		}
		case 2:{
			gengmode[id] = 1
			set_pev(id, pev_viewmodel2, mdl_v_toolbox)
			set_pev(id, pev_weaponmodel2, mdl_p_toolbox)
			engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, "items/gunpickup3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		}
	}
	ckrun_showhud_status(id)
}

public log_medic(taskid){
	static id
	if(taskid > g_maxplayers)
		id = ID_MEDIC
	else
		id = taskid
	new buttons = pev(id, pev_button)
	new target = gmedictarget[id]
	if(!gmedicing[id]) return;
	if(!is_user_alive(id) || !is_user_alive(target) || gpower[id] < 1 || glogmode[id] != 1){
		gmedicing[id] = false
		gmediced[target] = 0
		return
	}
	if(get_user_weapon(id) != CSW_C4){
		gmedicing[id] = false
		gmediced[target] = 0
		return
	}
	if(!(buttons & IN_ATTACK)){
		gmedicing[id] = false
		gmediced[target] = 0
		return
	}
	if(giszm[id] || giszm[target]){
		gmedicing[id] = false
		gmediced[target] = 0
		return
	}
	if(gmediced[target] != 0 && gmediced[target] != id){
		gmedicing[id] = false
		return
	}
	if(gammoed[target] != 0 && gammoed[target] != id){
		gmedicing[id] = false
		return
	}
	if (gcharge_shield[id])
		fm_set_rendering(target,kRenderFxGlowShell,250,125,0, kRenderNormal, 24)
	else
		fm_set_rendering(target,kRenderFxGlowShell,200,0,0, kRenderNormal, 8)
	new idorigin[3],targetorigin[3]
	get_user_origin(id,idorigin)
	get_user_origin(target,targetorigin)
	new distance = get_distance(idorigin, targetorigin)
	if(distance > 314){
		gmedicing[id] = false
		gmediced[target] = 0
		return
	}
	gmediced[target] = id
	gcharge[id] += get_pcvar_num(cvar_wpn_medic_charge)
	new maxhealth = ckrun_get_user_maxhealth(target)
	maxhealth = maxhealth * get_pcvar_num(cvar_wpn_medic_maxhealth) / 100
	if(get_user_health(target) + get_pcvar_num(cvar_wpn_medic_heal) <= maxhealth){
		fm_set_user_health(gmedictarget[id],get_user_health(target) + get_pcvar_num(cvar_wpn_medic_heal))
		gpower[id] -= get_pcvar_num(cvar_wpn_medic_power)
		gcharge[id] += get_pcvar_num(cvar_wpn_medic_charge)
	} else if((get_user_health(gmedictarget[id])+ get_pcvar_num(cvar_wpn_medic_heal) > maxhealth) && (get_user_health(target) < maxhealth)){
		fm_set_user_health(gmedictarget[id],maxhealth)
		gpower[id] -= get_pcvar_num(cvar_wpn_medic_power)
	}
	if(gcharge[id] > 1000)
		gcharge[id] = 1000
	FX_Healbeam(id, target, 225, 25, 25, 2)
	ckrun_showhud_status(target)
	remove_task(id+TASK_MEDIC,0)
	set_task(0.1,"log_medic", id+TASK_MEDIC)
}

public log_ammo(taskid){
	static id
	if(taskid > g_maxplayers)
		id = ID_AMMOSUPPLY
	else
		id = taskid
	if(!gammoing[id]) return;
	new buttons = pev(id, pev_button)
	new target = gammotarget[id]
	if(!is_user_alive(id) || !is_user_alive(target) || glogammo[id] < 0 || glogmode[id] != 2){
		gammoing[id] = false
		gammoed[target] = 0
		gcritical_on[target] = false
		return
	}
	if(get_user_weapon(id) != CSW_C4){
		gmedicing[id] = false
		gmediced[target] = 0
		gcritical_on[target] = false
		return
	}
	if(!(buttons & IN_ATTACK)){
		gammoing[id] = false
		gammoed[target] = 0
		gcritical_on[target] = false
		return
	}
	if(giszm[id] || giszm[target]){
		gammoing[id] = false
		gammoed[target] = 0
		gcritical_on[target] = false
		return
	}
	if(gmediced[target] != 0 && gmediced[target] != id){
		gammoing[id] = false
		gcritical_on[target] = false
		return
	}
	if(gammoed[target] != 0 && gammoed[target] != id){
		gammoing[id] = false
		gcritical_on[target] = false
		return
	}
	if (gcharge_crit[id]){
		gcritical_on[target] = true
		fm_set_rendering(target,kRenderFxGlowShell,0,125,250, kRenderNormal, 24)
	} else {
		fm_set_rendering(target,kRenderFxGlowShell,0,0,200, kRenderNormal, 8)
	}
	new idorigin[3],targetorigin[3]
	get_user_origin(id,idorigin)
	get_user_origin(target,targetorigin)
	new distance = get_distance(idorigin, targetorigin)
	if(distance > 314){
		gammoing[id] = false
		gammoed[target] = 0
		return
	}
	remove_task(id+TASK_AMMOSUPPLY,0)
	set_task(0.1,"log_ammo", id+TASK_AMMOSUPPLY)
	gammoed[target] = id
	if(ckrun_give_user_ammo(target,get_pcvar_num(cvar_wpn_ammopack_percent)) && glogammo[id] > 0){//给弹药-超强函数...
		glogammo[id] --
		gpower[id] -= get_pcvar_num(cvar_wpn_ammopack_power)
		gcharge[id] += get_pcvar_num(cvar_wpn_ammopack_charge)
	}
	gcharge[id] += get_pcvar_num(cvar_wpn_ammopack_charge)
	if(gcharge[id] > 1000)
		gcharge[id] = 1000
	FX_Healbeam(id, target, 25, 25, 225, 2)
	ckrun_showhud_status(target)
}
public log_charge(id){
	if(!gmedicing[id] && !gammoing[id]) return;
	if(gcharge_shield[id] && gcharge_crit[id]) return;
	if(gcharge[id] < 1000) return;
	switch(glogmode[id]){
		case 1:	gcharge_shield[id] = true
		case 2:	gcharge_crit[id] = true
	}
	engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_charge_on, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	ckrun_showhud_status(id)
}

public funcLoadAll(taskid){
	static id
	if(taskid > g_maxplayers)
		id = taskid - TASK_LOADALL
	else
		id = taskid 
	if(!(get_user_flags(id) & ACCESS_VIP)) return

	new name[128];
	get_user_name(id, name, sizeof name - 1);

	new cfgdir[512], linedata[64], userdata[512]
	get_configsdir(cfgdir, sizeof cfgdir - 1);
	formatex(userdata, sizeof userdata - 1, "%s/chickenrun/user_data/%s_data.cfg", cfgdir, name);

	new zombie[8], human[8], model[8]
	new vach_fast_1[8], vach_fast_2[8], vach_fast_3[8], vach_fast_4[8], vach_fast_5[8], vach_fast_6[8]
	new vach_fast_7[8], vach_fast_8[8], vach_fast_9[8], vach_fast_10[8], vach_fast_11[8], vach_fast_12[8], vach_fast_13[8], vach_fast_14[8]

	if (file_exists(userdata)){
		new file = fopen(userdata,"rt")
		while (file && !feof(file)){
			fgets(file, linedata, sizeof linedata - 1);
			if(!linedata[0] || str_count(linedata,' ') < 2) continue;
			parse(linedata, zombie, 7, human, 7, model, 7, vach_fast_1, 7, vach_fast_2, 7, vach_fast_3, 7, vach_fast_4, 7, vach_fast_5, 7, vach_fast_6, 7,
			vach_fast_7, 7, vach_fast_8, 7, vach_fast_9, 7, vach_fast_10, 7, vach_fast_11, 7, vach_fast_12, 7, vach_fast_13, 7, vach_fast_14, 7);
		}
		if (file) fclose(file);
	}
	gzombie[id] = str_to_num(zombie);
	gwillbezombie[id] = gzombie[id]
	ghuman[id] = str_to_num(human);
	gwillbehuman[id] = ghuman[id]
	gmodel[id] = str_to_num(model);
	g_ach_fast[id][ach_fast_1] = str_to_num(vach_fast_1)
	g_ach_fast[id][ach_fast_2] = str_to_num(vach_fast_2)
	g_ach_fast[id][ach_fast_3] = str_to_num(vach_fast_3)
	g_ach_fast[id][ach_fast_4] = str_to_num(vach_fast_4)
	g_ach_fast[id][ach_fast_5] = str_to_num(vach_fast_5)
	g_ach_fast[id][ach_fast_6] = str_to_num(vach_fast_6)
	g_ach_fast[id][ach_fast_7] = str_to_num(vach_fast_7)
	g_ach_fast[id][ach_fast_8] = str_to_num(vach_fast_8)
	g_ach_fast[id][ach_fast_9] = str_to_num(vach_fast_9)
	g_ach_fast[id][ach_fast_10] = str_to_num(vach_fast_10)
	g_ach_fast[id][ach_fast_11] = str_to_num(vach_fast_11)
	g_ach_fast[id][ach_fast_12] = str_to_num(vach_fast_12)
	g_ach_fast[id][ach_fast_13] = str_to_num(vach_fast_13)
	g_ach_fast[id][ach_fast_14] = str_to_num(vach_fast_14)
}

public funcSaveAll(id) {
	if(!(get_user_flags(id) & ACCESS_VIP)) return

	new name[128];
	get_user_name(id, name, sizeof name - 1);

	new cfgdir[512], userdata[512]
	get_configsdir(cfgdir, sizeof cfgdir - 1);
	formatex(userdata, sizeof userdata - 1, "%s/chickenrun/user_data/%s_data.cfg", cfgdir, name);
	
	new data[512];

	formatex(data, sizeof data - 1, "%i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i", gzombie[id], ghuman[id], gmodel[id], g_ach_fast[id][ach_fast_1],
	g_ach_fast[id][ach_fast_2], g_ach_fast[id][ach_fast_3], g_ach_fast[id][ach_fast_4], g_ach_fast[id][ach_fast_5], g_ach_fast[id][ach_fast_6],
	g_ach_fast[id][ach_fast_7], g_ach_fast[id][ach_fast_8], g_ach_fast[id][ach_fast_9], g_ach_fast[id][ach_fast_10], g_ach_fast[id][ach_fast_11],
	g_ach_fast[id][ach_fast_12], g_ach_fast[id][ach_fast_13], g_ach_fast[id][ach_fast_14])
	

	if (file_exists(userdata)) delete_file(userdata)
	write_file(userdata, data, -1)
}


//------------捡起武器作为弹药补给---------//
public fw_TempItemTouch(entity, id){
	if (!(1 <= id <= g_maxplayers))
		return HAM_SUPERCEDE
	if(!is_user_alive(id))
		return HAM_IGNORED
	if(gpickedup[id])
		return HAM_SUPERCEDE
	new bool:pickedup = false
	new type = pev(entity, CKI_TYPE)
	new amount = pev(entity, CKI_PARM)
	switch(type){
		case CKI_TYPE_HEALTH:pickedup = ckrun_give_user_health(id, amount)
		case CKI_TYPE_AMMO:pickedup = ckrun_give_user_ammo(id, amount)
		case CKI_TYPE_BUGKILLER:{
			pickedup = true
			ckrun_fakedamage(id, id, CKW_BACKSTAB, 99999, CKD_PUNCH)
			new name[32]
			get_user_name(id, name, sizeof name - 1)
			client_print_colored(0, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_BUG_KILLER", name)
		}
		default:pickedup = ckrun_give_user_ammo(id, get_pcvar_num(cvar_supply_item_weapon))
	}
	if(pickedup){
		engfunc(EngFunc_EmitSound,id, CHAN_ITEM, "items/gunpickup3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		fm_remove_entity_safe(entity)
		ckrun_showhud_status(id)
		gpickedup[id] = true
		set_task(PICKUP_DELAY, "ckrun_pickedup_reset", id+TASK_PICKUP)
	}
	return HAM_SUPERCEDE
}
//------------捡起武器作为弹药补给---------//
//------------物品系统---------//
public fw_ItemTouch(entity, id){
	if (!(1 <= id <= g_maxplayers))
		return HAM_SUPERCEDE
	if(!is_user_alive(id))
		return HAM_IGNORED
	if(!fm_is_entity_visible(entity))
		return HAM_SUPERCEDE
	if(gpickedup[id])
		return HAM_SUPERCEDE
	new bool:pickedup = false
	new type = pev(entity, CKI_TYPE)
	new amount = pev(entity, CKI_PARM)
	switch(type){
		case CKI_TYPE_HEALTH:pickedup = ckrun_give_user_health(id, amount)
		case CKI_TYPE_AMMO:pickedup = ckrun_give_user_ammo(id, amount)
		case CKI_TYPE_BUGKILLER:{
			pickedup = true
			ckrun_fakedamage(id, id, CKW_BACKSTAB, 99999, CKD_PUNCH)
			new name[32]
			get_user_name(id, name, sizeof name - 1)
			client_print_colored(0, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_BUG_KILLER", name)
		}
		default:pickedup = ckrun_give_user_ammo(id, get_pcvar_num(cvar_supply_item_weapon))
	}
	if(pickedup){
		engfunc(EngFunc_EmitSound,id, CHAN_ITEM, "items/gunpickup3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		fm_set_entity_visible(entity , 0)
		gpickedup[id] = true
		set_task(PICKUP_DELAY, "ckrun_pickedup_reset", id+TASK_PICKUP)
		set_task(float(get_pcvar_num(cvar_global_supply_respawn)), "ckrun_respawn_item", entity)
		ckrun_showhud_status(id)
	}
	return HAM_SUPERCEDE
}
public fw_CpTouch(entity, id){
	if (!(1 <= id <= g_maxplayers))	return HAM_SUPERCEDE
	if(!is_user_alive(id)) return HAM_SUPERCEDE
	if(giszm[id]) return HAM_SUPERCEDE
	if(gcaptured[id]) return HAM_SUPERCEDE
	gcaptured[id] = true
	set_task(CAPTURE_DELAY, "ckrun_captured_reset", id+TASK_CAPTURED)
	new need = pev(entity, MAP_DISPATCH2)

	if(need > g_cp_local) return HAM_SUPERCEDE

	new cp_num = pev(entity, MAP_CPNUMS)
	new progress = g_cp_progress[cp_num]
	if(progress >= 1000) return HAM_SUPERCEDE
	new this = pev(entity, MAP_DISPATCH)
	new speed = pev(entity, MAP_DISPATCH3)
	if(progress + speed < 1000){
		g_cp_progress[cp_num] += speed
	} else {
		g_cp_progress[cp_num] = 1000
		g_cp_local += this
		check_end()
	}
	return HAM_SUPERCEDE
}
public fw_SupplyDoorTouch(entity, id){
	if(!(1 <= id <= g_maxplayers)) return HAM_SUPERCEDE
	if(!is_user_alive(id)) return HAM_SUPERCEDE
	if(!giszm[id]) return HAM_SUPERCEDE
	return HAM_IGNORED
}
public ckrun_captured_reset(taskid){
	static id
	if(taskid > g_maxplayers)
		id = taskid - TASK_CAPTURED
	else
		id = taskid
	if (!is_user_alive(id)) return;
	remove_task(id+TASK_CAPTURED, 0)
	gcaptured[id] = false
}
public ckrun_pickedup_reset(taskid){
	static id
	if(taskid > g_maxplayers)
		id = taskid - TASK_PICKUP
	else
		id = taskid
	if (!is_user_alive(id)) return;
	remove_task(id+TASK_PICKUP,0)
	gpickedup[id] = false
}
public ckrun_respawn_item(entity){
	if (!pev_valid(entity))	return;
	fm_set_entity_visible(entity , 1)
}
//------------捡起弹药盒作为弹药补给---------//
public block_drop(id){
	return PLUGIN_HANDLED
}
public block_use(){
	return HAM_SUPERCEDE
}
public fw_EntitySpawn(entity){
	if (!pev_valid(entity))
		return FMRES_IGNORED
	static classname[32]
	pev(entity, pev_classname, classname, sizeof classname - 1)

	static i
	for (i = 0; i < sizeof g_load_remove; i++){
		if (equal(classname, g_load_remove[i])){
			engfunc(EngFunc_RemoveEntity, entity)
			return FMRES_SUPERCEDE
		}
	}
	return FMRES_IGNORED
}
public fw_KeyValue(i_Entid, i_Kvdid){
	if(!pev_valid(i_Entid)) return FMRES_IGNORED;
	new s_KeyName[32], s_KeyValue[32]
	get_kvd (i_Kvdid, KV_KeyName, s_KeyName, sizeof s_KeyName - 1);
	get_kvd (i_Kvdid, KV_Value, s_KeyValue, sizeof s_KeyValue - 1);
	if(equal(s_KeyName, "map_dispatch")){
		set_pev(i_Entid, MAP_DISPATCH, str_to_num(s_KeyValue))
	} else if(equal(s_KeyName, "map_dispatch2")){
		set_pev(i_Entid, MAP_DISPATCH2, str_to_num(s_KeyValue))
	} else if(equal(s_KeyName, "map_dispatch3")){
		set_pev(i_Entid, MAP_DISPATCH3, s_KeyValue)
	} else if(equal(s_KeyName, "map_obj")){
		if(equal(s_KeyValue, "capture") && g_cp_pointnums < CP_MAXPOINTS - 1)
			init_CapturePoint(i_Entid)
		else if(equal(s_KeyValue, "supplydoor"))
			init_SupplyDoor(i_Entid)
		//else if (equal(s_KeyValue, "ctflag"))
		//	init_CTFlag(i_Entid)
		//else if (equal(s_KeyValue, "payload"))
		//	init_Payload(i_Entid)
	}
	return FMRES_IGNORED;
}
//其他//
stock drop_weapons(id, dropwhat){
	static weapons[32], num, i
	num = 0 // reset passed weapons count (bugfix)
	get_user_weapons(id, weapons, num)
	for (i = 0; i < num; i++){
		if ((dropwhat == 1 && ((1<<weapons[i]) & PRIMARY_WEAPONS)) || (dropwhat == 2 && ((1<<weapons[i]) & SECONDARY_WEAPONS))){
			static wname[32]
			get_weaponname(weapons[i], wname, sizeof wname - 1)
			engclient_cmd(id, "drop", wname)
		}
	}
	if(dropwhat == 5){
		if(!giszm[id]){
			new Float:origin[3], parm[4]
			pev(id, pev_origin, origin)
			ckrun_FVecIVec(origin, parm)
			switch(ghuman[id]){
				case 3:parm[3] = CKI_RPG
				case 5:parm[3] = CKI_MEDICGUN
				case 6:parm[3] = CKI_TOOLBOX
				default: parm[3] = 0//你哪来的包?..
			}
			ckrun_create_item_temp(parm)
		}
	}
}
public ckrun_strip_user_weapons(taskid){
	new id = taskid
	if(!is_user_alive(id)) return;
	fm_strip_user_weapons(id)
	fm_give_item(id,"weapon_knife")
}
stock ham_strip_weapon(id,weapon[]){
	if(!equal(weapon,"weapon_",7)) return 0;
	new wId = get_weaponid(weapon);
	if(!wId) return 0;
	new wEnt;
	while((wEnt = engfunc(EngFunc_FindEntityByString,wEnt,"classname",weapon)) && pev(wEnt,pev_owner) != id) {}
	if(!wEnt) return 0;
	if(get_user_weapon(id) == wId) ExecuteHamB(Ham_Weapon_RetireWeapon,wEnt);
	if(!ExecuteHamB(Ham_RemovePlayerItem,id,wEnt)) return 0;
	ExecuteHamB(Ham_Item_Kill,wEnt);
	set_pev(id,pev_weapons,pev(id,pev_weapons) & ~(1<<wId));
	return 1;
}
stock ham_get_wpnentity(id, wpnid){
	new weapon[32]
	get_weaponname(wpnid,weapon,31)
	new wEnt;
	while((wEnt = engfunc(EngFunc_FindEntityByString,wEnt,"classname",weapon)) && pev(wEnt,pev_owner) != id) {}
	if(!pev_valid(wEnt)) return 0;
	return wEnt
}
//---------实体是否被隐藏--------//
stock is_entity_hidden(entity){
	if(pev(entity,pev_renderamt) == 0.0 && pev(entity,pev_rendermode) == kRenderTransTexture)
		return true

	return false;
}
// fakemeta
stock fm_set_user_health(id, health){
	(health > 0) ? set_pev(id, pev_health, float(health)) : dllfunc(DLLFunc_ClientKill, id);
}

stock fm_set_user_anim(id, anim){
	set_pev(id, pev_weaponanim, anim)
	message_begin(MSG_ONE, SVC_WEAPONANIM, {0, 0, 0}, id)
	write_byte(anim)
	write_byte(pev(id, pev_body))
	message_end()
}
stock fm_set_user_bpammo(id, wpn, ammo){
	static offset
	switch(wpn){
		case CSW_AWP: offset = OFFSET_AWM_AMMO;
		case CSW_SCOUT,CSW_AK47,CSW_G3SG1: offset = OFFSET_SCOUT_AMMO;
		case CSW_M249: offset = OFFSET_PARA_AMMO;
		case CSW_M4A1,CSW_FAMAS,CSW_AUG,CSW_SG550,CSW_GALI,CSW_SG552: offset = OFFSET_FAMAS_AMMO;
		case CSW_M3,CSW_XM1014: offset = OFFSET_M3_AMMO;
		case CSW_USP,CSW_UMP45,CSW_MAC10: offset = OFFSET_USP_AMMO;
		case CSW_FIVESEVEN,CSW_P90: offset = OFFSET_FIVESEVEN_AMMO;
		case CSW_DEAGLE: offset = OFFSET_DEAGLE_AMMO;
		case CSW_P228: offset = OFFSET_P228_AMMO;
		case CSW_GLOCK18,CSW_MP5NAVY,CSW_TMP,CSW_ELITE: offset = OFFSET_GLOCK_AMMO;
		case CSW_FLASHBANG: offset = OFFSET_FLASH_AMMO;
		case CSW_HEGRENADE: offset = OFFSET_HE_AMMO;
		case CSW_SMOKEGRENADE: offset = OFFSET_SMOKE_AMMO;
		case CSW_C4: offset = OFFSET_C4_AMMO;
		default: return;
	}
	set_pdata_int(id, offset, ammo, OFFSET_LINUX)
}
stock fm_get_user_bpammo(id, wpn){
	static offset

	switch(wpn){
		case CSW_AWP: offset = OFFSET_AWM_AMMO;
		case CSW_SCOUT,CSW_AK47,CSW_G3SG1: offset = OFFSET_SCOUT_AMMO;
		case CSW_M249: offset = OFFSET_PARA_AMMO;
		case CSW_M4A1,CSW_FAMAS,CSW_AUG,CSW_SG550,CSW_GALI,CSW_SG552: offset = OFFSET_FAMAS_AMMO;
		case CSW_M3,CSW_XM1014: offset = OFFSET_M3_AMMO;
		case CSW_USP,CSW_UMP45,CSW_MAC10: offset = OFFSET_USP_AMMO;
		case CSW_FIVESEVEN,CSW_P90: offset = OFFSET_FIVESEVEN_AMMO;
		case CSW_DEAGLE: offset = OFFSET_DEAGLE_AMMO;
		case CSW_P228: offset = OFFSET_P228_AMMO;
		case CSW_GLOCK18,CSW_MP5NAVY,CSW_TMP,CSW_ELITE: offset = OFFSET_GLOCK_AMMO;
		case CSW_FLASHBANG: offset = OFFSET_FLASH_AMMO;
		case CSW_HEGRENADE: offset = OFFSET_HE_AMMO;
		case CSW_SMOKEGRENADE: offset = OFFSET_SMOKE_AMMO;
		case CSW_C4: offset = OFFSET_C4_AMMO;
		case CKW_RPG: return grpgammo[id]
		case CKW_SENTRY: return gsentry_ammo[id]
		default: return -1;
	}
	return get_pdata_int(id, offset, OFFSET_LINUX);
}
stock fm_get_user_weapon_entity(id, wid = 0) {
	new weap = wid, clip, ammo;
	if (!weap && !(weap = get_user_weapon(id, clip, ammo)))
		return 0;
	
	new class[32];
	get_weaponname(weap, class, sizeof class - 1);

	return fm_find_ent_by_owner(-1, class, id);
}
stock fm_find_ent_by_owner(index, const classname[], owner, jghgtype = 0) {
	new strtype[11] = "classname", ent = index;
	switch (jghgtype) {
		case 1: strtype = "target";
		case 2: strtype = "targetname";
	}

	while ((ent = engfunc(EngFunc_FindEntityByString, ent, strtype, classname)) && pev(ent, pev_owner) != owner) {}

	return ent;
}
stock fm_set_user_model(id, const modelname[]){
	engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "model", modelname)
}
stock fm_get_user_model(id, model[], len){
	return engfunc(EngFunc_InfoKeyValue, engfunc(EngFunc_GetInfoKeyBuffer, id), "model", model, len)
}
stock fm_set_user_team(id, team){
	set_pdata_int(id, OFFSET_CSTEAMS, team)
	dllfunc(DLLFunc_ClientUserInfoChanged, id, engfunc(EngFunc_GetInfoKeyBuffer, id) )
	message_begin(MSG_ALL, g_msgTeamInfo)
	write_byte(id)
	write_string(CS_Teams[team])
	message_end()
}  
stock fm_set_user_money(index, money, show = false){
	set_pdata_int(index, OFFSET_CSMONEY, money);
	if(show){
		message_begin(MSG_ONE, get_user_msgid("Money"), {0,0,0}, index);
		write_long(money);
		write_byte(1);
		message_end();
	}
}
stock fm_get_user_team(id){
	return get_pdata_int(id, 139, 5);
}
stock fm_get_user_deaths(id){
	return get_pdata_int(id, 493, 5);
}
stock fm_set_user_deaths(id, value){
	set_pdata_int(id, 493, value, 5);
}
stock fm_set_kvd(entity, const key[], const value[], const classname[]){
	set_kvd(0, KV_ClassName, classname);
	set_kvd(0, KV_KeyName, key);
	set_kvd(0, KV_Value, value);
	set_kvd(0, KV_fHandled, 0);

	dllfunc(DLLFunc_KeyValue, entity, 0);
}
stock fm_set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16) {
	new Float:RenderColor[3];
	RenderColor[0] = float(r);
	RenderColor[1] = float(g);
	RenderColor[2] = float(b);

	set_pev(entity, pev_renderfx, fx);
	set_pev(entity, pev_rendercolor, RenderColor);
	set_pev(entity, pev_rendermode, render);
	set_pev(entity, pev_renderamt, float(amount));

	return 1;
}
stock fm_set_entity_visible(index, visible) {
	set_pev(index, pev_effects, visible == 1 ? pev(index, pev_effects) & ~EF_NODRAW : pev(index, pev_effects) | EF_NODRAW);
	return 1;
}

stock fm_trace_line(ignoreent, const Float:start[3], const Float:end[3], Float:ret[3]){
	engfunc(EngFunc_TraceLine, start, end, ignoreent == -1 ? 1 : 0, ignoreent, 0);

	new ent = get_tr2(0, TR_pHit);
	get_tr2(0, TR_vecEndPos, ret);

	return pev_valid(ent) ? ent : 0;
}
stock fm_strip_user_weapons(id){
	static ent
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "player_weaponstrip"))
	if (!pev_valid(ent)) return;
	
	dllfunc(DLLFunc_Spawn, ent)
	dllfunc(DLLFunc_Use, ent, id)
	engfunc(EngFunc_RemoveEntity, ent)
}
stock fm_give_item(id, const item[]){
	static ent
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, item));
	if (!pev_valid(ent)) return;
	
	static Float:originF[3]
	pev(id, pev_origin, originF);
	set_pev(ent, pev_origin, originF);
	set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN);
	dllfunc(DLLFunc_Spawn, ent);
	
	static save
	save = pev(ent, pev_solid);
	dllfunc(DLLFunc_Touch, ent, id);
	if (pev(ent, pev_solid) != save)
		return;
	
	engfunc(EngFunc_RemoveEntity, ent);
}
stock Float:fm_distance_to_box(const Float:point[3], const Float:mins[3], const Float:maxs[3]){
	new Float:dist[3];
	for (new i = 0; i < 3; ++i) {
		if (point[i] > maxs[i])
			dist[i] = point[i] - maxs[i];
		else if (mins[i] > point[i])
			dist[i] = mins[i] - point[i];
	}

	return vector_length(dist);
}
stock Float:fm_distance_to_boxent(entity, boxent){
	new Float:point[3];
	pev(entity, pev_origin, point);

	new Float:mins[3], Float:maxs[3];
	pev(boxent, pev_absmin, mins);
	pev(boxent, pev_absmax, maxs);

	return fm_distance_to_box(point, mins, maxs);
}

stock fm_get_aim_origin(index, Float:origin[3]) {
	new Float:start[3], Float:view_ofs[3];
	pev(index, pev_origin, start);
	pev(index, pev_view_ofs, view_ofs);
	xs_vec_add(start, view_ofs, start);

	new Float:dest[3];
	pev(index, pev_v_angle, dest);
	engfunc(EngFunc_MakeVectors, dest);
	global_get(glb_v_forward, dest);
	xs_vec_mul_scalar(dest, 9999.0, dest);
	xs_vec_add(start, dest, dest);

	engfunc(EngFunc_TraceLine, start, dest, 0, index, 0);
	get_tr2(0, TR_vecEndPos, origin);

	return 1;
}
stock fm_set_weapon_ammo(entity, amount){
	set_pdata_int(entity, OFFSET_CLIPAMMO, amount, OFFSET_LINUX_WEAPONS)
}

stock fm_get_weapon_ammo(entity){
	return get_pdata_int(entity, OFFSET_CLIPAMMO, OFFSET_LINUX_WEAPONS);
}
stock bool:fm_is_entity_visible(entity){
	if ((pev(entity, pev_effects) & EF_NODRAW))
		return false
	return true
}
stock fm_remove_entity_safe(entity){
	if(!pev_valid(entity)) return;
	set_pev(entity, pev_flags, pev(entity, pev_flags) | FL_KILLME)
	dllfunc(DLLFunc_Think, entity)
}

#define fm_point_contents(%1) engfunc(EngFunc_PointContents, %1)
#define fm_DispatchSpawn(%1) dllfunc(DLLFunc_Spawn, %1)
stock fm_PlaySound(id, const snd[]) {
	client_cmd(id, "spk ^"%s^"", snd)
}
public message_health(msg_id, msg_dest, msg_entity){
	static health
	health = get_msg_arg_int(1) // get health
	
	if (health < 256) return; // dont bother
	
	if (floatfract(float(health)/256.0) == 0.0)
		fm_set_user_health(msg_entity, health-1)
	
	set_msg_arg_int(1, get_msg_argtype(1), 255)
}
public message_Status(iMsgId, msg_dest, id){
	return PLUGIN_HANDLED
}
public message_money(msg_id, msg_dest, id){
	set_pdata_int(id, 140, 0, 5)
	return PLUGIN_HANDLED
}
public message_hideweapon(){
	set_msg_arg_int(1, get_msg_argtype(1), get_msg_arg_int(1) | (1<<5));
}
public message_textmsg(){ 
	static textmsg[32]
	get_msg_arg_string(2, textmsg, sizeof textmsg - 1)
	if (equal(textmsg, "#Hostages_Not_Rescued") || equal(textmsg, "#Round_Draw") || 
	equal(textmsg, "#Terrorists_Win") || equal(textmsg, "#CTs_Win") || 
	equal(textmsg, "#C4_Arming_Cancelled") || equal(textmsg, "#C4_Plant_At_Bomb_Spot") || 
	equal(textmsg, "#Killed_Hostage") || equal(textmsg, "#Game_will_restart_in") )
		return PLUGIN_HANDLED
	return PLUGIN_CONTINUE
}
public message_saytext(){ 
	static text[64]
	get_msg_arg_string(2, text, sizeof text - 1)
	if (equal(text, "#Cstrike_Name_Change"))
		return PLUGIN_HANDLED
	return PLUGIN_CONTINUE
}
public message_teaminfo(msg_id, msg_dest){
	if (msg_dest != MSG_ALL && msg_dest != MSG_BROADCAST) return PLUGIN_CONTINUE
	if (g_gamemode != mode_normal) return PLUGIN_CONTINUE
	if (g_round != round_zombie) return PLUGIN_CONTINUE//没开局那关我鸟事..
	new id = get_msg_arg_int(1)
	static team[2]
	get_msg_arg_string(2, team, sizeof team - 1)
	if(team[0] == 'U' || team[0] == 'S') return PLUGIN_CONTINUE
	new hm = get_humans_num()
	new zm = get_zombies_num()
	if (hm > 0 && zm == 0){
		client_cmd(id, "say !zspawn")
	} else if (hm > 0 && zm > 0){
		client_cmd(id, "say !zspawn")
	} else if (hm == 0 && zm > 0){
		check_end()
	} else if (hm == 0 && zm == 0){
		check_end()
	}
	return PLUGIN_HANDLED
}
public message_corpse(){
	set_msg_arg_string(1, gcurmodel[get_msg_arg_int(12)])

	if(gcorpse_hidden[get_msg_arg_int(12)])
	return PLUGIN_HANDLED

	return PLUGIN_CONTINUE
}
public message_hostagepos(){
	return PLUGIN_HANDLED;
}
public message_deathmsg(msg_id, msg_dest, id){
	return PLUGIN_HANDLED
}
stock ckrun_get_primary_maxid(id){
	if(!(1 <= ghuman[id] <= 6)) return 0
	switch(ghuman[id]){
		case human_scout: return sizeof g_primary_allow_scout
		case human_heavy: return sizeof g_primary_allow_heavy
		case human_rpg:	return sizeof g_primary_allow_rpg
		case human_snipe: return sizeof g_primary_allow_snipe
		case human_log:	return sizeof g_primary_allow_log
		case human_eng:	return sizeof g_primary_allow_eng
	}
	return 0
}
stock ckrun_get_primary_formatname(id, wpnid, name[], len){//玩家+允许主武器列表中的序号→该武器的游戏名
	if(!(1 <= ghuman[id] <= 6)) return 1
	switch(ghuman[id]){
		case human_scout: format(name, len, "%L", id, g_wpn_formatname[g_primary_allow_scout[wpnid]])
		case human_heavy: format(name, len, "%L", id, g_wpn_formatname[g_primary_allow_heavy[wpnid]])
		case human_rpg:	format(name, len, "%L", id, g_wpn_formatname[g_primary_allow_rpg[wpnid]])
		case human_snipe: format(name, len, "%L", id, g_wpn_formatname[g_primary_allow_snipe[wpnid]])
		case human_log:	format(name, len, "%L", id, g_wpn_formatname[g_primary_allow_log[wpnid]])
		case human_eng:	format(name, len, "%L", id, g_wpn_formatname[g_primary_allow_eng[wpnid]])
	}
	return 1
}
stock ckrun_get_primary_classname(id, wpnid, name[], len){//玩家+允许主武器列表中的序号→该武器的实体名
	if(!(1 <= ghuman[id] <= 6)) return 1
	switch(ghuman[id]){
		case human_scout: format(name, len, "%s", g_wpn_classname[g_primary_allow_scout[wpnid]])
		case human_heavy: format(name, len, "%s", g_wpn_classname[g_primary_allow_heavy[wpnid]])
		case human_rpg:	format(name, len, "%s", g_wpn_classname[g_primary_allow_rpg[wpnid]])
		case human_snipe: format(name, len, "%s", g_wpn_classname[g_primary_allow_snipe[wpnid]])
		case human_log:	format(name, len, "%s", g_wpn_classname[g_primary_allow_log[wpnid]])
		case human_eng:	format(name, len, "%s", g_wpn_classname[g_primary_allow_eng[wpnid]])
	}
	return 1
}

//---------获取人类类型名称--------//now
stock ckrun_get_user_classname(id, zombie, classname[], len){//1=僵尸 0=人类
	if(!(1 <= id <= g_maxplayers)) return;
	if(zombie){
		switch(gzombie[id]){
			case zombie_fast:format(classname,len,"%L",id,"NAME_ZOMBIE_FAST")
			case zombie_gravity:format(classname,len,"%L",id,"NAME_ZOMBIE_GRAVITY")
			case zombie_classic:format(classname,len,"%L",id,"NAME_ZOMBIE_CLASSIC")
			case zombie_jump:format(classname,len,"%L",id,"NAME_ZOMBIE_JUMP")
			case zombie_invis:format(classname,len,"%L",id,"NAME_ZOMBIE_VIS")
		}
	} else if(!zombie) {
		switch(ghuman[id]){
			case human_scout:format(classname,len,"%L",id,"NAME_HUMAN_SCOUT")
			case human_heavy:format(classname,len,"%L",id,"NAME_HUMAN_HEAVY")
			case human_rpg:format(classname,len,"%L",id,"NAME_HUMAN_RPG")
			case human_snipe:format(classname,len,"%L",id,"NAME_HUMAN_SNIPE")
			case human_log:format(classname,len,"%L",id,"NAME_HUMAN_LOG")
			case human_eng:format(classname,len,"%L",id,"NAME_HUMAN_ENG")
		}
	}
	return;
}
stock ckrun_get_secondary_maxid(id){
	if(!(1 <= ghuman[id] <= 6))
		return 0
	switch(ghuman[id]){
		case human_scout: return sizeof g_secondary_allow_scout
		case human_heavy: return sizeof g_secondary_allow_mg
		case human_rpg: return sizeof g_secondary_allow_rpg
		case human_snipe: return sizeof g_secondary_allow_snipe
		case human_log: return sizeof g_secondary_allow_log
		case human_eng:	return sizeof g_secondary_allow_eng
	}
	return 0
}
stock ckrun_get_secondary_formatname(id, wpnid, name[], len){//玩家+允许副武器列表中的序号→该武器的游戏名
	if(!(1 <= ghuman[id] <= 6))
		return 1
	switch(ghuman[id]){
		case human_scout: format(name, len, "%L", id, g_wpn_formatname[g_secondary_allow_scout[wpnid]])
		case human_heavy: format(name, len, "%L", id, g_wpn_formatname[g_secondary_allow_mg[wpnid]])
		case human_rpg:	format(name, len, "%L", id, g_wpn_formatname[g_secondary_allow_rpg[wpnid]])
		case human_snipe: format(name, len, "%L", id, g_wpn_formatname[g_secondary_allow_snipe[wpnid]])
		case human_log:	format(name, len, "%L", id, g_wpn_formatname[g_secondary_allow_log[wpnid]])
		case human_eng: format(name, len, "%L", id, g_wpn_formatname[g_secondary_allow_eng[wpnid]])
	}
	return 1
}
stock ckrun_get_secondary_classname(id, wpnid, name[], len){//玩家+允许副武器列表中的序号→该武器的实体名
	if(!(1 <= ghuman[id] <= 6))
		return 1
	switch(ghuman[id]){
		case human_scout:format(name, len, "%s", g_wpn_classname[g_secondary_allow_scout[wpnid]])
		case human_heavy:format(name, len, "%s", g_wpn_classname[g_secondary_allow_mg[wpnid]])
		case human_rpg:format(name, len, "%s", g_wpn_classname[g_secondary_allow_rpg[wpnid]])
		case human_snipe:format(name, len, "%s", g_wpn_classname[g_secondary_allow_snipe[wpnid]])
		case human_log:format(name, len, "%s", g_wpn_classname[g_secondary_allow_log[wpnid]])
		case human_eng:format(name, len, "%s", g_wpn_classname[g_secondary_allow_eng[wpnid]])
	}
	return 1
}
//---------获取人类类型名称--------//will be
stock ckrun_get_user_classname_willbe(id, zombie, classname[], len){//1=僵尸 0=人类
	if(!(1 <= id <= g_maxplayers)) return;
	if(zombie){
		switch(gwillbezombie[id]){
			case zombie_fast:format(classname,len,"%L",id,"NAME_ZOMBIE_FAST")
			case zombie_gravity:format(classname,len,"%L",id,"NAME_ZOMBIE_GRAVITY")
			case zombie_classic:format(classname,len,"%L",id,"NAME_ZOMBIE_CLASSIC")
			case zombie_jump:format(classname,len,"%L",id,"NAME_ZOMBIE_JUMP")
			case zombie_invis:format(classname,len,"%L",id,"NAME_ZOMBIE_VIS")
		}
	} else if(!zombie) {
		switch(gwillbehuman[id]){
			case human_scout:format(classname,len,"%L",id,"NAME_HUMAN_SCOUT")
			case human_heavy:format(classname,len,"%L",id,"NAME_HUMAN_HEAVY")
			case human_rpg:format(classname,len,"%L",id,"NAME_HUMAN_RPG")
			case human_snipe:format(classname,len,"%L",id,"NAME_HUMAN_SNIPE")
			case human_log:format(classname,len,"%L",id,"NAME_HUMAN_LOG")
			case human_eng:format(classname,len,"%L",id,"NAME_HUMAN_ENG")
		}
	}
	return;
}
//---------获取人类类型名称--------//willbe
//---------获取玩家所带武器名称--------//
stock ckrun_get_user_weapon_name(id,classname[],len){
	if(!is_user_alive(id))
		return 2
	new clip,ammo,wep = get_user_weapon(id,clip,ammo)
	switch(wep){
		case CSW_P228:format(classname, len, "%L", id, "NAME_WEAPON_P228")
		case CSW_HEGRENADE:format(classname, len, "%L", id, "NAME_WEAPON_HE")
		case CSW_XM1014:format(classname, len, "%L", id, "NAME_WEAPON_XM1014")
		case CSW_C4:{
			switch(ghuman[id]){
				case 3:	format(classname, len, "%L", id, "NAME_WEAPON_RPG")
				case 5: {
					if(glogmode[id] == 1)
						format(classname, len, "%L", id, "NAME_WEAPON_MEDICGUN")
					else
						format(classname, len, "%L", id, "NAME_WEAPON_AMMOPACK")
				}
				case 6:	{
					if(gengmode[id] == 1)
						format(classname, len, "%L", id, "NAME_WEAPON_TOOLBOX")
					else
						format(classname, len, "%L", id, "NAME_WEAPON_PDA")
				}
			}
		}
		case CSW_MAC10:format(classname, len, "%L", id, "NAME_WEAPON_MAC10")
		case CSW_AUG:format(classname, len, "%L", id, "NAME_WEAPON_AUG")
		case CSW_SMOKEGRENADE:format(classname, len, "%L", id, "NAME_WEAPON_SMOKE")
		case CSW_ELITE:format(classname, len, "%L", id, "NAME_WEAPON_ELITES")
		case CSW_FIVESEVEN:format(classname, len, "%L", id, "NAME_WEAPON_57")
		case CSW_UMP45:format(classname, len, "%L", id, "NAME_WEAPON_UMP45")
		case CSW_GALIL:format(classname, len, "%L", id, "NAME_WEAPON_GALIL")
		case CSW_FAMAS:format(classname, len, "%L", id, "NAME_WEAPON_FAMAS")
		case CSW_USP:format(classname, len, "%L", id, "NAME_WEAPON_USP45")
		case CSW_GLOCK18:format(classname, len, "%L", id, "NAME_WEAPON_GLOCK18")
		case CSW_AWP:format(classname, len, "%L", id, "NAME_WEAPON_AWP")
		case CSW_MP5NAVY:format(classname, len, "%L", id, "NAME_WEAPON_MP5")
		case CSW_M249:format(classname, len, "%L", id, "NAME_WEAPON_M249")
		case CSW_M3:format(classname, len, "%L", id, "NAME_WEAPON_M3")
		case CSW_M4A1:format(classname, len, "%L", id, "NAME_WEAPON_M4A1")	
		case CSW_TMP:format(classname, len, "%L", id, "NAME_WEAPON_TMP")
		case CSW_FLASHBANG:format(classname, len, "%L", id, "NAME_WEAPON_FLASH")
		case CSW_DEAGLE:format(classname, len, "%L", id, "NAME_WEAPON_DEAGLE")
		case CSW_SG552:format(classname, len, "%L", id, "NAME_WEAPON_SG552")
		case CSW_AK47:format(classname, len, "%L", id, "NAME_WEAPON_AK47")
		case CSW_KNIFE:{
			switch(ghuman[id]){
				case 6:format(classname, len, "%L", id, "NAME_WEAPON_HAMMER")
				default:format(classname, len, "%L", id, "NAME_WEAPON_KNIFE")
			}
		}
		case CSW_P90 :format(classname, len, "%L", id, "NAME_WEAPON_P90")
		default :format(classname, len, "%L", id, "NAME_WEAPON_UNKNOW")
	}
	return 2
}
//---------获取玩家所带武器名称--------//
//---------获取玩家所带武器自动/半自动类型--------//
stock ckrun_is_weapon_auto(wpn){
	new auto
	switch(wpn){
		case CSW_P228:		auto = 0
		case CSW_HEGRENADE:	auto = -1
		case CSW_XM1014:	auto = 0
		case CSW_C4:		auto = 0
		case CSW_MAC10:		auto = 1
		case CSW_AUG:		auto = 1
		case CSW_SMOKEGRENADE:	auto = 0
		case CSW_ELITE:		auto = 0
		case CSW_FIVESEVEN:	auto = 0
		case CSW_UMP45:		auto = 1
		case CSW_GALIL:		auto = 1
		case CSW_FAMAS:		auto = 1	
		case CSW_USP:		auto = 0
		case CSW_GLOCK18:	auto = 0
		case CSW_AWP:		auto = 0
		case CSW_MP5NAVY:	auto = 1
		case CSW_M249:		auto = 1
		case CSW_M3:		auto = 0
		case CSW_M4A1:		auto = 1	
		case CSW_TMP:		auto = 1
		case CSW_FLASHBANG:	auto = 0
		case CSW_DEAGLE:	auto = 0
		case CSW_SG552:		auto = 1
		case CSW_AK47:		auto = 1
		case CSW_KNIFE:		auto = 0
		case CSW_P90:		auto = 1
		case CKW_RPG:		auto = -1
		case CKW_SENTRY_ROCKET:	auto = -1
		case CKW_REFLECT_ROCKET:auto = -1
		case CKW_FLARE:		auto = -1
		case CKW_INFECT:	auto = -1
		case CKW_BACKSTAB:	auto = -1
		case CKW_HAMMER:	auto = 0
		default :		auto = 0
	}
	return auto
}
//---------获取玩家所带武器自动/半自动类型--------//

//---------获取正在给玩家加血/补给的人--------//
stock ckrun_get_user_assistance(id){
	if(!is_user_alive(id) || giszm[id]) return 0
	new assistant
	if(gmediced[id] > 0 && !gammoed[id])
		assistant = gmediced[id]
	else if (!gmediced[id] && gammoed[id] > 0)
		assistant = gammoed[id]
	else if (!gmediced[id] && !gammoed[id])
		assistant = 0
	return assistant
}
//---------获取正在给玩家加血/补给的人--------//
//---------设置成僵尸---------//
stock ckrun_set_user_zombie(id){
	if(!is_user_alive(id)) return;
	ckrun_sentry_destory(id)
	ckrun_dispenser_destory(id)
	ckrun_telein_destory(id, 1)
	ckrun_teleout_destory(id, 1)
	ckrun_reset_user_var(id)
	ckrun_reset_user_knife(id)
	giszm[id] = true
	fm_set_user_team(id, CS_TEAM_CT)
	drop_weapons(id, 1)
	drop_weapons(id, 2)
	drop_weapons(id, 5)
	set_task(0.1,"ckrun_strip_user_weapons", id)
	new Float:Origin[3]
	pev(id, pev_origin, Origin)
	FX_Explode(Origin, explo, 5, 10, 0)
	FX_ScreenShake(id)
	new classname[16]
	ckrun_get_user_classname(id, 1, classname, 15)//获取僵尸类型名称
	client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_IS_ZOMBIE", classname)
	if(!gzombie[id]){
		gzombie[id] = random_num(1, 5)
		gwillbezombie[id] = gzombie[id]
	}
	switch(gzombie[id]){
		case zombie_fast:{
			gorispeed[id] = get_pcvar_num(cvar_zm_fast_speed)
			gcurspeed[id] = gorispeed[id]
			fm_set_user_health(id,get_pcvar_num(cvar_zm_fast_hp))
			fm_set_rendering(id, kRenderFxNone, 0, 0, 255, kRenderNormal, 255)
			format(gcurmodel[id], 31, "fastzombie")
		}
		case zombie_gravity:{
			gorispeed[id] = get_pcvar_num(cvar_zm_gravity_speed)
			gcurspeed[id] = gorispeed[id]
			fm_set_user_health(id,get_pcvar_num(cvar_zm_gravity_hp))
			fm_set_rendering(id, kRenderFxNone, 0, 0, 255, kRenderNormal, 255)
			format(gcurmodel[id], 31, "classiczombie")
		} 
		case zombie_classic:{
			gorispeed[id] = get_pcvar_num(cvar_zm_classic_speed)
			gcurspeed[id] = gorispeed[id]
			fm_set_user_health(id,get_pcvar_num(cvar_zm_classic_hp))
			fm_set_rendering(id, kRenderFxNone, 0, 0, 255, kRenderNormal, 255)
			format(gcurmodel[id], 31, "classiczombie")
		}
		case zombie_jump:{
			gorispeed[id] = get_pcvar_num(cvar_zm_jump_speed)
			gcurspeed[id] = gorispeed[id]
			fm_set_user_health(id,get_pcvar_num(cvar_zm_jump_hp))
			fm_set_rendering(id, kRenderFxNone, 0, 0, 255, kRenderNormal, 255)
			format(gcurmodel[id], 31, "jumpzombie")
		}
		case zombie_invis:{
			gorispeed[id] = get_pcvar_num(cvar_zm_invis_speed)
			gcurspeed[id] = gorispeed[id]
			fm_set_user_health(id,get_pcvar_num(cvar_zm_invis_hp))
			fm_set_rendering(id,kRenderFxNone, 0,0,0, kRenderTransTexture,150)
			format(gcurmodel[id], 31, "jumpzombie")
			set_pev(id, pev_viewmodel2, mdl_v_knife_stab)
		}
	}
	fm_set_user_model(id, gcurmodel[id])
}

stock ckrun_set_user_human(id){
	if(!is_user_alive(id)) return;
	ckrun_sentry_destory(id)
	ckrun_dispenser_destory(id)
	ckrun_telein_destory(id, 1)
	ckrun_teleout_destory(id, 1)
	ckrun_reset_user_var(id)
	ckrun_reset_user_knife(id)
	giszm[id] = false
	fm_set_user_team(id, CS_TEAM_T)
	drop_weapons(id, 1)
	drop_weapons(id, 2)
	drop_weapons(id, 5)
	new classname[16]
	ckrun_get_user_classname(id, 0, classname, 15)//获取人类兵种名称
	client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_IS_HUMAN", classname)

	fm_set_user_bpammo(id,18,get_pcvar_num(cvar_wpn_ammo_awp))    // awp
	fm_set_user_bpammo(id,20,get_pcvar_num(cvar_wpn_ammo_m249))   // m249
	fm_set_user_bpammo(id,26,get_pcvar_num(cvar_wpn_ammo_deagle)) // deagle
	fm_set_user_bpammo(id,21,get_pcvar_num(cvar_wpn_ammo_shotgun))// m3, xm1014
	fm_set_user_bpammo(id,3,get_pcvar_num(cvar_wpn_ammo_default)) // scout, ak, g3sg1
	fm_set_user_bpammo(id,1,get_pcvar_num(cvar_wpn_ammo_default)) // p228
	fm_set_user_bpammo(id,15,get_pcvar_num(cvar_wpn_ammo_default))// famas, m4a1, aug, sg550, galil, sg552 
	fm_set_user_bpammo(id,16,get_pcvar_num(cvar_wpn_ammo_default))// usp, ump, mac
	fm_set_user_bpammo(id,11,get_pcvar_num(cvar_wpn_ammo_default))// fiveseven, p90
	fm_set_user_bpammo(id,17,get_pcvar_num(cvar_wpn_ammo_default))// glock, mp5, tmp, elites
	if(!ghuman[id]){
		ghuman[id] = random_num(1, 6)
		gwillbehuman[id] = ghuman[id]
	}
	switch(ghuman[id]){
		case human_scout: {
			fm_give_item(id, "weapon_hegrenade")
			engclient_cmd(id, "weapon_knife")
			gorispeed[id] = get_pcvar_num(cvar_hm_scout_speed)
			gcurspeed[id] = gorispeed[id]
			fm_set_user_health(id,get_pcvar_num(cvar_hm_scout_hp))
		}
		case human_heavy: {
			fm_give_item(id, "weapon_m249")
			engclient_cmd(id, "weapon_knife")
			gorispeed[id] = get_pcvar_num(cvar_hm_heavy_speed)
			gcurspeed[id] = gorispeed[id]
			fm_set_user_health(id,get_pcvar_num(cvar_hm_heavy_hp))
		}
		case human_rpg: {
			fm_give_item(id, "weapon_c4")
			engclient_cmd(id, "weapon_knife")
			gorispeed[id] = get_pcvar_num(cvar_hm_rpg_speed)
			gcurspeed[id] = gorispeed[id]
			fm_set_user_health(id,get_pcvar_num(cvar_hm_rpg_hp))
		}
		case human_snipe: {
			fm_give_item(id, "weapon_awp")
			engclient_cmd(id, "weapon_knife")
			gorispeed[id] = get_pcvar_num(cvar_hm_snipe_speed)
			gcurspeed[id] = gorispeed[id]
			fm_set_user_health(id,get_pcvar_num(cvar_hm_snipe_hp))
			set_task(0.1,"funcSniperRegen",id+TASK_SNIPE_REGEN)
		}
		case human_log: {
			fm_give_item(id, "weapon_c4")
			engclient_cmd(id, "weapon_knife")
			gorispeed[id] = get_pcvar_num(cvar_hm_log_speed)
			gcurspeed[id] = gorispeed[id]
			fm_set_user_health(id,get_pcvar_num(cvar_hm_log_hp))
		}
		case human_eng: {
			fm_give_item(id, "weapon_c4")
			engclient_cmd(id, "weapon_knife")
			gorispeed[id] = get_pcvar_num(cvar_hm_eng_speed)
			gcurspeed[id] = gorispeed[id]
			fm_set_user_health(id,get_pcvar_num(cvar_hm_eng_hp))
		}
	}
	if (is_user_bot(id)){
		gmodel[id] = random_num(4, 7)
		switch(ghuman[id]){
			case human_scout:{
				fm_give_item(id, g_wpn_classname[g_primary_allow_scout[random_num(0, sizeof g_primary_allow_scout-1)]])
				fm_give_item(id, g_wpn_classname[g_secondary_allow_scout[random_num(0, sizeof g_secondary_allow_scout-1)]])
			}
			case human_heavy:{
				fm_give_item(id, g_wpn_classname[g_primary_allow_heavy[random_num(0, sizeof g_primary_allow_heavy-1)]])
				fm_give_item(id, g_wpn_classname[g_secondary_allow_mg[random_num(0, sizeof g_secondary_allow_mg-1)]])
			}
			case human_rpg:{
				fm_give_item(id, g_wpn_classname[g_primary_allow_rpg[random_num(0, sizeof g_primary_allow_rpg-1)]])
				fm_give_item(id, g_wpn_classname[g_secondary_allow_rpg[random_num(0, sizeof g_secondary_allow_rpg-1)]])
			}
			case human_snipe:{
				fm_give_item(id, g_wpn_classname[g_primary_allow_snipe[random_num(0, sizeof g_primary_allow_snipe-1)]])
				fm_give_item(id, g_wpn_classname[g_secondary_allow_snipe[random_num(0, sizeof g_secondary_allow_snipe-1)]])
			}
			case human_log:{
				fm_give_item(id, g_wpn_classname[g_primary_allow_log[random_num(0, sizeof g_primary_allow_log-1)]])
				fm_give_item(id, g_wpn_classname[g_secondary_allow_log[random_num(0, sizeof g_secondary_allow_log-1)]])
			}
			case human_eng:{
				fm_give_item(id, g_wpn_classname[g_primary_allow_eng[random_num(0, sizeof g_primary_allow_eng-1)]])
				fm_give_item(id, g_wpn_classname[g_secondary_allow_eng[random_num(0, sizeof g_secondary_allow_eng-1)]])
			}
		}
	} else {
		show_menu_main(id)
	}
	format(gcurmodel[id], 31, "%s", mdl_human[gmodel[id]])
	fm_set_user_model(id, gcurmodel[id])
	fm_set_rendering(id, kRenderFxNone, 0, 0, 255, kRenderNormal, 255)
}

//---------------成绩设置---------------------//
stock ckrun_add_user_score(id,kill,death){
	if(!(1 <= id <= g_maxplayers))
		return
	if(kill != 0){
		gkill[id] += kill
		g_roundkill[id] += kill
		set_pev(id, pev_frags, float(kill));
	}
	if(death != 0){
		gdeath[id] += death
		g_rounddeath[id] += death
		set_pdata_int(id, OFFSET_CSDEATHS, death);
	}
	check_ach_fast_11(id)
	// 更新成绩数据
	message_begin(MSG_ALL, g_msgScoreInfo)
	write_byte(id)
	write_short(gkill[id])
	write_short(gdeath[id])
	write_short(0)
	write_short(fm_get_user_team(id))
	message_end()
}
	
//---------------成绩设置---------------------//
//---------------重新设置死亡标记---------------------//
stock ckrun_reset_user_deadflag(id){
	if(!(1 <= id <= g_maxplayers))
		return
	if(is_user_alive(id)){
		message_begin(MSG_BROADCAST, g_msgScoreAttrib)
		write_byte(id)
		write_byte(0)
		message_end()
	}
	return
}
stock ckrun_reset_user_var(id){
	gflame[id] = 0
	gfrozen[id] = 0
	gflamer[id] = 0
	gcharge[id] = 0
	gcritkilled[id] = 0
	gminigun_spin[id] = 0
	glogammo[id] = 100
	gengmetal[id] = 100
	gpower[id] = 100
	gcritical[id] = get_pcvar_num(cvar_global_crit_percent)
	gteletimes[id] = get_pcvar_num(cvar_global_tele)
	grpgammo[id] = get_pcvar_num(cvar_wpn_ammo_rpg)
	grpgclip[id] = get_pcvar_num(cvar_wpn_clip_rpg)
	gtelecd[id] = false
	gcaptured[id] = false
	glongjumpon[id] = false
	gdodgeon[id] = false
	ginvisible[id] = false
	gdisguising[id] = false
	gstabing[id] = false
	gjumping[id] = false
	gcansecondjump[id] = false
	gprimaryed[id] = false
	gsecondjump[id] = false
	gsecondaryed[id] = false
	gpickedup[id] = false
	gcorpse_hidden[id] = false
	gskill_ready[id] = true
	gsentry_rocket[id] = true
	grpgready[id] = true
	grpgreloading[id] = false
}
stock ckrun_reset_user_knife(id){
	if(giszm[id]){
		switch(gzombie[id]){
			case zombie_fast: {
				if(gknifesave_zm[id] == knife_moonstar) gknife[id] = knife_moonstar
				else gknife[id] = knife_normal
			}
			default: gknife[id] = knife_normal
		}
	} else {
		switch(ghuman[id]){
			case human_eng: {
				if(gknifesave_hm[id] == knife_hammer) gknife[id] = knife_hammer
				else gknife[id] = knife_normal
			}
			default: gknife[id] = knife_normal
		}
	}
	if(get_user_weapon(id) != CSW_KNIFE) return
	switch(gknife[id]){
		case knife_normal:{
			set_pev(id, pev_viewmodel2, mdl_v_knife)
			set_pev(id, pev_weaponmodel2, mdl_p_knife)
		}
		case knife_moonstar:{
			set_pev(id, pev_viewmodel2, mdl_v_moonstar)
			set_pev(id, pev_weaponmodel2, mdl_p_moonstar)
		}
		case knife_hammer:{
			set_pev(id, pev_viewmodel2, mdl_v_hammer)
			set_pev(id, pev_weaponmodel2, mdl_p_hammer)
		}
	}

}
stock ckrun_set_user_deadflag(id,dead){
	if(is_user_connected(id) && dead <= 1 && dead >= 0){
		message_begin(MSG_BROADCAST, g_msgScoreAttrib)
		write_byte(id)
		write_byte(dead)
		message_end()
	}
}
stock ckrun_fix_user_deadflag(id){
	if(is_user_alive(id)){
		message_begin(MSG_BROADCAST, g_msgScoreAttrib)
		write_byte(id)
		write_byte(0)
		message_end()
	}
}
stock is_back_face(enemy, id){
	new Float:anglea[3],Float:anglev[3]
	pev(enemy,pev_v_angle,anglea)
	pev(id,pev_v_angle,anglev)
	new Float:angle = anglea[1] - anglev[1] 
	if(angle < -180.0) angle += 360.0
	if(angle <= 90.0 && angle >= -90.0) return true
	return false
}
//---------------获取玩家最大生命值---------------------//
stock ckrun_get_user_maxhealth(id){
	if(!is_user_alive(id))
		return 0
	new maxhealth
	if(giszm[id]){
		switch(gzombie[id]){
			case 1: maxhealth = get_pcvar_num(cvar_zm_fast_hp)
			case 2: maxhealth = get_pcvar_num(cvar_zm_gravity_hp)
			case 3: maxhealth = get_pcvar_num(cvar_zm_classic_hp)
			case 4: maxhealth = get_pcvar_num(cvar_zm_jump_hp)
			case 5: maxhealth = get_pcvar_num(cvar_zm_invis_hp)
		}	
	} else {
		switch(ghuman[id]){
			case 1: maxhealth = get_pcvar_num(cvar_hm_scout_hp)
			case 2: maxhealth = get_pcvar_num(cvar_hm_heavy_hp)
			case 3: maxhealth = get_pcvar_num(cvar_hm_rpg_hp)
			case 4: maxhealth = get_pcvar_num(cvar_hm_snipe_hp)
			case 5: maxhealth = get_pcvar_num(cvar_hm_log_hp)
			case 6: maxhealth = get_pcvar_num(cvar_hm_eng_hp)
		}
	}
	return maxhealth
}
//---------------获取玩家最大生命值---------------------//
//----------------生命补给------------//返回值=是(成功给予生命)/否
stock bool:ckrun_give_user_health(id,percent){
	if(!is_user_alive(id) || giszm[id])
		return false
	if(percent > 100)
		percent = 100
	if(percent <= 0)
		return false
	new maxhealth = ckrun_get_user_maxhealth(id)
	new givehealth = maxhealth * percent / 100
	if(get_user_health(id) >= maxhealth){
		return false
	} else if(get_user_health(id) + givehealth > maxhealth){
		fm_set_user_health(id,maxhealth)
	} else if(get_user_health(id) + givehealth <= maxhealth){
		fm_set_user_health(id,get_user_health(id) + givehealth)
	} else {
		return false
	}
	return true
}
stock bool:ckrun_give_user_health_amount(id,amount){
	if(!is_user_alive(id) || giszm[id])
		return false
	if(amount <= 0)
		return false
	new maxhealth = ckrun_get_user_maxhealth(id)
	if(get_user_health(id) >= maxhealth){
		return false
	} else if(get_user_health(id) + amount > maxhealth){
		fm_set_user_health(id,maxhealth)
	} else if(get_user_health(id) + amount <= maxhealth){
		fm_set_user_health(id,get_user_health(id) + amount)
	} else {
		return false
	}
	return true
}
//----------------弹药补给------------//
//----------------获取弹药百分比------------//返回值=0~100的整数
stock ckrun_get_user_ammo(id){
	if(!is_user_alive(id))
		return -1
	if(giszm[id] && gpower[id] < 100)
		return gpower[id]
	new percent
	new clip,ammo
	new wep = get_user_weapon(id,clip,ammo)
	switch(wep){
		case 0: return -1
		case CSW_HEGRENADE: return -1
		case CSW_C4:{
			switch(ghuman[id]){
				case 3: percent = grpgammo[id] * 100 / get_pcvar_num(cvar_wpn_ammo_rpg)
				case 5: percent = glogammo[id]
				case 6: percent = gengmetal[id]
				default: return -1
			}
		}
		case CSW_SMOKEGRENADE: return -1
		case CSW_AWP: percent = fm_get_user_bpammo(id,wep) * 100 / get_pcvar_num(cvar_wpn_ammo_awp)
		case CSW_M249: percent = fm_get_user_bpammo(id,wep) * 100 / get_pcvar_num(cvar_wpn_ammo_m249)
		case CSW_FLASHBANG: return -1
		case CSW_DEAGLE: percent = fm_get_user_bpammo(id,wep) * 100 / get_pcvar_num(cvar_wpn_ammo_deagle)
		case CSW_M3,CSW_XM1014: percent = fm_get_user_bpammo(id,wep) * 100 / get_pcvar_num(cvar_wpn_ammo_shotgun)
		case CSW_KNIFE: {
			switch(ghuman[id]){
				case 5: percent = glogammo[id]
				case 6: percent = gengmetal[id]
				default: return -1
			}
		}
		default: percent = fm_get_user_bpammo(id,wep) * 100 / get_pcvar_num(cvar_wpn_ammo_default)
	}
	return percent
}
//----------------获取弹药百分比------------//
//----------------设置备用弹药------------//
stock ckrun_set_user_ammo(id,percent){
	if(!is_user_alive(id))
		return;
	if(percent > 100)
		percent = 100
	if(percent < 0)
		percent = 0
	if(giszm[id]){
		if(gpower[id] >= 100) return false
		gpower[id] = percent
		return true
	}
	new clip,ammo
	new wep = get_user_weapon(id,clip,ammo)
	switch(wep){
		case 0:	return;
		case CSW_HEGRENADE: return;
		case CSW_C4:{
			switch(ghuman[id]){
				case human_rpg:{
					new newammo = get_pcvar_num(cvar_wpn_ammo_rpg) * percent / 100
					grpgammo[id] = newammo
					FX_UpdateClip(id, CSW_C4, grpgclip[id])
					fm_set_user_bpammo(id, CSW_C4, max(grpgammo[id], 1))
				}
				case human_log:	glogammo[id] = percent
				case human_eng: gengmetal[id] = percent
				default: return;
			}
		}
		case CSW_SMOKEGRENADE:return false
		case CSW_AWP:{//awp
			new newammo = get_pcvar_num(cvar_wpn_ammo_awp) * percent / 100
			fm_set_user_bpammo(id, wep, newammo)
		}
		case CSW_M249:{//m249
			new newammo = get_pcvar_num(cvar_wpn_ammo_m249) * percent / 100
			fm_set_user_bpammo(id, wep, newammo)
		}
		case CSW_FLASHBANG:return false
		case CSW_DEAGLE:{//deagle
			new newammo = get_pcvar_num(cvar_wpn_ammo_deagle) * percent / 100
			fm_set_user_bpammo(id, wep, newammo)
		}
		case CSW_M3,CSW_XM1014:{//deagle
			new newammo = get_pcvar_num(cvar_wpn_ammo_shotgun) * percent / 100
			fm_set_user_bpammo(id, wep, newammo)
		}
		case CSW_KNIFE:{
			switch(ghuman[id]){
				case 5:	glogammo[id] = percent
				case 6: gengmetal[id] = percent
				default: return;
			}
		default:{
			new newammo = get_pcvar_num(cvar_wpn_ammo_default) * percent / 100
			fm_set_user_bpammo(id, wep, newammo)
		}
	}
	return;
}
//----------------设置备用弹药------------//
//----------------弹药补给------------//返回值=是(成功给予弹药)/否
stock bool:ckrun_give_user_ammo(id,percent){
	if(!is_user_alive(id))
		return false
	if(percent > 100)
		percent = 100
	if(percent <= 0)
		return false
	if(giszm[id]){
		if(gpower[id] >= 100) return false
		if(gpower[id] + percent > 100  && gpower[id] < 100)
			gpower[id] = 100
		else if(gpower[id] + percent <= 100 )
			gpower[id] += percent
		return true
	}
	new wep = get_user_weapon(id)
	switch(wep){
		case 0:return false
		case CSW_HEGRENADE:return false
		case CSW_C4:{
			switch(ghuman[id]){
				case human_rpg:{
					new maxammo = get_pcvar_num(cvar_wpn_ammo_rpg)
					new giveammo = maxammo * percent / 100
					if(giveammo < 1)
						giveammo = 1
					if(grpgammo[id] >= maxammo)
						return false
					if(grpgammo[id] > maxammo - giveammo && grpgammo[id] < maxammo)
						grpgammo[id] = maxammo
					if(grpgammo[id] <= maxammo - giveammo)
						grpgammo[id] += giveammo
					FX_UpdateClip(id, CSW_C4, grpgclip[id])
					fm_set_user_bpammo(id, CSW_C4, max(grpgammo[id], 1))
				}
				case human_log:{
					if(glogammo[id] >= 100)
						return false
					if(glogammo[id] > 100 - percent && glogammo[id] < 100)
						glogammo[id] = 100
					if(glogammo[id] <= 100 - percent)
						glogammo[id] += percent
				}
				case human_eng:{
					if(gengmetal[id] >= 100)
						return false
					if(gengmetal[id] > 100 - percent && gengmetal[id] < 100)
						gengmetal[id] = 100
					if(gengmetal[id] <= 100 - percent)
						gengmetal[id] += percent
				}
				default: return false;
			}
		}
		case CSW_SMOKEGRENADE:return false
		case CSW_AWP:{//awp
			new maxammo = get_pcvar_num(cvar_wpn_ammo_awp)
			new giveammo = maxammo * percent / 100
			if(giveammo < 1)
				giveammo = 1
			if(fm_get_user_bpammo(id,wep) >= maxammo)
				return false
			if(fm_get_user_bpammo(id,wep) > maxammo - giveammo && fm_get_user_bpammo(id,wep)< maxammo)
				fm_set_user_bpammo(id,wep,maxammo)
			if(fm_get_user_bpammo(id,wep) <= maxammo - giveammo)
				fm_set_user_bpammo(id,wep,fm_get_user_bpammo(id,wep)+giveammo)
		}
		case CSW_M249:{//m249
			new maxammo = get_pcvar_num(cvar_wpn_ammo_m249)
			new giveammo = maxammo * percent / 100
			if(giveammo < 1)
				giveammo = 1
			if(fm_get_user_bpammo(id,wep) >= maxammo)
				return false
			if(fm_get_user_bpammo(id,wep) > maxammo - giveammo && fm_get_user_bpammo(id,wep)< maxammo)
				fm_set_user_bpammo(id,wep,maxammo)
			if(fm_get_user_bpammo(id,wep) <= maxammo - giveammo)
				fm_set_user_bpammo(id,wep,fm_get_user_bpammo(id,wep)+giveammo)
		}
		case CSW_FLASHBANG:return false
		case CSW_DEAGLE:{//deagle
			new maxammo = get_pcvar_num(cvar_wpn_ammo_deagle)
			new giveammo = maxammo * percent / 100
			if(giveammo < 1)
				giveammo = 1
			if(fm_get_user_bpammo(id,wep) >= maxammo)
				return false
			if(fm_get_user_bpammo(id,wep) > maxammo - giveammo && fm_get_user_bpammo(id,wep)< maxammo)
				fm_set_user_bpammo(id,wep,maxammo)
			if(fm_get_user_bpammo(id,wep) <= maxammo - giveammo)
				fm_set_user_bpammo(id,wep,fm_get_user_bpammo(id,wep)+giveammo)
		}
		case CSW_M3,CSW_XM1014:{//deagle
			new maxammo = get_pcvar_num(cvar_wpn_ammo_shotgun)
			new giveammo = maxammo * percent / 100
			if(giveammo < 1)
				giveammo = 1
			if(fm_get_user_bpammo(id,wep) >= maxammo)
				return false
			if(fm_get_user_bpammo(id,wep) > maxammo - giveammo && fm_get_user_bpammo(id,wep)< maxammo)
				fm_set_user_bpammo(id,wep,maxammo)
			if(fm_get_user_bpammo(id,wep) <= maxammo - giveammo)
				fm_set_user_bpammo(id,wep,fm_get_user_bpammo(id,wep)+giveammo)
		}
		case CSW_KNIFE:{
			switch(ghuman[id]){
				case 3:{
					new maxammo = get_pcvar_num(cvar_wpn_ammo_rpg)
					new giveammo = maxammo * percent / 100
					if(giveammo < 1)
						giveammo = 1
					if(grpgammo[id] >= maxammo)
						return false
					if(grpgammo[id] > maxammo - giveammo && grpgammo[id] < maxammo)
						grpgammo[id] = maxammo
					if(grpgammo[id] <= maxammo - giveammo)
						grpgammo[id] += giveammo
				}
				case 5:{
					if(glogammo[id] >= 100)
						return false
					if(glogammo[id] > 100 - percent && glogammo[id] < 100)
						glogammo[id] = 100
					if(glogammo[id] <= 100 - percent)
						glogammo[id] += percent
				}
				case 6:{
					if(gengmetal[id] >= 100)
						return false
					if(gengmetal[id] > 100 - percent && gengmetal[id] < 100)
						gengmetal[id] = 100
					if(gengmetal[id] <= 100 - percent)
						gengmetal[id] += percent
				}
				default: {
					if(gpower[id] >= 100)return false
					if(gpower[id] > 100 - percent && gpower[id] < 100)
						gpower[id] = 100
					else if(gpower[id] <= 100 - percent)
						gpower[id] += percent
				}
			}
		}
		default:{
			new maxammo = get_pcvar_num(cvar_wpn_ammo_default)
			new giveammo = maxammo * percent / 100
			if(giveammo < 1)
				giveammo = 1
			if(fm_get_user_bpammo(id,wep) >= maxammo)
				return false
			if(fm_get_user_bpammo(id,wep) > maxammo - giveammo && fm_get_user_bpammo(id,wep)< maxammo)
				fm_set_user_bpammo(id,wep,maxammo)
			if(fm_get_user_bpammo(id,wep) <= maxammo - giveammo)
				fm_set_user_bpammo(id,wep,fm_get_user_bpammo(id,wep)+giveammo)
		}
	}
	return true
}
//----------------弹药补给------------//
stock ckrun_FVecIVec(const Float:forigin[3], iorigin[4]){
	iorigin[0] = floatround(forigin[0])
	iorigin[1] = floatround(forigin[1])
	iorigin[2] = floatround(forigin[2])
	return iorigin[2]
}
stock ckrun_VecAdd(Float:vec1[3], Float:vec2[3]){
	vec1[0] += vec2[0]
	vec1[1] += vec2[1]
	vec1[2] += vec2[2]
	return 1
}
//----------------获取击飞效果------------//返回值=正整数
stock ckrun_get_user_force(id,damage){
	if(!is_user_alive(id))
		return 0
	if(!giszm[id])
		return 0
	new force
	switch(gzombie[id]){
		case 1: force = damage*(100 - get_pcvar_num(cvar_zm_fast_kb))
		case 2: force = damage*(100 - get_pcvar_num(cvar_zm_gravity_kb))
		case 3: force = damage*(100 - get_pcvar_num(cvar_zm_classic_kb))
		case 4: force = damage*(100 - get_pcvar_num(cvar_zm_jump_kb))
		case 5: force = damage*(100 - get_pcvar_num(cvar_zm_invis_kb))
	}
	return force
}
stock bool:ckrun_can_damage(enemy,id){
	if(!is_user_alive(id))
		return false
	if(id == g_ctbot || id == g_tbot)
		return false
	if(enemy == id)
		return true
	if(!giszm[id] && giszm[enemy])
		return true
	if(giszm[id] && !giszm[enemy])
		return true
	return false
}

stock fm_get_entity_num(const classname[]){
	new ent, entnum = 0
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", classname)) != 0)
		entnum ++
	return entnum
}
stock get_humans_num(){
	new num = 0 , i
	for (i = 1; i <= g_maxplayers; i++){
		if (is_user_alive(i) && !giszm[i] && i != g_ctbot && i != g_tbot)
			num ++
	}
	return num
}
stock get_zombies_num(){
	new num = 0 , i
	for (i = 1; i <= g_maxplayers; i++){
		if (is_user_alive(i) && giszm[i] && i != g_ctbot && i != g_tbot)
			num ++
	}
	return num
}
stock get_players_num(){
	new num = 0 , i
	for (i = 1; i <= g_maxplayers; i++){
		if (is_user_connected(i) && i != g_ctbot && i != g_tbot)
			num ++
	}
	return num
}
//----------------获取击飞效果------------//
//----------------武器击飞系统------------//
public ckrun_knockback(id,enemy,force,onlyxy){
	if(force == 0 || !is_user_alive(id) || !is_user_alive(enemy)) return
	if(pev(id, pev_flags) & FL_ONGROUND)
		force *= 2
	if(pev(id, pev_flags) & FL_DUCKING)
		force /= 2
	if(force > 0 && force < 50)
		force = 50
	if (force > 15000)
		force = 15000
	new Float:oldvec[3], Float:vec[3]
	velocity_by_aim(enemy,force,vec)
	pev(id, pev_velocity,oldvec)
	oldvec[0] += vec[0]
	oldvec[1] += vec[1]
	if(onlyxy == 0)
		oldvec[2] += vec[2]
	set_pev(id, pev_velocity, oldvec)
}
//----------------武器击飞系统------------//
//----------------爆炸击飞系统------------//
public ckrun_knockback_explode(id,const Float:Origin[3], Float:force){
	if(force <= 0.0) return
	if(!is_user_alive(id)) return
	new Float:oldvec[3], Float:velocity[3], Float:id_origin[3]
	pev(id, pev_origin, id_origin);
	get_speed_vector(Origin, id_origin, force, velocity);
	pev(id, pev_velocity, oldvec);
	oldvec[0] += velocity[0]
	oldvec[1] += velocity[1]
	oldvec[2] += velocity[2]
	set_pev(id, pev_velocity, oldvec);
}
//----------------爆炸击飞系统------------//

stock ckrun_deathmsg(killer, assistant, killed, headshot, const weapon[]){
	new build
	if(killed > g_maxplayers){
		if(is_user_connected(killed - DEATHMSG_SENTRY)){
			build = 1
			killed -= DEATHMSG_SENTRY
		} else if(is_user_connected(killed - DEATHMSG_DISPENSER)){
			build = 2
			killed -= DEATHMSG_DISPENSER
		} else if(is_user_connected(killed - DEATHMSG_TELEIN)){
			build = 3
			killed -= DEATHMSG_TELEIN
		} else if(is_user_connected(killed - DEATHMSG_TELEOUT)){
			build = 4
			killed -= DEATHMSG_TELEOUT
		} else {
			return;
		}
	} else if(!is_user_connected(killed)){
		return;
	}
	new killername[32], assistantname[32], killedname[32]
	get_user_name(killed, killedname, sizeof killedname - 1)
	if(is_user_alive(killer) && is_user_connected(assistant) && !gswitching_name[killer]){
		get_user_name(killer, killername, sizeof killername - 1)
		get_user_name(assistant, assistantname, sizeof assistantname - 1)
		new formated[128], parm[2]
		parm[0] = killer
		parm[1] = killed
		copy(g_nametemp[killer], sizeof g_nametemp[] - 1, killername)
		copy(g_wpnametemp[killer], sizeof g_wpnametemp[] - 1, weapon)
		format(formated, sizeof formated - 1, "%s + %s", killername, assistantname)
		engfunc(EngFunc_SetClientKeyValue, killer, engfunc(EngFunc_GetInfoKeyBuffer, killer), "name", formated)
		set_task(0.1, "deathmsg_showassist", 0, parm, 2)
		gswitching_name[killer] = true
		return;
	} else if (is_user_alive(killer) && !is_user_connected(assistant) && !gswitching_name[killed]){
		if(build > 0){
			new formated[128], parm[2]
			parm[0] = killer
			parm[1] = killed
			copy(g_nametemp[killed], sizeof g_nametemp[] - 1, killedname)
			copy(g_wpnametemp[killer], sizeof g_wpnametemp[] - 1, weapon)
			switch(build){
				case 1:format(formated, sizeof formated - 1, "Sentry(%s)", killedname)
				case 2:format(formated, sizeof formated - 1, "Dispenser(%s)", killedname)
				case 3:format(formated, sizeof formated - 1, "TeleporterIn(%s)", killedname)
				case 4:format(formated, sizeof formated - 1, "TeleporterOut(%s)", killedname)
			}
			engfunc(EngFunc_SetClientKeyValue, killed, engfunc(EngFunc_GetInfoKeyBuffer, killed), "name", formated)
			set_task(0.1, "deathmsg_showbuild", 0, parm, 2)
			gswitching_name[killed] = true
			return;
		} else {
			make_deathmsg(killer, killed, headshot, weapon)
			return;
		}
	} else if (!is_user_connected(killer) || killer == killed){
		make_deathmsg(killed, killed, headshot, weapon)
		return;
	}
	ckrun_fix_user_deadflag(killed)
}

public deathmsg_showassist(parm[]){
	if(!is_user_connected(parm[0])) return;
	if(is_user_connected(parm[1]))
		make_deathmsg(parm[0], parm[1], 0, g_wpnametemp[parm[0]])
	if(!is_user_connected(parm[1])) return;
	engfunc(EngFunc_SetClientKeyValue, parm[0], engfunc(EngFunc_GetInfoKeyBuffer, parm[0]), "name", g_nametemp[parm[0]])
	ckrun_fix_user_deadflag(parm[1])
	gswitching_name[parm[0]] = false
}

public deathmsg_showbuild(parm[]){
	if(!is_user_connected(parm[0])) return;
	if(is_user_connected(parm[1]))
		make_deathmsg(parm[0], parm[1], 0, g_wpnametemp[parm[0]])
	if(!is_user_connected(parm[1])) return;
	engfunc(EngFunc_SetClientKeyValue, parm[1], engfunc(EngFunc_GetInfoKeyBuffer, parm[1]), "name", g_nametemp[parm[1]])
	ckrun_fix_user_deadflag(parm[1])
	gswitching_name[parm[1]] = false
}

public client_print_colored(target, const message[], any:...){
	static buffer[512], i, argscount
	argscount = numargs()
	
	if (!target){
		static player
		for (player = 1; player <= g_maxplayers; player++){
			if (!is_user_connected(player))
				continue;
			static changed[5], changedcount
			changedcount = 0

			for (i = 2; i < argscount; i++)
			{
				if (getarg(i) == LANG_PLAYER)
				{
					setarg(i, 0, player)
					changed[changedcount] = i
					changedcount++
				}
			}
			vformat(buffer, sizeof buffer - 1, message, 3)

			message_begin(MSG_ONE, g_msgSayText, _, player)
			write_byte(player)
			write_string(buffer)
			message_end()

			for (i = 0; i < changedcount; i++)
				setarg(changed[i], 0, LANG_PLAYER)
		}
	} else {
		vformat(buffer, sizeof buffer - 1, message, 3)

		message_begin(MSG_ONE, g_msgSayText, _, target)
		write_byte(target)
		write_string(buffer)
		message_end()
	}
}

public think_Player(taskid){
	static id
	if(taskid > g_maxplayers)
		id = ID_PLAYER_THINK
	else
		id = taskid
	if(!(1 <= id <= g_maxplayers)) return;
	if(id == g_ctbot || id == g_tbot) return;
	remove_task(id+TASK_PLAYER_THINK, 0)
	set_task(PLAYER_THINK, "think_Player", id+TASK_PLAYER_THINK)
	if(!is_user_alive(id)) return;
	if(ghuman[id] == human_eng && !giszm[id]){//检测建造
		//步哨枪
		if(gsentry_building[id] && gsentry_percent[id] < 100){
			gsentry_percent[id] ++
			gsentry_health[id] += get_pcvar_num(cvar_build_sentry_hp_lv1) / 100
			if(gsentry_health[id] > get_pcvar_num(cvar_build_sentry_hp_lv1) * gsentry_percent[id] / 100)
				gsentry_health[id] = get_pcvar_num(cvar_build_sentry_hp_lv1) * gsentry_percent[id] / 100
		} else if (gsentry_building[id] && gsentry_percent[id] >= 100){
			ckrun_sentry_build_turret(gsentry_base[id],id)
		}
		//补给器
		if(gdispenser_building[id] && gdispenser_percent[id] < 100){
			gdispenser_percent[id] ++
			gdispenser_health[id] += get_pcvar_num(cvar_build_dispenser_hp_lv1) / 100
			if(gdispenser_health[id] > get_pcvar_num(cvar_build_dispenser_hp_lv1) * gdispenser_percent[id] / 100)
				gdispenser_health[id] = get_pcvar_num(cvar_build_dispenser_hp_lv1) * gdispenser_percent[id] / 100
		} else if (gdispenser_building[id] && gdispenser_percent[id] >= 100){
			ckrun_dispenser_completed(id)
		}
		//传送装置入口
		if(gtelein_building[id] && gtelein_percent[id] + 2 < 100){
			gtelein_percent[id] += 2
			gtelein_health[id] += get_pcvar_num(cvar_build_telein_hp_lv1) / 100
			if(gtelein_health[id] > get_pcvar_num(cvar_build_telein_hp_lv1) * gtelein_percent[id] / 100)
				gtelein_health[id] = get_pcvar_num(cvar_build_telein_hp_lv1) * gtelein_percent[id] / 100
		} else if (gtelein_building[id] && gtelein_percent[id] + 2 >= 100){
			ckrun_telein_completed(id)
		}
		//传送装置出口
		if(gteleout_building[id] && gteleout_percent[id] + 2 < 100){
			gteleout_percent[id] += 2
			gteleout_health[id] += get_pcvar_num(cvar_build_teleout_hp_lv1) / 100
			if(gteleout_health[id] > get_pcvar_num(cvar_build_teleout_hp_lv1) * gteleout_percent[id] / 100)
				gteleout_health[id] = get_pcvar_num(cvar_build_teleout_hp_lv1) * gteleout_percent[id] / 100
		} else if (gteleout_building[id] && gteleout_percent[id] + 2 >= 100){
			ckrun_teleout_completed(id)
		}
	}
	if(gflame[id] > 0){
		gflame[id] --
		gcurspeed[id] = gorispeed[id] * get_pcvar_num(cvar_wpn_slowdown_he) / 100
		FX_Flame(id)
		if(ckrun_can_damage(gflamer[id], id))
			ckrun_fakedamage(id, gflamer[id], CSW_HEGRENADE, 3, CKD_FIRE)
		else
			ckrun_fakedamage(id, id, CSW_HEGRENADE, 3, CKD_FIRE)
	} else if(gflame[id] <= 0 && gflamer[id] != 0){
		gcurspeed[id] = gorispeed[id]
		gflamer[id] = 0
	}
	if(gfrozen[id] > 0) gfrozen[id] --
	if(gpower[id] < 100 && !ginvisible[id])
		gpower[id] ++
	else if(ginvisible[id] && gpower[id] - get_pcvar_num(cvar_skill_invisible_power) > 0)
		gpower[id] -= get_pcvar_num(cvar_skill_invisible_power)
	else if(ginvisible[id] && gpower[id] - get_pcvar_num(cvar_skill_invisible_power) <= 0)
		zombie_stop_invisible(id)
	if(!giszm[id]){
		switch(ghuman[id]){
			case 2:{
				if(gminigun_spin[id] != minigun_idle) gcurspeed[id] = gorispeed[id] * get_pcvar_num(cvar_wpn_minigun_slowdown) / 100
				else gcurspeed[id] = gorispeed[id]
			}
			case 5:if(get_user_health(id) < get_pcvar_num(cvar_hm_log_hp)) fm_set_user_health(id,get_user_health(id)+1)
		}
		if(gmediced[id] == 0 && gammoed[id] == 0){
			fm_set_rendering(id,kRenderFxNone, 0,0,0, kRenderNormal, 0)
			new maxhealth = ckrun_get_user_maxhealth(id)
			if(get_user_health(id) > maxhealth)
				fm_set_user_health(id,get_user_health(id)-1)
		}
		if(gcharge_shield[id]){
			gcharge[id] -= get_pcvar_num(cvar_wpn_charge_rate)
			fm_set_rendering(id,kRenderFxGlowShell,250,125,0, kRenderNormal, 24)
		} else if(gcharge_crit[id]){
			gcharge[id] -= get_pcvar_num(cvar_wpn_charge_rate)
			fm_set_rendering(id,kRenderFxGlowShell,0,125,250, kRenderNormal, 24)
		}
		if(gcharge[id] <= 0 && (gcharge_shield[id] || gcharge_crit[id])){
			if(gcharge_crit[id]){
				gcritical_on[gammotarget[id]] = false
				funcCritical(gammotarget[id])
			}
			gcharge_shield[id] = false
			gcharge_crit[id] = false
			gcharge[id] = 0
			engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_charge_off, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		}
	}
}
//----------------辅助电源系统------------//
//---------------地图初始化函数-------------//
stock init_CollectSpawns(const classname[]){
	static ent
	ent = -1;
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", classname)) != 0){
		static Float:originF[3]
		pev(ent, pev_origin, originF);
		g_spawns[g_spawnCount][0] = originF[0];
		g_spawns[g_spawnCount][1] = originF[1];
		g_spawns[g_spawnCount][2] = originF[2];

		g_spawnCount++;

		if(g_spawnCount >= sizeof g_spawns) break;
	}
}

stock init_CapturePoint(entity){
	if(!pev_valid(entity)) return;
	RegisterHamFromEntity(Ham_Touch, entity, "fw_CpTouch")
	g_cp_points[g_cp_pointnums] = entity//变量关联实体
	g_cp_progress[g_cp_pointnums] = 0
	set_pev(entity, MAP_CPNUMS, g_cp_pointnums)//实体关联变量
	g_cp_pointnums ++
}

stock init_SupplyDoor(entity){
	if(!pev_valid(entity)) return;
	RegisterHamFromEntity(Ham_Touch, entity, "fw_SupplyDoorTouch")
}
//---------------传送到出生点-------------//
public tele_to_spawn(id)
{
	if (!g_spawnCount) // no spawns
		return;

	static sp_index, i
	sp_index = random_num(0, g_spawnCount-1); // random spawn
	
	for (i = sp_index + 1; i != 999; i++)
	{
		if (i >= g_spawnCount) i = 0;
		
		if (i == sp_index) break;

		if (is_hull_vacant(g_spawns[i],HULL_HUMAN))
		{
			engfunc(EngFunc_SetOrigin, id, g_spawns[i]);
			break;
		}
	}
}

stock is_hull_vacant(Float:origin[3], hull){
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, 0, 0);

	if (!get_tr2(0, TR_StartSolid) && !get_tr2(0, TR_AllSolid) && get_tr2(0, TR_InOpen))
		return true;
	
	return false;
}

stock bool:is_on_moveable(id, Float:origin[3]){
	new Float:target[3], Float:hit[3]
	xs_vec_copy(origin, target)
	target[2] -= 2048.0
	new ent = fm_trace_line(id, origin, target, hit)
	if(!pev_valid(ent)) return false
	new classname[64]
	pev(ent, pev_classname, classname, sizeof classname - 1)
	if(equal(classname, "func_traintrack") || equal(classname, "func_train") || equal(classname, "func_plat") || equal(classname, "func_door") || equal(classname, "func_pushable"))
		return true
	return false
}
//---------------获取随机玩家-------------//
stock get_random_player(alive,team){
	new i
	new player_index = random_num(1, g_maxplayers-1)
	for (i = player_index + 1; i != g_maxplayers; i++){
		// 从头开始循环
		if (i >= g_maxplayers) i = 0;
		
		// 循环结束，无可用玩家
		if (i == player_index){
			i = 0
			break;
		}
		// 队伍正确?
		if(i != g_tbot && i != g_ctbot){
			if (team == 0) {
				if (is_user_alive(i) && alive == 1)
					break;
				if (!is_user_alive(i) && alive == 0)
					break;
			} else if (get_user_team(i) == team){
				if (is_user_alive(i) && alive == 1)
					break;
				if (!is_user_alive(i) && alive == 0)
					break;
			}
		}
	}
	return i
}
//---------------队伍平衡系统-----------//thanks for MeRcyLeZZ
public team_balancer(){
	new playersnum, x
	for (x = 1; x <= g_maxplayers; x++){
		if(is_user_connected(x) && get_user_team(x) != 3 && get_user_team(x) != 0)
			playersnum ++
	}
	if (playersnum < 1) return;
	new g_team[33], tnum
	new maxt = playersnum/2
	for (x = 1; x<= g_maxplayers; x++)
		g_team[x] = CS_TEAM_CT
	while (tnum < maxt){
		if (x < g_maxplayers)
		x++
		else
		x = 1
		if (random_num(0, 1) && g_team[x] == CS_TEAM_CT && is_user_connected(x) && get_user_team(x) != 3 && get_user_team(x) != 0){
			g_team[x] = CS_TEAM_T
			tnum++
		}
	}
	for (x = 1; x <= g_maxplayers; x++)
		if(is_user_connected(x) && get_user_team(x) != 3 && get_user_team(x) != 0 && x != g_ctbot && x != g_tbot)
			fm_set_user_team(x, g_team[x])
}
//---------------队伍平衡系统-----------//

//------------显示HUD----------------//

public ckrun_showhud_center(taskid){
	static id
	if(taskid > g_maxplayers)
		id = ID_SHOWCENTER
	else
		id = taskid
	remove_task(id+TASK_SHOWCENTER, 0)
	set_task(CENTER_REFRESH, "ckrun_showhud_center", id+TASK_SHOWCENTER)
	if(is_user_bot(id) || !(1 <= id <= g_maxplayers)) return;
	if(!is_user_connected(id)) return;
	//ClearSyncHud(id, g_hudcenter)
	new len = 0 , target
	new status[256],name[32]
	set_hudmessage(250, 0, 0, -1.0, 0.5, 0, 6.0, CENTER_REFRESH + 1.0, 0.0, 0.0, CENTER_CHANNEL)
	if(gmediced[id] != 0){
		target = gmediced[id]
		get_user_name(target,name,31)
		len += formatex(status[len], sizeof status - 1 - len,"%L %L^n", id, "HUD_MEDICED",name, id, "HUD_STATUS_CHARGE",gcharge[gmediced[id]]/10)
		if(gcharge_shield[target])
			len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_STATUS_SHIELD")
		if(gcharge_crit[target])
			len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_STATUS_CRITICAL")
		ShowSyncHudMsg(id, g_hudcenter, "%s",status)
	} else if(gammoed[id] != 0){
		target = gammoed[id]
		get_user_name(target,name,31)
		len += formatex(status[len], sizeof status - 1 - len,"%L %L^n", id, "HUD_AMMOED",name, id, "HUD_STATUS_CHARGE",gcharge[gammoed[id]]/10)
		if(gcharge_shield[target])
			len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_STATUS_SHIELD")
		if(gcharge_crit[target])
			len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_STATUS_CRITICAL")
		ShowSyncHudMsg(id, g_hudcenter, "%s",status)
	} else if(gmedicing[id]){
		target = gmedictarget[id]
		get_user_name(target,name,31)
		new ammo = ckrun_get_user_ammo(target)
		if(ammo != -1)
			len += formatex(status[len], sizeof status - 1 - len,"%L^n", id, "HUD_MEDICING",name,get_user_health(target),ammo)
		if(ammo == -1)
			len += formatex(status[len], sizeof status - 1 - len,"%L^n", id, "HUD_MEDICING_NOAMMO",name,get_user_health(target))
		if(ghuman[target] == 5 && !giszm[target])
			len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_STATUS_CHARGE", gcharge[id]/10)
		if(gcharge_shield[id])
			len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_STATUS_SHIELD")
		if(gcharge_crit[id])
			len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_STATUS_CRITICAL")
		ShowSyncHudMsg(id, g_hudcenter, "%s",status)
	} else if(gammoing[id]){
		target = gammotarget[id]
		get_user_name(target,name,31)
		new ammo = ckrun_get_user_ammo(target)
		if(ammo != -1)
			len += formatex(status[len], sizeof status - 1 - len,"%L^n", id, "HUD_AMMOING",name,get_user_health(target),ammo)
		if(ammo == -1)
			len += formatex(status[len], sizeof status - 1 - len,"%L^n", id, "HUD_AMMOING_NOAMMO",name,get_user_health(target))
		if(ghuman[target] == 5 && !giszm[target])
			len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_STATUS_CHARGE", gcharge[id]/10)
		if(gcharge_shield[id])
			len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_STATUS_SHIELD")
		if(gcharge_crit[id])
			len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_STATUS_CRITICAL")
		ShowSyncHudMsg(id, g_hudcenter, "%s",status)
	} else if(is_user_alive(gaiming[id]) && gaiming_a_build[id] == 0){
		target = gaiming[id]
		get_user_name(target,name,31)
		new ammo = ckrun_get_user_ammo(target)
		if(gdisguising[target]){
			get_user_name(gdisguise_target[target],name,31)
			len += formatex(status[len], sizeof status - 1 - len,"%L^n", id, "HUD_AIM",name,get_user_health(gdisguise_target[target]),100)
		}
		if(!gdisguising[target] && ammo != -1)
			len += formatex(status[len], sizeof status - 1 - len,"%L^n", id, "HUD_AIM",name,get_user_health(target),ammo)
		if(!gdisguising[target] && ammo == -1)
			len += formatex(status[len], sizeof status - 1 - len,"%L^n", id, "HUD_AIM_NOAMMO",name,get_user_health(target))
		if(ghuman[target] == 5 && !giszm[target])
			len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_STATUS_CHARGE", gcharge[target]/10)
		if(gcharge_shield[target] || gcharge_shield[gmediced[target]])
			len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_STATUS_SHIELD")
		if(gcharge_crit[target] || gcharge_crit[gmediced[target]])
			len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_STATUS_CRITICAL")
		ShowSyncHudMsg(id, g_hudcenter, "%s",status)
	} else if((1 <= gaiming[id] <= g_maxplayers) && gaiming_a_build[id] == 1){
		target = gaiming[id]
		get_user_name(target,name,31)
		if(gsentry_building[target])
			len += formatex(status[len], sizeof status - 1 - len, "%L%L%L", id, "HUD_SENTRY", id, "HUD_BUILD_OWNER", name, id, "HUD_BUILD_ING", gsentry_percent[target])
		if(!gsentry_building[target]){
			len += formatex(status[len], sizeof status - 1 - len, "%L%L%L^n", id, "HUD_SENTRY", id, "HUD_BUILD_OWNER", name, id, "HUD_BUILD_LEVEL", gsentry_level[target])
			switch(gsentry_level[target]){
				case 1: {
					len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_BUILD_UPGRADE", gsentry_upgrade[target], get_pcvar_num(cvar_build_sentry_cost_lv2))
					len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_BUILD_HEALTH", gsentry_health[target], get_pcvar_num(cvar_build_sentry_hp_lv1))
					len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_BUILD_AMMO", gsentry_ammo[target], get_pcvar_num(cvar_build_sentry_ammo_lv1))
				}
				case 2: {
					len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_BUILD_UPGRADE", gsentry_upgrade[target], get_pcvar_num(cvar_build_sentry_cost_lv3))
					len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_BUILD_HEALTH", gsentry_health[target], get_pcvar_num(cvar_build_sentry_hp_lv2))
					len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_BUILD_AMMO", gsentry_ammo[target], get_pcvar_num(cvar_build_sentry_ammo_lv2))
				}
				case 3: {
					len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_BUILD_HEALTH", gsentry_health[target], get_pcvar_num(cvar_build_sentry_hp_lv3))
					len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_BUILD_AMMO", gsentry_ammo[target], get_pcvar_num(cvar_build_sentry_ammo_lv3))
				}
			}
		}
		ShowSyncHudMsg(id, g_hudcenter, "%s",status)
	} else if((1 <= gaiming[id] <= g_maxplayers) && gaiming_a_build[id] == 2){
		target = gaiming[id]
		get_user_name(target,name,31)
		if(gdispenser_building[target])
			len += formatex(status[len], sizeof status - 1 - len, "%L%L%L", id, "HUD_DISPENSER", id, "HUD_BUILD_OWNER", name, id, "HUD_BUILD_ING", gdispenser_percent[target])
		if(!gdispenser_building[target]){
			len += formatex(status[len], sizeof status - 1 - len, "%L%L%L^n", id, "HUD_DISPENSER", id, "HUD_BUILD_OWNER", name, id, "HUD_BUILD_LEVEL", gdispenser_level[target])
			switch(gdispenser_level[target]){
				case 1: {
					len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_BUILD_UPGRADE", gdispenser_upgrade[target], get_pcvar_num(cvar_build_dispenser_cost_lv2))
					len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_BUILD_HEALTH", gdispenser_health[target], get_pcvar_num(cvar_build_dispenser_hp_lv1))
					len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_BUILD_AMMO", gdispenser_ammo[target], get_pcvar_num(cvar_build_dispenser_ammo_lv1))
				}
				case 2: {
					len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_BUILD_UPGRADE", gdispenser_upgrade[target], get_pcvar_num(cvar_build_dispenser_cost_lv3))
					len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_BUILD_HEALTH", gdispenser_health[target], get_pcvar_num(cvar_build_dispenser_hp_lv2))
					len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_BUILD_AMMO", gdispenser_ammo[target], get_pcvar_num(cvar_build_dispenser_ammo_lv2))
				}
				case 3: {
					len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_BUILD_HEALTH", gdispenser_health[target], get_pcvar_num(cvar_build_dispenser_hp_lv3))
					len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_BUILD_AMMO", gdispenser_ammo[target], get_pcvar_num(cvar_build_dispenser_ammo_lv3))
				}
			}
		}
		ShowSyncHudMsg(id, g_hudcenter, "%s",status)
	} else if((1 <= gaiming[id] <= g_maxplayers) && gaiming_a_build[id] == 3){
		target = gaiming[id]
		get_user_name(target,name,31)
		if(gtelein_building[target])
			len += formatex(status[len], sizeof status - 1 - len, "%L%L%L", id, "HUD_TELEIN", id, "HUD_BUILD_OWNER", name, id, "HUD_BUILD_ING", gtelein_percent[target])
		if(!gtelein_building[target]){
			len += formatex(status[len], sizeof status - 1 - len, "%L%L%L^n", id, "HUD_TELEIN", id, "HUD_BUILD_OWNER", name, id, "HUD_BUILD_LEVEL", gtele_level[target])
			switch(gtele_level[target]){
				case 1: {
					len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_BUILD_UPGRADE", gtele_upgrade[target], get_pcvar_num(cvar_build_tele_cost_lv2))
					len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_BUILD_HEALTH", gtelein_health[target], get_pcvar_num(cvar_build_telein_hp_lv1))
				}
				case 2: {
					len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_BUILD_UPGRADE", gtele_upgrade[target], get_pcvar_num(cvar_build_tele_cost_lv3))
					len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_BUILD_HEALTH", gtelein_health[target], get_pcvar_num(cvar_build_telein_hp_lv2))
				}
				case 3: {
					len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_BUILD_HEALTH", gtelein_health[target], get_pcvar_num(cvar_build_telein_hp_lv3))
				}
			}
			len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_BUILD_RELOAD", gtele_reload[target])
		}
		ShowSyncHudMsg(id, g_hudcenter, "%s",status)
	} else if((1 <= gaiming[id] <= g_maxplayers) && gaiming_a_build[id] == 4){
		target = gaiming[id]
		get_user_name(target,name,31)
		if(gteleout_building[target])
			len += formatex(status[len], sizeof status - 1 - len, "%L%L%L", id, "HUD_TELEOUT", id, "HUD_BUILD_OWNER", name, id, "HUD_BUILD_ING", gteleout_percent[target])
		if(!gteleout_building[target]){
			len += formatex(status[len], sizeof status - 1 - len, "%L%L%L^n", id, "HUD_TELEOUT", id, "HUD_BUILD_OWNER", name, id, "HUD_BUILD_LEVEL", gtele_level[target])
			switch(gtele_level[target]){
				case 1: {
					len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_BUILD_UPGRADE", gtele_upgrade[target], get_pcvar_num(cvar_build_tele_cost_lv2))
					len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_BUILD_HEALTH", gteleout_health[target], get_pcvar_num(cvar_build_teleout_hp_lv1))
				}
				case 2: {
					len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_BUILD_UPGRADE", gtele_upgrade[target], get_pcvar_num(cvar_build_tele_cost_lv3))
					len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_BUILD_HEALTH", gteleout_health[target], get_pcvar_num(cvar_build_teleout_hp_lv2))
				}
				case 3: {
					len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_BUILD_HEALTH", gteleout_health[target], get_pcvar_num(cvar_build_teleout_hp_lv3))
				}
			}
			len += formatex(status[len], sizeof status - 1 - len, "%L", id, "HUD_BUILD_RELOAD", gtele_reload[target])
		}
		ShowSyncHudMsg(id, g_hudcenter, "%s",status)
	}
}

public ckrun_showhud_status(taskid){
	static id
	if(taskid > g_maxplayers)
		id = ID_SHOWHUD
	else
		id = taskid
	remove_task(id+TASK_SHOWHUD, 0)
	set_task(HUD_REFRESH, "ckrun_showhud_status", id+TASK_SHOWHUD)
	//状态文字显示//
	if(!(1 <= id <= g_maxplayers)) return;
	if(is_user_bot(id)) return;
	new bool:spec, spectator
	if(!is_user_alive(id)){
		spectator = id
		id = pev(id, pev_iuser2)
		spec = true
		if (!is_user_alive(id)){
			//ClearSyncHud(id, g_hudsync)
			//ClearSyncHud(id, g_hudbuild)
			return;
		}
	}
	//ClearSyncHud(id, g_hudsync)
	//ClearSyncHud(id, g_hudbuild)
	new hudlen = 0
	new hudstatus[512]
	if(spec)
		set_hudmessage(200, 250, 0, 0.02, 0.77, 0, 6.0, HUD_REFRESH + 1.0, 0.0, 0.0, STATUS_CHANNEL)
	else
		set_hudmessage(200, 250, 0, 0.02, 0.85, 0, 6.0, HUD_REFRESH + 1.0, 0.0, 0.0, STATUS_CHANNEL)
	//僵尸//
	if(giszm[id]){
		switch(gzombie[id]){
			case 1:hudlen += formatex(hudstatus[hudlen], sizeof hudstatus - 1 - hudlen, "%L", id, "HUD_FAST", get_user_health(id))
			case 2:hudlen += formatex(hudstatus[hudlen], sizeof hudstatus - 1 - hudlen, "%L", id, "HUD_GRAVITY", get_user_health(id))
			case 3:hudlen += formatex(hudstatus[hudlen], sizeof hudstatus - 1 - hudlen, "%L", id, "HUD_CLASSIC", get_user_health(id))
			case 4:hudlen += formatex(hudstatus[hudlen], sizeof hudstatus - 1 - hudlen, "%L", id, "HUD_JUMP", get_user_health(id))
			case 5:hudlen += formatex(hudstatus[hudlen], sizeof hudstatus - 1 - hudlen, "%L", id, "HUD_VIS", get_user_health(id))
		}
		if(gdisguising[id])
			hudlen += formatex(hudstatus[hudlen], sizeof hudstatus - 1 - hudlen, "%L", id, "HUD_STATUS_DISGUISE")
		if(gdodgeon[id])
			hudlen += formatex(hudstatus[hudlen], sizeof hudstatus - 1 - hudlen, "%L", id, "HUD_STATUS_DODGEON")
		if(glongjumpon[id])
			hudlen += formatex(hudstatus[hudlen], sizeof hudstatus - 1 - hudlen, "%L", id, "HUD_STATUS_LONGJUMPON")
		if(ginvisible[id])
			hudlen += formatex(hudstatus[hudlen], sizeof hudstatus - 1 - hudlen, "%L", id, "HUD_STATUS_INVISIBLE")
		if(gflame[id] > 0)
			hudlen += formatex(hudstatus[hudlen], sizeof hudstatus - 1 - hudlen, "%L", id, "HUD_STATUS_FIRE")
		hudlen += formatex(hudstatus[hudlen], sizeof hudstatus - 1 - hudlen, "^n%L", id, "HUD_POWER", gpower[id])
		if(spec){
			new specname[48]
			get_user_name(id, specname, sizeof specname - 1)
			ShowSyncHudMsg(spectator, g_hudsync, "%L^n%s", LANG_PLAYER, "HUD_SPECTATOR", specname, hudstatus)
		} else {
			ShowSyncHudMsg(id, g_hudsync, "%s", hudstatus)
		}
	} else {
	//人类//
	//第一行--兵种+生命+(状态)//
		switch(ghuman[id]){
			case 1:hudlen += formatex(hudstatus[hudlen], sizeof hudstatus - 1 - hudlen,"%L", id, "HUD_SCOUT", get_user_health(id))
			case 2:hudlen += formatex(hudstatus[hudlen], sizeof hudstatus - 1 - hudlen,"%L", id, "HUD_HEAVY", get_user_health(id))	
			case 3:hudlen += formatex(hudstatus[hudlen], sizeof hudstatus - 1 - hudlen,"%L", id, "HUD_RPG", get_user_health(id))
			case 4:hudlen += formatex(hudstatus[hudlen], sizeof hudstatus - 1 - hudlen,"%L", id, "HUD_SNIPE", get_user_health(id))
			case 5:hudlen += formatex(hudstatus[hudlen], sizeof hudstatus - 1 - hudlen,"%L", id, "HUD_LOG", get_user_health(id))
			case 6:hudlen += formatex(hudstatus[hudlen], sizeof hudstatus - 1 - hudlen,"%L", id, "HUD_ENG", get_user_health(id))
		}
		if(gcharge_shield[gmediced[id]] || gcharge_shield[gammoed[id]] || gcharge_shield[id])
			hudlen += formatex(hudstatus[hudlen], sizeof hudstatus - 1 - hudlen, "%L", id, "HUD_STATUS_SHIELD")
		if(gcharge_crit[gmediced[id]] || gcharge_crit[gammoed[id]] || gcharge_crit[id])
			hudlen += formatex(hudstatus[hudlen], sizeof hudstatus - 1 - hudlen, "%L", id, "HUD_STATUS_CRITICAL")
		hudlen += formatex(hudstatus[hudlen], sizeof hudstatus - 1 - hudlen, "^n%L", id, "HUD_WEAPON")
		//第二行--武器+弹药//
		new wpname[16],clip,ammo,wep = get_user_weapon(id,clip,ammo)
		ckrun_get_user_weapon_name(id,wpname,15)

		hudlen += formatex(hudstatus[hudlen], sizeof hudstatus - 1 - hudlen, "%s", wpname)

		if(wep == CSW_C4 && ghuman[id] == 3)
			hudlen += formatex(hudstatus[hudlen], sizeof hudstatus - 1 - hudlen, "%L", id, "HUD_AMMO", grpgclip[id], grpgammo[id])
		else if(clip >= 0 && ammo >= 0)
			hudlen += formatex(hudstatus[hudlen], sizeof hudstatus - 1 - hudlen, "%L", id, "HUD_AMMO", clip, fm_get_user_bpammo(id,wep))
		//第三行--电源+(蓄能)+(补给)+(电荷)//
		hudlen += formatex(hudstatus[hudlen], sizeof hudstatus - 1 - hudlen, "^n%L", id, "HUD_POWER", gpower[id])
		switch(ghuman[id]){
			case 4:hudlen += formatex(hudstatus[hudlen], sizeof hudstatus - 1 - hudlen, "%L", id, "HUD_SNIPEPOWER", gsnipecharge[id])
			case 5:hudlen += formatex(hudstatus[hudlen], sizeof hudstatus - 1 - hudlen, "%L %L", id, "HUD_AMMOSTORE", glogammo[id], id, "HUD_CHARGE", gcharge[id]/10)
			case 6:hudlen += formatex(hudstatus[hudlen], sizeof hudstatus - 1 - hudlen, "%L", id, "HUD_METALSTORE", gengmetal[id])
		}
		if(spec){
			new specname[48]
			get_user_name(id, specname, sizeof specname - 1)
			ShowSyncHudMsg(spectator, g_hudsync, "%L^n%s", LANG_PLAYER, "HUD_SPECTATOR", specname, hudstatus)
		} else {
			ShowSyncHudMsg(id, g_hudsync, "%s", hudstatus)
		}

		//建筑状态
		if(ghuman[id] != human_eng || giszm[id]){
			//ClearSyncHud(id, g_hudbuild)
			return;
		}
		new buildlen = 0
		new buildstatus[256]
		set_hudmessage(200, 100, 0, -1.0, 0.07, 0, 6.0, HUD_REFRESH + 1.0, 0.0, 0.0, BUILD_CHANNEL)
		if(!ghavesentry[id] && !gsentry_building[id])
			buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L%L^n", id, "HUD_SENTRY", id, "HUD_BUILD_NO")
		if(ghavesentry[id] && gsentry_building[id])
			buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L%L^n", id, "HUD_SENTRY", id, "HUD_BUILD_ING", gsentry_percent[id])
		if(ghavesentry[id] && !gsentry_building[id]){
			buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L", id, "HUD_SENTRY")
			buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L", id, "HUD_BUILD_LEVEL", gsentry_level[id])
			switch(gsentry_level[id]){
				case 1: {
					buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L", id, "HUD_BUILD_UPGRADE", gsentry_upgrade[id], get_pcvar_num(cvar_build_sentry_cost_lv2))
					buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L", id, "HUD_BUILD_HEALTH", gsentry_health[id], get_pcvar_num(cvar_build_sentry_hp_lv1))
					buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L^n", id, "HUD_BUILD_AMMO", gsentry_ammo[id], get_pcvar_num(cvar_build_sentry_ammo_lv1))
				}
				case 2: {
					buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L", id, "HUD_BUILD_UPGRADE", gsentry_upgrade[id], get_pcvar_num(cvar_build_sentry_cost_lv3))
					buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L", id, "HUD_BUILD_HEALTH", gsentry_health[id], get_pcvar_num(cvar_build_sentry_hp_lv2))
					buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L^n", id, "HUD_BUILD_AMMO", gsentry_ammo[id], get_pcvar_num(cvar_build_sentry_ammo_lv2))
				}
				case 3: {
					buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L", id, "HUD_BUILD_HEALTH", gsentry_health[id], get_pcvar_num(cvar_build_sentry_hp_lv3))
					buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L^n", id, "HUD_BUILD_AMMO", gsentry_ammo[id], get_pcvar_num(cvar_build_sentry_ammo_lv3))
				}
			}
		}
		if(!ghavedispenser[id] && !gdispenser_building[id])
			buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L%L^n", id, "HUD_DISPENSER", id, "HUD_BUILD_NO")
		if(ghavedispenser[id] && gdispenser_building[id])
			buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L%L^n", id, "HUD_DISPENSER", id, "HUD_BUILD_ING", gdispenser_percent[id])
		if(ghavedispenser[id] && !gdispenser_building[id]){
			buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L", id, "HUD_DISPENSER")
			buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L", id, "HUD_BUILD_LEVEL", gdispenser_level[id])
			switch(gdispenser_level[id]){
				case 1: {
					buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L", id, "HUD_BUILD_UPGRADE", gdispenser_upgrade[id], get_pcvar_num(cvar_build_dispenser_cost_lv2))
					buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L", id, "HUD_BUILD_HEALTH", gdispenser_health[id], get_pcvar_num(cvar_build_dispenser_hp_lv1))
					buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L^n", id, "HUD_BUILD_AMMO", gdispenser_ammo[id], get_pcvar_num(cvar_build_dispenser_ammo_lv1))
				}
				case 2: {
					buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L", id, "HUD_BUILD_UPGRADE", gdispenser_upgrade[id], get_pcvar_num(cvar_build_dispenser_cost_lv3))
					buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L", id, "HUD_BUILD_HEALTH", gdispenser_health[id], get_pcvar_num(cvar_build_dispenser_hp_lv2))
					buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L^n", id, "HUD_BUILD_AMMO", gdispenser_ammo[id], get_pcvar_num(cvar_build_dispenser_ammo_lv2))
				}
				case 3: {
					buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L", id, "HUD_BUILD_HEALTH", gdispenser_health[id], get_pcvar_num(cvar_build_dispenser_hp_lv3))
					buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L^n", id, "HUD_BUILD_AMMO", gdispenser_ammo[id], get_pcvar_num(cvar_build_dispenser_ammo_lv3))
				}
			}
		}
		if(!ghavetelein[id] && !gtelein_building[id])
			buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L%L^n", id, "HUD_TELEIN", id, "HUD_BUILD_NO")
		if(ghavetelein[id] && gtelein_building[id])
			buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L%L^n", id, "HUD_TELEIN", id, "HUD_BUILD_ING", gtelein_percent[id])
		if(ghavetelein[id] && !gtelein_building[id]){
			buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L", id, "HUD_TELEIN")
			buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L", id, "HUD_BUILD_LEVEL", gtele_level[id])
			switch(gtele_level[id]){
				case 1: buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L^n", id, "HUD_BUILD_HEALTH", gtelein_health[id], get_pcvar_num(cvar_build_telein_hp_lv1))
				case 2: buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L^n", id, "HUD_BUILD_HEALTH", gtelein_health[id], get_pcvar_num(cvar_build_telein_hp_lv2))
				case 3: buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L^n", id, "HUD_BUILD_HEALTH", gtelein_health[id], get_pcvar_num(cvar_build_telein_hp_lv3))
			}
			if(!(ghaveteleout[id] && !gteleout_building[id])){
				buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L", id, "HUD_BUILD_LEVEL", gtele_level[id])
				if(gtele_level[id] == 1)
					buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L", id, "HUD_BUILD_UPGRADE", gtele_upgrade[id], get_pcvar_num(cvar_build_tele_cost_lv2))
				else if(gtele_level[id] == 2)
					buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L", id, "HUD_BUILD_UPGRADE", gtele_upgrade[id], get_pcvar_num(cvar_build_tele_cost_lv3))
				buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L^n", id, "HUD_BUILD_RELOAD", gtele_reload[id])
			}
		}
		if(!ghaveteleout[id] && !gteleout_building[id])
			buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L%L^n", id, "HUD_TELEOUT", id, "HUD_BUILD_NO")
		if(ghaveteleout[id] && gteleout_building[id])
			buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L%L^n", id, "HUD_TELEOUT", id, "HUD_BUILD_ING", gteleout_percent[id])
		if(ghaveteleout[id] && !gteleout_building[id]){
			buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L", id, "HUD_TELEOUT")
			switch(gtele_level[id]){
				case 1: buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L", id, "HUD_BUILD_HEALTH", gteleout_health[id], get_pcvar_num(cvar_build_teleout_hp_lv1))
				case 2: buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L", id, "HUD_BUILD_HEALTH", gteleout_health[id], get_pcvar_num(cvar_build_teleout_hp_lv2))
				case 3: buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L", id, "HUD_BUILD_HEALTH", gteleout_health[id], get_pcvar_num(cvar_build_teleout_hp_lv3))
			}
			if(!(ghavetelein[id] && !gtelein_building[id])){
				buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L", id, "HUD_BUILD_LEVEL", gtele_level[id])
				if(gtele_level[id] == 1)
					buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L", id, "HUD_BUILD_UPGRADE", gtele_upgrade[id], get_pcvar_num(cvar_build_tele_cost_lv2))
				else if(gtele_level[id] == 2)
					buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L", id, "HUD_BUILD_UPGRADE", gtele_upgrade[id], get_pcvar_num(cvar_build_tele_cost_lv3))
				buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L^n", id, "HUD_BUILD_RELOAD", gtele_reload[id])
			}
		}
		if(ghavetelein[id] && !gtelein_building[id] && ghaveteleout[id] && !gteleout_building[id]){
			buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L", id, "HUD_BUILD_LEVEL", gtele_level[id])
			if(gtele_level[id] == 1)
				buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L", id, "HUD_BUILD_UPGRADE", gtele_upgrade[id], get_pcvar_num(cvar_build_tele_cost_lv2))
			else if(gtele_level[id] == 2)
				buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L", id, "HUD_BUILD_UPGRADE", gtele_upgrade[id], get_pcvar_num(cvar_build_tele_cost_lv3))
			buildlen += formatex(buildstatus[buildlen], sizeof buildstatus - 1 - buildlen, "%L^n", id, "HUD_BUILD_RELOAD", gtele_reload[id])
		}
		if(spec){
			new specname[48]
			get_user_name(id, specname, sizeof specname - 1)
			ShowSyncHudMsg(spectator, g_hudbuild, "%L^n%s", LANG_PLAYER, "HUD_SPECTATOR", specname, buildstatus)
		} else {
			ShowSyncHudMsg(id, g_hudbuild, "%s", buildstatus)
		}
	}
}

public ckrun_showhud_timer(){
	//ClearSyncHud(0, g_hudtimer)
	set_hudmessage(100, 200, 0, -1.0, 0.33, 0, 6.0, TIMER_REFRESH + 1.0, 0.0, 0.0, TIMER_CHANNEL)
	new len = 0
	new text[256]
	switch(g_round){
		case round_setup: len += formatex(text[len], sizeof text - 1 - len, "[ %L ]", LANG_PLAYER, "NAME_ROUND_SETUP")
		case round_start: len += formatex(text[len], sizeof text - 1 - len, "[ %L ]", LANG_PLAYER, "NAME_ROUND_START")
		case round_zombie: len += formatex(text[len], sizeof text - 1 - len, "[ %L ]", LANG_PLAYER, "NAME_ROUND_ZOMBIE")
		case round_end: len += formatex(text[len], sizeof text - 1 - len, "[ %L ]", LANG_PLAYER, "NAME_ROUND_END")
	}
	new timeminutes = g_roundtime / 60
	new timeseconds = g_roundtime - timeminutes * 60
	if(g_roundtime < 60)
		len += formatex(text[len], sizeof text - 1 - len, "%L : [ %d ]", LANG_PLAYER, "NAME_ROUND_TIME", g_roundtime)
	else if(timeseconds < 10)
		len += formatex(text[len], sizeof text - 1 - len, "%L : [ %d : 0%d ]", LANG_PLAYER, "NAME_ROUND_TIME", timeminutes, timeseconds)
	else
		len += formatex(text[len], sizeof text - 1 - len, "%L : [ %d : %d ]", LANG_PLAYER, "NAME_ROUND_TIME", timeminutes, timeseconds)
	new map_obj[256]
	len = 0
	switch(g_gamemode){
		case mode_normal : len += formatex(map_obj[len], sizeof map_obj - 1 - len, "%L^n", LANG_PLAYER, "OBJ_NORMAL_NAME")
		case mode_capture :{
			new i, progress, need
			len += formatex(map_obj[len], sizeof map_obj - 1 - len, "%L", LANG_PLAYER, "OBJ_CP_NAME")
			for(i = 0; i < g_cp_pointnums; i++){
				progress = g_cp_progress[i]
				need = pev(g_cp_points[i], MAP_DISPATCH2)
				len += formatex(map_obj[len], sizeof map_obj - 1 - len, "^n%L", LANG_PLAYER, "OBJ_CP_POINT", i+1, progress / 10)
				if(progress >= 1000)
					len += formatex(map_obj[len], sizeof map_obj - 1 - len, "^%L", LANG_PLAYER, "OBJ_CP_CAPTURED")
				else if (need > g_cp_local)
					len += formatex(map_obj[len], sizeof map_obj - 1 - len, "^%L", LANG_PLAYER, "OBJ_CP_LOCKED")
			}
		}
		case mode_ctflag : len += formatex(map_obj[len], sizeof map_obj - 1 - len, "%L", LANG_PLAYER, "OBJ_CTF_NAME")
		case mode_payload : len += formatex(map_obj[len], sizeof map_obj - 1 - len, "%L", LANG_PLAYER, "OBJ_PL_NAME")
	}
	ShowSyncHudMsg(0, g_hudtimer, "%s^n%s^n%s^n^n^n^n^n^n^n^n^n^n^n%s^n^n^n%s", g_text1, g_text2, g_text3, map_obj, text)
	message_begin(MSG_ALL, g_msgRoundTime)
	write_short(g_roundtime)
	message_end()
	set_task(TIMER_REFRESH, "ckrun_showhud_timer")
}

public round_timer(){
	switch(g_round){
		case round_setup: g_roundtime --
		case round_start: g_roundtime --
		case round_zombie: g_roundtime --
	}
	g_gametime ++
	if(g_roundtime <= 0)
		check_end()
	remove_task(TASK_ROUND_TIMER, 0)
	set_task(1.0, "round_timer", TASK_ROUND_TIMER)
}
//------------HUD显示----------------//
//==============僵尸技能=============//
public zombie_skill(id){
	if(!is_user_alive(id) || is_user_bot(id)) return;
	if (!gskill_ready[id]) return;
	switch(gzombie[id]){
		case 1 : zombie_skill_longjump(id)
		case 2 : zombie_skill_airblast(id)
		case 3 : return;
		case 4 : zombie_skill_dodge(id)
		case 5 : zombie_skill_disguise(id)
	}
}
//by hzqst
Float:math_X12(Float:x,Float:angle,Float:distance){
	return x + xs_cos(angle, degrees) * distance
}
Float:math_Y12(Float:y,Float:angle,Float:distance){
	return y + xs_sin(angle, degrees) * distance
}
Float:math_AngleFix(Float:in){
	if(in > 180.0) in -= 360.0
	else if(in < -180.0) in += 360.0
	return in
}
/*
Float:math_GetDistance(Float:x1, Float:y1, Float:x2, Float:y2){
	return xs_sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1))
}
Float:math_GetAngle(Float:x1, Float:y1, Float:x2, Float:y2){
	return xs_rad2deg( xs_atan2(y2 - y1, x2 - x1, radian) )
}
*/
//by hzqst
public bool:moonslash_check(id){
	if(!giszm[id]) return false
	if(gzombie[id] != zombie_fast) return false
	if(!gskill_ready[id]) return false
	if(gknife[id] != knife_moonstar) return false
	if(gpower[id] < get_pcvar_num(cvar_skill_moonstar_power)) return false
	return true
}
public moonslash_effect(id){
	gpower[id] -= get_pcvar_num(cvar_skill_moonstar_power)
	gskill_ready[id] = false
	ckrun_showhud_status(id)
	set_task(1.5, "zombie_skill_reload", id+TASK_ZOMBIE_SKILL)
}
public moonslash_blink(id){
	new target = gmoonslash_target[id];
	if(!is_user_alive(target)){
		gmoonslash_blink[id] = 0
		return;
	}
	new Float:velocity[3];
	new Float:id_origin[3];
	new Float:target_origin[3];
	pev(id, pev_origin, id_origin);
	pev(target, pev_origin, target_origin);
	fm_set_entity_aim(id, target_origin);
	get_speed_vector(id_origin, target_origin, 1000.0, velocity)
	set_pev(id, pev_velocity, velocity);
}
public moonslash_slash(id){
	new wpnent = ham_get_wpnentity(id, CSW_KNIFE)
	if(!pev_valid(wpnent)) return
	set_pev(id, pev_velocity, {0.0,0.0,0.0})	
	new wpnid = get_user_weapon(id)
	if(wpnid == CSW_KNIFE){
		if(pev_valid(wpnent)){
			set_pdata_float(wpnent, 46, 6.0);
			set_pdata_float(wpnent, 47, 6.0);
			gmoonslash_timer[id] = get_gametime();
			gmoonslash_slash[id] = 1
		}
	}
}
public moonslash_neartarget(id){
	new target = gmoonslash_target[id];
	if (!is_user_alive(target) || gmoonslash_timer[id]+1.0>get_gametime()){
		gmoonslash_blink[id] = 0;
		return;
	}
	new Float:id_origin[3], Float:target_origin[3];
	pev(id, pev_origin, id_origin);
	pev(target, pev_origin, target_origin);
	new Float:distance = vector_distance(id_origin, target_origin);
	if(50.0 <= distance <= 768.0){
		gmoonslash_blink[id] = 1;
		return;
	} else if (50.0 > distance && gmoonslash_blink[id]) {
		new Float:angle[3]
		pev(id, pev_angles, angle)
		xs_vec_copy(angle, gmoonslash_angle[id])
		task_moonslash_left(id)
		task_moonslash_right(id)
		moonslash_effect(id)
		moonslash_slash(id);
		gfrozen[target] = 10//2.0sec
		check_ach_fast_9(id)
	}
	moonslash_cancel(id);
}
public moonslash_cancel(id){
	gmoonslash_blink[id] = 0;
	gmoonslash_target[id] = 0;
	if (!gmoonslash_canceled[id]){
		moonslash_setblink(id);
		gmoonslash_canceled[id] = 1;
	}
}
public moonslash_setblink(id){
	if (gmoonslash_blink[id]>1) return;
	if (gmoonslash_blink[id])
		gmoonslash_blink[id] ++;
}
public task_moonslash_left(id){

	if(!is_user_alive(id)) return
	if(!is_user_alive(gmoonslash_target[id])) return

	engfunc(EngFunc_EmitSound, id, CHAN_STATIC, snd_moonstar_mirror, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

	new Float:left_Origin[3], Float:left_Angle[3]

	new Float:id_origin[3], Float:target_origin[3]
	pev(id, pev_origin, id_origin)
	pev(gmoonslash_target[id], pev_origin, target_origin)

	left_Origin[0] = math_X12(target_origin[0], gmoonslash_angle[id][0] - 45.0, 128.0)
	left_Origin[1] = math_Y12(target_origin[1], gmoonslash_angle[id][0] - 45.0, 128.0)
	left_Origin[2] = target_origin[2]

	left_Angle[0] = gmoonslash_angle[id][0]
	left_Angle[1] = math_AngleFix(gmoonslash_angle[id][1] + 135.0)
	left_Angle[2] = gmoonslash_angle[id][2]

	static mirror
	mirror = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	engfunc(EngFunc_SetModel, mirror, mdl_moonstar_mirror)
	set_pev(mirror, pev_angles, left_Angle)
	set_pev(mirror, pev_origin, left_Origin)
	set_pev(mirror, pev_solid, SOLID_NOT)
	set_pev(mirror, pev_movetype, MOVETYPE_FLY)
	set_pev(mirror, pev_owner, id)
	set_pev(mirror, pev_classname, "moonstar_mirror")
	set_pev(mirror, pev_animtime,2.0)
	set_pev(mirror, pev_framerate,1.2)
	set_pev(mirror, pev_sequence, 0)

	new Float:right_Origin[3]
	right_Origin[0] = math_X12(target_origin[0], gmoonslash_angle[id][1] + 135.0, 128.0)
	right_Origin[1] = math_Y12(target_origin[1], gmoonslash_angle[id][1] + 135.0, 128.0)
	set_pev(mirror, MIRROR_MOVE, right_Origin)

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW)
	write_short(mirror)
	write_short(trail)
	write_byte(10) 
	write_byte(5) 
	write_byte(200)
	write_byte(00)
	write_byte(150)
	write_byte(150)
	message_end()

	message_begin(MSG_ONE, g_msgScreenFade, {0,0,0}, gmoonslash_target[id])
	write_short(1<<10)   // Duration
	write_short(1<<10)   // Hold time
	write_short(1<<12)   // Fade type
	write_byte (120)        // Red
	write_byte (0)      // Green
	write_byte (250)       // Blue
	write_byte (128)      // Alpha
	message_end()
	check_ach_fast_9(id)

	new parment[1]
	parment[0] = mirror
	set_task(0.3, "task_moonslash_move", 0, parment, 1)
	set_task(0.6, "task_moonslash_remove", 0, parment, 1)
}

public task_moonslash_right(id){
	if(!is_user_alive(id)) return
	if(!is_user_alive(gmoonslash_target[id])) return

	engfunc(EngFunc_EmitSound, gmoonslash_target[id], CHAN_STATIC, snd_moonstar_mirror, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

	new Float:right_Origin[3], Float:right_Angle[3]

	new Float:id_origin[3], Float:target_origin[3]
	pev(id, pev_origin, id_origin)
	pev(gmoonslash_target[id], pev_origin, target_origin)

	right_Origin[0] = math_X12(target_origin[0], gmoonslash_angle[id][1] + 45.0, 128.0)
	right_Origin[1] = math_Y12(target_origin[1], gmoonslash_angle[id][1] + 45.0, 128.0)
	right_Origin[2] = target_origin[2]

	right_Angle[0] = gmoonslash_angle[id][0]
	right_Angle[1] = math_AngleFix(gmoonslash_angle[id][1] - 135.0)
	right_Angle[2] = gmoonslash_angle[id][2]

	static mirror
	mirror = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	engfunc(EngFunc_SetModel, mirror, mdl_moonstar_mirror)
	set_pev(mirror, pev_angles, right_Angle)
	set_pev(mirror, pev_origin, right_Origin)
	set_pev(mirror, pev_solid, SOLID_NOT)
	set_pev(mirror, pev_movetype, MOVETYPE_FLY)
	set_pev(mirror, pev_owner, id)
	set_pev(mirror, pev_classname, "moonstar_mirror")
	set_pev(mirror, pev_animtime,2.0)
	set_pev(mirror, pev_framerate,1.2)
	set_pev(mirror, pev_sequence, 0)

	new Float:left_Origin[3]
	left_Origin[0] = math_X12(target_origin[0], gmoonslash_angle[id][1] - 135.0, 128.0)
	left_Origin[1] = math_Y12(target_origin[1], gmoonslash_angle[id][1] - 135.0, 128.0)
	set_pev(mirror, MIRROR_MOVE, left_Origin)


	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW)
	write_short(mirror)
	write_short(trail)
	write_byte(10) 
	write_byte(5) 
	write_byte(200)
	write_byte(00)
	write_byte(150)
	write_byte(150)
	message_end()

	new parment[1]
	parment[0] = mirror
	set_task(0.3, "task_moonslash_move", 0, parment, 1)
	set_task(0.6, "task_moonslash_remove", 0, parment, 1)
}

public task_moonslash_move(parment[]){
	static entity
	entity = parment[0]
	if(!pev_valid(parment[0])) return;
	new Float:origin[3], Float:new_origin[3]
	pev(entity, pev_origin, origin)
	pev(entity, MIRROR_MOVE, new_origin)
	new_origin[2] = origin[2]
	set_pev(entity, pev_origin, new_origin)
}

public task_moonslash_remove(parment[]){
	static entity
	entity = parment[0]
	if(!pev_valid(parment[0])) return;
	set_pev(entity, pev_flags, pev(entity, pev_flags) | FL_KILLME)
}
//==============重力僵尸空气波=============//
public zombie_skill_airblast(id){
	if(gpower[id] < get_pcvar_num(cvar_skill_airblast_power)) return;
	new Float:id_origin[3], Float:start_origin[3], Float:hit_origin[3], Float:angle[3]
	pev(id, pev_origin, id_origin)
	pev(id, pev_v_angle, angle)
	angle[0] *= -1.0
	ckrun_get_user_startpos(id, 96.0, 0.0, 6.0, start_origin)
	fm_trace_line(id, id_origin, start_origin, hit_origin)
	xs_vec_copy(hit_origin, start_origin)
	//空气波特效
	new Float:Velocity[3]
	velocity_by_aim(id, 1000, Velocity)
	new victim = -1
	new ent_class[32], Float:ent_origin[3]
	while((victim = engfunc(EngFunc_FindEntityInSphere, victim, start_origin, 160.0))){
		pev(victim, pev_classname, ent_class, 31)
		pev(victim, pev_origin, ent_origin)
		if(equal(ent_class, "rpg_rocket")){
			set_pev(victim, pev_velocity, Velocity)
			set_pev(victim, pev_angles, angle)
			set_pev(victim, ROCKET_REFLECT, 1)
			set_pev(victim, pev_owner, id)
			if(pev(victim, ROCKET_CRITICAL))
				fm_set_rendering(victim, kRenderFxGlowShell, 0, 64, 225, kRenderNormal, 128)
		} else if(equal(ent_class, "sentry_rocket")){
			velocity_by_aim(id, 1000, Velocity)
			set_pev(victim, pev_velocity, Velocity)
			set_pev(victim, pev_angles, angle)
			set_pev(victim, ROCKET_REFLECT, 1)
			set_pev(victim, pev_owner, id)
			if(pev(victim, ROCKET_CRITICAL))
				fm_set_rendering(victim, kRenderFxGlowShell, 0, 64, 225, kRenderNormal, 128)
		} else if(equal(ent_class, "player")){
			if(id == victim) continue
			if(!ckrun_can_damage(id,victim)) continue
			new ent = fm_trace_line(id, id_origin, ent_origin, hit_origin)
			if(ent != victim) continue
			ckrun_knockback_explode(victim, start_origin, 500.0)
			FX_ScreenShake(victim)
		}
	}
	gpower[id] -= get_pcvar_num(cvar_skill_airblast_power)
	gskill_ready[id] = false
	ckrun_showhud_status(id)
	set_task(1.5, "zombie_skill_reload", id+TASK_ZOMBIE_SKILL)
}

public zombie_skill_disguise(id){
	if(gdisguising[id] || ginvisible[id]) return;
	format(gcurmodel[id], 31, "%s", mdl_human[gmodel[id]])
	fm_set_user_model(id, gcurmodel[id])
	fm_set_user_anim(id, 0)
	switch(gwillbehuman[id]){
		case 1:{
		gorispeed[id] = get_pcvar_num(cvar_hm_scout_speed)
		if(gorispeed[id] > get_pcvar_num(cvar_zm_invis_speed))
			gorispeed[id] = get_pcvar_num(cvar_zm_invis_speed)
		gcurspeed[id] = gorispeed[id]
		set_pev(id, pev_weaponmodel2, "models/p_ak47.mdl")
		}
		case 2:{
		gorispeed[id] = get_pcvar_num(cvar_hm_heavy_speed)
		if(gorispeed[id] > get_pcvar_num(cvar_zm_invis_speed))
			gorispeed[id] = get_pcvar_num(cvar_zm_invis_speed)
		gcurspeed[id] = gorispeed[id]
		set_pev(id, pev_weaponmodel2, "models/p_m249.mdl")
		}
		case 3:{
		gorispeed[id] = get_pcvar_num(cvar_hm_rpg_speed)
		if(gorispeed[id] > get_pcvar_num(cvar_zm_invis_speed))
			gorispeed[id] = get_pcvar_num(cvar_zm_invis_speed)
		gcurspeed[id] = gorispeed[id]
		set_pev(id, pev_weaponmodel2, mdl_p_rpg)
		}
		case 4:{
		gorispeed[id] = get_pcvar_num(cvar_hm_snipe_speed)
		if(gorispeed[id] > get_pcvar_num(cvar_zm_invis_speed))
			gorispeed[id] = get_pcvar_num(cvar_zm_invis_speed)
		gcurspeed[id] = gorispeed[id]
		set_pev(id, pev_weaponmodel2, "models/p_awp.mdl")
		}
		case 5:{
		gorispeed[id] = get_pcvar_num(cvar_hm_log_speed)
		if(gorispeed[id] > get_pcvar_num(cvar_zm_invis_speed))
			gorispeed[id] = get_pcvar_num(cvar_zm_invis_speed)
		gcurspeed[id] = gorispeed[id]
		set_pev(id, pev_weaponmodel2, mdl_p_medicgun)
		}
		case 6:{
		gorispeed[id] = get_pcvar_num(cvar_hm_eng_speed)
		if(gorispeed[id] > get_pcvar_num(cvar_zm_invis_speed))
			gorispeed[id] = get_pcvar_num(cvar_zm_invis_speed)
		gcurspeed[id] = gorispeed[id]
		set_pev(id, pev_weaponmodel2, mdl_p_toolbox)
		}
	}
	fm_set_rendering(id, kRenderFxNone, 0, 0, 255, kRenderNormal, 255)
	gdisguise_class[id] = gwillbehuman[id]
	gdisguise_target[id] = get_random_player(1,CS_TEAM_T)//0/1=死/活，0/1=T或CT
	gdisguising[id] = true
	gskill_ready[id] = false
	ckrun_showhud_status(id)
	set_task(1.5, "zombie_skill_reload", id+TASK_ZOMBIE_SKILL)
}

public zombie_invisible(id){
	if(gdisguising[id] || !gskill_ready[id]) return;
	if(ginvisible[id]){
		zombie_stop_invisible(id)
		return
	}
	fm_set_user_anim(id, 0)
	fm_set_rendering(id,kRenderFxNone, 0,0,0, kRenderTransTexture, 50)
	set_pev(id, pev_viewmodel2, mdl_v_knife_invis)
	ginvisible[id] = true
	gorispeed[id] = get_pcvar_num(cvar_zm_invis_speed) * get_pcvar_num(cvar_skill_invisible_multisp) / 100
	gcurspeed[id] = gorispeed[id]
	gskill_ready[id] = false
	set_task(1.5, "zombie_skill_reload", id+TASK_ZOMBIE_SKILL)
	ckrun_showhud_status(id)
}

public zombie_stop_invisible(id){
	if(!ginvisible[id] || !gskill_ready[id]) return;
	fm_set_user_anim(id, 0)
	fm_set_rendering(id,kRenderFxNone, 0,0,0, kRenderTransTexture, 150)
	set_pev(id, pev_viewmodel2, mdl_v_knife_stab)
	gorispeed[id] = get_pcvar_num(cvar_zm_invis_speed)
	gcurspeed[id] = gorispeed[id]
	ginvisible[id] = false
	gskill_ready[id] = false
	set_task(1.5, "zombie_skill_reload", id+TASK_ZOMBIE_SKILL)
	ckrun_showhud_status(id)
}
public zombie_stab(taskid){
	static id
	if(taskid > g_maxplayers)
		id = ID_STABDELAY
	else
		id = taskid
	zombie_stop_disguise(id)
	new Float:target_origin[3]
	ckrun_get_user_startpos(id, 32.0, 0.0, 0.0, target_origin)
	new target,num = 0
	while((target = engfunc(EngFunc_FindEntityInSphere, target, target_origin, 32.0)) != 0){
		if(!is_user_alive(target)) continue
		if(giszm[target]) continue
		if(num > 0) continue
		num ++
		ExecuteHamB(Ham_TakeDamage, target, 0, id, float(get_pcvar_num(cvar_wpn_craw_heavy)), DMG_CLUB)
		engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, "weapons/knife_stab.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	}
	set_task(0.7, "zombie_stab_stop", id+TASK_STABDELAY)
}

public zombie_stab_stop(taskid){
	static id
	if(taskid > g_maxplayers)
		id = ID_STABDELAY
	else
		id = taskid
	if(!giszm[id] || !is_user_alive(id)) return;
	gstabing[id] = false
	fm_set_user_anim(id, 0)
}

public zombie_stop_disguise(id){
	if(!gdisguising[id]) return;
	gorispeed[id] = get_pcvar_num(cvar_zm_invis_speed)
	gcurspeed[id] = gorispeed[id]
	format(gcurmodel[id], 31, "jumpzombie")
	fm_set_user_model(id, gcurmodel[id])
	set_pev(id, pev_weaponmodel2, "models/p_knife.mdl")
	fm_set_rendering(id, kRenderFxNone, 0,0,0, kRenderTransTexture, 150)
	gdisguising[id] = false
	gskill_ready[id] = false
	ckrun_showhud_status(id)
	set_task(1.5, "zombie_skill_reload", id+TASK_ZOMBIE_SKILL)
}

public zombie_skill_dodge(id){
	if(gdodgeon[id]){
		gdodgeon[id] = false
		gorispeed[id] = get_pcvar_num(cvar_zm_jump_speed)
		gcurspeed[id] = gorispeed[id]
	} else if(!gdodgeon[id]){
		gdodgeon[id] = true
		gorispeed[id] = get_pcvar_num(cvar_zm_jump_speed) * get_pcvar_num(cvar_skill_dodge_slowdown) / 100
		gcurspeed[id] = gorispeed[id]
	}
	gskill_ready[id] = false
	ckrun_showhud_status(id)
	set_task(1.5, "zombie_skill_reload", id+TASK_ZOMBIE_SKILL)
}
public zombie_skill_longjump(id){
	if(gknife[id] != knife_normal) return
	if(glongjumpon[id]){
		glongjumpon[id] = false
	} else if(!glongjumpon[id]){
		glongjumpon[id] = true
	}
	gskill_ready[id] = false
	ckrun_showhud_status(id)
	set_task(1.5, "zombie_skill_reload", id+TASK_ZOMBIE_SKILL)
}
public zombie_skill_longjump_effect(id){
	if(!giszm[id]) return
	if(!glongjumpon[id]) return
	if(!gskill_ready[id]) return
	if(gknife[id] != knife_normal) return
	if(gpower[id] < get_pcvar_num(cvar_skill_longjump_power)) return
	set_task(1.5, "zombie_skill_reload", id+TASK_ZOMBIE_SKILL)
	new Float:Velocity[3]
	pev(id, pev_velocity, Velocity)
	velocity_by_aim(id, get_pcvar_num(cvar_skill_longjump_force), Velocity)
	Velocity[2] = 256.0
	set_pev(id, pev_velocity, Velocity)
	gpower[id] -= get_pcvar_num(cvar_skill_longjump_power)
	check_ach_fast_8(id)
	ckrun_showhud_status(id)
}
public zombie_skill_reload(taskid) {
	static id
	if(taskid > g_maxplayers)
		id = ID_ZOMBIE_SKILL
	else
		id = taskid
	if (!is_user_alive(id))	return;
	gskill_ready[id] = true
	ckrun_showhud_status(id)
}

//==============火箭炮=================//
public rocket_repeat(id){
	if(ghuman[id] != 3 || giszm[id] || !is_user_alive(id)) return;
	if(grpgclip[id] <= 0) return;
	grpgrepeat[id] = 1
	rocket_fire(id)
	remove_task(id+TASK_RPGREPEAT, 0)
	set_task(float(get_pcvar_num(cvar_wpn_rpg_repeat_time)) / 1000.0, "rocket_repeat_next", id+TASK_RPGREPEAT)
}
public rocket_repeat_next(taskid){
	static id
	if(taskid > g_maxplayers)
		id = taskid - TASK_RPGREPEAT
	else
		id = taskid
	new wpn = get_user_weapon(id)
	if(wpn != CSW_C4 || ghuman[id] != human_rpg || giszm[id] || !is_user_alive(id))	return;
	if(grpgrepeat[id] >= get_pcvar_num(cvar_wpn_rpg_repeat_max) || !grpgrepeat[id]){
		grpgready[id] = false
		remove_task(id+TASK_RPG_GETREADY, 0)
		set_task(float(get_pcvar_num(cvar_wpn_rpg_rof))/1000.0, "rpg_getready", id+TASK_RPG_GETREADY)
		return
	}
	if(grpgclip[id] <= 0) return;
	grpgrepeat[id] ++
	rocket_fire(id)
	remove_task(id+TASK_RPGREPEAT, 0)
	set_task(float(get_pcvar_num(cvar_wpn_rpg_repeat_time)) / 1000.0, "rocket_repeat_next", id+TASK_RPGREPEAT)
}
public flare_fire(id){
	if(grpgclip[id] - get_pcvar_num(cvar_wpn_rpg_flare_cost) < 0 || !grpgready[id])
		return
	if(grpgreloading[id]){
		grpgreloading[id] = false
		ckrun_showhud_status(id)
		remove_task(id+TASK_RPG_RELOAD, 0)
	}
	new Float:StartOrigin[3], Float:Angle[3]
	pev(id, pev_v_angle, Angle)
	Angle[0] *= -1.0
	//炮口位置定义
	ckrun_get_user_startpos(id,24.0,6.0,8.0,StartOrigin)

	new flare = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	set_pev(flare, pev_angles, Angle)
	set_pev(flare, pev_origin, StartOrigin)
	engfunc(EngFunc_SetModel, flare, mdl_pj_flare)

	set_pev(flare, pev_mins, {-1.0, -1.0, -1.0})
	set_pev(flare, pev_maxs, {1.0, 1.0, 1.0})

	set_pev(flare, pev_solid, SOLID_TRIGGER)
	set_pev(flare, pev_movetype, MOVETYPE_TOSS)
	set_pev(flare, pev_owner, id)
	set_pev(flare, pev_classname, "rpg_flare")

	new Float:Velocity[3]
	velocity_by_aim(id, 1200, Velocity)
	set_pev(flare, pev_velocity, Velocity)
	set_pev(flare, pev_gravity, 0.5)
	//glow
	new glow = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"info_target"))
	if(pev_valid(glow)){
		engfunc(EngFunc_SetModel,glow, "sprites/glow01.spr")
		set_pev(glow,pev_solid,SOLID_NOT)
		set_pev(glow, pev_aiment, flare)
		set_pev(glow,pev_movetype,MOVETYPE_FOLLOW)
		set_pev(glow,pev_scale,0.5)
		set_pev(glow,pev_rendermode,kRenderGlow)
		set_pev(glow,pev_renderfx,kRenderFxNoDissipation)
		set_pev(glow,pev_renderamt,200.0)
		set_pev(glow, pev_classname, "rpg_flare_glow")
		set_pev(flare, FLARE_GLOW, glow)
	}
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW)
	write_short(flare)	// entity
	write_short(trail)	// sprite
	write_byte(6)		// life
	write_byte(5)		// width
	write_byte(200) 	// r
	write_byte(200)		// g
	write_byte(200)		// b
	write_byte(200)		// brightness
	message_end();

	engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, snd_rpg_shoot_crit, 1.0, ATTN_NORM, 0, PITCH_NORM)

	grpgclip[id] -= get_pcvar_num(cvar_wpn_rpg_flare_cost)
	grpgready[id] = false
	fm_set_user_anim(id, anim_c4_shoot)

	remove_task(id+TASK_RPG_GETREADY, 0)
	set_task(float(get_pcvar_num(cvar_wpn_rpg_rof))/1000.0, "rpg_getready", id+TASK_RPG_GETREADY)
	new parm[2]
	parm[0] = flare
	parm[1] = get_pcvar_num(cvar_wpn_rpg_flare_time)
	set_task(0.1, "FX_Flare", flare+TASK_FLARE_THINK, parm, 2)
	ckrun_showhud_status(id)
}

public rocket_fire(id){
	if(grpgclip[id] <= 0) return
	if(!grpgready[id] && grpgrepeat[id] == 0) return
	if(grpgreloading[id]){
		grpgreloading[id] = false
		ckrun_showhud_status(id)
		remove_task(id+TASK_RPG_RELOAD, 0)
	}
	new Float:StartOrigin[3], Float:Angle[3]
	pev(id, pev_v_angle, Angle)
	Angle[0] *= -1.0
	//炮口位置定义
	ckrun_get_user_startpos(id,24.0,6.0,8.0,StartOrigin)

	new RocketEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	set_pev(RocketEnt, pev_angles, Angle)
	set_pev(RocketEnt, pev_origin, StartOrigin)
	set_pev(RocketEnt, pev_classname, "rpg_rocket")
	set_pev(RocketEnt, ROCKET_REFLECT, 0)
	engfunc(EngFunc_SetModel, RocketEnt, mdl_pj_rpgrocket)
	new critical = random_num(1,100)
	if(critical <= gcritical[id] || gcritical_on[id]){
		set_pev(RocketEnt, ROCKET_CRITICAL, 1)
		engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, snd_rpg_shoot_crit, 1.0, ATTN_NORM, 0, PITCH_NORM)
		fm_set_rendering(RocketEnt,kRenderFxGlowShell,225,0,0, kRenderNormal, 128)
	} else {
		set_pev(RocketEnt, ROCKET_CRITICAL, 0)
		engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, snd_rpg_shoot, 1.0, ATTN_NORM, 0, PITCH_NORM)
		fm_set_rendering(RocketEnt,kRenderFxGlowShell,250,128,0, kRenderNormal, 64)
	}
	set_pev(RocketEnt, pev_mins, {-1.0, -1.0, -1.0})
	set_pev(RocketEnt, pev_maxs, {1.0, 1.0, 1.0})

	set_pev(RocketEnt, pev_solid, 2)
	set_pev(RocketEnt, pev_movetype, 5)
	set_pev(RocketEnt, pev_owner, id)

	new Float:Velocity[3]
	velocity_by_aim(id, 1000, Velocity)
	set_pev(RocketEnt, pev_velocity, Velocity)
	//======发射动画=====//
	ckrun_get_user_startpos(id, 35.0,6.0,8.0,StartOrigin)
	FX_Explode(StartOrigin, rpglaunch, 6, 30, TE_EXPLFLAG_NOSOUND)
	ckrun_get_user_startpos(id,-30.0,6.0,8.0,StartOrigin)
	FX_Smoke(StartOrigin)

	grpgclip[id] --
	grpgready[id] = false
	fm_set_user_anim(id, anim_c4_shoot)

	FX_UpdateClip(id, CSW_C4, grpgclip[id])

	remove_task(id+TASK_RPG_GETREADY, 0)
	set_task(float(get_pcvar_num(cvar_wpn_rpg_rof))/1000.0, "rpg_getready", id+TASK_RPG_GETREADY)
	set_task(0.1, "FX_RPGTrail", RocketEnt+TASK_RPGTRAIL)
	ckrun_showhud_status(id)
}

public FX_RPGTrail(taskid){
	static ent
	if(!pev_valid(taskid))
		ent = ENT_RPGTRAIL
	else
		ent = taskid
	if (!pev_valid(ent)) return
	new Float:origin[3]
	pev(ent, pev_origin, origin)

	engfunc(EngFunc_PlaybackEvent, 0, ent, 26, 0.0, origin, Float:{0.0, 0.0, 0.0}, 5.0, 5.0, 0, 2, 0, 0);

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_SPARKS)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	message_end()

	remove_task(ent+TASK_RPGTRAIL,0)
	set_task(0.1, "FX_RPGTrail", ent+TASK_RPGTRAIL)
}

public rpg_getready(taskid) {
	static id
	if(taskid > g_maxplayers)
		id = ID_RPG_GETREADY
	else
		id = taskid
	if (!is_user_alive(id)) return
	grpgready[id] = true
	FX_UpdateClip(id, CSW_C4, grpgclip[id])
	fm_set_user_bpammo(id, CSW_C4, max(grpgammo[id], 1))
	ckrun_showhud_status(id)
	if(grpgrepeat[id] > 0)	grpgrepeat[id] = 0;
	remove_task(id+TASK_RPG_GETREADY,0)
}

public rocket_reload(id){
	if (!is_user_alive(id))	return;
	if(grpgreloading[id] || !grpgready[id])	return;
	if(grpgammo[id] <= 0 || grpgclip[id] >= get_pcvar_num(cvar_wpn_clip_rpg)){
		grpgreloading[id] = false
		return
	}
	grpgreloading[id] = true
	fm_set_user_anim(id, anim_c4_reload)
	new parm[1]
	parm[0] = id
	set_task(float(get_pcvar_num(cvar_wpn_rpg_reload)) / 1000.0, "rpg_reload", id+TASK_RPG_RELOAD, parm, 1)
}

public rpg_reload(data[]) {
	new id = data[0]
	if (!is_user_alive(id)) return
	if(!grpgreloading[id]) return
	if(grpgammo[id] <= 0 || grpgclip[id] >= get_pcvar_num(cvar_wpn_clip_rpg)){
		grpgreloading[id] = false
		return
	}
	grpgammo[id] --
	grpgclip[id] ++
	grpgreloading[id] = false

	FX_UpdateClip(id, CSW_C4, grpgclip[id])
	fm_set_user_bpammo(id, CSW_C4, max(grpgammo[id], 1))

	fm_set_user_anim(id, anim_c4_idle)
	ckrun_showhud_status(id)
	remove_task(id+TASK_RPG_RELOAD,0)
	if(grpgclip[id] < get_pcvar_num(cvar_wpn_clip_rpg))
		rocket_reload(id)
}

// from chr_engine.inc
stock get_speed_vector(const Float:origin1[3],const Float:origin2[3],Float:force, Float:new_velocity[3]){
    new_velocity[0] = origin2[0] - origin1[0]
    new_velocity[1] = origin2[1] - origin1[1]
    new_velocity[2] = origin2[2] - origin1[2]
    new Float:num = floatsqroot(force*force / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
    new_velocity[0] *= num
    new_velocity[1] *= num
    new_velocity[2] *= num

    return 1;
}

public fw_entitytouch(ptr, ptd){//分流
	if (!pev_valid(ptr))
		return HAM_IGNORED
	new classname[32]
	pev(ptr, pev_classname, classname, sizeof classname - 1)
	if(equal(classname, "rpg_rocket"))
		touch_rpgrocket(ptr, ptd)
	if(equal(classname, "sentry_rocket"))
		touch_sentryrocket(ptr, ptd)
	if(equal(classname, "rpg_flare"))
		touch_flare(ptr, ptd)
	return HAM_IGNORED
}
public touch_rpgrocket(ptr, ptd) {
	new enemy = pev(ptr, pev_owner)
	engfunc(EngFunc_EmitSound,ptr, CHAN_STATIC, snd_rpg_exp, 1.0, ATTN_NORM, 0, PITCH_NORM)

	new Float:EndOrigin[3]
	pev(ptr, pev_origin, EndOrigin)

	FX_NewExplode(EndOrigin)
	FX_Smoke(EndOrigin)
	FX_ExpDecal(EndOrigin)
	FX_DLight(EndOrigin, 16, 250, 250, 32, 6)

	new damage
	new id = -1
	new Float:id_origin[3], Float:distance, Float:force, id_class[32]
	while((id = engfunc(EngFunc_FindEntityInSphere, id, EndOrigin, float(get_pcvar_num(cvar_wpn_rpg_radius)) ))){
		pev(id, pev_classname, id_class, sizeof id_class - 1)
		if(equal(id_class, "sentry_base") || equal(id_class, "dispenser") || equal(id_class, "telein") || equal(id_class, "teleout")){
			new owner = pev(id, BUILD_OWNER)
			if(enemy == owner)
				continue
			if(!ckrun_can_damage(enemy,owner))
				continue
			distance = fm_distance_to_boxent(ptr, id)
			damage = get_pcvar_num(cvar_wpn_rpg_damage) - floatround(floatmul(float(get_pcvar_num(cvar_wpn_rpg_damage)), floatdiv(distance, float(get_pcvar_num(cvar_wpn_rpg_radius)) )))
			switch(id_class[0]){
				case 's':ckrun_fakedamage_build(owner, enemy, damage, CKW_RPG, 1)
				case 'd':ckrun_fakedamage_build(owner, enemy, damage, CKW_RPG, 2)
				case 't':{
					if(equal(id_class, "telein"))
						ckrun_fakedamage_build(owner, enemy, damage, CKW_RPG, 3)
					else
						ckrun_fakedamage_build(owner, enemy, damage, CKW_RPG, 4)
				}
			}
		} else if(equal(id_class, "player")){
			pev(id, pev_origin, id_origin)
			distance = vector_distance(EndOrigin, id_origin)
			damage = get_pcvar_num(cvar_wpn_rpg_damage) - floatround(floatmul(float(get_pcvar_num(cvar_wpn_rpg_damage)), floatdiv(distance, float(get_pcvar_num(cvar_wpn_rpg_radius)) )))
			if(ckrun_can_damage(enemy,id)){
				if(giszm[id]){
					force = (1.0 - (distance / 256.0)) * float(get_pcvar_num(cvar_wpn_rpg_force))
					damage *= (get_pcvar_num(cvar_wpn_rpg_multidamage) / 100)
					if(pev(ptr, ROCKET_CRITICAL)){
						damage *= (get_pcvar_num(cvar_global_crit_multi) / 100)
						FX_Critical(enemy, id)
					}
				} else {
					force = float(get_pcvar_num(cvar_wpn_rpg_force)) * (1.0 - (distance / 256.0));
					if(!(pev(id, pev_flags) & FL_ONGROUND))
						force *= 1.2
					if(pev(id, pev_flags) & FL_DUCKING)
						force *= 1.2
					if(force > 500) g_ach_rocketjump[id] = true
				}
				if(damage <= 0)
					continue
				if(gdodgeon[id] && gpower[id] >= get_pcvar_num(cvar_skill_dodge_power))
					if(random_num(1,100) <= get_pcvar_num(cvar_skill_dodge_percent)){
						gpower[id] -= get_pcvar_num(cvar_skill_dodge_power)
						force = 0.0
					}
				if(gdisguising[id]){
					damage *= get_pcvar_num(cvar_skill_disguise_multidamage) / 100
					force *= float(get_pcvar_num(cvar_skill_disguise_multiforce)) / 100
				} else if (ginvisible[id]){
					damage *= get_pcvar_num(cvar_skill_invisible_multidmg) / 100
					force *= float(get_pcvar_num(cvar_skill_invisible_multifc)) / 100
				}
				ckrun_knockback_explode(id,EndOrigin,force)
				if((gcharge_shield[gmediced[id]] || gcharge_shield[gammoed[id]]) && ckrun_get_user_assistance(id) != 0)//无敌
					continue
				if(gcharge_shield[id])//无敌
					continue
				if(pev(ptr, ROCKET_REFLECT) == 1)
					ckrun_fakedamage(id, enemy, CKW_REFLECT_ROCKET, damage, CKD_ROCKET)
				else
					ckrun_fakedamage(id, enemy, CKW_RPG, damage, CKD_ROCKET)
			}
		}
	}
	engfunc(EngFunc_RemoveEntity,ptr)
}

public touch_sentryrocket(ptr, ptd){
	new rocket_type[32]
	pev(ptr, pev_classname, rocket_type, sizeof rocket_type - 1)

	new enemy = pev(ptr, pev_owner)
	engfunc(EngFunc_EmitSound,ptr, CHAN_STATIC, snd_rpg_exp, 1.0, ATTN_NORM, 0, PITCH_NORM)

	new Float:EndOrigin[3]
	pev(ptr, pev_origin, EndOrigin)

	FX_NewExplode(EndOrigin)
	FX_Smoke(EndOrigin)
	FX_ExpDecal(EndOrigin)
	FX_DLight(EndOrigin, 16, 250, 250, 32, 6)

	new damage
	new id = -1
	new Float:id_origin[3], Float:distance, Float:force, id_class[32]
	while((id = engfunc(EngFunc_FindEntityInSphere, id, EndOrigin, float(get_pcvar_num(cvar_build_sentry_rocket_radius)) ))){
		pev(id, pev_classname, id_class, sizeof id_class - 1)
		if(equal(id_class, "sentry_base") || equal(id_class, "dispenser") || equal(id_class, "telein") || equal(id_class, "teleout")){
			new owner = pev(id, BUILD_OWNER)
			if(enemy == owner)
				continue
			if(!ckrun_can_damage(enemy,owner))
				continue
			distance = fm_distance_to_boxent(ptr, id)
			damage = get_pcvar_num(cvar_build_sentry_rocket_damage) - floatround(floatmul(float(get_pcvar_num(cvar_build_sentry_rocket_damage)), floatdiv(distance, float(get_pcvar_num(cvar_build_sentry_rocket_radius)) )))
			switch(id_class[0]){
				case 's':ckrun_fakedamage_build(owner, enemy, damage, CKW_SENTRY_ROCKET, 1)
				case 'd':ckrun_fakedamage_build(owner, enemy, damage, CKW_SENTRY_ROCKET, 2)
				case 't':{
					if(equal(id_class, "telein"))
						ckrun_fakedamage_build(owner, enemy, damage, CKW_SENTRY_ROCKET, 3)
					else
						ckrun_fakedamage_build(owner, enemy, damage, CKW_SENTRY_ROCKET, 4)
				}
			}
		} else if(equal(id_class, "player")){
			if(enemy == id)
				continue
			if(!ckrun_can_damage(enemy,id))
				continue
			pev(id, pev_origin, id_origin)
			distance = vector_distance(EndOrigin, id_origin)
			damage = get_pcvar_num(cvar_build_sentry_rocket_damage) - floatround(floatmul(float(get_pcvar_num(cvar_build_sentry_rocket_damage)), floatdiv(distance, float(get_pcvar_num(cvar_build_sentry_rocket_radius)) )))
			if(giszm[id]){
				force = float(ckrun_get_user_force(id,damage)) * (1.0 - (distance / 256.0)) / 5.0
				damage *= (get_pcvar_num(cvar_build_sentry_rocket_multi) / 100)
				if(pev(ptr, ROCKET_CRITICAL) == 1){
					damage *= (get_pcvar_num(cvar_global_crit_multi) / 100)
					FX_Critical(enemy, id)
				}
			} else {
				force = 600.0 * (1.0 - (distance / 256.0));
				if(!(pev(id, pev_flags) & FL_ONGROUND))
					force *= 1.2
				if(pev(id, pev_flags) & FL_DUCKING)
					force *= 1.2
			}
			if(damage <= 0)
				continue
			if(gdodgeon[id] && gpower[id] >= get_pcvar_num(cvar_skill_dodge_power))
				if(random_num(1,100) <= get_pcvar_num(cvar_skill_dodge_percent)){
					gpower[id] -= get_pcvar_num(cvar_skill_dodge_power)
					force = 0.0
				}
			if(gdisguising[id]){
				damage *= get_pcvar_num(cvar_skill_disguise_multidamage) / 100
				force *= float(get_pcvar_num(cvar_skill_disguise_multiforce)) / 100
			} else if (ginvisible[id]){
				damage *= get_pcvar_num(cvar_skill_invisible_multidmg) / 100
				force *= float(get_pcvar_num(cvar_skill_invisible_multifc)) / 100
			}
			ckrun_knockback_explode(id,EndOrigin,force)
			if((gcharge_shield[gmediced[id]] || gcharge_shield[gammoed[id]]) && ckrun_get_user_assistance(id) != 0)//无敌
				continue
			if(gcharge_shield[id])//无敌
				continue
			if(pev(ptr, ROCKET_REFLECT) == 1)
				ckrun_fakedamage(id, enemy, CKW_REFLECT_ROCKET, damage, CKD_ROCKET)
			else
				ckrun_fakedamage(id, enemy, CKW_SENTRY_ROCKET, damage, CKD_ROCKET)
		}
	}
	engfunc(EngFunc_RemoveEntity,ptr)
}

public touch_flare(ptr, ptd) {
	new move = pev(ptr, pev_movetype)
	if(move == MOVETYPE_NONE) return
	if(!(pev(ptr, pev_flags) & FL_ONGROUND)) return
	set_pev(ptr, pev_velocity, Float:{0.0, 0.0, 0.0})
	set_pev(ptr, pev_movetype, MOVETYPE_NONE)
}

//------------狙击蓄能检测------------//
public event_SetFOV(id){
	if(!is_user_alive(id)) return;
	if(giszm[id] || ghuman[id] != 4) return;
	new weapon = get_user_weapon(id);
	if(weapon != CSW_AWP){
		funcSnipeReset(id)
		return
	}
	new zoom = read_data(1)
	if(zoom == 90)
		funcSnipeReset(id)
	else if(zoom < 90)
		gsnipecharging[id] = true
}

public funcSniperRegen(taskid){
	static id
	if(taskid > g_maxplayers)
		id = taskid - TASK_SNIPE_REGEN
	else
		id = taskid
	if(!is_user_alive(id)) return;
	if(giszm[id]) return;
	if(gsnipecharging[id]){
		if(gsnipecharge[id] < 100){
			gsnipecharge[id] ++
			ckrun_showhud_status(id)
		}
		gcurspeed[id] = 80
	}
	remove_task(id+TASK_SNIPE_REGEN,0)
	set_task(0.1, "funcSniperRegen", id+TASK_SNIPE_REGEN)
}

public funcSnipeReset(id){
	if(!(1 <= id <= g_maxplayers)) return;
	gsnipecharge[id] = 0
	gsnipecharging[id] = false
	gcurspeed[id] = gorispeed[id]
	ckrun_showhud_status(id)
	remove_task(id+TASK_SNIPE_REGEN, 0)
	set_task(0.1, "funcSniperRegen", id+TASK_SNIPE_REGEN)
}
//------------狙击蓄能重置------------//

//------------刷新文字信息------------//
public refresh_message(){
	format(g_text3, sizeof g_text3 - 1, "%s", g_text2)
	format(g_text2, sizeof g_text2 - 1, "%s", g_text1)
	format(g_text1, sizeof g_text1 - 1, "%s", "")
	set_task(10.0,"refresh_message")
}
//------------刷新文字信息------------//

//===============步哨枪===========//
public sentry_build(id){
	//检测是否不允许建造(挂了 是僵尸 不是工程师)
	if(!is_user_alive(id) || giszm[id] || ghuman[id] != 6)
		return
	if(gengmetal[id] < get_pcvar_num(cvar_build_sentry_cost_lv1)){
		client_print(id, print_center, "%L", id, "MSG_BUILD_ENOUGHMETAL")
		return
	} else if(!(pev(id, pev_flags) & FL_ONGROUND)){
		client_print(id, print_center, "%L", id, "MSG_BUILD_ONGROUND")
		return
	} else if(pev(id, pev_bInDuck)){
		client_print(id, print_center, "%L", id, "MSG_BUILD_DUCK")
		return
	} else if(ghavesentry[id] || gsentry_building[id] || gsentry_percent[id] > 0){
		client_print(id, print_center, "%L", id, "MSG_BUILD_HAVE")
		return
	}
	new Float:Origin[3]
	pev(id, pev_origin, Origin)
	new Float:vNewOrigin[3]
	new Float:vTraceDirection[3]
	new Float:vTraceEnd[3]
	new Float:vTraceResult[3]
	velocity_by_aim(id, 64, vTraceDirection) // get a velocity in the directino player is aiming, with a multiplier of 64...
	vTraceEnd[0] = vTraceDirection[0] + Origin[0]
	vTraceEnd[1] = vTraceDirection[1] + Origin[1]
	vTraceEnd[2] = vTraceDirection[2] + Origin[2]
	fm_trace_line(id, Origin, vTraceEnd, vTraceResult) // 如果在路径上没东西，TraceEnd和TraceResult应该一样
	vNewOrigin[0] = vTraceResult[0]
	vNewOrigin[1] = vTraceResult[1]
	vNewOrigin[2] = Origin[2] // 总是建造在和人一样的高度
	if(!(ckrun_sentry_build(vNewOrigin,id)))
		client_print(id, print_center, "%L", id,"MSG_BUILD_UNABLE")
}

public ckrun_sentry_shoot(sentry, target, aim){
	new Float:sentryOrigin[3], Float:targetOrigin[3], Float:hitOrigin[3]
	pev(sentry, pev_origin, sentryOrigin)
	sentryOrigin[2] += 18.0
	pev(target, pev_origin, targetOrigin)
	targetOrigin[0] += random_float(float(aim) * -1.0, float(aim))
	targetOrigin[1] += random_float(float(aim) * -1.0, float(aim))
	targetOrigin[2] += random_float(float(aim) * -1.0, float(aim))
	new hitent = fm_trace_line(sentry, sentryOrigin, targetOrigin, hitOrigin)//连一条线，从步哨开始到僵尸身上，获取线中间的阻挡物实体
	new id = pev(sentry, BUILD_OWNER)
	if(gsentry_ammo[id] <= 0) return
	new base = gsentry_base[id]
	if(hitent == gsentry_base[id])
		hitent = fm_trace_line(base, sentryOrigin, targetOrigin, hitOrigin)
	if(hitent == target){
		new damage
		switch(gsentry_level[id]){
			case 1:damage = get_pcvar_num(cvar_build_sentry_bullet_lv1) + random_num(-10,10)
			case 2:damage = get_pcvar_num(cvar_build_sentry_bullet_lv2) + random_num(-10,10)
			case 3:damage = get_pcvar_num(cvar_build_sentry_bullet_lv3) + random_num(-10,10)
		}
		new force = ckrun_get_user_force(target, damage)
		ckrun_knockback_explode(target,sentryOrigin, float(force) / 3.0)
		ckrun_fakedamage(target, id, CKW_SENTRY, damage, CKD_BULLET)
	}
	if(!gcritical_on[id])
		FX_Trace(sentryOrigin, targetOrigin)
	else
		FX_ColoredTrace_point(sentryOrigin, targetOrigin)
	gsentry_ammo[id] --
}
stock bool:is_hull_default(Float:origin[3], const Float:BOUNDS){
	new Float:traceEnds[8][3], Float:traceHit[3], hitEnt
	traceEnds[0][0] = origin[0] - BOUNDS
	traceEnds[0][1] = origin[1] - BOUNDS
	traceEnds[0][2] = origin[2] - BOUNDS

	traceEnds[1][0] = origin[0] - BOUNDS
	traceEnds[1][1] = origin[1] - BOUNDS
	traceEnds[1][2] = origin[2] + BOUNDS

	traceEnds[2][0] = origin[0] + BOUNDS
	traceEnds[2][1] = origin[1] - BOUNDS
	traceEnds[2][2] = origin[2] + BOUNDS

	traceEnds[3][0] = origin[0] + BOUNDS
	traceEnds[3][1] = origin[1] - BOUNDS
	traceEnds[3][2] = origin[2] - BOUNDS

	traceEnds[4][0] = origin[0] - BOUNDS
	traceEnds[4][1] = origin[1] + BOUNDS
	traceEnds[4][2] = origin[2] - BOUNDS

	traceEnds[5][0] = origin[0] - BOUNDS
	traceEnds[5][1] = origin[1] + BOUNDS
	traceEnds[5][2] = origin[2] + BOUNDS

	traceEnds[6][0] = origin[0] + BOUNDS
	traceEnds[6][1] = origin[1] + BOUNDS
	traceEnds[6][2] = origin[2] + BOUNDS

	traceEnds[7][0] = origin[0] + BOUNDS
	traceEnds[7][1] = origin[1] + BOUNDS
	traceEnds[7][2] = origin[2] - BOUNDS

	for (new i = 0; i < 8; i++) {
		if (fm_point_contents(traceEnds[i]) != CONTENTS_EMPTY)
			return true

		hitEnt = fm_trace_line(0, origin, traceEnds[i], traceHit)
		if (hitEnt != 0)
			return true
		for (new j = 0; j < 3; j++)
			if (traceEnds[i][j] != traceHit[j])
				return true
	}
	return false
}
stock bool:is_hull_override(Float:origin[3], const Float:BOUNDS, ignored){
	new Float:traceEnds[8][3], Float:traceHit[3], hitEnt
	traceEnds[0][0] = origin[0] - BOUNDS
	traceEnds[0][1] = origin[1] - BOUNDS
	traceEnds[0][2] = origin[2] - BOUNDS

	traceEnds[1][0] = origin[0] - BOUNDS
	traceEnds[1][1] = origin[1] - BOUNDS
	traceEnds[1][2] = origin[2] + BOUNDS

	traceEnds[2][0] = origin[0] + BOUNDS
	traceEnds[2][1] = origin[1] - BOUNDS
	traceEnds[2][2] = origin[2] + BOUNDS

	traceEnds[3][0] = origin[0] + BOUNDS
	traceEnds[3][1] = origin[1] - BOUNDS
	traceEnds[3][2] = origin[2] - BOUNDS

	traceEnds[4][0] = origin[0] - BOUNDS
	traceEnds[4][1] = origin[1] + BOUNDS
	traceEnds[4][2] = origin[2] - BOUNDS

	traceEnds[5][0] = origin[0] - BOUNDS
	traceEnds[5][1] = origin[1] + BOUNDS
	traceEnds[5][2] = origin[2] + BOUNDS

	traceEnds[6][0] = origin[0] + BOUNDS
	traceEnds[6][1] = origin[1] + BOUNDS
	traceEnds[6][2] = origin[2] + BOUNDS

	traceEnds[7][0] = origin[0] + BOUNDS
	traceEnds[7][1] = origin[1] + BOUNDS
	traceEnds[7][2] = origin[2] - BOUNDS

	for (new i = 0; i < 8; i++) {
		if (fm_point_contents(traceEnds[i]) != CONTENTS_EMPTY)
			return true

		hitEnt = fm_trace_line(ignored, origin, traceEnds[i], traceHit)
		if (hitEnt != 0)
			return true
		for (new j = 0; j < 3; j++)
			if (traceEnds[i][j] != traceHit[j])
				return true
	}
	return false
}
stock ckrun_turntotarget(ent, target) {
	if (target){
		new Float:closestOrigin[3],Float:sentryOrigin[3]
		pev(target, pev_origin, closestOrigin)
		pev(ent, pev_origin, sentryOrigin)
		new Float:newAngle[3]
		pev(ent, pev_angles, newAngle)
		new Float:x = closestOrigin[0] - sentryOrigin[0]
		new Float:z = closestOrigin[1] - sentryOrigin[1]

		new Float:radians = floatatan(z/x, radian)
		newAngle[1] = radians * 180.0 / 3.14159
		if (closestOrigin[0] < sentryOrigin[0])
			newAngle[1] -= 180.0

		new Float:h = closestOrigin[2] - sentryOrigin[2]
		new Float:b = vector_distance(sentryOrigin, closestOrigin)
		radians = floatatan(h/b, radian)
		new Float:degs = radians * 180.0 / 3.14159
		new Float:RADIUS = 830.0
		new Float:degreeByte = RADIUS/256.0
		new Float:tilt = 127.0 - degreeByte * degs
		set_pev(ent, pev_angles, newAngle)
		set_pev(ent, pev_controller_1, floatround(tilt))
	}
}
stock fm_set_entity_view(entity, Float:Target[3]){
	new Float:Origin[3], Float:Angles[3]
	pev(entity, pev_origin, Origin)
	Target[0] -= Origin[0]
	Target[1] -= Origin[1]
	Target[2] -= Origin[2]
	vector_to_angle(Target, Angles)
	Angles[0] = 360.0 - Angles[0]
	set_pev(entity, pev_v_angle, Angles)
	Angles[0] *= -1
	set_pev(entity, pev_angles, Angles)
	set_pev(entity, pev_fixangle, 1)
}
stock fm_set_entity_aim(ent,const Float:origin2[3],bone=0){
	if(!pev_valid(ent))
		return 0;

	static Float:origin[3]
	origin[0] = origin2[0]
	origin[1] = origin2[1]
	origin[2] = origin2[2]

	static Float:ent_origin[3], Float:angles[3]

	if(bone)
		engfunc(EngFunc_GetBonePosition,ent,bone,ent_origin,angles)
	else
		pev(ent,pev_origin,ent_origin)

	origin[0] -= ent_origin[0]
	origin[1] -= ent_origin[1]
	origin[2] -= ent_origin[2]

	static Float:v_length
	v_length = vector_length(origin)

	static Float:aim_vector[3]
	aim_vector[0] = origin[0] / v_length
	aim_vector[1] = origin[1] / v_length
	aim_vector[2] = origin[2] / v_length

	static Float:new_angles[3]
	vector_to_angle(aim_vector,new_angles)

	new_angles[0] *= -1

	if(new_angles[1]>180.0) new_angles[1] -= 360
	if(new_angles[1]<-180.0) new_angles[1] += 360
	if(new_angles[1]==180.0 || new_angles[1]==-180.0) new_angles[1]=-179.999999

	set_pev(ent,pev_angles,new_angles)
	set_pev(ent,pev_fixangle,1)

	return 1;
}
stock Float:fm_get_entity_speed(entity){
	static Float:velocity[3]
	pev(entity, pev_velocity, velocity)
	
	return vector_length(velocity);
}
//fm stock结束

stock bool:ckrun_sentry_build(Float:origin[3],id){
	if (fm_point_contents(origin) != CONTENTS_EMPTY || is_hull_default(origin, 24.0))
		return false
	if(is_on_moveable(id, origin)) return false
	new Float:hitPoint[3], Float:originDown[3]
	originDown = origin
	originDown[2] = -5000.0
	fm_trace_line(0, origin, originDown, hitPoint)
	new Float:DistanceFromGround = vector_distance(origin, hitPoint)

	new Float:difference = 36.0 - DistanceFromGround
	if (difference < -1 * 10.0 || difference > 10.0) return false//防止在过陡斜坡上建造

	new sentry_base = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"func_breakable")) // 可以接受伤害
	if (!sentry_base)
		return false
	//设置基础底座实体属性
	fm_set_kvd(sentry_base, "health", "10000", "func_breakable")
	fm_set_kvd(sentry_base, "material", "6", "func_breakable")
	fm_DispatchSpawn(sentry_base)

	set_pev(sentry_base, pev_classname, "sentry_base")//重设实体名称
	engfunc(EngFunc_SetModel, sentry_base, "models/sentries/base.mdl")//设置模型
	engfunc(EngFunc_SetSize, sentry_base, {-16.0, -16.0, 0.0}, {16.0, 16.0, 48.0})
	engfunc(EngFunc_SetOrigin, sentry_base, origin)
	pev(id, pev_v_angle, origin)
	origin[0] = 0.0
	origin[1] += 180.0
	origin[2] = 0.0
	set_pev(sentry_base, pev_angles, origin)
	set_pev(sentry_base, pev_solid, SOLID_SLIDEBOX)
	set_pev(sentry_base, pev_movetype, MOVETYPE_TOSS)
	set_pev(sentry_base, BUILD_OWNER, id)
	gsentry_base[id] = sentry_base
	gsentry_building[id] = true
	gsentry_health[id] = 1
	ghavesentry[id] = true
	gengmetal[id] -= get_pcvar_num(cvar_build_sentry_cost_lv1)
	return true
}

public ckrun_sentry_build_turret(sentry_base, id) {
	if (!gsentry_building[id]){// 开局就不造了...
		if (pev_valid(sentry_base)) ckrun_sentry_destory(id)
		return
	}
	if (!pev_valid(sentry_base)) return
	new Float:origin[3]
	pev(sentry_base, pev_origin, origin)
	new sentry_turret = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"info_target"))
	if(!sentry_turret){
		if(pev_valid(sentry_base)) ckrun_sentry_destory(id)
		return
	}
	new Float:MinBox[3] = {-16.0, -16.0, -1.0}
	new Float:MaxBox[3] = {16.0, 16.0, 16.0}
	engfunc(EngFunc_SetSize, sentry_turret, MinBox, MaxBox)
	set_pev(sentry_turret, pev_classname, "sentry_turret")

	engfunc(EngFunc_SetModel, sentry_turret, "models/sentries/sentry1.mdl")
	origin[2] += 64.0
	engfunc(EngFunc_SetOrigin, sentry_turret, origin)
	pev(sentry_base, pev_angles, origin)
	set_pev(sentry_turret, pev_angles, origin)
	set_pev(sentry_turret, pev_solid, SOLID_SLIDEBOX)
	set_pev(sentry_turret, pev_movetype, MOVETYPE_TOSS)
	set_pev(sentry_turret, pev_controller_1, 127)
	set_pev(sentry_turret, pev_controller_2, 127)
	set_pev(sentry_turret, pev_controller_3, 127)
	set_pev(sentry_turret, BUILD_OWNER, id)
	new topColor = random_num(0, 255)
	new bottomColor = random_num(0, 255)
	new map = topColor | (bottomColor<<8)
	set_pev(sentry_turret, pev_colormap, map)
	set_task(SENTRY_THINK, "think_sentry", TASK_SENTRY_THINK + id, _, _)
	gsentry_building[id] = false
	ghavesentry[id] = true
	gsentry_turret[id] = sentry_turret
	gsentry_upgrade[id] = 0
	gsentry_level[id] = 1
	gsentry_ammo[id] = get_pcvar_num(cvar_build_sentry_ammo_lv1)
	gsentry_health[id] = get_pcvar_num(cvar_build_sentry_hp_lv1)
}

public ckrun_sentry_destory(id){
	new class[24]
	remove_task(TASK_SENTRY_THINK + id,0)
	if(pev_valid(gsentry_base[id])){
		pev(gsentry_base[id], pev_classname, class, 23)
		if(equal(class, "sentry_base")){
			FX_Demolish(gsentry_base[id])
			set_pev(gsentry_base[id], pev_flags, pev(gsentry_base[id], pev_flags) | FL_KILLME)
		}
	}
	if(pev_valid(gsentry_turret[id])){
		pev(gsentry_turret[id], pev_classname, class, 23)
		if(equal(class, "sentry_turret")){
			FX_Demolish(gsentry_turret[id])
			set_pev(gsentry_turret[id], pev_flags, pev(gsentry_turret[id], pev_flags) | FL_KILLME)
		}
	}
	ghavesentry[id] = false
	gsentry_building[id] = false
	gsentry_upgrade[id] = 0
	gsentry_level[id] = 0
	gsentry_base[id] = 0
	gsentry_turret[id] = 0
	gsentry_percent[id] = 0
	gsentry_firemode[id] = 0 // 步哨枪攻击模式 0=距离 1=生命 2=速度
	gsentry_health[id] = 0
	gsentry_ammo[id] = 0
}
stock ckrun_sentry_find_player(sentry, bywhat){//hzqst编写,sentry:步哨实体 radius:搜索范围 bywhat:0=距离,1=生命,2=速度
	if(!pev_valid(sentry))
		return 0
	if(bywhat > 2 || bywhat < 0)
		bywhat = 0
	new id = 0, hitent, Float:sentryOrigin[3], Float:targetOrigin[3], Float:hitOrigin[3]
	new Float:closest, Float:distance, closestid
	new vaule, mostvaule, vauleid
	new owner = pev(sentry, BUILD_OWNER)
	new base = gsentry_base[owner]
	pev(sentry, pev_origin, sentryOrigin)//获取步哨坐标
	sentryOrigin[2] += 20.0
	new Float:radius
	switch(gsentry_level[owner]){
		case 1:radius = float(get_pcvar_num(cvar_build_sentry_radius_lv1))
		case 2:radius = float(get_pcvar_num(cvar_build_sentry_radius_lv2))
		case 3:radius = float(get_pcvar_num(cvar_build_sentry_radius_lv3))
	}
	while((id = engfunc(EngFunc_FindEntityInSphere, id, sentryOrigin, radius)) != 0){//WHILE循环对每个玩家都运行一遍
		if(!is_user_alive(id))//不对非玩家起作用
			continue
		if(!giszm[id] || g_round != round_zombie)//不对人类和无僵尸状态起作用
			continue
		if(ginvisible[id] || gdisguising[id])
			continue
		pev(id, pev_origin, targetOrigin)//获取此僵尸坐标
		hitent = fm_trace_line(sentry, sentryOrigin, targetOrigin, hitOrigin)//连一条线，从步哨开始到僵尸身上，获取线中间的阻挡物实体
		if(hitent == base)//可能trace到底座里..咱再来一遍
			hitent = fm_trace_line(base, sentryOrigin, targetOrigin, hitOrigin)
		if(hitent == id){//哦耶可以打到:P
			switch(bywhat){
				case 0:{
					distance = vector_distance(sentryOrigin, targetOrigin)
					if (distance < closest || closest == 0.0){//如果距离更小或者首次获取距离
						closestid = id
						closest = distance
					}
				}
				case 1:{
					vaule = get_user_health(id)
					if (vaule < mostvaule || mostvaule == 0){
						vauleid = id
						mostvaule = vaule
					}
				}
				case 2:{
					vaule = gcurspeed[id]
					if (vaule < mostvaule || mostvaule == 0){
						vauleid = id
						mostvaule = vaule
					}
				}
			}
		} else {//打不到:(
			continue
		}
	}
	if(closestid != 0 && bywhat == 0)
		id = closestid
	if(vauleid != 0 && bywhat == 1)
		id = vauleid
	if(vauleid != 0 && bywhat == 2)
		id = vauleid
	return id
}

public think_sentry(taskid) {
	static id
	if(taskid > g_maxplayers)
		id = taskid - TASK_SENTRY_THINK
	else
		id = taskid
	static sentry ; sentry = gsentry_turret[id]
	if (!pev_valid(sentry)) return
	new target = ckrun_sentry_find_player(sentry, gsentry_firemode[id])
	if (is_user_alive(target)){
		if(gsentry_ammo[id] > 0){
			ckrun_turntotarget(sentry, target)
			engfunc(EngFunc_EmitSound,sentry, CHAN_WEAPON, snd_sentry_shoot, 1.0, ATTN_NORM, 0, PITCH_NORM)
			ckrun_sentry_shoot(sentry, target, 16)
			ckrun_sentry_rocket(id, target)
			if (float(gsentry_time[id]) >= float(get_pcvar_num(cvar_build_sentry_rescan))/200.0)
				engfunc(EngFunc_EmitSound,sentry, CHAN_STATIC, snd_sentry_scan, 1.0, ATTN_NORM, 0, PITCH_NORM)
			gsentry_time[id] = 1
		}
	} else {
		gsentry_time[id] ++//0.2s:1 0.4:2 3.0:15
	}
	set_task(SENTRY_THINK, "think_sentry", TASK_SENTRY_THINK + id, _, _)
}

public ckrun_sentry_repair(id, which){
	if(!ghavesentry[id] || gengmetal[id] <= 0) return;
	new sentry = gsentry_base[id]
	if(!pev_valid(sentry)) return;
	new bool:health, bool:ammo
	switch(which){
		case 1:{
			if(gsentry_building[id]){
				if(gsentry_percent[id] + 2 <= 100) gsentry_percent[id] += 2
				else gsentry_percent[id] = 100
			} else {
				health = ckrun_give_sentry_health(id,get_pcvar_num(cvar_build_repair))
				if(!health)
					ammo = ckrun_give_sentry_ammo(id,get_pcvar_num(cvar_build_repair))
				if(!ammo && gsentry_level[id] < 3)
					ckrun_give_sentry_upgrade(id,get_pcvar_num(cvar_build_repair))
			}
		}
		case 2:{
			if(gsentry_percent[id] < 100){
				if(gsentry_percent[id] + 5 <= 100) gsentry_percent[id] += 5
				else gsentry_percent[id] = 100
			} else {
				ckrun_give_sentry_upgrade(id,get_pcvar_num(cvar_build_repair))
			}
		}
	}
}

public ckrun_sentry_repair_help(id, helper, which){
	if(!ghavesentry[id] || gengmetal[helper] <= 0) return;
	new sentry = gsentry_base[id]
	if(!pev_valid(sentry)) return;
	new bool:health, bool:ammo
	switch(which){
		case 1:{
			if(gsentry_building[id]){
				if(gsentry_percent[id] + 2 <= 100) gsentry_percent[id] += 2
				else gsentry_percent[id] = 100
			} else {
				health = ckrun_give_sentry_health_help(id,helper,get_pcvar_num(cvar_build_repair))
				if(!health)
					ammo = ckrun_give_sentry_ammo_help(id,helper,get_pcvar_num(cvar_build_repair))
				if(!ammo && gsentry_level[id] < 3)
					ckrun_give_sentry_upgrade_help(id,helper,get_pcvar_num(cvar_build_repair))
			}
		}
		case 2:{
			if(gsentry_percent[id] < 100){
				if(gsentry_percent[id] + 5 <= 100) gsentry_percent[id] += 5
				else gsentry_percent[id] = 100
			} else {
				ckrun_give_sentry_upgrade_help(id,helper,get_pcvar_num(cvar_build_repair))
			}
		}
	}
}

//主人修复/补弹/升级步哨
stock bool:ckrun_give_sentry_health(id, percent){//返回值true or false
	if(percent <= 0)
		return false
	new maxhealth
	switch(gsentry_level[id]){
		case 1:maxhealth = get_pcvar_num(cvar_build_sentry_hp_lv1)
		case 2:maxhealth = get_pcvar_num(cvar_build_sentry_hp_lv2)
		case 3:maxhealth = get_pcvar_num(cvar_build_sentry_hp_lv3)
	}
	new givehealth = maxhealth * percent / 100
	if(givehealth < 1)
		givehealth = 1
	new needmetal
	if(gsentry_health[id] >= maxhealth){
		return false
	} else if(gsentry_health[id]+givehealth > maxhealth && gsentry_health[id] < maxhealth){
		needmetal = (maxhealth - gsentry_health[id]) * 100 / maxhealth
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[id] >= needmetal){//正常工作
			gsentry_health[id] = maxhealth
			gengmetal[id] -= needmetal
			ckrun_showhud_status(id)
			return true
		} else if(gengmetal[id] < needmetal && gengmetal[id] > 0){
			gsentry_health[id] += gengmetal[id] * maxhealth / 100//(当所需金属大于实际拥有金属时给予生命=金属/最大金属*最大生命)
			gengmetal[id] = 0
			ckrun_showhud_status(id)
			return true
		} else {
			return false
		}
	} else if(gsentry_health[id]+givehealth <= maxhealth){
		needmetal = givehealth * 100 / maxhealth//(实际生命/最大生命*最大金属=所需金属)
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[id] >= needmetal){//正常工作
			gsentry_health[id] += givehealth
			gengmetal[id] -= needmetal
			ckrun_showhud_status(id)
			return true
		} else if(gengmetal[id] < needmetal && gengmetal[id] > 0) {
			gsentry_health[id] += gengmetal[id] * maxhealth / 100//(当所需金属大于实际拥有金属时给予生命=金属/最大金属*最大生命)
			gengmetal[id] = 0
			ckrun_showhud_status(id)
			return true
		} else {
			return false
		}
	}
	return false
}
stock bool:ckrun_give_sentry_ammo(id, percent){//返回值true or false
	if(percent <= 0)
		return false
	new maxammo
	switch(gsentry_level[id]){
		case 1:maxammo = get_pcvar_num(cvar_build_sentry_ammo_lv1)
		case 2:maxammo = get_pcvar_num(cvar_build_sentry_ammo_lv2)
		case 3:maxammo = get_pcvar_num(cvar_build_sentry_ammo_lv3)
	}
	new giveammo = maxammo * percent / 100 
	if(giveammo < 1)
		giveammo = 1
	new needmetal
	if(gsentry_ammo[id] >= maxammo){
		return false
	} else if(gsentry_ammo[id]+giveammo > maxammo && gsentry_ammo[id] < maxammo){
		needmetal = (maxammo - gsentry_ammo[id]) * 100 / maxammo
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[id] >= needmetal){//正常工作
			gsentry_ammo[id] = maxammo
			gengmetal[id] -= needmetal
			ckrun_showhud_status(id)
			return true
		} else if(gengmetal[id] < needmetal && gengmetal[id] > 0){
			gsentry_ammo[id] += gengmetal[id] * maxammo / 100//(当所需金属大于实际拥有金属时给予弹药=金属/最大金属*最大弹药)
			gengmetal[id] = 0
			ckrun_showhud_status(id)
			return true
		} else {
			return false
		}
	} else if(gsentry_ammo[id]+giveammo <= maxammo){
		needmetal = giveammo * 100 / maxammo//(实际生命/最大生命*最大金属=所需金属)
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[id] >= needmetal){//正常工作
			gsentry_ammo[id] += giveammo
			gengmetal[id] -= needmetal
			ckrun_showhud_status(id)
			return true
		} else if(gengmetal[id] < needmetal && gengmetal[id] > 0) {
			gsentry_ammo[id] += gengmetal[id] * maxammo / 100//(当所需金属大于实际拥有金属时给予弹药=金属/最大金属*最大弹药)
			gengmetal[id] = 0
			ckrun_showhud_status(id)
			return true
		} else {
			return false
		}
	}
	return false
}
stock ckrun_give_sentry_upgrade(id, percent){//无返回值
	if(percent <= 0)
		return ;
	new maxupgrade
	switch(gsentry_level[id]){
		case 1:maxupgrade = get_pcvar_num(cvar_build_sentry_cost_lv2)
		case 2:maxupgrade = get_pcvar_num(cvar_build_sentry_cost_lv3)
	}
	new giveupgrade = percent
	new needmetal
	if(gsentry_upgrade[id]+giveupgrade > maxupgrade && gsentry_upgrade[id] < maxupgrade){
		needmetal = maxupgrade - gsentry_upgrade[id]
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[id] >= needmetal){//正常工作
			gsentry_upgrade[id] = maxupgrade
			gengmetal[id] -= needmetal
			ckrun_showhud_status(id)
		} else if(gengmetal[id] < needmetal && gengmetal[id] > 0){
			gsentry_upgrade[id] += gengmetal[id]//(当所需金属大于实际拥有金属时给予弹药=金属/最大金属*最大弹药)
			gengmetal[id] = 0
			ckrun_showhud_status(id)
		}
	} else if(gsentry_upgrade[id]+giveupgrade <= maxupgrade){
		needmetal = giveupgrade//(实际生命/最大生命*最大金属=所需金属)
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[id] >= needmetal){//正常工作
			gsentry_upgrade[id] += giveupgrade
			gengmetal[id] -= needmetal
			ckrun_showhud_status(id)
		} else if(gengmetal[id] < needmetal && gengmetal[id] > 0) {
			gsentry_upgrade[id] += gengmetal[id]//(当所需金属大于实际拥有金属时给予弹药=金属/最大金属*最大弹药)
			gengmetal[id] = 0
			ckrun_showhud_status(id)
		}
	}
	if(gsentry_upgrade[id] >= maxupgrade)
		ckrun_sentry_upgrade(id)
	return;
}

//别人帮助修复/补弹/升级步哨
stock bool:ckrun_give_sentry_health_help(id, helper, percent){//返回值true or false
	if(percent <= 0)
		return false
	new maxhealth
	switch(gsentry_level[id]){
		case 1:maxhealth = get_pcvar_num(cvar_build_sentry_hp_lv1)
		case 2:maxhealth = get_pcvar_num(cvar_build_sentry_hp_lv2)
		case 3:maxhealth = get_pcvar_num(cvar_build_sentry_hp_lv3)
	}
	new givehealth = maxhealth * percent / 100
	if(givehealth < 1)
		givehealth = 1
	new needmetal
	if(gsentry_health[id] >= maxhealth){
		return false
	} else if(gsentry_health[id]+givehealth > maxhealth && gsentry_health[id] < maxhealth){
		needmetal = (maxhealth - gsentry_health[id]) * 100 / maxhealth
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[helper] >= needmetal){//正常工作
			gsentry_health[id] = maxhealth
			gengmetal[helper] -= needmetal
			ckrun_showhud_status(id)
			return true
		} else if(gengmetal[helper] < needmetal && gengmetal[helper] > 0){
			gsentry_health[id] += gengmetal[helper] * maxhealth / 100//(当所需金属大于实际拥有金属时给予生命=金属/最大金属*最大生命)
			gengmetal[helper] = 0
			ckrun_showhud_status(id)
			return true
		} else {
			return false
		}
	} else if(gsentry_health[id]+givehealth <= maxhealth){
		needmetal = givehealth * 100 / maxhealth//(实际生命/最大生命*最大金属=所需金属)
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[helper] >= needmetal){//正常工作
			gsentry_health[id] += givehealth
			gengmetal[helper] -= needmetal
			ckrun_showhud_status(id)
			return true
		} else if(gengmetal[helper] < needmetal && gengmetal[helper] > 0) {
			gsentry_health[id] += gengmetal[helper] * maxhealth / 100//(当所需金属大于实际拥有金属时给予生命=金属/最大金属*最大生命)
			gengmetal[helper] = 0
			ckrun_showhud_status(id)
			return true
		} else {
			return false
		}
	}
	return false
}
stock bool:ckrun_give_sentry_ammo_help(id, helper, percent){//返回值true or false
	if(percent <= 0)
		return false
	new maxammo
	switch(gsentry_level[id]){
		case 1:maxammo = get_pcvar_num(cvar_build_sentry_ammo_lv1)
		case 2:maxammo = get_pcvar_num(cvar_build_sentry_ammo_lv2)
		case 3:maxammo = get_pcvar_num(cvar_build_sentry_ammo_lv3)
	}
	new giveammo = maxammo * percent / 100 
	if(giveammo < 1)
		giveammo = 1
	new needmetal
	if(gsentry_ammo[id] >= maxammo){
		return false
	} else if(gsentry_ammo[id]+giveammo > maxammo && gsentry_ammo[id] < maxammo){
		needmetal = (maxammo - gsentry_ammo[id]) * 100 / maxammo
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[helper] >= needmetal){//正常工作
			gsentry_ammo[id] = maxammo
			gengmetal[helper] -= needmetal
			ckrun_showhud_status(id)
			return true
		} else if(gengmetal[helper] < needmetal && gengmetal[helper] > 0){
			gsentry_ammo[id] += gengmetal[helper] * maxammo / 100//(当所需金属大于实际拥有金属时给予弹药=金属/最大金属*最大弹药)
			gengmetal[helper] = 0
			ckrun_showhud_status(id)
			return true
		} else {
			return false
		}
	} else if(gsentry_ammo[id]+giveammo <= maxammo){
		needmetal = giveammo * 100 / maxammo//(实际生命/最大生命*最大金属=所需金属)
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[helper] >= needmetal){//正常工作
			gsentry_ammo[id] += giveammo
			gengmetal[helper] -= needmetal
			ckrun_showhud_status(id)
			return true
		} else if(gengmetal[helper] < needmetal && gengmetal[helper] > 0) {
			gsentry_ammo[id] += gengmetal[helper] * maxammo / 100//(当所需金属大于实际拥有金属时给予弹药=金属/最大金属*最大弹药)
			gengmetal[helper] = 0
			ckrun_showhud_status(id)
			return true
		} else {
			return false
		}
	}
	return false
}

stock ckrun_give_sentry_upgrade_help(id, helper, percent){//无返回值
	if(percent <= 0)
		return;
	new maxupgrade
	switch(gsentry_level[id]){
		case 1:maxupgrade = get_pcvar_num(cvar_build_sentry_cost_lv2)
		case 2:maxupgrade = get_pcvar_num(cvar_build_sentry_cost_lv3)
	}
	new giveupgrade = percent
	new needmetal
	if(gsentry_upgrade[id]+giveupgrade > maxupgrade && gsentry_upgrade[id] < maxupgrade){
		needmetal = maxupgrade - gsentry_upgrade[id]
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[helper] >= needmetal){//正常工作
			gsentry_upgrade[id] = maxupgrade
			gengmetal[helper] -= needmetal
			ckrun_showhud_status(id)
		} else if(gengmetal[helper] < needmetal && gengmetal[helper] > 0){
			gsentry_upgrade[id] += gengmetal[helper]//(当所需金属大于实际拥有金属时给予弹药=金属/最大金属*最大弹药)
			gengmetal[helper] = 0
			ckrun_showhud_status(id)
		}
	} else if(gsentry_upgrade[id]+giveupgrade <= maxupgrade){
		needmetal = giveupgrade//(实际生命/最大生命*最大金属=所需金属)
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[helper] >= needmetal){//正常工作
			gsentry_upgrade[id] += giveupgrade
			gengmetal[helper] -= needmetal
			ckrun_showhud_status(id)
		} else if(gengmetal[helper] < needmetal && gengmetal[helper] > 0) {
			gsentry_upgrade[id] += gengmetal[helper]//(当所需金属大于实际拥有金属时给予弹药=金属/最大金属*最大弹药)
			gengmetal[helper] = 0
			ckrun_showhud_status(id)
		}
	}
	if(gsentry_upgrade[id] >= maxupgrade)
		ckrun_sentry_upgrade(id)
	return;
}

stock ckrun_sentry_upgrade(id) {
	new sentry_base = gsentry_base[id]
	new sentry_turret = gsentry_turret[id]
	if(!pev_valid(sentry_base) || !pev_valid(sentry_turret))
		return;
	switch(gsentry_level[id]){
		case 1:{
			engfunc(EngFunc_SetModel, sentry_turret, "models/sentries/sentry2.mdl")
			gsentry_health[id] = get_pcvar_num(cvar_build_sentry_hp_lv2)
			gsentry_ammo[id] = get_pcvar_num(cvar_build_sentry_ammo_lv2)
			gsentry_level[id] ++
			gsentry_upgrade[id] = 0
		}
		case 2:{
			engfunc(EngFunc_SetModel, sentry_turret, "models/sentries/sentry3.mdl")
			gsentry_health[id] = get_pcvar_num(cvar_build_sentry_hp_lv3)
			gsentry_ammo[id] = get_pcvar_num(cvar_build_sentry_ammo_lv3)
			gsentry_level[id] ++
			gsentry_upgrade[id] = 0
		}
	}
	return;
}
public ckrun_sentry_rocket(id, target){
	if(!is_user_alive(id) || !is_user_alive(target)) return
	if (gsentry_level[id] < 3) return
	if (!gsentry_rocket[id] || gsentry_ammo[id] < get_pcvar_num(cvar_build_sentry_rocket_cost)) return
	new sentry = gsentry_turret[id]
	new Float:targetOrigin[3], Float:sentryOrigin[3], Float:hitOrigin[3], Float:newtargetOrigin[3], Float:Angle[3], Float:startOrigin[3]
	pev(sentry, pev_origin, sentryOrigin)
	pev(sentry, pev_angles, Angle)
	pev(target, pev_origin, targetOrigin)
	ckrun_get_startpos(sentry, 42.0, 0.0, 18.0, startOrigin)
	newtargetOrigin = targetOrigin
	newtargetOrigin[2] -= 36.0
	fm_trace_line(sentry, startOrigin, newtargetOrigin, hitOrigin)
	new Float:distance = vector_distance(targetOrigin, hitOrigin)
	if(distance <= 128.0)
		targetOrigin = newtargetOrigin

	new RocketEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))

	set_pev(RocketEnt, pev_origin, startOrigin)
	set_pev(RocketEnt, pev_angles, Angle)
	engfunc(EngFunc_SetModel, RocketEnt, mdl_pj_rpgrocket)
	//ckrun_set_entity_view(RocketEnt, targetOrigin)
	set_pev(RocketEnt, pev_classname, "sentry_rocket")
	set_pev(RocketEnt, ROCKET_REFLECT, 0)
	new critical = random_num(1,100)
	if(critical <= gcritical[id] || gcritical_on[id]){
		set_pev(RocketEnt, ROCKET_CRITICAL, 1)
		fm_set_rendering(RocketEnt,kRenderFxGlowShell,225,0,0, kRenderNormal, 128)
	} else {
		set_pev(RocketEnt, ROCKET_CRITICAL, 0)
		fm_set_rendering(RocketEnt,kRenderFxGlowShell,250,128,0, kRenderNormal, 64)
	}

	new Float:MinBox[3] = {-1.0, -1.0, -1.0}
	new Float:MaxBox[3] = {1.0, 1.0, 1.0}
	set_pev(RocketEnt, pev_mins, MinBox)
	set_pev(RocketEnt, pev_maxs, MaxBox)

	set_pev(RocketEnt, pev_solid, 2)
	set_pev(RocketEnt, pev_movetype, 5)
	set_pev(RocketEnt, pev_owner, id)

	new Float:Velocity[3]
	get_speed_vector(startOrigin, targetOrigin, 1200.0, Velocity);
	set_pev(RocketEnt, pev_velocity, Velocity)
	fm_set_entity_view(RocketEnt, targetOrigin)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(RocketEnt);	// entity
	write_short(trail);// sprite
	write_byte(10);		// life
	write_byte(5); 	// width
	write_byte(200); 		// r
	write_byte(200); 	// g
	write_byte(200); 		// b
	write_byte(200);	// brightness
	message_end();
	gsentry_ammo[id] -= get_pcvar_num(cvar_build_sentry_rocket_cost)
	gsentry_rocket[id] = false
	engfunc(EngFunc_EmitSound,sentry, CHAN_STATIC, snd_sentry_rocket, 1.0, ATTN_NORM, 0, PITCH_NORM)
	remove_task(id+TASK_SENTRY_ROCKET,0)
	set_task((float(get_pcvar_num(cvar_build_sentry_rocket_reload)))/1000.0, "ckrun_sentry_rocket_reload", id+TASK_SENTRY_ROCKET, _, _)
	ckrun_showhud_status(id)
}

public ckrun_sentry_rocket_reload(taskid){
	static id
	if(taskid > g_maxplayers)
		id = taskid - TASK_SENTRY_ROCKET
	else
		id = taskid
	if(giszm[id] || ghuman[id] != human_eng) return
	gsentry_rocket[id] = true
	remove_task(id + TASK_SENTRY_ROCKET, 0)
}

public dispenser_build(id){
	//检测是否不允许建造(挂了 是僵尸 不是工程师)
	if(!is_user_alive(id) || giszm[id] || ghuman[id] != human_eng)
		return
	if(gengmetal[id] < get_pcvar_num(cvar_build_dispenser_cost_lv1)){
		client_print(id, print_center, "%L", id, "MSG_BUILD_ENOUGHMETAL")
		return
	} else if(!(pev(id, pev_flags) & FL_ONGROUND)){
		client_print(id, print_center, "%L", id, "MSG_BUILD_ONGROUND")
		return
	} else if(pev(id, pev_bInDuck)){
		client_print(id, print_center, "%L", id, "MSG_BUILD_DUCK")
		return
	} else if(ghavedispenser[id] || gdispenser_building[id] || gdispenser_percent[id] > 0){
		client_print(id, print_center, "%L", id, "MSG_BUILD_HAVE")
		return
	}
	new Float:Origin[3]
	pev(id, pev_origin, Origin)
	new Float:vNewOrigin[3]
	new Float:vTraceDirection[3]
	new Float:vTraceEnd[3]
	new Float:vTraceResult[3]
	velocity_by_aim(id, 64, vTraceDirection)
	vTraceEnd[0] = vTraceDirection[0] + Origin[0]
	vTraceEnd[1] = vTraceDirection[1] + Origin[1]
	vTraceEnd[2] = vTraceDirection[2] + Origin[2]
	fm_trace_line(id, Origin, vTraceEnd, vTraceResult) // 如果在路径上没东西，TraceEnd和TraceResult应该一样
	vNewOrigin[0] = vTraceResult[0]
	vNewOrigin[1] = vTraceResult[1]
	vNewOrigin[2] = Origin[2] // 总是建造在和人一样的高度
	if(!(ckrun_dispenser_build(vNewOrigin,id)))
		client_print(id, print_center, "%L", id, "MSG_BUILD_UNABLE")
}
stock bool:ckrun_dispenser_build(Float:origin[3], id){
	if (fm_point_contents(origin) != CONTENTS_EMPTY || is_hull_default(origin, 24.0))
		return false
	if(is_on_moveable(id, origin)) return false
	new Float:hitPoint[3], Float:originDown[3]
	originDown = origin
	originDown[2] = -5000.0
	fm_trace_line(0, origin, originDown, hitPoint)
	new Float:DistanceFromGround = vector_distance(origin, hitPoint)

	new Float:difference = 36.0 - DistanceFromGround
	if (difference < -1 * 10.0 || difference > 10.0) return false//防止在过陡斜坡上建造
	new dispenser = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"func_breakable")) // 可以接受伤害
	if (!dispenser)
		return false
	//设置实体属性
	fm_set_kvd(dispenser, "health", "10000", "func_breakable")
	fm_set_kvd(dispenser, "material", "6", "func_breakable")
	fm_DispatchSpawn(dispenser)

	set_pev(dispenser, pev_classname, "dispenser")//重设实体名称
	engfunc(EngFunc_SetModel, dispenser, mdl_dispenser)//设置模型
	engfunc(EngFunc_SetSize, dispenser, {-16.0, -16.0, 0.0}, {16.0, 16.0, 48.0})
	engfunc(EngFunc_SetOrigin, dispenser, origin)
	pev(id, pev_v_angle, origin)
	origin[0] = 0.0
	origin[1] += 180.0
	origin[2] = 0.0
	set_pev(dispenser, pev_angles, origin)
	set_pev(dispenser, pev_solid, SOLID_SLIDEBOX)
	set_pev(dispenser, pev_movetype, MOVETYPE_TOSS)
	set_pev(dispenser, BUILD_OWNER, id)
	gdispenser[id] = dispenser
	gdispenser_building[id] = true
	gdispenser_health[id] = 1
	ghavedispenser[id] = true
	gengmetal[id] -= get_pcvar_num(cvar_build_dispenser_cost_lv1)
	return true
}
public ckrun_dispenser_completed(id){
	if(!is_user_alive(id)) return
	if(giszm[id] || ghuman[id] != 6 || !ghavedispenser[id]) return
	gdispenser_building[id] = false
	gdispenser_upgrade[id] = 0
	gdispenser_level[id] = 1
	gdispenser_health[id] = get_pcvar_num(cvar_build_dispenser_hp_lv1)
	gdispenser_ammo[id] = get_pcvar_num(cvar_build_dispenser_ammo_lv1)
	set_task(DISPENSER_THINK, "think_dispenser", TASK_DISPENSER_THINK + id, _, _)
}
public ckrun_dispenser_destory(id){
	new class[24]
	remove_task(TASK_DISPENSER_THINK + id, 0)
	if(pev_valid(gdispenser[id])){
		pev(gdispenser[id], pev_classname, class, 23)
		if(equal(class, "dispenser")){
			FX_Demolish(gdispenser[id])
			set_pev(gdispenser[id], pev_flags, pev(gdispenser[id], pev_flags) | FL_KILLME)
		}
	}
	ghavedispenser[id] = false
	gdispenser_building[id] = false
	gdispenser[id] = 0
	gdispenser_upgrade[id] = 0
	gdispenser_level[id] = 0
	gdispenser_percent[id] = 0
	gdispenser_health[id] = 0
	gdispenser_ammo[id] = 0
	gdispenser_time[id] = 0
	gdispenser_respawn[id] = 0
}
public think_dispenser(taskid){
	static id
	if(taskid > g_maxplayers)
		id = taskid - TASK_DISPENSER_THINK
	else
		id = taskid
	static dispenser ; dispenser = gdispenser[id]
	if (!pev_valid(dispenser)) return
	new Float:radius, heal, respawn
	gdispenser_time[id] ++
	gdispenser_respawn[id] ++
	switch(gdispenser_level[id]){
		case 1:{
			radius = float(get_pcvar_num(cvar_build_dispenser_radius_lv1))
			heal = get_pcvar_num(cvar_build_dispenser_heal_lv1)
			respawn = get_pcvar_num(cvar_build_dispenser_rsp_lv1)
		}
		case 2:{
			radius = float(get_pcvar_num(cvar_build_dispenser_radius_lv2))
			heal = get_pcvar_num(cvar_build_dispenser_heal_lv2)
			respawn = get_pcvar_num(cvar_build_dispenser_rsp_lv2)
		}
		case 3:{
			radius = float(get_pcvar_num(cvar_build_dispenser_radius_lv3))
			heal = get_pcvar_num(cvar_build_dispenser_heal_lv3)
			respawn = get_pcvar_num(cvar_build_dispenser_rsp_lv3)
		}
	}
	if(gdispenser_respawn[id] >= respawn){
		ckrun_dispenser_respawn(id, 10)
		gdispenser_respawn[id] = 0
	}
	new Float:dispenserOrigin[3]
	pev(dispenser, pev_origin, dispenserOrigin)
	dispenserOrigin[2] += 24.0

	new target, bool:pickedup
	while((target = engfunc(EngFunc_FindEntityInSphere, target, dispenserOrigin, radius )) != 0){
		if (!is_user_alive(target))
			continue
		if(giszm[target])
			continue
		if (gdispenser_time[id] >= 6)//0.2s:1 0.4:2 3.0:15
			engfunc(EngFunc_EmitSound, dispenser, CHAN_STATIC, snd_dispenser_heal, 1.0, ATTN_NORM, 0, PITCH_NORM)
		gdispenser_time[id] = 0
		ckrun_give_user_health_amount(target, heal)
		FX_Healbeam(dispenser, target, 225, 25, 25, 6)
		if(gpickedup[target])
			continue
		pickedup = false
		if(gdispenser_ammo[id] >= get_pcvar_num(cvar_build_dispenser_supply))
			pickedup = ckrun_give_user_ammo(target, get_pcvar_num(cvar_build_dispenser_supply))
		if(pickedup){
			engfunc(EngFunc_EmitSound, target, CHAN_ITEM, "items/gunpickup3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			gdispenser_ammo[id] -= get_pcvar_num(cvar_build_dispenser_supply)
			ckrun_showhud_status(id)
			ckrun_showhud_status(target)
			gpickedup[target] = true
			set_task(PICKUP_DELAY,"ckrun_pickedup_reset", target+TASK_PICKUP)
		}
	}
	remove_task(TASK_DISPENSER_THINK + id, 0)
	set_task(DISPENSER_THINK, "think_dispenser", TASK_DISPENSER_THINK + id, _, _ )
}
public ckrun_dispenser_repair(id,which) {
	if(!ghavedispenser[id] || gengmetal[id] <= 0) return;
	new dispenser = gdispenser[id]
	if(!pev_valid(dispenser)) return;
	new bool:health, bool:ammo
	switch(which){
		case 1:{
			if(gdispenser_building[id]){
				if(gdispenser_percent[id] + 2 <= 100) gdispenser_percent[id] += 2
				else gdispenser_percent[id] = 100
			} else {
				health = ckrun_give_disp_health(id,get_pcvar_num(cvar_build_repair))
				if(!health)
					ammo = ckrun_give_disp_ammo(id,get_pcvar_num(cvar_build_repair))
				if(!ammo && gdispenser_level[id] < 3)
					ckrun_give_disp_upgrade(id,get_pcvar_num(cvar_build_repair))
			}
		}
		case 2:{
			if(gdispenser_percent[id] < 100){
				if(gdispenser_percent[id] + 5 <= 100) gdispenser_percent[id] += 5
				else gdispenser_percent[id] = 100
			} else {
				ckrun_give_disp_upgrade(id,get_pcvar_num(cvar_build_repair))
			}
		}
	}
}
public ckrun_dispenser_repair_help(id,helper,which) {
	if(!ghavedispenser[id] || gengmetal[helper] <= 0) return;
	new dispenser = gdispenser[id]
	if(!pev_valid(dispenser)) return;
	new bool:health, bool:ammo
	switch(which){
		case 1:{
			if(gdispenser_building[id]){
				if(gdispenser_percent[id] + 2 <= 100) gdispenser_percent[id] += 2
				else gdispenser_percent[id] = 100
			} else {
				health = ckrun_give_disp_health_help(id,helper,get_pcvar_num(cvar_build_repair))
				if(!health)
					ammo = ckrun_give_disp_ammo_help(id,helper,get_pcvar_num(cvar_build_repair))
				if(!ammo && gdispenser_level[id] < 3)
					ckrun_give_disp_upgrade_help(id,helper,get_pcvar_num(cvar_build_repair))
			}
		}
		case 2:{
			if(gdispenser_percent[id] < 100){
				if(gdispenser_percent[id] + 5 <= 100) gdispenser_percent[id] += 5
				else gdispenser_percent[id] = 100
			} else {
				ckrun_give_disp_upgrade_help(id,helper,get_pcvar_num(cvar_build_repair))
			}
		}
	}
}
//主人自己修复/补弹/升级步哨
stock bool:ckrun_give_disp_health(id,percent){//返回值true or false
	if(percent <= 0)
		return false
	new maxhealth
	switch(gdispenser_level[id]){
		case 1:maxhealth = get_pcvar_num(cvar_build_dispenser_hp_lv1)
		case 2:maxhealth = get_pcvar_num(cvar_build_dispenser_hp_lv2)
		case 3:maxhealth = get_pcvar_num(cvar_build_dispenser_hp_lv3)
	}
	new givehealth = maxhealth * percent / 100
	if(givehealth < 1)
		givehealth = 1
	new needmetal
	if(gdispenser_health[id] >= maxhealth){
		return false
	} else if(gdispenser_health[id]+givehealth > maxhealth && gdispenser_health[id] < maxhealth){
		needmetal = (maxhealth - gdispenser_health[id]) * 100 / maxhealth
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[id] >= needmetal){//正常工作
			gdispenser_health[id] = maxhealth
			gengmetal[id] -= needmetal
			ckrun_showhud_status(id)
			return true
		} else if(gengmetal[id] < needmetal && gengmetal[id] > 0){
			gdispenser_health[id] += gengmetal[id] * maxhealth / 100//(当所需金属大于实际拥有金属时给予生命=金属/最大金属*最大生命)
			gengmetal[id] = 0
			ckrun_showhud_status(id)
			return true
		} else {
			return false
		}
	} else if(gdispenser_health[id]+givehealth <= maxhealth){
		needmetal = givehealth * 100 / maxhealth//(实际生命/最大生命*最大金属=所需金属)
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[id] >= needmetal){//正常工作
			gdispenser_health[id] += givehealth
			gengmetal[id] -= needmetal
			ckrun_showhud_status(id)
			return true
		} else if(gengmetal[id] < needmetal && gengmetal[id] > 0) {
			gdispenser_health[id] += gengmetal[id] * maxhealth / 100//(当所需金属大于实际拥有金属时给予生命=金属/最大金属*最大生命)
			gengmetal[id] = 0
			ckrun_showhud_status(id)
			return true
		} else {
			return false
		}
	}
	return false
}
stock bool:ckrun_give_disp_ammo(id,percent){//返回值true or false
	if(percent <= 0)
		return false
	new maxammo
	switch(gdispenser_level[id]){
		case 1:maxammo = get_pcvar_num(cvar_build_dispenser_ammo_lv1)
		case 2:maxammo = get_pcvar_num(cvar_build_dispenser_ammo_lv2)
		case 3:maxammo = get_pcvar_num(cvar_build_dispenser_ammo_lv3)
	}
	new giveammo = maxammo * percent / 100 
	if(giveammo < 1)
		giveammo = 1
	new needmetal
	if(gdispenser_ammo[id] >= maxammo){
		return false
	} else if(gdispenser_ammo[id]+giveammo > maxammo && gdispenser_ammo[id] < maxammo){
		needmetal = (maxammo - gdispenser_ammo[id]) * 100 / maxammo
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[id] >= needmetal){//正常工作
			gdispenser_ammo[id] = maxammo
			gengmetal[id] -= needmetal
			ckrun_showhud_status(id)
			return true
		} else if(gengmetal[id] < needmetal && gengmetal[id] > 0){
			gdispenser_ammo[id] += gengmetal[id] * maxammo / 100//(当所需金属大于实际拥有金属时给予弹药=金属/最大金属*最大弹药)
			gengmetal[id] = 0
			ckrun_showhud_status(id)
			return true
		} else {
			return false
		}
	} else if(gdispenser_ammo[id]+giveammo <= maxammo){
		needmetal = giveammo * 100 / maxammo//(实际生命/最大生命*最大金属=所需金属)
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[id] >= needmetal){//正常工作
			gdispenser_ammo[id] += giveammo
			gengmetal[id] -= needmetal
			ckrun_showhud_status(id)
			return true
		} else if(gengmetal[id] < needmetal && gengmetal[id] > 0) {
			gdispenser_ammo[id] += gengmetal[id] * maxammo / 100//(当所需金属大于实际拥有金属时给予弹药=金属/最大金属*最大弹药)
			gengmetal[id] = 0
			ckrun_showhud_status(id)
			return true
		} else {
			return false
		}
	}
	return false
}
stock ckrun_give_disp_upgrade(id,percent){//无返回值
	if(percent <= 0)
		return ;
	new maxupgrade
	switch(gdispenser_level[id]){
		case 1:maxupgrade = get_pcvar_num(cvar_build_dispenser_cost_lv2)
		case 2:maxupgrade = get_pcvar_num(cvar_build_dispenser_cost_lv3)
	}
	new giveupgrade = percent
	new needmetal
	if(gdispenser_upgrade[id]+giveupgrade > maxupgrade && gdispenser_upgrade[id] < maxupgrade){
		needmetal = maxupgrade - gdispenser_upgrade[id]
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[id] >= needmetal){//正常工作
			gdispenser_upgrade[id] = maxupgrade
			gengmetal[id] -= needmetal
			ckrun_showhud_status(id)
		} else if(gengmetal[id] < needmetal && gengmetal[id] > 0){
			gdispenser_upgrade[id] += gengmetal[id]//(当所需金属大于实际拥有金属时给予弹药=金属/最大金属*最大弹药)
			gengmetal[id] = 0
			ckrun_showhud_status(id)
		}
	} else if(gdispenser_upgrade[id]+giveupgrade <= maxupgrade){
		needmetal = giveupgrade//(实际生命/最大生命*最大金属=所需金属)
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[id] >= needmetal){//正常工作
			gdispenser_upgrade[id] += giveupgrade
			gengmetal[id] -= needmetal
			ckrun_showhud_status(id)
		} else if(gengmetal[id] < needmetal && gengmetal[id] > 0) {
			gdispenser_upgrade[id] += gengmetal[id]//(当所需金属大于实际拥有金属时给予弹药=金属/最大金属*最大弹药)
			gengmetal[id] = 0
			ckrun_showhud_status(id)
		}
	}
	if(gdispenser_upgrade[id] >= maxupgrade)
		ckrun_dispenser_upgrade(id)
	return;
}
//别人帮助修复/补弹/升级步哨
stock bool:ckrun_give_disp_health_help(id,helper,percent){//返回值true or false
	if(percent <= 0)
		return false
	new maxhealth
	switch(gdispenser_level[id]){
		case 1:maxhealth = get_pcvar_num(cvar_build_dispenser_hp_lv1)
		case 2:maxhealth = get_pcvar_num(cvar_build_dispenser_hp_lv2)
		case 3:maxhealth = get_pcvar_num(cvar_build_dispenser_hp_lv3)
	}
	new givehealth = maxhealth * percent / 100
	if(givehealth < 1)
		givehealth = 1
	new needmetal
	if(gdispenser_health[id] >= maxhealth){
		return false
	} else if(gdispenser_health[id]+givehealth > maxhealth && gdispenser_health[id] < maxhealth){
		needmetal = (maxhealth - gdispenser_health[id]) * 100 / maxhealth
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[helper] >= needmetal){//正常工作
			gdispenser_health[id] = maxhealth
			gengmetal[helper] -= needmetal
			ckrun_showhud_status(id)
			return true
		} else if(gengmetal[helper] < needmetal && gengmetal[helper] > 0){
			gdispenser_health[id] += gengmetal[helper] * maxhealth / 100//(当所需金属大于实际拥有金属时给予生命=金属/最大金属*最大生命)
			gengmetal[helper] = 0
			ckrun_showhud_status(id)
			return true
		} else {
			return false
		}
	} else if(gdispenser_health[id]+givehealth <= maxhealth){
		needmetal = givehealth * 100 / maxhealth//(实际生命/最大生命*最大金属=所需金属)
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[helper] >= needmetal){//正常工作
			gdispenser_health[id] += givehealth
			gengmetal[helper] -= needmetal
			ckrun_showhud_status(id)
			return true
		} else if(gengmetal[helper] < needmetal && gengmetal[helper] > 0) {
			gdispenser_health[id] += gengmetal[helper] * maxhealth / 100//(当所需金属大于实际拥有金属时给予生命=金属/最大金属*最大生命)
			gengmetal[helper] = 0
			ckrun_showhud_status(id)
			return true
		} else {
			return false
		}
	}
	return false
}
stock bool:ckrun_give_disp_ammo_help(id,helper,percent){//返回值true or false
	if(percent <= 0)
		return false
	new maxammo
	switch(gdispenser_level[id]){
		case 1:maxammo = get_pcvar_num(cvar_build_dispenser_ammo_lv1)
		case 2:maxammo = get_pcvar_num(cvar_build_dispenser_ammo_lv2)
		case 3:maxammo = get_pcvar_num(cvar_build_dispenser_ammo_lv3)
	}
	new giveammo = maxammo * percent / 100 
	if(giveammo < 1)
		giveammo = 1
	new needmetal
	if(gdispenser_ammo[id] >= maxammo){
		return false
	} else if(gdispenser_ammo[id]+giveammo > maxammo && gdispenser_ammo[id] < maxammo){
		needmetal = (maxammo - gdispenser_ammo[id]) * 100 / maxammo
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[helper] >= needmetal){//正常工作
			gdispenser_ammo[id] = maxammo
			gengmetal[helper] -= needmetal
			ckrun_showhud_status(id)
			return true
		} else if(gengmetal[helper] < needmetal && gengmetal[helper] > 0){
			gdispenser_ammo[id] += gengmetal[helper] * maxammo / 100//(当所需金属大于实际拥有金属时给予弹药=金属/最大金属*最大弹药)
			gengmetal[helper] = 0
			ckrun_showhud_status(id)
			return true
		} else {
			return false
		}
	} else if(gdispenser_ammo[id]+giveammo <= maxammo){
		needmetal = giveammo * 100 / maxammo//(实际生命/最大生命*最大金属=所需金属)
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[helper] >= needmetal){//正常工作
			gdispenser_ammo[id] += giveammo
			gengmetal[helper] -= needmetal
			ckrun_showhud_status(id)
			return true
		} else if(gengmetal[helper] < needmetal && gengmetal[helper] > 0) {
			gdispenser_ammo[id] += gengmetal[helper] * maxammo / 100//(当所需金属大于实际拥有金属时给予弹药=金属/最大金属*最大弹药)
			gengmetal[helper] = 0
			ckrun_showhud_status(id)
			return true
		} else {
			return false
		}
	}
	return false
}
stock ckrun_give_disp_upgrade_help(id,helper,percent){//无返回值
	if(percent <= 0)
		return ;
	new maxupgrade
	switch(gdispenser_level[id]){
		case 1:maxupgrade = get_pcvar_num(cvar_build_dispenser_cost_lv2)
		case 2:maxupgrade = get_pcvar_num(cvar_build_dispenser_cost_lv3)
	}
	new giveupgrade = percent
	new needmetal
	if(gdispenser_upgrade[id]+giveupgrade > maxupgrade && gdispenser_upgrade[id] < maxupgrade){
		needmetal = maxupgrade - gdispenser_upgrade[id]
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[helper] >= needmetal){//正常工作
			gdispenser_upgrade[id] = maxupgrade
			gengmetal[helper] -= needmetal
			ckrun_showhud_status(id)
		} else if(gengmetal[helper] < needmetal && gengmetal[helper] > 0){
			gdispenser_upgrade[id] += gengmetal[helper]//(当所需金属大于实际拥有金属时给予弹药=金属/最大金属*最大弹药)
			gengmetal[helper] = 0
			ckrun_showhud_status(id)
		}
	} else if(gdispenser_upgrade[id]+giveupgrade <= maxupgrade){
		needmetal = giveupgrade//(实际生命/最大生命*最大金属=所需金属)
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[helper] >= needmetal){//正常工作
			gdispenser_upgrade[id] += giveupgrade
			gengmetal[helper] -= needmetal
			ckrun_showhud_status(id)
		} else if(gengmetal[helper] < needmetal && gengmetal[helper] > 0) {
			gdispenser_upgrade[id] += gengmetal[helper]//(当所需金属大于实际拥有金属时给予弹药=金属/最大金属*最大弹药)
			gengmetal[helper] = 0
			ckrun_showhud_status(id)
		}
	}
	if(gdispenser_upgrade[id] >= maxupgrade)
		ckrun_dispenser_upgrade(id)
	return;
}


stock ckrun_dispenser_respawn(id,percent){
	if(percent <= 0)
		return
	new maxammo
	switch(gdispenser_level[id]){
		case 1:maxammo = get_pcvar_num(cvar_build_dispenser_ammo_lv1)
		case 2:maxammo = get_pcvar_num(cvar_build_dispenser_ammo_lv2)
		case 3:maxammo = get_pcvar_num(cvar_build_dispenser_ammo_lv3)
	}
	new giveammo = maxammo * percent / 100 
	if(giveammo < 1)
		giveammo = 1
	if(gdispenser_ammo[id] >= maxammo){
		return
	} else if(gdispenser_ammo[id]+giveammo > maxammo && gdispenser_ammo[id] < maxammo){
		gdispenser_ammo[id] = maxammo
		ckrun_showhud_status(id)
		return
	} else if(gdispenser_ammo[id]+giveammo <= maxammo){
		gdispenser_ammo[id] += giveammo
		ckrun_showhud_status(id)
		return
	}
	return
}
stock ckrun_dispenser_upgrade(id) {
	new dispenser = gdispenser[id]
	if(!pev_valid(dispenser))
		return;
	switch(gdispenser_level[id]){
		case 1:{
			//engfunc(EngFunc_SetModel, dispenser, "models/sentries/dispenser2.mdl")
			gdispenser_health[id] = get_pcvar_num(cvar_build_dispenser_hp_lv2)
			gdispenser_ammo[id] = get_pcvar_num(cvar_build_dispenser_ammo_lv2)
			gdispenser_level[id] ++
			gdispenser_upgrade[id] = 0
		}
		case 2:{
			//engfunc(EngFunc_SetModel, dispenser_turret, "models/chickenrun/dispenser3.mdl")
			gdispenser_health[id] = get_pcvar_num(cvar_build_dispenser_hp_lv3)
			gdispenser_ammo[id] = get_pcvar_num(cvar_build_dispenser_ammo_lv3)
			gdispenser_level[id] ++
			gdispenser_upgrade[id] = 0
		}
	}
	return;
}
//传送装置入口
public telein_build(id){
	//检测是否不允许建造(挂了 是僵尸 不是工程师)
	if(!is_user_alive(id) || giszm[id] || ghuman[id] != human_eng)
		return
	if(gengmetal[id] < get_pcvar_num(cvar_build_telein_cost_lv1)){
		client_print(id, print_center, "%L", id, "MSG_BUILD_ENOUGHMETAL")
		return
	} else if(!(pev(id, pev_flags) & FL_ONGROUND)){
		client_print(id, print_center, "%L", id, "MSG_BUILD_ONGROUND")
		return
	} else if(pev(id, pev_bInDuck)){
		client_print(id, print_center, "%L", id, "MSG_BUILD_DUCK")
		return
	} else if(ghavetelein[id] || gtelein_building[id] || gtelein_percent[id] > 0){
		client_print(id, print_center, "%L", id, "MSG_BUILD_HAVE")
		return
	}
	new Float:Origin[3]
	pev(id, pev_origin, Origin)
	new Float:vNewOrigin[3]
	new Float:vTraceDirection[3]
	new Float:vTraceEnd[3]
	new Float:vTraceResult[3]
	velocity_by_aim(id, 64, vTraceDirection)
	vTraceEnd[0] = vTraceDirection[0] + Origin[0]
	vTraceEnd[1] = vTraceDirection[1] + Origin[1]
	vTraceEnd[2] = vTraceDirection[2] + Origin[2]
	fm_trace_line(id, Origin, vTraceEnd, vTraceResult) // 如果在路径上没东西，TraceEnd和TraceResult应该一样
	vNewOrigin[0] = vTraceResult[0]
	vNewOrigin[1] = vTraceResult[1]
	vNewOrigin[2] = Origin[2] // 总是建造在和人一样的高度
	if(!(ckrun_telein_build(vNewOrigin,id)))
		client_print(id, print_center, "%L", id, "MSG_BUILD_UNABLE")
}
stock bool:ckrun_telein_build(Float:origin[3], id){
	if (fm_point_contents(origin) != CONTENTS_EMPTY || is_hull_default(origin, 24.0))
		return false
	if(is_on_moveable(id, origin)) return false
	new Float:hitPoint[3], Float:originDown[3]
	originDown = origin
	originDown[2] = -5000.0
	fm_trace_line(0, origin, originDown, hitPoint)
	new Float:DistanceFromGround = vector_distance(origin, hitPoint)

	new Float:difference = 36.0 - DistanceFromGround
	if (difference < -1 * 10.0 || difference > 10.0) return false//防止在过陡斜坡上建造
	new telein = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"func_breakable")) // 可以接受伤害
	if (!telein) return false
	//设置实体属性
	fm_set_kvd(telein, "health", "10000", "func_breakable")
	fm_set_kvd(telein, "material", "6", "func_breakable")
	fm_DispatchSpawn(telein)

	set_pev(telein, pev_classname, "telein")//重设实体名称
	engfunc(EngFunc_SetModel, telein, mdl_teleporter)//设置模型
	engfunc(EngFunc_SetSize, telein, {-16.0, -16.0, 0.0}, {16.0, 16.0, 12.0})
	engfunc(EngFunc_SetOrigin, telein, origin)
	pev(id, pev_v_angle, origin)
	origin[0] = 0.0
	origin[1] += 180.0
	origin[2] = 0.0
	set_pev(telein, pev_angles, origin)
	set_pev(telein, pev_solid, SOLID_SLIDEBOX)
	set_pev(telein, pev_movetype, MOVETYPE_TOSS)
	set_pev(telein, BUILD_OWNER, id)
	gtelein[id] = telein
	gtelein_building[id] = true
	gtelein_health[id] = 1
	ghavetelein[id] = true
	gengmetal[id] -= get_pcvar_num(cvar_build_telein_cost_lv1)
	return true
}
public ckrun_telein_completed(id){
	if(!is_user_alive(id)) return
	if(giszm[id] || ghuman[id] != human_eng || !ghavetelein[id]) return
	if(!(ghaveteleout[id] && !gteleout_building[id])){
		gtele_upgrade[id] = 0
		gtele_level[id] = 1
	}
	gtele_reload[id] = 100
	gtelein_building[id] = false
	gtelein_health[id] = get_pcvar_num(cvar_build_telein_hp_lv1)
	if(pev_valid(gtelein[id]) && ghaveteleout[id] && !gteleout_building[id]){
		set_pev(gtelein[id], pev_framerate, float(gtele_level[id]))
		set_pev(gtelein[id], pev_sequence, 1)//旋转动画
	}
	set_task(TELEIN_THINK, "think_telein", TASK_TELEIN_THINK + id, _, _)
}

public ckrun_telein_destory(id, reset){
	new class[24]
	remove_task(TASK_TELEIN_THINK + id, 0)
	if(pev_valid(gtelein[id])){
		pev(gtelein[id], pev_classname, class, 23)
		if(equal(class, "telein")){
			FX_Demolish(gtelein[id])
			set_pev(gtelein[id], pev_flags, pev(gtelein[id], pev_flags) | FL_KILLME)
		}
	}
	ghavetelein[id] = false
	gtelein_building[id] = false
	gtelein_percent[id] = 0
	gtelein_health[id] = 0
	gtelein[id] = 0
	if(!ghaveteleout[id] || reset){
		gtele_upgrade[id] = 0
		gtele_level[id] = 0
	}
	gtele_reload[id] = 0
	gtele_stand[id] = 0
	gtele_timer[id] = 0.0
}
public think_telein(taskid){
	static id
	if(taskid > g_maxplayers)
		id = taskid - TASK_TELEIN_THINK
	else
		id = taskid
	static telein ; telein = gtelein[id]
	if (!pev_valid(telein)) return
	if(gtele_reload[id] < 100){
		switch(gtele_level[id]){
			case 1:	gtele_reload[id] += get_pcvar_num(cvar_build_tele_reload_lv1)
			case 2: gtele_reload[id] += get_pcvar_num(cvar_build_tele_reload_lv2)
			case 3:	gtele_reload[id] += get_pcvar_num(cvar_build_tele_reload_lv3)
		}
		if(gtele_reload[id] > 100) gtele_reload[id] = 100
	}
	set_pev(telein, pev_framerate, float(gtele_reload[id]) * float(gtele_level[id]) / 100.0)
	if(ghaveteleout[id] && !gteleout_building[id]) set_pev(telein, pev_sequence, 1)
	else set_pev(telein, pev_sequence, 0)

	remove_task(TASK_TELEIN_THINK + id, 0)
	set_task(TELEIN_THINK, "think_telein", TASK_TELEIN_THINK + id, _, _ )

	if(!(ghaveteleout[id] && !gteleout_building[id])) return
	if(gtele_reload[id] < 100) return
	new Float:telein_origin[3], Float:player_origin[3], Float:distance, Float:closest
	new player, closestid
	pev(telein, pev_origin, telein_origin)
	telein_origin[2] += 12.0
	
	while((player = engfunc(EngFunc_FindEntityInSphere, player, telein_origin, 16.0 ))){
		if(!(0 < player <= global_get(glb_maxClients)))
			continue
		if(!is_user_alive(player))
			continue
		if(giszm[player])
			continue
		if(!(pev(player, pev_flags) & FL_ONGROUND))
			continue
		pev(player, pev_origin, player_origin)
		distance = vector_distance(telein_origin, player_origin)
		if(distance < closest || closest == 0.0){
			closest = distance
			closestid = player
		}
	}
	if(!closestid){
		gtele_stand[id] = 0
		gtele_timer[id] = 0.0
	} else if(closestid == gtele_stand[id]){
		if(get_gametime() - gtele_timer[id] >= TELE_DELAY) ckrun_tele_player(id, closestid)
	} else {
		gtele_stand[id] = closestid
		gtele_timer[id] = get_gametime()
	}
}
public ckrun_telein_repair(id, which) {
	if(!ghavetelein[id] || gengmetal[id] <= 0) return;
	new telein = gtelein[id]
	if(!pev_valid(telein)) return;
	new bool:health, bool:reload
	switch(which){
		case 1:{
			if(gtelein_building[id]){
				if(gtelein_percent[id] + 2 <= 100) gtelein_percent[id] += 2
				else gtelein_percent[id] = 100
			} else {
				health = ckrun_give_telein_health(id,get_pcvar_num(cvar_build_repair))
				if(!health)
					reload = ckrun_give_tele_reload(id,get_pcvar_num(cvar_build_repair))
				if(!reload && gtele_level[id] < 3)
					ckrun_give_tele_upgrade(id, 10)
			}
		}
		case 2:{
			if(gtelein_percent[id] < 100){
				if(gtelein_percent[id] + 5 <= 100) gtelein_percent[id] += 5
				else gtelein_percent[id] = 100
			} else {
				ckrun_give_tele_upgrade(id, 10)
			}
		}
	}
}
public ckrun_telein_repair_help(id, helper, which) {
	if(!ghavetelein[id] || gengmetal[helper] <= 0) return;
	new telein = gtelein[id]
	if(!pev_valid(telein)) return;
	new bool:health, bool:reload
	switch(which){
		case 1:{
			if(gtelein_building[id]){
				if(gtelein_percent[id] + 2 <= 100) gtelein_percent[id] += 2
				else gtelein_percent[id] = 100
			} else {
				health = ckrun_give_telein_health_help(id, helper, get_pcvar_num(cvar_build_repair))
				if(!health)
					reload = ckrun_give_tele_reload_help(id, get_pcvar_num(cvar_build_repair))
				if(!reload && gtele_level[id] < 3)
					ckrun_give_tele_upgrade_help(id, helper, 10)
			}
		}
		case 2:{
			if(gtelein_percent[id] < 100){
				if(gtelein_percent[id] + 5 <= 100) gtelein_percent[id] += 5
				else gtelein_percent[id] = 100
			} else {
				ckrun_give_tele_upgrade_help(id,helper, 10)
			}
		}
	}
}
public ckrun_teleout_repair(id, which) {
	if(!ghaveteleout[id] || gengmetal[id] <= 0) return;
	new teleout = gteleout[id]
	if(!pev_valid(teleout)) return;
	new bool:health, bool:reload
	switch(which){
		case 1:{
			if(gteleout_building[id]){
				if(gteleout_percent[id] + 2 <= 100) gteleout_percent[id] += 2
				else gteleout_percent[id] = 100
			} else {
				health = ckrun_give_teleout_health(id,get_pcvar_num(cvar_build_repair))
				if(!health)
					reload = ckrun_give_tele_reload(id,get_pcvar_num(cvar_build_repair))
				if(!reload && gtele_level[id] < 3)
					ckrun_give_tele_upgrade(id, 10)
			}
		}
		case 2:{
			if(gteleout_percent[id] < 100){
				if(gteleout_percent[id] + 5 <= 100) gteleout_percent[id] += 5
				else gteleout_percent[id] = 100
			} else {
				ckrun_give_tele_upgrade(id, 10)
			}
		}
	}
}
public ckrun_teleout_repair_help(id, helper, which) {
	if(!ghaveteleout[id] || gengmetal[helper] <= 0) return;
	new teleout = gteleout[id]
	if(!pev_valid(teleout)) return;
	new bool:health, bool:reload
	switch(which){
		case 1:{
			if(gteleout_building[id]){
				if(gteleout_percent[id] + 2 <= 100) gteleout_percent[id] += 2
				else gteleout_percent[id] = 100
			} else {
				health = ckrun_give_teleout_health_help(id, helper, get_pcvar_num(cvar_build_repair))
				if(!health)
					reload = ckrun_give_tele_reload_help(id, get_pcvar_num(cvar_build_repair))
				if(!reload && gtele_level[id] < 3)
					ckrun_give_tele_upgrade_help(id, helper, 10)
			}
		}
		case 2:{
			if(gteleout_percent[id] < 100){
				if(gteleout_percent[id] + 5 <= 100) gteleout_percent[id] += 5
				else gteleout_percent[id] = 100
			} else {
				ckrun_give_tele_upgrade_help(id, helper, 10)
			}
		}
	}
}

//传送装置出口
public teleout_build(id){
	//检测是否不允许建造(挂了 是僵尸 不是工程师)
	if(!is_user_alive(id) || giszm[id] || ghuman[id] != human_eng)
		return
	if(gengmetal[id] < get_pcvar_num(cvar_build_teleout_cost_lv1)){
		client_print(id, print_center, "%L", id, "MSG_BUILD_ENOUGHMETAL")
		return
	} else if(!(pev(id, pev_flags) & FL_ONGROUND)){
		client_print(id, print_center, "%L", id, "MSG_BUILD_ONGROUND")
		return
	} else if(pev(id, pev_bInDuck)){
		client_print(id, print_center, "%L", id, "MSG_BUILD_DUCK")
		return
	} else if(ghaveteleout[id] || gteleout_building[id] || gteleout_percent[id] > 0){
		client_print(id, print_center, "%L", id, "MSG_BUILD_HAVE")
		return
	}
	new Float:Origin[3]
	pev(id, pev_origin, Origin)
	new Float:vNewOrigin[3]
	new Float:vTraceDirection[3]
	new Float:vTraceEnd[3]
	new Float:vTraceResult[3]
	velocity_by_aim(id, 64, vTraceDirection)
	vTraceEnd[0] = vTraceDirection[0] + Origin[0]
	vTraceEnd[1] = vTraceDirection[1] + Origin[1]
	vTraceEnd[2] = vTraceDirection[2] + Origin[2]
	fm_trace_line(id, Origin, vTraceEnd, vTraceResult) // 如果在路径上没东西，TraceEnd和TraceResult应该一样
	vNewOrigin[0] = vTraceResult[0]
	vNewOrigin[1] = vTraceResult[1]
	vNewOrigin[2] = Origin[2] // 总是建造在和人一样的高度
	if(!(ckrun_teleout_build(vNewOrigin,id)))
		client_print(id, print_center, "%L", id, "MSG_BUILD_UNABLE")
}
stock bool:ckrun_teleout_build(Float:origin[3], id){
	if (fm_point_contents(origin) != CONTENTS_EMPTY || is_hull_default(origin, 24.0))
		return false
	if(is_on_moveable(id, origin)) return false
	new Float:hitPoint[3], Float:originDown[3]
	originDown = origin
	originDown[2] = -5000.0
	fm_trace_line(0, origin, originDown, hitPoint)
	new Float:DistanceFromGround = vector_distance(origin, hitPoint)

	new Float:difference = 36.0 - DistanceFromGround
	if (difference < -1 * 10.0 || difference > 10.0) return false//防止在过陡斜坡上建造
	new teleout = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"func_breakable")) // 可以接受伤害
	if (!teleout) return false
	//设置实体属性
	fm_set_kvd(teleout, "health", "10000", "func_breakable")
	fm_set_kvd(teleout, "material", "6", "func_breakable")
	fm_DispatchSpawn(teleout)

	set_pev(teleout, pev_classname, "teleout")//重设实体名称
	engfunc(EngFunc_SetModel, teleout, mdl_teleporter)//设置模型
	engfunc(EngFunc_SetSize, teleout, {-16.0, -16.0, 0.0}, {16.0, 16.0, 12.0})
	engfunc(EngFunc_SetOrigin, teleout, origin)
	pev(id, pev_v_angle, origin)
	origin[0] = 0.0
	origin[1] += 180.0
	origin[2] = 0.0
	set_pev(teleout, pev_angles, origin)
	set_pev(teleout, pev_solid, SOLID_SLIDEBOX)
	set_pev(teleout, pev_movetype, MOVETYPE_TOSS)
	set_pev(teleout, BUILD_OWNER, id)
	gteleout[id] = teleout
	gteleout_building[id] = true
	gteleout_health[id] = 1
	ghaveteleout[id] = true
	gengmetal[id] -= get_pcvar_num(cvar_build_teleout_cost_lv1)
	return true
}
public ckrun_teleout_completed(id){
	if(!is_user_alive(id)) return
	if(giszm[id] || ghuman[id] != human_eng || !ghaveteleout[id]) return
	if(!(ghavetelein[id] && !gtelein_building[id])){
		gtele_upgrade[id] = 0
		gtele_level[id] = 1
	}
	gtele_reload[id] = 100
	gteleout_building[id] = false
	gteleout_health[id] = get_pcvar_num(cvar_build_teleout_hp_lv1)
	if(pev_valid(gteleout[id]) && ghavetelein[id] && !gtelein_building[id]){
		set_pev(gteleout[id], pev_framerate, float(gtele_level[id]))
		set_pev(gteleout[id], pev_sequence, 1)//旋转动画
	}
	set_task(TELEOUT_THINK, "think_teleout", TASK_TELEOUT_THINK + id, _, _)
}

public ckrun_teleout_destory(id, reset){
	new class[24]
	remove_task(TASK_TELEOUT_THINK + id, 0)
	if(pev_valid(gteleout[id])){
		pev(gteleout[id], pev_classname, class, 23)
		if(equal(class, "teleout")){
			FX_Demolish(gteleout[id])
			set_pev(gteleout[id], pev_flags, pev(gteleout[id], pev_flags) | FL_KILLME)
		}
	}
	ghaveteleout[id] = false
	gteleout_building[id] = false
	gteleout_percent[id] = 0
	gteleout_health[id] = 0
	gteleout[id] = 0
	if(!ghavetelein[id] || reset){
		gtele_upgrade[id] = 0
		gtele_level[id] = 0
	}
	gtele_reload[id] = 0
	gtele_stand[id] = 0
	gtele_timer[id] = 0.0
}
public think_teleout(taskid){
	static id
	if(taskid > g_maxplayers)
		id = taskid - TASK_TELEOUT_THINK
	else
		id = taskid
	static teleout ; teleout = gteleout[id]
	if (!pev_valid(teleout)) return

	set_pev(teleout, pev_framerate, float(gtele_reload[id]) * float(gtele_level[id]) / 100.0)
	if(ghavetelein[id] && !gtelein_building[id]) set_pev(teleout, pev_sequence, 1)
	else set_pev(teleout, pev_sequence, 0)

	remove_task(TASK_TELEOUT_THINK + id, 0)
	set_task(TELEOUT_THINK, "think_teleout", TASK_TELEOUT_THINK + id, _, _ )
}

stock ckrun_tele_player(id, player){
	if(!is_user_alive(player)) return
	if(!ghavetelein[id] || !ghaveteleout[id] || gtele_reload[id] < 100) return

	new Float:out_origin[3]
	pev(gteleout[id], pev_origin, out_origin)
	out_origin[2] += 77.0
	if(!is_hull_vacant(out_origin, HULL_HUMAN)){
		new outplayer
		new Float:teleout_origin[3]
		pev(gteleout[id], pev_origin, teleout_origin)
		while((outplayer = engfunc(EngFunc_FindEntityInSphere, outplayer, teleout_origin, 16.0 ))){
			if(!(0 < outplayer <= global_get(glb_maxClients)))
				continue
			if(!is_user_alive(outplayer))
				continue
			if(giszm[outplayer])
				continue
			if(!(pev(outplayer, pev_flags) & FL_ONGROUND))
				continue
			new Float:new_origin[3]
			xs_vec_copy(out_origin, new_origin)
			new_origin[0] += 33.0
			if(is_hull_vacant(new_origin, HULL_HUMAN)){
				set_pev(outplayer, pev_origin, new_origin)
				return
			}
			new_origin[0] -= 66.0
			if(is_hull_vacant(new_origin, HULL_HUMAN)){
				set_pev(outplayer, pev_origin, new_origin)
				return
			}
			new_origin[0] += 33.0
			new_origin[1] += 33.0
			if(is_hull_vacant(new_origin, HULL_HUMAN)){
				set_pev(outplayer, pev_origin, new_origin)
				return
			}
			new_origin[1] -= 66.0
			if(is_hull_vacant(new_origin, HULL_HUMAN)){
				set_pev(outplayer, pev_origin, new_origin)
				return
			}
			new_origin[1] += 33.0
			new_origin[2] += 73.0
			if(is_hull_vacant(new_origin, HULL_HUMAN)){
				set_pev(outplayer, pev_origin, new_origin)
				return
			}
		}
		return
	}
	set_pev(player, pev_origin, out_origin)

	message_begin(MSG_ONE, g_msgScreenFade, {0,0,0}, player)
	write_short(1<<10)   // Duration
	write_short(1<<10)   // Hold time
	write_short(1<<12)   // Fade type
	write_byte (200)        // Red
	write_byte (200)      // Green
	write_byte (200)       // Blue
	write_byte (255)      // Alpha
	message_end()

	gtele_reload[id] = 0
	gtele_stand[id] = 0
	gtele_timer[id] = 0.0
}

//主人自己修复/补弹/升级传送入口
stock bool:ckrun_give_telein_health(id, percent){//返回值true or false
	if(percent <= 0)
		return false
	new maxhealth
	switch(gtele_level[id]){
		case 1:maxhealth = get_pcvar_num(cvar_build_telein_hp_lv1)
		case 2:maxhealth = get_pcvar_num(cvar_build_telein_hp_lv2)
		case 3:maxhealth = get_pcvar_num(cvar_build_telein_hp_lv3)
	}
	new givehealth = maxhealth * percent / 100
	if(givehealth < 1)
		givehealth = 1
	new needmetal
	if(gtelein_health[id] >= maxhealth){
		return false
	} else if(gtelein_health[id]+givehealth > maxhealth && gtelein_health[id] < maxhealth){
		needmetal = (maxhealth - gtelein_health[id]) * 100 / maxhealth
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[id] >= needmetal){//正常工作
			gtelein_health[id] = maxhealth
			gengmetal[id] -= needmetal
			ckrun_showhud_status(id)
			return true
		} else if(gengmetal[id] < needmetal && gengmetal[id] > 0){
			gtelein_health[id] += gengmetal[id] * maxhealth / 100//(当所需金属大于实际拥有金属时给予生命=金属/最大金属*最大生命)
			gengmetal[id] = 0
			ckrun_showhud_status(id)
			return true
		} else {
			return false
		}
	} else if(gtelein_health[id]+givehealth <= maxhealth){
		needmetal = givehealth * 100 / maxhealth//(实际生命/最大生命*最大金属=所需金属)
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[id] >= needmetal){//正常工作
			gtelein_health[id] += givehealth
			gengmetal[id] -= needmetal
			ckrun_showhud_status(id)
			return true
		} else if(gengmetal[id] < needmetal && gengmetal[id] > 0) {
			gtelein_health[id] += gengmetal[id] * maxhealth / 100//(当所需金属大于实际拥有金属时给予生命=金属/最大金属*最大生命)
			gengmetal[id] = 0
			ckrun_showhud_status(id)
			return true
		} else {
			return false
		}
	}
	return false
}
stock bool:ckrun_give_teleout_health(id, percent){//返回值true or false
	if(percent <= 0)
		return false
	new maxhealth
	switch(gtele_level[id]){
		case 1:maxhealth = get_pcvar_num(cvar_build_teleout_hp_lv1)
		case 2:maxhealth = get_pcvar_num(cvar_build_teleout_hp_lv2)
		case 3:maxhealth = get_pcvar_num(cvar_build_teleout_hp_lv3)
	}
	new givehealth = maxhealth * percent / 100
	if(givehealth < 1)
		givehealth = 1
	new needmetal
	if(gteleout_health[id] >= maxhealth){
		return false
	} else if(gteleout_health[id]+givehealth > maxhealth && gteleout_health[id] < maxhealth){
		needmetal = (maxhealth - gteleout_health[id]) * 100 / maxhealth
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[id] >= needmetal){//正常工作
			gteleout_health[id] = maxhealth
			gengmetal[id] -= needmetal
			ckrun_showhud_status(id)
			return true
		} else if(gengmetal[id] < needmetal && gengmetal[id] > 0){
			gteleout_health[id] += gengmetal[id] * maxhealth / 100//(当所需金属大于实际拥有金属时给予生命=金属/最大金属*最大生命)
			gengmetal[id] = 0
			ckrun_showhud_status(id)
			return true
		} else {
			return false
		}
	} else if(gteleout_health[id]+givehealth <= maxhealth){
		needmetal = givehealth * 100 / maxhealth//(实际生命/最大生命*最大金属=所需金属)
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[id] >= needmetal){//正常工作
			gteleout_health[id] += givehealth
			gengmetal[id] -= needmetal
			ckrun_showhud_status(id)
			return true
		} else if(gengmetal[id] < needmetal && gengmetal[id] > 0) {
			gteleout_health[id] += gengmetal[id] * maxhealth / 100//(当所需金属大于实际拥有金属时给予生命=金属/最大金属*最大生命)
			gengmetal[id] = 0
			ckrun_showhud_status(id)
			return true
		} else {
			return false
		}
	}
	return false
}
stock bool:ckrun_give_tele_reload(id, percent){//返回值true or false
	if(percent <= 0)
		return false
	new givereload = percent
	if(givereload < 1)
		givereload = 1
	if(gtele_reload[id] >= 100){
		return false
	} else if(gtele_reload[id] + givereload > 100 && gtele_reload[id] < 100){
		gtele_reload[id] = 100
		ckrun_showhud_status(id)
		return true
	} else if(gtele_reload[id] + givereload <= 100){
		gtele_reload[id] += givereload
		ckrun_showhud_status(id)
		return true
	}
	return false
}
stock ckrun_give_tele_upgrade(id, percent){//无返回值
	if(percent <= 0) return
	new maxupgrade
	switch(gtele_level[id]){
		case 1:maxupgrade = get_pcvar_num(cvar_build_tele_cost_lv2)
		case 2:maxupgrade = get_pcvar_num(cvar_build_tele_cost_lv3)
	}
	new giveupgrade = percent
	new needmetal
	if(gtele_upgrade[id]+giveupgrade > maxupgrade && gtele_upgrade[id] < maxupgrade){
		needmetal = maxupgrade - gtele_upgrade[id]
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[id] >= needmetal){//正常工作
			gtele_upgrade[id] = maxupgrade
			gengmetal[id] -= needmetal
			ckrun_showhud_status(id)
		} else if(gengmetal[id] < needmetal && gengmetal[id] > 0){
			gtele_upgrade[id] += gengmetal[id]//(当所需金属大于实际拥有金属时给予弹药=金属/最大金属*最大弹药)
			gengmetal[id] = 0
			ckrun_showhud_status(id)
		}
	} else if(gtele_upgrade[id]+giveupgrade <= maxupgrade){
		needmetal = giveupgrade//(实际生命/最大生命*最大金属=所需金属)
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[id] >= needmetal){//正常工作
			gtele_upgrade[id] += giveupgrade
			gengmetal[id] -= needmetal
			ckrun_showhud_status(id)
		} else if(gengmetal[id] < needmetal && gengmetal[id] > 0) {
			gtele_upgrade[id] += gengmetal[id]//(当所需金属大于实际拥有金属时给予弹药=金属/最大金属*最大弹药)
			gengmetal[id] = 0
			ckrun_showhud_status(id)
		}
	}
	if(gtele_upgrade[id] >= maxupgrade)
		ckrun_tele_upgrade(id)
	return;
}
//别人帮助修复/补弹/升级步哨
stock bool:ckrun_give_telein_health_help(id, helper, percent){//返回值true or false
	if(percent <= 0)
		return false
	new maxhealth
	switch(gtele_level[id]){
		case 1:maxhealth = get_pcvar_num(cvar_build_telein_hp_lv1)
		case 2:maxhealth = get_pcvar_num(cvar_build_telein_hp_lv2)
		case 3:maxhealth = get_pcvar_num(cvar_build_telein_hp_lv3)
	}
	new givehealth = maxhealth * percent / 100
	if(givehealth < 1)
		givehealth = 1
	new needmetal
	if(gtelein_health[id] >= maxhealth){
		return false
	} else if(gtelein_health[id]+givehealth > maxhealth && gtelein_health[id] < maxhealth){
		needmetal = (maxhealth - gtelein_health[id]) * 100 / maxhealth
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[helper] >= needmetal){//正常工作
			gtelein_health[id] = maxhealth
			gengmetal[helper] -= needmetal
			ckrun_showhud_status(id)
			return true
		} else if(gengmetal[helper] < needmetal && gengmetal[helper] > 0){
			gtelein_health[id] += gengmetal[helper] * maxhealth / 100//(当所需金属大于实际拥有金属时给予生命=金属/最大金属*最大生命)
			gengmetal[helper] = 0
			ckrun_showhud_status(id)
			return true
		} else {
			return false
		}
	} else if(gtelein_health[id]+givehealth <= maxhealth){
		needmetal = givehealth * 100 / maxhealth//(实际生命/最大生命*最大金属=所需金属)
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[helper] >= needmetal){//正常工作
			gtelein_health[id] += givehealth
			gengmetal[helper] -= needmetal
			ckrun_showhud_status(id)
			return true
		} else if(gengmetal[helper] < needmetal && gengmetal[helper] > 0) {
			gtelein_health[id] += gengmetal[helper] * maxhealth / 100//(当所需金属大于实际拥有金属时给予生命=金属/最大金属*最大生命)
			gengmetal[helper] = 0
			ckrun_showhud_status(id)
			return true
		} else {
			return false
		}
	}
	return false
}
stock bool:ckrun_give_teleout_health_help(id, helper, percent){//返回值true or false
	if(percent <= 0)
		return false
	new maxhealth
	switch(gtele_level[id]){
		case 1:maxhealth = get_pcvar_num(cvar_build_teleout_hp_lv1)
		case 2:maxhealth = get_pcvar_num(cvar_build_teleout_hp_lv2)
		case 3:maxhealth = get_pcvar_num(cvar_build_teleout_hp_lv3)
	}
	new givehealth = maxhealth * percent / 100
	if(givehealth < 1)
		givehealth = 1
	new needmetal
	if(gteleout_health[id] >= maxhealth){
		return false
	} else if(gteleout_health[id]+givehealth > maxhealth && gteleout_health[id] < maxhealth){
		needmetal = (maxhealth - gteleout_health[id]) * 100 / maxhealth
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[helper] >= needmetal){//正常工作
			gteleout_health[id] = maxhealth
			gengmetal[helper] -= needmetal
			ckrun_showhud_status(id)
			return true
		} else if(gengmetal[helper] < needmetal && gengmetal[helper] > 0){
			gteleout_health[id] += gengmetal[helper] * maxhealth / 100//(当所需金属大于实际拥有金属时给予生命=金属/最大金属*最大生命)
			gengmetal[helper] = 0
			ckrun_showhud_status(id)
			return true
		} else {
			return false
		}
	} else if(gteleout_health[id]+givehealth <= maxhealth){
		needmetal = givehealth * 100 / maxhealth//(实际生命/最大生命*最大金属=所需金属)
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[helper] >= needmetal){//正常工作
			gteleout_health[id] += givehealth
			gengmetal[helper] -= needmetal
			ckrun_showhud_status(id)
			return true
		} else if(gengmetal[helper] < needmetal && gengmetal[helper] > 0) {
			gteleout_health[id] += gengmetal[helper] * maxhealth / 100//(当所需金属大于实际拥有金属时给予生命=金属/最大金属*最大生命)
			gengmetal[helper] = 0
			ckrun_showhud_status(id)
			return true
		} else {
			return false
		}
	}
	return false
}
stock bool:ckrun_give_tele_reload_help(id, percent){//返回值true or false
	if(percent <= 0)
		return false
	new givereload = percent
	if(givereload < 1)
		givereload = 1
	if(gtele_reload[id] >= 100){
		return false
	} else if(gtele_reload[id] + givereload > 100 && gtele_reload[id] < 100){
		gtele_reload[id] = 100
		ckrun_showhud_status(id)
		return true
	} else if(gtele_reload[id] + givereload <= 100){
		gtele_reload[id] += givereload
		ckrun_showhud_status(id)
		return true
	}
	return false
}
stock ckrun_give_tele_upgrade_help(id,helper,percent){//无返回值
	if(percent <= 0)
		return ;
	new maxupgrade
	switch(gtele_level[id]){
		case 1:maxupgrade = get_pcvar_num(cvar_build_tele_cost_lv2)
		case 2:maxupgrade = get_pcvar_num(cvar_build_tele_cost_lv3)
	}
	new giveupgrade = percent
	new needmetal
	if(gtele_upgrade[id]+giveupgrade > maxupgrade && gtele_upgrade[id] < maxupgrade){
		needmetal = maxupgrade - gtele_upgrade[id]
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[helper] >= needmetal){//正常工作
			gtele_upgrade[id] = maxupgrade
			gengmetal[helper] -= needmetal
			ckrun_showhud_status(id)
		} else if(gengmetal[helper] < needmetal && gengmetal[helper] > 0){
			gtele_upgrade[id] += gengmetal[helper]//(当所需金属大于实际拥有金属时给予弹药=金属/最大金属*最大弹药)
			gengmetal[helper] = 0
			ckrun_showhud_status(id)
		}
	} else if(gtele_upgrade[id]+giveupgrade <= maxupgrade){
		needmetal = giveupgrade//(实际生命/最大生命*最大金属=所需金属)
		if(needmetal < 1)
			needmetal = 1
		if(gengmetal[helper] >= needmetal){//正常工作
			gtele_upgrade[id] += giveupgrade
			gengmetal[helper] -= needmetal
			ckrun_showhud_status(id)
		} else if(gengmetal[helper] < needmetal && gengmetal[helper] > 0) {
			gtele_upgrade[id] += gengmetal[helper]//(当所需金属大于实际拥有金属时给予弹药=金属/最大金属*最大弹药)
			gengmetal[helper] = 0
			ckrun_showhud_status(id)
		}
	}
	if(gtele_upgrade[id] >= maxupgrade)
		ckrun_tele_upgrade(id)
	return;
}

stock ckrun_tele_upgrade(id) {
	new telein = gtelein[id]
	new teleout = gteleout[id]
	if(!pev_valid(telein) && !pev_valid(teleout))
		return;
	switch(gtele_level[id]){
		case 1:{
			gtelein_health[id] = get_pcvar_num(cvar_build_telein_hp_lv2)
			gteleout_health[id] = get_pcvar_num(cvar_build_teleout_hp_lv2)
			gtele_level[id] ++
			gtele_upgrade[id] = 0
		}
		case 2:{
			gtelein_health[id] = get_pcvar_num(cvar_build_telein_hp_lv3)
			gteleout_health[id] = get_pcvar_num(cvar_build_teleout_hp_lv3)
			gtele_level[id] ++
			gtele_upgrade[id] = 0
		}
	}
	return;
}

stock ckrun_get_startpos(id,Float:forw,Float:right,Float:up,Float:vStart[]){
	new Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3]
	
	pev(id, pev_origin, vOrigin)
	pev(id, pev_angles, vAngle)
	
	engfunc(EngFunc_MakeVectors, vAngle)
	
	global_get(glb_v_forward, vForward)
	global_get(glb_v_right, vRight)
	global_get(glb_v_up, vUp)
	
	vStart[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up
	vStart[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up
	vStart[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up
	
	return 5
}

stock ckrun_get_user_startpos(id,Float:forw,Float:right,Float:up,Float:vStart[]){
	new Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3]
	
	pev(id, pev_origin, vOrigin)
	pev(id, pev_v_angle, vAngle)

	engfunc(EngFunc_MakeVectors, vAngle)
	
	global_get(glb_v_forward, vForward)
	global_get(glb_v_right, vRight)
	global_get(glb_v_up, vUp)
	
	vStart[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up
	vStart[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up
	vStart[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up
	
	return 5
}

stock str_count(const str[], searchchar){
	static count, i
	count = 0
	for (i = 0; i <= strlen(str); i++){
		if(str[i] == searchchar)
			count++
	}
	return count
}
//Ckrun-Create系列
public ckrun_create_item(parm[]){
	if(!parm[3]) return;//无物品类型
	new Float:origin[3]
	origin[0] = float(parm[0])
	origin[1] = float(parm[1])
	origin[2] = float(parm[2])
	new item = parm[3]
	new entity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "armoury_entity"))
	new Float:Angle[3]
	Angle[1] = random_float(0.0,360.0)
	set_pev(entity, pev_angles, Angle)
	set_pev(entity, pev_origin, origin)
	switch(item){
		case CKI_HEALTHKIT:{//自定义血包
			engfunc(EngFunc_SetModel, entity, mdl_w_healthkit)
			set_pev(entity, CKI_TYPE, CKI_TYPE_HEALTH)
			set_pev(entity, CKI_PARM, get_pcvar_num(cvar_supply_item_healthkit))
		}
		case CKI_AMMOBOX:{//弹药
			engfunc(EngFunc_SetModel, entity, mdl_w_ammobox)
			set_pev(entity, CKI_TYPE, CKI_TYPE_AMMO)
			set_pev(entity, CKI_PARM, get_pcvar_num(cvar_supply_item_ammobox))
		}
		case CKI_BUGKILLER:{//直接死
			engfunc(EngFunc_SetModel, entity, mdl_w_bugkiller)
			set_pev(entity, CKI_TYPE, CKI_TYPE_BUGKILLER)
		}
		case CKI_RPG:{//弹药
			engfunc(EngFunc_SetModel, entity, mdl_w_rpg)
			set_pev(entity, CKI_TYPE, CKI_TYPE_AMMO)
			set_pev(entity, CKI_PARM, get_pcvar_num(cvar_supply_item_weapon))
		}
		case CKI_MEDICGUN:{//弹药
			engfunc(EngFunc_SetModel, entity, mdl_w_medicgun)
			set_pev(entity, CKI_TYPE, CKI_TYPE_AMMO)
			set_pev(entity, CKI_PARM, get_pcvar_num(cvar_supply_item_weapon))
		}
		case CKI_TOOLBOX:{//弹药
			engfunc(EngFunc_SetModel, entity, mdl_w_toolbox)
			set_pev(entity, CKI_TYPE, CKI_TYPE_AMMO)
			set_pev(entity, CKI_PARM, get_pcvar_num(cvar_supply_item_weapon))
		}

	}
	set_pev(entity, pev_mins, {-8.0, -8.0, -0.0})
	set_pev(entity, pev_maxs, {8.0, 8.0, 16.0})

	set_pev(entity, pev_solid, SOLID_TRIGGER)
	set_pev(entity, pev_movetype, MOVETYPE_TOSS)
}
public ckrun_create_item_temp(parm[]){//临时物品保留于当前回合
	if(parm[3] == 0) return;//无此物品类型
	new Float:origin[3]
	origin[0] = float(parm[0])
	origin[1] = float(parm[1])
	origin[2] = float(parm[2])
	new item = parm[3]
	new entity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "weaponbox"))
	new Float:Angle[3]
	Angle[1] = random_float(0.0, 360.0)
	set_pev(entity, pev_angles, Angle)
	set_pev(entity, pev_origin, origin)
	switch(item){
		case CKI_HEALTHKIT:{//自定义血包
			engfunc(EngFunc_SetModel, entity, mdl_w_healthkit)
			set_pev(entity, CKI_TYPE, CKI_TYPE_HEALTH)
			set_pev(entity, CKI_PARM, get_pcvar_num(cvar_supply_item_healthkit))
		}
		case CKI_AMMOBOX:{//弹药
			engfunc(EngFunc_SetModel, entity, mdl_w_ammobox)
			set_pev(entity, CKI_TYPE, CKI_TYPE_AMMO)
			set_pev(entity, CKI_PARM, get_pcvar_num(cvar_supply_item_ammobox))
		}
		case CKI_BUGKILLER:{//直接死
			engfunc(EngFunc_SetModel, entity, mdl_w_bugkiller)
			set_pev(entity, CKI_TYPE, CKI_TYPE_BUGKILLER)
		}
		case CKI_RPG:{//弹药
			engfunc(EngFunc_SetModel, entity, mdl_w_rpg)
			set_pev(entity, CKI_TYPE, CKI_TYPE_AMMO)
			set_pev(entity, CKI_PARM, get_pcvar_num(cvar_supply_item_weapon))
		}
		case CKI_MEDICGUN:{//弹药
			engfunc(EngFunc_SetModel, entity, mdl_w_medicgun)
			set_pev(entity, CKI_TYPE, CKI_TYPE_AMMO)
			set_pev(entity, CKI_PARM, get_pcvar_num(cvar_supply_item_weapon))
		}
		case CKI_TOOLBOX:{//弹药
			engfunc(EngFunc_SetModel, entity, mdl_w_toolbox)
			set_pev(entity, CKI_TYPE, CKI_TYPE_AMMO)
			set_pev(entity, CKI_PARM, get_pcvar_num(cvar_supply_item_weapon))
		}
	}
	set_pev(entity, pev_mins, {-1.0, -1.0, -1.0})
	set_pev(entity, pev_maxs, {1.0, 1.0, 1.0})

	set_pev(entity, pev_solid, SOLID_TRIGGER)
	set_pev(entity, pev_movetype, MOVETYPE_TOSS)
}
public ckrun_item_create_edit(parm[]){
	new Float:origin[3]
	origin[0] = float(parm[0])
	origin[1] = float(parm[1])
	origin[2] = float(parm[2])
	new item = parm[3]
	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	new Float:Angle[3]
	Angle[1] = random_float(0.0,360.0)

	set_pev(ent, pev_angles, Angle)
	set_pev(ent, pev_origin, origin)
	switch(item){
		case CKI_HEALTHKIT:{
			engfunc(EngFunc_SetModel, ent, mdl_w_healthkit)
			set_pev(ent, pev_classname, "edit_healthkit")
			client_print_colored(0, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", LANG_PLAYER, "MSG_EDIT_CREATED", LANG_PLAYER, "NAME_ITEM_HEALTHKIT", floatround(origin[0]), floatround(origin[1]), floatround(origin[2]) )
		}
		case CKI_AMMOBOX:{
			engfunc(EngFunc_SetModel, ent, mdl_w_ammobox)
			set_pev(ent, pev_classname, "edit_ammobox")
			client_print_colored(0, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", LANG_PLAYER, "MSG_EDIT_CREATED", LANG_PLAYER, "NAME_ITEM_AMMOBOX", floatround(origin[0]), floatround(origin[1]), floatround(origin[2]) )
		}
		case CKI_BUGKILLER:{
			engfunc(EngFunc_SetModel, ent, mdl_w_bugkiller)
			set_pev(ent, pev_classname, "edit_bugkiller")
			client_print_colored(0, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", LANG_PLAYER, "MSG_EDIT_CREATED", LANG_PLAYER, "NAME_ITEM_BUGKILLER", floatround(origin[0]), floatround(origin[1]), floatround(origin[2]) )
		}
	}
	fm_set_rendering(ent,kRenderFxNone, 0,0,0, kRenderTransTexture, 150)
	set_pev(ent, pev_mins, {-1.0, -1.0, -1.0})
	set_pev(ent, pev_maxs, {1.0, 1.0, 1.0})
	set_pev(ent, pev_solid, SOLID_TRIGGER)
	set_pev(ent, pev_movetype, MOVETYPE_TOSS)
}
//========================================//

//Ckrun_FakeDamage系列
public ckrun_fakedamage_build(id, enemy, damage, wpn, build){
	if(!(1 <= id <= g_maxplayers) || damage <= 0) return;
	if(g_round != round_zombie) return;
	new health
	switch(build){
		case 1:{
			if(giszm[id] || !ghavesentry[id]) return;
			health = gsentry_health[id]
			if(health <= 0) return;
			if(health - damage > 0){
				gsentry_health[id] -= damage
			} else {
				ckrun_sentry_destory(id)
				ckrun_fakekill_msg(id + DEATHMSG_SENTRY, enemy, g_wpn_name[wpn], 0)
			}
		}
		case 2:{
			if(giszm[id] || !ghavedispenser[id]) return;
			health = gdispenser_health[id]
			if(health <= 0) return;
			if(health - damage > 0){
				gdispenser_health[id] -= damage
			} else {
				ckrun_dispenser_destory(id)
				ckrun_fakekill_msg(id + DEATHMSG_DISPENSER, enemy, g_wpn_name[wpn], 0)
			}
		}
		case 3:{
			if(giszm[id] || !ghavetelein[id]) return;
			health = gtelein_health[id]
			if(health <= 0) return;
			if(health - damage > 0){
				gtelein_health[id] -= damage
			} else {
				ckrun_telein_destory(id, 0)
				ckrun_fakekill_msg(id + DEATHMSG_TELEIN, enemy, g_wpn_name[wpn], 0)
			}
		}
		case 4:{
			if(giszm[id] || !ghaveteleout[id]) return;
			health = gteleout_health[id]
			if(health <= 0) return;
			if(health - damage > 0){
				gteleout_health[id] -= damage
			} else {
				ckrun_teleout_destory(id, 0)
				ckrun_fakekill_msg(id + DEATHMSG_TELEOUT, enemy, g_wpn_name[wpn], 0)
			}
		}
	}
}
stock ckrun_get_weapon_name(weapon, wpname[], len){
	if(weapon < 1 || weapon > 40)
		format(wpname, len, "OMGWTFBBQ")
	else
		format(wpname, len, "%s", g_wpn_name[weapon])
	return 2
}
stock ckrun_fakedamage(id, enemy, wpn, dmg, dmg_type){
	//受害者,攻击者,武器,伤害,伤害类型(武器不为枪械类时根据dmg_type判定造成伤害的武器)
	//只能作用于玩家攻击
	if(!is_user_alive(id) || !is_user_alive(enemy) || dmg <= 0)
		return 0
	if(giszm[enemy] == giszm[id] && enemy != id)
		return 0
	if(id == g_ctbot || id == g_tbot)
		return 0
	new health = get_user_health(id)
	new bool:gib
	new wpname[24]

	switch(dmg_type){
		case CKD_BULLET: 	gib = false
		case CKD_ROCKET: 	gib = true
		case CKD_FIRE:		gib = false
		case CKD_SLASH:		gib = false
		case CKD_PUNCH:		gib = true
		default:		gib = false
	}

	if(id == enemy || !(1 <= enemy <= g_maxplayers)){
		if(health - dmg > 0){
			fm_set_user_health(id, health - dmg)
			if(random_num(1, 10) <= get_pcvar_num(cvar_global_blood))
				FX_BloodDecal(id)
			if(random_num(1, 10) <= get_pcvar_num(cvar_global_blood))
				FX_Blood(id, 1)
		} else {
			ckrun_get_weapon_name(wpn, wpname, sizeof wpname - 1)
			ckrun_fakekill_msg(id, id, wpname,0)
			if(gib)	FX_Gibs(id)
			ExecuteHamB(Ham_Killed, id, enemy, 0)
		}
		return 1
	}
	new bool:crit
	new auto = ckrun_is_weapon_auto(wpn)//-1=无暴击 0=半自动武器暴击 1=自动武器暴击
	if(auto != -1)
		if(gcritical_on[enemy]){
			dmg *= (get_pcvar_num(cvar_global_crit_multi) / 100)
			FX_Critical(enemy,id)
			crit = true
		}
	if(health - dmg > 0){
		fm_set_user_health(id, health - dmg)
		if(random_num(1, 10) <= get_pcvar_num(cvar_global_blood))
			FX_BloodDecal(id)
		if(random_num(1, 10) <= get_pcvar_num(cvar_global_blood)){
			if(dmg >= 250)
				FX_Blood(id, 3)
			else if (dmg >= 100 && dmg < 250)
				FX_Blood(id, 2)
			else if (dmg >= 10 && dmg < 100)
				FX_Blood(id, 1)
		}
	} else {
		if(gib) FX_Gibs(id)
		if(crit){
			gcritkilled[id] = 1;
			check_ach_fast_6(id)
		}
		ExecuteHamB(Ham_Killed, id, enemy, 0)
		ckrun_get_weapon_name(wpn, wpname, sizeof wpname - 1)
		ckrun_fakekill_msg(id, enemy, wpname, gcritkilled[id])
	}
	if(!is_user_alive(glastatk[id]) || giszm[glastatk[id]]){
		glastatk[id] = enemy
	} else if (!is_user_alive(glast2atk[id]) || giszm[glast2atk[id]]){
		glast2atk[id] = enemy
	} else if (glastatk[id] != enemy && glast2atk[id] != enemy){
		glast2atk[id] = enemy
	} else if (glastatk[id] != enemy && glast2atk[id] == enemy){
		glast2atk[id] = glastatk[id]
		glastatk[id] = enemy
	}
	return 1
}
public fw_wpnfire_m249(wpn){
	new id = pev(wpn, pev_owner)
	if(!is_user_alive(id))
		return HAM_IGNORED
	if(fm_get_weapon_ammo(wpn) <= 0)
		return HAM_IGNORED

	ckrun_knockback(id,id,get_pcvar_num(cvar_wpn_minigun_backforce),0)

	new Float:idorigin[3],Float:targetorigin[3],Float:hitorigin[3],hitent
	new Float:right,Float:up,force
	pev(id, pev_origin, idorigin)
	idorigin[2] += 13.5
	if(pev(id, pev_flags) & FL_DUCKING)
	idorigin[2] -= 8.0
	fm_get_aim_origin(id, hitorigin)
	for(new i=0;i <= 2;i++){
		right = random_float(-400.0,400.0)
		up = random_float(0.0,800.0)
		ckrun_get_user_startpos(id,4096.0,right,up,targetorigin)
		hitent = fm_trace_line(id, idorigin, targetorigin, hitorigin)
		new dmg = random_num(10,20) * get_pcvar_num(cvar_wpn_multidamage_m249) / 100
		if(is_user_alive(hitent))
			if(giszm[hitent]){
				force = ckrun_get_user_force(hitent, dmg)
				ckrun_knockback(hitent, id, force, 0)
				ckrun_fakedamage(hitent, id, CSW_M249, dmg, CKD_BULLET)
			}
		if(!gcritical_on[id])
			FX_Trace(idorigin,hitorigin)
		else
			FX_ColoredTrace_point(idorigin,hitorigin)
	} 
	return HAM_IGNORED
}
public fw_wpnfire_shotgun(wpn){
	new id = pev(wpn, pev_owner)
	if(!is_user_alive(id))
		return HAM_IGNORED
	if(fm_get_weapon_ammo(wpn) <= 0)
		return HAM_IGNORED
	if(gwpntraced[id]){
		gwpntraced[id] = false
		return HAM_IGNORED
	}
	new Float:idorigin[3],Float:targetorigin[3],Float:hitorigin[3]
	new Float:right,Float:up
	pev(id, pev_origin, idorigin)
	idorigin[2] += 13.5
	if(pev(id, pev_flags) & FL_DUCKING)
	idorigin[2] -= 8.0
	fm_get_aim_origin(id, hitorigin)
	for(new i=0;i <= 3;i++){
		right = random_float(-250.0,250.0)
		up = random_float(-150.0,350.0)
		ckrun_get_user_startpos(id,4096.0,right,up,targetorigin)
		fm_trace_line(id, idorigin, targetorigin, hitorigin)
		if(!gcritical_on[id])
			FX_Trace(idorigin,hitorigin)
		else
			FX_ColoredTrace_point(idorigin,hitorigin)
	}
	return HAM_IGNORED
}
public fw_wpndraw_knife(ent){
	static id;id = pev(ent, pev_owner)
	if(!is_user_alive(id)) return;
	if(!giszm[id]){
		switch(gknife[id]){//新刀子模型替换
			case knife_normal:{
				set_pev(id, pev_viewmodel2, mdl_v_knife)
				set_pev(id, pev_weaponmodel2, mdl_p_knife)
			}
			case knife_hammer:{
				set_pev(id, pev_viewmodel2, mdl_v_hammer)
				set_pev(id, pev_weaponmodel2, mdl_p_hammer)
			}
		}
	} else {
		switch(gzombie[id]){
			case zombie_fast:{
				if(gknife[id] == knife_moonstar){
					set_pev(id, pev_viewmodel2, mdl_v_moonstar)
					set_pev(id, pev_weaponmodel2, mdl_p_moonstar)
				}
			}
			case zombie_invis:{
				if(ginvisible[id])
					set_pev(id, pev_viewmodel2, mdl_v_knife_invis)
				else
					set_pev(id, pev_weaponmodel2, mdl_v_knife_stab)
			}
			default : {
				set_pev(id, pev_viewmodel2, mdl_v_knife)
				set_pev(id, pev_weaponmodel2, mdl_p_knife)
			}
		}
	}
}
public fw_wpndraw_custom(ent){
	static id;id = pev(ent, pev_owner)
	if(!is_user_alive(id)) return;
	switch(ghuman[id]){
		case human_rpg:{
			set_pev(id, pev_viewmodel2, mdl_v_rpg)
			set_pev(id, pev_weaponmodel2, mdl_p_rpg)
			grpgready[id] = false
			remove_task(id+TASK_RPG_GETREADY, 0)
			set_task(float(get_pcvar_num(cvar_wpn_rpg_rof))/1000.0, "rpg_getready", id+TASK_RPG_GETREADY)
			fm_set_user_anim(id, anim_c4_draw)
		}
		case human_log:{
			switch(glogmode[id]){
				case 1:{
					set_pev(id, pev_viewmodel2, mdl_v_medicgun)
					set_pev(id, pev_weaponmodel2, mdl_p_medicgun)
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, "items/gunpickup3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
				case 2:{
					set_pev(id, pev_viewmodel2, mdl_v_ammopack)
					set_pev(id, pev_weaponmodel2, mdl_p_ammopack)
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, "items/gunpickup3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
			}
			fm_set_user_anim(id, anim_c4_draw)
		}
		case human_eng:{
			switch(gengmode[id]){
				case 1:{
					set_pev(id, pev_viewmodel2, mdl_v_toolbox)
					set_pev(id, pev_weaponmodel2, mdl_p_toolbox)
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, "items/gunpickup3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					fm_set_user_anim(id, anim_c4_draw)
				}
				case 2:{
					set_pev(id, pev_viewmodel2, mdl_v_pda)
					set_pev(id, pev_weaponmodel2, mdl_p_pda)
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, "items/gunpickup3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					fm_set_user_anim(id, anim_c4_draw)
				}
			}
		}
		default:ham_strip_weapon(id, "weapon_c4")
	}
}
public fw_wpndraw_m249(ent){
	static id;id = pev(ent, pev_owner)
	if(!is_user_alive(id)) return;
	set_pev(id, pev_viewmodel2, mdl_v_minigun)
	set_pev(id, pev_weaponmodel2, mdl_p_minigun)
	fm_set_user_anim(id, anim_m249_draw)
}
public fw_wpnholster_custom(ent){
	static id;id = pev(ent, pev_owner)
	if(!is_user_alive(id)) return;
	switch(ghuman[id]){
		case human_rpg:{
			grpgready[id] = false
			grpgreloading[id] = false
			remove_task(id+TASK_RPG_GETREADY, 0)
			remove_task(id+TASK_RPG_RELOAD, 0)
		}
		case human_log:{
			gmedicing[id] = false
			gmediced[gmedictarget[id]] = 0
			gmedictarget[id] = 0
			gammoing[id] = false
			gammoed[gammotarget[id]] = 0
			gammotarget[id] = 0
			remove_task(id+TASK_MEDIC, 0)
			remove_task(id+TASK_AMMOSUPPLY, 0)
		}
	}
}
public fw_wpnfire_custom(ent){
	static id;id = pev(ent, pev_owner)
	if(!is_user_alive(id)) return;
	switch(ghuman[id]){
		case human_eng: {
			switch(gengmode[id]){
				case 1:show_menu_build(id)
				case 2:show_menu_demolish(id)
			}
		}
	}
}
public fw_wpnholster_sniperifle(ent){
	static id;id = pev(ent, pev_owner)
	if(!is_user_alive(id)) return;
	if(giszm[id] || ghuman[id] != 4) return;
	funcSnipeReset(id)
}
public FX_Lightning(){
	if(g_lightning == 0){
		FX_Environment()
		return
	}
	switch(g_lightning){
		case 1:{
			g_lightning ++
			engfunc(EngFunc_LightStyle, 0, "z")
		}
		case 2:{
			g_lightning ++
			engfunc(EngFunc_LightStyle, 0, "v")
		}
		case 3:{
			g_lightning ++
			engfunc(EngFunc_LightStyle, 0, "r")
		}
		case 4:{
			g_lightning ++
			engfunc(EngFunc_LightStyle, 0, "p")
		}
		case 5:{
			g_lightning = 0
			fm_PlaySound(0, snd_thunder[random_num(0,sizeof snd_thunder - 1)])
			FX_Environment()
			return
		}
	}
	remove_task(TASK_LIGHTNING,0)
	if(g_lightning > 0 && g_lightning <= 5)
		set_task(0.1, "FX_Lightning", TASK_LIGHTNING)
}

public FX_Environment(){
	remove_task(TASK_ENVIRONMENT,0)
	set_task(5.0, "FX_Environment", TASK_ENVIRONMENT)
	if(g_lightning > 0 && g_lightning < 5) return
	switch(get_pcvar_num(cvar_global_light)){
		case 0:engfunc(EngFunc_LightStyle, 0, "a")
		case 1:engfunc(EngFunc_LightStyle, 0, "b")
		case 2:engfunc(EngFunc_LightStyle, 0, "c")
		case 3:engfunc(EngFunc_LightStyle, 0, "d")
		case 4:engfunc(EngFunc_LightStyle, 0, "e")
		case 5:engfunc(EngFunc_LightStyle, 0, "f")
		case 6:engfunc(EngFunc_LightStyle, 0, "g")
		case 7:engfunc(EngFunc_LightStyle, 0, "h")
		case 8:engfunc(EngFunc_LightStyle, 0, "i")
		case 9:engfunc(EngFunc_LightStyle, 0, "j")
		case 10:engfunc(EngFunc_LightStyle, 0, "k")
	}
	new lightning
	switch(get_pcvar_num(cvar_global_lightning)){
		case 0:lightning = 0
		case 1:lightning = 2
		case 2:lightning = 4
		case 3:lightning = 6
		case 4:lightning = 8
		case 5:lightning = 10
	}
	if(lightning >= random_num(1,10)){
		g_lightning = 1
		FX_Lightning()
	}
}
#if defined AMBIENCE_SOUND
public FX_AmbienceSound(taskid){
	static id
	if(taskid > g_maxplayers)
		id = taskid - TASK_AMBIENCE_SOUND
	else
		id = taskid
	remove_task(id+TASK_AMBIENCE_SOUND,0)
	if(!is_user_alive(id)) return
	client_cmd(id, "mp3 stop; stopsound")
	if (equal(snd_ambience[strlen(snd_ambience)-4], ".mp3"))
		client_cmd(id, "mp3 play ^"%s^"", snd_ambience)
	else
		fm_PlaySound(id, snd_ambience)
	set_task(snd_ambience_duration, "FX_AmbienceSound", id+TASK_AMBIENCE_SOUND)
}
#endif
public fw_TraceAttack_Pushable(ent, attacker, Float:damage, Float:direction[3]){
	if (!(1 <= attacker <= g_maxplayers)) return;

	static Float:velocity[3]
	pev(ent, pev_velocity, velocity)

	xs_vec_mul_scalar(direction, damage, direction)

	xs_vec_add(velocity, direction, direction)

	direction[2] = velocity[2]

	set_pev(ent, pev_velocity, direction)
}
public fw_Touch_Pushable(ptd, ptr){
	if (!pev_valid(ptr))
		return HAM_IGNORED
	return HAM_SUPERCEDE
}
public fw_TraceLine_Post(Float:start[3], Float:end[3], noMonsters, id, trace){
	if(!(1 <= id <= g_maxplayers))
		return FMRES_IGNORED
	if (!is_user_alive(id))
		return FMRES_IGNORED
	if (is_user_bot(id))
		return FMRES_IGNORED
	new target = get_tr(TR_pHit)
	if(!pev_valid(target)){
		gaiming[id] = 0
		gaiming_a_build[id] = 0
		return FMRES_IGNORED
	}
	new classname[32]
	pev(target, pev_classname, classname, 31)
	gaiming_a_build[id] = 0
	gaiming[id] = 0
	if(equal(classname,"sentry_base") || equal(classname,"sentry_turret")){
		gaiming[id] = pev(target, BUILD_OWNER)
		gaiming_a_build[id] = 1
	} else if (equal(classname,"dispenser")){
		gaiming[id] = pev(target, BUILD_OWNER)
		gaiming_a_build[id] = 2
	} else if (equal(classname,"telein")){
		gaiming[id] = pev(target, BUILD_OWNER)
		gaiming_a_build[id] = 3
	} else if (equal(classname,"teleout")){
		gaiming[id] = pev(target, BUILD_OWNER)
		gaiming_a_build[id] = 4
	} else if (equal(classname,"player")){
		if(is_user_alive(target)){
			gaiming[id] = target
			gaiming_a_build[id] = 0
			if(gdisguising[target]){//对方伪装中
				gaiming[id] = gdisguise_target[target]
				if(!is_user_alive(gaiming[id]) || giszm[gaiming[id]])//挂了或者是僵尸
					gaiming[id] = id//看他显示看自己
			} else if(ginvisible[target]){
				gaiming[id] = 0
			}
			//星月斩
			if(giszm[id] && gzombie[id] == zombie_fast){
				new wpnid = get_user_weapon(id)
				if (wpnid != CSW_KNIFE){
					moonslash_cancel(id);
					return FMRES_IGNORED;
				}
				new enemy = gmoonslash_target[id];
				if (!is_user_alive(enemy)){
					enemy = get_tr2(trace, TR_pHit);
					if (giszm[enemy]){
						moonslash_cancel(id)
						return FMRES_IGNORED;
					}
					gmoonslash_target[id] = enemy
				}
			}
			//星月斩
		} else {
			if(giszm[id] && gzombie[id] == 1){
				moonslash_cancel(id);
			}
		}
	}
	return FMRES_IGNORED
}
public fw_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch){
	if (!(1 <= id <= g_maxplayers))
		return FMRES_IGNORED
	if (equal(sample[8], "kni", 3))
		if(!equal(sample,"weapons/knife_deploy1.wav") && !equal(sample,"weapons/knife_slash1.wav") && !equal(sample,"weapons/knife_slash2.wav")){
			if(!giszm[id] && ghuman[id] == 6){
				if(gknife[id] == knife_hammer){//新刀子声音替换
					engfunc(EngFunc_EmitSound, id, channel, snd_hammer[random_num(0,sizeof snd_hammer - 1)], volume, attn, flags, pitch)
					return FMRES_SUPERCEDE
				}
			}
		}
	#if defined CUSTOM_DEATHSOUND
	new i
	if (equal(sample[7], "die", 3) || equal(sample[7], "dea", 3)){
		for (i = 0 ; i < sizeof snd_death_model ; i++)
			if(equal(snd_death_model[i], gcurmodel[id])){
				engfunc(EngFunc_EmitSound, id, channel, snd_death_custom[i], volume, attn, flags, pitch)
				return FMRES_SUPERCEDE
			}
	}
	#endif
	return FMRES_IGNORED
}
public fw_GameDesc(){
	forward_return(FMV_STRING, g_modname)
	return FMRES_SUPERCEDE
}
public fw_ClientKill(id){
	if(!is_user_alive(id))
		return FMRES_IGNORED
	if(giszm[id]){
		client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_NOSUICIDE")
		return FMRES_SUPERCEDE
	}
	return FMRES_IGNORED
}

public fw_SetClientKeyValue(id, const infobuffer[], const key[]){
	if (equal(key, "model"))
		return FMRES_SUPERCEDE;
	return FMRES_IGNORED;
}
public fw_ClientUserInfoChanged(id){
	new model[32]
	fm_get_user_model(id, model, sizeof model - 1)

	if (!equal(model, gcurmodel[id]))
		fm_set_user_model(id, gcurmodel[id])
}
public fw_SetModel(entity, model[]) {
	if (!pev_valid(entity))
		return FMRES_IGNORED
	if (equal(model, "models/w_backpack.mdl")){
		new Float:forigin[3],parm[4]
		pev(entity, pev_origin, forigin)
		ckrun_FVecIVec(forigin, parm)
		new owner = pev(entity, pev_owner)
		if(is_user_connected(owner)){
			switch(ghuman[owner]){
				case 3:parm[3] = CKI_RPG
				case 5:parm[3] = CKI_MEDICGUN
				case 6:parm[3] = CKI_TOOLBOX
				default: return FMRES_IGNORED//你哪来的包?..
			}
			ckrun_create_item_temp(parm)
		}
	}
	return FMRES_IGNORED
}

public fw_UpdateClientData_Post(id, sendweapons, cd_handle){
	if(!is_user_alive(id))
		return FMRES_IGNORED;
	new wpn = get_user_weapon(id)
	if(ghuman[id] == human_rpg && wpn == CSW_C4){
		set_cd(cd_handle, CD_ID, 0);
		return FMRES_HANDLED;
	} else if(wpn == CSW_M249){
		if(gminigun_spin[id] != minigun_spining){
			set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001)
			return FMRES_HANDLED;
		}
	} else if(giszm[id] && gzombie[id] == zombie_invis){
		if(gstabing[id]){
			set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001)
			set_cd(cd_handle, CD_ID, 0);
			return FMRES_HANDLED;
		} else if(gdisguising[id]){
			set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001)
			set_cd(cd_handle, CD_ID, 0);
			return FMRES_HANDLED;
		}
	} else if(gfrozen[id]){
		set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001)
		set_cd(cd_handle, CD_ID, 0);
		return FMRES_HANDLED;
	}
	return FMRES_IGNORED;
}

public fw_AddToFullPack_Post(es_handle,e,ent,host,hostflags,player,pSet){
	if(pev_valid(ent)){
		new class[32]
		pev(ent, pev_classname, class, 31)
		if(equal(class, "telein")){
			new owner = pev(ent, BUILD_OWNER)
			if(ghavetelein[owner] && !gtelein_building[owner] && giszm[host]){
				set_es(es_handle, ES_RenderMode, kRenderTransTexture)
				new renderamt = floatround(-2.55*float(gtele_reload[owner])+255.0)
				if(renderamt > 255) renderamt = 255
				switch(gtele_level[owner]){
					case 1:	if(renderamt < get_pcvar_num(cvar_build_tele_trans_lv1)) renderamt = get_pcvar_num(cvar_build_tele_trans_lv1)
					case 2: if(renderamt < get_pcvar_num(cvar_build_tele_trans_lv2)) renderamt = get_pcvar_num(cvar_build_tele_trans_lv2)
					case 3: if(renderamt < get_pcvar_num(cvar_build_tele_trans_lv3)) renderamt = get_pcvar_num(cvar_build_tele_trans_lv3)
				}
				set_es(es_handle, ES_RenderAmt, renderamt)
				return FMRES_IGNORED
			}
		} else if(equal(class, "teleout")){
			new owner = pev(ent, BUILD_OWNER)
			if(ghaveteleout[owner] && !gteleout_building[owner] && giszm[host]){
				set_es(es_handle, ES_RenderMode, kRenderTransTexture)
				new renderamt = floatround(-2.55*float(gtele_reload[owner])+255.0)
				if(renderamt > 255) renderamt = 255
				switch(gtele_level[owner]){
					case 1:	if(renderamt < get_pcvar_num(cvar_build_tele_trans_lv1)) renderamt = get_pcvar_num(cvar_build_tele_trans_lv1)
					case 2: if(renderamt < get_pcvar_num(cvar_build_tele_trans_lv2)) renderamt = get_pcvar_num(cvar_build_tele_trans_lv2)
					case 3: if(renderamt < get_pcvar_num(cvar_build_tele_trans_lv3)) renderamt = get_pcvar_num(cvar_build_tele_trans_lv3)
				}
				set_es(es_handle, ES_RenderAmt, renderamt)
				return FMRES_IGNORED
			}
		}
	}
	if(!player)
		return FMRES_IGNORED
	if(!giszm[host]){
		if(giszm[ent] && gzombie[ent] == zombie_invis)
			if(ginvisible[ent]){
				set_es(es_handle,ES_RenderMode,kRenderTransTexture)
				set_es(es_handle,ES_RenderAmt,0)
			} else if(gdisguising[ent]){
				set_es(es_handle,ES_RenderMode,kRenderNormal)
				set_es(es_handle,ES_RenderAmt,255)
			} else {
				set_es(es_handle,ES_RenderMode,kRenderTransTexture)
				set_es(es_handle,ES_RenderAmt,50)
			}
	} else {
		if(gdisguising[ent]){
			set_es(es_handle,ES_RenderFx,kRenderFxGlowShell)
			set_es(es_handle,ES_RenderColor, {64, 64, 64})
			set_es(es_handle,ES_RenderAmt, 32)
		} else if (ginvisible[ent]){
			set_es(es_handle,ES_RenderFx,kRenderFxGlowShell)
			set_es(es_handle,ES_RenderColor, {192, 192, 192})
			set_es(es_handle,ES_RenderAmt, 32)
		}
	}
	return FMRES_IGNORED
}
public clcmd_zspawn(id){
	if(is_user_alive(id)){
		client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_ZSPAWN_ALIVE")
		return PLUGIN_HANDLED
	}
	if(g_zspawned[id]){
		client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_ZSPAWN_ONCE")
		return PLUGIN_HANDLED
	}
	if(g_round != round_zombie){
		client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_ZSPAWN_NOZOMBIE")
		return PLUGIN_HANDLED
	}
	if(get_user_team(id) != 1 && get_user_team(id) != 2) return PLUGIN_HANDLED
	g_zspawned[id] = true
	giszm[id] = true
	set_task(0.1, "respawn", id+TASK_RESPAWN)
	client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_ZSPAWN_SUCCESS")
	return PLUGIN_HANDLED
}

public clcmd_ztele(id){
	if(g_gamemode != mode_normal)
		return PLUGIN_HANDLED;
	if(!is_user_alive(id))
		return PLUGIN_HANDLED;
	if(gtelecd[id] && giszm[id]){
		client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_TELE_CD")
		return PLUGIN_HANDLED;
	}
	if(giszm[id]){
		tele_to_spawn(id)
		gtelecd[id] = true
		remove_task(id+TASK_TELECD, 0)
		set_task(float(get_pcvar_num(cvar_global_tele_cd)), "reset_user_telecd", id+TASK_TELECD)
		client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_TELE_CDSTART", get_pcvar_num(cvar_global_tele_cd))
		return PLUGIN_HANDLED;
	} else {
		if(gteletimes[id] <= 0){
			client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_TELE_USEUP")
			return PLUGIN_HANDLED;
		}
		tele_to_spawn(id)
		gteletimes[id] --
		client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_TELE_REMAIN",gteletimes[id])
	}
	return PLUGIN_HANDLED;
}
public reset_user_telecd(taskid){
	static id
	if(taskid > g_maxplayers)
		id = taskid - TASK_TELECD
	else
		id = taskid
	gtelecd[id] = false
	remove_task(id+TASK_TELECD, 0)
}

public clcmd_zsave(id){
	if(!(get_user_flags(id) & ACCESS_VIP)){
		client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_SAVE_VIP")
		return PLUGIN_HANDLED;
	}
	if(get_gametime() - g_lastsave[id] < SAVE_DELAY){
		client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_SAVE_WAIT", floatround(SAVE_DELAY - get_gametime() + g_lastsave[id]))
		return PLUGIN_HANDLED;
	} else {
		g_lastsave[id] = get_gametime()
		client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_SAVE_SUCCESS")
		funcSaveAll(id)
	}
	return PLUGIN_HANDLED;
}

public hide_money(taskid){//清空并隐藏玩家金钱
	static id
	if(taskid > g_maxplayers)
		id = taskid - TASK_HIDEMONEY
	else
		id = taskid
	if (!is_user_alive(id)) return;

	message_begin(MSG_ONE, g_msgHideWeapon, _, id)
	write_byte(HIDE_MONEY) // what to hide bitsum
	message_end()

	message_begin(MSG_ONE, g_msgCrosshair, _, id)
	write_byte(0) // toggle
	message_end()

	fm_set_user_money(id, 0)
}

public check_ach_fast_1(id){//[嗜血成性] 一局内获得的杀敌数达到所有人中最高
	if(!is_user_connected(id)) return
	if(!giszm[id]) return
	if(gzombie[id] != 1) return
	if(g_ach_fast[id][ach_fast_1]) return

	if(get_players_num() < 8) return
	new first
	for(new i; i < g_maxplayers; i++){
		if(is_user_connected(i)){
			if(g_roundkill[i] > first) first = gkill[i]
		}
	}
	if(g_roundkill[id] < first) return

	g_ach_fast[id][ach_fast_1] = 1
	client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_ACH_COMPLETED", id, ach_fast_formatname[ach_fast_1] )
}

public check_ach_fast_2(id){//[值得纪念的一天] 累计感染/杀死512个敌人
	if(!is_user_connected(id)) return
	if(!giszm[id]) return
	if(gzombie[id] != 1) return
	if(g_ach_fast[id][ach_fast_2] >= ach_fast_progress[ach_fast_2]) return
	if(g_ach_fast[id][ach_fast_2] + 1 == ach_fast_progress[ach_fast_2] / 2){
		g_ach_fast[id][ach_fast_2] ++
		client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_ACH_PROGRESS", id, ach_fast_formatname[ach_fast_2], g_ach_fast[id][ach_fast_2], ach_fast_progress[ach_fast_2])
	} else if(g_ach_fast[id][ach_fast_2] + 1 == ach_fast_progress[ach_fast_2]){
		g_ach_fast[id][ach_fast_2] = ach_fast_progress[ach_fast_2]
		client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_ACH_COMPLETED", id, ach_fast_formatname[ach_fast_2])
	} else {
		g_ach_fast[id][ach_fast_2] ++
	}
}

public check_ach_fast_3(id){//[同行交手] 累计感染/杀死50个侦察兵
	if(!is_user_connected(id)) return
	if(!giszm[id]) return
	if(gzombie[id] != 1) return
	if(g_ach_fast[id][ach_fast_3] >= ach_fast_progress[ach_fast_3]) return
	if(g_ach_fast[id][ach_fast_3] + 1 == ach_fast_progress[ach_fast_3] / 2){
		g_ach_fast[id][ach_fast_3] = ach_fast_progress[ach_fast_3]
		client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_ACH_COMPLETED", id, ach_fast_formatname[ach_fast_3])
	} else if(g_ach_fast[id][ach_fast_3] + 1 == ach_fast_progress[ach_fast_3]){
		g_ach_fast[id][ach_fast_3] ++
		client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_ACH_PROGRESS", id, ach_fast_formatname[ach_fast_3], g_ach_fast[id][ach_fast_3], ach_fast_progress[ach_fast_3])
	} else {
		g_ach_fast[id][ach_fast_3] ++
	}
}

public check_ach_fast_4(id){//[疾风跳砍] 在跳起后感染/杀死20个敌人
	if(!is_user_connected(id)) return
	if(!giszm[id]) return
	if(gzombie[id] != 1) return
	if(pev(id, pev_flags) & FL_ONGROUND) return
	if(!gjumping[id]) return
	if(g_ach_fast[id][ach_fast_4] >= ach_fast_progress[ach_fast_4]) return
	if(g_ach_fast[id][ach_fast_4] + 1 == ach_fast_progress[ach_fast_4] / 2){
		g_ach_fast[id][ach_fast_4] = ach_fast_progress[ach_fast_4]
		client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_ACH_COMPLETED", id, ach_fast_formatname[ach_fast_4])
	} else if(g_ach_fast[id][ach_fast_4] + 1 == ach_fast_progress[ach_fast_4]){
		g_ach_fast[id][ach_fast_4] ++
		client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_ACH_PROGRESS", id, ach_fast_formatname[ach_fast_4], g_ach_fast[id][ach_fast_4], ach_fast_progress[ach_fast_3])
	} else {
		g_ach_fast[id][ach_fast_4] ++
	}
}

public check_ach_fast_5(id){//[失足坠落] 从高空跌落摔死
	if(!is_user_connected(id)) return
	if(!giszm[id]) return
	if(gzombie[id] != 1) return
	if(g_ach_fast[id][ach_fast_5]) return
	g_ach_fast[id][ach_fast_5] = 1
	client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_ACH_COMPLETED", id, ach_fast_formatname[ach_fast_5])
}

public check_ach_fast_6(id){//[致命一击] 5次被暴击杀死
	if(!is_user_connected(id)) return
	if(!giszm[id]) return
	if(gzombie[id] != 1) return
	if(g_ach_fast[id][ach_fast_6] >= ach_fast_progress[ach_fast_6]) return
	if(g_ach_fast[id][ach_fast_6] + 1 == ach_fast_progress[ach_fast_6] / 2){
		g_ach_fast[id][ach_fast_6] = ach_fast_progress[ach_fast_6]
		client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_ACH_COMPLETED", id, ach_fast_formatname[ach_fast_6])
	} else if(g_ach_fast[id][ach_fast_6] + 1 == ach_fast_progress[ach_fast_6]){
		g_ach_fast[id][ach_fast_6] ++
		client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_ACH_PROGRESS", id, ach_fast_formatname[ach_fast_6], g_ach_fast[id][ach_fast_6], ach_fast_progress[ach_fast_6])
	} else {
		g_ach_fast[id][ach_fast_6] ++
	}
}
public check_ach_fast_7(id){//[终结者] 5次感染/杀死最后一个人类
	if(!is_user_connected(id)) return
	if(!giszm[id]) return
	if(gzombie[id] != 1) return
	if(get_humans_num() > 0) return
	if(g_ach_fast[id][ach_fast_7] >= ach_fast_progress[ach_fast_7]) return
	if(g_ach_fast[id][ach_fast_7] + 1 == ach_fast_progress[ach_fast_7] / 2){
		g_ach_fast[id][ach_fast_7] = ach_fast_progress[ach_fast_7]
		client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_ACH_COMPLETED", id, ach_fast_formatname[ach_fast_7])
	} else if(g_ach_fast[id][ach_fast_7] + 1 == ach_fast_progress[ach_fast_7]){
		g_ach_fast[id][ach_fast_7] ++
		client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_ACH_PROGRESS", id, ach_fast_formatname[ach_fast_7], g_ach_fast[id][ach_fast_7], ach_fast_progress[ach_fast_7])
	} else {
		g_ach_fast[id][ach_fast_7] ++
	}
}
public check_ach_fast_8(id){//[蝙蝠侠] 表演1000次长跳
	if(!is_user_connected(id)) return
	if(!giszm[id]) return
	if(gzombie[id] != 1) return
	if(g_ach_fast[id][ach_fast_8] >= ach_fast_progress[ach_fast_8]) return
	if(g_ach_fast[id][ach_fast_8] + 1 == ach_fast_progress[ach_fast_8] / 2){
		g_ach_fast[id][ach_fast_8] = ach_fast_progress[ach_fast_8]
		client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_ACH_COMPLETED", id, ach_fast_formatname[ach_fast_8])
	} else if(g_ach_fast[id][ach_fast_8] + 1 == ach_fast_progress[ach_fast_8]){
		g_ach_fast[id][ach_fast_8] ++
		client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_ACH_PROGRESS", id, ach_fast_formatname[ach_fast_8], g_ach_fast[id][ach_fast_8], ach_fast_progress[ach_fast_8])
	} else {
		g_ach_fast[id][ach_fast_8] ++
	}
}
public check_ach_fast_9(id){//[X斩] 使用星月斩定住100个敌人
	if(!is_user_connected(id)) return
	if(!giszm[id]) return
	if(gzombie[id] != 1) return
	if(g_ach_fast[id][ach_fast_9] >= ach_fast_progress[ach_fast_9]) return
	if(g_ach_fast[id][ach_fast_9] + 1 == ach_fast_progress[ach_fast_9] / 2){
		g_ach_fast[id][ach_fast_9] = ach_fast_progress[ach_fast_9]
		client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_ACH_COMPLETED", id, ach_fast_formatname[ach_fast_9])
	} else if(g_ach_fast[id][ach_fast_9] + 1 == ach_fast_progress[ach_fast_9]){
		g_ach_fast[id][ach_fast_9] ++
		client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_ACH_PROGRESS", id, ach_fast_formatname[ach_fast_9], g_ach_fast[id][ach_fast_9], ach_fast_progress[ach_fast_9])
	} else {
		g_ach_fast[id][ach_fast_9] ++
	}
}
public check_ach_fast_10(id){//[逃兵] 剩余生命值小于10%并活到回合结束
	if(!is_user_alive(id)) return
	if(!giszm[id]) return
	if(gzombie[id] != 1) return
	if(g_ach_fast[id][ach_fast_10]) return
	if(get_user_health(id) > ckrun_get_user_maxhealth(id) / 10) return
	g_ach_fast[id][ach_fast_10] = 1
	client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_ACH_COMPLETED", id, ach_fast_formatname[ach_fast_10])
}
public check_ach_fast_11(id){//[霉星高照] 一局内被杀死5次
	if(!is_user_connected(id)) return
	if(!giszm[id]) return
	if(gzombie[id] != 1) return
	if(g_ach_fast[id][ach_fast_11]) return
	if(g_roundkill[id] < 5) return
	g_ach_fast[id][ach_fast_11] = 1
	client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_ACH_COMPLETED", id, ach_fast_formatname[ach_fast_11])
}
public check_ach_fast_12(id){//[飞行明火] 感染/杀死一个火箭跳未落地的火箭兵
	if(!is_user_connected(id)) return
	if(!giszm[id]) return
	if(gzombie[id] != 1) return
	if(g_ach_fast[id][ach_fast_12]) return
	g_ach_fast[id][ach_fast_12] = 1
	client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_ACH_COMPLETED", id, ach_fast_formatname[ach_fast_12])
}
public check_ach_fast_13(id){//[神出鬼没] 在背后感染/杀死一个机枪兵
	if(!is_user_connected(id)) return
	if(!giszm[id]) return
	if(gzombie[id] != 1) return
	if(g_ach_fast[id][ach_fast_13]) return
	g_ach_fast[id][ach_fast_13] = 1
	client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_ACH_COMPLETED", id, ach_fast_formatname[ach_fast_13])
}
public check_ach_fast_14(id){//[成就里程碑1] 获得闪电僵尸的5个成就
	if(!is_user_connected(id)) return
	if(!giszm[id]) return
	if(gzombie[id] != 1) return
	if(g_ach_fast[id][ach_fast_14]) return
	if(ach_fast_stats(id) < 5) return
	g_ach_fast[id][ach_fast_14] = 1
	client_print_colored(id, "^x04%L^x01%L", LANG_PLAYER, "MSG_TITLE", id, "MSG_ACH_COMPLETED", id, ach_fast_formatname[ach_fast_14])
}
stock ach_fast_stats(id){
	new num = 0, i
	for(i = 0; i < MAX_ACH_FAST; i++){
		if(!ach_fast_progress[i]){
			if(g_ach_fast[id][i] == 1) num ++
		} else {
			if(g_ach_fast[id][i] >= ach_fast_progress[i]) num ++
		}
	}
	return num
}
//------------核心----------------//

public plugin_init(){
	g_hudcenter = CreateHudSyncObj()
	g_hudsync = CreateHudSyncObj()
	g_hudbuild = CreateHudSyncObj()
	g_hudtimer = CreateHudSyncObj()
	g_msgTeamInfo = get_user_msgid("TeamInfo")
	g_msgScreenShake = get_user_msgid("ScreenShake")
	g_msgScoreInfo = get_user_msgid("ScoreInfo")
	g_msgScoreAttrib = get_user_msgid("ScoreAttrib")
	g_msgRoundTime = get_user_msgid("RoundTime")
	g_msgHideWeapon = get_user_msgid("HideWeapon")
	g_msgCrosshair = get_user_msgid("Crosshair")
	g_msgScreenFade = get_user_msgid("ScreenFade")
	g_msgSayText = get_user_msgid("SayText")
	g_msgCurWeapon = get_user_msgid("CurWeapon")
	g_coloredMenus = colored_menus()
	register_clcmd("say !zmenu", "show_menu_main")
	register_clcmd("say_team !zmenu", "show_menu_main")
	register_clcmd("say !zzombie", "show_menu_zombie")
	register_clcmd("say_team !zzombie", "show_menu_zombie")
	register_clcmd("say !zhuman", "show_menu_human")
	register_clcmd("say_team !zhuman", "show_menu_human")
	register_clcmd("say !zweapon", "show_menu_weapon")
	register_clcmd("say_team !zweapon", "show_menu_weapon")
	register_clcmd("say !zprimary", "show_menu_primary")
	register_clcmd("say_team !zprimary", "show_menu_primary")
	register_clcmd("say !zsecondary", "show_menu_secondary")
	register_clcmd("say_team !zsecondary", "show_menu_secondary")
	register_clcmd("say !ztele", "clcmd_ztele")
	register_clcmd("say_team !ztele", "clcmd_ztele")
	register_clcmd("say !zspawn", "clcmd_zspawn")
	register_clcmd("say_team !zspawn", "clcmd_zspawn")
	register_clcmd("say !zhelp", "show_menu_help")
	register_clcmd("say_team !zhelp", "show_menu_help")
	register_clcmd("say !zstats", "zmstats")
	register_clcmd("say_team !zstats", "zmstats")
	register_clcmd("say !zmodel", "show_menu_model")
	register_clcmd("say_team !zmodel", "show_menu_model")
	register_clcmd("say !zteam", "show_menu_team")
	register_clcmd("say_team !zteam", "show_menu_team")
	register_clcmd("say !zach", "show_menu_achievement")
	register_clcmd("say_team !zach", "show_menu_achievement")
	register_clcmd("say !zadmin", "show_menu_admin")
	register_clcmd("say_team !zadmin", "show_menu_admin")
	register_clcmd("say !zsave", "clcmd_zsave")
	register_clcmd("say_team !zsave", "clcmd_zsave")
	register_clcmd("buy", "show_menu_weapon")
	register_clcmd("drop", "block_drop")
	register_clcmd("say !zsupply", "show_menu_itemmaker")

	register_clcmd("ckrun_setzombie", "cmdSetZombieMenu", ACCESS_ADMIN, "- displays set zombie menu")
	register_clcmd("ckrun_sethuman", "cmdSetHumanMenu", ACCESS_ADMIN, "- displays set human menu")

	register_menu("Main Menu", KEYSMENU, "menu_main")
	register_menu("Zombie Menu", KEYSMENU, "menu_zombie")
	register_menu("Human Menu", KEYSMENU, "menu_human")
	register_menu("Weapon Menu", KEYSMENU, "menu_weapon")
	register_menu("Primary Menu", KEYSMENU, "menu_primary")
	register_menu("Secondary Menu", KEYSMENU, "menu_secondary")
	register_menu("Knife Menu", KEYSMENU, "menu_knife")
	register_menu("Team Menu", KEYSMENU, "menu_team")
	register_menu("Model Menu", KEYSMENU, "menu_model")
	register_menu("Build Menu", KEYSMENU, "menu_build")
	register_menu("Demolish Menu", KEYSMENU, "menu_demolish")
	register_menu("Achievement Menu", KEYSMENU, "menu_achievement")
	register_menu("Admin Menu", KEYSMENU, "menu_admin")
	register_menu("ItemMaker Menu", KEYSMENU, "menu_itemmaker")

	register_menucmd(register_menuid("Set Zombie Menu"), 1023, "actionSetZombieMenu")
	register_menucmd(register_menuid("Set Human Menu"), 1023, "actionSetHumanMenu")

	register_message(get_user_msgid("Health"), "message_health")
	register_message(get_user_msgid("TextMsg"), "message_textmsg")
	register_message(get_user_msgid("StatusValue"), "message_Status")
	register_message(get_user_msgid("StatusText"), "message_Status")
	register_message(get_user_msgid("Money"), "message_money")
	register_message(get_user_msgid("HostagePos"), "message_hostagepos")
	register_message(get_user_msgid("ClCorpse"), "message_corpse")
	register_message(get_user_msgid("DeathMsg"), "message_deathmsg")
	register_message(g_msgHideWeapon, "message_hideweapon")
	register_message(g_msgTeamInfo, "message_teaminfo")
	register_message(g_msgSayText, "message_saytext")

	register_plugin("chicken_run","1.0.0","hzqst")

	register_event("DeathMsg","event_playerdie","a")
	register_event("Damage", "event_damage", "b", "2!0")//此事件只用作HUD生命显示
	register_event("CurWeapon", "event_weapon", "b")
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	register_event("SetFOV", "event_SetFOV", "be")//检测AWP
	RegisterHam(Ham_Touch,"info_target", "fw_entitytouch")
	RegisterHam(Ham_Touch,"weaponbox", "fw_TempItemTouch")
	RegisterHam(Ham_Touch,"armoury_entity", "fw_ItemTouch")
	RegisterHam(Ham_Use, "func_pushable", "block_use")
	RegisterHam(Ham_Use, "hostage_entity", "block_use")
	//RegisterHam(Ham_Use, "game_end", "end_round")
	RegisterHam(Ham_TakeDamage, "player", "fw_damage")//Ham才是王道!
	RegisterHam(Ham_TakeDamage, "func_breakable", "fw_damage_build")
	RegisterHam(Ham_BloodColor, "player", "fw_blood")//Ham才是王道!
	RegisterHam(Ham_Spawn, "player", "fw_spawn", 1)//Ham才是王道!
	//RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "fw_knifelight")
	//RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "fw_knifeheavy")
/*
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_p228", "fw_wpnfire")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_scout", "fw_wpnfire")
	
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_mac10", "fw_wpnfire")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_aug", "fw_wpnfire")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_elite", "fw_wpnfire")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_fiveseven", "fw_wpnfire")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ump45", "fw_wpnfire")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_sg550", "fw_wpnfire")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_galil", "fw_wpnfire")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_famas", "fw_wpnfire")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_usp", "fw_wpnfire")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_glock18", "fw_wpnfire")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_awp", "fw_wpnfire")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_mp5navy", "fw_wpnfire")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m4a1", "fw_wpnfire")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_tmp", "fw_wpnfire")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_g3sg1", "fw_wpnfire")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_deagle", "fw_wpnfire")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_sg552", "fw_wpnfire")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_ak47", "fw_wpnfire")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_p90", "fw_wpnfire")
*/
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m3", "fw_wpnfire_shotgun")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_xm1014", "fw_wpnfire_shotgun")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m249", "fw_wpnfire_m249")
	RegisterHam(Ham_Item_Deploy, "weapon_c4", "fw_wpndraw_custom", 1)
	RegisterHam(Ham_Item_Holster, "weapon_c4", "fw_wpnholster_custom", 1)

	RegisterHam(Ham_Item_Deploy, "weapon_m249", "fw_wpndraw_m249", 1)

	RegisterHam(Ham_Item_Holster, "weapon_awp", "fw_wpnholster_sniperifle", 1)

	RegisterHam(Ham_Item_Deploy, "weapon_knife", "fw_wpndraw_knife", 1)
	//RegisterHam(Ham_Item_Holster, "weapon_knife", "fw_wpnholster_knife", 1)

	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_c4", "fw_wpnfire_custom")
	RegisterHam(Ham_Player_Jump, "player", "fw_jump")
	RegisterHam(Ham_TraceAttack, "func_pushable", "fw_TraceAttack_Pushable")
	RegisterHam(Ham_Touch, "func_pushable", "fw_Touch_Pushable")

	register_forward(FM_GetGameDescription, "fw_GameDesc")
	register_forward(FM_TraceLine, "fw_TraceLine_Post", 1)
	register_forward(FM_SetClientKeyValue, "fw_SetClientKeyValue")
	register_forward(FM_ClientUserInfoChanged, "fw_ClientUserInfoChanged")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	register_forward(FM_AddToFullPack,"fw_AddToFullPack_Post",1)
	register_forward(FM_EmitSound, "fw_EmitSound")
	register_forward(FM_PlayerPreThink,"fw_PreThink")
	register_forward(FM_CmdStart,"fw_CmdStart")
	register_forward(FM_ClientKill, "fw_ClientKill")
	//register_forward(FM_SetModel, "fw_SetModel")
	unregister_forward(FM_Spawn, g_fwEntitySpawn)
	unregister_forward(FM_KeyValue, g_fwKeyValue)
	register_logevent("event_round_end", 2, "1=Round_End")
	register_dictionary("chicken_run.txt")
	register_dictionary("chicken_run_motd.txt")
	init_CollectSpawns("info_player_start")
	init_CollectSpawns("info_player_deathmatch")
	set_task(0.5,"first_zombie")
	set_task(10.0,"refresh_message")
	set_task(0.8, "FX_Environment")
	set_task(0.6, "faketeambot_create")
	set_task(1.0, "round_timer", TASK_ROUND_TIMER)
	set_task(TIMER_REFRESH, "ckrun_showhud_timer")
	g_gametime = 0
	//僵尸生命
	cvar_zm_fast_hp = register_cvar("ckrun_zm_fast_hp","6000")
	cvar_zm_gravity_hp = register_cvar("ckrun_zm_gravity_hp","20000")
	cvar_zm_classic_hp = register_cvar("ckrun_zm_classic_hp","15000")
	cvar_zm_jump_hp = register_cvar("ckrun_zm_jump_hp","8000")
	cvar_zm_invis_hp = register_cvar("ckrun_zm_invis_hp","5000")
	//僵尸速度
	cvar_zm_fast_speed = register_cvar("ckrun_zm_fast_speed","400")
	cvar_zm_gravity_speed = register_cvar("ckrun_zm_gravity_speed","200")
	cvar_zm_classic_speed = register_cvar("ckrun_zm_classic_speed","320")
	cvar_zm_jump_speed = register_cvar("ckrun_zm_jump_speed","280")
	cvar_zm_invis_speed = register_cvar("ckrun_zm_invis_speed","260")
	//僵尸抗弹
	cvar_zm_fast_kb = register_cvar("ckrun_zm_fast_kb","30")
	cvar_zm_gravity_kb = register_cvar("ckrun_zm_gravity_kb","95")
	cvar_zm_classic_kb = register_cvar("ckrun_zm_classic_kb","80")
	cvar_zm_jump_kb = register_cvar("ckrun_zm_jump_kb","50")
	cvar_zm_invis_kb = register_cvar("ckrun_zm_invis_kb","60")
	//僵尸跳跃
	cvar_zm_fast_jump = register_cvar("ckrun_zm_fast_jump","16")
	cvar_zm_gravity_jump = register_cvar("ckrun_zm_gravity_jump","16")
	cvar_zm_classic_jump = register_cvar("ckrun_zm_classic_jump","0")
	cvar_zm_jump_jump = register_cvar("ckrun_zm_jump_jump","128")
	cvar_zm_invis_jump = register_cvar("ckrun_zm_invis_jump","0")
	//人类生命
	cvar_hm_scout_hp = register_cvar("ckrun_hm_scout_hp","125")
	cvar_hm_heavy_hp = register_cvar("ckrun_hm_heavy_hp","300")
	cvar_hm_rpg_hp = register_cvar("ckrun_hm_rpg_hp","200")
	cvar_hm_snipe_hp = register_cvar("ckrun_hm_snipe_hp","125")
	cvar_hm_log_hp = register_cvar("ckrun_hm_log_hp","150")
	cvar_hm_eng_hp = register_cvar("ckrun_hm_eng_hp","125")
	//人类速度
	cvar_hm_scout_speed = register_cvar("ckrun_hm_scout_speed","300")
	cvar_hm_heavy_speed = register_cvar("ckrun_hm_mg_speed","180")
	cvar_hm_rpg_speed = register_cvar("ckrun_hm_rpg_speed","200")
	cvar_hm_snipe_speed = register_cvar("ckrun_hm_snipe_speed","240")
	cvar_hm_log_speed = register_cvar("ckrun_hm_log_speed","280")
	cvar_hm_eng_speed = register_cvar("ckrun_hm_eng_speed","220")

	cvar_wpn_ammo_default = register_cvar("ckrun_wpn_ammo_default","250")
	cvar_wpn_ammo_shotgun = register_cvar("ckrun_wpn_ammo_shotgun","100")
	cvar_wpn_ammo_m249 = register_cvar("ckrun_wpn_ammo_m249","500")
	cvar_wpn_ammo_deagle = register_cvar("ckrun_wpn_ammo_deagle","35")
	cvar_wpn_ammo_awp = register_cvar("ckrun_wpn_ammo_awp","25")
	cvar_wpn_clip_rpg = register_cvar("ckrun_wpn_clip_rpg","5")//主弹夹
	cvar_wpn_ammo_rpg = register_cvar("ckrun_wpn_ammo_rpg","25")//备用弹药

	//常规武器
	cvar_wpn_slowdown_he = register_cvar("ckrun_wpn_slowdown_he","80")//燃烧弹减20%速度
	cvar_wpn_multidamage_he = register_cvar("ckrun_wpn_multidamage_he","1000")//10倍伤害
	cvar_wpn_multidamage_m249 = register_cvar("ckrun_wpn_multidamage_m249","150")
	cvar_wpn_multidamage_awp = register_cvar("ckrun_wpn_multidamage_awp","300")
	cvar_wpn_multidamage_deagle = register_cvar("ckrun_wpn_multidamage_deagle","250")
	cvar_wpn_multidamage_default = register_cvar("ckrun_wpn_multidamage_default","165")
	cvar_wpn_multidamage_shotgun = register_cvar("ckrun_wpn_multidamage_shotgun","110")
	cvar_wpn_multidamage_knife = register_cvar("ckrun_wpn_multidamage_knife","1000")
	cvar_wpn_multidamage_hammer = register_cvar("ckrun_wpn_multidamage_hammer","1200")
	//特殊武器
	cvar_wpn_rpg_damage = register_cvar("ckrun_wpn_rpg_damage","80")
	cvar_wpn_rpg_radius = register_cvar("ckrun_wpn_rpg_radius","180")
	cvar_wpn_rpg_multidamage = register_cvar("ckrun_wpn_rpg_multidamage","1000")
	cvar_wpn_rpg_rof = register_cvar("ckrun_wpn_rpg_rof","650")
	cvar_wpn_rpg_reload = register_cvar("ckrun_wpn_rpg_reload","1000")
	cvar_wpn_rpg_force = register_cvar("ckrun_wpn_rpg_force","500")
	cvar_wpn_rpg_flare_cost = register_cvar("ckrun_wpn_rpg_flare_cost","5")
	cvar_wpn_rpg_flare_time = register_cvar("ckrun_wpn_rpg_flare_time","45")//60sec
	cvar_wpn_rpg_flare_size = register_cvar("ckrun_wpn_rpg_flare_size","24")
	cvar_wpn_rpg_repeat_time = register_cvar("ckrun_wpn_rpg_repeat_time","200")//0.2sec
	cvar_wpn_rpg_repeat_max = register_cvar("ckrun_wpn_rpg_repeat_max","3")

	cvar_wpn_minigun_backforce = register_cvar("ckrun_wpn_minigun_backforce","-20")
	cvar_wpn_minigun_spinup = register_cvar("ckrun_wpn_minigun_spinup","0.5")
	cvar_wpn_minigun_spindown = register_cvar("ckrun_wpn_minigun_spindown","0.5")
	cvar_wpn_minigun_spining = register_cvar("ckrun_wpn_minigun_spining","0.5")
	cvar_wpn_minigun_slowdown = register_cvar("ckrun_wpn_minigun_slowdown","50")//减速
	cvar_wpn_medic_heal = register_cvar("ckrun_wpn_medic_heal","2")
	cvar_wpn_medic_maxhealth = register_cvar("ckrun_wpn_medic_maxhealth","150")//正常生命上限的1.5倍
	cvar_wpn_medic_charge = register_cvar("ckrun_wpn_medic_charge","1")
	cvar_wpn_medic_power = register_cvar("ckrun_wpn_medic_power","1")

	cvar_wpn_ammopack_percent = register_cvar("ckrun_wpn_ammopack_percent","5")// = 20% = 1/5
	cvar_wpn_ammopack_charge = register_cvar("ckrun_wpn_ammopack_charge","1")
	cvar_wpn_ammopack_power = register_cvar("ckrun_wpn_ammopack_power","1")

	cvar_wpn_charge_rate = register_cvar("ckrun_wpn_charge_rate","20")//电荷消耗速度

	cvar_wpn_awp_charge = register_cvar("ckrun_wpn_awp_charge","4")//狙击最大蓄能伤害倍数

	cvar_wpn_craw_light = register_cvar("ckrun_wpn_craw_light","50")//僵尸轻刀50HP
	cvar_wpn_craw_heavy = register_cvar("ckrun_wpn_craw_heavy","100")
	cvar_wpn_moonstar_light = register_cvar("ckrun_wpn_moonstar_light","60")
	cvar_wpn_moonstar_heavy = register_cvar("ckrun_wpn_moonstar_heavy","120")
	//步哨枪
	cvar_build_sentry_hp_lv1 = register_cvar("ckrun_build_sentry_hp_lv1","250")//耐久
	cvar_build_sentry_hp_lv2 = register_cvar("ckrun_build_sentry_hp_lv2","325")
	cvar_build_sentry_hp_lv3 = register_cvar("ckrun_build_sentry_hp_lv3","400")
	cvar_build_sentry_ammo_lv1 = register_cvar("ckrun_build_sentry_ammo_lv1","150")//弹药
	cvar_build_sentry_ammo_lv2 = register_cvar("ckrun_build_sentry_ammo_lv2","200")
	cvar_build_sentry_ammo_lv3 = register_cvar("ckrun_build_sentry_ammo_lv3","300")
	cvar_build_sentry_cost_lv1 = register_cvar("ckrun_build_sentry_cost_lv1","80")//消耗金属
	cvar_build_sentry_cost_lv2 = register_cvar("ckrun_build_sentry_cost_lv2","120")
	cvar_build_sentry_cost_lv3 = register_cvar("ckrun_build_sentry_cost_lv3","160")
	cvar_build_sentry_bullet_lv1 = register_cvar("ckrun_build_sentry_bullet_lv1","25")//子弹伤害
	cvar_build_sentry_bullet_lv2 = register_cvar("ckrun_build_sentry_bullet_lv2","35")
	cvar_build_sentry_bullet_lv3 = register_cvar("ckrun_build_sentry_bullet_lv3","45")
	cvar_build_sentry_radius_lv1 = register_cvar("ckrun_build_sentry_radius_lv1","1200")//射程
	cvar_build_sentry_radius_lv2 = register_cvar("ckrun_build_sentry_radius_lv2","1600")
	cvar_build_sentry_radius_lv3 = register_cvar("ckrun_build_sentry_radius_lv3","2400")
	cvar_build_sentry_rocket_cost = register_cvar("ckrun_build_sentry_rocket_cost","10")//火箭消耗弹药
	cvar_build_sentry_rocket_reload = register_cvar("ckrun_build_sentry_rocket_reload","4000")//火箭发射间隔
	cvar_build_sentry_rocket_damage = register_cvar("ckrun_build_sentry_rocket_damage","80")//火箭基础伤害
	cvar_build_sentry_rocket_multi = register_cvar("ckrun_build_sentry_rocket_multidamage","500")//火箭对僵尸倍率
	cvar_build_sentry_rocket_radius = register_cvar("ckrun_build_sentry_rocket_radius","350")//火箭杀伤半径
	cvar_build_sentry_rescan = register_cvar("ckrun_build_sentry_rescan","5000")//5秒内二次遇敌不会发出扫描声

	//补给器
	cvar_build_dispenser_hp_lv1 = register_cvar("ckrun_build_dispenser_hp_lv1","150")//耐久
	cvar_build_dispenser_hp_lv2 = register_cvar("ckrun_build_dispenser_hp_lv2","200")
	cvar_build_dispenser_hp_lv3 = register_cvar("ckrun_build_dispenser_hp_lv3","250")
	cvar_build_dispenser_ammo_lv1 = register_cvar("ckrun_build_dispenser_ammo_lv1","100")//弹药
	cvar_build_dispenser_ammo_lv2 = register_cvar("ckrun_build_dispenser_ammo_lv2","150")
	cvar_build_dispenser_ammo_lv3 = register_cvar("ckrun_build_dispenser_ammo_lv3","200")
	cvar_build_dispenser_cost_lv1 = register_cvar("ckrun_build_dispenser_cost_lv1","60")//消耗金属
	cvar_build_dispenser_cost_lv2 = register_cvar("ckrun_build_dispenser_cost_lv2","120")
	cvar_build_dispenser_cost_lv3 = register_cvar("ckrun_build_dispenser_cost_lv3","160")
	cvar_build_dispenser_radius_lv1 = register_cvar("ckrun_build_dispenser_radius_lv1","50")//补给范围
	cvar_build_dispenser_radius_lv2 = register_cvar("ckrun_build_dispenser_radius_lv2","75")
	cvar_build_dispenser_radius_lv3 = register_cvar("ckrun_build_dispenser_radius_lv3","90")
	cvar_build_dispenser_heal_lv1 = register_cvar("ckrun_build_dispenser_heal_lv1","1")//医疗速度
	cvar_build_dispenser_heal_lv2 = register_cvar("ckrun_build_dispenser_heal_lv2","2")
	cvar_build_dispenser_heal_lv3 = register_cvar("ckrun_build_dispenser_heal_lv3","3")
	cvar_build_dispenser_rsp_lv1 = register_cvar("ckrun_build_dispenser_respawn_lv1","25")//弹药重生时间 5 = 1sec
	cvar_build_dispenser_rsp_lv2 = register_cvar("ckrun_build_dispenser_respawn_lv2","20")
	cvar_build_dispenser_rsp_lv3 = register_cvar("ckrun_build_dispenser_respawn_lv3","15")
	cvar_build_dispenser_supply = register_cvar("ckrun_build_dispenser_supply","10")//每次补给弹药（百分制）

	//传送装置
	cvar_build_telein_hp_lv1 = register_cvar("ckrun_build_telein_hp_lv1","150")
	cvar_build_telein_hp_lv2 = register_cvar("ckrun_build_telein_hp_lv2","200")
	cvar_build_telein_hp_lv3 = register_cvar("ckrun_build_telein_hp_lv2","250")//入口耐久
	cvar_build_teleout_hp_lv1 = register_cvar("ckrun_build_teleout_hp_lv1","125")
	cvar_build_teleout_hp_lv2 = register_cvar("ckrun_build_teleout_hp_lv2","150")
	cvar_build_teleout_hp_lv3 = register_cvar("ckrun_build_teleout_hp_lv2","175")//出口耐久
	cvar_build_telein_cost_lv1 = register_cvar("ckrun_build_telein_cost_lv1","60")
	cvar_build_teleout_cost_lv1 = register_cvar("ckrun_build_teleout_cost_lv1","60")
	cvar_build_tele_cost_lv2 = register_cvar("ckrun_build_tele_cost_lv2","100")
	cvar_build_tele_cost_lv3 = register_cvar("ckrun_build_tele_cost_lv3","140")//建造/升级需要金属
	cvar_build_tele_reload_lv1 = register_cvar("ckrun_build_tele_reload_lv1","1")//
	cvar_build_tele_reload_lv2 = register_cvar("ckrun_build_tele_reload_lv2","2")//
	cvar_build_tele_reload_lv3 = register_cvar("ckrun_build_tele_reload_lv3","3")//传送装置重新准备速度
	cvar_build_tele_trans_lv1 = register_cvar("ckrun_build_tele_trans_lv1","10")//(255制)
	cvar_build_tele_trans_lv2 = register_cvar("ckrun_build_tele_trans_lv2","1")//0.3%, 0.004%, 0%
	cvar_build_tele_trans_lv3 = register_cvar("ckrun_build_tele_trans_lv3","0")//传送装置入口最小可见度 可见度计算公式 y=-2.25x+255 (y=renderamt,x=重装进度)

	cvar_build_repair = register_cvar("ckrun_build_repair","10") // 10%
	//僵尸技能
	cvar_skill_airblast_power = register_cvar("ckrun_skill_airblast_power","20")//空气弹耗电
	cvar_skill_dodge_power = register_cvar("ckrun_skill_dodge_power","10")//闪避耗电
	cvar_skill_dodge_percent = register_cvar("ckrun_skill_dodge_percent","60")//闪避几率
	cvar_skill_dodge_slowdown = register_cvar("ckrun_skill_dodge_slowdown","80")//闪避模式减20%速度
	cvar_skill_invisible_power = register_cvar("ckrun_skill_invisible_power","3")//隐形耗电
	cvar_skill_invisible_multifc = register_cvar("ckrun_skill_invisible_multifc","150")
	cvar_skill_invisible_multidmg = register_cvar("ckrun_skill_invisible_multidmg","500")
	cvar_skill_invisible_multisp = register_cvar("ckrun_skill_invisible_multisp","140")
	cvar_skill_disguise_multidamage = register_cvar("ckrun_skill_disguise_multidamage","500")//伪装时接受5倍伤害
	cvar_skill_disguise_multiforce = register_cvar("ckrun_skill_disguise_multiforce","10")//伪装时被击飞推力倍率 10%推力
	cvar_skill_longjump_force = register_cvar("ckrun_skill_longjump_force","750")
	cvar_skill_longjump_power = register_cvar("ckrun_skill_longjump_power","10")
	cvar_skill_moonstar_power = register_cvar("ckrun_skill_moonstar_power","100")
	//全局参数
	cvar_global_light = register_cvar("ckrun_global_light","6")
	cvar_global_lightning = register_cvar("ckrun_global_lightning","2")
	cvar_global_crit_multi = register_cvar("ckrun_global_crit_multi","500")//暴击5倍伤害
	cvar_global_crit_percent = register_cvar("ckrun_global_crit_percent","15")//暴击率15%
	cvar_global_tele = register_cvar("ckrun_global_tele","3")//最大传送次数
	cvar_global_tele_cd = register_cvar("ckrun_global_tele_cd","15")//传送冷却时间
	cvar_global_gib_amount = register_cvar("ckrun_global_gib_amount","2")
	cvar_global_gib_time = register_cvar("ckrun_global_gib_time","100")
	cvar_global_supply_respawn = register_cvar("ckrun_global_supply_respawn","15")//物品重生时间
	cvar_global_blood = register_cvar("ckrun_global_blood","5")
	cvar_global_crit_tracecolor = register_cvar("ckrun_global_crit_tracecolor","1")
	cvar_global_crit_tracelen = register_cvar("ckrun_global_crit_tracelen","25")
	cvar_global_crit_tracetime = register_cvar("ckrun_global_crit_tracetime","12")
	cvar_global_respawn = register_cvar("ckrun_global_respawn","25")
	cvar_cp_respawn = register_cvar("ckrun_cp_respawn","15")
	cvar_pl_respawn = register_cvar("ckrun_lp_respawn","10")
	cvar_cp_craw_light = register_cvar("ckrun_cp_craw_light","50")
	cvar_cp_craw_heavy = register_cvar("ckrun_cp_craw_heavy","100")
	cvar_ctf_craw_light = register_cvar("ckrun_ctf_craw_light","50")
	cvar_ctf_craw_heavy = register_cvar("ckrun_ctf_craw_heavy","100")
	cvar_pl_craw_light = register_cvar("ckrun_pl_craw_light","50")
	cvar_pl_craw_heavy = register_cvar("ckrun_pl_craw_heavy","100")
	//回合时间
	cvar_roundtime_default = register_cvar("ckrun_roundtime_default","360")//6分钟
	cvar_roundtime_capture = register_cvar("ckrun_roundtime_capture","1200")//20分钟
	cvar_roundtime_ctflag = register_cvar("ckrun_roundtime_ctflag","1200")//20分钟
	cvar_roundtime_payload = register_cvar("ckrun_roundtime_payload","1800")//30分钟

	cvar_supply_item_healthkit = register_cvar("ckrun_supply_item_healthkit","25")//补血包
	cvar_supply_item_ammobox = register_cvar("ckrun_supply_item_ammobox","25")
	cvar_supply_item_weapon = register_cvar("ckrun_supply_item_weapon","50")

	formatex(g_modname, sizeof g_modname - 1, "%L", LANG_PLAYER, "CKRUN_MODNAME")
	g_maxplayers = get_maxplayers()
	new mapname[32], cfgdir[32], linedata[64]
	get_configsdir(cfgdir, sizeof cfgdir - 1);
	get_mapname(mapname, sizeof mapname - 1); 
	formatex(g_ItemFile, sizeof g_ItemFile - 1, "%s/chickenrun/%s_item.cfg", cfgdir, mapname);
	if (file_exists(g_ItemFile)){
		new data[4][6], Float:time = 0.2, file = fopen(g_ItemFile,"rt")
		new parm[4]
		while (file && !feof(file)){
			fgets(file, linedata, sizeof linedata - 1);
			if(!linedata[0] || str_count(linedata,' ') < 2) continue;
			parse(linedata,data[0],5,data[1],5,data[2],5,data[3],5);
			parm[0] = str_to_num(data[0])
			parm[1] = str_to_num(data[1])
			parm[2] = str_to_num(data[2])
			parm[3] = str_to_num(data[3])
			set_task(time,"ckrun_create_item", 0, parm, 4)
			time += 0.2
		}
		if (file) fclose(file);
	}
	//游戏模式
	if(equal(mapname[0], "cp_", 3)) {
		g_gamemode = mode_capture
	} else if(equal(mapname[0], "ctf_", 4)) {
		g_gamemode = mode_ctflag
	} else if(equal(mapname[0], "pl_", 3)) {
		g_gamemode = mode_payload
	} else {
		g_gamemode = mode_normal
	}
	format(g_mapname, sizeof g_mapname - 1, "%s", mapname)
	server_cmd("exec %s/chicken_run.cfg", cfgdir)
	set_cvar_string("sv_skyname","space")
	set_cvar_num("sv_skycolor_r", 0)
	set_cvar_num("sv_skycolor_g", 0)
	set_cvar_num("sv_skycolor_b", 0)
}
