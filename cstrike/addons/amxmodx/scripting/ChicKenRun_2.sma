/* 本插件由 AMXX-Studio 中文版自动生成*/
/* UTF-8 func by www.DT-Club.net */

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <hamsandwich>
#include <fakemeta>
#include <cstrike_dump>
#include <ChicKenRun2_const>
#include <xs>
#include <orpheu>
#include <orpheu_stocks>
#include <orpheu_memory>

#define PLUGIN_NAME	"小鸡快跑2"
#define PLUGIN_VERSION	"1.0"
#define PLUGIN_AUTHOR	"asd5315325"

#define CHAN_PLAYERHUD	1
#define CHAN_SENTRYHUD	2
#define CHAN_KILLMSGHUD	3
#define CHAN_ROUNDHUD	4


#define MAX_STICKYBOMB	108


//-----------------------------------------------------------------------------//



//-----------------------------------------------------------------------------//
////全局信息区
new g_roundtime				//回合时间数->int
new g_roundstatus			//回合状态
enum{
	round_start=0,			
	round_ready,
	round_running,
	round_end
}
new g_gamemode				//游戏模式
enum{
	gamemode_arena=0,		//对战模式->Red Vs Blue
	gamemode_cp,			//据点模式->Red Vs Blue
	gamemode_zombie,		//僵尸模式->Red&Blue Vs Zombie
	gamemode_human_subsist,		//生存模式->Red&Blue Vs Npc
	gamemode_vsasb,			//挑战asb模式->Red&Blue Vs Asb
	gamemode_scp,			//SCP模式->Red&Blue Vs F*ckMonster
	gamemode_vscs,			//TF2VSCS->TF2 Vs Cs
}
new lastwinteam
enum{
	win_red=0,
	win_blue,
	win_none
}
enum{
	win_human=0,
	win_zombie,
	win_none
}
enum{
	win_human=0,
	win_boss,
	win_none
}
new g_maxplayer


new extra_item_num
new Array:item_id			//物品的序列号->int
new Array:item_chinese_name		//物品中文名称->string
new Array:item_english_name		//物品英文名称->string
new Array:item_type			//物品类型
enum{
	item_none=0,
	item_item,
	item_weapon,
	item_hat,
	item_suit
}
new Array:item_usertype			//使用者兵种类型(Human)
new Array:item_weaponslot
enum{
	itemwpn_none=0,
	itemwpn_primary,
	itemwpn_secondry,
	itemwpn_knife,
	itemwpn_,
}
new Array:item_wpnmaxclip
new Array:item_wpnmaxammo



//
new g_fwRoundStart
new g_fwRoundEnd
new g_fwPlayerHurt_Pre
new g_fwPlayerHurt_Post
new g_fwPlayerKilled
new g_fwPlayerBeHealedPer_Pre
new g_fwPlayerBeHealedPer_Post
new g_fwPlayerBeHealedNum_Pre
new g_fwPlayerBeHealedNum_Post
new g_fwPlayerAddAmmoPer_Pre
new g_fwPlayerAddAmmoPer_Post
new g_fwPlayerAddMetalPer_Pre
new g_fwPlayerAddMetalPer_Post
new g_fwPlayerAddMetalNum_Pre
new g_fwPlayerAddMetalNum_Post
new g_fwPlayerBeFired_Pre
new g_fwPlayerBeFired_Post

new g_fwPlayerKnockBack_Pre
new g_fwPlayerKnockBack_Post
new g_fwPlayerSlowVec_Pre
new g_fwPlayerSlowVec_Post
new g_fwPlayerExplode_Pre
new g_fwPlayerExplode_Post

new g_fwPlayerDisFired_Pre
new g_fwPlayerDisFired_Post
new g_fwResetVar_Pre
new g_fwResetVar_Post
new g_fwGivePriWpn
new g_fwGiveSecWpn
new g_fwGiveKnifeWpn
new g_fwPlayerSpawn
new g_fwBuild_Pre
new g_fwBuild_Post
new g_fwBuildingDestroy_Pre
new g_fwBuildingDestroy_Post
new g_fwPutSapperInBuilding_pre
new g_fwPutSapperInBuilding_post
new g_fwWeaponCur_Pre
new g_fwWeaponCur_Post
new g_fwWeaponHolster_Pre
new g_fwWeaponHolster_Post
new g_fwKnifeAttacking

new g_fwResult

new forward_change_num[11]
new Float:forward_change_float[11]
new Float:forward_change_vectype[11][3]
new forward_change_string[11][64]




new g_hudmsg_text1[64],g_hudmsg_text2[64],g_hudmsg_text3[64],g_hudmsg_text4[64],g_hudmsg_text5[64]
new g_hudsync

//shotgun anim
enum{
	anim_shotgunidle=0,
	anim_shotgunstartreload,
	anim_shotgunreloading,
	anim_shotgunendreload,
	anim_shotgundraw,
	anim_shotgunfire
}
//pistol anim
enum{
	anim_pistolidle=0,
	anim_pistolreload,
	anim_pistoldraw,
	anim_pistolfire
}

//minigun anim
enum{
	anim_miniidle=0,
	anim_minifire,
	anim_minidraw,
	anim_minidown,
	anim_miniup,
	anim_minispoolidle
}

//rpg anim
enum{
	anim_rpgidle=0,
	anim_rpgstartreload,
	anim_rpgreloading,
	anim_rpgendreload,
	anim_rpgdraw,
	anim_rpgfire
}

//flamethrower anim
enum{
	anim_flameidle=0,
	anim_flameshoot,
	anim_flameairblast,
	anim_flamedraw,
	anim_flameshoot2
}


//medic gun anim
enum{
	anim_medicidle=0,
	anim_medicdraw,
	anim_mediccharge
}


//grenadelauncher anim
enum{
	anum_grenadeidle=0,
	anim_grenadestartreload,
	anim_grenadereloading,
	anim_grenadeendreload,
	anim_grenadedraw,
	anim_grenadeshoot
}
//stickylauncher anim
enum{
	anim_stickyidle=0,
	anim_stickystartreload,
	anim_stickyreloading,
	anim_stickyendreload,
	anim_stickydraw,
	anim_stickyshoot
}


//sniperifle anim
enum{
	anim_snipeidle=0,
	anim_snipeiddle,
	anim_snipedraw,
	anim_snipeshoot
}

//smg anim
enum{
	anim_smgidle=0,
	anim_smgreload,
	anim_smgdraw,
	anim_smgshoot
}

//syringe gun
enum{
	anim_syringeidle=0,
	anim_syringereload,
	anim_syringedraw,
	anim_syringeshoot
}


//knife anim
enum{
	anim_knifeidle=0,
	anim_knifedraw=3,
	anim_knifeattack_a=6,
	anim_knifeattack_b=7
}


//revolver anim
enum{
	anim_revolveridle=0,
	anim_revolverreload,
	anim_revolverdraw,
	anim_revolverfire,
	anim_revolverwatchdraw,
	anim_revolverwatchholster
}

//butterfly anim
enum{
	butterfly_animidle = 0,
	butterfly_animbackuping = 1,
	butterfly_animbackupidle = 2,
	butterfly_animdraw = 3,
	butterfly_animbackdowning = 8,
	butterfly_animbackstab = 9,
	butterfly_animwatchdraw = 10,
	butterfly_animwatchholster = 11
}

//sapper anim
enum{
	anim_idle=0,
	anim_sapperdraw,
	anim_sapperput
}
//sapper anim
enum{
	anim_idle=0,
	anim_zbsapperdraw,
	anim_zbsapperwatchdraw,
	anim_zbsapperwatchholster,
}


//buildpda
enum{
	anim_buildpdaidle=0,
	anim_buildpdadraw
}

//destroypda
enum{
	anim_destroypdaidle=0,
	anim_destroypdadraw
}


enum{
	anim_sentryidle=0,
	anim_sentryfire,
	anim_sentrybuild
}
enum{
	anim_dispenserlv1=0,
	anim_dispenserbuild,
	anim_dispenserlv2,
	anim_dispenserlv2up,
	anim_dispenserlv3,
	anim_dispenserlv3up
}
	

enum{
	CS_TEAM_UNASSIGNED = 0,
	CS_TEAM_T,
	CS_TEAM_CT,
	CS_TEAM_SPECTATOR
}


//-----------------------------------------------------------------------------//
////常量数组区
new const ALLKEYS = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9)
new const CSWEAPONCLASSNAME[][] = { "weapon_p228", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10",
			"weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550",
			"weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249",
			"weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552",
			"weapon_ak47", "weapon_knife", "weapon_p90" }//原CS武器类型名称

new const MSG_CKR2[] = {"------小鸡快跑2------"}	
new const MSG_humantype_name[][] = {"None","侦察","机枪","士兵","喷火","狙击","医生","工程","爆破","间谍","黑岩射手"}
new const human_maxhealth[] = {1,125,300,200,175,125,150,125,175,125,1000}
new const human_overhealed[] = {2,185,450,300,265,185,225,185,265,185,1500}
new const human_maxspeed[] = {1,330,180,200,260,250,270,240,230,260,275}
new const human_normal_priwpnname[][] = {"f*ck","双管猎枪","转轮机枪","火箭发射器","火焰喷射器","狙击枪","医疗枪","霰弹枪","榴弹发射器","左轮手枪","爆炸霰弹"}
new const human_normal_secwpnname[][] = {"all","手枪","霰弹枪","霰弹枪","霰弹枪","微型冲锋枪","针筒发射器","手枪","粘弹发射器","电子工兵","双持爆炸沙鹰"}
new const human_normal_knifewpnname[][] = {"people","棒球棍","拳头","铁铲","消防斧","猎刀","骨锯","扳手","酒瓶","蝴蝶刀","袖刃"}
new const human_normal_priwpnengname[][] = {"gentleman","Scatter Gun","M134","Rocket Launcher","Flame Thrower","Snipe's Gun","Medic Gun","Shot Gun","Grenade Launcher","Revolver","2333"}
new const human_normal_secwpnengname[][] = {"lady","Pistol","Shot Gun","Shot Gun","Shot Gun","Smg","Syringe Launcher","Pistol","Stickybomb Launcher","Sapper","2333"}
new const human_normal_knifewpnengname[][] = {"f@ckyou","Bat","Fist","Shovel","Fireaxe","Machete","Bone Saw","Wrench","Bottle","Butter Fly","2333"}
new const human_normal_priwpnmaxclip[] = {1,6,-1,4,-1,-1,-1,6,4,6,8}
new const human_normal_priwpnmaxbpammo[] = {1,32,200,20,200,25,-1,32,16,24,32}
new const human_normal_secwpnmaxclip[] = {1,12,6,6,6,25,40,12,8,-1,14}
new const human_normal_secwpnmaxbpammo[] = {1,36,32,32,32,75,120,200,24,-1,56}

new const MSG_zombietype_name[][] = {"None","巫毒侦察僵尸","巫毒重装僵尸","巫毒火箭僵尸","巫毒火焰僵尸","巫毒狙击僵尸","巫毒医护僵尸","巫毒工程僵尸","巫毒爆破僵尸","巫毒间谍僵尸"}
new const zombie_maxhealth[] = {1,125,300,200,175,125,150,125,175,125}
new const zombie_overhealed[] = {2,185,450,300,265,185,225,185,265,185}
new const zombie_maxspeed[] = {1,330,180,200,260,250,270,240,230,260}
new const Float:zombie_bullet_kb_mul[] = {1.0,1.8,0.65,0.75,0.8,1.3,0.9,1.0,0.75,1.5}
new const Float:zombie_explode_kb_mul[] = {1.0,1.5,0.7,0.85,0.9,1.2,1.0,1.0,0.85,1.3}
new const zombie_normal_knifewpnname[][] = {"节操","爪子","爪子","爪子","爪子","爪子","骨锯","爪子","爪子","爪子"}
new const zombie_normal_knifewpnengname[][] = {"f@ckyou","Paw","Paw","Paw","Paw","Paw","Bone Saw","Paw","Paw","Paw"}
new const MSG_zombielevel_name[][] = {"None","虚弱","普通","强力","噩梦"}

new const MSG_bosstype_name[][] = {"Nope.avi","残暴基督徒狙击手","SCP-173","苦力怕妹子","地狱监护者"}
new const boss_maxspeed[] = {1,270,75,260,270}

new const MSG_team_name[][] = {"中立","红队","蓝队","观察者"}
new const MSG_CKRWPNNAME[][] = {"双管猎枪","霰弹枪","转轮机枪","微型冲锋枪","狙击枪","火箭发射器","火焰喷射器","医疗枪","榴弹发射器","左轮手枪","手枪","针筒发射器","粘弹发射器","电子工兵","棒球棍","拳头","铁铲","消防斧","猎刀","骨锯","扳手","酒瓶","蝴蝶刀","反射火箭弹","反射榴弹","步哨枪","步哨火箭","爪子","建筑爆炸","灌木丛","部落刮胡刀","CS枪械","自然伤害"}
new const MSG_CKRWPNNAME_2[][] = {"爆裂霰弹","双持爆裂沙鹰"}
new const MSG_GAMEMODE[][] = {"竞技","控制点","僵尸","生存","决战","SCP"}
new const MSG_ROUNDSTATUS[][] = {"开始","准备","进行中","结束"}

new const mdl_human[][] = {"vip","tf2_scout_4","tf2_heavy_4","tf2_soldier_3","tf2_pyro_4","tf2_sniper_7","tf2_medic_1","tf2_engineer_1","tf2_demoman_1","tf2_spy_2","ckr2_adm_1"}
new const snd_callmedic[][] = {"chickenrun_2/callmedic/scout_medic.wav","chickenrun_2/callmedic/scout_medic.wav","chickenrun_2/callmedic/heavy_medic.wav","chickenrun_2/callmedic/soldier_medic.wav","chickenrun_2/callmedic/soldier_medic.wav","chickenrun_2/callmedic/sniper_medic.wav","chickenrun_2/callmedic/medic_medic.wav","chickenrun_2/callmedic/engineer_medic.wav","chickenrun_2/callmedic/demoman_medic.wav","chickenrun_2/callmedic/spy_medic.wav","chickenrun_2/callmedic/spy_medic.wav"}

new const g_round_remove[][] = {"obj_rocket","obj_sentryrocket","obj_grenade","obj_stickybomb","obj_flame","obj_crossbow","obj_huntsman","obj_rocket_blackbox","obj_grenade_tuojiang","supply_health","supply_ammo","supply_healthandammo"}

new CS_Teams[][] = { "UNASSIGNED", "TERRORIST", "CT", "SPECTATOR" }
new g_msgTeamInfo
new g_msgScoreInfo
new g_msgRoundTime
new g_msgStatusText
new g_msgStatusValue


//new const mdl_wpn_w_p[] = {"models/chickenrun_2/wp_all_1014.mdl"}

new const mdl_wpn_v_scattergun[] = {"models/chickenrun_2/v_scattergun.mdl"}
new const mdl_wpn_wp_scattergun[] = {"models/chickenrun_2/wp_scattergun.mdl"}
new const snd_wpn_scattergun_reload[] = {"chicken_fortress_2/scattergun_reload.wav"}
new const snd_wpn_scattergun_shoot[] = {"chickenrun_2/scattergun_shoot.wav"}

new const mdl_wpn_v_pistol[] = {"models/chickenrun_2/v_pistol.mdl"}
new const mdl_wpn_v_pistol_engineer[] = {"models/chickenrun_2/v_pistol_engineer.mdl"}
new const mdl_wpn_wp_pistol[] = {"models/chickenrun_2/wp_pistol.mdl"}
new const snd_wpn_pistol_reload[] = {"chicken_fortress_2/pistol_reload.wav"}
new const snd_wpn_pistol_shoot[] = {"chickenrun_2/pistol_shoot.wav"}


new const mdl_wpn_v_minigun[] = {"models/chickenrun_2/v_minigun.mdl"}
new const mdl_wpn_wp_minigun[] = {"models/chickenrun_2/wp_minigun.mdl"}
new const snd_wpn_minigun_shoot[] = {"chickenrun_2/minigun_shoot.wav"}
new const snd_wpn_minigun_shoot_crit[] = {"chickenrun_2/minigun_shoot_crit.wav"}
new const snd_wpn_minigun_spin[] = {"chickenrun_2/minigun_spin.wav"}
new const snd_wpn_minigun_winddown[] = {"chickenrun_2/minigun_wind_down.wav"}
new const snd_wpn_minigun_windup[] = {"chickenrun_2/minigun_wind_up.wav"}


new const mdl_wpn_v_rpg[] = {"models/chickenrun_2/v_rocketlauncher.mdl"}
new const mdl_wpn_wp_rpg[] = {"models/chickenrun_2/wp_rocketlauncher.mdl"}
new const mdl_wpn_pj_rocket[] = {"models/chickenrun_2/pj_rocket.mdl"}
new const snd_wpn_rpg_shoot[] = {"chickenrun_2/rocketlauncher_shoot.wav"}
new const snd_wpn_rpg_reload[] = {"chicken_fortress_2/rocketlauncher_reload.wav"}
new rockettrail,exp_new1,exp_new2,exp_new3


new const mdl_wpn_v_flamethrower[] = {"models/chickenrun_2/v_flamethrower.mdl"}
new const mdl_wpn_wp_flamethrower[] = {"models/chickenrun_2/wp_flamethrower.mdl"}
new const mdl_wpn_pj_flame[] = {"sprites/chickenrun_2/pyro_flame.spr"}
new const snd_wpn_flamethrower_start[] = {"chickenrun_2/flamethrower_start.wav"}
new const snd_wpn_flamethrower_airblast[] = {"chickenrun_2/flamethrower_airblast.wav"}
new const snd_wpn_flamethrower_redirect[] = {"chickenrun_2/flamethrower_redirect.wav"}
new const snd_wpn_flamethrower_loop[] = {"chickenrun_2/flamethrower_loop.wav"}
new const snd_wpn_flamethrower_loop_crit[] = {"chickenrun_2/flamethrower_loop_crit.wav"}


new const mdl_wpn_v_medicgun[] = {"models/chickenrun_2/v_medigun.mdl"}
new const mdl_wpn_wp_medicgun[] = {"models/chickenrun_2/wp_medigun.mdl"}
new const snd_wpn_medicgun_fullcharge[] = {"chickenrun_2/medigun_charged.wav"}
new const snd_wpn_medicgun_heal[] = {"chickenrun_2/medigun_heal.wav"}
new const snd_wpn_medicgun_chargeon[] = {"chickenrun_2/medigun_invulon.wav"}
new const snd_wpn_medicgun_chargeoff[] = {"chickenrun_2/medigun_invuloff.wav"}
new const snd_wpn_medicgun_notarget[] = {"chickenrun_2/medigun_no_target.wav"}
new medicbeam


new const mdl_wpn_v_syringegun[] = {"models/chickenrun_2/v_syringegun.mdl"}
new const mdl_wpn_wp_syringegun[] = {"models/chickenrun_2/wp_syringegun.mdl"}
new const mdl_wpn_pj_syringe[] = {"models/chickenrun_2/pj_syringe.mdl"}
new const snd_wpn_syringegun_shoot[] = {"chickenrun_2/syringegun_shoot.wav"}
new const snd_wpn_syringegun_reload[] = {"chicken_fortress_2/syringegun_reload.wav"}


new const mdl_wpn_v_bonesaw[] = {"models/chickenrun_2/v_bonesaw.mdl"}
new const mdl_wpn_wp_bonesaw[] = {"models/chickenrun_2/wp_bonesaw.mdl"}
new const snd_wpn_bonesaw_hit[] = {"chickenrun_2/bonesaw_hit.wav"}


new const mdl_wpn_v_shotgunheavy[] = {"models/chickenrun_2/v_shotgunheavy.mdl"}
new const mdl_wpn_v_shotgunsoldier[] = {"models/chickenrun_2/v_shotgunsoldier.mdl"}
new const mdl_wpn_v_shotgunpyro[] = {"models/chickenrun_2/v_shotgunpyro.mdl"}
new const mdl_wpn_v_shotgunengineer[] = {"models/chickenrun_2/v_shotgunengineer.mdl"}
new const mdl_wpn_wp_shotgunall[] = {"models/chickenrun_2/wp_shotgunall.mdl"}
new const snd_wpn_shotgun_shoot[] = {"chickenrun_2/shotgun_shoot.wav"}
new const snd_wpn_shotgun_reload[] = {"chicken_fortress_2/shotgun_reload.wav"}


new const mdl_wpn_v_grenadelauncher[] = {"models/chickenrun_2/v_grenadelauncher.mdl"}
new const mdl_wpn_wp_grenadelauncher[] = {"models/chickenrun_2/wp_grenadelauncher.mdl"}
new const mdl_wpn_pj_grenade[] = {"models/chickenrun_2/pj_grenade.mdl"}
new const snd_wpn_grenadelauncher_shoot[] = {"chickenrun_2/grenadelauncher_shoot.wav"}
new const snd_wpn_grenadelauncher_reload[] = {"chicken_fortress_2/grenadelauncher_reload.wav"}


new const mdl_wpn_v_stickylauncher[] = {"models/chickenrun_2/v_stickylauncher.mdl"}
new const mdl_wpn_wp_stickylauncher[] = {"models/chickenrun_2/wp_stickylauncher.mdl"}
new const mdl_wpn_pj_stickybomb[] = {"models/chickenrun_2/pj_stickybomb.mdl"}
new const snd_wpn_stickylauncher_shoot[] = {"chickenrun_2/stickylauncher_shoot.wav"}
new const snd_wpn_stickylauncher_reload[] = {"chicken_fortress_2/stickylauncher_reload.wav"}
new const snd_wpn_stickylauncher_det[] = {"chickenrun_2/stickylauncher_det.wav"}
new const snd_wpn_stickylauncher_charge[] = {"chickenrun_2/stickylauncher_charge.wav"}


new const mdl_wpn_v_sniperifle[] = {"models/chickenrun_2/v_sniperifle.mdl"}
new const mdl_wpn_wp_sniperifle[] = {"models/chickenrun_2/wp_sniperifle.mdl"}
new const snd_wpn_sniperifle_shoot[] = {"chickenrun_2/sniperifle_shoot.wav"}
new const snd_wpn_sniperifle_reload[] = {"chickenrun_2/sniperifle_reload.wav"}
new const snd_wpn_sniperifle_charge[] = {"chickenrun_2/sniperifle_charge.wav"}


new const mdl_wpn_v_smg[] = {"models/chickenrun_2/v_smg.mdl"}
new const mdl_wpn_wp_smg[] = {"models/chickenrun_2/wp_smg.mdl"}
new const snd_wpn_smg_shoot[] = {"chickenrun_2/smg_shoot.wav"}
new const snd_wpn_smg_reload[] = {"chicken_fortress_2/smg_reload.wav"}


new const mdl_wpn_v_revolver[] = {"models/chickenrun_2/v_revolver.mdl"}
new const mdl_wpn_v_revolver_watch[] = {"models/chickenrun_2/v_revolver_watch.mdl"}
new const mdl_wpn_wp_revolver[] = {"models/chickenrun_2/wp_revolver.mdl"}
new const snd_wpn_revolver_shoot[] = {"chickenrun_2/revolver_shoot.wav"}
new const snd_wpn_revolver_reload[] = {"chicken_fortress_2/revolver_reload.wav"}



new const mdl_wpn_v_bat[] = {"models/chickenrun_2/v_bat.mdl"}
new const mdl_wpn_wp_bat[] = {"models/chickenrun_2/wp_bat.mdl"}
new const snd_wpn_bat_hit[] = {"chickenrun_2/bat_hit.wav"}
new const snd_wpn_bat_draw[] = {"chickenrun_2/bat_draw.wav"}


new const mdl_wpn_v_fist[] = {"models/chickenrun_2/v_fist.mdl"}
new const mdl_wpn_wp_fist[] = {"models/chickenrun_2/wp_fist.mdl"}
new const snd_wpn_fist_hitbody[] = {"chickenrun_2/fist_hitbody.wav"}


new const mdl_wpn_v_shovel[] = {"models/chickenrun_2/v_shovel.mdl"}
new const mdl_wpn_wp_shovel[] = {"models/chickenrun_2/wp_shovel.mdl"}
new const snd_wpn_shovel_hit[] = {"chickenrun_2/shovel_hit.wav"}

new const mdl_wpn_v_fireaxe[] = {"models/chickenrun_2/v_fireaxe.mdl"}
new const mdl_wpn_wp_fireaxe[] = {"models/chickenrun_2/wp_fireaxe.mdl"}
new const snd_wpn_fireaxe_hitbody[] = {"chickenrun_2/fireaxe_hitbody.wav"}

new const mdl_wpn_v_machete[] = {"models/chickenrun_2/v_machete.mdl"}
new const mdl_wpn_wp_machete[] = {"models/chickenrun_2/wp_machete.mdl"}
new const snd_wpn_machete_hit[] = {"chickenrun_2/machete_hit.wav"}

new const mdl_wpn_v_wrench[] = {"models/chickenrun_2/v_wrench.mdl"}
new const mdl_wpn_wp_wrench[] = {"models/chickenrun_2/wp_wrench.mdl"}
new const snd_wpn_wrench_hitworld[] = {"chickenrun_2/wrench_hit_world.wav"}
new const snd_wpn_wrench_hitswing[] = {"chickenrun_2/wrench_swing.wav"}
new const snd_wpn_wrench_hitbuild[] = {"chickenrun_2/wrench_hit_build.wav"}

new const mdl_wpn_v_bottle[] = {"models/chickenrun_2/v_bottle.mdl"}
new const mdl_wpn_wp_bottle[] = {"models/chickenrun_2/wp_bottle.mdl"}
new const snd_wpn_bottle_hit[] = {"chickenrun_2/bottle_hit.wav"}


new const mdl_wpn_v_butterfly[] = {"models/chickenrun_2/v_butterfly.mdl"}
new const mdl_wpn_v_butterfly_watch[] = {"models/chickenrun_2/v_butterfly_watch.mdl"}
new const mdl_wpn_wp_butterfly[] = {"models/chickenrun_2/wp_butterfly.mdl"}
new const snd_wpn_butterfly_hit[] = {"chickenrun_2/butterfly_hit.wav"}
new const snd_wpn_butterfly_draw[] = {"chickenrun_2/butterfly_draw.wav"}
new const snd_wpn_butterfly_swing[] = {"chickenrun_2/butterfly_swing.wav"}


new const mdl_wpn_v_buildpda[] = {"models/chickenrun_2/v_buildpda.mdl"}
new const mdl_wpn_wp_buildpda[] = {"models/chickenrun_2/wp_buildpda.mdl"}
new const mdl_wpn_v_toolbox[] = {"models/chickenrun_2/v_toolbox.mdl"}
new const mdl_wpn_v_destroypda[] = {"models/chickenrun_2/v_destroypda.mdl"}
new const mdl_wpn_wp_destroypda[] = {"models/chickenrun_2/wp_destroypda.mdl"}

new const mdl_wpn_v_sapper[] = {"models/chickenrun_2/v_sapper.mdl"}
new const mdl_wpn_v_sapper_watch[] = {"models/chickenrun_2/v_sapper_watch.mdl"}
new const mdl_wpn_wp_sapper[] = {"models/chickenrun_2/wp_sapper.mdl"}
new const snd_wpn_sapper_plant[] = {"chickenrun_2/sapper_plant.wav"}
new const snd_wpn_sapper_removed[] = {"chickenrun_2/sapper_removed.wav"}
new const snd_wpn_sapped_warning[] = {"chickenrun_2/sapped_warning.wav"}


new const mdl_wpn_v_disguisekit[] = {"models/chickenrun_2/v_disguisekit.mdl"}
new const mdl_wpn_wp_disguisekit[] = {"models/chickenrun_2/wp_disguisekit.mdl"}

//------------admin=====================//------------admin=====================
new const mdl_wpn_v_assdeagle[] = {"models/chickenrun_2/v_assdeagle.mdl"}
new const mdl_wpn_p_assdeagle[] = {"models/chickenrun_2/p_assdeagle.mdl"}
new const mdl_wpn_w_assdeagle[] = {"models/chickenrun_2/w_assdeagle.mdl"}
new const snd_wpn_assdeagle_shoot[] = {"chickenrun_2/assdeagle_shoot.wav"}
new const snd_wpn_assdeagle_reload[] = {"chickenrun_2/assdeagle_reload.wav"}
enum{
	anim_assdeagleidle=0,
	anim_assdeagleleft=6,
	anim_assdeagleright=12,
	anim_assdeaglereload=14,
	anim_assdeagledraw=15
	
}
new bool:deagleleft[33]=false

new const mdl_wpn_v_assm3[] = {"models/chickenrun_2/v_assm3.mdl"}
new const mdl_wpn_p_assm3[] = {"models/p_m3.mdl"}
new const mdl_wpn_w_assm3[] = {"models/w_m3.mdl"}
new const snd_wpn_assm3_shoot[] = {"chickenrun_2/assm3_shoot.wav"}
new const snd_wpn_assm3_reload[] = {"chickenrun_2/assm3_reload.wav"}
enum{
	anim_assm3idle=0,
	anim_assm3right=1,
	anim_assm3left=2,
	anim_assm3startreload=5,
	anim_assm3reloading=3,
	anim_assm3endreload=4,
	anim_assm3draw=6
	
}
new bool:m3left[33]=false
//------------admin=====================


new const mdl_sentry_level1[] = {"models/chickenrun_2/w_sentry_lv1.mdl"}
new const mdl_sentry_level2[] = {"models/chickenrun_2/w_sentry_lv2.mdl"}
new const mdl_sentry_level3[] = {"models/chickenrun_2/w_sentry_lv3.mdl"}
new const snd_sentry_shoot[] = {"chickenrun_2/sentry_shoot.wav"}
new const snd_sentry_rocket[] = {"chickenrun_2/sentry_rocket.wav"}

new const mdl_dispenser[] = {"models/chickenrun_2/w_dispenser.mdl"}

new const snd_build_deploy[] = {"chickenrun_2/build_deploy.wav"}


new const snd_cloak[] = {"chickenrun_2/spy_cloak.wav"}
new const snd_uncloak[] = {"chickenrun_2/spy_uncloak.wav"}
new const snd_disguise[] = {"chickenrun_2/spy_disguise.wav"}

new const snd_empty[] = {"chickenrun_2/empty.wav"}

new const snd_swing[] = {"chickenrun_2/melee_swing.wav"}
new const snd_weapondraw[] = {"chickenrun_2/weapon_draw.wav"}
new const snd_multijump[] = {"chickenrun_2/multijump.wav"}

new const snd_spawnitem[] = {"chickenrun_2/spawn_item.wav"}
new const snd_pickitem[] = {"items/clipinsert1.wav"}

new spr_blood_spray,spr_blood_drop//,spr_dot

new const snd_crit_shot[] = {"chickenrun_2/crit_shot.wav"}
new const snd_minicrit[] = {"chickenrun_2/minicrit.wav"}
new const snd_crit_hit[] = {"chickenrun_2/crit_hit.wav"}
new const snd_crit_received[] = {"chickenrun_2/crit_received.wav"}

new const snd_hitsound[] = {"chickenrun_2/hitsound.wav"}

new const snd_explode[4][] = {"chickenrun_2/explode.wav","chickenrun_2/explode1.wav","chickenrun_2/explode2.wav","chickenrun_2/explode3.wav"}
new smoke,spr_minicrit,spr_crit

new const snd_playerpain1[][] = {"","chickenrun_2/scout_painsevere01.wav","chickenrun_2/heavy_painsevere01.wav","chickenrun_2/soldier_painsevere01.wav","chickenrun_2/pyro_painsevere01.wav","chickenrun_2/sniper_painsevere01.wav","chickenrun_2/medic_painsevere01.wav","chickenrun_2/engineer_painsevere01.wav","chickenrun_2/demoman_painsevere01.wav","chickenrun_2/spy_painsevere01.wav","chickenrun_2/spy_painsevere01.wav"}
new const snd_playerpain2[][] = {"","chickenrun_2/scout_painsevere02.wav","chickenrun_2/heavy_painsevere02.wav","chickenrun_2/soldier_painsevere02.wav","chickenrun_2/pyro_painsevere02.wav","chickenrun_2/sniper_painsevere02.wav","chickenrun_2/medic_painsevere02.wav","chickenrun_2/engineer_painsevere02.wav","chickenrun_2/demoman_painsevere02.wav","chickenrun_2/spy_painsevere02.wav","chickenrun_2/spy_painsevere02.wav"}

//---==[Zombie Mode cache]==---	//大丧失模式

new const snd_zb_startgame[] = {"sound/chickenrun_2/zb/startgame.mp3"}		//开局
new const snd_zb_readybgm[] = {"sound/chickenrun_2/zb/readybgm.mp3"}		//准备
new const snd_zb_gamestartbgm[] = {"sound/chickenrun_2/zb/gamestartbgm.mp3"}	//游戏开始BGM
new const snd_zb_thelasthumanbgm[] = {"sound/chickenrun_2/zb/lasthuman.mp3"}	//最后一个人类BGM
new const snd_zb_humanwin[] = {"sound/chickenrun_2/zb/humanwin.mp3"}		//人类胜利
new const snd_zb_zombiewin[] = {"sound/chickenrun_2/zb/zombiewin.mp3"}		//JS胜利
new const snd_zb_zombiehit[] = {"chickenrun_2/zombiehit.wav"}			//僵尸击打
new const snd_zb_human_ah[][] = {"chickenrun_2/scoutah.wav","chickenrun_2/scoutah.wav","chickenrun_2/heavyah.wav","chickenrun_2/soldierah.wav","chickenrun_2/pyroah.wav","chickenrun_2/sniperah.wav","chickenrun_2/medicah.wav","chickenrun_2/engineerah.wav","chickenrun_2/demomanah.wav","chickenrun_2/spyah.wav"}

new const mdl_zombie[][] = {"vip","ckr2zb_scout","ckr2zb_heavy","ckr2zb_soldier","ckr2zb_pyro","ckr2zb_sniper","ckr2zb_medic","ckr2zb_engineer","ckr2zb_demoman","ckr2zb_spy"}
new const mdl_wpn_scoutzombieknife[] = {"models/chickenrun_2/ckr2zb_scoutzombieknife.mdl"}
new const mdl_wpn_heavyzombieknife[] = {"models/chickenrun_2/ckr2zb_heavyzombieknife.mdl"}
new const mdl_wpn_soldierzombieknife[] = {"models/chickenrun_2/ckr2zb_soldierzombieknife.mdl"}
new const mdl_wpn_pyrozombieknife[] = {"models/chickenrun_2/ckr2zb_pyrozombieknife.mdl"}
new const mdl_wpn_sniperzombieknife[] = {"models/chickenrun_2/ckr2zb_sniperzombieknife.mdl"}
new const mdl_wpn_mediczombieknife[] = {"models/chickenrun_2/ckr2zb_mediczombieknife.mdl"}
new const mdl_wpn_engineerzombieknife[] = {"models/chickenrun_2/ckr2zb_engineerzombieknife.mdl"}
new const mdl_wpn_demomanzombieknife[] = {"models/chickenrun_2/ckr2zb_demomanzombieknife.mdl"}
new const mdl_wpn_spyzombieknife[] = {"models/chickenrun_2/ckr2zb_spyzombieknife.mdl"}
new const mdl_wpn_spyzombieknifehide[] = {"models/chickenrun_2/ckr2zb_spyzombieknifehide.mdl"}
new const mdl_wpn_spyzombiesapper[] = {"models/chickenrun_2/ckr2zb_spyzombiesapper.mdl"}
new const mdl_wpn_spyzombiesapperhide[] = {"models/chickenrun_2/ckr2zb_spyzombiesapperhide.mdl"}


//---==[Vs Mode Precache]==---		//VSBOSS

new const mdl_boss[][] = {"vip","ckr2vs_CBS_boss","ckr2vs_scp173_boss","ckr2vs_creeper_boss","ckr2vs_guardian"}

//CBS->邪恶基督徒
new const mdl_wpn_CBS_bossknife_normal[] = {"models/chickenrun_2/ckr2vs_cbsknifenormal_boss.mdl"}
new const mdl_wpn_CBS_bossknife_croc[] = {"models/chickenrun_2/ckr2vs_cbsknifecroc_boss.mdl"}
new const mdl_wpn_CBS_bossknife_wood[] = {"models/chickenrun_2/ckr2vs_cbsknifewood_boss.mdl"}
new const snd_vs_CBS_shoot[] = {"chickenrun_2/ckr2vs_cbsknifeshoot.wav"}
new const snd_vs_CBS_hitworld[] = {"chickenrun_2/ckr2vs_CBShitworld.wav"}
new const snd_vs_CBS_hitbody[] = {"chickenrun_2/ckr2vs_CBShitflesh.wav"}
new const snd_vs_CBS_nuhou[] = {"chickenrun_2/ckr2vs_CBSnuhou.wav"}
new const snd_vs_CBS_superjump[] = {"chickenrun_2/ckr2vs_CBSsuperjump.wav"}

new const snd_vs_CBS_start[] = {"sound/chickenrun_2/ckr2vs_CBSstart.mp3"}
new const snd_vs_CBS_gamebgm[] = {"sound/chickenrun_2/vs/ckr2vs_CBSBGM.mp3"}	//游戏BGM

//SCP173
new const mdl_wpn_SCP173_bossknife[] = {"models/chickenrun_2/ckr2vs_scp173knife_boss.mdl"}
new const snd_vs_SCP173_hitworld[] = {"chickenrun_2/ckr2vs_scp173hitworld.wav"}
new const snd_vs_SCP173_hitbody[] = {"chickenrun_2/ckr2vs_scp173hitflesh.wav"}
new const snd_vs_SCP173_kaojin[] = {"chickenrun_2/ckr2vs_scp173kaojin.wav"}

new const snd_vs_SCP173_start[] = {"sound/chickenrun_2/vs/ckr2vs_scp173start.mp3"}
new const snd_vs_SCP173_gamebgm[] = {"sound/chickenrun_2/vs/ckr2vs_scp173bgm.mp3"}	//游戏BGM

//Creeper
new const mdl_wpn_creeper_bossknife[] = {"models/chickenrun_2/ckr2vs_creeperknife_boss.mdl"}
new const snd_vs_creeper_explode[] = {"chickenrun_2/ckr2vs_creeper_explode.wav"}
new const snd_vs_creeper_nuhou[] = {"chickenrun_2/ckr2vs_creeper_nuhou.wav"}

new const snd_vs_creeper_start[] = {"sound/chickenrun_2/vs/ckr2vs_creeper_start.mp3"}
//new const snd_vs_creeper_gamebgm[] = {"sound/chickenrun_2/vs/ckr2vs_creeperbgm.mp3"}	//游戏BGM

//Guardian
new const mdl_wpn_guardian_bossknife[] = {"models/chickenrun_2/ckr2vs_guardianknife_boss.mdl"}
new const snd_vs_guardian_jianta[] = {"chickenrun_2/ckr2vs_guardian_jianta.wav"}





new const snd_vs_CBS_humanwin[] = {"sound/chickenrun_2/vs/victory.mp3"}
new const snd_vs_CBS_humanfailed[] = {"sound/chickenrun_2/vs/failed.mp3"}
new const snd_vs_SCP173_humanwin[] = {"sound/chickenrun_2/vs/ckr2vs_scp173lost.mp3"}
new const snd_vs_SCP173_humanfailed[] = {"sound/chickenrun_2/vs/ckr2vs_scp173win.mp3"}



new const snd_vs_Boss_beicishengyin[] = {"chickenrun_2/ckr2vs_beicishengyin.wav"}



//ano
new const snd_ano_start_3[] = {"sound/chickenrun_2/ano/announncer_am_roundstart03.mp3"}
new const snd_ano_start_2[] = {"sound/chickenrun_2/ano/announncer_am_roundstart02.mp3"}
new const snd_ano_start_1[] = {"sound/chickenrun_2/ano/announncer_am_roundstart01.mp3"}
new const snd_ano_ends_5sec[] = {"sound/chickenrun_2/ano/announcer_ends_5sec.mp3"}
new const snd_ano_ends_4sec[] = {"sound/chickenrun_2/ano/announcer_ends_4sec.mp3"}
new const snd_ano_ends_3sec[] = {"sound/chickenrun_2/ano/announcer_ends_3sec.mp3"}
new const snd_ano_ends_2sec[] = {"sound/chickenrun_2/ano/announcer_ends_2sec.mp3"}
new const snd_ano_ends_1sec[] = {"sound/chickenrun_2/ano/announcer_ends_1sec.mp3"}



//ITEM
new const mdl_w_health[] = {"models/chickenrun_2/obj_health.mdl"}
new const mdl_w_ammo[] = {"models/chickenrun_2/obj_ammo.mdl"}
new const mdl_w_healthandammo[] = {"models/chickenrun_2/obj_healthandammo.mdl"}





//hl sound
new const snd_pain[][] = {"player/pl_pain2.wav","player/pl_pain4.wav","player/pl_pain5.wav","player/pl_pain6.wav","player/pl_pain7.wav"}




public plugin_precache()
{
	
	
	//precache_model(mdl_wpn_w_p)
	
	//scattergun
	precache_model(mdl_wpn_v_scattergun)
	precache_model(mdl_wpn_wp_scattergun)
	precache_sound(snd_wpn_scattergun_reload)
	precache_sound(snd_wpn_scattergun_shoot)
	
	//pistol
	precache_model(mdl_wpn_v_pistol)
	precache_model(mdl_wpn_v_pistol_engineer)
	precache_model(mdl_wpn_wp_pistol)
	precache_sound(snd_wpn_pistol_reload)
	precache_sound(snd_wpn_pistol_shoot)
	
	//minigun
	precache_model(mdl_wpn_v_minigun)
	precache_model(mdl_wpn_wp_minigun)
	precache_sound(snd_wpn_minigun_shoot)
	precache_sound(snd_wpn_minigun_shoot_crit)
	precache_sound(snd_wpn_minigun_spin)
	precache_sound(snd_wpn_minigun_winddown)
	precache_sound(snd_wpn_minigun_windup)
	
	//rpg
	precache_model(mdl_wpn_v_rpg)
	precache_model(mdl_wpn_wp_rpg)
	precache_model(mdl_wpn_pj_rocket)
	precache_sound(snd_wpn_rpg_shoot)
	precache_sound(snd_wpn_rpg_reload)
	
	//flamethrower
	precache_model(mdl_wpn_v_flamethrower)
	precache_model(mdl_wpn_wp_flamethrower)
	precache_model(mdl_wpn_pj_flame)
	precache_sound(snd_wpn_flamethrower_start)
	precache_sound(snd_wpn_flamethrower_loop)
	precache_sound(snd_wpn_flamethrower_loop_crit)
	precache_sound(snd_wpn_flamethrower_airblast)
	precache_sound(snd_wpn_flamethrower_redirect)
	
	//medicgun
	precache_model(mdl_wpn_v_medicgun)
	precache_model(mdl_wpn_wp_medicgun)
	precache_sound(snd_wpn_medicgun_heal)
	precache_sound(snd_wpn_medicgun_fullcharge)
	precache_sound(snd_wpn_medicgun_chargeon)
	precache_sound(snd_wpn_medicgun_chargeoff)
	precache_sound(snd_wpn_medicgun_notarget)
	
	//syringegun
	precache_model(mdl_wpn_v_syringegun)
	precache_model(mdl_wpn_wp_syringegun)
	precache_model(mdl_wpn_pj_syringe)
	precache_sound(snd_wpn_syringegun_shoot)
	precache_sound(snd_wpn_syringegun_reload)
	
	//bonesaw
	precache_model(mdl_wpn_v_bonesaw)
	precache_model(mdl_wpn_wp_bonesaw)
	precache_sound(snd_wpn_bonesaw_hit)
	
	
	//shotgun
	precache_model(mdl_wpn_v_shotgunheavy)
	precache_model(mdl_wpn_v_shotgunsoldier)
	precache_model(mdl_wpn_v_shotgunpyro)
	precache_model(mdl_wpn_v_shotgunengineer)
	precache_model(mdl_wpn_wp_shotgunall)
	precache_sound(snd_wpn_shotgun_shoot)
	precache_sound(snd_wpn_shotgun_reload)
	
	
	//grenadelauncher
	precache_model(mdl_wpn_v_grenadelauncher)
	precache_model(mdl_wpn_wp_grenadelauncher)
	precache_model(mdl_wpn_pj_grenade)
	precache_sound(snd_wpn_grenadelauncher_shoot)
	precache_sound(snd_wpn_grenadelauncher_reload)
	
	//stickylauncher
	precache_model(mdl_wpn_v_stickylauncher)
	precache_model(mdl_wpn_wp_stickylauncher)
	precache_model(mdl_wpn_pj_stickybomb)
	precache_sound(snd_wpn_stickylauncher_shoot)
	precache_sound(snd_wpn_stickylauncher_reload)
	precache_sound(snd_wpn_stickylauncher_det)
	precache_sound(snd_wpn_stickylauncher_charge)
	
	//sniperifle
	precache_model(mdl_wpn_v_sniperifle)
	precache_model(mdl_wpn_wp_sniperifle)
	precache_sound(snd_wpn_sniperifle_shoot)
	precache_sound(snd_wpn_sniperifle_reload)
	precache_sound(snd_wpn_sniperifle_charge)
	
	//smg
	precache_model(mdl_wpn_v_smg)
	precache_model(mdl_wpn_wp_smg)
	precache_sound(snd_wpn_smg_shoot)
	precache_sound(snd_wpn_smg_reload)
	
	//revolver
	precache_model(mdl_wpn_v_revolver)
	precache_model(mdl_wpn_v_revolver_watch)
	precache_model(mdl_wpn_wp_revolver)
	precache_sound(snd_wpn_revolver_reload)
	precache_sound(snd_wpn_revolver_shoot)
	
	
	
	//bat
	precache_model(mdl_wpn_v_bat)
	precache_model(mdl_wpn_wp_bat)
	precache_sound(snd_wpn_bat_draw)
	precache_sound(snd_wpn_bat_hit)
	
	//fist
	precache_model(mdl_wpn_v_fist)
	precache_model(mdl_wpn_wp_fist)
	precache_sound(snd_wpn_fist_hitbody)
	
	//shovel
	precache_model(mdl_wpn_v_shovel)
	precache_model(mdl_wpn_wp_shovel)
	precache_sound(snd_wpn_shovel_hit)
	
	//fireaxe
	precache_model(mdl_wpn_v_fireaxe)
	precache_model(mdl_wpn_wp_fireaxe)
	precache_sound(snd_wpn_fireaxe_hitbody)
	
	//machete
	precache_model(mdl_wpn_v_machete)
	precache_model(mdl_wpn_wp_machete)
	precache_sound(snd_wpn_machete_hit)
	
	//wrench
	precache_model(mdl_wpn_v_wrench)
	precache_model(mdl_wpn_wp_wrench)
	precache_sound(snd_wpn_wrench_hitswing)
	precache_sound(snd_wpn_wrench_hitworld)
	precache_sound(snd_wpn_wrench_hitbuild)
	
	precache_model(mdl_wpn_v_bottle)
	precache_model(mdl_wpn_wp_bottle)
	precache_sound(snd_wpn_bottle_hit)
	
	//butterfly
	precache_model(mdl_wpn_v_butterfly)
	precache_model(mdl_wpn_v_butterfly_watch)
	precache_model(mdl_wpn_wp_butterfly)
	precache_sound(snd_wpn_butterfly_draw)
	precache_sound(snd_wpn_butterfly_hit)
	precache_sound(snd_wpn_butterfly_swing)

	//buildpda & destroypda
	precache_model(mdl_wpn_v_buildpda)
	precache_model(mdl_wpn_wp_buildpda)
	precache_model(mdl_wpn_v_toolbox)
	precache_model(mdl_wpn_v_destroypda)
	precache_model(mdl_wpn_wp_destroypda)
	
	//sapper
	precache_model(mdl_wpn_v_sapper)
	precache_model(mdl_wpn_wp_sapper)
	precache_model(mdl_wpn_v_sapper_watch)
	precache_sound(snd_wpn_sapper_plant)
	precache_sound(snd_wpn_sapper_removed)
	precache_sound(snd_wpn_sapped_warning)
	
	//disguisekit
	precache_model(mdl_wpn_v_disguisekit)
	precache_model(mdl_wpn_wp_disguisekit)
	
	//sentry
	precache_model(mdl_sentry_level1)
	precache_model(mdl_sentry_level2)
	precache_model(mdl_sentry_level3)
	precache_sound(snd_sentry_shoot)
	precache_sound(snd_sentry_rocket)
	
	//ADMIN======================================
	precache_model(mdl_wpn_v_assdeagle)
	precache_model(mdl_wpn_p_assdeagle)
	precache_model(mdl_wpn_w_assdeagle)
	precache_sound(snd_wpn_assdeagle_shoot)
	precache_sound(snd_wpn_assdeagle_reload)
	
	precache_model(mdl_wpn_v_assm3)
	precache_model(mdl_wpn_p_assm3)
	precache_model(mdl_wpn_w_assm3)
	precache_sound(snd_wpn_assm3_shoot)
	precache_sound(snd_wpn_assm3_reload)
	//ADMIN======================================
	
	//dispenser
	precache_model(mdl_dispenser)
	
	precache_sound(snd_build_deploy)
	
	
	precache_sound(snd_cloak)
	precache_sound(snd_disguise)
	precache_sound(snd_uncloak)
	
	precache_sound(snd_empty)
	
	precache_sound(snd_swing)
	precache_sound(snd_weapondraw)
	precache_sound(snd_multijump)
	
	precache_sound(snd_crit_shot)
	precache_sound(snd_minicrit)
	precache_sound(snd_crit_hit)
	precache_sound(snd_crit_received)
	
	precache_sound(snd_hitsound)
	
	precache_sound(snd_explode[0])
	precache_sound(snd_explode[1])
	precache_sound(snd_explode[2])
	precache_sound(snd_explode[3])
	
	
	new name[64]
	for(new i;i<sizeof mdl_human;i++)
	{
		format(name,63,"models/player/%s/%s.mdl",mdl_human[i],mdl_human[i])
		precache_model(name)
	}
	for(new i;i<sizeof mdl_zombie;i++)
	{
		format(name,63,"models/player/%s/%s.mdl",mdl_zombie[i],mdl_zombie[i])
		precache_model(name)
	}
	for(new i;i<sizeof mdl_boss;i++)
	{
		format(name,63,"models/player/%s/%s.mdl",mdl_boss[i],mdl_boss[i])
		precache_model(name)
	}
	for(new i=1;i<11;i++)
	{
		precache_sound(snd_callmedic[i])
	}
	for(new i=1;i<11;i++)
	{
		precache_sound(snd_playerpain1[i])
		precache_sound(snd_playerpain2[i])
	}
	
	precache_sound(snd_zb_human_ah[1])
	precache_sound(snd_zb_human_ah[2])
	precache_sound(snd_zb_human_ah[3])
	precache_sound(snd_zb_human_ah[4])
	precache_sound(snd_zb_human_ah[5])
	precache_sound(snd_zb_human_ah[6])
	precache_sound(snd_zb_human_ah[7])
	precache_sound(snd_zb_human_ah[8])
	precache_sound(snd_zb_human_ah[9])
	
	
	//zb mode
	precache_generic(snd_zb_startgame)				//开局
	precache_generic(snd_zb_readybgm)				//30s准备
	precache_generic(snd_zb_gamestartbgm)				//游戏开始BGM
	precache_generic(snd_zb_thelasthumanbgm)			//最后一个人类BGM
	precache_generic(snd_zb_humanwin)				//人类胜利
	precache_generic(snd_zb_zombiewin)				//JS胜利
	precache_sound(snd_zb_zombiehit)				//僵尸击打
	
	precache_model(mdl_wpn_scoutzombieknife)
	precache_model(mdl_wpn_heavyzombieknife)
	precache_model(mdl_wpn_soldierzombieknife)
	precache_model(mdl_wpn_pyrozombieknife)
	precache_model(mdl_wpn_sniperzombieknife)
	precache_model(mdl_wpn_mediczombieknife)
	precache_model(mdl_wpn_engineerzombieknife)
	precache_model(mdl_wpn_demomanzombieknife)
	precache_model(mdl_wpn_spyzombieknife)
	precache_model(mdl_wpn_spyzombieknifehide)
	precache_model(mdl_wpn_spyzombiesapper)
	precache_model(mdl_wpn_spyzombiesapperhide)
	
	
	//vs mode
	precache_generic(snd_vs_CBS_gamebgm)
	precache_generic(snd_vs_CBS_start)
	precache_generic(snd_vs_CBS_humanwin)
	precache_generic(snd_vs_CBS_humanfailed)
	
	precache_model(mdl_wpn_CBS_bossknife_normal)
	precache_model(mdl_wpn_CBS_bossknife_croc)
	precache_model(mdl_wpn_CBS_bossknife_wood)
	precache_sound(snd_vs_CBS_shoot)
	precache_sound(snd_vs_CBS_hitworld)
	precache_sound(snd_vs_CBS_hitbody)
	precache_sound(snd_vs_CBS_nuhou)
	precache_sound(snd_vs_CBS_superjump)
	
	
	precache_generic(snd_vs_SCP173_gamebgm)
	precache_generic(snd_vs_SCP173_start)
	
	precache_model(mdl_wpn_SCP173_bossknife)
	precache_sound(snd_vs_SCP173_hitworld)
	precache_sound(snd_vs_SCP173_hitbody)
	precache_sound(snd_vs_SCP173_kaojin)
	
	
	precache_generic(snd_vs_creeper_start)
	
	precache_model(mdl_wpn_creeper_bossknife)
	precache_sound(snd_vs_creeper_nuhou)
	precache_sound(snd_vs_creeper_explode)
	
	precache_model(mdl_wpn_guardian_bossknife)
	precache_sound(snd_vs_guardian_jianta)
	
	precache_sound(snd_vs_Boss_beicishengyin)
	
	//ano
	precache_generic(snd_ano_start_3)
	precache_generic(snd_ano_start_2)
	precache_generic(snd_ano_start_1)
	precache_generic(snd_ano_ends_5sec)
	precache_generic(snd_ano_ends_4sec)
	precache_generic(snd_ano_ends_3sec)
	precache_generic(snd_ano_ends_2sec)
	precache_generic(snd_ano_ends_1sec)
	
	
	//ITEM
	precache_model(mdl_w_health)
	precache_model(mdl_w_ammo)
	precache_model(mdl_w_healthandammo)
	precache_sound(snd_spawnitem)
	precache_sound(snd_pickitem)
	
	
	//hl sound
	precache_sound(snd_pain[0])
	precache_sound(snd_pain[1])
	precache_sound(snd_pain[2])
	precache_sound(snd_pain[3])
	
	
	//SPR
	spr_minicrit = engfunc(EngFunc_PrecacheModel,"sprites/chickenrun_2/minicrit.spr")
	spr_crit = engfunc(EngFunc_PrecacheModel,"sprites/chickenrun_2/critical.spr")
	spr_blood_spray = engfunc(EngFunc_PrecacheModel,"sprites/bloodspray.spr")//游戏自带
	spr_blood_drop = engfunc(EngFunc_PrecacheModel,"sprites/blood.spr")//游戏自带
	medicbeam = engfunc(EngFunc_PrecacheModel,"sprites/chickenrun_2/medicbeam.spr")
	rockettrail= engfunc(EngFunc_PrecacheModel,"sprites/chickenrun_2/rockettrail.spr")
	exp_new1 = engfunc(EngFunc_PrecacheModel,"sprites/chickenrun_2/exp_new1.spr")//28kb
	exp_new2 = engfunc(EngFunc_PrecacheModel,"sprites/chickenrun_2/exp_new2.spr")//28kb
	exp_new3 = engfunc(EngFunc_PrecacheModel,"sprites/chickenrun_2/exp_new3.spr")//10kb
	smoke = engfunc(EngFunc_PrecacheModel,"sprites/chickenrun_2/rpgsmoke.spr")//86kb
	//spr_dot=  engfunc(EngFunc_PrecacheModel,"sprites/chickenrun_2/dot.spr")
	
	//precache_model("models/player/sorpack_zm_lv3/sorpack_zm_lv3.mdl")
}
//-----------------------------------------------------------------------------//
////ConVar变量区
new cvar_normal_mul
new cvar_minicrit_mul
new cvar_crit_mul
new cvar_crit_percent

new cvar_arenamode_gametime
new cvar_arenamode_endtime
new cvar_arenamode_spawntime
new cvar_arenamode_redspawnnum
new cvar_arenamode_bluespawnnum

new cvar_zombiemode_could_spawn
new cvar_zombiemode_spawntime
new cvar_zombiemode_firstzb_time
new cvar_zombiemode_starttime
new cvar_zombiemode_gametime
new cvar_zombiemode_humannumtime
new cvar_zombiemode_endtime

new cvar_zombie_first_other_ndhm
new cvar_zombie_basehp_mul
new cvar_zombie_first_hm_num_addhp
new cvar_zombie_lvnew_dmgmul_per
new cvar_zombie_lvold_dmgmul_per
new cvar_zombie_lvstr_dmgmul_per
new cvar_zombie_lvsup_dmgmul_per

new cvar_vsmode_boss_cometime
new cvar_vsmode_starttime
new cvar_vsmode_gametime
new cvar_vsmode_endtime
new cvar_vsmode_humannumtime
new cvar_vsmode_boss_addspeedmax
new cvar_vsmode_boss_maxpower
new cvar_vsmode_boss_minhppercent

new cvar_supply_heal_small
new cvar_supply_heal_normal
new cvar_supply_heal_big
new cvar_supply_ammo_small
new cvar_supply_ammo_normal
new cvar_supply_ammo_big
new cvar_supply_spawn_time

new cvar_wpn_scattergun_curtime
new cvar_wpn_scattergun_shotnum
new cvar_wpn_scattergun_radius
new cvar_wpn_scattergun_distance
new cvar_wpn_scattergun_mindmgmul
new cvar_wpn_scattergun_dmg
new cvar_wpn_scattergun_kb
new cvar_wpn_scattergun_shotdealy

new cvar_wpn_rpg_curtime
new cvar_wpn_rpg_damage
new cvar_wpn_rpg_ownermindamage
new cvar_wpn_rpg_ownermaxdamage
new cvar_wpn_rpg_shotdealy
new cvar_wpn_rpg_slowvec_mul
new cvar_wpn_rpg_rocketspeed
new cvar_wpn_rpg_timer_maxtime
new cvar_wpn_rpg_timer_minmul
new cvar_wpn_rpg_explode_maxradius
new cvar_wpn_rpg_explode_minmul
new cvar_wpn_rpg_expforce_ground
new cvar_wpn_rpg_expforce_noground

new cvar_wpn_pistol_curtime
new cvar_wpn_pistol_radius
new cvar_wpn_pistol_dmg
new cvar_wpn_pistol_distance
new cvar_wpn_pistol_mindmgmul
new cvar_wpn_pistol_shotdealy
new cvar_wpn_pistol_kb


new cvar_wpn_minigun_curtime
new cvar_wpn_minigun_putdown_time
new cvar_wpn_minigun_putup_time
new cvar_wpn_minigun_shotnum
new cvar_wpn_minigun_radius
new cvar_wpn_minigun_shotdealy
new cvar_wpn_minigun_dmg
new cvar_wpn_minigun_distance
new cvar_wpn_minigun_mindmgmul
new cvar_wpn_minigun_kb
new cvar_wpn_minigun_punchangle

new cvar_wpn_firegun_curtime
new cvar_wpn_firegun_shotdealy
new cvar_wpn_firegun_flamespeed
new cvar_wpn_firegun_removetime
new cvar_wpn_firegun_slowmul

new cvar_wpn_medicgun_curtime
new cvar_wpn_medicgun_maxdistance
new cvar_wpn_medicgun_healdsts
new cvar_wpn_medicgun_overheal_c
new cvar_wpn_medicgun_heal_c
new cvar_wpn_medicgun_healtime
new cvar_wpn_medicgun_supercharge


new cvar_wpn_sniperifle_curtime
new cvar_wpn_sniperifle_shotdealy
new cvar_wpn_sniperifle_damage
new cvar_wpn_sniperifle_kjspper
new cvar_wpn_sniperifle_powerwait
new cvar_wpn_sniperifle_maxpower
new cvar_wpn_sniperifle_powerspeed
new cvar_wpn_sniperifle_kb

new cvar_wpn_smg_curtime

new cvar_wpn_shotgun_curtime

new cvar_wpn_grenadelaunch_curtime

new cvar_wpn_stickylauncher_curtime
new cvar_wpn_stickylauncher_shotdl
new cvar_wpn_stickylauncher_maxdmg
new cvar_wpn_stickylauncher_radius
new cvar_wpn_stickylauncher_minmul
new cvar_wpn_stickylauncher_slowvec
new cvar_wpn_stickylauncher_zjxdmg
new cvar_wpn_stickylauncher_zjddmg
new cvar_wpn_stickylauncher_speed
new cvar_wpn_stickylauncher_bombrd
new cvar_wpn_stickylauncher_health
new cvar_wpn_stickylauncher_dpower
new cvar_wpn_stickylauncher_ground
new cvar_wpn_stickylauncher_uground
new cvar_wpn_stickylauncher_strelo
new cvar_wpn_stickylauncher_inrelo
new cvar_wpn_stickylauncher_endrelo
new cvar_wpn_stickylauncher_maxnum

new cvar_wpn_revolver_curtime

new cvar_wpn_assdeagle_curtime

new cvar_wpn_sapper_curtime

new cvar_wpn_bat_curtime

new cvar_wpn_fist_curtime

new cvar_wpn_shovel_curtime

new cvar_wpn_fireaxe_curtime

new cvar_wpn_machete_curtime

new cvar_wpn_syringegun_curtime

new cvar_wpn_bonesaw_curtime

new cvar_wpn_wrench_curtime

new cvar_wpn_bottle_curtime

new cvar_wpn_butterfly_curtime

new cvar_sentry_rocketdamage

new cvar_sentry_rocketspeed

//-----------------------------------------------------------------------------//
////玩家变量区
new g_wpnitem_pri[33][11]			//玩家使用哪种主武器物品 -> -1为原配
new g_wpnitem_sec[33][11]			//玩家使用哪种副武器物品 -> -1为原配
new g_wpnitem_knife[33][11]			//玩家使用哪种近战武器物品 -> -1为原配
new g_wpnitem_willpri[33][11]			//玩家使用哪种主武器物品 -> -1为原配
new g_wpnitem_willsec[33][11]			//玩家使用哪种副武器物品 -> -1为原配
new g_wpnitem_willknife[33][11]			//玩家使用哪种近战武器物品 -> -1为原配

new g_wpnitem_knife_zombie[33][11]
new g_wpnitem_willknife_zombie[33][11]

new player_weaponid_last[33]
new player_weaponid_now[33]
new player_weaponclassname_chi[33][32]
new player_weaponclassname_eng[33][32]




new bool:g_critical_on[33]=false		//大暴击开启?
new bool:must_critical[33]=false		//强制暴击

new gcritical[33]			//玩家回合随机暴击率
new gfactspeed[33]			//玩家回合最大移动速度
new gmaxhealth[33]			//玩家回合生命上限
new goverhealed[33]			//


//SLOT 1 CLIP ->
new gpri_clip[33]			//当前主武器弹夹子弹量
new gmaxpriclip[33]			//玩家主武器最大弹夹上限
//SLOT 1 BPAMMO ->
new gpri_bpammo[33]			//当前主武器弹夹子弹量
new gmaxpribpammo[33]			//玩家主武器最大备弹上限
//SLOT 2 CLIP ->
new gsec_clip[33]			//当前副武器弹夹子弹量
new gmaxsecclip[33]			//玩家副武器最大弹夹上限
//SLOT 2 BPAMMO ->
new gsec_bpammo[33]			//当前副武器弹夹子弹量
new gmaxsecbpammo[33]			//玩家副武器最大备弹上限










new bool:giszm[1001]			//是JS么
new ghuman[33],gwillbehuman[33]		//当前人类兵种&将要变成的人类兵种
enum{
	human_scout=1,
	human_heavy,
	human_soldier,
	human_pyro,
	human_sniper,
	human_medic,
	human_engineer,
	human_demoman,
	human_spy,
	human_assassin
}
new gzombie[33],gwillbezombie[33]	//当前的JS兵种&将要变成的JS兵种
enum{
	zombie_scout=1,
	zombie_heavy,
	zombie_soldier,
	zombie_pyro,
	zombie_sniper,
	zombie_medic,
	zombie_engineer,
	zombie_demoman,
	zombie_spy
}
new gboss[33],gwillbeboss[33]		//当前的Boss兵种&将要变成的Boss兵种
enum{
	boss_cbs=1,
	boss_scp173,
	boss_creeper,
	boss_guardian,
	boss_gentlespy,
	boss_saxtonhale
}

new bool:gunonground[33]		//没在地上
new gsecjump_num[33]			//连跳数量
new gsecjump_maxnum[33]			//最大连跳数量

new medictarget[1001]			//医疗 -> 返回被医疗者id
new bemedic[1001]			//被医疗 -> 返回医疗者id

new Float:ent_anglethinktime[1001]	//实体角度变更检测时间
new bool:ent_touched[1001][33]		//玩家是否被该实体撞过
new bool:ent_touchedground[1001]	//实体撞到东西了

new befire[33]				//被烧到了 -> 返回烧你的人的id
new firedmg_times[33]			//余焰伤害次数

new bebleed[33]				//被割伤了 -> 返回割你的人的id
new bleeddmg_times[33]			//流血伤害次数

new stickylauncher_power[33]		//粘弹蓄力能量
new bool:stickyready[1001]		//这颗粘弹就绪了 准备爆炸

new bool:knifeattacking[33]		//刀子挥舞(中)

new sniperifle_power[33]		//狙击蓄能

new lastattacker[33]			//谁最后打了你
new lastattacker_2[33]			//谁最后的前一个打了你

new bool:minigun_downing[33]		//转轮机枪放下中
new bool:minigun_downed[33]		//转轮机枪就绪
new bool:minigun_uping[33]		//转轮机枪抬起中

new bool:butterfly_backuping[33]	//蝴蝶刀抬起来中
new bool:butterfly_backuped[33]		//蝴蝶刀就绪
new bool:butterfly_backdownning[33]	//蝴蝶刀放下中

new bool:invisible_ing[33]		//正在隐形
new bool:invisible_ed[33]		//隐形中...
new bool:uninvisible_ing[33]		//解除隐形中
new Float:invisible_checktime[33]
new invisible_power[33]
#define MAX_INVISIBLE_POWER	10000

new bool:skill_canuse[33]		//技能(WTF)可以使用了

new bool:willspawn[33]			//将要重生
new spawn_second[33]			//重生倒计时(秒)

new bool:cancallmedic[33]		//可以喊医生了 MEDIC~~~~

new gcurmodel[33][32]			//当前的模型index

new bool:player_reloadstatus[33][4]	//玩家上弹属性
enum{
	reload_none=0,
	reload_start,
	reload_ing,
	reload_end
}

new player_sentrystatus[33][12]// 360/255=1.41176...  255/360=0.70833...	//太哲学
enum{
	sentry_id=0,
	sentry_buildpercent,
	sentry_startangle_leftright,
	sentry_controller0_num,
	sentry_controller1_num,
	sentry_level,
	sentry_levelnum,
	sentry_maxlevelnum,
	sentry_health,
	sentry_maxhealth,
	sentry_ammo,
	sentry_maxammo
}
new player_dispenserstatus[33][9]	//太TM哲学
enum{
	dispenser_id=0,
	dispenser_buildpercent,
	dispenser_level,
	dispenser_levelnum,
	dispenser_maxlevelnum,
	dispenser_health,
	dispenser_maxhealth,
	dispenser_ammo,
	dispenser_maxammo
}
new Float:sentry_buildthinktime[33]	//步哨建造检测时间
new Float:dispenser_buildthinktime[33]	//补给器建造检测时间

new Float:sentry_turnthinktime[33]	//步哨转向检测时间
new Float:sentry_shootthinktime[33]	//步哨射击检测时间
new Float:sentry_leveltime[33]		//步哨升级时间
new Float:sentry_shootrockettime[33]	//步哨发射火箭检测时间

new Float:dispenser_healthinktime[33]	//补给器补给生命检测时间
new Float:dispenser_addammothinktime[33]//补给器补给弹药检测
new Float:dispenser_leveltime[33]	//补给器升级时间


new Float:ent_timer[1001]		//实体计时器(我用来检测创建了多久)
new Entity_Status[1001][11]		//实体属性
enum{
	entstat_startvec=0,
	entstat_valuefordamage,
	entstat_valueforhealth,
	entstat_valueforcritnum,
	entstat_returned
}

new Float:player_pickitemtime[33]	
new Float:player_pickammotime[33]	//玩家捡起补给检测时间(间隔)


new gmetalnum[33]
new gmetalmaxnum[33]

new bool:spawn_post[33]
new Float:gtouchsupply_think[33]

new gstickyid[33][MAX_STICKYBOMB]
new gstickymaxnum[33]

new Float:player_timer[33]
new medic_callustimes[33]

new bool:weaponcur_lock[33]

new Float:player_curweapontime[33]
new Float:player_priwpnnextattacktime[33]
new Float:player_secwpnnextattacktime[33]
new Float:player_knifewpnnextattacktime[33]
new Float:player_priwpn_specialtimer[33]
new Float:player_secwpn_specialtimer[33]
new Float:player_knifewpn_specialtimer[33]

new bool:infire[33]

#define MAX_CHARGEPOWER	10000
new gchargepower[33] //-> MAX = 10000
new bool:supercharge[33]

new player_movebuilding[33]
new bool:build_insapper[33][5]
new build_spapper_remove_percent[33][5]
new build_sapperowner[33][5]
new Float:sapperdmg_checktime_sentry[33]
new Float:sapperdmg_checktime_dispenser[33]
enum{
	build_sentry=1,
	build_dispenser,
	build_telein,
	build_teleout
}

new gaimtarget[33]
new Float:getaimtarget_checktime[33]

new bool:first_playgame[33]
new gteam[1001]
new g_teamplayernum[4]			//返回哪个队伍的玩家数
new g_teamhumantypenum[4][11]		//返回哪个队伍的什么兵种的数量
new g_teamzombietypenum[11]		//返回僵尸兵种的数量
new g_teambosstypenum[11]		//返回BOSS类型的数量
enum{
	team_no=0,
	team_red,
	team_blue,
	team_spec
}

new bool:player_use_chinese[33]



#define MAX_FIRSTZOMBIE	2
new firstzombie[MAX_FIRSTZOMBIE+1]
new firstzmcome_second			//FirstZmComeTime(秒)
new humanspecialcome_second

new gzombielevel[33]
new gzombielevelnum[33]
enum{
	level_new=1,
	level_old,
	level_strong,
	level_super
}
new Float:gzombie_skilltime[33]

#define MAX_HUMANHERO	1
new human_hero[MAX_HUMANHERO] //好把其实这是最后一人
new ghuman_armornum[33]

#define MAX_HUMANSPECIAL	1
new human_special[MAX_HUMANSPECIAL] //这才是英雄



new healthpoint_num,ammopoint_num,healthandammopoint_num
new supply_type[33],supply_size[33]
new bool:supply_ready[1001]

new supply_status[128][6]
new tempsupply_status[1001][6]
enum{
	supplytype=0,
	supplysize,
	supplyorg_x,
	supplyorg_y,
	supplyorg_z,
	supplyentityid
}
new supply_index[1001]
new const MSG_SUPPLY_TYPE[][] = {"生命","弹药","生命&弹药"}
enum{
	type_health=0,
	type_ammo,
	type_healthandammo
}
new const MSG_SUPPLY_SIZE[][] = {"小","中","大"}
enum{
	size_small=0,
	size_normal,
	size_big
}
new const CLASSNAME_SUPPLY[][] = {"supply_health","supply_ammo","supply_healthandammo"}
new const MDL_SUPPLY[][] = {"models/chickenrun_2/obj_health.mdl","models/chickenrun_2/obj_ammo.mdl","models/chickenrun_2/obj_healthandammo.mdl"}
new bool:loaded_mapsupply=false
new putsupply

new g_roundscore[33]
new g_allscore[33]
new g_takedamage[33]
new g_roundtakedamage[33]
new g_alltakedamage[33]
new g_bedamage[33]
new g_roundbedamage[33]
new g_allbedamage[33]


new OrpheuFunction:handleFuncResetSequenceInfo
new PlayerAnim:g_iSequence[33]
new start_anim[33]
new g_iPMLastPlayer


new Float:playerpain_checktime[33]

new bool:g_zspawned[33]
new Float:spawn_godmodetime[33]

new bool:disguise[33]		//伪装了
new disguise_target[33]		//伪装哪个SB
new disguise_team[33]		//伪装到哪个阵营
new disguise_type[33]		//伪装成甚么类型
new bool:disguise_iszm[33]

new Boss			//Boss就是Boss呗 傻X
new Bosscome_second		//Boss还有多久出现
new Boss_fuckpower		//Boss怒气值积攒
new Boss_maxfuckpower		//Boss最大怒气值
new Boss_changeknife
new Boss_lunliudian[33]

new Float:Bossskilldealy[33]

new Float:getpowertosuperjump[33]
new bool:insuperjump[33]	//在超级跳中?
new Float:lastsuperjumptime[33]	//最后一次超级跳时间

new Float:player_lastvec[33][3]	//玩家上次的向量

new bossspawnpoint_num
new bool:loaded_mapbossspawnpoint=false
new bossspawnpoint_status[128][3]
new bossspawnpointent_index[501]
enum{
	bossspawnpoint_x=0,
	bossspawnpoint_y,
	bossspawnpoint_z
}

new Float:player_zhayanchecktime[33]

new TeamSpawn_Num[4]


new WeaponMenu_Pri_WpnIndex[11][1000]
new WeaponMenu_Pri_WpnName[11][1000][32]
new WeaponMenu_Pri_PlayerPage[11][33]



new WeaponMenu_Sec_WpnIndex[11][1000]
new WeaponMenu_Sec_WpnName[11][1000][32]
new WeaponMenu_Sec_PlayerPage[11][33]


new WeaponMenu_PlayerType[33]

new WeaponMenu_Knife_WpnIndex[11][1000]
new WeaponMenu_Knife_WpnName[11][1000][32]
new WeaponMenu_Knife_PlayerPage[11][33]

new WeaponMenu_PlayerChooseSuit[33]
enum{
	suit_primary=1,
	suit_secondry,
	suit_knife,
	suit_hat,
	suit_model

}


new Float:NextCould_CurWeapon_Time[33]
new Float:NextCould_Duck_Time[33]
new Float:NextCould_Jump_Time[33]

new bool:Speedmul_switch[33]
new Speedmul_value_percent[33]

new bool:Attackspeedmul_switch[33][4]
new Attackspeedmul_value_percent[33][4]
new bool:Reloadspeedmul_switch[33][4]
new Reloadspeedmul_value_percent[33][4]
enum{
	weapon_primary=1,
	weapon_secondry,
	weapon_knife
}


#define NPC_CLNAME "ent_npc"
new g_npcid[128],g_idnpc[501],g_npcnum

public create_npc(id)
{
	new Float:idorg[3],Float:endorg[3]
	pev(id,pev_origin,idorg)
	idorg[2]+=20.0
	ckrun_get_user_startpos(id,10000.0,0.0,0.0,endorg)
	fm_trace_line(id,idorg,endorg,endorg)
	endorg[2]+=35.0
	
	new Float:Angle[3]
	pev(id,pev_angles,Angle)
	
	new npc = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!npc) return; //没创建成功的话..
	
	set_pev(npc, pev_angles, Angle)
	set_pev(npc, pev_classname, NPC_CLNAME)
									
	engfunc(EngFunc_SetModel, npc,"models/player/sorpack_zm_lv3/sorpack_zm_lv3.mdl")
	engfunc(EngFunc_SetSize,npc, {-12.0, -12.0, -0.0},{12.0,12.0, 0.0})
								
	set_pev(npc, pev_solid, SOLID_SLIDEBOX)
	set_pev(npc, pev_movetype, MOVETYPE_FLY)
	set_pev(npc, pev_owner, 0)
	set_pev(npc, pev_entowner, id)
	
	set_pev(npc,pev_origin,endorg)
	
	set_pev(npc,pev_sequence,random_num(1,112))
	set_pev(npc,pev_framerate,1.0)
					
							
	fm_set_entity_visible(npc,1)
	
	g_idnpc[npc]=g_npcnum
	g_npcid[g_npcnum]=npc
	g_npcnum++
	
}
public remove_npc(id)
{
	new target
	while((target=engfunc(EngFunc_FindEntityByString,target,"classname",NPC_CLNAME))!=0)
	{
	if(pev_valid(target))
		{
			engfunc(EngFunc_RemoveEntity,target)
			g_npcid[g_idnpc[target]]=0
			g_idnpc[target]=0
			g_npcnum--
		}
	}
}


//-----------------------------------------------------------------------------//
////TASK参数
enum(+=50){
	TASK_START=100,
	TASK_SPAWN,
	TASK_SHOWHUD,
	TASK_RANDOMCRIT,
	TASK_FIRE,
	TASK_CRITICAL,
	TASK_KNIFEATTACKING,
	TASK_SNIPEPOWER,
	TASK_SNIPERRELOAD,
	TASK_KILLMSG,
	TASK_KILLMSGADD,
	TASK_ROUNDMSG,
	TASK_RESETLASTATTACK,
	TASK_UNINVISIBLE,
	TASK_INVISIBLE,
	TASK_SKILLDEALY,
	TASK_KILLSPAWN,
	TASK_BLEED,
	TASK_CALLMEDIC,
	TASK_STARTRELOAD,
	TASK_RELOADING,
	TASK_ENDRELOAD,
	TASK_FIRSTZM,
	TASK_CHECKEND,
	TASK_INIT_CREATESUPPLY,
	TASK_XUANZHUAN,
	TASK_ROUNDTIMER,
	TASK_RESET_SUPPLY,
	TASK_DISGUISE,
	TASK_BOSSCOME,
	TASK_PLAYBGM,
	TASK_HUMANSPECIAL,
	TASK_ROUNDTIMERFIX
}



//-----------------------------------------------------------------------------//
////插件核心
public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	//direction
	//register_dictionary("chickenrun_up.txt")
	register_dictionary("chickenrun_2_motd.txt")
	
	//menu
	register_menu("MENU MAIN",ALLKEYS,"ckrun_mainmenu")
	register_menu("MENU TYPE",ALLKEYS,"ckrun_typemenu")
	register_menu("MENU TEAM",ALLKEYS,"ckrun_teammenu")
	register_menu("MENU ZBTYPE",ALLKEYS,"ckrun_zbtypemenu")
	register_menu("MENU BOSSTYPE",ALLKEYS,"ckrun_bosstypemenu")
	register_menu("MENU STATUS SETUP",ALLKEYS,"ckrun_setstatusmenu")
	
	register_menu("MENU ADMIN SETUP",ALLKEYS,"ckrun_adminsetupmenu")
	register_menu("MENU SUPPLY SETUP",ALLKEYS,"ckrun_supplymenu")
	register_menu("MENU BOSS SPAWNPOINT",ALLKEYS,"ckrun_bossspawnpointmenu")
	register_menu("MENU ADMIN SKILL",ALLKEYS,"ckrun_adminskill")
	
	register_menu("MENU BUILD",(1<<0|1<<1|1<<2|1<<3|1<<9),"ckrun_buildmenu")
	register_menu("MENU DESTROY",(1<<0|1<<1|1<<2|1<<3|1<<9),"ckrun_destroymenu")
	register_menu("MENU DISGUISE",ALLKEYS,"ckrun_disguisemenu")
	
	
	//player menu
	register_menu("MENU PERSONAL",ALLKEYS,"ckrun_personalmenu")
	
	register_menu("MENU SUIT",ALLKEYS,"ckrun_suitmenu")
	//register_menu("MENU SUIT USERTYPE",ALLKEYS,"ckrun_suitmenu_usertype")
	register_menu("MENU PRIWPN",ALLKEYS,"ckrun_priwpnmenu")
	register_menu("MENU SECWPN",ALLKEYS,"ckrun_secwpnmenu")
	register_menu("MENU KNIFEWPN",ALLKEYS,"ckrun_knifewpnmenu")
	
	//Half Life Event
	register_event("HLTV","event_round_start","a","1=0","2=0")
	
	
	register_message(get_user_msgid("RoundTime"), "Message_RoundTime")
	register_message(get_user_msgid("ItemPickup"),"message_block")
	register_message(get_user_msgid("AmmoPickup"),"message_block")
	register_message(get_user_msgid("WeapPickup"),"message_block")
	register_message(get_user_msgid("DeathMsg"),"message_block")
	register_message(get_user_msgid("ClCorpse"), "message_block")
	register_message(g_msgTeamInfo, "message_teaminfo")
	register_message(get_user_msgid("Health"), "message_health")
	
	//hamsandwich&fakemeta Event
	RegisterHam(Ham_TakeDamage,"player","Ham_Takedamage")
	RegisterHam(Ham_Spawn,"player","Ham_playerspawn",1)
	RegisterHam(Ham_Touch,"weaponbox","Ham_touch")
	RegisterHam(Ham_Touch,"info_target","Ham_InfoTouch")
	RegisterHam(Ham_Touch,"player","Ham_plTouch")
	//RegisterHam(Ham_Touch,"player","Ham_PlayerTouch")
	
	//RegisterHam(Ham_Item_AttachToPlayer,"weapon_m3","Ham_WeaponCured",1)
	RegisterHam(Ham_Item_Deploy,"weapon_m3","Ham_WeaponCured",1)
	RegisterHam(Ham_Item_Holster,"weapon_m3","Ham_WeaponHolster")
	RegisterHam(Ham_Item_Deploy,"weapon_mp5navy","Ham_WeaponCured",1)
	RegisterHam(Ham_Item_Holster,"weapon_mp5navy","Ham_WeaponHolster")
	
	//RegisterHam(Ham_Item_AttachToPlayer,"weapon_p228","Ham_WeaponCured",1)
	RegisterHam(Ham_Item_Deploy,"weapon_p228","Ham_WeaponCured",1)
	RegisterHam(Ham_Item_Holster,"weapon_p228","Ham_WeaponHolster")
	RegisterHam(Ham_Item_Deploy,"weapon_deagle","Ham_WeaponCured",1)
	RegisterHam(Ham_Item_Holster,"weapon_deagle","Ham_WeaponHolster")
	
	//RegisterHam(Ham_Item_AttachToPlayer,"weapon_knife","Ham_WeaponCured",1)
	RegisterHam(Ham_Item_Deploy,"weapon_knife","Ham_WeaponCured",1)
	RegisterHam(Ham_Item_Holster,"weapon_knife","Ham_WeaponHolster")
	
	//RegisterHam(Ham_Item_AttachToPlayer,"weapon_hegrenade","Ham_WeaponCured",1)
	RegisterHam(Ham_Item_Deploy,"weapon_hegrenade","Ham_WeaponCured",1)
	RegisterHam(Ham_Item_Holster,"weapon_hegrenade","Ham_WeaponHolster")
	
	//RegisterHam(Ham_Item_AttachToPlayer,"weapon_c4","Ham_WeaponCured",1)
	RegisterHam(Ham_Item_Deploy,"weapon_c4","Ham_WeaponCured",1)
	RegisterHam(Ham_Item_Holster,"weapon_c4","Ham_WeaponHolster")
	
	register_forward(FM_ClientKill,"block_kill")
	register_forward(FM_PlayerPreThink,"Fm_prethink")
	register_forward(FM_PlayerPreThink,"Fm_sentrythink")
	register_forward(FM_PlayerPreThink,"Fm_dispenserthink")
	register_forward(FM_CmdStart,"Fm_CmdStart")
	register_forward(FM_ClientCommand,"Fm_ClientCommand")
	register_forward(FM_AddToFullPack,"Fm_AddToFullPack",1)
	register_forward(FM_StartFrame,"Fm_StartFrame")
	
	register_forward(FM_SetModel, "Fm_SetModel")
	register_forward(FM_SetClientKeyValue, "fw_SetClientKeyValue")
	register_forward(FM_ClientUserInfoChanged, "fw_ClientUserInfoChanged")
	
	OrpheuRegisterHook( OrpheuGetFunction( "SetAnimation", "CBasePlayer" ), "fw_SetAnimation", OrpheuHookPre );
	OrpheuRegisterHook( OrpheuGetFunction( "CheckWinConditions" , "CHalfLifeMultiplay" ), "fw_CheckWinConditions" );
	handleFuncResetSequenceInfo = OrpheuGetFunction( "ResetSequenceInfo", "CBaseAnimating" );
	OrpheuRegisterHook( OrpheuGetFunction( "PM_Jump" ), "Orpheu_fw_PMJump", OrpheuHookPre );
	OrpheuRegisterHook( OrpheuGetFunction( "PM_Duck" ), "Orpheu_fw_PMDuck", OrpheuHookPre );
	OrpheuRegisterHook( OrpheuGetDLLFunction( "pfnPM_Move", "PM_Move" ), "PM_Move", OrpheuHookPre );
	OrpheuRegisterHook( OrpheuGetDLLFunction( "pfnPM_Move", "PM_Move" ), "PM_Move_Post", OrpheuHookPost );
	
	register_forward(FM_GetGameDescription, "fw_GameDesc")
	
	//cmd
	register_clcmd("drop","block_drop")
	register_clcmd("jointeam","block_jointeam")	//图形菜单的。。
	register_clcmd("chooseteam","block_jointeam")	//文字菜单的、
	register_clcmd("say /create_npc","create_npc")
	register_clcmd("say /remove_npc","remove_npc")
	
	//Cvar
	cvar_normal_mul=register_cvar("ChicKenRun2_normalmul","100") //普通伤害
	cvar_minicrit_mul=register_cvar("ChicKenRun2_minicritmul","135") //迷你暴击伤害倍数
	cvar_crit_mul=register_cvar("ChicKenRun2_critmul","300") //大暴击伤害倍数
	cvar_crit_percent=register_cvar("ChicKenRun2_crit_percent","6") //大暴击几率
	
	//arena
	cvar_arenamode_gametime=register_cvar("ChicKenRun2_Arena_GameTime","750") //竞技场模式回合时间,默认300秒
	cvar_arenamode_endtime=register_cvar("ChicKenRun2_Arena_EndTime","15")
	cvar_arenamode_spawntime=register_cvar("ChicKenRun2_Arena_SpawnTime","6") //竞技场模式的重生时间,默认5秒
	cvar_arenamode_redspawnnum=register_cvar("ChicKenRun2_Arena_RedSpawnPoint","100")
	cvar_arenamode_bluespawnnum=register_cvar("ChicKenRun2_Arena_BlueSpawnPoint","100")
	
	//zb
	cvar_zombiemode_could_spawn=register_cvar("ChicKenRun2_Zombie_CouldSpawn","1") //僵尸会不会重生.默认0
	cvar_zombiemode_spawntime=register_cvar("ChicKenRun2_Zombie_SpawnTime","20") //僵尸重生时间.默认10秒
	cvar_zombiemode_starttime=register_cvar("ChicKenRun2_Zombie_StartTime","5")
	cvar_zombiemode_firstzb_time=register_cvar("ChicKenRun2_Zombie_FirstZombie_Time","20") //第一个僵尸出现的时间.默认30秒
	cvar_zombiemode_gametime=register_cvar("ChicKenRun2_Zombie_GameTime","90") //回合时间.默认60秒
	cvar_zombiemode_humannumtime=register_cvar("ChicKenRun2_Zombie_AddHumanTime","12") //每个人类加的回合时间.默认30秒
	cvar_zombiemode_endtime=register_cvar("ChicKenRun2_Zombie_EndTime","15") //僵尸模式下结束时间.默认15
	
	cvar_zombie_first_other_ndhm=register_cvar("ChicKenRun2_Zombie_First_Other_NeedHuman","12") //出现2只母体僵尸需要“玩家”的最小值
	cvar_zombie_basehp_mul=register_cvar("ChicKenRun2_Zombie_BaseHealth_Mul","4.0") //基础生命值倍数
	cvar_zombie_first_hm_num_addhp=register_cvar("ChicKenRun2_Zombie_First_AddHumanNum_Health","100")
	cvar_zombie_lvnew_dmgmul_per=register_cvar("ChicKenRun2_Zombie_LevelNew_DmgMul_Percent","100")
	cvar_zombie_lvold_dmgmul_per=register_cvar("ChicKenRun2_Zombie_LevelOld_DmgMul_Percent","150")
	cvar_zombie_lvstr_dmgmul_per=register_cvar("ChicKenRun2_Zombie_LevelStrong_DmgMul_Percent","200")
	cvar_zombie_lvsup_dmgmul_per=register_cvar("ChicKenRun2_Zombie_LevelSuper_DmgMul_Percent","300")
	
	//vs
	cvar_vsmode_starttime=register_cvar("ChicKenRun2_Vs_StartTime","5") //玩家能换兵种的时间.默认5秒
	cvar_vsmode_boss_cometime=register_cvar("ChicKenRun2_Vs_Boss_ComeTime","15") //BOSS冻结结束时间.默认7秒.这里我改13秒了
	cvar_vsmode_gametime=register_cvar("ChicKenRun2_Vs_GameTime","300") //游戏时间.默认300秒
	cvar_vsmode_endtime=register_cvar("ChicKenRun2_Vs_EndTime","15") //回合结束时间.默认15秒
	cvar_vsmode_humannumtime=register_cvar("ChicKenRun2_Vs_AddHumanTime","15") //每个人类加的回合时间.默认15秒.
	cvar_vsmode_boss_addspeedmax=register_cvar("ChicKenRun2_Vs_BossAddSpeedMax","75") //BOSSHP越少加的速度.默认75
	cvar_vsmode_boss_maxpower=register_cvar("ChicKenRun2_Vs_BossMaxPower","1900") //BOSS怒气上限
	cvar_vsmode_boss_minhppercent=register_cvar("ChicKenRun2_Vs_BossMinHealthPercent","25") //现在根本没有用到。
	
	cvar_supply_heal_small=register_cvar("ChicKenRun2_Supply_Heal_Small","25") //小血包恢复多少百分比的血量.默认25
	cvar_supply_heal_normal=register_cvar("ChicKenRun2_Supply_Heal_Normal","50") //中血包恢复多少百分比的血量.默认50
	cvar_supply_heal_big=register_cvar("ChicKenRun2_Supply_Heal_Big","100") //大血包恢复多少百分比的血量.默认100
	cvar_supply_ammo_small=register_cvar("ChicKenRun2_Supply_Ammo_Small","25") //小弹药包补充多少百分比的弹药.默认25
	cvar_supply_ammo_normal=register_cvar("ChicKenRun2_Supply_Ammo_Normal","50") //中弹药包补充多少百分比的弹药.默认50
	cvar_supply_ammo_big=register_cvar("ChicKenRun2_Supply_Ammo_Big","100") //大弹药包补充多少百分比的弹药.默认100
	cvar_supply_spawn_time=register_cvar("ChicKenRun2_Supply_Spawn_Time","10.0") //补给重生时间.默认10秒
	
	cvar_wpn_scattergun_curtime=register_cvar("CKR2_wpn_scattergun_curtime","0.7") //侦察霰弹切换出来的速度
	cvar_wpn_scattergun_shotdealy=register_cvar("CKR2_wpn_scattergun_shotdealy","0.625") //射击延迟
	cvar_wpn_scattergun_shotnum=register_cvar("CKR2_wpn_scattergun_shotnum","10") //射出的子弹数量
	cvar_wpn_scattergun_radius=register_cvar("CKR2_wpn_scattergun_radius","1.65") //散射程度
	cvar_wpn_scattergun_distance=register_cvar("CKR2_wpn_scattergun_distance","1300") //最大伤害修正距离
	cvar_wpn_scattergun_mindmgmul=register_cvar("CKR2_wpn_scattergun_mindmgmul","0.45") //最小单发伤害倍数
	cvar_wpn_scattergun_dmg=register_cvar("CKR2_wpn_scattergun_damage","11.0") //每一颗子弹的伤害
	cvar_wpn_scattergun_kb=register_cvar("CKR2_wpn_scattergun_knockback","50") //击退
	
	cvar_wpn_rpg_curtime=register_cvar("CKR2_wpn_rpg_curtime","0.7")
	cvar_wpn_rpg_shotdealy=register_cvar("CKR2_wpn_rpg_shotdealy","0.7")
	cvar_wpn_rpg_damage=register_cvar("CKR2_wpn_rpg_damage","90.0")
	cvar_wpn_rpg_ownermindamage=register_cvar("CKR2_wpn_rpg_ownermindamage","35")
	cvar_wpn_rpg_ownermaxdamage=register_cvar("CKR2_wpn_rpg_ownermaxdamage","40")
	cvar_wpn_rpg_slowvec_mul=register_cvar("CKR2_wpn_rpg_slowvec_mul","0.85")
	cvar_wpn_rpg_rocketspeed=register_cvar("CKR2_wpn_rpg_rocketspeed","720")
	cvar_wpn_rpg_timer_maxtime=register_cvar("CKR2_wpn_rpg_timer_maxtime","4.0")
	cvar_wpn_rpg_timer_minmul=register_cvar("CKR2_wpn_rpg_timer_minmul","0.7")
	cvar_wpn_rpg_explode_maxradius=register_cvar("CKR2_wpn_rpg_explode_maxradius","108.0")
	cvar_wpn_rpg_explode_minmul=register_cvar("CKR2_wpn_rpg_explode_minmul","0.62")
	cvar_wpn_rpg_expforce_ground=register_cvar("CKR2_wpn_rpg_expforce_ground","475.0")
	cvar_wpn_rpg_expforce_noground=register_cvar("CKR2_wpn_rpg_expforce_noground","425.0")
	
	cvar_wpn_pistol_curtime=register_cvar("CKR2_wpn_pistol_curtime","0.7")
	cvar_wpn_pistol_radius=register_cvar("CKR2_wpn_pistol_radius","0.5")
	cvar_wpn_pistol_dmg=register_cvar("CKR2_wpn_pistol_damage","22.0")
	cvar_wpn_pistol_distance=register_cvar("CKR2_wpn_pistol_distance","1300")
	cvar_wpn_pistol_mindmgmul=register_cvar("CKR2_wpn_pistol_mindmgmul","0.4")
	cvar_wpn_pistol_shotdealy=register_cvar("CKR2_wpn_pistol_shotdealy","0.17")
	cvar_wpn_pistol_kb=register_cvar("CKR2_wpn_pistol_knockback","25")

	
	cvar_wpn_minigun_curtime=register_cvar("CKR2_wpn_minigun_curtime","0.7")
	cvar_wpn_minigun_putdown_time=register_cvar("CKR2_wpn_minigun_putdown_time","0.8")
	cvar_wpn_minigun_putup_time=register_cvar("CKR2_wpn_minigun_putup_time","0.87")
	cvar_wpn_minigun_shotnum=register_cvar("CKR2_wpn_minigun_shotnum","3")
	cvar_wpn_minigun_radius=register_cvar("CKR2_wpn_minigun_radius","1.6")
	cvar_wpn_minigun_shotdealy=register_cvar("CKR2_wpn_minigun_shotdealy","0.085")
	cvar_wpn_minigun_dmg=register_cvar("CKR2_wpn_minigun_damage","10.5")
	cvar_wpn_minigun_distance=register_cvar("CKR2_wpn_minigun_distance","1300")
	cvar_wpn_minigun_mindmgmul=register_cvar("CKR2_wpn_minigun_mindmgmul","0.45")
	cvar_wpn_minigun_kb=register_cvar("CKR2_wpn_minigun_knockback","35.0")
	cvar_wpn_minigun_punchangle=register_cvar("CKR2_wpn_minigun_punchangle","8.0")
	
	cvar_wpn_firegun_curtime=register_cvar("CKR2_wpn_firegun_curtime","0.6")
	cvar_wpn_firegun_shotdealy=register_cvar("CKR2_wpn_firegun_shotdealy","0.08")
	cvar_wpn_firegun_flamespeed=register_cvar("CKR2_wpn_firegun_flamespeed","500")
	cvar_wpn_firegun_removetime=register_cvar("CKR2_wpn_firegun_flameremovetime","0.6")
	cvar_wpn_firegun_slowmul=register_cvar("CKR2_wpn_firegun_slowmul","0.6")
	
	cvar_wpn_medicgun_curtime=register_cvar("CKR2_wpn_medicgun_curtime","0.7")
	cvar_wpn_medicgun_maxdistance=register_cvar("CKR2_wpn_medicgun_maxdistance","255.0")
	cvar_wpn_medicgun_healdsts=register_cvar("CKR2_wpn_medicgun_healdsts","300.0")
	cvar_wpn_medicgun_overheal_c=register_cvar("CKR2_wpn_medicgun_overheal_charge","9")
	cvar_wpn_medicgun_heal_c=register_cvar("CKR2_wpn_medicgun_heal_charge","15")
	cvar_wpn_medicgun_healtime=register_cvar("CKR2_wpn_medicgun_healchecktime","0.16")
	cvar_wpn_medicgun_supercharge=register_cvar("CKR2_wpn_medicgun_supercharge","60")
	
	cvar_wpn_sniperifle_curtime=register_cvar("CKR2_wpn_sniperifle_curtime","0.7")
	cvar_wpn_sniperifle_shotdealy=register_cvar("CKR2_wpn_sniperifle_shotdealy","1.5")
	cvar_wpn_sniperifle_damage=register_cvar("CKR2_wpn_sniperifle_damage","50")
	cvar_wpn_sniperifle_kjspper=register_cvar("CKR2_wpn_sniperifle_kjspeed_per","45")
	cvar_wpn_sniperifle_maxpower=register_cvar("CKR2_wpn_sniperifle_maxpower","100")
	cvar_wpn_sniperifle_powerwait=register_cvar("CKR2_wpn_sniperifle_powerwaittime","1.5")
	cvar_wpn_sniperifle_powerspeed=register_cvar("CKR2_wpn_sniperifle_powerspeed","0.025")
	cvar_wpn_sniperifle_kb=register_cvar("CKR2_wpn_sniperifle_knockback","150.0")
	
	cvar_wpn_smg_curtime=register_cvar("CKR2_wpn_smg_curtime","0.7")
	
	cvar_wpn_shotgun_curtime=register_cvar("CKR2_wpn_shotgun_curtime","0.6")
	
	cvar_wpn_grenadelaunch_curtime=register_cvar("CKR2_wpn_grenadelauncher_curtime","0.7")
	
	cvar_wpn_stickylauncher_curtime=register_cvar("CKR2_wpn_stickylauncher_curtime","0.7")
	cvar_wpn_stickylauncher_shotdl=register_cvar("CKR2_wpn_stickylauncher_ShotDealy","0.67")
	cvar_wpn_stickylauncher_maxdmg=register_cvar("CKR2_wpn_stickylauncher_MaxDamage","128")
	cvar_wpn_stickylauncher_radius=register_cvar("CKR2_wpn_stickylauncher_Radius","118.0")
	cvar_wpn_stickylauncher_minmul=register_cvar("CKR2_wpn_stickylauncher_Damage_MinMul","0.55")
	cvar_wpn_stickylauncher_slowvec=register_cvar("CKR2_wpn_stickylauncher_SlowVec","0.85")
	cvar_wpn_stickylauncher_zjxdmg=register_cvar("CKR2_wpn_stickylauncher_MinDamage_self","60")
	cvar_wpn_stickylauncher_zjddmg=register_cvar("CKR2_wpn_stickylauncher_MaxDamage_self","65")
	cvar_wpn_stickylauncher_speed=register_cvar("CKR2_wpn_stickylauncher_BombSpeed","750")
	cvar_wpn_stickylauncher_bombrd=register_cvar("CKR2_wpn_stickylauncher_BombReadytime","0.8")
	cvar_wpn_stickylauncher_health=register_cvar("CKR2_wpn_stickylauncher_BombHealth","25")
	cvar_wpn_stickylauncher_dpower=register_cvar("CKR2_wpn_stickylauncher_MaxPower","750")
	cvar_wpn_stickylauncher_ground=register_cvar("CKR2_wpn_stickylauncher_force_ground","475.0")
	cvar_wpn_stickylauncher_uground=register_cvar("CKR2_wpn_stickylauncher_force_unground","425.0")
	cvar_wpn_stickylauncher_strelo=register_cvar("CKR2_wpn_stickylauncher_StartReloadTime","0.3")
	cvar_wpn_stickylauncher_inrelo=register_cvar("CKR2_wpn_stickylauncher_InReloadTime","0.65")
	cvar_wpn_stickylauncher_endrelo=register_cvar("CKR2_wpn_stickylauncher_EndReloadTime","0.3")
	cvar_wpn_stickylauncher_maxnum=register_cvar("CKR2_wpn_stickylauncher_BombMaxNum","8")
	
	cvar_wpn_revolver_curtime=register_cvar("CKR2_wpn_revolver_curtime","0.7")
	
	cvar_wpn_assdeagle_curtime=register_cvar("CKR2_wpn_assdeagle_curtime","0.6")
	
	cvar_wpn_sapper_curtime=register_cvar("CKR2_wpn_sapper_curtime","0.5")
	
	cvar_wpn_bat_curtime=register_cvar("CKR2_wpn_bat_curtime","0.5")
	
	cvar_wpn_fist_curtime=register_cvar("CKR2_wpn_fist_curtime","0.5")
	
	cvar_wpn_shovel_curtime=register_cvar("CKR2_wpn_shovel_curtime","0.5")
	
	cvar_wpn_fireaxe_curtime=register_cvar("CKR2_wpn_fireaxe_curtime","0.5")
	
	cvar_wpn_machete_curtime=register_cvar("CKR2_wpn_machete_curtime","0.5")
	
	cvar_wpn_syringegun_curtime=register_cvar("CKR2_wpn_syringegun_curtime","0.7")
	
	cvar_wpn_bonesaw_curtime=register_cvar("CKR2_wpn_bonesaw_curtime","0.5")
	
	cvar_wpn_wrench_curtime=register_cvar("CKR2_wpn_wrench_curtime","0.5")
	
	cvar_wpn_bottle_curtime=register_cvar("CKR2_wpn_bottle_curtime","0.5")
	
	cvar_wpn_butterfly_curtime=register_cvar("CKR2_wpn_butterfly_curtime","0.5")
	
	cvar_sentry_rocketdamage=register_cvar("CKR2_build_rocketdamage","158")
	cvar_sentry_rocketspeed=register_cvar("CKR2_build_rocketspeed","1080")
	
	
	//array
	extra_item_num=0
	item_id=ArrayCreate(1,1)			//物品的序列号
	item_english_name=ArrayCreate(32,1)		//物品英文名称
	item_chinese_name=ArrayCreate(32,1)		//物品中文名称
	
	item_type=ArrayCreate(1,1)
	item_usertype=ArrayCreate(1,1)
	item_weaponslot=ArrayCreate(1,1)
	item_wpnmaxclip=ArrayCreate(1,1)
	item_wpnmaxammo=ArrayCreate(1,1)
	
	
	//forward
	
	g_fwRoundStart = CreateMultiForward("ckr_FW_RoundStart",ET_IGNORE)
	g_fwRoundEnd = CreateMultiForward("ckr_FW_RoundEnd",ET_IGNORE,FP_CELL)
	g_fwPlayerHurt_Pre = CreateMultiForward("ckr_FW_TakeDamage_Pre",ET_IGNORE,FP_CELL,FP_CELL,FP_CELL,FP_CELL,FP_CELL,FP_CELL,FP_CELL,FP_CELL,FP_CELL)
	g_fwPlayerHurt_Post = CreateMultiForward("ckr_FW_TakeDamage_Post",ET_IGNORE,FP_CELL,FP_CELL,FP_CELL,FP_CELL,FP_CELL,FP_CELL,FP_CELL,FP_CELL,FP_CELL)
	g_fwPlayerKilled = CreateMultiForward("ckr_FW_Killed",ET_IGNORE,FP_CELL,FP_CELL,FP_CELL,FP_CELL,FP_CELL,FP_CELL)
	g_fwPlayerBeHealedPer_Pre = CreateMultiForward("ckr_FW_HealedPer_Pre",ET_IGNORE,FP_CELL,FP_CELL)
	g_fwPlayerBeHealedPer_Post = CreateMultiForward("ckr_FW_HealedPer_Post",ET_IGNORE,FP_CELL,FP_CELL)
	g_fwPlayerBeHealedNum_Pre = CreateMultiForward("ckr_FW_HealedNum_Pre",ET_IGNORE,FP_CELL,FP_CELL,FP_CELL)
	g_fwPlayerBeHealedNum_Post = CreateMultiForward("ckr_FW_HealedNum_Post",ET_IGNORE,FP_CELL,FP_CELL,FP_CELL)
	g_fwPlayerAddAmmoPer_Pre = CreateMultiForward("ckr_FW_PlayerAddAmmoPer_Pre",ET_IGNORE,FP_CELL,FP_CELL)
	g_fwPlayerAddAmmoPer_Post = CreateMultiForward("ckr_FW_PlayerAddAmmoPer_Post",ET_IGNORE,FP_CELL,FP_CELL)
	g_fwPlayerAddMetalPer_Pre = CreateMultiForward("ckr_FW_PlayerAddMetalPer_Pre",ET_IGNORE,FP_CELL,FP_CELL)
	g_fwPlayerAddMetalPer_Post = CreateMultiForward("ckr_FW_PlayerAddMetalPer_Post",ET_IGNORE,FP_CELL,FP_CELL)
	g_fwPlayerAddMetalNum_Pre = CreateMultiForward("ckr_FW_PlayerAddMetalNum_Pre",ET_IGNORE,FP_CELL,FP_CELL)
	g_fwPlayerAddMetalNum_Post = CreateMultiForward("ckr_FW_PlayerAddMetalNum_Post",ET_IGNORE,FP_CELL,FP_CELL)

	g_fwPlayerKnockBack_Pre = CreateMultiForward("ckr_FW_PlayerKnockBack_Pre",ET_IGNORE,FP_CELL,FP_CELL,FP_STRING,FP_CELL)
	g_fwPlayerKnockBack_Post = CreateMultiForward("ckr_FW_PlayerKnockBack_Pre",ET_IGNORE,FP_CELL,FP_CELL,FP_STRING,FP_CELL)
	g_fwPlayerSlowVec_Pre = CreateMultiForward("ckr_FW_PlayerSlowVec_Pre",ET_IGNORE,FP_CELL,FP_CELL,FP_FLOAT,FP_CELL,FP_CELL)
	g_fwPlayerSlowVec_Post = CreateMultiForward("ckr_FW_PlayerSlowVec_Post",ET_IGNORE,FP_CELL,FP_CELL,FP_FLOAT,FP_CELL,FP_CELL)
	g_fwPlayerExplode_Pre = CreateMultiForward("ckr_FW_PlayerExplode_Pre",ET_IGNORE,FP_CELL,FP_STRING,FP_FLOAT,FP_CELL)
	g_fwPlayerExplode_Post = CreateMultiForward("ckr_FW_PlayerExplode_Post",ET_IGNORE,FP_CELL,FP_STRING,FP_FLOAT,FP_CELL)

	g_fwPlayerBeFired_Pre = CreateMultiForward("ckr_FW_PlayerBeFired_Pre",ET_IGNORE,FP_CELL,FP_CELL,FP_CELL,FP_CELL,FP_CELL,FP_CELL)
	g_fwPlayerBeFired_Post = CreateMultiForward("ckr_FW_PlayerBeFired_Post",ET_IGNORE,FP_CELL,FP_CELL,FP_CELL,FP_CELL,FP_CELL,FP_CELL)

	g_fwPlayerDisFired_Pre = CreateMultiForward("ckr_FW_PlayerAddMetalNum_Pre",ET_IGNORE,FP_CELL,FP_CELL)
	g_fwPlayerDisFired_Post = CreateMultiForward("ckr_FW_PlayerAddMetalNum_Post",ET_IGNORE,FP_CELL,FP_CELL)

	g_fwResetVar_Pre = CreateMultiForward("ckr_FW_ResetVar_Pre",ET_IGNORE,FP_CELL)
	g_fwResetVar_Post = CreateMultiForward("ckr_FW_ResetVar_Post",ET_IGNORE,FP_CELL)
	g_fwGivePriWpn = CreateMultiForward("ckr_FW_GivePriWpn",ET_IGNORE,FP_CELL,FP_CELL)
	g_fwGiveSecWpn = CreateMultiForward("ckr_FW_GiveSecWpn",ET_IGNORE,FP_CELL,FP_CELL)
	g_fwGiveKnifeWpn = CreateMultiForward("ckr_FW_GiveKnifeWpn",ET_IGNORE,FP_CELL,FP_CELL)
	g_fwPlayerSpawn = CreateMultiForward("ckr_FW_PlayerSpawn",ET_IGNORE,FP_CELL)
	g_fwBuild_Pre = CreateMultiForward("ckr_FW_Build_Pre",ET_IGNORE,FP_CELL,FP_CELL)
	g_fwBuild_Post = CreateMultiForward("ckr_FW_Build_Post",ET_IGNORE,FP_CELL,FP_CELL)
	g_fwBuildingDestroy_Pre = CreateMultiForward("ckr_FW_Building_Destroy_Pre",ET_IGNORE,FP_CELL,FP_CELL,FP_CELL)
	g_fwBuildingDestroy_Post = CreateMultiForward("ckr_FW_Building_Destroy_Post",ET_IGNORE,FP_CELL,FP_CELL,FP_CELL)
	g_fwPutSapperInBuilding_pre = CreateMultiForward("ckr_FW_PutSapperInBuilding_pre",ET_IGNORE,FP_CELL,FP_CELL,FP_CELL)
	g_fwPutSapperInBuilding_post = CreateMultiForward("ckr_FW_PutSapperInBuilding_post",ET_IGNORE,FP_CELL,FP_CELL,FP_CELL)
	g_fwWeaponCur_Pre = CreateMultiForward("ckr_FW_WeaponCur_Pre",ET_IGNORE,FP_CELL,FP_CELL,FP_CELL)
	g_fwWeaponCur_Post = CreateMultiForward("ckr_FW_WeaponCur_Post",ET_IGNORE,FP_CELL,FP_CELL,FP_CELL)
	g_fwWeaponHolster_Pre = CreateMultiForward("ckr_FW_WeaponHolster_Pre",ET_IGNORE,FP_CELL,FP_CELL)
	g_fwWeaponHolster_Post = CreateMultiForward("ckr_FW_WeaponHolster_Post",ET_IGNORE,FP_CELL,FP_CELL)
	g_fwKnifeAttacking = CreateMultiForward("ckr_FW_KnifeAttacking",ET_IGNORE,FP_CELL)
	
	new Float:empty[3],empty2[64]
	
	for(new i;i<10;i++)
	{
		forward_change_num[i]=-1
		forward_change_float[i]=-1.0
		forward_change_vectype[i]=empty
		forward_change_string[i]=empty2
	}
	
	
	
	set_task(3.0,"func_update_hudmsg",TASK_KILLMSG)
	set_task(3.0,"func_addkillmsg",TASK_KILLMSGADD)
	set_task(1.0,"func_update_roundstatus",TASK_ROUNDMSG)
	
	set_task(5.0,"func_nativeitem_get")
	
	g_maxplayer=get_maxplayers()
	new mapname[32]
	get_mapname(mapname,31)
	if(equali(mapname,"ckr2_",5))
		g_gamemode=gamemode_arena
	else if(equali(mapname,"ckr2cp_",7))
		g_gamemode=gamemode_cp
	else if(equali(mapname,"ckr2zb_",7))
		g_gamemode=gamemode_zombie
	else if(equali(mapname,"ckr2sub_",8))
		g_gamemode=gamemode_human_subsist
	else if(equali(mapname,"ckr2vs_",7))
	{
		g_gamemode=gamemode_vsasb
		load_bossspawnpoint_file()
	}
	else if(equali(mapname,"ckr2scp_",8))
		g_gamemode=gamemode_scp
	else
		g_gamemode=gamemode_arena
		
	
	putsupply=0
	load_supply_file()
	
	new Float:time=0.2
	for(new i;i<putsupply;i++)
	{
		new param[6]
		param[0]=supply_status[i][supplyorg_x]
		param[1]=supply_status[i][supplyorg_y]
		param[2]=supply_status[i][supplyorg_z]
		param[3]=supply_status[i][supplytype]
		param[4]=supply_status[i][supplysize]
		param[5]=i
				
		set_task(time,"ckrun_create_item",TASK_INIT_CREATESUPPLY,param,6)
		time+=0.2
		
	}
	
	
	
	g_msgTeamInfo = get_user_msgid("TeamInfo")
	g_msgScoreInfo = get_user_msgid("ScoreInfo")
	g_msgRoundTime = get_user_msgid("RoundTime")
	g_msgStatusText = get_user_msgid("StatusText")
	g_msgStatusValue = get_user_msgid("StatusValue")
	
	set_msg_block(g_msgStatusText, BLOCK_SET)
	set_msg_block(g_msgStatusValue, BLOCK_SET)
	
	
	set_task(1.0, "Round_Timer", TASK_ROUNDTIMER)
	set_task(20.0, "Round_Timer_Fix", TASK_ROUNDTIMERFIX)
	
	
	server_cmd("sv_maxspeed 645")
	server_cmd("sv_maxvelocity 10000")
	server_cmd("mp_autoteambalance 0")
	server_cmd("sv_proxies 1")
	
	
}
//-----------------------------------------------------------------------------//
//-----------------------------------------------------------------------------//
//-----------------------------------------------------------------------------//
//-----------------------------------------------------------------------------//

new register_prinum[11],register_secnum[11],register_knifenum[11]

public func_nativeitem_get()
{
	for(new i;i < extra_item_num;i++)
	{
		if(ArrayGetCell(item_type,i)==item_weapon)
		{
			new usertype = ArrayGetCell(item_usertype,i)
			switch(ArrayGetCell(item_weaponslot,i))
			{
				case itemwpn_primary:
				{
					WeaponMenu_Pri_WpnIndex[usertype][register_prinum[usertype]]=i
					format(WeaponMenu_Pri_WpnName[usertype][register_prinum[usertype]],31,"%a",ArrayGetStringHandle(item_chinese_name,i))
					register_prinum[usertype]++
				}
				case itemwpn_secondry:
				{
					WeaponMenu_Sec_WpnIndex[usertype][register_secnum[usertype]]=i
					format(WeaponMenu_Sec_WpnName[usertype][register_secnum[usertype]],31,"%a",ArrayGetStringHandle(item_chinese_name,i))
					register_secnum[usertype]++
				}
				case itemwpn_knife:
				{
					WeaponMenu_Knife_WpnIndex[usertype][register_knifenum[usertype]]=i
					format(WeaponMenu_Knife_WpnName[usertype][register_knifenum[usertype]],31,"%a",ArrayGetStringHandle(item_chinese_name,i))
					register_knifenum[usertype]++
				}
			}
		}
	}
}



//-----------------------------------------------------------------------------//
public event_round_start()
{
	g_roundstatus=round_start //回合开始
	
	client_print(0,print_chat,"【叶风CS】欢迎来到小鸡快跑2服务器") //发给客户端的信息.
	client_print(0,print_chat,"小鸡要塞2服务器IP:game.gmodcn.com:27015")
	client_print(0,print_chat,"小鸡快跑2官方QQ群:202739921")
	
	
	for(new i = 1;i <= g_maxplayer;i++)
	{
		ckrun_destroy_sentry(i,i)
		ckrun_destroy_dispenser(i,i)
	}
	
	switch(g_gamemode)
	{
		case gamemode_arena:
		{
			g_roundstatus=round_ready		
			
			TeamSpawn_Num[team_red]=get_pcvar_num(cvar_arenamode_redspawnnum)
			TeamSpawn_Num[team_blue]=get_pcvar_num(cvar_arenamode_bluespawnnum)

			remove_task(TASK_START)
			set_task(2.0,"event_roundbegin",TASK_START)
		}
		case gamemode_cp:
		{
			
		}
		case gamemode_zombie:
		{
			firstzombie[1]=0
			firstzombie[2]=0
			human_hero[0]=0
			human_special[0]=0
			firstzmcome_second=get_pcvar_num(cvar_zombiemode_firstzb_time)
			humanspecialcome_second=30
			g_roundtime=get_pcvar_num(cvar_zombiemode_starttime)
			FX_ChangeRoundTime(g_roundtime)
			
			for(new i = 1;i <= g_maxplayer;i++)
			{
				if(pev_valid(i) && is_user_connected(i) && !first_playgame[i])
				{
					play_mp3(i,snd_zb_startgame)
					fm_set_user_team(i,gteam[i],0)
					//g_roundscore[i]=0
					g_takedamage[i]=0
					g_roundtakedamage[i]=0
					g_bedamage[i]=0
					g_roundbedamage[i]=0
					FX_UpdateScore(i)
					
					gzombielevel[i]=level_new
					gzombielevelnum[i]=0
					
					ghuman_armornum[i]=0
					
					cs_set_user_money(i,0,0)
				}
			
			}
			
			remove_task(TASK_FIRSTZM)
			remove_task(TASK_START)
			set_task(get_pcvar_float(cvar_zombiemode_starttime),"event_roundbegin",TASK_START)
			remove_task(TASK_HUMANSPECIAL)
			
			engfunc(EngFunc_LightStyle, 0, "e")
			
		}
		case gamemode_vsasb:
		{
			
			Boss=0
			Boss_fuckpower=0
			Boss_maxfuckpower=get_pcvar_num(cvar_vsmode_boss_maxpower)
			Boss_changeknife=0
			Bosscome_second=get_pcvar_num(cvar_vsmode_boss_cometime)
			g_roundtime=get_pcvar_num(cvar_vsmode_starttime)
			FX_ChangeRoundTime(g_roundtime)
			
			for(new i = 1;i <= g_maxplayer;i++)
			{
				if(pev_valid(i) && is_user_connected(i) && !first_playgame[i])
				{
					//play_mp3(i,snd_vs_startgame)
					stop_mp3(i)
					fm_set_user_team(i,gteam[i],0)
					//g_roundscore[i]=0
					g_takedamage[i]=0
					g_roundtakedamage[i]=0
					g_bedamage[i]=0
					g_roundbedamage[i]=0
					FX_UpdateScore(i)
					
					cs_set_user_money(i,0,0)
					Boss_lunliudian[i]++
				}
			
			}
			
			remove_task(TASK_BOSSCOME)
			remove_task(TASK_START)
			set_task(get_pcvar_float(cvar_vsmode_starttime),"event_roundbegin",TASK_START)
			
		}
		case gamemode_human_subsist:
		{
			
		}
	}
	
	for(new i;i < sizeof g_round_remove;i++)
	{
		new target
		while((target=engfunc(EngFunc_FindEntityByString,target,"classname",g_round_remove[i]))!=0)
		{
			if(pev(target,pev_temp)==1)
			{
				remove_task(target)
				engfunc(EngFunc_RemoveEntity,target)
			}
		}
	}
	
	
	remove_task(TASK_CHECKEND)
	set_task(2.0,"func_checkend",TASK_CHECKEND)
	
	ExecuteForward(g_fwRoundStart,g_fwResult)
	
}
public event_roundbegin()
{
	switch(g_gamemode)
	{
		case gamemode_arena:
		{
			g_roundstatus=round_running
			
			g_roundtime=get_pcvar_num(cvar_arenamode_gametime)
			FX_ChangeRoundTime(g_roundtime)
			
		}
		case gamemode_cp:
		{
			
		}
		case gamemode_zombie:
		{
			if(ckrun_get_humannum_alive()<2)
			{
				client_print(0,print_center,"等待其他玩家加入......")
				remove_task(TASK_START)
				set_task(get_pcvar_float(cvar_zombiemode_starttime),"event_roundbegin",TASK_START)
			}else{
				g_roundstatus=round_ready
				
				for(new i = 1;i < g_maxplayer;i++)
				{
					if(pev_valid(i))
						play_mp3(i,snd_zb_readybgm)
				
				}
				client_print(0,print_center,"游戏开始")//...%d秒后将出现第一只僵尸",firstzmcome_second)
				
				remove_task(TASK_FIRSTZM)
				set_task(1.0,"event_firstzmcometimecheck",TASK_FIRSTZM)
			}
			g_roundtime=firstzmcome_second
			FX_ChangeRoundTime(g_roundtime)
		}
		case gamemode_human_subsist:
		{
			
		}
		case gamemode_vsasb:
		{
			if(ckrun_get_humannum_alive()<2)
			{
				client_print(0,print_center,"VSBOSS模式中最少2个人才能开始游戏。")
				remove_task(TASK_START)
				set_task(get_pcvar_float(cvar_vsmode_starttime),"event_roundbegin",TASK_START)
			}else{
				g_roundstatus=round_ready
				
				new name[32]
				event_bosscome()
				
				if(bossspawnpoint_num>0)
				{
					new Float:teletoorigin[3],whatthefuck = random_num(0,bossspawnpoint_num - 1)
					
					if(bossspawnpoint_status[whatthefuck][0]!=0 || bossspawnpoint_status[whatthefuck][1]!=0 || bossspawnpoint_status[whatthefuck][2]!=0)
					{
						teletoorigin[0]=float(bossspawnpoint_status[whatthefuck][0])
						teletoorigin[1]=float(bossspawnpoint_status[whatthefuck][1])
						teletoorigin[2]=float(bossspawnpoint_status[whatthefuck][2])
					}
					
					set_pev(Boss,pev_origin,teletoorigin)
					
				}
				
				get_user_name(Boss,name,31)
				client_print(0,print_chat,"")
				client_print(0,print_chat,"")
				client_print(0,print_chat,"")
				client_print(0,print_chat,"")
				client_print(0,print_center,"Boss出现了,他的名字是%s,拥有%d生命!",name,get_user_health(Boss))
				client_print(Boss,print_chat,"[技能]怒气值满时按G释放技能(怒气值显示在护甲上)")
				func_update_hudmsg()
				
				new param[5]
				for(new i = 1;i <= g_maxplayer;i++)
				{
					if(pev_valid(i))
					{
						param[0]=i
						param[1]=gamemode_vsasb
						param[2]=round_ready
						param[3]=gboss[Boss]
						func_playgamebgm(param)
					}
				}
				
				FX_UpdateScore(Boss)
				
				spawn_godmodetime[Boss]=99999.0
				
				event_bosscomecheck()
				
				
			}

			g_roundtime=Bosscome_second+1
			FX_ChangeRoundTime(g_roundtime)
		}
	}
	
	
}

public event_firstzmcometimecheck()
{
	if(ckrun_get_humannum_alive()<1)
	{
		server_cmd("sv_restartround 3")
		return;
	}
	
	firstzmcome_second--
	if(firstzmcome_second<=0 && ckrun_get_humannum_alive()>0)
	{
		new name[32]
		event_firstzombie()
		
		get_user_name(firstzombie[1],name,31)
		client_print(0,print_center,"第一只僵尸是%s",name)
		func_update_hudmsg()
		
		FX_UpdateScore(firstzombie[1])
		
		g_roundtime=get_pcvar_num(cvar_zombiemode_gametime)+get_pcvar_num(cvar_zombiemode_humannumtime)*ckrun_get_humannum_alive()
		FX_ChangeRoundTime(g_roundtime)
		
		g_roundstatus=round_running
		
		remove_task(TASK_HUMANSPECIAL)
		set_task(3.0,"event_specialcometimecheck",TASK_HUMANSPECIAL)
		
		return;
	}
	client_print(0,print_center,"%d秒后将出现第一只僵尸",firstzmcome_second)
	
	remove_task(TASK_FIRSTZM)
	set_task(1.0,"event_firstzmcometimecheck",TASK_FIRSTZM)
}
public event_firstzombie()
{
	new id = random_num(1,g_maxplayer)
	if(is_user_alive(id) && ckrun_get_zombienum() ==0  && is_user_connected(id) && !first_playgame[id])
	{
		firstzombie[1]=id
		gzombielevel[id]=level_old
		ckrun_set_user_zombie(id)
		for(new i = 1;i <= g_maxplayer;i++)
		{
			if(pev_valid(i))
				play_mp3(i,snd_zb_gamestartbgm)
			if(!giszm[i] && is_user_connected(i) && !first_playgame[i])
				fm_set_user_team(i,team_red,0)
		}

		if(ckrun_get_humannum_alive()+1 >= get_pcvar_num(cvar_zombie_first_other_ndhm))
		{
			new stop = 0
			for(new i;i < 72;i++)
			{
				if(!stop)
				{
					id = random_num(1,g_maxplayer)
					if(!giszm[id] && is_user_alive(id) && is_user_alive(firstzombie[1]) && is_user_connected(id) && !first_playgame[id])
					{
						firstzombie[2]=id
						gzombielevel[id]=level_old
						ckrun_set_user_zombie(id)
						
						stop=1
					}
				}
			}
		}
		
		
		
	}
		
	if(!firstzombie[1])
		event_firstzombie()
}
public event_specialcometimecheck()
{
	if(ckrun_get_humannum_alive()<1 || human_special[0]!=0)
	{
		return;
	}
	
	humanspecialcome_second--
	if(humanspecialcome_second<=0 && ckrun_get_humannum_alive()>0 && human_special[0]==0)
	{
		new name[32]
		event_humanspecial()
		
		get_user_name(human_special[0],name,31)
		client_print(0,print_center,"%s已成为了人类领袖",name)
		func_update_hudmsg()
		
		FX_UpdateScore(human_special[0])
		
		
		
		return;
	}
	client_print(0,print_center,"距离人类领袖抵达战场还有%d秒",humanspecialcome_second)
	
	remove_task(TASK_HUMANSPECIAL)
	set_task(1.0,"event_specialcometimecheck",TASK_HUMANSPECIAL)
}
public event_humanspecial()
{
	new id = random_num(1,g_maxplayer)
	if(is_user_alive(id) && !human_special[0] && is_user_connected(id) && !first_playgame[id])
	{
		ckrun_set_user_special(id)
	}
		
	if(!human_special[0])
		event_humanspecial()
}
public event_bosscomecheck()
{
	new param[5]
	if(Bosscome_second <= 0)
	{
		spawn_godmodetime[Boss]=get_gametime()
		
		g_roundtime=get_pcvar_num(cvar_vsmode_gametime)+get_pcvar_num(cvar_vsmode_humannumtime)*(ckrun_get_playernum_alive()-1)
		FX_ChangeRoundTime(g_roundtime)
		g_roundstatus=round_running
		
		for(new i = 1;i <= g_maxplayer;i++)
		{
			if(pev_valid(i))
			{
				switch(random_num(1,3))
				{
					case 3:
					{
						play_mp3(i,snd_ano_start_3)
					}
					case 2:
					{
						play_mp3(i,snd_ano_start_2)
					}
					case 1:
					{
						play_mp3(i,snd_ano_start_1)
					}
				}
				param[0]=i
				param[1]=gamemode_vsasb
				param[2]=round_running
				param[3]=gboss[Boss]
				remove_task(i+TASK_PLAYBGM)
				set_task(3.0,"func_playgamebgm",i+TASK_PLAYBGM,param,5)
			}
		}
		
		client_print(0,print_center,"Boss已解除冻结！")
		
		Bosscome_second=0
		return;
	}
	
	client_print(0,print_center,"距离Boss解除冻结还有%d秒",Bosscome_second)
	Bosscome_second--
	
	remove_task(TASK_BOSSCOME)
	set_task(1.0,"event_bosscomecheck",TASK_BOSSCOME)
}
public event_bosscome()
{
	new point,id,bool:ok=false
	for(new i = 1;i < g_maxplayer;i++)
	{
		if(is_user_alive(i) && !Boss && is_user_connected(i) && !first_playgame[i])
		{
			if(Boss_lunliudian[i]>point)
			{
				point=Boss_lunliudian[i]
				id=i
				ok=true
			}
			else if(Boss_lunliudian[i]==point)
			{
				if(random_num(0,1)==1)
				{
					point=Boss_lunliudian[i]
					id=i
					ok=true
				}
			}
			
		}
	}
	if(ok)
	{
		ckrun_set_user_boss(id)
		Boss_lunliudian[id]=0
		for(new i = 1;i <= g_maxplayer;i++)
		{
			if(Boss != i && is_user_connected(i) && !first_playgame[i])
			fm_set_user_team(i,team_red,0)
		}
	}else{
		event_bosscome()
	}
}

public func_playgamebgm(param[])//0=id 1=mode 2=roundtype 3=bgmtype
{
	new id = param[0],mode = param[1],roundtype = param[2],bgmtype = param[3]
	
	switch(mode)
	{
		case gamemode_arena:
		{
			switch(roundtype)
			{
				case round_start:
				{
					
				}
				case round_ready:
				{
					
				}
				case round_running:
				{
					
				}
				case round_end:
				{
					
				}
			}
		}
		case gamemode_zombie:
		{
			switch(roundtype)
			{
				case round_start:
				{
					
				}
				case round_ready:
				{
					
				}
				case round_running:
				{
					
				}
				case round_end:
				{
					
				}
			}
		}
		case gamemode_vsasb:
		{
			switch(roundtype)
			{
				case round_start:
				{
					
				}
				case round_ready:
				{
					switch(bgmtype)
					{
						case boss_cbs:
						{
							play_mp3(id,snd_vs_CBS_start)
						}
						case boss_scp173:
						{
							play_mp3(id,snd_vs_SCP173_start)
						}
						case boss_creeper:
						{
							play_mp3(id,snd_vs_creeper_start)
						}
					}
				}
				case round_running:
				{
					switch(bgmtype)
					{
						case boss_cbs:
						{
							play_mp3(id,snd_vs_CBS_gamebgm)
						}
						case boss_scp173:
						{
							play_mp3(id,snd_vs_SCP173_gamebgm)
						}
					}
				}
				case round_end:
				{
					switch(lastwinteam)
					{
						case win_human:
						{
							switch(bgmtype)
							{
								case boss_cbs:play_mp3(id,snd_vs_CBS_humanwin)
								case boss_scp173:play_mp3(id,snd_vs_SCP173_humanwin)
							}
						}
						case win_boss:
						{
							switch(bgmtype)
							{
								case boss_cbs:play_mp3(id,snd_vs_CBS_humanfailed)
								case boss_scp173:play_mp3(id,snd_vs_SCP173_humanfailed)
							}
						}
					}
				}
			}
		}
	}
}
public func_checkend()
{
	switch(g_gamemode)
	{
		case gamemode_arena:
		{
			if(g_roundstatus == round_running)
			{
				if(!g_roundtime)
				{
					if(TeamSpawn_Num[team_red]>TeamSpawn_Num[team_blue])
					{
						event_round_end(win_red)
					}
					else if(TeamSpawn_Num[team_red]<TeamSpawn_Num[team_blue])
					{
						event_round_end(win_blue)
					}
					else{
						event_round_end(win_none)
					}
				}else{
					if(!TeamSpawn_Num[team_red]&&!TeamSpawn_Num[team_blue])
					{
						event_round_end(win_none)
					}else{
						if(!TeamSpawn_Num[team_red])
						{
							event_round_end(win_blue)
						}
						else if(!TeamSpawn_Num[team_blue])
						{
							event_round_end(win_red)
						}
					}
					
				}
			}
		}
		case gamemode_zombie:
		{
			new hm,zm
			hm=ckrun_get_humannum_alive()
			zm=ckrun_get_zombienum_alive()
			
			if(g_roundstatus == round_running)
			{
				if(!g_roundtime)
				{
					if(hm > 0 && zm > 0)
					{
						event_round_end(win_human)
					}
					else if(hm <=0 && zm > 0)
					{
						event_round_end(win_zombie)
					}
					else if(hm <=0 && zm <= 0)
					{
						event_round_end(win_none)
					}
				}else{
					if(hm > 0 && zm <=0)
					{
						event_round_end(win_human)
					}
					else if(hm <=0 && zm > 0)
					{
						event_round_end(win_zombie)
					}
					else if(hm <=0 && zm <= 0)
					{
						event_round_end(win_none)
					}
				}
			}
		}
		case gamemode_vsasb:
		{
			new aliveplayernum = ckrun_get_playernum_alive()
			
			if(g_roundstatus == round_running)
			{
				if(!g_roundtime)
				{
					if(!is_user_alive(Boss) && Boss > 0)
					{
						if(aliveplayernum>0)
						{
							event_round_end(win_human)
						}else{
							event_round_end(win_none)
						}
					}
					else if(is_user_alive(Boss) && Boss > 0)
					{
						if(aliveplayernum>1)
						{
							event_round_end(win_human)
						}else{
							event_round_end(win_boss)
						}
					}
				}else{
					if(!is_user_alive(Boss) && Boss > 0)
					{
						if(aliveplayernum>0)
						{
							event_round_end(win_human)
						}else{
							event_round_end(win_none)
						}
					}
					else if(is_user_alive(Boss) && Boss > 0)
					{
						if(aliveplayernum==1)
						{
							event_round_end(win_boss)
						}
					}
				}
			}
		}
	}
	
	remove_task(TASK_CHECKEND)
	set_task(2.0,"func_checkend",TASK_CHECKEND)
}
public Round_Timer()
{
	g_roundtime--
	if(g_roundtime <= 0)
		g_roundtime=0
		
	switch(g_gamemode)
	{
		case gamemode_zombie,gamemode_vsasb:
		{
			switch(g_roundstatus)
			{
				case round_ready,round_running:
				{
					for(new i = 1;i <= g_maxplayer;i++)
					{
						if(pev_valid(i))
						{
							switch(g_roundtime)
							{
								case 5:
								{
									play_mp3(i,snd_ano_ends_5sec)
								}
								case 4:
								{
									play_mp3(i,snd_ano_ends_4sec)
								}
								case 3:
								{
									play_mp3(i,snd_ano_ends_3sec)
								}
								case 2:
								{
									play_mp3(i,snd_ano_ends_2sec)
								}
								case 1:
								{
									play_mp3(i,snd_ano_ends_1sec)
								}
							}
						}
					}
				}
			}
		}
	}
	
	
	remove_task(TASK_ROUNDTIMER)
	set_task(1.0, "Round_Timer", TASK_ROUNDTIMER)
}
public Round_Timer_Fix()
{
	FX_ChangeRoundTime(g_roundtime)
	
	remove_task(TASK_ROUNDTIMERFIX)
	set_task(20.0, "Round_Timer_Fix", TASK_ROUNDTIMERFIX)
}
public Message_RoundTime(msg_id, msg_dest, id)
{
	if(get_msg_arg_int(1))
	{
		switch(g_roundstatus)
		{
			case round_end: set_msg_arg_int(1, ARG_SHORT, 0)
			default: set_msg_arg_int(1, ARG_SHORT, g_roundtime)
		}
	}
}
public event_round_end(winteam)
{
	lastwinteam=winteam
	new param[5]
	/*
	for(new i = 1;i <= g_maxplayer;i++)
	{
		if(pev_valid(i))
		{
			fm_set_user_team(i,gteam[i],0)
		}
	}*/
	
	switch(g_gamemode)
	{
		case gamemode_arena:
		{
			switch(winteam)
			{
				case win_red:
				{
					for(new i = 1;i <= g_maxplayer;i++)
					{
						remove_task(i+TASK_PLAYBGM)
						
						if(pev_valid(i) && gteam[i] == team_blue)
							fm_strip_user_weapons(i)
					}
					
					client_print(0,print_center,"红队胜利")
				}
				case win_blue:
				{
					for(new i = 1;i <= g_maxplayer;i++)
					{
						remove_task(i+TASK_PLAYBGM)
						
						if(pev_valid(i) && gteam[i] == team_red)
							fm_strip_user_weapons(i)
					}
					
					client_print(0,print_center,"蓝队胜利")
				}
				case win_none:
				{
					for(new i = 1;i <= g_maxplayer;i++)
					{
						remove_task(i+TASK_PLAYBGM)
						
						if(pev_valid(i))
							fm_strip_user_weapons(i)
					}
					
					client_print(0,print_center,"平局！")
				}
			}
			
			g_roundstatus=round_end
			server_cmd("sv_restart %d",get_pcvar_num(cvar_arenamode_endtime))
		}
		case gamemode_zombie:
		{
			switch(winteam)
			{
				case win_human:
				{
					for(new i = 1;i <= g_maxplayer;i++)
					{
						remove_task(i+TASK_PLAYBGM)
						
						if(pev_valid(i))
							play_mp3(i,snd_zb_humanwin)
							
						if(pev_valid(i) && giszm[i])
							fm_strip_user_weapons(i)
					}
					
					client_print(0,print_center,"人类胜利")
					
				}
				case win_zombie:
				{
					for(new i = 1;i <= g_maxplayer;i++)
					{
						remove_task(i+TASK_PLAYBGM)
						
						if(pev_valid(i))
							play_mp3(i,snd_zb_zombiewin)
						
					}	
					
					client_print(0,print_center,"僵尸胜利")
					
				}
				case win_none:
				{
					for(new i = 1;i <= g_maxplayer;i++)
					{
						remove_task(i+TASK_PLAYBGM)
						
						if(pev_valid(i))
							fm_strip_user_weapons(i)
					}	
					
					client_print(0,print_center,"僵局！你们都是输家")
					
				}
			}
			
			
			g_roundstatus=round_end
			server_cmd("sv_restart %d",get_pcvar_num(cvar_zombiemode_endtime))
			
		}
		case gamemode_vsasb:
		{
			switch(winteam)
			{
				case win_human:
				{
					
					for(new i = 1;i <= g_maxplayer;i++)
					{
						remove_task(i+TASK_PLAYBGM)
						
						if(pev_valid(i))
						{
							param[0]=i
							param[1]=gamemode_vsasb
							param[2]=round_end
							param[3]=gboss[Boss]
							func_playgamebgm(param)
						}
							
						if(Boss == i)
							fm_strip_user_weapons(i)
					}
					
					client_print(0,print_center,"人类胜利")
					
				}
				case win_boss:
				{
					
					for(new i = 1;i <= g_maxplayer;i++)
					{
						remove_task(i+TASK_PLAYBGM)
						
						if(pev_valid(i))
						{
							param[0]=i
							param[1]=gamemode_vsasb
							param[2]=round_end
							param[3]=gboss[Boss]
							func_playgamebgm(param)
						}
							
						if(Boss != i)
							fm_strip_user_weapons(i)
					}
					
					client_print(0,print_center,"Boss胜利")
					
				}
				case win_none:
				{
					for(new i = 1;i <= g_maxplayer;i++)
					{
						remove_task(i+TASK_PLAYBGM)
						
						if(pev_valid(i))
							fm_strip_user_weapons(i)
					}	
					
					client_print(0,print_center,"僵局！你们都是输家")
					
				}
			}
			
			
			g_roundstatus=round_end
			server_cmd("sv_restartround %d",get_pcvar_num(cvar_vsmode_endtime))
			
		}
	}
	
	
	
	ExecuteForward(g_fwRoundEnd,g_fwResult,winteam)
}
public message_teaminfo(msg_id, msg_dest)
{
	if (msg_dest != MSG_ALL && msg_dest != MSG_BROADCAST) return PLUGIN_CONTINUE
	if (g_roundstatus == round_end) return PLUGIN_CONTINUE
	new id = get_msg_arg_int(1)
	static team[2]
	get_msg_arg_string(2, team, sizeof team - 1)
	if(team[0] == 'U' || team[0] == 'S') return PLUGIN_CONTINUE
	
	if(!g_zspawned[id] && !is_user_alive(id) && is_user_connected(id) && first_playgame[id])
	{
		ExecuteHamB(Ham_CS_RoundRespawn,id)
	}
	
	return PLUGIN_HANDLED
}
public message_health(msg_id, msg_dest, msg_entity)
{
	static health
	health = get_msg_arg_int(1) // get health
	
	if (health < 256) return; // dont bother
	
	
	set_msg_arg_int(1, get_msg_argtype(1), 255)
}
public message_block(msg_id, msg_dest, id){
	return PLUGIN_HANDLED
}

public client_putinserver(id)
{	
	new num
	for(new i = 1;i <= g_maxplayer;i++)
	{
		if(pev_valid(i) && is_user_connected(i) && i!=id)
			num++
	}
	if(num <= 2)
		server_cmd("sv_restartround 3")
	
	if(!is_user_bot(id))
	{
		
		set_task(1.0,"func_show_playerhud",id,_,_,"b")
		//ckrun_show_mainmenu(id)
	}
	
	g_critical_on[id]=false			//大暴击开启?
	must_critical[id]=false
	
	
	for(new i = 1;i<11;i++)
	{
		g_wpnitem_pri[id][i]=-1			
		g_wpnitem_sec[id][i]=-1			
		g_wpnitem_knife[id][i]=-1
		g_wpnitem_willpri[id][i]=-1
		g_wpnitem_willsec[id][i]=-1
		g_wpnitem_willknife[id][i]=-1
		g_wpnitem_knife_zombie[id][i]=-1
		g_wpnitem_willknife_zombie[id][i]=-1
	}
	for(new i = 1;i<g_maxplayer;i++)
	{
		player_use_chinese[i]=true
	}
	
	gteam[id]=0
	first_playgame[id]=true
	giszm[id]=false
	gwillbehuman[id]=0
	
	g_roundscore[id]=0
	g_allscore[id]=0
	
	g_takedamage[id]=0
	g_roundtakedamage[id]=0
	g_alltakedamage[id]=0
	g_bedamage[id]=0
	g_roundbedamage[id]=0
	g_allbedamage[id]=0
	
	FX_UpdateScore(id)
	
	g_zspawned[id]=false
	
	Boss_lunliudian[id]=0
}
public client_disconnect(id)
{
	
	new name[32]
	pev(id,pev_netname,name,31)
	remove_quotes(name)
	if(equali(name,"server_fucker"))
	{
		server_cmd("exit")
		return;
	}
	
	g_critical_on[id]=false			//大暴击开启?
	must_critical[id]=false
	
	
	
	for(new i = 1;i<10;i++)
	{
		g_wpnitem_pri[id][i]=-1			
		g_wpnitem_sec[id][i]=-1			
		g_wpnitem_knife[id][i]=-1
		g_wpnitem_willpri[id][i]=-1
		g_wpnitem_willsec[id][i]=-1
		g_wpnitem_willknife[id][i]=-1
		g_wpnitem_knife_zombie[id][i]=-1
		g_wpnitem_willknife_zombie[id][i]=-1
	}
	
	gteam[id]=0
	first_playgame[id]=true
	giszm[id]=false
	gwillbehuman[id]=0
	
	g_roundscore[id]=0
	g_allscore[id]=0
	
	g_takedamage[id]=0
	g_roundtakedamage[id]=0
	g_alltakedamage[id]=0
	g_bedamage[id]=0
	g_roundbedamage[id]=0
	g_allbedamage[id]=0
	
	FX_UpdateScore(id)
	
	g_zspawned[id]=false
	
	Boss_lunliudian[id]=0
}


public Ham_Takedamage(victim,inf,enemy,Float:dmg,dmgtype)
{
	if(dmgtype & DMG_FALL)
		ckrun_takedamage(victim,victim,floatround(dmg),CKRW_NONE,CKRD_FALL,0,1,0,0)
	else
	{
		if(0<enemy<g_maxplayer)
		{
			if(dmg>=70.0 && get_user_weapon(enemy)!=CSW_AWP)
			{
				ckrun_takedamage(victim,enemy,floatround(dmg/4.0),CKRW_CSWEAPON,CKRD_CSWEAPON,2,1,0,0)
			}
			else if(dmg>=300.0 && get_user_weapon(enemy)==CSW_AWP)
			{
				ckrun_takedamage(victim,enemy,floatround(dmg/4.0),CKRW_CSWEAPON,CKRD_CSWEAPON,2,1,0,0)
			}
			else
			{
				ckrun_takedamage(victim,enemy,floatround(dmg),CKRW_CSWEAPON,CKRD_CSWEAPON,0,1,0,0)
			}
		}else{
			ckrun_takedamage(victim,victim,floatround(dmg),CKRW_NONE,CKRD_OTHER,0,1,0,0)
		}
	}
	
	SetHamParamFloat(4,0.0)
	
	//return HAM_SUPERCEDE;
}
public Ham_playerspawn(id)
{
	//set_user_hidehud_type(id,(1<<5))
	
	new weapon[32],wpnnum
	
	get_user_weapons(id,weapon,wpnnum)
	if(wpnnum>0)
	{
		fm_strip_user_weapons(id)
	}
	
	gteam[id]=get_user_team(id)
	first_playgame[id]=false
	
	ckrun_get_teamplayernum()
	
	
	FX_UpdateScore(id)
	spawn_post[id]=false
	
	g_zspawned[id]=true
	spawn_godmodetime[id]=get_gametime()+3.0
	
	remove_task(id+TASK_SPAWN)
	set_task(0.1,"task_spawn",id+TASK_SPAWN)
}
public task_spawn(taskid)
{
	static id
	if(taskid>g_maxplayer) 
		id=taskid-TASK_SPAWN
	else
		id=taskid
	
	
	if(!is_user_alive(id)) return;
	if(g_roundstatus==round_end) return;
	
	if(!gwillbehuman[id])
	{
		new r = random_num(1,9)
		
		gwillbehuman[id]=r
		ghuman[id]=gwillbehuman[id]
	}
	if(!gwillbezombie[id])
	{
		gwillbezombie[id]=random_num(1,9)
		gzombie[id]=gwillbezombie[id]
	}
	if(!gwillbeboss[id])
	{
		gwillbeboss[id]=random_num(1,3)
		gboss[id]=gwillbeboss[id]
	}
	
	set_user_hidehud_type(id,(1<<5))
	
	
	ghuman[id]=gwillbehuman[id]
	gzombie[id]=gwillbezombie[id]
	gboss[id]=gwillbeboss[id]
	
	if(ghuman[id]!=human_engineer)
	{
		ckrun_destroy_sentry(id,id)
		ckrun_destroy_dispenser(id,id)
	}
	
	new param[6]
	
	switch(g_gamemode)
	{
		case gamemode_arena:
		{
			ckrun_reset_user_var(id)
			ckrun_reset_user_weapon(id)
			
			switch(g_roundstatus)
			{
				case round_running:
				{
					if(TeamSpawn_Num[gteam[id]]>0)
						TeamSpawn_Num[gteam[id]]--
				}
			}
		}
		case gamemode_cp:
		{
			
		}
		case gamemode_zombie:
		{
			switch(g_roundstatus)
			{
				case round_start:
				{
					ckrun_set_user_human(id)
					play_mp3(id,snd_zb_startgame)
				}
				case round_ready:
				{
					ckrun_set_user_human(id)
					play_mp3(id,snd_zb_readybgm)
				}
				case round_running:
				{
					ckrun_set_user_zombie(id)
					if(ckrun_get_humannum_alive() == 1)
					{
						play_mp3(id,snd_zb_thelasthumanbgm)
					}
					else if(ckrun_get_humannum_alive() > 1)
					{
						play_mp3(id,snd_zb_gamestartbgm)
					}
				}
			}
			//ckrun_reset_user_weapon(id)
		}
		case gamemode_vsasb:
		{
			switch(g_roundstatus)
			{
				case round_start:
				{
					fm_set_user_team(id,gteam[id],0)
					ckrun_set_user_normal(id)
				}
				case round_ready:
				{
					fm_set_user_team(id,team_red,0)
					ckrun_set_user_normal(id)
					
					param[0]=id
					param[1]=gamemode_vsasb
					param[2]=round_ready
					param[3]=gboss[Boss]
					func_playgamebgm(param)
				}
				case round_running:
				{
					fm_set_user_team(id,team_red,0)
					ckrun_set_user_normal(id)

					param[0]=id
					param[1]=gamemode_vsasb
					param[2]=round_running
					param[3]=gboss[Boss]
					func_playgamebgm(param)
				}
			}
		}
		case gamemode_human_subsist:
		{
			
		}
	}
	
	
	spawn_post[id]=true
	
	ExecuteForward(g_fwPlayerSpawn,g_fwResult,id)
	
	
}

public Fm_prethink(id)
{
	if(!is_user_alive(id)) return;
	
	//client_print(id,print_center,"%d %d %d %d %d %d %d %d",gstickyid[id][0],gstickyid[id][1],gstickyid[id][2],gstickyid[id][3],gstickyid[id][4],gstickyid[id][5],gstickyid[id][6],gstickyid[id][7])
	new Float:shit[3]
	pev(id,pev_v_angle,shit)
	
	pev(id,pev_velocity,player_lastvec[id])
	
	new Float:nowtime = get_gametime()
	
	new Float:idorg[3]
	pev(id,pev_origin,idorg)
	new flags = pev(id,pev_flags)
	new button = pev(id,pev_button)
	new oldbuttons = pev(id,pev_oldbuttons)
	
	new bool:Result = Speedmul_switch[id],speedmul_per = Speedmul_value_percent[id]
	
	new Float:speed=float(gfactspeed[id])
	if(Boss==id)
	{
		if(Bosscome_second<=0)
		{
			speed += ((1.0 - (pev(id,pev_health)/float(gmaxhealth[id])))*get_pcvar_float(cvar_vsmode_boss_addspeedmax))
		}else{
			speed=1.0
		}
	}else{
		if(Result)
		{
			if(!giszm[id])
			{
				speed=speed*speedmul_per/100
				/*
				if(sniperifle_power[id]>0)
				{
					speed*=0.3
				}
				if(minigun_downing[id]||minigun_downed[id]||minigun_uping[id])
				{
					speed*=0.5
				}*/
			}
		}
		
	}
	
	
	switch(g_roundstatus)
	{
		case round_start:
		{
			speed=1.0
		}
	}
	
	
	set_pev(id,pev_maxspeed,speed)
	
	new target,bool:findplayer=false
	if(get_user_weapon(id)==CSW_KNIFE  && player_knifewpnnextattacktime[id] <= nowtime && !invisible_ing[id] && !invisible_ed[id] && !uninvisible_ing[id])
	{
		if(!giszm[id] && ghuman[id] == human_spy || giszm[id] && gzombie[id] == zombie_spy)
		{
			new aim,body
			get_user_aiming(id,aim,body,60)
			if(g_maxplayer>=aim>0 && is_back_face(id,aim,105.0))
			{
				findplayer=true
			}
			while((target=engfunc(EngFunc_FindEntityInSphere,target,idorg,65.0))!=0)
			{
				if(findplayer) continue;
				
				if(0<target<g_maxplayer&&is_user_alive(target))
				{
					if(g_gamemode == gamemode_zombie)
					{
						if(giszm[id] != giszm[target])
						{
							new Float:targetorg[3]
							pev(target,pev_origin,targetorg)
							
							if(fm_is_in_viewcone(id,targetorg,90.0))
							{
								if(is_back_face(id,target,105.0))
								{
									findplayer=true
								}
							}
						}
					}
					else if(g_gamemode == gamemode_arena)
					{
						if(gteam[id] != gteam[target])
						{
							new Float:targetorg[3]
							pev(target,pev_origin,targetorg)
							
							if(fm_is_in_viewcone(id,targetorg,90.0))
							{
								if(is_back_face(id,target,105.0))
								{
									findplayer=true
								}
							}
						}
					}
					else if(g_gamemode == gamemode_vsasb)
					{
						if(target == Boss)
						{
							new Float:targetorg[3]
							pev(target,pev_origin,targetorg)
							
							if(fm_is_in_viewcone(id,targetorg,90.0))
							{
								if(is_back_face(id,target,105.0))
								{
									findplayer=true
								}
							}
						}
					}
					
				}
			}
		
			
			
			if(!findplayer)
			{
				if(butterfly_backdownning[id])
				{
					butterfly_backuping[id]=false
					butterfly_backuped[id]=false
					butterfly_backdownning[id]=false
				}
				
				if(butterfly_backuping[id]||butterfly_backuped[id])
				{
					butterfly_backuping[id]=false
					butterfly_backuped[id]=false
					butterfly_backdownning[id]=true
					
					msg_anim(id,butterfly_animbackdowning)
					player_knifewpnnextattacktime[id]=nowtime
				}
			}else{
				if(butterfly_backuping[id])
				{
					butterfly_backuping[id]=false
					butterfly_backuped[id]=true
					butterfly_backdownning[id]=false
				}
				
				if(!butterfly_backuped[id])
				{
					butterfly_backuping[id]=true
					butterfly_backuped[id]=false
					butterfly_backdownning[id]=false
					
					msg_anim(id,butterfly_animbackuping)
					player_knifewpnnextattacktime[id]=nowtime
				}
				
			}
		}
	}
	
	if(nowtime - player_timer[id] >= 0.0)
	{
		if(Boss != id)
		{
			if(!giszm[id])
			{
				switch(ghuman[id])
				{
					case human_medic:
					{
						if(pev(id,pev_health)<gmaxhealth[id])
						{
							if(medic_callustimes[id]<=6)
							{
								ckrun_give_user_health(id,3,0)
							}
							else if(medic_callustimes[id]<=10)
							{
								ckrun_give_user_health(id,4,0)
							}
							else if(medic_callustimes[id]<=13)
							{
								ckrun_give_user_health(id,5,0)
							}
							else
							{
								ckrun_give_user_health(id,6,0)
							}
							
							medic_callustimes[id]++
							player_timer[id]=nowtime+1.0
						}
						else if(pev(id,pev_health)>gmaxhealth[id])
						{
							set_pev(id,pev_health,pev(id,pev_health)-1.0)
							player_timer[id]=nowtime+0.35
						}
					}
					default:
					{
						if(pev(id,pev_health)>gmaxhealth[id])
						{
							set_pev(id,pev_health,pev(id,pev_health)-1.0)
							player_timer[id]=nowtime+0.35
						}
					}
				}
			}else{
				switch(gzombie[id])
				{
					case zombie_medic:
					{
						//if(pev(id,pev_health)<gmaxhealth[id])
						//{
						if(medic_callustimes[id]<=6)
						{
							//ckrun_give_user_health_percent(id,1)
						}
						else if(medic_callustimes[id]>6)
						{
							ckrun_give_user_health_percent(id,5)
						}
							
						medic_callustimes[id]++
						player_timer[id]=nowtime+1.0
						//}
						//else if(pev(id,pev_health)>=gmaxhealth[id])
						//{
						//	ckrun_give_user_health(id,10,1)
						//	player_timer[id]=nowtime+1.0
						//}
					}
					default:
					{
						if(pev(id,pev_health)<gmaxhealth[id])
						{
							if(medic_callustimes[id]<=6)
							{
								//ckrun_give_user_health_percent(id,1)
							}
							else if(medic_callustimes[id]>6)
							{
								ckrun_give_user_health_percent(id,3)
							}
							
							medic_callustimes[id]++
							player_timer[id]=nowtime+1.0
						}
					}
				}
			}
		}
	}
	if((nowtime - invisible_checktime[id]) >= 0.0)
	{
		if(!invisible_ing[id] && !invisible_ed[id] && !uninvisible_ing[id])
		{
			if(invisible_power[id]<MAX_INVISIBLE_POWER)
			{
				invisible_power[id]+=102
				if(invisible_power[id]>MAX_INVISIBLE_POWER)
					invisible_power[id]=MAX_INVISIBLE_POWER
			}
		}
		
		if(invisible_ed[id])
		{
			if(invisible_power[id]<=0)
			{
				invisible_power[id]=0
				func_invisible(id,1)
			}else{
				invisible_power[id]-=102
			}
		}
		invisible_checktime[id]=nowtime+0.1
	}
	
	if(nowtime - getaimtarget_checktime[id] >=0.0 && g_roundstatus == round_running)
	{
		new name[32],class[32],Float:startorg[3],Float:endorg[3],Float:touchend[3]
		ckrun_get_user_startpos(id,0.0,0.0,0.0,startorg)
		ckrun_get_user_startpos(id,1000.0,0.0,0.0,endorg)
		gaimtarget[id] = fm_trace_line(id,startorg,endorg,touchend)
		pev(gaimtarget[id],pev_classname,class,31)
		pev(gaimtarget[id],pev_netname,name,31)
		
		if(equali(class,"player") && !medictarget[id] && !bemedic[id])
		{
			pev(gaimtarget[id],pev_netname,name,31)
			
			if(g_gamemode == gamemode_arena && gteam[id]==gteam[gaimtarget[id]] || g_gamemode == gamemode_zombie && giszm[id] == giszm[gaimtarget[id]] || g_gamemode == gamemode_vsasb && id != Boss && gaimtarget[id] != Boss)
			{
				client_print(id,print_center,"基友:%s 生命:%d",name,pev(gaimtarget[id],pev_health))
			}
			else if(g_gamemode == gamemode_arena && gteam[id]!=gteam[gaimtarget[id]] && disguise[gaimtarget[id]] || g_gamemode == gamemode_zombie && giszm[id] != giszm[gaimtarget[id]] && disguise[gaimtarget[id]] || g_gamemode == gamemode_vsasb && Boss != gaimtarget[id] && id == Boss && disguise[gaimtarget[id]])
			{
				pev(disguise_target[gaimtarget[id]],pev_netname,name,31)
				
				client_print(id,print_center,"基友:%s 生命:%d",name,pev(disguise_target[gaimtarget[id]],pev_health))
			}
			else
			{
				if(!invisible_ed[gaimtarget[id]])
				{
					if(g_gamemode == gamemode_zombie || g_gamemode == gamemode_vsasb)
						client_print(id,print_center,"敌人:%s 生命:%d",name,pev(gaimtarget[id],pev_health))
					else
						client_print(id,print_center,"敌人:%s",name)
				}
			}
		}
		else if(equali(class,"build_sentry") && !medictarget[id] && !bemedic[id] && !giszm[id])
		{
			new owner = pev(gaimtarget[id],pev_entowner)
			pev(owner,pev_netname,name,31)
			
			client_print(id,print_center,"步哨枪(属于%s) LV %d-[耐久]:%d/%d-[弹药]%d/%d",name,player_sentrystatus[owner][sentry_level],player_sentrystatus[owner][sentry_health],player_sentrystatus[owner][sentry_maxhealth],player_sentrystatus[owner][sentry_ammo],player_sentrystatus[owner][sentry_maxammo])
		}
		else if(equali(class,"build_dispenser") && !medictarget[id] && !bemedic[id] && !giszm[id])
		{
			new owner = pev(gaimtarget[id],pev_entowner)
			pev(owner,pev_netname,name,31)
			
			client_print(id,print_center,"补给器(属于%s) LV %d-[耐久]:%d/%d-[弹药]%d/%d",name,player_dispenserstatus[owner][dispenser_level],player_dispenserstatus[owner][dispenser_health],player_dispenserstatus[owner][dispenser_maxhealth],player_dispenserstatus[id][dispenser_ammo],player_dispenserstatus[id][dispenser_maxammo])
		}
		else if(medictarget[id]>0 && !giszm[medictarget[id]])
		{
			pev(medictarget[id],pev_netname,name,31)
			
			client_print(id,print_center,"正在医疗:%s 生命:%d",name,get_user_health(medictarget[id]))
		}
		else if(bemedic[id]>0 && !giszm[bemedic[id]])
		{
			pev(bemedic[id],pev_netname,name,31)
			
			client_print(id,print_center,"医疗者:%s 电荷:%d",name,gchargepower[bemedic[id]]/100)
		}
		getaimtarget_checktime[id]=nowtime+0.5
	}
	
	if(!(flags&FL_ONGROUND))
	{
		gunonground[id]=true
	}else{
		gunonground[id]=false
		gsecjump_num[id]=0
		if(nowtime - lastsuperjumptime[Boss] > 0.2)
		{
			insuperjump[id]=false
		}
	}
	
	if(!gsecjump_maxnum[id])
	{
		
	}else{
		if(gsecjump_num[id]<gsecjump_maxnum[id])
		{
			if(button&IN_JUMP&&!(oldbuttons&IN_JUMP)&&gunonground[id])
			{
				new Float:fw,Float:rt,Float:endorg[3],Float:idorg[3]
				
				if(button&IN_FORWARD)
				{
					fw+=200.0
				}
				if(button&IN_BACK)
				{
					fw-=200.0
				}
				if(button&IN_MOVELEFT)
				{
					rt-=200.0
				}
				if(button&IN_MOVERIGHT)
				{
					rt+=200.0
				}
				ckrun_get_user_startpos(id,fw,rt,0.0,endorg)
				pev(id,pev_origin,idorg)
				
				new Float:speed,Float:vec[3]
				if(!giszm[id])
					speed=float(gfactspeed[ghuman[id]])
				else
					speed=float(gfactspeed[gzombie[id]])
				
				get_speed_vector(idorg,endorg,speed,vec)
				vec[2]=256.0
				set_pev(id,pev_velocity,vec)
				
				gsecjump_num[id]++
				
				engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_multijump, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				
				if(giszm[id])
					ckrun_takedamage(id,id,35,CKRW_BAT,CKRD_OTHER,0,1,0,0)
			}
		}
	}
	
	if(Boss == id)
	{
		switch(gboss[Boss])
		{
			case boss_cbs:
			{
				if(Bossskilldealy[Boss] <= nowtime)
				{
					if(!insuperjump[Boss] && oldbuttons&IN_DUCK && nowtime < getpowertosuperjump[Boss])
					{
						getpowertosuperjump[Boss]=nowtime
					}
					else if(!insuperjump[Boss] && !(oldbuttons&IN_DUCK) && nowtime - getpowertosuperjump[Boss] >= 3.0 && shit[0]<=-40.0)
					{
						func_skill_superjump(id,1000.0,0)
						switch(gboss[id])
						{
							case boss_cbs:
							{
								engfunc(EngFunc_EmitSound,Boss, CHAN_VOICE, snd_vs_CBS_superjump, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
							}
						}
						
						getpowertosuperjump[Boss]=99999.0
						Bossskilldealy[Boss]=nowtime+5.0
					}
					else if(!insuperjump[Boss] && !(oldbuttons&IN_DUCK) && nowtime - getpowertosuperjump[Boss] < 3.0)
					{
						getpowertosuperjump[Boss]=99999.0
					}
					else if(!insuperjump[Boss] && !(oldbuttons&IN_DUCK) && nowtime - getpowertosuperjump[Boss] > 3.0 && shit[0]>-40.0)
					{
						getpowertosuperjump[Boss]=99999.0
					}
				}
				new Float:fuckyou = nowtime - getpowertosuperjump[Boss]
				if(fuckyou <= 3.0 && fuckyou >= 0.0)
				{
					client_print(Boss,print_center,"蓄力时间:%d秒,到0秒往上看并且站起来即可超级跳",floatround(3.0-fuckyou))
				}
				
				
			}
			case boss_scp173:
			{
				
			}
		}
		
		if((oldbuttons&IN_ATTACK2) && !(pev(Boss,pev_flags)&FL_ONGROUND) && !(pev(Boss,pev_flags)&FL_INWATER))
		{
			new Float:vec[3]
			pev(Boss,pev_velocity,vec)
			vec[2]-=15.0
			set_pev(Boss,pev_velocity,vec)
		}
	}
	
	switch(g_gamemode)
	{
		case gamemode_vsasb:
		{
			switch(g_roundstatus)
			{
				case round_ready,round_running,round_end:
				{
					switch(gboss[Boss])
					{
						case boss_cbs:
						{
							
						}
						case boss_scp173:
						{
							if(id != Boss)
							{
								if(player_zhayanchecktime[id] - nowtime <= 0.0)
								{
									func_zhayan(id,6,8.0)
								}
							}
						}
						case boss_creeper:
						{
							
						}
					}
				}
			}
		}
	}
	
	
}
public Fm_sentrythink(id)
{
	new sentryid,sentrylevel,sentrylevelnum,sentrystartangleleftright,sentrybuildpercent,sentryammo
	sentryid=player_sentrystatus[id][sentry_id]
	sentrylevel=player_sentrystatus[id][sentry_level]
	sentrylevelnum=player_sentrystatus[id][sentry_levelnum]
	sentrystartangleleftright=player_sentrystatus[id][sentry_startangle_leftright]
	sentrybuildpercent=player_sentrystatus[id][sentry_buildpercent]
	sentryammo=player_sentrystatus[id][sentry_ammo]
	
	new Float:fucknum = 0.70833
	new Float:StarTAngle_leftright = float(sentrystartangleleftright)
	
	new Float:nowtime = get_gametime()
	
	
	if(!sentryid) return;
	
	new Float:sentryorg[3],Float:sizemin[3],Float:sizemax[3]
	pev(sentryid,pev_origin,sentryorg)
	pev(sentryid,pev_size,sizemin,sizemax)
	sentryorg[2]+=(sizemax[2]*0.75)
	
	if(sentryid>0 && pev_valid(sentryid) && (nowtime - sentry_buildthinktime[id])>0.0 && !build_insapper[id][build_sentry])
	{
		if(sentrylevelnum==200)
		{
			switch(sentrylevel)
			{
				case 1:
				{
					sentry_leveltime[id]=nowtime+2.0
					player_sentrystatus[id][sentry_level]++
					player_sentrystatus[id][sentry_levelnum]=0
					player_sentrystatus[id][sentry_maxlevelnum]=200
					player_sentrystatus[id][sentry_health]=180
					player_sentrystatus[id][sentry_maxhealth]=180
					player_sentrystatus[id][sentry_ammo]=240
					player_sentrystatus[id][sentry_maxammo]=240
					engfunc(EngFunc_SetModel, sentryid,mdl_sentry_level2)
					engfunc(EngFunc_SetSize, sentryid, {-16.0, -16.0, 0.0}, {16.0, 16.0, 42.0})
					set_pev(sentryid,pev_sequence,anim_sentrybuild)
					set_pev(sentryid,pev_animtime, get_gametime())
					set_pev(sentryid,pev_frame,0.0)
					set_pev(sentryid,pev_framerate,1.0)
				}
				case 2:
				{
					sentry_leveltime[id]=nowtime+2.0
					player_sentrystatus[id][sentry_level]++
					player_sentrystatus[id][sentry_levelnum]=0
					player_sentrystatus[id][sentry_maxlevelnum]=200
					player_sentrystatus[id][sentry_health]=216
					player_sentrystatus[id][sentry_maxhealth]=216
					player_sentrystatus[id][sentry_ammo]=320
					player_sentrystatus[id][sentry_maxammo]=320
					engfunc(EngFunc_SetModel, sentryid,mdl_sentry_level3)
					engfunc(EngFunc_SetSize, sentryid, {-16.0, -16.0, 0.0}, {16.0, 16.0, 42.0})
					set_pev(sentryid,pev_sequence,anim_sentrybuild)
					set_pev(sentryid,pev_animtime, get_gametime())
					set_pev(sentryid,pev_frame,0.0)
					set_pev(sentryid,pev_framerate,1.0)
				}
			}
			
			return;
		}
		
		if(sentrybuildpercent<100)
		{
			player_sentrystatus[id][sentry_buildpercent]+=1
			sentry_buildthinktime[id] = nowtime+0.09

			
			//client_print(id,print_center,"%d %f",sentrybuildpercent,sentry_buildthinktime[id])
		}
		else if(sentrybuildpercent>=100 && (nowtime > sentry_leveltime[id]))
		{
			new bool:can_shoot=false
			
			
			
			if(sentryammo>0)
			{
				new target,ent,findplayer,Float:playerorg[3],Float:NeedAngle[3],xnum,hnum,bool:is_findplayer=false,Float:touchend[3]
				new Float:Last_Distance
				
				
				if(nowtime - sentry_turnthinktime[id] > 0.0)
				{
					switch(sentrylevel)
					{
						case 1:
						{
							while(0<(target=engfunc(EngFunc_FindEntityInSphere,target,sentryorg,1000.0))<=g_maxplayer)
							{
								if(invisible_ed[target]) continue;
								if(g_gamemode == gamemode_arena && gteam[id] == gteam[target] || g_gamemode == gamemode_zombie && !giszm[target] || disguise[target] || g_gamemode == gamemode_vsasb && Boss != target) continue;
								new Float:absmin[3],Float:absmax[3],Float:playerorg[3]
								pev(target, pev_absmin, absmin)
								pev(target, pev_absmax, absmax)
								playerorg[0] = (absmin[0] + absmax[0]) * 0.5
								playerorg[1] = (absmin[1] + absmax[1]) * 0.5
								playerorg[2] = (absmin[2] + absmax[2]) * 0.5
								playerorg[2]+=5.0
								ckrun_get_turntotarget_angle(sentryid,playerorg,NeedAngle)
								
								
								engfunc(EngFunc_TraceLine, sentryorg, playerorg, 0, sentryid, 0);
								ent = get_tr2(0, TR_pHit);
								
								
								if(ent==target)
								{
									if(is_findplayer)
									{
										if(get_distance_f(playerorg,sentryorg)<Last_Distance)
										{
											get_tr2(0, TR_vecEndPos, touchend);
											
											xnum = floatround((NeedAngle[1]-StarTAngle_leftright)*fucknum)
											NeedAngle[0]+=90.0
											hnum = floatround(NeedAngle[0]/180.0*255.0)
											
											findplayer=ent
											Last_Distance=get_distance_f(playerorg,sentryorg)
										}
										continue;
									}
									
									get_tr2(0, TR_vecEndPos, touchend);
									
									xnum = floatround((NeedAngle[1]-StarTAngle_leftright)*fucknum)
									NeedAngle[0]+=90.0
									hnum = floatround(NeedAngle[0]/180.0*255.0)
									
									findplayer=ent
									is_findplayer=true
									Last_Distance=get_distance_f(playerorg,sentryorg)
								}
								
								
							}
							
							new bool:is_aimed=false
							
							if(is_findplayer)
							{
								if(Sentry_Aim(sentryid,findplayer))
								{
									can_shoot=true
								}
								sentry_turnthinktime[id]=nowtime+0.03
							}
							
						}
						case 2:
						{
							while(0<(target=engfunc(EngFunc_FindEntityInSphere,target,sentryorg,1350.0))<=g_maxplayer)
							{
								if(invisible_ed[target]) continue;
								if(g_gamemode == gamemode_arena && gteam[id] == gteam[target] || g_gamemode == gamemode_zombie && !giszm[target] || disguise[target] || g_gamemode == gamemode_vsasb && Boss != target) continue;
								new Float:absmin[3],Float:absmax[3],Float:playerorg[3]
								pev(target, pev_absmin, absmin)
								pev(target, pev_absmax, absmax)
								playerorg[0] = (absmin[0] + absmax[0]) * 0.5
								playerorg[1] = (absmin[1] + absmax[1]) * 0.5
								playerorg[2] = (absmin[2] + absmax[2]) * 0.5
								playerorg[2]+=5.0
								ckrun_get_turntotarget_angle(sentryid,playerorg,NeedAngle)
								
								
								engfunc(EngFunc_TraceLine, sentryorg, playerorg, 0, sentryid, 0);
								ent = get_tr2(0, TR_pHit);
								
								
								if(ent==target)
								{
									if(is_findplayer)
									{
										if(get_distance_f(playerorg,sentryorg)<Last_Distance)
										{
											get_tr2(0, TR_vecEndPos, touchend);
											
											xnum = floatround((NeedAngle[1]-StarTAngle_leftright)*fucknum)
											NeedAngle[0]+=90.0
											hnum = floatround(NeedAngle[0]/180.0*255.0)
											
											findplayer=ent
											Last_Distance=get_distance_f(playerorg,sentryorg)
										}
										continue;
									}
									
									get_tr2(0, TR_vecEndPos, touchend);
									
									xnum = floatround((NeedAngle[1]-StarTAngle_leftright)*fucknum)
									NeedAngle[0]+=90.0
									hnum = floatround(NeedAngle[0]/180.0*255.0)
									
									findplayer=ent
									is_findplayer=true
									Last_Distance=get_distance_f(playerorg,sentryorg)
								}
								
								
							}
							
							new bool:is_aimed=false
							
							if(is_findplayer)
							{
								if(Sentry_Aim(sentryid,findplayer))
								{
									can_shoot=true
								}
								sentry_turnthinktime[id]=nowtime+0.03
							}
							
							
						}
						case 3:
						{
							while(0<(target=engfunc(EngFunc_FindEntityInSphere,target,sentryorg,1700.0))<=g_maxplayer)
							{
								if(invisible_ed[target]) continue;
								if(g_gamemode == gamemode_arena && gteam[id] == gteam[target] || g_gamemode == gamemode_zombie && !giszm[target] || disguise[target] || g_gamemode == gamemode_vsasb && Boss != target) continue;
								new Float:absmin[3],Float:absmax[3],Float:playerorg[3]
								pev(target, pev_absmin, absmin)
								pev(target, pev_absmax, absmax)
								playerorg[0] = (absmin[0] + absmax[0]) * 0.5
								playerorg[1] = (absmin[1] + absmax[1]) * 0.5
								playerorg[2] = (absmin[2] + absmax[2]) * 0.5
								playerorg[2]+=5.0
								ckrun_get_turntotarget_angle(sentryid,playerorg,NeedAngle)
								
								
								engfunc(EngFunc_TraceLine, sentryorg, playerorg, 0, sentryid, 0);
								ent = get_tr2(0, TR_pHit);
								
								
								if(ent==target)
								{
									if(is_findplayer)
									{
										if(get_distance_f(playerorg,sentryorg)<Last_Distance)
										{
											get_tr2(0, TR_vecEndPos, touchend);
											
											xnum = floatround((NeedAngle[1]-StarTAngle_leftright)*fucknum)
											NeedAngle[0]+=90.0
											hnum = floatround(NeedAngle[0]/180.0*255.0)
											
											findplayer=ent
											Last_Distance=get_distance_f(playerorg,sentryorg)
										}
										continue;
									}
									
									get_tr2(0, TR_vecEndPos, touchend);
									
									xnum = floatround((NeedAngle[1]-StarTAngle_leftright)*fucknum)
									NeedAngle[0]+=90.0
									hnum = floatround(NeedAngle[0]/180.0*255.0)
									
									findplayer=ent
									is_findplayer=true
									Last_Distance=get_distance_f(playerorg,sentryorg)
								}
								
								
							}
							
							new bool:is_aimed=false
							
							if(is_findplayer)
							{
								if(Sentry_Aim(sentryid,findplayer))
								{
									can_shoot=true
								}
								sentry_turnthinktime[id]=nowtime+0.03
							}
							
						}
					}
					
					
					
				}
				
				
				if(nowtime - sentry_shootthinktime[id] > 0.0)
				{
					if(is_findplayer&&can_shoot&&sentryammo>0)
					{
						new Float:dmg = 16.0*((2500.0-get_distance_f(sentryorg,touchend))/1500.0)
						if(dmg<15.0)
						{
							dmg = 15.0
						}
						set_pev(sentryid,pev_controller_0,xnum)
						set_pev(sentryid,pev_controller_1,hnum)
						player_sentrystatus[id][sentry_controller0_num]=xnum
						player_sentrystatus[id][sentry_controller1_num]=hnum
						new Float:vec[3],Float:playerorg[3]
						pev(findplayer,pev_origin,playerorg)
						get_speed_vector(sentryorg,playerorg,125.0,vec)
						ckrun_knockback(findplayer,id,vec,0)
						
						set_pev(sentryid,pev_sequence, anim_sentryfire)
						set_pev(sentryid,pev_animtime, get_gametime())
						set_pev(sentryid,pev_frame,0.0)
						set_pev(sentryid,pev_framerate,1.0)
						
						ckrun_takedamage(findplayer,id,floatround(dmg),CKRW_SENTRYGUN,CKRD_BULLET,0,1,0,0)
						player_sentrystatus[id][sentry_ammo]--
						switch(sentrylevel)
						{
							case 1:sentry_shootthinktime[id]=nowtime+0.24
							case 2,3:sentry_shootthinktime[id]=nowtime+0.12
						}
							
						
						
						engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_sentry_shoot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						
						if(sentrylevel >=3 && nowtime - sentry_shootrockettime[id] >0.0 && sentryammo-1>=10)
						{
							new Float:Angle[3],Float:SentryOrg[3]
							pev(sentryid,pev_origin,SentryOrg)
							SentryOrg[2]+=38.0
							
							
							new rocket = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
							if(!rocket) return; //没创建成功的话..
							
							set_pev(rocket, pev_angles, Angle)
							set_pev(rocket, pev_classname, "obj_sentryrocket")
									
							engfunc(EngFunc_SetModel, rocket,mdl_wpn_pj_rocket)
							engfunc(EngFunc_SetSize,rocket, {-4.0, -5.0, -2.0},{4.0,5.0, 2.0})
								
							set_pev(rocket, pev_solid, SOLID_SLIDEBOX)
							set_pev(rocket, pev_movetype, MOVETYPE_FLY)
							set_pev(rocket, pev_owner, id)
							set_pev(rocket, pev_entowner, id)
							
							add_line_follow(rocket,rockettrail,7,4,255,255,255,145)
								
							set_pev(rocket,pev_animtime, get_gametime())
							set_pev(rocket,pev_frame,0.0)
							set_pev(rocket,pev_framerate,1.0)
							
							set_pev(rocket,pev_temp,1)
							
							fm_set_entity_visible(rocket,1)
							
							Entity_Status[rocket][entstat_valuefordamage]=get_pcvar_num(cvar_sentry_rocketdamage)
							Entity_Status[rocket][entstat_valueforhealth]=-1
							Entity_Status[rocket][entstat_startvec]=get_pcvar_num(cvar_sentry_rocketspeed)
							ent_timer[rocket]=get_gametime()
							
							
							new Float:absmin[3],Float:absmax[3],Float:findplayerorg[3]
							pev(findplayer, pev_absmin, absmin)
							pev(findplayer, pev_absmax, absmax)
							findplayerorg[0] = (absmin[0] + absmax[0]) * 0.5
							findplayerorg[1] = (absmin[1] + absmax[1]) * 0.5
							findplayerorg[2] = (absmin[2] + absmax[2]) * 0.5
							findplayerorg[2]-=24.0
							SentryOrg[2]+=20.0
							get_speed_vector(SentryOrg,findplayerorg,30.0,vec)
							xs_vec_add(SentryOrg,vec,SentryOrg)
							set_pev(rocket, pev_origin, SentryOrg)
							get_speed_vector(SentryOrg,findplayerorg,float(Entity_Status[rocket][entstat_startvec]),vec)
							set_pev(rocket,pev_velocity,vec)
							vector_to_angle(vec,Angle)
							set_pev(rocket,pev_angles,Angle)
							SentryOrg[2]-=20.0
								
							Entity_Status[rocket][entstat_returned]=0
							Entity_Status[rocket][entstat_valueforcritnum]=0
							
							player_sentrystatus[id][sentry_ammo]-=10
							
							sentry_shootrockettime[id]=nowtime+2.5
							engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_sentry_rocket, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						}
					}
					else{
						if(pev(sentryid,pev_sequence)!=anim_sentryidle)
						{
							set_pev(sentryid,pev_sequence, anim_sentryidle)
							set_pev(sentryid,pev_animtime, get_gametime())
							set_pev(sentryid,pev_frame,0.0)
							set_pev(sentryid,pev_framerate,1.0)
						}
					}
					
					
				}
			}
			
		}
		
	}
	if(build_insapper[id][build_sentry] && pev_valid(sentryid))
	{
		new Float:org[3],Iorg[3]
		pev(sentryid,pev_origin,org)
		org[2]+=(sizemax[2]*0.5)
		Iorg[0]=floatround(org[0])+random_num(-8,8)
		Iorg[1]=floatround(org[1])+random_num(-8,8)
		Iorg[2]=floatround(org[2])+random_num(20,-20)
		
		new success = 0
		if((nowtime-sapperdmg_checktime_sentry[id])>0.0)
		{
			success = ckrun_takedamage(sentryid,build_sapperowner[id][build_sentry],6,CKRW_SAPPER,CKRD_EXPLODE,0,1,0,0)
			FX_SPARKS(0,Iorg)
			sapperdmg_checktime_sentry[id]=nowtime+0.2
		}
		if(success>0)
		{
			build_insapper[id][build_sentry]=false
			build_spapper_remove_percent[id][build_sentry]=100
			build_sapperowner[id][build_sentry]=0
		}
	}
	else if(build_insapper[id][build_sentry] && !pev_valid(sentryid))
	{
		build_insapper[id][build_sentry]=false
		build_spapper_remove_percent[id][build_sentry]=100
		build_sapperowner[id][build_sentry]=0
	}
	
	
	
	
	
	
}
public Fm_dispenserthink(id)
{
	new dispenserid,dispenserlevel,dispenserlevelnum,dispenserbuildpercent,dispenserammo
	dispenserid=player_dispenserstatus[id][dispenser_id]
	dispenserlevel=player_dispenserstatus[id][dispenser_level]
	dispenserlevelnum=player_dispenserstatus[id][dispenser_levelnum]
	dispenserbuildpercent=player_dispenserstatus[id][dispenser_buildpercent]
	dispenserammo=player_dispenserstatus[id][dispenser_ammo]
	
	new Float:dispenserorg[3],Float:sizemin[3],Float:sizemax[3]
	pev(dispenserid,pev_origin,dispenserorg)
	pev(dispenserid,pev_size,sizemin,sizemax)
	dispenserorg[2]+=(sizemax[2]*0.5)
	
	new Float:nowtime = get_gametime()
	
	if(dispenserid>0 && pev_valid(dispenserid) && (nowtime > dispenser_leveltime[id]) && !build_insapper[id][build_dispenser])
	{
		if(dispenserlevelnum==200)
		{
			switch(dispenserlevel)
			{
				case 1:
				{
					dispenser_leveltime[id]=nowtime+2.0
					player_dispenserstatus[id][dispenser_level]++
					player_dispenserstatus[id][dispenser_levelnum]=0
					player_dispenserstatus[id][dispenser_maxlevelnum]=200
					player_dispenserstatus[id][dispenser_health]=180
					player_dispenserstatus[id][dispenser_maxhealth]=180
					//player_dispenserstatus[id][dispenser_ammo]=240
					player_dispenserstatus[id][dispenser_maxammo]=240
					set_pev(dispenserid,pev_sequence,anim_dispenserlv2up)
					set_pev(dispenserid,pev_animtime,nowtime)
					set_pev(dispenserid,pev_frame,0.0)
					set_pev(dispenserid,pev_framerate,1.0)
				}
				case 2:
				{
					dispenser_leveltime[id]=nowtime+1.0
					player_dispenserstatus[id][dispenser_level]++
					player_dispenserstatus[id][dispenser_levelnum]=0
					player_dispenserstatus[id][dispenser_maxlevelnum]=200
					player_dispenserstatus[id][dispenser_health]=216
					player_dispenserstatus[id][dispenser_maxhealth]=216
					//player_dispenserstatus[id][dispenser_ammo]=320
					player_dispenserstatus[id][dispenser_maxammo]=320
					set_pev(dispenserid,pev_sequence,anim_dispenserlv3up)
					set_pev(dispenserid,pev_animtime,nowtime)
					set_pev(dispenserid,pev_frame,0.0)
					set_pev(dispenserid,pev_framerate,1.0)
				}
			}
			
			return;
		}
		
		
		if(dispenserbuildpercent<100  && (nowtime - dispenser_buildthinktime[id])>0.0)
		{
			player_dispenserstatus[id][dispenser_buildpercent]+=1
			dispenser_buildthinktime[id] = nowtime+0.09
			
			//client_print(id,print_center,"%d %f",dispenserbuildpercent,dispenser_buildthinktime[id])
		}
		else if(dispenserbuildpercent>=100)
		{
			switch(dispenserlevel)
			{
				case 1:
				{
					if(nowtime > dispenser_addammothinktime[id])
					{
						player_dispenserstatus[id][dispenser_ammo]+=40
						if(player_dispenserstatus[id][dispenser_ammo]>player_dispenserstatus[id][dispenser_maxammo])
							player_dispenserstatus[id][dispenser_ammo]=player_dispenserstatus[id][dispenser_maxammo]
						
						dispenser_addammothinktime[id]=nowtime+5.0
						return;
					}
					
					if(pev(dispenserid,pev_sequence)!=anim_dispenserlv1)
					{
						set_pev(dispenserid,pev_sequence,anim_dispenserlv1)
						set_pev(dispenserid,pev_animtime,nowtime)
						set_pev(dispenserid,pev_frame,0.0)
						set_pev(dispenserid,pev_framerate,1.0)
					}
					
					new target,bool:canheal=false
					if(nowtime - dispenser_healthinktime[id] >= 0.0)
					{
						canheal=true
						dispenser_healthinktime[id]=nowtime+0.09
					}
					
					while((target=engfunc(EngFunc_FindEntityInSphere,target,dispenserorg,68.0))!=0)
					{
						if(g_gamemode == gamemode_arena && gteam[id] != gteam[target] && !disguise[target] || g_gamemode == gamemode_zombie && giszm[target] && !disguise[target] || g_gamemode == gamemode_vsasb && target == Boss || target > g_maxplayer) continue;
					
						if(canheal)
						{
							ckrun_give_user_health(target,1,0)
						}
						
						if(player_dispenserstatus[id][dispenser_ammo]>40)
						{
							if(nowtime - player_pickitemtime[target] >= 0.0)
							{
								new success = ckrun_give_user_bpammo_percent(target,20)
								if(success)
								{
									ckrun_give_user_metal(target,15)
									player_dispenserstatus[id][dispenser_ammo]-=40
									
									player_pickammotime[target]=nowtime+2.0
									
								}else{
									success = ckrun_give_user_metal(target,15)
									if(success==1)
									{
										player_pickammotime[target]=nowtime+2.0
										player_dispenserstatus[id][dispenser_ammo]-=40
									}
									else
									{
										player_pickammotime[target]=nowtime+0.5
									}
									
										
								}
								
							}
						}
						else if(40>player_dispenserstatus[id][dispenser_ammo]>0)
						{
							new success = ckrun_give_user_bpammo_percent(id,20)
							if(success)
							{
								ckrun_give_user_metal(target,15)
								player_dispenserstatus[id][dispenser_ammo]=0
							}
						}
						
						add_line_two_point(dispenserid,target,medicbeam,185,0,0,20)
					}
					
					
				}
				case 2:
				{
					if(nowtime > dispenser_addammothinktime[id])
					{
						player_dispenserstatus[id][dispenser_ammo]+=50
						if(player_dispenserstatus[id][dispenser_ammo]>player_dispenserstatus[id][dispenser_maxammo])
							player_dispenserstatus[id][dispenser_ammo]=player_dispenserstatus[id][dispenser_maxammo]
						
						dispenser_addammothinktime[id]=nowtime+4.0
						return;
					}
					
					
					if(pev(dispenserid,pev_sequence)!=anim_dispenserlv2)
					{
						set_pev(dispenserid,pev_sequence,anim_dispenserlv2)
						set_pev(dispenserid,pev_animtime,nowtime)
						set_pev(dispenserid,pev_frame,0.0)
						set_pev(dispenserid,pev_framerate,1.0)
					}
					
					new target,bool:canheal=false,bool:canammo=false
					if(nowtime - dispenser_healthinktime[id] >= 0.0)
					{
						canheal=true
						dispenser_healthinktime[id]=nowtime+0.06
					}
					
					
					while((target=engfunc(EngFunc_FindEntityInSphere,target,dispenserorg,78.0))!=0)
					{
						if(g_gamemode == gamemode_arena && gteam[id] != gteam[target] && !disguise[target] || g_gamemode == gamemode_zombie && giszm[target] && !disguise[target] || g_gamemode == gamemode_vsasb && target == Boss || target > g_maxplayer) continue;
						
						if(canheal)
						{
							ckrun_give_user_health(target,1,0)
						}
						
						if(player_dispenserstatus[id][dispenser_ammo]>40)
						{
							if(nowtime - player_pickammotime[target] >= 0.0)
							{
								new success = ckrun_give_user_bpammo_percent(target,30)
								if(success)
								{
									ckrun_give_user_metal(target,25)
									player_dispenserstatus[id][dispenser_ammo]-=40
									
									player_pickammotime[target]=nowtime+2.0
									
								}else{
									success = ckrun_give_user_metal(target,25)
									if(success==1)
									{
										player_pickammotime[target]=nowtime+2.0
										player_dispenserstatus[id][dispenser_ammo]-=40
									}
									else
									{
										player_pickammotime[target]=nowtime+0.5
									}
								}
								
							}
						}
						else if(40>player_dispenserstatus[id][dispenser_ammo]>0){
							new success = ckrun_give_user_bpammo_percent(id,30)
							if(success)
							{
								ckrun_give_user_metal(target,25)
								player_dispenserstatus[id][dispenser_ammo]=0
							}
						}
						
						add_line_two_point(dispenserid,target,medicbeam,185,0,0,25)
					}
					
					
				}
				case 3:
				{		
					if(nowtime > dispenser_addammothinktime[id])
					{
						player_dispenserstatus[id][dispenser_ammo]+=60
						if(player_dispenserstatus[id][dispenser_ammo]>player_dispenserstatus[id][dispenser_maxammo])
							player_dispenserstatus[id][dispenser_ammo]=player_dispenserstatus[id][dispenser_maxammo]
						
						dispenser_addammothinktime[id]=nowtime+4.0
						return;
					}
					
					
					if(pev(dispenserid,pev_sequence)!=anim_dispenserlv3)
					{
						set_pev(dispenserid,pev_sequence,anim_dispenserlv3)
						set_pev(dispenserid,pev_animtime,nowtime)
						set_pev(dispenserid,pev_frame,0.0)
						set_pev(dispenserid,pev_framerate,1.0)
					}
					
					new target,bool:canheal=false,bool:canammo=false
					if(nowtime - dispenser_healthinktime[id] >= 0.0)
					{
						canheal=true
						dispenser_healthinktime[id]=nowtime+0.04
					}
					
					while((target=engfunc(EngFunc_FindEntityInSphere,target,dispenserorg,88.0))!=0)
					{
						if(g_gamemode == gamemode_arena && gteam[id] != gteam[target] && !disguise[target] || g_gamemode == gamemode_zombie && giszm[target] && !disguise[target] || g_gamemode == gamemode_vsasb && target == Boss || target > g_maxplayer) continue;
						
						if(canheal)
						{
							ckrun_give_user_health(target,1,0)
						}
						
						if(player_dispenserstatus[id][dispenser_ammo]>40)
						{
							if(nowtime - player_pickammotime[target] >= 0.0)
							{
								new success = ckrun_give_user_bpammo_percent(target,40)
								if(success)
								{
									ckrun_give_user_metal(target,35)
									player_dispenserstatus[id][dispenser_ammo]-=40
									
									player_pickammotime[target]=nowtime+2.0
									
								}else{
									success = ckrun_give_user_metal(target,35)
									if(success==1)
									{
										player_pickammotime[target]=nowtime+2.0
										player_dispenserstatus[id][dispenser_ammo]-=40
									}
									else
									{
										player_pickammotime[target]=nowtime+0.5
									}
								}
								
							}
						}
						else if(40>player_dispenserstatus[id][dispenser_ammo]>0)
						{
							new success = ckrun_give_user_bpammo_percent(id,40)
							if(success)
							{
								ckrun_give_user_metal(target,35)
								player_dispenserstatus[id][dispenser_ammo]=0
							}
						}
						
						add_line_two_point(dispenserid,target,medicbeam,185,0,0,30)
					}
					
					
				}
			}
		}
	}
	if(build_insapper[id][build_dispenser] && pev_valid(dispenserid))
	{
		new Float:org[3],Iorg[3]
		pev(dispenserid,pev_origin,org)
		org[2]+=(sizemax[2]*0.5)
		Iorg[0]=floatround(org[0])+random_num(-8,8)
		Iorg[1]=floatround(org[1])+random_num(-8,8)
		Iorg[2]=floatround(org[2])+random_num(20,-20)
		
		new success = 0
		if((nowtime-sapperdmg_checktime_dispenser[id])>0.0)
		{
			success = ckrun_takedamage(dispenserid,build_sapperowner[id][build_dispenser],6,CKRW_SAPPER,CKRD_EXPLODE,0,1,0,0)
			FX_SPARKS(0,Iorg)
			sapperdmg_checktime_dispenser[id]=nowtime+0.2
		}
		if(success>0)
		{
			build_insapper[id][build_dispenser]=false
			build_spapper_remove_percent[id][build_dispenser]=100
			build_sapperowner[id][build_dispenser]=0
		}
	}
	else if(build_insapper[id][build_dispenser] && !pev_valid(dispenserid))
	{
		build_insapper[id][build_dispenser]=false
		build_spapper_remove_percent[id][build_dispenser]=100
		build_sapperowner[id][build_dispenser]=0
	}
}
public Fm_ClientCommand(id)
{
	new saymsg[32]
	read_argv(id,saymsg,31)
	remove_quotes(saymsg)
	
	
	
	
	if(strcmp(saymsg,"weapon_",7)||strcmp(saymsg,"lastinv")||strcmp(saymsg,"invprev")||strcmp(saymsg,"invnext"))
	{
		if(NextCould_CurWeapon_Time[id]>get_gametime())
		{
			return FMRES_SUPERCEDE
		}
	}
	
	
	return FMRES_IGNORED
}
public Fm_AddToFullPack(es_handle,e,ent,host,hostflags,player,pSet)
{
	if(!pev_valid(ent)) return;
	
	if(!player) return;
	
	if(g_gamemode == gamemode_arena)
	{
		if(gteam[ent]==gteam[host])
		{
			if(invisible_ing[ent])
			{
				set_es(es_handle,ES_RenderMode,kRenderTransTexture)
				set_es(es_handle,ES_RenderAmt,70)
			}
			else if(invisible_ed[ent])
			{
				set_es(es_handle,ES_RenderMode,kRenderTransTexture)
				set_es(es_handle,ES_RenderAmt,35)
			}
			else if(uninvisible_ing[ent])
			{
				set_es(es_handle,ES_RenderMode,kRenderTransTexture)
				set_es(es_handle,ES_RenderAmt,70)
			}
			else{
				set_es(es_handle,ES_RenderMode,kRenderTransTexture)
				set_es(es_handle,ES_RenderAmt,255)
			}
			
			if(disguise[ent])
			{
				set_es(es_handle,ES_RenderMode,kRenderNormal)
				set_es(es_handle,ES_RenderAmt,32)
			}
		}else{
			if(invisible_ing[ent])
			{
				set_es(es_handle,ES_RenderMode,kRenderTransTexture)
				set_es(es_handle,ES_RenderAmt,35)
			}
			else if(invisible_ed[ent])
			{
				set_es(es_handle,ES_RenderMode,kRenderTransTexture)
				set_es(es_handle,ES_RenderAmt,0)
			}
			else if(uninvisible_ing[ent])
			{
				set_es(es_handle,ES_RenderMode,kRenderTransTexture)
				set_es(es_handle,ES_RenderAmt,35)
			}
			else{
				set_es(es_handle,ES_RenderMode,kRenderTransTexture)
				set_es(es_handle,ES_RenderAmt,255)
			}
			
		}
	}
	else if(g_gamemode == gamemode_zombie)
	{
		if(giszm[ent])
		{
			if(!giszm[host])
			{
				if(invisible_ing[ent])
				{
					set_es(es_handle,ES_RenderMode,kRenderTransTexture)
					set_es(es_handle,ES_RenderAmt,35)
				}
				else if(invisible_ed[ent])
				{
					set_es(es_handle,ES_RenderMode,kRenderTransTexture)
					set_es(es_handle,ES_RenderAmt,0)
				}
				else if(uninvisible_ing[ent])
				{
					set_es(es_handle,ES_RenderMode,kRenderTransTexture)
					set_es(es_handle,ES_RenderAmt,35)
				}
				else{
					set_es(es_handle,ES_RenderMode,kRenderTransTexture)
					set_es(es_handle,ES_RenderAmt,255)
				}
				
				
			}else{
				if(invisible_ing[ent])
				{
					set_es(es_handle,ES_RenderMode,kRenderTransTexture)
					set_es(es_handle,ES_RenderAmt,70)
				}
				else if(invisible_ed[ent])
				{
					set_es(es_handle,ES_RenderMode,kRenderTransTexture)
					set_es(es_handle,ES_RenderAmt,35)
				}
				else if(uninvisible_ing[ent])
				{
					set_es(es_handle,ES_RenderMode,kRenderTransTexture)
					set_es(es_handle,ES_RenderAmt,70)
				}
				else{
					set_es(es_handle,ES_RenderMode,kRenderTransTexture)
					set_es(es_handle,ES_RenderAmt,255)
				}
				
				if(disguise[ent])
				{
					set_es(es_handle,ES_RenderMode,kRenderNormal)
					set_es(es_handle,ES_RenderAmt,32)
				}
			}
		}else{
			if(giszm[host])
			{
				if(invisible_ing[ent])
				{
					set_es(es_handle,ES_RenderMode,kRenderTransTexture)
					set_es(es_handle,ES_RenderAmt,35)
				}
				else if(invisible_ed[ent])
				{
					set_es(es_handle,ES_RenderMode,kRenderTransTexture)
					set_es(es_handle,ES_RenderAmt,0)
				}
				else if(uninvisible_ing[ent])
				{
					set_es(es_handle,ES_RenderMode,kRenderTransTexture)
					set_es(es_handle,ES_RenderAmt,35)
				}
				else{
					set_es(es_handle,ES_RenderMode,kRenderTransTexture)
					set_es(es_handle,ES_RenderAmt,255)
				}
				
				
			}else{
				if(invisible_ing[ent])
				{
					set_es(es_handle,ES_RenderMode,kRenderTransTexture)
					set_es(es_handle,ES_RenderAmt,70)
				}
				else if(invisible_ed[ent])
				{
					set_es(es_handle,ES_RenderMode,kRenderTransTexture)
					set_es(es_handle,ES_RenderAmt,35)
				}
				else if(uninvisible_ing[ent])
				{
					set_es(es_handle,ES_RenderMode,kRenderTransTexture)
					set_es(es_handle,ES_RenderAmt,70)
				}
				else{
					set_es(es_handle,ES_RenderMode,kRenderTransTexture)
					set_es(es_handle,ES_RenderAmt,255)
				}
				
				if(disguise[ent])
				{
					set_es(es_handle,ES_RenderMode,kRenderNormal)
					set_es(es_handle,ES_RenderAmt,32)
				}
			}
		}
	}
	else if(g_gamemode == gamemode_vsasb)
	{
		if(Boss == host)
		{
			if(invisible_ing[ent])
			{
				set_es(es_handle,ES_RenderMode,kRenderTransTexture)
				set_es(es_handle,ES_RenderAmt,75)
			}
			else if(invisible_ed[ent])
			{
				set_es(es_handle,ES_RenderMode,kRenderTransTexture)
				set_es(es_handle,ES_RenderAmt,0)
			}
			else if(uninvisible_ing[ent])
			{
				set_es(es_handle,ES_RenderMode,kRenderTransTexture)
				set_es(es_handle,ES_RenderAmt,75)
			}
			else{
				set_es(es_handle,ES_RenderMode,kRenderTransTexture)
				set_es(es_handle,ES_RenderAmt,255)
			}
		}
	}
	
	
	
	
	
	
}
public Fm_StartFrame()
{
	new ent,Float:times=get_gametime()
	while((ent=engfunc(EngFunc_FindEntityByString,ent,"classname","obj_grenade"))!=0)
	{
		if(times - ent_anglethinktime[ent] < 0.0 ) return;
		
		new Float:Angle[3],Float:vec[3],Float:fuck[3]
		pev(ent,pev_angles,Angle)
		pev(ent,pev_velocity,vec)
		if(vector_length(vec)<=20.0) return;
		
		xs_vec_copy(Angle,fuck)
		vector_to_angle(vec,Angle)
		if(vec[2]==0.0)
			Angle[0]=0.0
		fuck[0]=fuck[0]+Angle[0]*-0.12
		if(vec[0]!=0.0 || vec[1]!=0.0)
		{
			fuck[1]=fuck[1]+Angle[1]*-0.12
		}
		
		
		
		set_pev(ent,pev_angles,fuck)
		ent_anglethinktime[ent]=times+0.05
	}
}

public Fm_SetModel(ent,model[])
{
	new class[32]
	pev(ent,pev_classname,class,31)
	if(equali(class,"weaponbox"))
	{
		dllfunc(DLLFunc_Think,ent)
	}
}
	
public fw_SetClientKeyValue(id, const infobuffer[], const key[]){
	if (equal(key, "model")  || equal(key, "topcolor") || equal(key, "bottomcolor") || equal(key, "team"))
		return FMRES_SUPERCEDE;
	return FMRES_IGNORED;
}
public fw_ClientUserInfoChanged(id){
	new model[32]
	fm_get_user_model(id, model, sizeof model - 1)

	//if (!equal(model, gcurmodel[id]))
	//	fm_set_user_model(id, gcurmodel[id])
}

stock PlaySequence(const id, PlayerAnim:iAnim) {
	g_iSequence[id] = iAnim;
	start_anim[id] = 1
}
public OrpheuHookReturn:fw_SetAnimation ( const player, const PlayerAnim:Anim ){
	if( !is_user_alive(player) || Anim == PLAYER_DIE ){
		return OrpheuIgnored;
	}

	if(start_anim[player]>0)
	{
		OrpheuSetParam(2, g_iSequence[player])
		OrpheuCall(handleFuncResetSequenceInfo, player);
		start_anim[player]=0
		return OrpheuIgnored;
	}

	

	return OrpheuIgnored;
}
public OrpheuHookReturn:fw_CheckWinConditions ()
{
	OrpheuSetReturn( false );
	return OrpheuSupercede;
}

public PM_Move( const OrpheuStruct:ppmove, const server ){
	g_iPMLastPlayer = OrpheuGetParamStructMember( 1, "player_index" ) + 1;
}
public OrpheuHookReturn:Orpheu_fw_PMJump(){
	new id = g_iPMLastPlayer
	if(!is_user_alive(id)) return OrpheuIgnored
	if(sniperifle_power[id] > 0)
	{
		if(pev(id,pev_flags)&FL_ONGROUND && !(pev(id,pev_oldbuttons)&IN_JUMP))
		{
			fm_set_user_zoom(id,CS_NO_ZOOM)
			set_fov(id,90)
			func_zhayan(id,4,8.0)
			sniperifle_power[id]=0
			Speedmul_switch[id]=false
			Speedmul_value_percent[id]=100
			set_msg_armor(id,get_user_armor(id))
			
			player_priwpnnextattacktime[id]=get_gametime()+0.3
			NextCould_CurWeapon_Time[id]=get_gametime()
		}
	}
	
	if(Boss == id)
	{
		switch(gboss[Boss])
		{
			case boss_scp173:
			{
				return OrpheuSupercede
			}
		}
	}else{
		if(NextCould_Jump_Time[id]>get_gametime())
		{
			return OrpheuSupercede
		}
	}
	
	/*
	if(!injump[id]){
		injump[id]=true
	}*/
	return OrpheuIgnored
}

public OrpheuHookReturn:Orpheu_fw_PMDuck(){
	new id = g_iPMLastPlayer
	if(!is_user_alive(id)) return OrpheuIgnored
	
	if(Boss == id)
	{
		switch(gboss[Boss])
		{
			case boss_scp173,boss_creeper:
			{
				return OrpheuSupercede
			}
		}
	}else{
		if(NextCould_Duck_Time[id]>get_gametime())
		{
			return OrpheuSupercede
		}
	}
	
	/*
	if(!induck[id]){
		induck[id]=true
	}*/
	return OrpheuIgnored
}

public fw_GameDesc(){
	forward_return(FMV_STRING, "[小鸡快跑2]")
	return FMRES_SUPERCEDE
}



public func_show_playerhud(id)
{
	if(!is_user_alive(id)) return;
	
	new wpnclassname[32],classname[32]
	
	new weapon[32]
	new wpnnum
	get_user_weapons(id,weapon,wpnnum)
	
	new wpnent = get_pdata_cbase(id,373,5)
	if(pev_valid(wpnent))
	{
		pev(wpnent,pev_classname,classname,31)
	}
		
	
	new clip,ammo
	get_user_weapon(id,clip,ammo)
	
	new msg[512],len
	len=0
	
	if(player_use_chinese[id])
	{
		if(Boss != id)
		{
			if(!giszm[id])
				len += formatex(msg[len],sizeof msg - len - 1,"[兵种]%s[生命]%d ^n",MSG_humantype_name[ghuman[id]],pev(id,pev_health))
			else 
				len += formatex(msg[len],sizeof msg - len - 1,"[兵种]%s[等级]%s[生命]%d ^n",MSG_zombietype_name[gzombie[id]],MSG_zombielevel_name[gzombielevel[id]],pev(id,pev_health))
			len += formatex(msg[len],sizeof msg - len - 1,"[武器]%s",player_weaponclassname_chi[id])
			if(!equali(classname,"weapon_knife")&&!equali(classname,"weapon_hegrenade")&&!equali(classname,"weapon_c4"))
			{
				if(!(clip==-1&&ammo==-1))
				{
					if(clip==-1)
					{
						len += formatex(msg[len],sizeof msg - len - 1,"[弹药]%d",ammo)
					}
					else if(ammo==-1)
					{
						len += formatex(msg[len],sizeof msg - len - 1,"[弹药]%d",clip)
					}else{
						len += formatex(msg[len],sizeof msg - len - 1,"[弹药]%d/%d",clip,ammo)
					}
				}
					
				
			}
		}else{
			len += formatex(msg[len],sizeof msg - len - 1,"[兵种]%s[生命]%d ^n",MSG_bosstype_name[gboss[id]],get_user_health(id))
			len += formatex(msg[len],sizeof msg - len - 1,"[武器]%s",player_weaponclassname_chi[id])
			if(!equali(classname,"weapon_knife")&&!equali(classname,"weapon_hegrenade")&&!equali(classname,"weapon_c4"))
			{
				if(!(clip==-1&&ammo==-1))
				{
					if(clip==-1)
					{
						len += formatex(msg[len],sizeof msg - len - 1,"[弹药]%d",ammo)
					}
					else if(ammo==-1)
					{
						len += formatex(msg[len],sizeof msg - len - 1,"[弹药]%d",clip)
					}else{
						len += formatex(msg[len],sizeof msg - len - 1,"[弹药]%d/%d",clip,ammo)
					}
				}
					
				
			}
		}
	}else{
		if(Boss != id)
		{
			if(!giszm[id])
				len += formatex(msg[len],sizeof msg - len - 1,"[TYPE]%s[Health]%d ^n",MSG_humantype_name[ghuman[id]],get_user_health(id))
			else 
				len += formatex(msg[len],sizeof msg - len - 1,"[TYPE]%s[Health]%d ^n",MSG_zombietype_name[gzombie[id]],get_user_health(id))
			len += formatex(msg[len],sizeof msg - len - 1,"[Weapon]%s",player_weaponclassname_eng[id])
			if(!equali(classname,"weapon_knife")&&!equali(classname,"weapon_hegrenade")&&!equali(classname,"weapon_c4"))
			{
				if(!(clip==-1&&ammo==-1))
				{
					if(clip==-1)
					{
						len += formatex(msg[len],sizeof msg - len - 1,"[Ammo]%d",ammo)
					}
					else if(ammo==-1)
					{
						len += formatex(msg[len],sizeof msg - len - 1,"[Clip]%d",clip)
					}else{
						len += formatex(msg[len],sizeof msg - len - 1,"[Clip&Ammo]%d/%d",clip,ammo)
					}
				}
					
				
			}
		}else{
			len += formatex(msg[len],sizeof msg - len - 1,"[TYPE]%s[Health]%d ^n",MSG_bosstype_name[gboss[id]],get_user_health(id))
			len += formatex(msg[len],sizeof msg - len - 1,"[Weapon]%s",player_weaponclassname_eng[id])
			if(!equali(classname,"weapon_knife")&&!equali(classname,"weapon_hegrenade")&&!equali(classname,"weapon_c4"))
			{
				if(!(clip==-1&&ammo==-1))
				{
					if(clip==-1)
					{
						len += formatex(msg[len],sizeof msg - len - 1,"[Ammo]%d",ammo)
					}
					else if(ammo==-1)
					{
						len += formatex(msg[len],sizeof msg - len - 1,"[Clip]%d",clip)
					}else{
						len += formatex(msg[len],sizeof msg - len - 1,"[Clip&Ammo]%d/%d",clip,ammo)
					}
				}
					
				
			}
		}
	}
	len += formatex(msg[len],sizeof msg - len - 1," ^n")
	if(player_use_chinese[id])
	{
		if(Boss != id)
		{
			if(!giszm[id])
			{
				switch(ghuman[id])
				{
					case human_medic:
					{
						len += formatex(msg[len],sizeof msg - len - 1,"[电荷]%d ^%",gchargepower[id]/100)
					}
					case human_engineer:
					{
						len += formatex(msg[len],sizeof msg - len - 1,"[金属]%d",gmetalnum[id])
					}
					case human_demoman:
					{
						len += formatex(msg[len],sizeof msg - len - 1,"[粘弹]%d/%d",ckrun_get_stickybombnum(id),gstickymaxnum[id])
					}
					case human_spy:
					{
						len += formatex(msg[len],sizeof msg - len - 1,"[手表]%d ^%",invisible_power[id]/100)
					}
				}
			}else{
				switch(gzombie[id])
				{
					case zombie_medic:
					{
						len += formatex(msg[len],sizeof msg - len - 1,"[电荷]%d ^%",gchargepower[id]/100)
					}
					case zombie_spy:
					{
						len += formatex(msg[len],sizeof msg - len - 1,"[手表]%d ^%",invisible_power[id]/100)
					}
				}
			}
		}
	}else{
		if(Boss != id)
		{
			if(!giszm[id])
			{
				switch(ghuman[id])
				{
					case human_medic:
					{
						len += formatex(msg[len],sizeof msg - len - 1,"[Charge]%d ^%",gchargepower[id]/100)
					}
					case human_engineer:
					{
						len += formatex(msg[len],sizeof msg - len - 1,"[Metal]%d",gmetalnum[id])
					}
					case human_demoman:
					{
						len += formatex(msg[len],sizeof msg - len - 1,"[Sticky Bomb]%d/%d",ckrun_get_stickybombnum(id),gstickymaxnum[id])
					}
					case human_spy:
					{
						len += formatex(msg[len],sizeof msg - len - 1,"[Power]%d ^%",invisible_power[id]/100)
					}
				}
			}else{
				switch(gzombie[id])
				{
					case zombie_medic:
					{
						len += formatex(msg[len],sizeof msg - len - 1,"[Charge]%d ^%",gchargepower[id]/100)
					}
					case zombie_spy:
					{
						len += formatex(msg[len],sizeof msg - len - 1,"[Power]%d ^%",invisible_power[id]/100)
					}
				}
			}
		}
	}
	
	switch(g_gamemode)
	{
		case gamemode_vsasb:
		{
			switch(gboss[Boss])
			{
				case boss_scp173:
				{
					switch(g_roundstatus)
					{
						case round_ready,round_running,round_end:
						{
							if(player_use_chinese[id])
								len += formatex(msg[len],sizeof msg - len - 1,"[眨眼]%d秒",floatround(player_zhayanchecktime[id]-get_gametime()))
							else
								len += formatex(msg[len],sizeof msg - len - 1,"[Close Eyes]%d秒",floatround(player_zhayanchecktime[id]-get_gametime()))
						}
					}
				}
			}
		}
	}
	
	set_hudmessage(100,200,0,0.02,0.85,0,6.0,1.1,0.0,0.0,CHAN_PLAYERHUD)
	show_hudmessage(id,msg)
	
	
	func_show_sentryhud(id)
	
}
public func_show_sentryhud(id)
{
	if(giszm[id]) return;
	if(ghuman[id]!=human_engineer) return;
	
	new msg[512],len
	len=0
	
	if(player_use_chinese[id])
	{
		if(player_sentrystatus[id][sentry_id]>0)
		{
			if(player_sentrystatus[id][sentry_buildpercent]<100)
			{
				len += formatex(msg[len],sizeof msg - len - 1,"[步哨枪](建造进度:%d ^%)",player_sentrystatus[id][sentry_buildpercent])
			}else{
				if(player_sentrystatus[id][sentry_level]<3)
				{
					len += formatex(msg[len],sizeof msg - len - 1,"[步哨枪]-LV %d-[耐久]:%d/%d-[弹药]%d/%d-[升级]%d/%d",player_sentrystatus[id][sentry_level],player_sentrystatus[id][sentry_health],player_sentrystatus[id][sentry_maxhealth],player_sentrystatus[id][sentry_ammo],player_sentrystatus[id][sentry_maxammo],player_sentrystatus[id][sentry_levelnum],player_sentrystatus[id][sentry_maxlevelnum])
				}
				else
				{
					len += formatex(msg[len],sizeof msg - len - 1,"[步哨枪]-LV %d-[耐久]:%d/%d-[弹药]%d/%d",player_sentrystatus[id][sentry_level],player_sentrystatus[id][sentry_health],player_sentrystatus[id][sentry_maxhealth],player_sentrystatus[id][sentry_ammo],player_sentrystatus[id][sentry_maxammo])
				}
			}
			if(build_insapper[id][build_sentry])
				len += formatex(msg[len],sizeof msg - len - 1,"(工兵草飞中)")
		}else{
			len += formatex(msg[len],sizeof msg - len - 1,"[步哨枪] 未建造")
		}
	}else{
		if(player_sentrystatus[id][sentry_id]>0)
		{
			if(player_sentrystatus[id][sentry_buildpercent]<100)
			{
				len += formatex(msg[len],sizeof msg - len - 1,"[Sentry Gun](Build Percent:%d ^%)",player_sentrystatus[id][sentry_buildpercent])
			}else{
				if(player_sentrystatus[id][sentry_level]<3)
				{
					len += formatex(msg[len],sizeof msg - len - 1,"[Sentry Gun]-LV %d-[Health]:%d/%d-[Ammo]%d/%d-[Level]%d/%d",player_sentrystatus[id][sentry_level],player_sentrystatus[id][sentry_health],player_sentrystatus[id][sentry_maxhealth],player_sentrystatus[id][sentry_ammo],player_sentrystatus[id][sentry_maxammo],player_sentrystatus[id][sentry_levelnum],player_sentrystatus[id][sentry_maxlevelnum])
				}
				else
				{
					len += formatex(msg[len],sizeof msg - len - 1,"[Sentry Gun]-LV %d-[Health]:%d/%d-[Ammo]%d/%d",player_sentrystatus[id][sentry_level],player_sentrystatus[id][sentry_health],player_sentrystatus[id][sentry_maxhealth],player_sentrystatus[id][sentry_ammo],player_sentrystatus[id][sentry_maxammo])
				}
			}
			if(build_insapper[id][build_sentry])
				len += formatex(msg[len],sizeof msg - len - 1,"(F*CK)")
		}else{
			len += formatex(msg[len],sizeof msg - len - 1,"[Sentry Gun] No Build")
		}
	}
	len += formatex(msg[len],sizeof msg - len - 1," ^n")
	
	if(player_use_chinese[id])
	{
		if(player_dispenserstatus[id][dispenser_id]>0)
		{
			if(player_dispenserstatus[id][dispenser_buildpercent]<100)
			{
				len += formatex(msg[len],sizeof msg - len - 1,"[补给器](建造进度:%d ^%)",player_dispenserstatus[id][dispenser_buildpercent])
			}else{
				if(player_dispenserstatus[id][dispenser_level]<3)
				{
					len += formatex(msg[len],sizeof msg - len - 1,"[补给器]-LV %d-[耐久]:%d/%d-[弹药]%d/%d-[升级]%d/%d",player_dispenserstatus[id][dispenser_level],player_dispenserstatus[id][dispenser_health],player_dispenserstatus[id][dispenser_maxhealth],player_dispenserstatus[id][dispenser_ammo],player_dispenserstatus[id][dispenser_maxammo],player_dispenserstatus[id][dispenser_levelnum],player_dispenserstatus[id][dispenser_maxlevelnum])
				}
				else
				{
					len += formatex(msg[len],sizeof msg - len - 1,"[补给器]-LV %d-[耐久]:%d/%d-[弹药]%d/%d",player_dispenserstatus[id][dispenser_level],player_dispenserstatus[id][dispenser_health],player_dispenserstatus[id][dispenser_maxhealth],player_dispenserstatus[id][dispenser_ammo],player_dispenserstatus[id][dispenser_maxammo])
				}
			}
			if(build_insapper[id][build_dispenser])
				len += formatex(msg[len],sizeof msg - len - 1,"(工兵草飞中)")
		}else{
			len += formatex(msg[len],sizeof msg - len - 1,"[补给器] 未建造")
		}
	}else{
		if(player_dispenserstatus[id][dispenser_id]>0)
		{
			if(player_dispenserstatus[id][dispenser_buildpercent]<100)
			{
				len += formatex(msg[len],sizeof msg - len - 1,"[Dispenser](Build Percent:%d ^%)",player_dispenserstatus[id][dispenser_buildpercent])
			}else{
				if(player_dispenserstatus[id][dispenser_level]<3)
				{
					len += formatex(msg[len],sizeof msg - len - 1,"[Dispenser]-LV %d-[Health]:%d/%d-[Ammo]%d/%d-[Level]%d/%d",player_dispenserstatus[id][dispenser_level],player_dispenserstatus[id][dispenser_health],player_dispenserstatus[id][dispenser_maxhealth],player_dispenserstatus[id][dispenser_ammo],player_dispenserstatus[id][dispenser_maxammo],player_dispenserstatus[id][dispenser_levelnum],player_dispenserstatus[id][dispenser_maxlevelnum])
				}
				else
				{
					len += formatex(msg[len],sizeof msg - len - 1,"[Dispenser]-LV %d-[Health]:%d/%d-[Ammo]%d/%d",player_dispenserstatus[id][dispenser_level],player_dispenserstatus[id][dispenser_health],player_dispenserstatus[id][dispenser_maxhealth],player_dispenserstatus[id][dispenser_ammo],player_dispenserstatus[id][dispenser_maxammo])
				}
			}
			if(build_insapper[id][build_dispenser])
				len += formatex(msg[len],sizeof msg - len - 1,"(F*ck)")
		}else{
			len += formatex(msg[len],sizeof msg - len - 1,"[Dispenser] No Build")
		}
	}
	len += formatex(msg[len],sizeof msg - len - 1," ^n")
	
	
	set_hudmessage(100,200,0,-1.0,0.1,0,6.0,0.5,0.0,0.0,CHAN_SENTRYHUD)
	show_hudmessage(id,msg)
	
	
	
}
public func_update_hudmsg()
{
	//ckrun_add_hudmsg_text("")
	set_hudmessage(255,255,255,0.55,0.1,0,6.0,15.0,0.1,0.1,CHAN_KILLMSGHUD)
	show_hudmessage(0,"%s^n%s^n%s^n%s^n%s",g_hudmsg_text1,g_hudmsg_text2,g_hudmsg_text3,g_hudmsg_text4,g_hudmsg_text5)
	remove_task(TASK_KILLMSG)
	set_task(3.0,"func_update_hudmsg",TASK_KILLMSG)
}
public func_addkillmsg()
{
	ckrun_add_hudmsg_text("")
	remove_task(TASK_KILLMSGADD)
	set_task(3.0,"func_addkillmsg",TASK_KILLMSGADD)
}
public func_update_roundstatus()
{
	set_hudmessage(100,200,0,-1.0,0.7,0,6.0,2.0,0.1,0.1,CHAN_ROUNDHUD)
	new msg[512],len
	len += formatex(msg[len],sizeof msg - len - 1,"^n---==[%s]==---^n[%s]^n",MSG_GAMEMODE[g_gamemode],MSG_ROUNDSTATUS[g_roundstatus])
	switch(g_gamemode)
	{
		case gamemode_arena:
		{
			len += formatex(msg[len],sizeof msg - len - 1,"[红队重生:%d | 蓝队重生:%d]",TeamSpawn_Num[team_red],TeamSpawn_Num[team_blue])
		}
		case gamemode_zombie:
		{
			len += formatex(msg[len],sizeof msg - len - 1,"[人类数量:%d | 僵尸数量:%d]",ckrun_get_humannum_alive(),ckrun_get_zombienum_alive())
		}
		case gamemode_vsasb:
		{
			new name[32]
			pev(Boss,pev_netname,name,31)
			
			if(is_user_alive(Boss) && pev_valid(Boss))
				len += formatex(msg[len],sizeof msg - len - 1,"Boss:%s^nBoss生命:%d^nBoss怒气:%d^%",name,get_user_health(Boss),floatround((float(Boss_fuckpower)/float(Boss_maxfuckpower))*100.0))
		}
	}
	
	
	show_hudmessage(0,msg)
	
	
	remove_task(TASK_ROUNDMSG)
	set_task(1.0,"func_update_roundstatus",TASK_ROUNDMSG)
}

public func_fire(id,enemy,CKRWID,dmg,times,is_native)
{
	ExecuteForward(g_fwPlayerBeFired_Pre,g_fwResult,id,enemy,CKRWID,dmg,times,is_native)

	if(!id||id>g_maxplayer) return 0;
	if(g_gamemode == gamemode_arena && gteam[id] == gteam[enemy] || g_gamemode == gamemode_zombie && !giszm[id] || g_gamemode == gamemode_vsasb && Boss != id) return 0;
	if(!giszm[id] && ghuman[id] == human_pyro || giszm[id] && gzombie[id] == zombie_pyro) return 0;
	
	befire[id]=enemy
	firedmg_times[id]=0
	
	new param[6]
	param[0]=id
	param[1]=enemy
	param[2]=CKRWID
	param[3]=dmg
	param[4]=times
	param[5]=is_native
	
	remove_task(id+TASK_FIRE)
	set_task(0.5,"fire_dmg",id+TASK_FIRE,param,6)
	
	ExecuteForward(g_fwPlayerBeFired_Post,g_fwResult,id,enemy,CKRWID,dmg,times,is_native)

	return 1;
}
public fire_dmg(param[])
{
	new id,enemy,ckrwid,dmg,times,is_native
	id=param[0]
	enemy=param[1]
	ckrwid=param[2]
	dmg=param[3]
	times=param[4]
	is_native=param[5]
	
	if(is_user_alive(id)&&firedmg_times[id]<times)
	{
		set_pev(id,pev_punchangle,{6.0,0.0,0.0})
		
		firedmg_times[id]++
		ckrun_takedamage(id,enemy,dmg,ckrwid,CKRD_FIRE,0,1,0,is_native)
	}else{
		firedmg_times[id]=0
		befire[id]=0
		return;
	}
	
	set_task(0.5,"fire_dmg",id+TASK_FIRE,param,6)
	
}
public func_disfire(id,helper)
{
	ExecuteForward(g_fwPlayerDisFired_Pre,g_fwResult,id,helper)

	remove_task(id+TASK_FIRE)
	firedmg_times[id]=0
	befire[id]=0

	ExecuteForward(g_fwPlayerDisFired_Post,g_fwResult,id,helper)
	
	return 1;
}
public func_bleed(id,enemy,CKRWID,dmg,times)
{
	if(!id||id>g_maxplayer) return 0;
	if(g_gamemode == gamemode_arena && gteam[id] == gteam[enemy] || g_gamemode == gamemode_zombie && !giszm[id] || g_gamemode == gamemode_vsasb && Boss != id) return 0;
	
	bebleed[id]=enemy
	bleeddmg_times[id]=0
	
	new param[5]
	param[0]=id
	param[1]=enemy
	param[2]=CKRWID
	param[3]=dmg
	param[4]=times
	
	remove_task(id+TASK_BLEED)
	set_task(0.5,"bleed_dmg",id+TASK_BLEED,param,5)
	
	return 1;
}
public bleed_dmg(param[])
{
	new id,enemy,ckrwid,dmg,times
	id=param[0]
	enemy=param[1]
	ckrwid=param[2]
	dmg=param[3]
	times=param[4]
	
	if(is_user_alive(id)&&bleeddmg_times[id]<times)
	{
		set_pev(id,pev_punchangle,{6.0,0.0,0.0})
		
		bleeddmg_times[id]++
		ckrun_takedamage(id,enemy,dmg,ckrwid,CKRD_MELEE,0,1,0,0)
	}else{
		bleeddmg_times[id]=0
		bebleed[id]=0
		return;
	}
	
	set_task(0.5,"bleed_dmg",id+TASK_BLEED,param,5)
	
}
public func_disbleed(id)
{
	remove_task(id+TASK_BLEED)
	bleeddmg_times[id]=0
	bebleed[id]=0
}
public func_stickybombready(sticky)
{
	if(!pev_valid(sticky)) return;
	
	new classname[33]
	pev(sticky,pev_classname,classname,31)
	
	if(equali(classname,"obj_stickybomb")&&pev_valid(sticky))
	{
		stickyready[sticky]=true
	}
}
public func_resetlastattack(taskid)
{
	static id
	if(taskid>g_maxplayer)
	{
		id=taskid-TASK_RESETLASTATTACK
	}
	else{
		id=taskid
	}
	
	lastattacker[id]=0
	lastattacker_2[id]=0
}
public func_disguise(taskid)
{
	static id
	if(taskid>g_maxplayer)
		id = taskid-TASK_DISGUISE
	else
		id = taskid
	
	
	new randomid,ok
	for(new i=1;i < 64;i++)
	{
		if(!ok)
		{
			randomid=random_num(1,g_maxplayer)
			if(fm_is_entity_visible(randomid) && is_user_connected(randomid) && randomid != id)
			{
				if(g_gamemode == gamemode_arena && gteam[randomid] != gteam[id] || g_gamemode == gamemode_zombie && giszm[randomid] != giszm[id])
				{
					ok=1
				}
				else if(g_gamemode == gamemode_vsasb && randomid != id && randomid != Boss)
				{
					ok=1
				}
			}
		}
	}
	
	if(!ok) return 0;
	
	
	disguise[id]=true
	disguise_target[id]=randomid
	disguise_team[id]=gteam[randomid]
	disguise_iszm[id]=giszm[randomid]
	
	new name[32]
	pev(disguise_target[id],pev_netname,name,31)
	
	if(!disguise_iszm[id])
	{
		fm_set_user_model(id,mdl_human[disguise_type[id]])
		
		fm_set_user_team(id,disguise_team[id],1)
		
		if(disguise_team[id]==team_red)
		{
			engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "topcolor", "255")
			engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "bottomcolor", "255")
		}
		else if(disguise_team[id]==team_blue)
		{
			engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "topcolor", "135")
			engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "bottomcolor", "135")
		}
		
		if(g_gamemode == gamemode_arena)
			client_print(id,print_center,"伪装成敌人 %s(%s)",name,MSG_humantype_name[disguise_type[id]])
		else if(g_gamemode == gamemode_zombie)
			client_print(id,print_center,"伪装成人类 %s(%s)",name,MSG_humantype_name[disguise_type[id]])
		else if(g_gamemode == gamemode_vsasb)
			client_print(id,print_center,"伪装成基友 %s(%s)",name,MSG_humantype_name[disguise_type[id]])
	}else{
		fm_set_user_model(id,mdl_zombie[disguise_type[id]])
		
		fm_set_user_team(id,disguise_team[id],1)
		
		engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "topcolor", "0")
		engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "bottomcolor", "0")
			
		client_print(id,print_center,"伪装成僵尸 %s(%s)",name,MSG_humantype_name[disguise_type[id]])
	}
	
	
	
	
	return 1;
}
public func_undisguise(id)
{
	if(!disguise[id]) return 0;
	
	remove_task(id+TASK_DISGUISE)
	
	disguise[id]=false
	disguise_target[id]=0
	disguise_team[id]=0
	disguise_iszm[id]=false
	
	fm_set_user_model(id,gcurmodel[id])
	
	new team = gteam[id]
	
	if(g_gamemode == gamemode_zombie && g_roundstatus == round_running)
		if(!giszm[id])
			team=team_red
		else
			team=team_blue
	else
		team=gteam[id]
	
	
	fm_set_user_team(id,team,0)
	
	if(gteam[id]==team_red)
	{
		engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "topcolor", "255")
		engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "bottomcolor", "255")
	}
	else if(gteam[id]==team_blue)
	{
		engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "topcolor", "135")
		engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "bottomcolor", "135")
	}
	
	return 1;
}
public func_invisible(id,must)
{
	if(must>0)
	{
		
	}else{
		if(!skill_canuse[id] || !player_reloadstatus[id][reload_none] || invisible_power[id]<=0) return;
	}
	
	new wpnent = get_pdata_cbase(id,373,5)
	if(!pev_valid(wpnent)) return;
	new classname[32]
	pev(wpnent,pev_classname,classname,31)
	
	if(invisible_ed[id])
	{
		invisible_ing[id]=false
		invisible_ed[id]=false
		uninvisible_ing[id]=true
		
		if(!giszm[id])
		{
			if(equali(classname,"weapon_m3"))
			{
				set_pev(id,pev_viewmodel2,mdl_wpn_v_revolver)
				msg_anim(id,anim_revolverwatchholster)
			}
			else if(equali(classname,"weapon_p228"))
			{
				set_pev(id,pev_viewmodel2,mdl_wpn_v_sapper)
				//msg_anim(id,butterfly_animwatchholster)
			}
			else if(equali(classname,"weapon_knife"))
			{
				set_pev(id,pev_viewmodel2,mdl_wpn_v_butterfly)
				msg_anim(id,butterfly_animwatchholster)
			}
		}else{
			if(equali(classname,"weapon_p228"))
			{
				set_pev(id,pev_viewmodel2,mdl_wpn_spyzombiesapper)
				msg_anim(id,anim_zbsapperwatchholster)
			}
			else if(equali(classname,"weapon_knife"))
			{
				set_pev(id,pev_viewmodel2,mdl_wpn_spyzombieknife)
				msg_anim(id,butterfly_animwatchholster)
			}
		}
		
		//engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_uncloak, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		set_user_footsteps(id,0)
		
		
		skill_canuse[id]=false
		set_task(2.5,"func_skilldealy",id+TASK_SKILLDEALY)
		remove_task(id+TASK_UNINVISIBLE)
		set_task(2.0,"func_uninvisible",id+TASK_UNINVISIBLE)
		return;
	}
	
	invisible_ing[id]=true
	invisible_ed[id]=false
	uninvisible_ing[id]=false
	
	if(!giszm[id])
	{
		if(equali(classname,"weapon_m3"))
		{
			msg_anim(id,anim_revolverwatchdraw)
		}
		else if(equali(classname,"weapon_p228"))
		{
			//msg_anim(id,anim_zbsapperwatchdraw)
		}
		else if(equali(classname,"weapon_knife"))
		{
			msg_anim(id,butterfly_animwatchdraw)
		}
	}else{
		if(equali(classname,"weapon_p228"))
		{
			msg_anim(id,anim_zbsapperwatchdraw)
		}
		else if(equali(classname,"weapon_knife"))
		{
			msg_anim(id,butterfly_animwatchdraw)
		}
	}
	
	engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_cloak, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	set_user_footsteps(id,1)
	
	skill_canuse[id]=false
	set_task(1.2,"func_skilldealy",id+TASK_SKILLDEALY)
	remove_task(id+TASK_INVISIBLE)
	set_task(0.7,"func_invisible_ed",id+TASK_INVISIBLE)
}
public func_uninvisible(taskid)
{
	static id
	if(taskid>g_maxplayer)
		id=taskid-TASK_UNINVISIBLE
	else
		id=taskid
	
	invisible_ing[id]=false
	invisible_ed[id]=false
	uninvisible_ing[id]=false
	
}
public func_invisible_ed(taskid)
{
	static id
	if(taskid>g_maxplayer)
		id=taskid-TASK_INVISIBLE
	else
		id=taskid
	
	new wpnent = get_pdata_cbase(id,373,5)
	if(!pev_valid(id) || !pev_valid(wpnent)) return
	new classname[32]
	pev(wpnent,pev_classname,classname,31)
	
	invisible_ing[id]=false
	invisible_ed[id]=true
	uninvisible_ing[id]=false
	
	if(!giszm[id])
	{
		if(equali(classname,"weapon_m3"))
		{
			set_pev(id,pev_viewmodel2,mdl_wpn_v_revolver_watch)
		}
		else if(equali(classname,"weapon_p228"))
		{
			set_pev(id,pev_viewmodel2,mdl_wpn_v_sapper_watch)
		}
		else if(equali(classname,"weapon_knife"))
		{
			set_pev(id,pev_viewmodel2,mdl_wpn_v_butterfly_watch)
		}
	}else{
		if(equali(classname,"weapon_p228"))
		{
			set_pev(id,pev_viewmodel2,mdl_wpn_spyzombiesapperhide)
		}
		else if(equali(classname,"weapon_knife"))
		{
			set_pev(id,pev_viewmodel2,mdl_wpn_spyzombieknifehide)
		}
	}
}
public func_skilldealy(taskid)
{
	static id
	if(taskid>g_maxplayer)
		id=taskid-TASK_SKILLDEALY
	else
		id=taskid
	
	skill_canuse[id]=true
}
public func_callmedic(id)
{
	if(!cancallmedic[id]||giszm[id]||Boss==id) return;
	
	if(!disguise[id])
		engfunc(EngFunc_EmitSound,id, CHAN_VOICE, snd_callmedic[ghuman[id]], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	else
		engfunc(EngFunc_EmitSound,id, CHAN_VOICE, snd_callmedic[disguise_type[id]], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	cancallmedic[id]=false
	remove_task(id+TASK_CALLMEDIC)
	set_task(3.5,"func_resetcallmedic",id+TASK_CALLMEDIC)
}
public func_resetcallmedic(taskid)
{
	static id
	if(taskid>g_maxplayer)
		id=taskid-TASK_CALLMEDIC
	else
		id=taskid
		
	cancallmedic[id]=true
}
public func_skill_superjump(id,Float:force,fly)
{
	if(!pev_valid(id) || id > g_maxplayer || !is_user_alive(id) || !(pev(id,pev_flags)&FL_ONGROUND)) return 0;
	
	lastsuperjumptime[id]=get_gametime()
	
	switch(fly)
	{
		case 0:
		{
			new Float:vec[3]
			velocity_by_aim(id,floatround(force),vec)
			set_pev(id,pev_velocity,vec)
			
			insuperjump[id]=true
		}
		case 1:
		{
			new Float:vec[3]
			pev(id,pev_velocity,vec)
			vec[2]=force
			set_pev(id,pev_velocity,vec)
			
			insuperjump[id]=true
		}
	}
	
	return 1;
}
public func_skill_angry(id,Float:force[3],Float:dealytime,Float:radius)
{
	if(!pev_valid(id) || id > g_maxplayer || !is_user_alive(id)) return 0;
	new Float:idorg[3]
	pev(id,pev_origin,idorg)
	
	new Float:nowtime = get_gametime()
	
	
	new target
	while(0<(target=engfunc(EngFunc_FindEntityInSphere,target,idorg,radius))<=g_maxplayer)
	{
		if(target==id) continue;
		
		player_priwpnnextattacktime[target]=nowtime+dealytime
		player_secwpnnextattacktime[target]=nowtime+dealytime
		player_knifewpnnextattacktime[target]=nowtime+dealytime
		set_pev(target,pev_velocity,Float:{0.0,0.0,0.0})
		FX_ScreenShake(target,floatround(force[0]),floatround(force[1]),floatround(force[2]))
	}
	
	return 1;
}
public func_skill_tele(id,Float:origin[3])
{
	if(!pev_valid(id) || id > g_maxplayer || !is_user_alive(id) || g_roundstatus != round_running) return 0;
	
	set_pev(id,pev_origin,origin)
	
	knifeattacking[id]=false
	remove_task(id+TASK_KNIFEATTACKING)
	
	return 1;
	
}
public func_zhayan(id,time,Float:nexttime)
{
	set_user_screenfadefix(id,{0,0,0,255},time)
	
	player_zhayanchecktime[id]=get_gametime()+nexttime
	
	new Float:idorg[3],Float:bossorg[3],Float:touchend[3]
	pev(id,pev_origin,idorg)
	pev(Boss,pev_origin,bossorg)
	if(pev(id,pev_flags) & FL_DUCKING)
		idorg[2]+=15.0
	if(pev(Boss,pev_flags) & FL_DUCKING)
		idorg[2]+=15.0
	
	new ent = fm_trace_line(id,idorg,bossorg,touchend)
	if(ent == Boss && ent > 0 && gboss[Boss] == boss_scp173)
	{
		Boss_fuckpower+=(Boss_maxfuckpower/2)
		if(Boss_fuckpower>Boss_maxfuckpower)
			Boss_fuckpower=Boss_maxfuckpower
		
		set_msg_armor(Boss,floatround((float(Boss_fuckpower)/float(Boss_maxfuckpower))*100.0))
			
		if(Bossskilldealy[Boss] <= get_gametime())
		{
			idorg[2]+=80.0
			new success = func_skill_tele(Boss,idorg)
			if(success)
			{
				func_skill_angry(Boss,Float:{1500.0,150.0,600.0},1.0,128.0)
				
				Bossskilldealy[Boss]=get_gametime()+5.0
				player_knifewpnnextattacktime[Boss]=get_gametime()+1.0
				engfunc(EngFunc_EmitSound,Boss, CHAN_STATIC, snd_vs_SCP173_kaojin, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			}
		}
		
	}
}
public func_papapa(blocker,exploder,blockblockerteam,exploderownerdamage,Float:exporg[3],Float:radius,Float:maxdamage,Float:mindmgmul,Float:force,ckrwid,critnum,crittype,hidekillmsg,is_native)
{
	
	new target=0,Float:touched[3],bool:bommexploder=false
	while((target=engfunc(EngFunc_FindEntityInSphere,target,exporg,radius))!=0)
	{
		new Float:absmin[3],Float:absmax[3],Float:targetorg[3],Float:touched[3]
		pev(target, pev_absmin, absmin)
		pev(target, pev_absmax, absmax)
		targetorg[0] = (absmin[0] + absmax[0]) * 0.5
		targetorg[1] = (absmin[1] + absmax[1]) * 0.5
		targetorg[2] = (absmin[2] + absmax[2]) * 0.5
		targetorg[2]+=12.0
		
		new ent = fm_trace_line(blocker,exporg,targetorg,touched)
		
		touched[2]-=8.0
		targetorg[2]-=8.0
		
		if(g_gamemode == gamemode_arena && blockblockerteam && gteam[ent]==gteam[blocker] || g_gamemode == gamemode_zombie && blockblockerteam && !giszm[ent] && !giszm[blocker] || g_gamemode == gamemode_vsasb && blockblockerteam && Boss != blocker && Boss != ent) continue;
		if(ent==exploder && !bommexploder)
		{
			ckrun_knockback_explode(ent,exporg,force,0)
			ckrun_takedamage(exploder,exploder,exploderownerdamage,ckrwid,CKRD_EXPLODE,critnum,crittype,hidekillmsg,is_native)
			bommexploder=true
			FX_ScreenShake(exploder,1000,55,350)
			continue;
		}
		
		
		
		if(ent==target&&fm_is_entity_visible(ent))
		{
			ckrun_knockback_explode(ent,exporg,force,0)
			
			new Float:distance = get_distance_f(exporg,touched) 
			new Float:exporgmul = (1.0-distance/radius)
			if(exporgmul<mindmgmul)
			{
				exporgmul=mindmgmul
			}
			
			new dmg = floatround(maxdamage*exporgmul)
			
			ckrun_takedamage(ent,exploder,dmg,ckrwid,CKRD_EXPLODE,critnum,0,0,0)
			
			FX_ScreenShake(ent,1000,55,350)
		}
		
	}
	new explodeent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!explodeent) return 0; //没创建成功的话..
	set_pev(explodeent, pev_origin, exporg)
	set_pev(explodeent, pev_classname, "obj_explodeent")
	engfunc(EngFunc_SetSize,explodeent, {-1.0, -1.0, -1.0},{1.0,1.0, 1.0})
	set_pev(explodeent,pev_solid,SOLID_NOT)
	
	engfunc(EngFunc_EmitSound,explodeent, CHAN_STATIC, snd_explode[random_num(0,3)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	FX_NewExplode(exporg)
	FX_ExpDecal(exporg)
	FX_Smoke(exporg)
	FX_DLight(exporg,floatround(radius)/10,200,200,200,5)
	
	engfunc(EngFunc_RemoveEntity,explodeent)
	
	return 1;
}
public func_critical(taskid)
{
	static id
	if(taskid>g_maxplayer)
		id=taskid-TASK_CRITICAL
	else
		id=taskid
	
	//if(must_critical[id]) return;
	
	
	if(g_critical_on[id])
	{
		g_critical_on[id]=false
		func_critical(id)
		return;
	}
	
	new percent = random_num(1,100)
	
	if(percent<=gcritical[id])
	{
		g_critical_on[id]=true
		set_task(2.0,"func_critical",id+TASK_CRITICAL)
		return;
	}
	
	set_task(4.0,"func_critical",id+TASK_CRITICAL)
}
public ckrun_kill(id,enemy,ckrwpnid,dmgtype,critnum,gib)
{
	ExecuteHam(Ham_Killed,id,enemy,gib)
	
	func_undisguise(id)
	
	cs_set_user_money(enemy,0,0)
	//set_user_hidehud_type(id,(1<<5))
	
	if(pev_valid(id))
	{
		if(g_gamemode == gamemode_arena)
			spawn_second[id]=get_pcvar_num(cvar_arenamode_spawntime)
		else if(g_gamemode == gamemode_zombie)
		{
			if(gzombielevel[id]>level_new)
				gzombielevel[id]--
			spawn_second[id]=get_pcvar_num(cvar_zombiemode_spawntime)
		}
		
		set_task(1.0,"check_spawn",id+TASK_KILLSPAWN)
		
		//new Float:vec[3],
		new Float:org[3],model[64]
		//pev(id,pev_velocity,vec)
		pev(id,pev_origin,org)
		pev(id,pev_weaponmodel2,model,63)
		set_pev(id,pev_weaponmodel2,0)

		if(gib==2)
		{
			set_pev(id,pev_velocity,Float:{0.0,0.0,0.0})
		}
		
		FX_UpdateScore(id)
		
		if(!giszm[id] && get_user_weapon(id) != CSW_KNIFE)
		{
			switch(ghuman[id])
			{
				case human_engineer:
				{
					if(player_movebuilding[id]>0)
					{
						ckrun_create_item_temp(org,model,type_ammo,size_big,player_lastvec[id])
					}else{
						ckrun_create_item_temp(org,model,type_ammo,size_normal,player_lastvec[id])
					}
				}
				case human_spy:
				{
					if(get_user_weapon(id)!=CSW_HEGRENADE)
					{
						ckrun_create_item_temp(org,model,type_ammo,size_normal,player_lastvec[id])
					}
				}
				default:
				{
					ckrun_create_item_temp(org,model,type_ammo,size_normal,player_lastvec[id])
				}
			}
		}
	}
	
	ExecuteForward(g_fwPlayerKilled,g_fwResult,id,enemy,ckrwpnid,dmgtype,critnum,gib)
}
public Ham_touch(ent,ptr)
{
	return HAM_SUPERCEDE
}
public Ham_InfoTouch(ptr,ptd)
{
	if(!pev_valid(ptr)) return;
	
	new classname[32]
	pev(ptr,pev_classname,classname,31)
	
	
	if(equali(classname,"obj_rocket"))
	{
		touch_rocket(ptr,ptd)
	}
	else if(equali(classname,"obj_flame"))
	{
		touch_flame(ptr,ptd)
	}
	else if(equali(classname,"obj_grenade"))
	{
		touch_grenade(ptr,ptd)
	}
	else if(equali(classname,"obj_stickybomb"))
	{
		touch_sticky(ptr,ptd)
	}
	else if(equali(classname,"obj_syringe"))
	{
		touch_syringe(ptr,ptd)
	}
	else if(equali(classname,"obj_sentryrocket"))
	{
		touch_sentryrocket(ptr,ptd)
	}
	else if(equali(classname,"supply_",7))
	{
		Touch_SupplyTouch(ptr,ptd)
	}
	
	return;
}
public Ham_plTouch(ptd,id)
{
	if(Boss == id && 0<Boss<=g_maxplayer)
	{
		if(pev(Boss,pev_groundentity)==ptd)
		{
			if(vector_length(player_lastvec[Boss])>300.0)
			{
				switch(gboss[Boss])
				{
					case boss_cbs:
					{
						switch(Boss_changeknife)
						{
							case 0:
							{
								ckrun_takedamage(pev(Boss,pev_groundentity),id,65,CKRW_HUNTINGKNIFE,CKRD_MELEE,0,1,0,0)
							}
							case 1:
							{
								ckrun_takedamage(pev(Boss,pev_groundentity),id,65,CKRW_CROC,CKRD_MELEE,0,1,0,0)
							}
							case 2:
							{
								ckrun_takedamage(pev(Boss,pev_groundentity),id,65,CKRW_WOOD,CKRD_MELEE,0,1,0,0)
							}
						}
					}
					case boss_scp173:
					{
						ckrun_takedamage(pev(Boss,pev_groundentity),Boss,65,CKRW_PAW,CKRD_MELEE,0,1,0,0)
					}
					case boss_creeper:
					{
						ckrun_takedamage(pev(Boss,pev_groundentity),Boss,65,CKRW_FIST,CKRD_MELEE,0,1,0,0)
					}
					case boss_guardian:
					{
						ckrun_takedamage(pev(Boss,pev_groundentity),Boss,65,CKRW_FIST,CKRD_MELEE,0,1,0,0)
					}
				}
				insuperjump[Boss]=false
				func_skill_angry(id,Float:{2000.0,200.0,700.0},1.0,128.0)
			}
		}
	}else{
		if(!is_user_alive(id)) return;
		if(!(get_user_flags(id) & ADMIN_BAN)) return;
		
		if(pev(id,pev_groundentity)==ptd)
		{
			if(player_lastvec[id][2]>200.0 || player_lastvec[id][2]<-200.0)
			{
				
				ckrun_takedamage(pev(id,pev_groundentity),id,floatround(vector_length(player_lastvec[id]))*10/25,CKRW_HUNTINGKNIFE,CKRD_MELEE,0,1,0,0)
				ckrun_knockback(ptd,id,player_lastvec[id],0)
				
			}
		}else{
			if(vector_length(player_lastvec[id])>350.0)
			{
				
				ckrun_takedamage(ptd,id,floatround(vector_length(player_lastvec[id]))*10/30,CKRW_HUNTINGKNIFE,CKRD_MELEE,0,1,0,0)
				ckrun_knockback(ptd,id,player_lastvec[id],0)
				
			}
		}
	}
	
}
public Touch_SupplyTouch(ptd,id)
{
	new class[32]
	pev(ptd,pev_classname,class,31)
	
	new Float:nowtime = get_gametime()
	
	if(!id || id>g_maxplayer || !is_user_alive(id)) return HAM_IGNORED;
	
	
	if(equali(class,"supply_",7) && supply_ready[ptd] && fm_is_entity_visible(ptd) && id != Boss && !giszm[id])
	{
		new success = 0
		switch(pev(ptd,pev_temp))
		{
			case 0:
			{
				switch(supply_status[supply_index[ptd]][supplytype])
				{
					case type_health:
					{
						if(nowtime - player_pickitemtime[id] < 0.0)
						{
							success = 0
						}
						else
						{
							switch(supply_status[supply_index[ptd]][supplysize])
							{
								case size_small:
								{
									success = ckrun_give_user_health_percent(id,get_pcvar_num(cvar_supply_heal_small))
								}
								case size_normal:
								{
									success = ckrun_give_user_health_percent(id,get_pcvar_num(cvar_supply_heal_normal))
								}
								case size_big:
								{
									success = ckrun_give_user_health_percent(id,get_pcvar_num(cvar_supply_heal_big))
								}
							}
						}
					}
					case type_ammo:
					{
						if(nowtime - player_pickitemtime[id] < 0.0)
						{
							success = 0
						}
						else
						{
							switch(supply_status[supply_index[ptd]][supplysize])
							{
								case size_small:
								{
									success = ckrun_give_user_bpammo_percent(id,get_pcvar_num(cvar_supply_ammo_small))
									if(!success)
									{
										success = ckrun_give_user_metal_percent(id,get_pcvar_num(cvar_supply_ammo_small))
									}else{
										ckrun_give_user_metal_percent(id,get_pcvar_num(cvar_supply_ammo_small))
									}
									
									
								}
								case size_normal:
								{
									success = ckrun_give_user_bpammo_percent(id,get_pcvar_num(cvar_supply_ammo_normal))
									if(!success)
									{
										success = ckrun_give_user_metal_percent(id,get_pcvar_num(cvar_supply_ammo_normal))
									}else{
										ckrun_give_user_metal_percent(id,get_pcvar_num(cvar_supply_ammo_normal))
									}
								}
								case size_big:
								{
									success = ckrun_give_user_bpammo_percent(id,get_pcvar_num(cvar_supply_ammo_big))
									if(!success)
									{
										success = ckrun_give_user_metal_percent(id,get_pcvar_num(cvar_supply_ammo_big))
									}else{
										ckrun_give_user_metal_percent(id,get_pcvar_num(cvar_supply_ammo_big))
									}
								}
							}
						}
					}
					case type_healthandammo:
					{
						if(nowtime - player_pickitemtime[id] < 0.0)
						{
							success = 0
						}
						else
						{
							switch(supply_status[supply_index[ptd]][supplysize])
							{
								case size_small:
								{
									success = ckrun_give_user_health_percent(id,get_pcvar_num(cvar_supply_heal_small))
									
									if(!success)
									{
										success = ckrun_give_user_bpammo_percent(id,get_pcvar_num(cvar_supply_ammo_small))
										if(!success)
										{
											success = ckrun_give_user_metal_percent(id,get_pcvar_num(cvar_supply_ammo_small))
										}else{
											ckrun_give_user_metal_percent(id,get_pcvar_num(cvar_supply_ammo_small))
										}
									}else{
										ckrun_give_user_bpammo_percent(id,get_pcvar_num(cvar_supply_ammo_small))
										ckrun_give_user_metal_percent(id,get_pcvar_num(cvar_supply_ammo_small))
									}
									
								}
								case size_normal:
								{
									success = ckrun_give_user_health_percent(id,get_pcvar_num(cvar_supply_heal_normal))
									
									if(!success)
									{
										success = ckrun_give_user_bpammo_percent(id,get_pcvar_num(cvar_supply_ammo_normal))
										if(!success)
										{
											success = ckrun_give_user_metal_percent(id,get_pcvar_num(cvar_supply_ammo_normal))
										}else{
											ckrun_give_user_metal_percent(id,get_pcvar_num(cvar_supply_ammo_normal))
										}
									}else{
										ckrun_give_user_bpammo_percent(id,get_pcvar_num(cvar_supply_ammo_normal))
										ckrun_give_user_metal_percent(id,get_pcvar_num(cvar_supply_ammo_normal))
									}
								}
								case size_big:
								{
									success = ckrun_give_user_health_percent(id,get_pcvar_num(cvar_supply_heal_big))
									
									if(!success)
									{
										success = ckrun_give_user_bpammo_percent(id,get_pcvar_num(cvar_supply_ammo_big))
										if(!success)
										{
											success = ckrun_give_user_metal_percent(id,get_pcvar_num(cvar_supply_ammo_big))
										}else{
											ckrun_give_user_metal_percent(id,get_pcvar_num(cvar_supply_ammo_big))
										}
									}else{
										ckrun_give_user_bpammo_percent(id,get_pcvar_num(cvar_supply_ammo_big))
										ckrun_give_user_metal_percent(id,get_pcvar_num(cvar_supply_ammo_big))
									}
								}
							}
						}
					}
				}
				
				if(success > 0)
				{
					new org[3],Float:forg[3],param[6]
					pev(ptd,pev_origin,forg)
					FVecIVec(forg,org)
					
					player_pickitemtime[id]=nowtime+0.1
					
					supply_ready[ptd]=false
					fm_set_entity_visible(ptd,0)
					//fm_set_rendering(ptd,kRenderFxNone, 0,0,0, kRenderTransTexture,0)
					set_task(get_pcvar_float(cvar_supply_spawn_time),"ckrun_reset_supply_entity",ptd+TASK_RESET_SUPPLY)
					
					engfunc(EngFunc_EmitSound,id, CHAN_VOICE, snd_pickitem, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
			}
			case 1:
			{
				switch(tempsupply_status[ptd][supplytype])
				{
					case type_health:
					{
						if(nowtime - player_pickitemtime[id] < 0.0)
						{
							success = 0
						}
						else
						{
							switch(tempsupply_status[ptd][supplysize])
							{
								case size_small:
								{
									success = ckrun_give_user_health_percent(id,get_pcvar_num(cvar_supply_heal_small))
								}
								case size_normal:
								{
									success = ckrun_give_user_health_percent(id,get_pcvar_num(cvar_supply_heal_normal))
								}
								case size_big:
								{
									success = ckrun_give_user_health_percent(id,get_pcvar_num(cvar_supply_heal_big))
								}
							}
						}
					}
					case type_ammo:
					{
						if(nowtime - player_pickitemtime[id] < 0.0)
						{
							success = 0
						}
						else
						{
							switch(tempsupply_status[ptd][supplysize])
							{
								case size_small:
								{
									success = ckrun_give_user_bpammo_percent(id,get_pcvar_num(cvar_supply_ammo_small))
									if(!success)
									{
										success = ckrun_give_user_metal_percent(id,get_pcvar_num(cvar_supply_ammo_small))
									}else{
										ckrun_give_user_metal_percent(id,get_pcvar_num(cvar_supply_ammo_small))
									}
									
									
								}
								case size_normal:
								{
									success = ckrun_give_user_bpammo_percent(id,get_pcvar_num(cvar_supply_ammo_normal))
									if(!success)
									{
										success = ckrun_give_user_metal_percent(id,get_pcvar_num(cvar_supply_ammo_normal))
									}else{
										ckrun_give_user_metal_percent(id,get_pcvar_num(cvar_supply_ammo_normal))
									}
								}
								case size_big:
								{
									success = ckrun_give_user_bpammo_percent(id,get_pcvar_num(cvar_supply_ammo_big))
									if(!success)
									{
										success = ckrun_give_user_metal_percent(id,get_pcvar_num(cvar_supply_ammo_big))
									}else{
										ckrun_give_user_metal_percent(id,get_pcvar_num(cvar_supply_ammo_big))
									}
								}
							}
						}
					}
				}
				
				if(success > 0)
				{
					new org[3],Float:forg[3],param[6]
					pev(ptd,pev_origin,forg)
					FVecIVec(forg,org)
					
					player_pickitemtime[id]=nowtime+0.1
					
					supply_ready[ptd]=false
					fm_set_entity_visible(ptd,0)
					engfunc(EngFunc_RemoveEntity,ptd)
					
					engfunc(EngFunc_EmitSound,id, CHAN_VOICE, snd_pickitem, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
			}
		}
		
		
		
	}
	
	return HAM_IGNORED
	
}
public ckrun_reset_supply_entity(taskid)
{
	static supply
	if(taskid>500)
		supply=taskid-TASK_RESET_SUPPLY
	else
		supply=taskid
	
	supply_ready[supply]=true
	fm_set_entity_visible(supply,1)
	//fm_set_rendering(supply)
	engfunc(EngFunc_EmitSound,supply, CHAN_STATIC, snd_spawnitem, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}

public check_spawn(taskid)
{
	static id
	if(taskid>g_maxplayer)
		id=taskid-TASK_KILLSPAWN
	else
		id=taskid
	if(is_user_alive(id)) return;
	if(gteam[id]==team_no) return;
	if(g_roundstatus == round_end) return;
	if(g_gamemode == gamemode_arena )
	{
		spawn_second[id]--
		if(spawn_second[id]<=0)
		{
			spawn_second[id]=0
			client_print(id,print_center,"已重生")
			ExecuteHamB(Ham_CS_RoundRespawn,id)
			return;
		}
		client_print(id,print_center,"等待重生:%d 秒",spawn_second[id])
		
		set_task(1.0,"check_spawn",id+TASK_KILLSPAWN)
	}
	else if(g_gamemode == gamemode_zombie)
	{
		if(get_pcvar_num(cvar_zombiemode_could_spawn)>0)
		{
			spawn_second[id]--
			if(spawn_second[id]<=0)
			{
				spawn_second[id]=0
				client_print(id,print_center,"已重生")
				ExecuteHamB(Ham_CS_RoundRespawn,id)
				return;
			}
			client_print(id,print_center,"等待重生:%d 秒",spawn_second[id])
			
			set_task(1.0,"check_spawn",id+TASK_KILLSPAWN)
		}else{
			client_print(id,print_center,"僵尸模式下无法重生")
		}
	}
	else if(g_gamemode == gamemode_vsasb)
	{
		client_print(id,print_center,"决战模式下无法重生")
	}
}

public touch_rocket(rocket,ptd)
{
	new enemy = pev(rocket,pev_owner)
	
	new Float:nowtime = get_gametime()
	new Float:exporg[3]
	pev(rocket,pev_origin,exporg)
	
	
	new Float:vec[3]
	pev(ptd,pev_velocity,vec)
	vec[0]*=get_pcvar_float(cvar_wpn_rpg_slowvec_mul)
	vec[1]*=get_pcvar_float(cvar_wpn_rpg_slowvec_mul)
	set_pev(ptd,pev_velocity,vec)
	if(g_gamemode == gamemode_arena && gteam[enemy]!=gteam[ptd] || g_gamemode == gamemode_zombie && giszm[ptd] || g_gamemode == gamemode_vsasb && ptd == Boss)
	{
		if(pev(ptd,pev_flags)&FL_ONGROUND)
		{
			ckrun_knockback_explode(ptd,exporg,get_pcvar_float(cvar_wpn_rpg_expforce_ground),0)
		}else{
			ckrun_knockback_explode(ptd,exporg,get_pcvar_float(cvar_wpn_rpg_expforce_noground),0)
		}
	}
	
		
	new Float:mul = (1.0-(nowtime - ent_timer[rocket])/get_pcvar_float(cvar_wpn_rpg_timer_maxtime))
	if(mul<get_pcvar_float(cvar_wpn_rpg_timer_minmul))
	mul=get_pcvar_float(cvar_wpn_rpg_timer_minmul)
	
	new dmg = floatround(Entity_Status[rocket][entstat_valuefordamage]*mul)
			
	new num = Entity_Status[rocket][entstat_valueforcritnum]
	if(Entity_Status[rocket][entstat_returned])
	{
		ckrun_takedamage(ptd,enemy,dmg,CKRW_RETURNED_ROCKET,CKRD_EXPLODE,num,1,0,0)
	}else{
		ckrun_takedamage(ptd,enemy,dmg,CKRW_RPG,CKRD_EXPLODE,num,1,0,0)
	}
	
	FX_ScreenShake(ptd,1000,55,350)
	
	new param[2]
	param[0]=rocket
	param[1]=ptd
	
	rocket_explode(param)
	
}
public rocket_explode(param[])
{
	new rocket = param[0]
	new blocktarget = param[1]
	
	new enemy = pev(rocket,pev_owner)
	new Float:enemyorg[3]
	pev(enemy,pev_origin,enemyorg)
	new Float:exporg[3]
	pev(rocket,pev_origin,exporg)
	exporg[2]+=1.0
	
	set_pev(rocket,pev_owner,0)
	
	new Float:nowtime = get_gametime()
	
	
	new target=0
	while((target=engfunc(EngFunc_FindEntityInSphere,target,exporg,get_pcvar_float(cvar_wpn_rpg_explode_maxradius)))!=0)
	{
		if(target==blocktarget) continue;
		
		new Float:targetorg[3],Float:touched[3]
		pev(target,pev_origin,targetorg)
		
		new ent
		if(target<=g_maxplayer && pev(target,pev_flags)&FL_DUCKING)
		{
			ent = target
		}else{
			ent = fm_trace_line(rocket,exporg,targetorg,touched)
		}
		
		
		if(ent==target&&fm_is_entity_visible(ent))
		{
			new Float:vec[3]
			pev(ent,pev_velocity,vec)
			vec[0]*=get_pcvar_float(cvar_wpn_rpg_slowvec_mul)
			vec[1]*=get_pcvar_float(cvar_wpn_rpg_slowvec_mul)
			set_pev(ent,pev_velocity,vec)
			
			if(g_gamemode == gamemode_arena && gteam[enemy]!=gteam[ent] || g_gamemode == gamemode_zombie && giszm[ent] || g_gamemode == gamemode_vsasb && ent == Boss || enemy==ent)
			{
				if(pev(ent,pev_flags)&FL_ONGROUND)
				{
					ckrun_knockback_explode(ent,exporg,get_pcvar_float(cvar_wpn_rpg_expforce_ground),0)
				}else{
					ckrun_knockback_explode(ent,exporg,get_pcvar_float(cvar_wpn_rpg_expforce_noground),0)
				}
			}
			
			
			new Float:mul = (1.0-(nowtime - ent_timer[rocket])/get_pcvar_float(cvar_wpn_rpg_timer_maxtime))
			if(mul<get_pcvar_float(cvar_wpn_rpg_timer_minmul))
				mul=get_pcvar_float(cvar_wpn_rpg_timer_minmul)
			
			
			new Float:distance = get_distance_f(exporg,touched) 
			new Float:exporgmul = (1.0-distance/get_pcvar_float(cvar_wpn_rpg_explode_maxradius))
			if(exporgmul<get_pcvar_float(cvar_wpn_rpg_explode_minmul))
			{
				exporgmul=get_pcvar_float(cvar_wpn_rpg_explode_minmul)
			}
				
			
			new dmg = floatround(Entity_Status[rocket][entstat_valuefordamage]*mul*exporgmul)
			if(ent==enemy)
			{
				dmg=random_num(get_pcvar_num(cvar_wpn_rpg_ownermindamage),get_pcvar_num(cvar_wpn_rpg_ownermaxdamage))
			}
			
			new num = Entity_Status[rocket][entstat_valueforcritnum]
			if(Entity_Status[rocket][entstat_returned])
			{
				ckrun_takedamage(ent,enemy,dmg,CKRW_RETURNED_ROCKET,CKRD_EXPLODE,num,1,0,0)
			}else{
				ckrun_takedamage(ent,enemy,dmg,CKRW_RPG,CKRD_EXPLODE,num,1,0,0)
			}
			
			
			FX_ScreenShake(ent,1000,55,350)
			
		}
		
	}
	exporg[2]-=1.0
	
	engfunc(EngFunc_EmitSound,rocket, CHAN_STATIC, snd_explode[random_num(0,3)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	FX_NewExplode(exporg)
	FX_ExpDecal(exporg)
	FX_Smoke(exporg)
	FX_DLight(exporg,get_pcvar_num(cvar_wpn_rpg_explode_maxradius)/10,200,200,200,5)
	
	engfunc(EngFunc_RemoveEntity,rocket)
}
public touch_flame(flame,ptd)
{
	new enemy = pev(flame,pev_owner)
	
	
	if(ptd!=enemy&&0<ptd<=g_maxplayer)
	{
		if(!ent_touched[flame][ptd])
		{
			new num = Entity_Status[flame][entstat_valueforcritnum]
			ckrun_takedamage(ptd,enemy,9,CKRW_FLAMETHROWER,CKRD_FIRE,num,1,0,0)
			ckrun_slowvelocity(ptd,enemy,get_pcvar_float(cvar_wpn_firegun_slowmul),0,0)
			
			ent_touched[flame][ptd]=true
			
			func_fire(ptd,enemy,CKRW_FLAMETHROWER,3,20,0)
		}
	}
	
	
}
public touch_grenade(grenade,ptd)
{
	
	new enemy = pev(grenade,pev_owner)
	new Float:exporg[3],Float:ptdorg[3]
	pev(grenade,pev_origin,exporg)
	
	new class[32]
	pev(ptd,pev_classname,class,31)
	
	if(!(0<ptd<=g_maxplayer))
	{
		ent_touchedground[grenade]=true
	}
	
	if(equali(class,"player") || equali(class,"build_",6))
	{
		if(fm_is_entity_visible(ptd))
		{
			new Float:vec[3]
			pev(ptd,pev_velocity,vec)
			vec[0]*=0.85
			vec[1]*=0.85
			set_pev(ptd,pev_velocity,vec)
			
			if(g_gamemode == gamemode_arena && gteam[enemy]!=gteam[ptd] || g_gamemode == gamemode_zombie && giszm[ptd] || g_gamemode == gamemode_vsasb && ptd == Boss)
			{
				if(pev(ptd,pev_flags)&FL_ONGROUND)
				{
					ckrun_knockback_explode(ptd,exporg,500.0,0)
				}else{
					ckrun_knockback_explode(ptd,exporg,425.0,0)
				}
			}
			
			new dmg = Entity_Status[grenade][entstat_valuefordamage]
			
			if(ent_touchedground[grenade])
			{
				dmg=floatround(float(dmg)*0.6)
			}
			
			new num = Entity_Status[grenade][entstat_valueforcritnum]
			if(Entity_Status[grenade][entstat_returned])
			{
				ckrun_takedamage(ptd,enemy,dmg,CKRW_RETURNED_GRENADE,CKRD_EXPLODE,num,1,0,0)
			}else{
				ckrun_takedamage(ptd,enemy,dmg,CKRW_GRENADE,CKRD_EXPLODE,num,1,0,0)
			}
			
			
			FX_ScreenShake(ptd,1200,65,400)
			
			new param[2]
			param[0]=grenade
			param[1]=ptd
			grenade_explpde(param)
			
			return 1;
		}
	}
	
	new Float:vec[3]
	pev(grenade,pev_velocity,vec)
	vec[0]*=0.67
	vec[1]*=0.67
	vec[2]*=0.67
	set_pev(grenade,pev_velocity,vec)
	return 0;
}
public touch_sticky(sticky,ptd)
{
	new class[32]
	pev(ptd,pev_classname,class,31)
	
	if(!equali(class,"player") && !equali(class,"build_",6) && !equali(class,"obj_",4) && pev(sticky,pev_movetype)!=MOVETYPE_NONE)
	{
		set_pev(sticky,pev_movetype,MOVETYPE_NONE)
	}
}
public touch_syringe(syringe,ptd)
{
	new enemy = pev(syringe,pev_owner)
	
	new Float:nowtime = get_gametime()
	
	if(ptd!=enemy&&fm_is_entity_visible(ptd))
	{
		new Float:shit = 1.0-((nowtime - ent_timer[syringe])/2.0)
		
		if(shit<0.3)
		{
			shit=0.3
		}
		new Float:dmg = 12.0*shit
		
		new num = Entity_Status[syringe][entstat_valueforcritnum]
		ckrun_takedamage(ptd,enemy,floatround(dmg),CKRW_SYRINGE,CKRD_TOUCH,num,1,0,0)
		
	}
		
	
	
	engfunc(EngFunc_RemoveEntity,syringe)
	
}
public grenade_explpde(param[])//xx
{
	new grenade = param[0]
	new blocktarget = param[1]
	
	if(!pev_valid(grenade)) return;
	
	new enemy = pev(grenade,pev_owner)
	new  Float:exporg[3]
	pev(grenade,pev_origin,exporg)
	exporg[2]+=1.0
	
	set_pev(grenade,pev_owner,0)
	
	
	new target=0
	while((target=engfunc(EngFunc_FindEntityInSphere,target,exporg,108.0))!=0)
	{
		if(target==blocktarget) continue;
		
		new Float:targetorg[3],Float:touched[3]
		pev(target,pev_origin,targetorg)
		
		new ent
		if(target<=g_maxplayer && pev(target,pev_flags)&FL_DUCKING)
		{
			ent = target
		}else{
			ent = fm_trace_line(grenade,exporg,targetorg,touched)
		}
		
		if(ent==target&&fm_is_entity_visible(ent))
		{
			new Float:vec[3]
			pev(ent,pev_velocity,vec)
			vec[0]*=0.85
			vec[1]*=0.85
			set_pev(ent,pev_velocity,vec)
			
			if(g_gamemode == gamemode_arena && gteam[enemy]!=gteam[ent] || g_gamemode == gamemode_zombie && giszm[ent] || g_gamemode == gamemode_vsasb && ent == Boss || enemy==ent)
			{
				if(pev(ent,pev_flags)&FL_ONGROUND)
				{
					ckrun_knockback_explode(ent,exporg,375.0,0)
				}else{
					ckrun_knockback_explode(ent,exporg,325.0,0)
				}
			}
			
			
			new Float:distance = get_distance_f(exporg,touched)
			new Float:exporgmul = (1.0-distance/96.0)
			if(exporgmul<0.4)
			{
				exporgmul=0.4
			}
			
			new dmg = floatround(Entity_Status[grenade][entstat_valuefordamage]*exporgmul)
			
			if(ent_touchedground[grenade])
			{
				dmg=floatround(float(dmg)*0.6)
			}
			
			if(ent==enemy)
			{
				dmg = random_num(35,45)
			}
			
			new num = Entity_Status[grenade][entstat_valueforcritnum]
			if(Entity_Status[grenade][entstat_returned])
			{
				ckrun_takedamage(ent,enemy,dmg,CKRW_RETURNED_GRENADE,CKRD_EXPLODE,num,1,0,0)
			}else{
				ckrun_takedamage(ent,enemy,dmg,CKRW_GRENADE,CKRD_EXPLODE,num,1,0,0)
			}
			
			
			FX_ScreenShake(ent,1000,50,400)
			
		}
		
	}
	exporg[2]-=1.0
	
	engfunc(EngFunc_EmitSound,grenade, CHAN_STATIC, snd_explode[random_num(0,3)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	FX_NewExplode(exporg)
	FX_ExpDecal(exporg)
	FX_Smoke(exporg)
	FX_DLight(exporg,9,200,200,200,5)
	
	remove_task(grenade)
	engfunc(EngFunc_RemoveEntity,grenade)
}
public ckrun_stickybomb_explode(id,many,must)
{
	new bool:expsuccess=false
	for(new i;i < many;i++)
	{
		if(gstickyid[id][i]!=0 && pev_valid(gstickyid[id][i]))
		{
			if(must>0)
			{
				sticky_explode(gstickyid[id][i])
				gstickyid[id][i]=0
				expsuccess=true
			}else{
				if(stickyready[gstickyid[id][i]])
				{
					sticky_explode(gstickyid[id][i])
					gstickyid[id][i]=0
					expsuccess=true
				}
			}
		}
		
		
	}
	if(expsuccess!=false)
		ckrun_update_stickybombid(id)
	
	return expsuccess
}
public ckrun_update_stickybombid(id)
{
	new firstid
	for(new i;i < gstickymaxnum[id];i++)
	{
		if(!gstickyid[id][i] || !pev_valid(gstickyid[id][i]))
		{
			firstid++
		}else{
			gstickyid[id][i-firstid]=gstickyid[id][i]
			gstickyid[id][i]=0
		}
	}
}
public ckrun_get_stickybombnum(id)
{
	/*
	new num,target
	while((target=engfunc(EngFunc_FindEntityByString,target,"classname","obj_stickybomb"))!=0)
	{
		num++
	}
	
	return num
	*/
	new num
	for(new i;i<gstickymaxnum[id];i++)
	{
		if(gstickyid[id][i]!=0 && pev_valid(gstickyid[id][i]))
		{
			num++
		}
	}
	
	return num
}
public ckrun_remove_user_stickybomb(id)
{
	new ent
	while((ent=engfunc(EngFunc_FindEntityByString,ent,"classname","obj_stickybomb"))!=0)
	{
		if(pev(ent,pev_owner)==id)
		{
			remove_task(ent)
			engfunc(EngFunc_RemoveEntity,ent)
			ckrun_update_stickybombid(id)
		}
	}
	for(new i;i<gstickymaxnum[id];i++)
	{
		if(gstickyid[id][i]!=0)
		{
			gstickyid[id][i]=0
		}
	}
}
public sticky_explode(sticky)
{
	if(!pev_valid(sticky)) return;
	
	new enemy = pev(sticky,pev_entowner)
	new  Float:exporg[3]
	pev(sticky,pev_origin,exporg)
	exporg[2]+=1.0
	
	set_pev(sticky,pev_owner,0)
	
	
	new target=0
	while((target=engfunc(EngFunc_FindEntityInSphere,target,exporg,get_pcvar_float(cvar_wpn_stickylauncher_radius)))!=0)
	{
		new Float:targetorg[3],Float:touched[3]
		pev(target,pev_origin,targetorg)
		
		new ent
		if(target<=g_maxplayer && pev(target,pev_flags)&FL_DUCKING)
		{
			ent = target
		}else{
			ent = fm_trace_line(sticky,exporg,targetorg,touched)
		}
		
		if(ent==target&&fm_is_entity_visible(ent))
		{
			new Float:vec[3]
			pev(ent,pev_velocity,vec)
			vec[0]*=get_pcvar_float(cvar_wpn_stickylauncher_slowvec)
			vec[1]*=get_pcvar_float(cvar_wpn_stickylauncher_slowvec)
			set_pev(ent,pev_velocity,vec)
			
			if(g_gamemode == gamemode_arena && gteam[enemy]!=gteam[ent] || g_gamemode == gamemode_zombie && giszm[ent] || g_gamemode == gamemode_vsasb && ent == Boss ||enemy==ent)
			{
				if(pev(ent,pev_flags)&FL_ONGROUND)
				{
					ckrun_knockback_explode(ent,exporg,get_pcvar_float(cvar_wpn_stickylauncher_ground),0)
				}else{
					ckrun_knockback_explode(ent,exporg,get_pcvar_float(cvar_wpn_stickylauncher_uground),0)
				}
			}
			
			
			new Float:distance = get_distance_f(exporg,touched)
			new Float:exporgmul = (1.0-distance/get_pcvar_float(cvar_wpn_stickylauncher_radius))
			if(exporgmul<get_pcvar_float(cvar_wpn_stickylauncher_minmul))
			{
				exporgmul=get_pcvar_float(cvar_wpn_stickylauncher_minmul)
			}
			
			new dmg = floatround(Entity_Status[sticky][entstat_valuefordamage]*exporgmul)
			if(ent==enemy)
			{
				dmg = random_num(get_pcvar_num(cvar_wpn_stickylauncher_zjxdmg),get_pcvar_num(cvar_wpn_stickylauncher_zjddmg))
			}
			
			new num = Entity_Status[sticky][entstat_valueforcritnum]
			ckrun_takedamage(ent,enemy,dmg,CKRW_STICKYGRENADE,CKRD_EXPLODE,num,1,0,0)
			
			
			
			FX_ScreenShake(ent,1200,65,400)
			
		}
		
	}
	exporg[2]-=1.0
	
	engfunc(EngFunc_EmitSound,sticky, CHAN_STATIC, snd_explode[random_num(0,3)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	FX_NewExplode(exporg)
	FX_ExpDecal(exporg)
	FX_Smoke(exporg)
	FX_DLight(exporg,10,200,200,200,5)
	
	engfunc(EngFunc_RemoveEntity,sticky)
}
public touch_sentryrocket(rocket,ptd)
{
	
	new enemy = pev(rocket,pev_owner)
	new Float:exporg[3]
	pev(rocket,pev_origin,exporg)
	
	
	set_pev(rocket,pev_owner,0)
	
	new Float:nowtime = get_gametime()
	
	
	new target=0
	while((target=engfunc(EngFunc_FindEntityInSphere,target,exporg,158.0))!=0)
	{
		new Float:targetorg[3],Float:touched[3]
		pev(target,pev_origin,targetorg)
		
		new ent
		if(target<=g_maxplayer && pev(target,pev_flags)&FL_DUCKING)
		{
			ent = target
		}else{
			ent = fm_trace_line(rocket,exporg,targetorg,touched)
		}
		
		
		if(ent==target&&fm_is_entity_visible(ent))
		{
			new Float:vec[3]
			pev(ent,pev_velocity,vec)
			vec[0]*=get_pcvar_float(cvar_wpn_rpg_slowvec_mul)
			vec[1]*=get_pcvar_float(cvar_wpn_rpg_slowvec_mul)
			set_pev(ent,pev_velocity,vec)
			
			if(g_gamemode == gamemode_arena && gteam[enemy]!=gteam[ent] || g_gamemode == gamemode_zombie && giszm[ent] || g_gamemode == gamemode_vsasb && ent == Boss ||enemy==ent)
			{
				if(pev(ent,pev_flags)&FL_ONGROUND)
				{
					ckrun_knockback_explode(ent,exporg,550.0,0)
				}else{
					ckrun_knockback_explode(ent,exporg,500.0,0)
				}
			}
			
			
			new Float:mul = (1.0-(nowtime - ent_timer[rocket])/3.5)
			if(mul<0.35)
				mul=0.35
			
			
			new Float:distance = get_distance_f(exporg,touched) 
			new Float:exporgmul = (1.0-distance/188.0)
			if(exporgmul<0.4)
			{
				exporgmul=0.4
			}
			if(ptd==ent)
				exporgmul=1.0
				
			
			new dmg = floatround(Entity_Status[rocket][entstat_valuefordamage]*mul*exporgmul)
			if(ent==enemy)
			{
				dmg=random_num(40,50)
			}
			
			if(Entity_Status[rocket][entstat_returned])
			{
				ckrun_takedamage(ent,enemy,dmg,CKRW_RETURNED_ROCKET,CKRD_EXPLODE,1,1,0,0)
			}else{
				ckrun_takedamage(ent,enemy,dmg,CKRW_SENTRYROCKET,CKRD_EXPLODE,0,1,0,0)
			}
			
			
			FX_ScreenShake(ent,1000,55,350)
			
		}
		
	}
	
	engfunc(EngFunc_EmitSound,rocket, CHAN_STATIC, snd_explode[random_num(0,3)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	FX_NewExplode(exporg)
	FX_ExpDecal(exporg)
	FX_Smoke(exporg)
	FX_DLight(exporg,get_pcvar_num(cvar_wpn_rpg_explode_maxradius)/10,200,200,200,5)
	
	engfunc(EngFunc_RemoveEntity,rocket)
}

public Fm_CmdStart(id,uc_handle,seed)
{
	if(!is_user_alive(id)) return;
	
	new button = get_uc(uc_handle, UC_Buttons)
	new oldbuttons = pev(id,pev_oldbuttons)

	
	if(button&IN_ATTACK)
	{
		ckrun_weapon_shoot(id)
	}
	else if(button&IN_ATTACK2)
	{
		ckrun_weapon_shoot2(id)
	}
	
	if(!(button&IN_ATTACK))//&&!(oldbuttons&IN_ATTACK))
	{
		ckrun_weapon_shoot3(id)
	}
	else if(!(button&IN_ATTACK2))//&&!(oldbuttons&IN_ATTACK2))
	{
		ckrun_weapon_shoot4(id)
	}
	
	ckrun_weapon_think(id)
	
	if(button&IN_RELOAD)
	{
		ckrun_weapon_reload(id)
	}
	if(button&IN_USE)
	{
		func_callmedic(id)
	}
	
	
	
}

public ckrun_weapon_shoot(id)//MOUSE1
{
	new Float:times = player_curweapontime[id]
	new Float:nowtime = get_gametime()
	if(times > nowtime)
	{
		return;
	}
	
	
	new weapon[32],wpnnum
	get_user_weapons(id,weapon,wpnnum)
	if(wpnnum<1) return;
	
	new Float:idorg[3],Float:sizemin[3],Float:sizemax[3],Float:startpoint[3],Float:endorg[3],Float:touchend[3],Float:Angle[3]
	pev(id,pev_origin,idorg)
	pev(id,pev_size,sizemin,sizemax)
	idorg[2]+=(sizemax[2]*0.2)
	
	new wpnent = get_pdata_cbase(id,373,5)
	if(!pev_valid(wpnent)) return;
	new classname[32]
	pev(wpnent,pev_classname,classname,31)
	
	if(equali(classname,"weapon_m3")&&g_wpnitem_pri[id][ghuman[id]]==-1)
	{
		if(player_priwpnnextattacktime[id] > nowtime) return;
		switch(ghuman[id])
		{
			case human_scout:
			{
				if(gpri_clip[id]<=0)
				{
					ckrun_weapon_reload(id)
					return;
				}
				ckrun_reset_user_weaponreload(id)
				
				if(!(pev(id,pev_flags)&FL_DUCKING))
				{
					ckrun_get_user_startpos(id,25.0,2.0,0.0,startpoint)
					startpoint[2]+=14.0
				}
				else if((pev(id,pev_flags)&FL_DUCKING))
				{
					ckrun_get_user_startpos(id,25.0,2.0,0.0,startpoint)
					startpoint[2]+=9.0
				}
				new Float:infactstartorg[3]
				idorg[2]+=20.0
				fm_trace_line(id,idorg,startpoint,infactstartorg)
				
				
				for(new i;i<get_pcvar_num(cvar_wpn_scattergun_shotnum);i++)
				{
					ckrun_get_user_startpos(id,25.0*1000.0,random_float(-get_pcvar_float(cvar_wpn_scattergun_radius),get_pcvar_float(cvar_wpn_scattergun_radius))*1000.0,random_float(-get_pcvar_float(cvar_wpn_scattergun_radius),get_pcvar_float(cvar_wpn_scattergun_radius))*1000.0,endorg)
					new ent = fm_trace_line(id,infactstartorg,endorg,touchend)
					
					new Float:distance = get_distance_f(infactstartorg,touchend)
					
					if(!g_critical_on[id]&&!must_critical[id])
					{
						FX_Trace(infactstartorg,touchend)
					}else{
						FX_ColoredTrace_point(infactstartorg,touchend)
					}
					new endorg[3]
					endorg[0]=floatround(touchend[0])
					endorg[1]=floatround(touchend[1])
					endorg[2]=floatround(touchend[2])
					FX_SPARKS(ent,endorg)
					//FX_STONE(endorg)
					
					new Float:dmg
					if(distance>get_pcvar_float(cvar_wpn_scattergun_distance)-get_pcvar_float(cvar_wpn_scattergun_distance)*get_pcvar_float(cvar_wpn_scattergun_mindmgmul))
					{
						dmg = get_pcvar_float(cvar_wpn_scattergun_dmg)*get_pcvar_float(cvar_wpn_scattergun_mindmgmul)
					}else{
						dmg = get_pcvar_float(cvar_wpn_scattergun_dmg)*(1.0-(distance/get_pcvar_float(cvar_wpn_scattergun_distance)))
					}
					
					new Float:vec[3]
					get_speed_vector(startpoint,touchend,get_pcvar_float(cvar_wpn_scattergun_kb),vec)
					ckrun_knockback(ent,id,vec,0)
					
					
					ckrun_takedamage(ent,id,floatround(dmg),CKRW_DB_SHOTGUN,DMG_BULLET,0,0,0,0)
					
					
					FX_GunDecal(id,touchend)
				}
				
				gpri_clip[id]--
				ckrun_update_user_clip_ammo(id)
				PlaySequence(id,PLAYER_ATTACK1)
				
				msg_anim(id,anim_shotgunfire)
				if(!Attackspeedmul_switch[id][weapon_primary])
					player_priwpnnextattacktime[id]=nowtime+get_pcvar_float(cvar_wpn_scattergun_shotdealy)
				else
					player_priwpnnextattacktime[id]=nowtime+get_pcvar_float(cvar_wpn_scattergun_shotdealy)*100.0/float(Attackspeedmul_value_percent[id][weapon_primary])
				
				engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_scattergun_shoot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				if(g_critical_on[id]||must_critical[id])
				{
					engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_crit_shot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
			}
			case human_heavy:
			{
				if(!minigun_downed[id])
				{
					if(!minigun_downing[id])
					{
						infire[id]=false
						minigun_downing[id]=true
						minigun_downed[id]=false
						minigun_uping[id]=false
						msg_anim(id,anim_minidown)
						PlaySequence(id,PLAYER_IDLE)
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_minigun_winddown, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						player_priwpn_specialtimer[id]=nowtime
						player_priwpnnextattacktime[id]=nowtime+get_pcvar_float(cvar_wpn_minigun_putdown_time)
						NextCould_CurWeapon_Time[id]=get_gametime()+999.0
						NextCould_Jump_Time[id]=get_gametime()+999.0
						NextCould_Duck_Time[id]=get_gametime()+999.0
						
						Speedmul_switch[id]=true
						Speedmul_value_percent[id]=50
					}else{
						infire[id]=false
						minigun_downing[id]=false
						minigun_downed[id]=true
						minigun_uping[id]=false
						msg_anim(id,anim_minispoolidle)
						PlaySequence(id,PLAYER_IDLE)
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_minigun_spin, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						player_priwpn_specialtimer[id]=nowtime
						NextCould_CurWeapon_Time[id]=get_gametime()+999.0
						NextCould_Jump_Time[id]=get_gametime()+999.0
						NextCould_Duck_Time[id]=get_gametime()+999.0
						
					}
					return;
				}
				
				if(gpri_bpammo[id]<=0)
				{
					if(minigun_downed[id])
					{
						if(!minigun_uping[id])
						{
							infire[id]=false
							minigun_downing[id]=false
							minigun_downed[id]=false
							minigun_uping[id]=true
							msg_anim(id,anim_miniup)
							PlaySequence(id,PLAYER_IDLE)
							engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_minigun_windup, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
							player_priwpn_specialtimer[id]=nowtime
							player_priwpnnextattacktime[id]=nowtime+get_pcvar_float(cvar_wpn_minigun_putup_time)
							NextCould_CurWeapon_Time[id]=get_gametime()+999.0
							NextCould_Jump_Time[id]=get_gametime()+999.0
							NextCould_Duck_Time[id]=get_gametime()+999.0
						}
						return;
					}
					infire[id]=false
					minigun_downing[id]=false
					minigun_downed[id]=false
					minigun_uping[id]=false
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_empty, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					player_priwpn_specialtimer[id]=nowtime
					NextCould_CurWeapon_Time[id]=get_gametime()
					NextCould_Jump_Time[id]=get_gametime()
					NextCould_Duck_Time[id]=get_gametime()
					
					Speedmul_switch[id]=false
					Speedmul_value_percent[id]=100
					
					return;
				}
				
				if(!(pev(id,pev_flags)&FL_DUCKING))
				{
					ckrun_get_user_startpos(id,20.0,2.0,0.0,startpoint)
					startpoint[2]+=12.0
				}
				else if((pev(id,pev_flags)&FL_DUCKING))
				{
					ckrun_get_user_startpos(id,20.0,2.0,0.0,startpoint)
					startpoint[2]+=7.0
				}
				new Float:infactstartorg[3]
				idorg[2]+=20.0
				fm_trace_line(id,idorg,startpoint,infactstartorg)
				
				for(new i;i<get_pcvar_num(cvar_wpn_minigun_shotnum);i++)
				{
					ckrun_get_user_startpos(id,25.0*1000.0,random_float(-get_pcvar_float(cvar_wpn_minigun_radius),get_pcvar_float(cvar_wpn_minigun_radius))*1000.0,random_float(-get_pcvar_float(cvar_wpn_minigun_radius),get_pcvar_float(cvar_wpn_minigun_radius))*1000.0,endorg)
					new ent = fm_trace_line(id,infactstartorg,endorg,touchend)
					
					new Float:distance = get_distance_f(infactstartorg,touchend)
					/*
					if(!g_critical_on[id]&&!must_critical[id])
					{
						FX_Trace(infactstartorg,touchend)
					}else{
						FX_ColoredTrace_point(infactstartorg,touchend)
					}*/
					new endorg[3]
					endorg[0]=floatround(touchend[0])
					endorg[1]=floatround(touchend[1])
					endorg[2]=floatround(touchend[2])
					FX_SPARKS(ent,endorg)
					//FX_STONE(endorg)
					
					new Float:dmg
					if(distance>get_pcvar_float(cvar_wpn_minigun_distance)-get_pcvar_float(cvar_wpn_minigun_distance)*get_pcvar_float(cvar_wpn_minigun_mindmgmul))
					{
						dmg = get_pcvar_float(cvar_wpn_minigun_dmg)*get_pcvar_float(cvar_wpn_minigun_mindmgmul)
					}else{
						dmg = get_pcvar_float(cvar_wpn_minigun_dmg)*(1.0-(distance/get_pcvar_float(cvar_wpn_minigun_distance)))
					}
					
					new Float:vec[3]
					get_speed_vector(startpoint,touchend,get_pcvar_float(cvar_wpn_minigun_kb),vec)
					ckrun_knockback(ent,id,vec,0)
					
					new Float:punchangle[3]
					punchangle[0]=get_pcvar_float(cvar_wpn_minigun_punchangle)
					
					if(0<ent<=g_maxplayer)
					{
						set_pev(ent,pev_punchangle,punchangle)
					}
					
					ckrun_takedamage(ent,id,floatround(dmg),CKRW_M134,DMG_BULLET,0,0,0,0)
					
					
					FX_GunDecal(id,touchend)
				}
				
				gpri_bpammo[id]--
				ckrun_update_user_clip_ammo(id)
				PlaySequence(id,PLAYER_ATTACK1)
				
				msg_anim(id,anim_minifire)
				if(!Attackspeedmul_switch[id][weapon_primary])
					player_priwpnnextattacktime[id]=nowtime+get_pcvar_float(cvar_wpn_minigun_shotdealy)
				else
					player_priwpnnextattacktime[id]=nowtime+get_pcvar_float(cvar_wpn_minigun_shotdealy)*100.0/float(Attackspeedmul_value_percent[id][weapon_primary])
				
				
				
				
				if(!g_critical_on[id]&&!must_critical[id])
				{
					FX_ScreenShake(id,150,30,350)
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_minigun_shoot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}else{
					FX_ScreenShake(id,250,40,350)
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_minigun_shoot_crit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
				infire[id]=true
			}
			case human_soldier:
			{
				if(gpri_clip[id]<=0)
				{
					ckrun_weapon_reload(id)
					return;
				}
				ckrun_reset_user_weaponreload(id)
				
				if(!(pev(id,pev_flags)&FL_DUCKING))
				{
					ckrun_get_user_startpos(id,2.0,9.0,0.0,startpoint)
					startpoint[2]+=13.0
				}
				else if((pev(id,pev_flags)&FL_DUCKING))
				{
					ckrun_get_user_startpos(id,2.0,9.0,0.0,startpoint)
					startpoint[2]+=8.0
				}
					
				new Float:infactstartorg[3]
				idorg[2]+=20.0
				fm_trace_line(id,idorg,startpoint,infactstartorg)
					
				pev(id, pev_v_angle, Angle)
				Angle[0] *= -1.0
				
				
				new rocket = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
				if(!rocket) return; //没创建成功的话..
						
				set_pev(rocket, pev_angles, Angle)
				set_pev(rocket, pev_origin, infactstartorg)
				set_pev(rocket, pev_classname, "obj_rocket")
						
						
				engfunc(EngFunc_SetModel, rocket,mdl_wpn_pj_rocket)
				engfunc(EngFunc_SetSize,rocket, {-4.0, -5.0, -2.0},{4.0,5.0, 2.0})
					
				set_pev(rocket, pev_solid, SOLID_SLIDEBOX)
				set_pev(rocket, pev_movetype, MOVETYPE_FLY)
				set_pev(rocket, pev_owner, id)
				set_pev(rocket, pev_entowner, id)
					
				add_line_follow(rocket,rockettrail,7,4,255,255,255,145)
					
				set_pev(rocket,pev_animtime, get_gametime())
				set_pev(rocket,pev_frame,0.0)
				set_pev(rocket,pev_framerate,1.0)
				
				set_pev(rocket,pev_temp,1)
					
				fm_set_entity_visible(rocket,1)
					
				new Float:vec[3]
				velocity_by_aim(id,get_pcvar_num(cvar_wpn_rpg_rocketspeed),vec)
				set_pev(rocket,pev_velocity,vec)
					
				Entity_Status[rocket][entstat_valuefordamage]=get_pcvar_num(cvar_wpn_rpg_damage)
				Entity_Status[rocket][entstat_valueforhealth]=-1
				Entity_Status[rocket][entstat_startvec]=get_pcvar_num(cvar_wpn_rpg_rocketspeed)
				ent_timer[rocket]=get_gametime()
				Entity_Status[rocket][entstat_returned]=0
				Entity_Status[rocket][entstat_valueforcritnum]=0
					
				gpri_clip[id]--
				ckrun_update_user_clip_ammo(id)
				PlaySequence(id,PLAYER_ATTACK1)
					
				msg_anim(id,anim_rpgfire)
				if(!Attackspeedmul_switch[id][weapon_primary])
					player_priwpnnextattacktime[id]=nowtime+get_pcvar_float(cvar_wpn_rpg_shotdealy)
				else
					player_priwpnnextattacktime[id]=nowtime+get_pcvar_float(cvar_wpn_rpg_shotdealy)*100.0/float(Attackspeedmul_value_percent[id][weapon_primary])
				
					
				engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_rpg_shoot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					
				new num = random_num(1,100)
					
				if(num<=gcritical[id]||must_critical[id])
				{
					if(gteam[id]==team_red)
					{
						fm_set_rendering(rocket, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 8)
					}
					else if(gteam[id]==team_blue)
					{
						fm_set_rendering(rocket, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 8)
					}
					Entity_Status[rocket][entstat_valueforcritnum]=2
					engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_crit_shot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
				
			}
			case human_pyro:
			{
				if(gpri_bpammo[id]<=0)
				{
					msg_anim(id,anim_flameidle)
					infire[id]=false
					player_priwpnnextattacktime[id]=nowtime+0.1
					player_priwpn_specialtimer[id]=nowtime+0.1
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_empty, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					return;
				}
				
				if(!(pev(id,pev_flags)&FL_DUCKING))
				{
					ckrun_get_user_startpos(id,90.0,9.0,0.0,startpoint)
					startpoint[2]+=30.0
				}
				else if((pev(id,pev_flags)&FL_DUCKING))
				{
					ckrun_get_user_startpos(id,90.0,9.0,0.0,startpoint)
					startpoint[2]+=20.0
				}
				
				new Float:infactstartorg[3]
				//idorg[2]+=20.0
				fm_trace_line(id,idorg,startpoint,infactstartorg)
				
				
				//pev(id, pev_v_angle, Angle)
				//Angle[0] *= -1.0
				
				if(!infire[id])
				{
					msg_anim(id,anim_flameidle)
					player_priwpnnextattacktime[id]=nowtime+0.16
					player_priwpn_specialtimer[id]=nowtime+0.16
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_flamethrower_start,VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					infire[id]=true
					
					return;
				}
				
				new flame = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
				if(!flame) return; //没创建成功的话..
					
				//set_pev(rocket, pev_angles, Angle)
				set_pev(flame, pev_origin, infactstartorg)
				set_pev(flame, pev_classname, "obj_flame")
					
				
				engfunc(EngFunc_SetModel,flame,mdl_wpn_pj_flame)
				//engfunc(EngFunc_SetSize,flame,{-1.0, -1.0, -1.0},{1.0,1.0,1.0})
				set_pev(flame, pev_mins,{-4.0, -4.0, -4.0})
				set_pev(flame, pev_maxs,{4.0, 4.0, 4.0})
				
				set_pev(flame, pev_solid, SOLID_TRIGGER)
				set_pev(flame, pev_movetype, MOVETYPE_FLY)
				set_pev(flame, pev_owner, id)
				set_pev(flame, pev_entowner, id)
				
				fm_set_entity_visible(flame,1)
				
				new Float:vec[3]
				velocity_by_aim(id,get_pcvar_num(cvar_wpn_firegun_flamespeed),vec)
				set_pev(flame,pev_velocity,vec)
				
				set_pev(flame,pev_rendermode,5)
				set_pev(flame,pev_renderamt,175.0)
				
				set_pev(flame,pev_temp,1)
				
				gpri_bpammo[id]--
				ckrun_update_user_clip_ammo(id)
				
				msg_anim(id,anim_flameshoot)
				if(!Attackspeedmul_switch[id][weapon_primary])
					player_priwpnnextattacktime[id]=nowtime+get_pcvar_float(cvar_wpn_firegun_shotdealy)
				else
					player_priwpnnextattacktime[id]=nowtime+get_pcvar_float(cvar_wpn_firegun_shotdealy)*100.0/float(Attackspeedmul_value_percent[id][weapon_primary])
				
				PlaySequence(id,PLAYER_ATTACK1)
				
				for(new i=1;i<=g_maxplayer;i++)
				{
					ent_touched[flame][i]=false
				}
				
				set_task(0.1,"func_AnimNextFrame",flame)
				set_task(get_pcvar_float(cvar_wpn_firegun_removetime),"remove",flame)
				
				Entity_Status[flame][entstat_valueforcritnum]=0
				
				if(player_priwpn_specialtimer[id] < nowtime)
				{
					if(g_critical_on[id]||must_critical[id])
					{
						Entity_Status[flame][entstat_valueforcritnum]=2
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_flamethrower_loop_crit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}else{
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_flamethrower_loop, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
					player_priwpn_specialtimer[id]=nowtime+2.0
				}
				
					
			}
			case human_sniper:
			{
				if(gpri_bpammo[id]<=0)
				{
					
					return;
				}
				
				if(!(pev(id,pev_flags)&FL_DUCKING))
				{
					ckrun_get_user_startpos(id,20.0,0.0,0.0,startpoint)
					startpoint[2]+=13.0
				}
				else if((pev(id,pev_flags)&FL_DUCKING))
				{
					ckrun_get_user_startpos(id,20.0,0.0,0.0,startpoint)
					startpoint[2]+=7.0
				}
				new Float:infactstartorg[3]
				idorg[2]+=20.0
				fm_trace_line(id,idorg,startpoint,infactstartorg)
				
				for(new i;i<1;i++)
				{
					ckrun_get_user_startpos(id,10000.0,0.0,0.0,endorg)
					fm_get_aim_origin(id,endorg)
					new Float:fvec[3]
					velocity_by_aim(id,10,fvec)
					endorg[0]+=fvec[0]
					endorg[1]+=fvec[1]
					endorg[2]+=fvec[2]
					
					new ent = fm_trace_line(id,infactstartorg,endorg,touchend)
					
					//new Float:distance = get_distance_f(infactstartorg,touchend)
					//new Float:entorg[3]
					//pev(ent,pev_origin,entorg)
					
					//FX_Trace(infactstartorg,touchend)
					new endorg[3]
					endorg[0]=floatround(touchend[0])
					endorg[1]=floatround(touchend[1])
					endorg[2]=floatround(touchend[2])
					FX_SPARKS(ent,endorg)
					
					new Float:dmg = get_pcvar_float(cvar_wpn_sniperifle_damage)+sniperifle_power[id]
					
					new Float:vec[3]
					get_speed_vector(startpoint,touchend,get_pcvar_float(cvar_wpn_sniperifle_kb),vec)
					ckrun_knockback(ent,id,vec,0)
					//ckrun_slowvelocity(ent,id,0.35,0,0)
					
					
					if(get_tr2(0,TR_iHitgroup)==HIT_HEAD && sniperifle_power[id]>0)//&&sniperifle_power[id]>0)//touchend[2]-entorg[2]>=15.0
					{
						ckrun_takedamage(ent,id,floatround(dmg),CKRW_SNIPE,DMG_BULLET,2,1,0,0)
					}
					if(get_tr2(0,TR_iHitgroup)==HIT_CHEST && sniperifle_power[id]>0)//&&sniperifle_power[id]>0)//touchend[2]-entorg[2]>=15.0
					{
						ckrun_takedamage(ent,id,floatround(dmg),CKRW_SNIPE,DMG_BULLET,2,1,0,0)
					}
					else
					{
						ckrun_takedamage(ent,id,floatround(dmg),CKRW_SNIPE,DMG_BULLET,0,1,0,0)
					}
					
					FX_GunDecal(id,touchend)
				}
				
				gpri_bpammo[id]--
				ckrun_update_user_clip_ammo(id)
				PlaySequence(id,PLAYER_ATTACK1)
				
				msg_anim(id,anim_snipeshoot)
				if(!Attackspeedmul_switch[id][weapon_primary])
					player_priwpnnextattacktime[id]=nowtime+get_pcvar_float(cvar_wpn_sniperifle_shotdealy)
				else
					player_priwpnnextattacktime[id]=nowtime+get_pcvar_float(cvar_wpn_sniperifle_shotdealy)*100.0/float(Attackspeedmul_value_percent[id][weapon_primary])
				
				
				set_task(0.7,"sniperifle_reload",id+TASK_SNIPERRELOAD)
				
				engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_sniperifle_shoot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				if(must_critical[id])
				{
					engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_crit_shot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
				//func_papapa(0,id,0,40,touchend,96.0,100.0,0.3,400.0,CKRW_SNIPE,0,1)
			}
			case human_medic:
			{
				new target,body
				get_user_aiming(id,target,body)
				
				new Float:targetorg[3],Float:idorg[3]
				pev(target,pev_origin,targetorg)

				if(!(pev(id,pev_flags)&FL_DUCKING))
				{
					ckrun_get_user_startpos(id,15.0,2.0,0.0,idorg)
					idorg[2]+=13.0
				}
				else if((pev(id,pev_flags)&FL_DUCKING))
				{
					ckrun_get_user_startpos(id,15.0,2.0,0.0,idorg)
					idorg[2]+=7.0
				}
				
				if(target>0)
				{
					if(g_gamemode == gamemode_arena && medictarget[id] != target && gteam[id] == gteam[target] || g_gamemode == gamemode_zombie && medictarget[id] != target && giszm[id] == giszm[target] || g_gamemode == gamemode_arena && medictarget[id] != target && disguise[target] && gteam[id] == disguise_team[target] || g_gamemode == gamemode_zombie && medictarget[id] != target && disguise[target] && giszm[id] == disguise_iszm[target] || g_gamemode == gamemode_vsasb && medictarget[id] != target && target != Boss)
					{
						new Float:distance = get_distance_f(idorg,targetorg)
						if(distance<=get_pcvar_float(cvar_wpn_medicgun_maxdistance))
						{
							bemedic[medictarget[id]]=0
							
							medictarget[id]=target
							if(!bemedic[target])
							{
								bemedic[target]=id
							}
							engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_medicgun_heal, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						
						}
						
					}
					
				}
				else if(!target && !medictarget[id])
				{
					player_priwpnnextattacktime[id]=nowtime+0.3
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_medicgun_notarget, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
				
				
			}
			case human_engineer:
			{
				if(gpri_clip[id]<=0)
				{
					ckrun_weapon_reload(id)
					return;
				}
				ckrun_reset_user_weaponreload(id)
				
				if(!(pev(id,pev_flags)&FL_DUCKING))
				{
					ckrun_get_user_startpos(id,15.0,2.0,0.0,startpoint)
					startpoint[2]+=15.0
				}
				else if((pev(id,pev_flags)&FL_DUCKING))
				{
					ckrun_get_user_startpos(id,15.0,2.0,0.0,startpoint)
					startpoint[2]+=10.0
				}
				new Float:infactstartorg[3]
				idorg[2]+=20.0
				fm_trace_line(id,idorg,startpoint,infactstartorg)
				
				
				for(new i;i<10;i++)
				{
					ckrun_get_user_startpos(id,25.0*1000.0,random_float(-1.5,1.5)*1000.0,random_float(-1.5,1.5)*1000.0,endorg)
					new ent = fm_trace_line(id,infactstartorg,endorg,touchend)
					
					new Float:distance = get_distance_f(infactstartorg,touchend)
					
					if(!g_critical_on[id]&&!must_critical[id])
					{
						FX_Trace(infactstartorg,touchend)
					}else{
						FX_ColoredTrace_point(infactstartorg,touchend)
					}
					new endorg[3]
					endorg[0]=floatround(touchend[0])
					endorg[1]=floatround(touchend[1])
					endorg[2]=floatround(touchend[2])
					FX_SPARKS(ent,endorg)
					//FX_STONE(endorg)
					
					new Float:dmg
					if(distance>660.0)
					{
						dmg *= 0.45
					}else{
						dmg = 9.0*(1.0-(distance/1200.0))
					}
					
					new Float:vec[3]
					get_speed_vector(startpoint,touchend,55.0,vec)
					ckrun_knockback(ent,id,vec,0)
					
					
					ckrun_takedamage(ent,id,floatround(dmg),CKRW_SHOTGUN,DMG_BULLET,0,0,0,0)
					
					
					FX_GunDecal(id,touchend)
				}
				
				gpri_clip[id]--
				ckrun_update_user_clip_ammo(id)
				PlaySequence(id,PLAYER_ATTACK1)
				
				msg_anim(id,anim_shotgunfire)
				if(!Attackspeedmul_switch[id][weapon_primary])
					player_priwpnnextattacktime[id]=nowtime+0.625
				else
					player_priwpnnextattacktime[id]=nowtime+0.625*100.0/float(Attackspeedmul_value_percent[id][weapon_primary])
				
				
				engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_shotgun_shoot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				
				if(g_critical_on[id]||must_critical[id])
				{
					engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_crit_shot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
				
				
			}
			case human_demoman:
			{
				if(gpri_clip[id]<=0)
				{
					ckrun_weapon_reload(id)
					return;
				}
				ckrun_reset_user_weaponreload(id)
				
				if(!(pev(id,pev_flags)&FL_DUCKING))
				{
					ckrun_get_user_startpos(id,90.0,9.0,0.0,startpoint)
					startpoint[2]+=12.0
				}
				else if((pev(id,pev_flags)&FL_DUCKING))
				{
					ckrun_get_user_startpos(id,90.0,9.0,0.0,startpoint)
					startpoint[2]+=2.0
				}
				new Float:infactstartorg[3]
				idorg[2]+=20.0
				fm_trace_line(id,idorg,startpoint,infactstartorg)
				
				pev(id, pev_v_angle, Angle)
				Angle[0] *= -1.0
				
				new grenade = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
				if(!grenade) return; //没创建成功的话..
					
				set_pev(grenade, pev_angles, Angle)
				set_pev(grenade, pev_origin, infactstartorg)
				set_pev(grenade, pev_classname, "obj_grenade")
					
				
				engfunc(EngFunc_SetModel, grenade,mdl_wpn_pj_grenade)
				engfunc(EngFunc_SetSize,grenade,{-3.0, -3.0, -3.0},{3.0,3.0, 3.0})
				
				
				set_pev(grenade, pev_solid, SOLID_SLIDEBOX)
				set_pev(grenade, pev_movetype, MOVETYPE_BOUNCE)
				set_pev(grenade, pev_owner, id)
				set_pev(grenade, pev_entowner, id)
				
				set_pev(grenade,pev_gravity,0.65)
				
				set_pev(grenade,pev_skin,gteam[id]-1)
				
				set_pev(grenade,pev_temp,1)
				
				fm_set_entity_visible(grenade,1)
				
				new blu=0,red=0
				if(gteam[id]==team_red)
				{
					red=235
				}
				else if(gteam[id]==team_blue)
				{
					blu=235
				}
				
				//add_line_follow(grenade,rockettrail,3,2,red,50,blu,128)
				
				
				Entity_Status[grenade][entstat_returned]=0
				Entity_Status[grenade][entstat_valuefordamage]=random_num(84,123)
				Entity_Status[grenade][entstat_valueforhealth]=-1
				Entity_Status[grenade][entstat_startvec]=725
				ent_timer[grenade]=get_gametime()
				Entity_Status[grenade][entstat_valueforcritnum]=0
				
				new Float:vec[3]
				velocity_by_aim(id,Entity_Status[grenade][entstat_startvec],vec)
				set_pev(grenade,pev_velocity,vec)
				
				gpri_clip[id]--
				ckrun_update_user_clip_ammo(id)
				PlaySequence(id,PLAYER_ATTACK1)
				
				msg_anim(id,anim_grenadeshoot)
				if(!Attackspeedmul_switch[id][weapon_primary])
					player_priwpnnextattacktime[id]=nowtime+0.55
				else
					player_priwpnnextattacktime[id]=nowtime+0.55*100.0/float(Attackspeedmul_value_percent[id][weapon_primary])
				
				
				engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_grenadelauncher_shoot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				
				new num = random_num(1,100)
				
				if(num<=gcritical[id]||must_critical[id])
				{
					if(gteam[id]==team_red)
					{
						fm_set_rendering(grenade, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 8)
					}
					else if(gteam[id]==team_blue)
					{
						fm_set_rendering(grenade, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 8)
					}
					Entity_Status[grenade][entstat_valueforcritnum]=2
					engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_crit_shot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
				
				ent_touchedground[grenade]=false
				
				//->0 ren bu neng zha zi ji , yong param
				new param[2]
				param[0]=grenade
				param[1]=0
				set_task(3.0,"grenade_explpde",grenade,param,2)
				
			}
			case human_spy:
			{
				if(invisible_ing[id]||invisible_ed[id]||uninvisible_ing[id]) return;
				if(gpri_clip[id]<=0)
				{
					ckrun_weapon_reload(id)
					return;
				}
				func_undisguise(id)
				ckrun_reset_user_weaponreload(id)
				
				if(!(pev(id,pev_flags)&FL_DUCKING))
				{
					ckrun_get_user_startpos(id,20.0,4.0,0.0,startpoint)
					startpoint[2]+=15.0
				}
				else if((pev(id,pev_flags)&FL_DUCKING))
				{
					ckrun_get_user_startpos(id,20.0,4.0,0.0,startpoint)
					startpoint[2]+=10.0
				}
				new Float:infactstartorg[3]
				idorg[2]+=20.0
				fm_trace_line(id,idorg,startpoint,infactstartorg)
				
				
				for(new i;i<1;i++)
				{
					fm_get_aim_origin(id,endorg)
					new Float:fvec[3]
					velocity_by_aim(id,10,fvec)
					endorg[0]+=fvec[0]
					endorg[1]+=fvec[1]
					endorg[2]+=fvec[2]
					
					new ent = fm_trace_line(id,infactstartorg,endorg,touchend)
					
					new Float:distance = get_distance_f(infactstartorg,touchend)
					
					if(!g_critical_on[id]&&!must_critical[id])
					{
						FX_Trace(infactstartorg,touchend)
					}else{
						FX_ColoredTrace_point(infactstartorg,touchend)
					}
					new endorg[3]
					endorg[0]=floatround(touchend[0])
					endorg[1]=floatround(touchend[1])
					endorg[2]=floatround(touchend[2])
					FX_SPARKS(ent,endorg)
					//FX_STONE(endorg)
					
					new Float:vec[3]
					get_speed_vector(startpoint,touchend,300.0,vec)
					ckrun_knockback(ent,id,vec,0)
					
					new Float:dmg
					if(distance>560.0)
					{
						dmg = 60.0*0.3
					}else{
						dmg = 60.0*(1.0-(distance/800.0))
					}
					
					
					ckrun_takedamage(ent,id,floatround(dmg),CKRW_REVOLVER,CKRD_BULLET,0,0,0,0)
					
					
					FX_GunDecal(id,touchend)
				}
				
				gpri_clip[id]--
				ckrun_update_user_clip_ammo(id)
				
				msg_anim(id,anim_revolverfire)
				if(!Attackspeedmul_switch[id][weapon_primary])
					player_priwpnnextattacktime[id]=nowtime+0.58
				else
					player_priwpnnextattacktime[id]=nowtime+0.58*100.0/float(Attackspeedmul_value_percent[id][weapon_primary])
				
				PlaySequence(id,PLAYER_ATTACK1)
				
				engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_revolver_shoot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				
				if(g_critical_on[id]||must_critical[id])
				{
					engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_crit_shot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
				
				
			}
			case human_assassin:
				{
					
					if(gpri_clip[id]<=0)
					{
						ckrun_weapon_reload(id)
						return;
					}
					ckrun_reset_user_weaponreload(id)
					
					
					if(!(pev(id,pev_flags)&FL_DUCKING))
					{
						ckrun_get_user_startpos(id,25.0,5.0,0.0,startpoint)
						startpoint[2]+=14.0
					}
					else if((pev(id,pev_flags)&FL_DUCKING))
					{
						ckrun_get_user_startpos(id,25.0,5.0,0.0,startpoint)
						startpoint[2]+=9.0
					}
					
					
					new Float:infactstartorg[3]
					idorg[2]+=20.0
					fm_trace_line(id,idorg,startpoint,infactstartorg)
						
						
					for(new i;i<8;i++)
					{
						ckrun_get_user_startpos(id,25.0*1000.0,random_float(-2.0,2.0)*1000.0,random_float(-2.0,2.0)*1000.0,endorg)
						new ent = fm_trace_line(id,infactstartorg,endorg,touchend)
							
						new Float:distance = get_distance_f(infactstartorg,touchend)
							
						if(!g_critical_on[id]&&!must_critical[id])
						{
							FX_Trace(infactstartorg,touchend)
						}else{
							FX_ColoredTrace_point(infactstartorg,touchend)
						}
						new endorg[3]
						endorg[0]=floatround(touchend[0])
						endorg[1]=floatround(touchend[1])
						endorg[2]=floatround(touchend[2])
						FX_SPARKS(ent,endorg)
						//FX_STONE(endorg)
							
						new Float:dmg
						if(distance>1200.0)
						{
							dmg = 35.0*0.45
						}else{
							dmg = 35.0*(1.0-(distance/1200.0))
						}
							
						new Float:vec[3]
						get_speed_vector(startpoint,touchend,75.0,vec)
						ckrun_knockback(ent,id,vec,0)
							
						ckrun_takedamage(ent,id,floatround(dmg),CKRW_ASSM3,DMG_BULLET,0,0,0,0)
						func_papapa(0,id,0,5,touchend,64.0,60.0,0.45,150.0,CKRW_ASSM3,0,0,0,0)
							
							
						FX_GunDecal(id,touchend)
					}
						
					gpri_clip[id]--
					ckrun_update_user_clip_ammo(id)
					PlaySequence(id,PLAYER_ATTACK1)
					
					if(m3left[id])
					{
						msg_anim(id,anim_assm3left)
						m3left[id]=false
					}else{
						msg_anim(id,anim_assm3right)
						m3left[id]=true
					}
					if(!Attackspeedmul_switch[id][weapon_primary])
						player_priwpnnextattacktime[id]=nowtime+0.93
					else
						player_priwpnnextattacktime[id]=nowtime+0.93*100.0/float(Attackspeedmul_value_percent[id][weapon_primary])
						
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_assm3_shoot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						
					if(g_critical_on[id]||must_critical[id])
					{
						engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_crit_shot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
						
						
				}
			
		}
	}
	else if(equali(classname,"weapon_p228"))
	{
		if(player_secwpnnextattacktime[id] > nowtime) return;
		
		if(!giszm[id] && g_wpnitem_sec[id][ghuman[id]]==-1)
		{
			switch(ghuman[id])
			{
				case human_scout:
				{
					if(gsec_clip[id]<=0)
					{
						ckrun_weapon_reload(id)
						return;
					}
					ckrun_reset_user_weaponreload(id)
					
					if(!(pev(id,pev_flags)&FL_DUCKING))
					{
						ckrun_get_user_startpos(id,25.0,4.0,0.0,startpoint)
						startpoint[2]+=15.0
					}
					else if((pev(id,pev_flags)&FL_DUCKING))
					{
						ckrun_get_user_startpos(id,25.0,4.0,0.0,startpoint)
						startpoint[2]+=9.0
					}
					new Float:infactstartorg[3]
					idorg[2]+=20.0
					fm_trace_line(id,idorg,startpoint,infactstartorg)
					
					
					
					{
						ckrun_get_user_startpos(id,25.0*1000.0,random_float(-get_pcvar_float(cvar_wpn_pistol_radius),get_pcvar_float(cvar_wpn_pistol_radius))*1000.0,random_float(-get_pcvar_float(cvar_wpn_pistol_radius),get_pcvar_float(cvar_wpn_pistol_radius))*1000.0,endorg)
						new ent = fm_trace_line(id,infactstartorg,endorg,touchend)
						
						new Float:distance = get_distance_f(infactstartorg,touchend)
						
						if(!g_critical_on[id]&&!must_critical[id])
						{
							FX_Trace(infactstartorg,touchend)
						}else{
							FX_ColoredTrace_point(infactstartorg,touchend)
						}
						new endorg[3]
						endorg[0]=floatround(touchend[0])
						endorg[1]=floatround(touchend[1])
						endorg[2]=floatround(touchend[2])
						FX_SPARKS(ent,endorg)
						//FX_STONE(endorg)
						
						new Float:dmg
						if(distance>get_pcvar_float(cvar_wpn_pistol_distance)-get_pcvar_float(cvar_wpn_pistol_distance)*get_pcvar_float(cvar_wpn_pistol_mindmgmul))
						{
							dmg = get_pcvar_float(cvar_wpn_pistol_dmg)*get_pcvar_float(cvar_wpn_pistol_mindmgmul)
						}else{
							dmg = get_pcvar_float(cvar_wpn_pistol_dmg)*(1.0-(distance/get_pcvar_float(cvar_wpn_pistol_distance)))
						}
						
						new Float:vec[3]
						get_speed_vector(startpoint,touchend,get_pcvar_float(cvar_wpn_pistol_kb),vec)
						ckrun_knockback(ent,id,vec,0)
						
						ckrun_takedamage(ent,id,floatround(dmg),CKRW_PISTOL,DMG_BULLET,0,0,0,0)
						
						
						FX_GunDecal(id,touchend)
					}
					
					gsec_clip[id]--
					ckrun_update_user_clip_ammo(id)
					PlaySequence(id,PLAYER_ATTACK1)
					
					msg_anim(id,anim_pistolfire)
					if(!Attackspeedmul_switch[id][weapon_secondry])
						player_secwpnnextattacktime[id]=nowtime+get_pcvar_float(cvar_wpn_pistol_shotdealy)
					else
						player_secwpnnextattacktime[id]=nowtime+get_pcvar_float(cvar_wpn_pistol_shotdealy)*100.0/float(Attackspeedmul_value_percent[id][weapon_secondry])
				
					
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_pistol_shoot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					
					if(g_critical_on[id]||must_critical[id])
					{
						engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_crit_shot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
					
					
				}
				case human_heavy,human_soldier,human_pyro:
				{
					if(gsec_clip[id]<=0)
					{
						ckrun_weapon_reload(id)
						return;
					}
					ckrun_reset_user_weaponreload(id)
					
					if(!(pev(id,pev_flags)&FL_DUCKING))
					{
						ckrun_get_user_startpos(id,20.0,2.0,0.0,startpoint)
						startpoint[2]+=15.0
					}
					else if((pev(id,pev_flags)&FL_DUCKING))
					{
						ckrun_get_user_startpos(id,20.0,2.0,0.0,startpoint)
						startpoint[2]+=10.0
					}
					new Float:infactstartorg[3]
					idorg[2]+=20.0
					fm_trace_line(id,idorg,startpoint,infactstartorg)
					
					
					for(new i;i<10;i++)
					{
						ckrun_get_user_startpos(id,25.0*1000.0,random_float(-1.35,1.35)*1000.0,random_float(-1.5,1.5)*1000.0,endorg)
						new ent = fm_trace_line(id,infactstartorg,endorg,touchend)
						
						new Float:distance = get_distance_f(infactstartorg,touchend)
						
						if(!g_critical_on[id]&&!must_critical[id])
						{
							FX_Trace(infactstartorg,touchend)
						}else{
							FX_ColoredTrace_point(infactstartorg,touchend)
						}
						new endorg[3]
						endorg[0]=floatround(touchend[0])
						endorg[1]=floatround(touchend[1])
						endorg[2]=floatround(touchend[2])
						FX_SPARKS(ent,endorg)
						//FX_STONE(endorg)
						
						new Float:dmg
						if(distance>840.0)
						{
							dmg *= 0.3
						}else{
							dmg = 9.0*(1.0-(distance/1200.0))
						}
						
						new Float:vec[3]
						get_speed_vector(startpoint,touchend,65.0,vec)
						ckrun_knockback(ent,id,vec,0)
						
						ckrun_takedamage(ent,id,floatround(dmg),CKRW_SHOTGUN,DMG_BULLET,0,0,0,0)
						
						
						FX_GunDecal(id,touchend)
					}
					
					gsec_clip[id]--
					ckrun_update_user_clip_ammo(id)
					PlaySequence(id,PLAYER_ATTACK1)
					
					msg_anim(id,anim_shotgunfire)
					if(!Attackspeedmul_switch[id][weapon_secondry])
						player_secwpnnextattacktime[id]=nowtime+0.625
					else
						player_secwpnnextattacktime[id]=nowtime+0.625*100.0/float(Attackspeedmul_value_percent[id][weapon_secondry])
					
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_shotgun_shoot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					
					if(g_critical_on[id]||must_critical[id])
					{
						engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_crit_shot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
					
					
				}
				case human_sniper:
				{
					if(gsec_clip[id]<=0)
					{
						ckrun_weapon_reload(id)
						return;
					}
					ckrun_reset_user_weaponreload(id)
					
					if(!(pev(id,pev_flags)&FL_DUCKING))
					{
						ckrun_get_user_startpos(id,25.0,4.0,0.0,startpoint)
						startpoint[2]+=14.0
					}
					else if((pev(id,pev_flags)&FL_DUCKING))
					{
						ckrun_get_user_startpos(id,25.0,4.0,0.0,startpoint)
						startpoint[2]+=9.0
					}
					new Float:infactstartorg[3]
					idorg[2]+=20.0
					fm_trace_line(id,idorg,startpoint,infactstartorg)
					
					
					for(new i;i<1;i++)
					{
						ckrun_get_user_startpos(id,25.0*1000.0,random_float(-1.0,1.0)*1000.0,random_float(-1.0,1.0)*1000.0,endorg)
						new ent = fm_trace_line(id,infactstartorg,endorg,touchend)
						
						new Float:distance = get_distance_f(infactstartorg,touchend)
						
						if(!g_critical_on[id]&&!must_critical[id])
						{
							FX_Trace(infactstartorg,touchend)
						}else{
							FX_ColoredTrace_point(infactstartorg,touchend)
						}
						new endorg[3]
						endorg[0]=floatround(touchend[0])
						endorg[1]=floatround(touchend[1])
						endorg[2]=floatround(touchend[2])
						FX_SPARKS(ent,endorg)
						//FX_STONE(endorg)
						
						new Float:dmg
						if(distance>720.0)
						{
							dmg = 12.0*0.4
						}else{
							dmg = 12.0*(1.0-(distance/1200.0))
						}
						
						new Float:vec[3]
						get_speed_vector(startpoint,touchend,35.0,vec)
						ckrun_knockback(ent,id,vec,0)
						
						ckrun_takedamage(ent,id,floatround(dmg),CKRW_SMG,DMG_BULLET,0,0,0,0)
						
						
						FX_GunDecal(id,touchend)
					}
					
					gsec_clip[id]--
					ckrun_update_user_clip_ammo(id)
					PlaySequence(id,PLAYER_ATTACK1)
					
					msg_anim(id,anim_smgshoot)
					if(!Attackspeedmul_switch[id][weapon_secondry])
						player_secwpnnextattacktime[id]=nowtime+0.1
					else
						player_secwpnnextattacktime[id]=nowtime+0.1*100.0/float(Attackspeedmul_value_percent[id][weapon_secondry])
					
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_smg_shoot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					
					if(g_critical_on[id]||must_critical[id])
					{
						engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_crit_shot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
					
					
				}
				case human_medic:
				{
					if(gsec_clip[id]<=0)
					{
						ckrun_weapon_reload(id)
						return;
					}
					ckrun_reset_user_weaponreload(id)
					
					if(!(pev(id,pev_flags)&FL_DUCKING))
					{
						ckrun_get_user_startpos(id,90.0,9.0,0.0,startpoint)
						startpoint[2]+=12.0
					}
					else if((pev(id,pev_flags)&FL_DUCKING))
					{
						ckrun_get_user_startpos(id,90.0,9.0,0.0,startpoint)
						startpoint[2]+=2.0
					}
					new Float:infactstartorg[3]
					idorg[2]+=20.0
					fm_trace_line(id,idorg,startpoint,infactstartorg)
					
					pev(id, pev_v_angle, Angle)
					Angle[0] *= -1.0
					
					new syringe = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
					if(!syringe) return; //没创建成功的话..
						
					set_pev(syringe, pev_angles, Angle)
					set_pev(syringe, pev_origin, infactstartorg)
					set_pev(syringe, pev_classname, "obj_syringe")
						
					
					engfunc(EngFunc_SetModel, syringe,mdl_wpn_pj_syringe)
					
					engfunc(EngFunc_SetSize,syringe,{-3.0, -3.0, -2.0},{3.0,3.0, 2.0})
					
					set_pev(syringe, pev_solid, 2)
					set_pev(syringe, pev_movetype, MOVETYPE_TOSS)
					set_pev(syringe, pev_owner, id)
					set_pev(syringe, pev_entowner, id)
					
					set_pev(syringe,pev_gravity,0.5)
					
					set_pev(syringe,pev_temp,1)
					
					fm_set_entity_visible(syringe,1)
					
					Entity_Status[syringe][entstat_valuefordamage]=12
					Entity_Status[syringe][entstat_valueforhealth]=-1
					Entity_Status[syringe][entstat_startvec]=700
					ent_timer[syringe]=get_gametime()
					Entity_Status[syringe][entstat_valueforcritnum]=0
					
					new Float:vec[3]
					velocity_by_aim(id,Entity_Status[syringe][entstat_startvec],vec)
					set_pev(syringe,pev_velocity,vec)
					
					gsec_clip[id]--
					ckrun_update_user_clip_ammo(id)
					PlaySequence(id,PLAYER_ATTACK1)
					
					msg_anim(id,anim_syringeshoot)
					if(!Attackspeedmul_switch[id][weapon_secondry])
						player_secwpnnextattacktime[id]=nowtime+0.1
					else
						player_secwpnnextattacktime[id]=nowtime+0.1*100.0/float(Attackspeedmul_value_percent[id][weapon_secondry])
					
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_syringegun_shoot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					
					if(g_critical_on[id]||must_critical[id])
					{
						if(gteam[id]==team_red)
						{
							fm_set_rendering(syringe, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 8)
						}
						else if(gteam[id]==team_blue)
						{
							fm_set_rendering(syringe, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 8)
						}
						Entity_Status[syringe][entstat_valueforcritnum]=2
						engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_crit_shot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
					
					
				}
				case human_engineer:
				{
					if(gsec_clip[id]<=0)
					{
						ckrun_weapon_reload(id)
						return;
					}
					ckrun_reset_user_weaponreload(id)
					
					if(!(pev(id,pev_flags)&FL_DUCKING))
					{
						ckrun_get_user_startpos(id,25.0,4.0,0.0,startpoint)
						startpoint[2]+=15.0
					}
					else if((pev(id,pev_flags)&FL_DUCKING))
					{
						ckrun_get_user_startpos(id,25.0,4.0,0.0,startpoint)
						startpoint[2]+=9.0
					}
					new Float:infactstartorg[3]
					idorg[2]+=20.0
					fm_trace_line(id,idorg,startpoint,infactstartorg)
					
					
					
					{
						ckrun_get_user_startpos(id,25.0*1000.0,random_float(-get_pcvar_float(cvar_wpn_pistol_radius),get_pcvar_float(cvar_wpn_pistol_radius))*1000.0,random_float(-get_pcvar_float(cvar_wpn_pistol_radius),get_pcvar_float(cvar_wpn_pistol_radius))*1000.0,endorg)
						new ent = fm_trace_line(id,infactstartorg,endorg,touchend)
						
						new Float:distance = get_distance_f(infactstartorg,touchend)
						
						if(!g_critical_on[id]&&!must_critical[id])
						{
							FX_Trace(infactstartorg,touchend)
						}else{
							FX_ColoredTrace_point(infactstartorg,touchend)
						}
						new endorg[3]
						endorg[0]=floatround(touchend[0])
						endorg[1]=floatround(touchend[1])
						endorg[2]=floatround(touchend[2])
						FX_SPARKS(ent,endorg)
						//FX_STONE(endorg)
						
						new Float:dmg
						if(distance>get_pcvar_float(cvar_wpn_pistol_distance)-get_pcvar_float(cvar_wpn_pistol_distance)*get_pcvar_float(cvar_wpn_pistol_mindmgmul))
						{
							dmg = get_pcvar_float(cvar_wpn_pistol_dmg)*get_pcvar_float(cvar_wpn_pistol_mindmgmul)
						}else{
							dmg = get_pcvar_float(cvar_wpn_pistol_dmg)*(1.0-(distance/get_pcvar_float(cvar_wpn_pistol_distance)))
						}
						
						new Float:vec[3]
						get_speed_vector(startpoint,touchend,get_pcvar_float(cvar_wpn_pistol_kb),vec)
						ckrun_knockback(ent,id,vec,0)
						
						ckrun_takedamage(ent,id,floatround(dmg),CKRW_PISTOL,DMG_BULLET,0,0,0,0)
						
						
						FX_GunDecal(id,touchend)
					}
					
					gsec_clip[id]--
					ckrun_update_user_clip_ammo(id)
					PlaySequence(id,PLAYER_ATTACK1)
					
					msg_anim(id,anim_pistolfire)
					if(!Attackspeedmul_switch[id][weapon_secondry])
						player_secwpnnextattacktime[id]=nowtime+get_pcvar_float(cvar_wpn_pistol_shotdealy)
					else
						player_secwpnnextattacktime[id]=nowtime+get_pcvar_float(cvar_wpn_pistol_shotdealy)*100.0/float(Attackspeedmul_value_percent[id][weapon_secondry])
					
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_pistol_shoot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					
					if(g_critical_on[id]||must_critical[id])
					{
						engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_crit_shot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
					
					
				}
				case human_demoman:
				{
					if(gsec_clip[id]<=0)
					{
						ckrun_weapon_reload(id)
						return;
					}
					ckrun_reset_user_weaponreload(id)
					
					if(stickylauncher_power[id]<=0)
					{
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_stickylauncher_charge, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
					
					stickylauncher_power[id]+=(get_pcvar_num(cvar_wpn_stickylauncher_dpower)/75)
					if(stickylauncher_power[id]>get_pcvar_num(cvar_wpn_stickylauncher_dpower))
					{
						stickylauncher_power[id]=get_pcvar_num(cvar_wpn_stickylauncher_dpower)
					}
					player_secwpnnextattacktime[id]=nowtime+0.05
				}
				case human_spy:
				{
					new success = ckrun_sapper_plant(id)
					if(success>0)
						msg_anim(id,anim_sapperput)
					player_secwpnnextattacktime[id]=nowtime+0.2
					PlaySequence(id,PLAYER_ATTACK1)
				}
				case human_assassin:
				{
					if(gsec_clip[id]<=0)
					{
						ckrun_weapon_reload(id)
						return;
					}
					ckrun_reset_user_weaponreload(id)
					
					if(deagleleft[id])
					{
						if(!(pev(id,pev_flags)&FL_DUCKING))
						{
							ckrun_get_user_startpos(id,25.0,5.0,0.0,startpoint)
							startpoint[2]+=14.0
						}
						else if((pev(id,pev_flags)&FL_DUCKING))
						{
							ckrun_get_user_startpos(id,25.0,5.0,0.0,startpoint)
							startpoint[2]+=9.0
						}
					}else{
						if(!(pev(id,pev_flags)&FL_DUCKING))
						{
							ckrun_get_user_startpos(id,25.0,-5.0,0.0,startpoint)
							startpoint[2]+=14.0
						}
						else if((pev(id,pev_flags)&FL_DUCKING))
						{
							ckrun_get_user_startpos(id,25.0,-5.0,0.0,startpoint)
							startpoint[2]+=9.0
						}
					}
					
					new Float:infactstartorg[3]
					idorg[2]+=20.0
					fm_trace_line(id,idorg,startpoint,infactstartorg)
						
						
					for(new i;i<1;i++)
					{
						ckrun_get_user_startpos(id,25.0*1000.0,random_float(-0.35,0.35)*1000.0,random_float(-0.35,0.35)*1000.0,endorg)
						new ent = fm_trace_line(id,infactstartorg,endorg,touchend)
							
						new Float:distance = get_distance_f(infactstartorg,touchend)
							
						if(!g_critical_on[id]&&!must_critical[id])
						{
							FX_Trace(infactstartorg,touchend)
						}else{
							FX_ColoredTrace_point(infactstartorg,touchend)
						}
						new endorg[3]
						endorg[0]=floatround(touchend[0])
						endorg[1]=floatround(touchend[1])
						endorg[2]=floatround(touchend[2])
						FX_SPARKS(ent,endorg)
						//FX_STONE(endorg)
							
						new Float:dmg
						if(distance>1200.0)
						{
							dmg = 50.0*0.45
						}else{
							dmg = 50.0*(1.0-(distance/1200.0))
						}
							
						new Float:vec[3]
						get_speed_vector(startpoint,touchend,65.0,vec)
						ckrun_knockback(ent,id,vec,0)
							
						ckrun_takedamage(ent,id,floatround(dmg),CKRW_ASSDEAGLE,DMG_BULLET,0,0,0,0)
						func_papapa(0,id,0,20,touchend,96.0,90.0,0.45,250.0,CKRW_ASSDEAGLE,0,0,0,0)
							
							
						FX_GunDecal(id,touchend)
					}
						
					gsec_clip[id]--
					ckrun_update_user_clip_ammo(id)
					PlaySequence(id,PLAYER_ATTACK1)
					
					if(deagleleft[id])
					{
						msg_anim(id,anim_assdeagleleft)
						deagleleft[id]=false
					}else{
						msg_anim(id,anim_assdeagleright)
						deagleleft[id]=true
					}
					if(!Attackspeedmul_switch[id][weapon_secondry])
						player_secwpnnextattacktime[id]=nowtime+0.16
					else
						player_secwpnnextattacktime[id]=nowtime+0.16*100.0/float(Attackspeedmul_value_percent[id][weapon_secondry])
						
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_assdeagle_shoot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						
					if(g_critical_on[id]||must_critical[id])
					{
						engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_crit_shot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
						
						
				}
			}
		}
		else if(giszm[id])
		{
			switch(gzombie[id])
			{
				case zombie_spy:
				{
					new success = ckrun_sapper_plant(id)
					if(success>0)
						msg_anim(id,anim_sapperput)
					player_secwpnnextattacktime[id]=nowtime+0.3
					PlaySequence(id,PLAYER_ATTACK1)
					
				}
			}
		}
	}
	else if(equali(classname,"weapon_knife"))
	{
		if(player_knifewpnnextattacktime[id] > nowtime) return;
		
		if(Boss != id)
		{
			if(!giszm[id] && g_wpnitem_knife[id][ghuman[id]]==-1)
			{
				func_knifeattack(id)
				switch(ghuman[id])
				{
					case human_scout:
					{
						if(!Attackspeedmul_switch[id][weapon_knife])
							player_knifewpnnextattacktime[id]=nowtime+0.45
						else
							player_knifewpnnextattacktime[id]=nowtime+0.45*100.0/float(Attackspeedmul_value_percent[id][weapon_knife])
					}
					default:
					{
						if(!Attackspeedmul_switch[id][weapon_knife])
							player_knifewpnnextattacktime[id]=nowtime+0.8
						else
							player_knifewpnnextattacktime[id]=nowtime+0.8*100.0/float(Attackspeedmul_value_percent[id][weapon_knife])
					}
				}
			}
			else if(giszm[id] && g_wpnitem_knife_zombie[id][gzombie[id]]==-1)
			{
				func_knifeattack(id)
				switch(gzombie[id])
				{
					case zombie_scout:
					{
						player_knifewpnnextattacktime[id]=nowtime+0.4
					}
					default:
					{
						player_knifewpnnextattacktime[id]=nowtime+0.8
					}
				}
			}
		}else{
			func_knifeattack(id)
			switch(gboss[id])
			{
				case boss_cbs:
				{
					player_knifewpnnextattacktime[id]=nowtime+0.8
				}
				case boss_scp173:
				{
					player_knifewpnnextattacktime[id]=nowtime+0.5
				}
				case boss_creeper:
				{
					player_knifewpnnextattacktime[id]=nowtime+0.8
				}
				case boss_guardian:
				{
					player_knifewpnnextattacktime[id]=nowtime+0.8
				}
				default:
				{
					player_knifewpnnextattacktime[id]=nowtime+0.8
				}
			}
		}
	}
	else if(equali(classname,"weapon_hegrenade"))
	{
		if(pev(id, pev_bInDuck) || (pev(id, pev_flags) & IN_DUCK))
			idorg[2] += 24.0
		
		if(!giszm[id])
		{
			switch(ghuman[id])
			{
				case human_engineer:
				{
					switch(player_movebuilding[id])
					{
						case build_sentry:
						{
							ExecuteForward(g_fwBuild_Pre,g_fwResult,id,build_sentry)
							
							ckrun_get_user_startpos(id,0.0,0.0,0.0,startpoint)
							ckrun_get_user_startpos(id,65.0,0.0,0.0,endorg)
							
							new ent = fm_trace_line(id,startpoint,endorg,touchend)
							if(0<ent<=g_maxplayer) return;
							
							new Float:savepoint[3],Float:Downup[3]
							xs_vec_copy(touchend,savepoint)
							xs_vec_copy(touchend,Downup)
							Downup[2]-=1000.0
							ent = fm_trace_line(0,savepoint,Downup,touchend)
							if(!pev(id,pev_bInDuck) && !(pev(id,pev_flags) & IN_DUCK))
								idorg[2]-=24.0
							if(touchend[2]-idorg[2]>60.0 || touchend[2]-idorg[2]<-60.0 || 0<ent<=g_maxplayer) return;
							savepoint[2]=touchend[2]
							Downup[2]+=2000.0
							ent = fm_trace_line(0,savepoint,Downup,touchend)
							if(get_distance_f(savepoint,touchend)<45.0 || 0<ent<=g_maxplayer) return;
							
							
							if(is_hull_default(savepoint,28.0)) return;
							
							
							ckrun_build_sentry(id,savepoint)
							player_movebuilding[id]=0
							engclient_cmd(id,"weapon_knife")
							NextCould_CurWeapon_Time[id]=get_gametime()
							
							
							
							ExecuteForward(g_fwBuild_Post,g_fwResult,id,build_sentry)
							
						}
						case build_dispenser:
						{
							ExecuteForward(g_fwBuild_Pre,g_fwResult,id,build_dispenser)
							
							ckrun_get_user_startpos(id,0.0,0.0,0.0,startpoint)
							ckrun_get_user_startpos(id,65.0,0.0,0.0,endorg)
							
							new ent = fm_trace_line(id,startpoint,endorg,touchend)
							if(0<ent<=g_maxplayer) return;
							
							new Float:savepoint[3],Float:Downup[3]
							xs_vec_copy(touchend,savepoint)
							xs_vec_copy(touchend,Downup)
							Downup[2]-=1000.0
							ent = fm_trace_line(0,savepoint,Downup,touchend)
							if(!pev(id,pev_bInDuck) && !(pev(id,pev_flags) & IN_DUCK))
								idorg[2]-=24.0
							if(touchend[2]-idorg[2]>60.0 || touchend[2]-idorg[2]<-60.0 || 0<ent<=g_maxplayer) return;
							savepoint[2]=touchend[2]
							Downup[2]+=2000.0
							ent = fm_trace_line(0,savepoint,Downup,touchend)
							if(get_distance_f(savepoint,touchend)<45.0 || 0<ent<=g_maxplayer) return;
							
							
							if(is_hull_default(savepoint,28.0)) return;
							
							
							
							ckrun_build_dispenser(id,savepoint)
							player_movebuilding[id]=0
							engclient_cmd(id,"weapon_knife")
							NextCould_CurWeapon_Time[id]=get_gametime()
							
							
							ExecuteForward(g_fwBuild_Post,g_fwResult,id,build_dispenser)
							
						}
						default:
						{
							ckrun_show_buildmenu(id)
						}
					}
				}
				case human_spy:
				{
					ckrun_show_disguisemenu(id)
				}
			}
		}
		else
		{
			switch(gzombie[id])
			{
				case zombie_spy:
				{
					ckrun_show_disguisemenu(id)
				}
			}
		}
	}
	else if(equali(classname,"weapon_c4"))
	{
		switch(ghuman[id])
		{
			case human_engineer:
			{
				ckrun_show_destroymenu(id)
			}
		}
	}
	
}
public ckrun_weapon_shoot2(id)//MOUSE2
{
	
	new prient = get_entity_index(id,"weapon_m3")
	new Float:times = player_curweapontime[id]
	new Float:nowtime = get_gametime()
	
	if(times > nowtime) return;
	
	new weapon[32],wpnnum
	get_user_weapons(id,weapon,wpnnum)
	if(wpnnum<1) return;
	
	new Float:idorg[3],Float:sizemin[3],Float:sizemax[3],Float:startpoint[3],Float:endorg[3],Float:touchend[3],Float:Angle[3]
	pev(id,pev_origin,idorg)
	pev(id,pev_size,sizemin,sizemax)
	idorg[2]+=(sizemax[2]*0.2)
	
	new wpnent = get_pdata_cbase(id,373,5)
	if(!pev_valid(wpnent)) return;
	new classname[32]
	pev(wpnent,pev_classname,classname,31)
	
	if(equali(classname,"weapon_m3")&&g_wpnitem_pri[id][ghuman[id]]==-1)
	{
		if(player_priwpnnextattacktime[id] > nowtime) return;
		
		switch(ghuman[id])
		{
			case human_heavy:
			{
				if(pev(id,pev_button)&IN_ATTACK || pev(id,pev_flags)&FL_DUCKING) return;
				
				if(!minigun_downed[id])
				{
					if(!minigun_downing[id])
					{
						minigun_downing[id]=true
						minigun_downed[id]=false
						minigun_uping[id]=false
						msg_anim(id,anim_minidown)
						PlaySequence(id,PLAYER_IDLE)
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_minigun_winddown, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						player_priwpn_specialtimer[id]=nowtime
						player_priwpnnextattacktime[id]=nowtime+get_pcvar_float(cvar_wpn_minigun_putdown_time)
						NextCould_CurWeapon_Time[id]=get_gametime()+999.0
						NextCould_Jump_Time[id]=get_gametime()+999.0
						NextCould_Duck_Time[id]=get_gametime()+999.0
						
						Speedmul_switch[id]=true
						Speedmul_value_percent[id]=50
					}else{
						minigun_downing[id]=false
						minigun_downed[id]=true
						minigun_uping[id]=false
						msg_anim(id,anim_minispoolidle)
						PlaySequence(id,PLAYER_IDLE)
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_minigun_spin, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						player_priwpn_specialtimer[id]=nowtime
						NextCould_CurWeapon_Time[id]=get_gametime()+999.0
						NextCould_Jump_Time[id]=get_gametime()+999.0
						NextCould_Duck_Time[id]=get_gametime()+999.0
					}
					return;
				}
				
				
				if(minigun_downed[id]&&nowtime >= player_priwpn_specialtimer[id])
				{
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_minigun_spin, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					msg_anim(id,anim_minispoolidle)
					PlaySequence(id,PLAYER_IDLE)
					player_priwpn_specialtimer[id]=nowtime+0.5
				}
			}
			case human_pyro:
			{
				if(times > nowtime)
				{
					return;
				}
				
				if(gpri_bpammo[id]<20)
				{
					
					return;
				}
				
				if(!(pev(id,pev_flags)&FL_DUCKING))
				{
					ckrun_get_user_startpos(id,90.0,9.0,0.0,startpoint)
					startpoint[2]+=29.0
				}
				else if((pev(id,pev_flags)&FL_DUCKING))
				{
					ckrun_get_user_startpos(id,90.0,9.0,0.0,startpoint)
					startpoint[2]+=19.0
				}
				new Float:infactstartorg[3]
				fm_trace_line(id,idorg,startpoint,infactstartorg)
				
				new ent=0,class[32]
				while((ent=engfunc(EngFunc_FindEntityInSphere,ent,idorg,188.0))!=0)
				{
					new Float:entorg[3]
					pev(ent,pev_origin,entorg)
					pev(ent,pev_classname,class,31)
					
					if(fm_is_in_viewcone(id,entorg,235.0)&&pev(ent,pev_owner)!=id)
					{
						if(equali(class,"player"))
						{
							if(g_gamemode == gamemode_arena && gteam[id]!=gteam[ent] || g_gamemode == gamemode_zombie && giszm[id]!=giszm[ent] || g_gamemode == gamemode_vsasb && ent == Boss)
							{
								new Float:vec[3]
								velocity_by_aim(id,500,vec)
								set_pev(ent,pev_velocity,vec)
							}
							
							if(g_gamemode == gamemode_arena && gteam[id]==gteam[ent] || g_gamemode == gamemode_zombie && giszm[id]==giszm[ent] || g_gamemode == gamemode_vsasb && ent != Boss)
							{
								func_disfire(ent,id)
							}
						}
						else if(equali(class,"obj_rocket",10))
						{
							pev(id, pev_v_angle, Angle)
							Angle[0] *= -1.0
							
							set_pev(ent, pev_angles, Angle)
							
							set_pev(ent, pev_owner, id)
							set_pev(ent, pev_entowner, id)
							
							ent_timer[ent]=get_gametime()
							
							Entity_Status[ent][entstat_returned]=1
							new Float:vec[3]
							velocity_by_aim(id,floatround(Entity_Status[ent][entstat_startvec]*1.25),vec)
							set_pev(ent,pev_velocity,vec)
							
							Entity_Status[ent][entstat_valueforcritnum]++
							engfunc(EngFunc_EmitSound,id, CHAN_STATIC,snd_wpn_flamethrower_redirect, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						}
						else if(equali(class,"obj_weaponbox"))
						{
							new Float:vec[3]
							velocity_by_aim(id,600,vec)
							set_pev(ent,pev_velocity,vec)
						}
						else if(equali(class,"obj_stickybomb",14))
						{
							set_pev(ent, pev_movetype, MOVETYPE_TOSS)
							
							new Float:vec[3]
							velocity_by_aim(id,floatround(Entity_Status[ent][entstat_startvec]*1.25),vec)
							set_pev(ent,pev_velocity,vec)
							engfunc(EngFunc_EmitSound,id, CHAN_STATIC,snd_wpn_flamethrower_redirect, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						}
						else if(equali(class,"obj_",4))
						{
							pev(id, pev_v_angle, Angle)
							Angle[0] *= -1.0
							
							set_pev(ent, pev_angles, Angle)
							
							set_pev(ent, pev_owner, id)
							set_pev(ent, pev_entowner, id)
							
							ent_timer[ent]=get_gametime()
							
							Entity_Status[ent][entstat_returned]=1
							new Float:vec[3]
							velocity_by_aim(id,floatround(Entity_Status[ent][entstat_startvec]*1.25),vec)
							set_pev(ent,pev_velocity,vec)
							
							Entity_Status[ent][entstat_valueforcritnum]++
							engfunc(EngFunc_EmitSound,id, CHAN_STATIC,snd_wpn_flamethrower_redirect, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						}
					}
				}
				
				gpri_bpammo[id]-=20
				ckrun_update_user_clip_ammo(id)
				PlaySequence(id,PLAYER_ATTACK1)
				
				msg_anim(id,anim_flameairblast)
				if(!Attackspeedmul_switch[id][weapon_primary])
					player_priwpnnextattacktime[id]=nowtime+0.65
				else
					player_priwpnnextattacktime[id]=nowtime+0.65*100.0/float(Attackspeedmul_value_percent[id][weapon_primary])
				
				engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_flamethrower_airblast, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				
			}
			case human_sniper:
			{
				if(times > nowtime)
				{
					return;
				}
				
				
				if(sniperifle_power[id]==0)
				{
					fm_set_user_zoom(id,CS_FIRST_ZOOM)
					func_zhayan(id,6,8.0)
					sniperifle_power[id]=1
					
					Speedmul_switch[id]=true
					Speedmul_value_percent[id]=get_pcvar_num(cvar_wpn_sniperifle_kjspper)
					
					player_priwpnnextattacktime[id]=nowtime+0.25
					player_priwpn_specialtimer[id]=nowtime+get_pcvar_float(cvar_wpn_sniperifle_powerwait)
					NextCould_CurWeapon_Time[id]=get_gametime()+999.0
				}else{
					fm_set_user_zoom(id,CS_NO_ZOOM)
					set_fov(id,90)
					func_zhayan(id,4,8.0)
					sniperifle_power[id]=0
					
					Speedmul_switch[id]=false
					Speedmul_value_percent[id]=100
					
					set_msg_armor(id,get_user_armor(id))
					
					player_priwpnnextattacktime[id]=nowtime+0.25
					NextCould_CurWeapon_Time[id]=get_gametime()
				}
				
					
			}
			case human_medic:
			{
				if(gchargepower[id]==MAX_CHARGEPOWER)
				{
					if(!supercharge[id])
					{
						supercharge[id]=true
						engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_wpn_medicgun_chargeon, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
				}
			}
			case human_demoman:
			{
				
				new boom = ckrun_stickybomb_explode(id,gstickymaxnum[id],0)
				if(boom)
				{
					//player_priwpnnextattacktime[id]=nowtime+0.1
					engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_wpn_stickylauncher_det, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
			}
			case human_spy:
			{
				func_invisible(id,0)
			}
			
		}
	}
	else if(equali(classname,"weapon_p228")&&g_wpnitem_sec[id][ghuman[id]]==-1)
	{
		
		
		if(!giszm[id])
		{
			switch(ghuman[id])
			{
				case human_demoman:
				{
					new boom = ckrun_stickybomb_explode(id,gstickymaxnum[id],0)
					if(boom)
					{
						//player_secwpnnextattacktime[id]=nowtime+0.1
						engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_wpn_stickylauncher_det, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
				}
				case human_spy:
				{
					if(player_secwpnnextattacktime[id] > nowtime) return;
					
					func_invisible(id,0)
				}
			}
		}
		else
		{
			switch(gzombie[id])
			{
				case zombie_spy:
				{
					if(player_secwpnnextattacktime[id] > nowtime) return;
					
					func_invisible(id,0)
				}
			}
		}
	}
	else if(equali(classname,"weapon_knife")&&g_wpnitem_knife[id][ghuman[id]]==-1)
	{
		if(player_knifewpnnextattacktime[id] > nowtime) return;
		
		if(Boss != id)
		{
			if(!giszm[id])
			{
				switch(ghuman[id])
				{
					case human_heavy:
					{
						PlaySequence(id,PLAYER_ATTACK1)
						
						func_knifeattack(id)
						if(!Attackspeedmul_switch[id][weapon_knife])
							player_knifewpnnextattacktime[id]=nowtime+0.8
						else
							player_knifewpnnextattacktime[id]=nowtime+0.8*100.0/float(Attackspeedmul_value_percent[id][weapon_knife])
						
					}
					case human_demoman:
					{
						new boom = ckrun_stickybomb_explode(id,gstickymaxnum[id],0)
						if(boom)
						{
							//player_knifewpnnextattacktime[id]=nowtime+0.1
							engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_wpn_stickylauncher_det, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						}
					}
					case human_spy:
					{
						func_invisible(id,0)
					}
				}
			}
			else if(giszm[id])
			{
				switch(gzombie[id])
				{
					case zombie_heavy:
					{
						
						func_knifeattack(id)
						player_knifewpnnextattacktime[id]=nowtime+0.8
						
					}
					case zombie_spy:
					{
						func_invisible(id,0)
					}
				}
			}
		}
	}
	
}
public ckrun_weapon_shoot3(id)//MOUSE1 NOHIT
{
	new Float:times = player_curweapontime[id]
	new Float:nowtime = get_gametime()
	if(times > nowtime)
	{
		return;
	}
	
	
	new weapon[32],wpnnum
	get_user_weapons(id,weapon,wpnnum)
	if(wpnnum<1) return;
	
	new Float:idorg[3],Float:sizemin[3],Float:sizemax[3],Float:startpoint[3],Float:endorg[3],Float:touchend[3],Float:Angle[3]
	pev(id,pev_origin,idorg)
	pev(id,pev_size,sizemin,sizemax)
	idorg[2]+=(sizemax[2]*0.2)
	
	new wpnent = get_pdata_cbase(id,373,5)
	if(!pev_valid(wpnent)) return;
	new classname[32]
	pev(wpnent,pev_classname,classname,31)
	
	if(equali(classname,"weapon_m3")&&g_wpnitem_pri[id][ghuman[id]]==-1)
	{
		if(player_priwpnnextattacktime[id] > nowtime) return;
		
		switch(ghuman[id])
		{
			case human_heavy:
			{
				if(pev(id,pev_button)&IN_ATTACK2) return;
				
				if(minigun_downing[id])
				{
					infire[id]=false
					minigun_downing[id]=false
					minigun_downed[id]=true
					minigun_uping[id]=false
					NextCould_CurWeapon_Time[id]=get_gametime()+999.0
					NextCould_Jump_Time[id]=get_gametime()+999.0
					NextCould_Duck_Time[id]=get_gametime()+999.0
				}
				
				if(minigun_downed[id])
				{
					if(!minigun_uping[id])
					{
						infire[id]=false
						minigun_downing[id]=false
						minigun_downed[id]=false
						minigun_uping[id]=true
						msg_anim(id,anim_miniup)
						PlaySequence(id,PLAYER_IDLE)
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_minigun_windup, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						player_priwpn_specialtimer[id]=nowtime
						player_priwpnnextattacktime[id]=nowtime+get_pcvar_float(cvar_wpn_minigun_putup_time)
						NextCould_CurWeapon_Time[id]=get_gametime()+999.0
						NextCould_Jump_Time[id]=get_gametime()+999.0
						NextCould_Duck_Time[id]=get_gametime()+999.0
					}
					return;
				}
				infire[id]=false
				minigun_downing[id]=false
				minigun_downed[id]=false
				minigun_uping[id]=false
				NextCould_CurWeapon_Time[id]=get_gametime()
				NextCould_Jump_Time[id]=get_gametime()
				NextCould_Duck_Time[id]=get_gametime()
				
				Speedmul_switch[id]=false
				Speedmul_value_percent[id]=100
				
				engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_empty, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				
			}
			case human_pyro:
			{
				if(infire[id])
				{
					msg_anim(id,anim_flameidle)
					PlaySequence(id,PLAYER_IDLE)
					infire[id]=false
					player_priwpnnextattacktime[id]=nowtime+0.3
					player_priwpn_specialtimer[id]=nowtime+0.3
					
				}else{
					if(player_priwpn_specialtimer[id]<nowtime)
					{
						player_priwpn_specialtimer[id]=nowtime+9999.0
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_empty, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
				}
						
				
				
				
			}
		}
	}
	else if(equali(classname,"weapon_p228")&&g_wpnitem_sec[id][ghuman[id]]==-1)
	{
		if(player_secwpnnextattacktime[id] > nowtime) return;
		
		switch(ghuman[id])
		{
			case human_demoman:
			{
				if(stickylauncher_power[id]>0)
				{
					if(!(pev(id,pev_flags)&FL_DUCKING))
					{
						ckrun_get_user_startpos(id,90.0,9.0,0.0,startpoint)
						startpoint[2]+=15.0
					}
					else if((pev(id,pev_flags)&FL_DUCKING))
					{
						ckrun_get_user_startpos(id,90.0,9.0,0.0,startpoint)
						startpoint[2]+=5.0
					}
					new Float:infactstartorg[3]
					idorg[2]+=20.0
					fm_trace_line(id,idorg,startpoint,infactstartorg)
					
					new sticky = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
					if(!sticky) return; //没创建成功的话..
						
						
					set_pev(sticky, pev_origin, infactstartorg)
					set_pev(sticky, pev_classname, "obj_stickybomb")
					
					engfunc(EngFunc_SetModel, sticky,mdl_wpn_pj_stickybomb)
					engfunc(EngFunc_SetSize,sticky,{-4.0, -4.0, -5.0},{4.0,4.0, 5.0})
					
					set_pev(sticky, pev_solid, SOLID_SLIDEBOX)
					set_pev(sticky, pev_movetype, MOVETYPE_TOSS)
					set_pev(sticky, pev_owner, id)
					set_pev(sticky, pev_entowner, id)
					
					set_pev(sticky,pev_gravity,0.8)
					
					set_pev(sticky,pev_skin,gteam[id]-1)
					
					set_pev(sticky,pev_temp,0)
					
					fm_set_entity_visible(sticky,1)
					
					new blu=0,red=0
					if(gteam[id]==team_red)
					{
						red=235
					}
					else if(gteam[id]==team_blue)
					{
						blu=235
					}
					
					add_line_follow(sticky,rockettrail,3,3,red,50,blu,128)
					
					
					Entity_Status[sticky][entstat_valuefordamage]=get_pcvar_num(cvar_wpn_stickylauncher_maxdmg)
					Entity_Status[sticky][entstat_valueforhealth]=get_pcvar_num(cvar_wpn_stickylauncher_health)
					Entity_Status[sticky][entstat_startvec]=get_pcvar_num(cvar_wpn_stickylauncher_speed)+stickylauncher_power[id]
					ent_timer[sticky]=get_gametime()
					
					new Float:vec[3]
					velocity_by_aim(id,Entity_Status[sticky][entstat_startvec],vec)
					set_pev(sticky,pev_velocity,vec)
					
					gsec_clip[id]--
					ckrun_update_user_clip_ammo(id)
					PlaySequence(id,PLAYER_ATTACK1)
					
					
					msg_anim(id,anim_stickyshoot)
					if(!Attackspeedmul_switch[id][weapon_secondry])
						player_secwpnnextattacktime[id]=nowtime+get_pcvar_float(cvar_wpn_stickylauncher_shotdl)
					else
						player_secwpnnextattacktime[id]=nowtime+get_pcvar_float(cvar_wpn_stickylauncher_shotdl)*100.0/float(Attackspeedmul_value_percent[id][weapon_secondry])
					
					Entity_Status[sticky][entstat_valueforcritnum]=0
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_stickylauncher_shoot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					
					
					new num = random_num(1,100)
					
					if(num<=gcritical[id]||must_critical[id])
					{
						if(gteam[id]==team_red)
						{
							fm_set_rendering(sticky, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 8)
						}
						else if(gteam[id]==team_blue)
						{
							fm_set_rendering(sticky, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 8)
						}
						Entity_Status[sticky][entstat_valueforcritnum]=2
						engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_crit_shot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
					
					
					stickylauncher_power[id]=0
					stickyready[sticky]=false
					
					new stickybombnum = ckrun_get_stickybombnum(id)
					if(stickybombnum>=gstickymaxnum[id])
					{
						ckrun_stickybomb_explode(id,1,1)
					}
					
					new bool:findok=false
					for(new i;i<gstickymaxnum[id];i++)
					{
						if(!gstickyid[id][i] && !findok)
						{
							findok=true
							gstickyid[id][i]=sticky
						}
					}
					
					
					
					set_task(get_pcvar_float(cvar_wpn_stickylauncher_bombrd),"func_stickybombready",sticky)
					
				}
				
			}
		}
	}
	else if(equali(classname,"weapon_knife")&&g_wpnitem_knife[id][ghuman[id]]==-1)
	{
		if(player_knifewpnnextattacktime[id] > nowtime) return;
		
		
	}
	
}
public ckrun_weapon_shoot4(id)//MOUSE2 NOHIT
{
	new Float:times = player_curweapontime[id]
	new Float:nowtime = get_gametime()
	if(times > nowtime)
	{
		return;
	}
	new weapon[32],wpnnum
	get_user_weapons(id,weapon,wpnnum)
	if(wpnnum<1) return;
	
	//new Float:idorg[3],Float:startpoint[3],Float:endorg[3],Float:touchend[3],Float:Angle[3]
	//pev(id,pev_origin,idorg)
	
	new wpnent = get_pdata_cbase(id,373,5)
	if(!pev_valid(wpnent)) return;
	new classname[32]
	pev(wpnent,pev_classname,classname,31)
	
	if(equali(classname,"weapon_m3")&&g_wpnitem_pri[id][ghuman[id]]==-1)
	{
		if(player_priwpnnextattacktime[id] > nowtime) return;
		
		switch(ghuman[id])
		{
			case human_heavy:
			{
				if(pev(id,pev_button)&IN_ATTACK) return;
				
				
				
				if(minigun_downing[id])
				{
					infire[id]=false
					minigun_downing[id]=false
					minigun_downed[id]=true
					minigun_uping[id]=false
					NextCould_CurWeapon_Time[id]=get_gametime()+999.0
					NextCould_Jump_Time[id]=get_gametime()+999.0
					NextCould_Duck_Time[id]=get_gametime()+999.0
				}
				
				if(minigun_downed[id])
				{
					if(!minigun_uping[id])
					{
						infire[id]=false
						minigun_downing[id]=false
						minigun_downed[id]=false
						minigun_uping[id]=true
						msg_anim(id,anim_miniup)
						PlaySequence(id,PLAYER_IDLE)
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_minigun_windup, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						player_priwpn_specialtimer[id]=nowtime
						player_priwpnnextattacktime[id]=nowtime+get_pcvar_float(cvar_wpn_minigun_putup_time)
						NextCould_CurWeapon_Time[id]=get_gametime()+999.0
						NextCould_Jump_Time[id]=get_gametime()+999.0
						NextCould_Duck_Time[id]=get_gametime()+999.0
					}
					return;
				}
				infire[id]=false
				minigun_downing[id]=false
				minigun_downed[id]=false
				minigun_uping[id]=false
				NextCould_CurWeapon_Time[id]=get_gametime()
				NextCould_Jump_Time[id]=get_gametime()
				NextCould_Duck_Time[id]=get_gametime()
				
				Speedmul_switch[id]=false
				Speedmul_value_percent[id]=100
				
				engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_empty, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			}
			
		}
	}
	else if(equali(classname,"weapon_p228")&&g_wpnitem_sec[id][ghuman[id]]==-1)
	{
		if(player_secwpnnextattacktime[id] > nowtime) return;
		
	}
	else if(equali(classname,"weapon_knife")&&g_wpnitem_knife[id][ghuman[id]]==-1)
	{
		if(player_knifewpnnextattacktime[id] > nowtime) return;
		
	}
}
public ckrun_weapon_think(id)
{
	new Float:times = player_curweapontime[id]
	new Float:nowtime = get_gametime()
	if(times > nowtime)
	{
		return;
	}
	
	
	new weapon[32],wpnnum
	get_user_weapons(id,weapon,wpnnum)
	if(wpnnum<1) return;
	
	new Float:idorg[3],Float:sizemin[3],Float:sizemax[3],Float:startpoint[3],Float:endorg[3],Float:touchend[3],Float:Angle[3]
	pev(id,pev_origin,idorg)
	pev(id,pev_size,sizemin,sizemax)
	idorg[2]+=(sizemax[2]*0.2)
	
	new wpnent = get_pdata_cbase(id,373,5)
	if(!pev_valid(wpnent)) return;
	new classname[32]
	pev(wpnent,pev_classname,classname,31)
	
	if(equali(classname,"weapon_m3")&&g_wpnitem_pri[id][ghuman[id]]==-1)
	{
		if(player_priwpnnextattacktime[id] > nowtime) return;
		
		switch(ghuman[id])
		{
			case human_medic:
			{
				if(medictarget[id]>0)
				{
					new Float:bemedicorg[3]
					pev(medictarget[id],pev_origin,bemedicorg)
					
					new Float:distance = get_distance_f(idorg,bemedicorg)
					if(distance > get_pcvar_float(cvar_wpn_medicgun_healdsts))
					{
						if(bemedic[medictarget[id]]==id)
						{
							bemedic[medictarget[id]]=0
							set_pev(medictarget[id],pev_skin,0)
						}
						medictarget[id]=0
					}
					else if(distance<=get_pcvar_float(cvar_wpn_medicgun_healdsts))
					{
						if(0<medictarget[id]<=g_maxplayer)
						{
							if(g_gamemode == gamemode_arena  && gteam[id] == gteam[medictarget[id]] || g_gamemode == gamemode_zombie && !giszm[id] && !giszm[medictarget[id]] || g_gamemode == gamemode_arena && disguise[medictarget[id]] && gteam[id] == disguise_team[medictarget[id]] || g_gamemode == gamemode_zombie && disguise[medictarget[id]] && giszm[id] == disguise_iszm[medictarget[id]] || g_gamemode == gamemode_vsasb && medictarget[id] != Boss)
							{
								new red,blue,green
								if(gteam[id]==team_blue)
								{
									blue=225
								}
								else if(gteam[id]==team_red)
								{
									red=225
								}else{
									green=225
								}
								
								new addhealth = 4,mode = 1
								
								if(is_user_alive(medictarget[id]))
								{
									ckrun_give_user_health(medictarget[id],addhealth,mode)
									
									add_line_two_point(id,medictarget[id],medicbeam,red,green,blue,18)
								}else{
									if(bemedic[medictarget[id]]==id)
									{
										bemedic[medictarget[id]]=0
									}
									medictarget[id]=0
								}
								
								if(!supercharge[id])
								{
									if(pev(medictarget[id],pev_health)>=float(gmaxhealth[ghuman[medictarget[id]]]))
										gchargepower[id]+=get_pcvar_num(cvar_wpn_medicgun_overheal_c)
									else
										gchargepower[id]+=get_pcvar_num(cvar_wpn_medicgun_heal_c)
									
									if(gchargepower[id]>MAX_CHARGEPOWER)
										gchargepower[id]=MAX_CHARGEPOWER
									
								}
								set_pdata_int(get_entity_index(id,"weapon_m3"),OFFSET_CLIPAMMO,gchargepower[id]*100/MAX_CHARGEPOWER)
								player_priwpnnextattacktime[id]=nowtime+get_pcvar_float(cvar_wpn_medicgun_healtime)
							}
							else
							{
								if(bemedic[medictarget[id]]==id)
								{
									bemedic[medictarget[id]]=0
									set_pev(medictarget[id],pev_skin,0)
								}
								medictarget[id]=0
							}
						}
					}
				}
				if(!supercharge[id]&&gchargepower[id]==MAX_CHARGEPOWER)
				{
					msg_anim(id,anim_mediccharge)
				}else{
					msg_anim(id,anim_medicidle)
				}
				
				
				
			}
			case human_sniper:
			{
				if(nowtime >= player_priwpn_specialtimer[id])
				{
					if(sniperifle_power[id]>0)
					{
						sniperifle_power[id]++
						if(sniperifle_power[id]>get_pcvar_num(cvar_wpn_sniperifle_maxpower))
						{
							sniperifle_power[id]=get_pcvar_num(cvar_wpn_sniperifle_maxpower)
						}
						set_msg_armor(id,sniperifle_power[id])
						new Float:org[3]
						fm_get_aim_origin(id,org)
						//show_spr(org,spr_dot,1+sniperifle_power[id]/25,155)
						
						
						player_priwpn_specialtimer[id]=nowtime+get_pcvar_float(cvar_wpn_sniperifle_powerspeed)
					}
				}
				
			}
		}
	}
	else if(equali(classname,"weapon_p228")&&g_wpnitem_sec[id][ghuman[id]]==-1)
	{
		if(player_secwpnnextattacktime[id] > nowtime) return;
		
		
	}
	else if(equali(classname,"weapon_knife")&&g_wpnitem_knife[id][ghuman[id]]==-1)
	{
		if(player_knifewpnnextattacktime[id] > nowtime) return;
		
		
	}
	
	if(supercharge[id])
	{
		gchargepower[id]-=get_pcvar_num(cvar_wpn_medicgun_supercharge)
		if(gchargepower[id]<=0)
		{
			gchargepower[id]=0
			supercharge[id]=false
			set_pev(id,pev_skin,0)
			if(bemedic[medictarget[id]]==id)
			{
				set_pev(medictarget[id],pev_skin,0)
			}
			engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_wpn_medicgun_chargeoff, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			set_pdata_int(get_entity_index(id,"weapon_m3"),OFFSET_CLIPAMMO,0)
			return;
		}
					
		set_pev(id,pev_skin,1)
		if(bemedic[medictarget[id]]==id)
		{
			set_pev(medictarget[id],pev_skin,1)
		}
		player_priwpnnextattacktime[id]=nowtime+get_pcvar_float(cvar_wpn_medicgun_healtime)
		
		set_pdata_int(get_entity_index(id,"weapon_m3"),OFFSET_CLIPAMMO,gchargepower[id]*100/MAX_CHARGEPOWER)
	}else{
		set_pev(id,pev_skin,0)
		if(bemedic[medictarget[id]]==id)
		{
			set_pev(medictarget[id],pev_skin,0)
		}
	}
	
}

public ckrun_weapon_reload(id)
{
	new Float:times = player_curweapontime[id]
	new Float:nowtime = get_gametime()
	if(times > nowtime) return;
	
	if(!player_reloadstatus[id][reload_none]) return;
	
	new wpnent = get_pdata_cbase(id,373,5)
	new classname[32]
	pev(wpnent,pev_classname,classname,31)
	
	if(equali(classname,"weapon_m3")&&g_wpnitem_pri[id][ghuman[id]]==-1)
	{
		if(player_priwpnnextattacktime[id]>nowtime) return;
		if(gpri_bpammo[id]<=0||gpri_clip[id]>=gmaxpriclip[id]) return;
		
		switch(ghuman[id])
		{
			case human_scout:
			{
				player_reloadstatus[id][reload_none]=false
				player_reloadstatus[id][reload_start]=true
				player_reloadstatus[id][reload_ing]=false
				player_reloadstatus[id][reload_end]=false
				
				new param[3]
				param[0]=id
				param[1]=1
				param[2]=1
				
				msg_anim(id,anim_shotgunstartreload)
				PlaySequence(id,PLAYER_RELOAD)
				
				new Float:rtime=0.2*100.0/float(Reloadspeedmul_value_percent[id][weapon_primary])
				
				remove_task(id+TASK_STARTRELOAD)
				if(Reloadspeedmul_switch[id][weapon_primary])
				{
					set_task(rtime,"func_reload",id+TASK_STARTRELOAD,param,3)
				}else{
					set_task(0.2,"func_reload",id+TASK_STARTRELOAD,param,3)
				}
			}
			case human_soldier:
			{
				player_reloadstatus[id][reload_none]=false
				player_reloadstatus[id][reload_start]=true
				player_reloadstatus[id][reload_ing]=false
				player_reloadstatus[id][reload_end]=false
				
				new param[3]
				param[0]=id
				param[1]=1
				param[2]=1
				
				msg_anim(id,anim_rpgstartreload)
				PlaySequence(id,PLAYER_RELOAD)
				
				new Float:rtime=0.5*100.0/float(Reloadspeedmul_value_percent[id][weapon_primary])
				
				remove_task(id+TASK_STARTRELOAD)
				if(Reloadspeedmul_switch[id][weapon_primary])
				{
					set_task(rtime,"func_reload",id+TASK_STARTRELOAD,param,3)
				}else{
					set_task(0.5,"func_reload",id+TASK_STARTRELOAD,param,3)
				}
			}
			case human_engineer:
			{
				player_reloadstatus[id][reload_none]=false
				player_reloadstatus[id][reload_start]=true
				player_reloadstatus[id][reload_ing]=false
				player_reloadstatus[id][reload_end]=false
				
				new param[3]
				param[0]=id
				param[1]=1
				param[2]=1
				
				msg_anim(id,anim_shotgunstartreload)
				PlaySequence(id,PLAYER_RELOAD)
				
				new Float:rtime=0.3*100.0/float(Reloadspeedmul_value_percent[id][weapon_primary])
				
				remove_task(id+TASK_STARTRELOAD)
				if(Reloadspeedmul_switch[id][weapon_primary])
				{
					set_task(rtime,"func_reload",id+TASK_STARTRELOAD,param,3)
				}else{
					set_task(0.3,"func_reload",id+TASK_STARTRELOAD,param,3)
				}
			}
			case human_demoman:
			{
				player_reloadstatus[id][reload_none]=false
				player_reloadstatus[id][reload_start]=true
				player_reloadstatus[id][reload_ing]=false
				player_reloadstatus[id][reload_end]=false
				
				new param[3]
				param[0]=id
				param[1]=1
				param[2]=1
				
				msg_anim(id,anim_grenadestartreload)
				PlaySequence(id,PLAYER_RELOAD)
				
				new Float:rtime=0.6*100.0/float(Reloadspeedmul_value_percent[id][weapon_primary])
				
				remove_task(id+TASK_STARTRELOAD)
				if(Reloadspeedmul_switch[id][weapon_primary])
				{
					set_task(rtime,"func_reload",id+TASK_STARTRELOAD,param,3)
				}else{
					set_task(0.6,"func_reload",id+TASK_STARTRELOAD,param,3)
				}
			}
			case human_spy:
			{
				player_reloadstatus[id][reload_none]=false
				player_reloadstatus[id][reload_start]=false
				player_reloadstatus[id][reload_ing]=true
				player_reloadstatus[id][reload_end]=false
				
				new param[3]
				param[0]=id
				param[1]=0
				param[2]=1
				
				msg_anim(id,anim_revolverreload)
				PlaySequence(id,PLAYER_RELOAD)
				
				new Float:rtime=1.0*100.0/float(Reloadspeedmul_value_percent[id][weapon_primary])
				
				remove_task(id+TASK_STARTRELOAD)
				if(Reloadspeedmul_switch[id][weapon_primary])
				{
					set_task(rtime,"func_reload",id+TASK_STARTRELOAD,param,3)
				}else{
					set_task(1.0,"func_reload",id+TASK_STARTRELOAD,param,3)
				}
			}
			case human_assassin:
			{
				player_reloadstatus[id][reload_none]=false
				player_reloadstatus[id][reload_start]=true
				player_reloadstatus[id][reload_ing]=false
				player_reloadstatus[id][reload_end]=false
				
				new param[3]
				param[0]=id
				param[1]=1
				param[2]=1
				
				msg_anim(id,anim_assm3startreload)
				PlaySequence(id,PLAYER_RELOAD)
				
				new Float:rtime=0.37*100.0/float(Reloadspeedmul_value_percent[id][weapon_primary])
				
				remove_task(id+TASK_STARTRELOAD)
				if(Reloadspeedmul_switch[id][weapon_primary])
				{
					set_task(rtime,"func_reload",id+TASK_STARTRELOAD,param,3)
				}else{
					set_task(0.37,"func_reload",id+TASK_STARTRELOAD,param,3)
				}
				
			}
			
		}
	}
	else if(equali(classname,"weapon_p228")&&g_wpnitem_sec[id][ghuman[id]]==-1)
	{
		if(player_secwpnnextattacktime[id]>nowtime) return;
		if(gsec_bpammo[id]<=0||gsec_clip[id]>=gmaxsecclip[id]) return;
		
		switch(ghuman[id])
		{
			case human_scout:
			{
				player_reloadstatus[id][reload_none]=false
				player_reloadstatus[id][reload_start]=false
				player_reloadstatus[id][reload_ing]=true
				player_reloadstatus[id][reload_end]=false
				
				new param[3]
				param[0]=id
				param[1]=0
				param[2]=2
				
				msg_anim(id,anim_pistolreload)
				PlaySequence(id,PLAYER_RELOAD)
				
				new Float:rtime=1.1*100.0/float(Reloadspeedmul_value_percent[id][weapon_secondry])
				
				remove_task(id+TASK_STARTRELOAD)
				if(Reloadspeedmul_switch[id][weapon_secondry])
				{
					set_task(rtime,"func_reload",id+TASK_STARTRELOAD,param,3)
				}else{
					set_task(1.1,"func_reload",id+TASK_STARTRELOAD,param,3)
				}
			}
			case human_heavy,human_soldier,human_pyro:
			{
				player_reloadstatus[id][reload_none]=false
				player_reloadstatus[id][reload_start]=true
				player_reloadstatus[id][reload_ing]=false
				player_reloadstatus[id][reload_end]=false
				
				new param[3]
				param[0]=id
				param[1]=1
				param[2]=2
				
				msg_anim(id,anim_shotgunstartreload)
				PlaySequence(id,PLAYER_RELOAD)
				
				new Float:rtime=1.1*100.0/float(Reloadspeedmul_value_percent[id][weapon_secondry])
				
				remove_task(id+TASK_STARTRELOAD)
				if(Reloadspeedmul_switch[id][weapon_secondry])
				{
					set_task(rtime,"func_reload",id+TASK_STARTRELOAD,param,3)
				}else{
					set_task(0.35,"func_reload",id+TASK_STARTRELOAD,param,3)
				}
			}
			case human_sniper:
			{
				player_reloadstatus[id][reload_none]=false
				player_reloadstatus[id][reload_start]=false
				player_reloadstatus[id][reload_ing]=true
				player_reloadstatus[id][reload_end]=false
				
				new param[3]
				param[0]=id
				param[1]=0
				param[2]=2
				
				msg_anim(id,anim_smgreload)
				PlaySequence(id,PLAYER_RELOAD)
				
				new Float:rtime=1.2*100.0/float(Reloadspeedmul_value_percent[id][weapon_secondry])
				
				remove_task(id+TASK_STARTRELOAD)
				if(Reloadspeedmul_switch[id][weapon_secondry])
				{
					set_task(rtime,"func_reload",id+TASK_STARTRELOAD,param,3)
				}else{
					set_task(1.2,"func_reload",id+TASK_STARTRELOAD,param,3)
				}
			}
			case human_medic:
			{
				player_reloadstatus[id][reload_none]=false
				player_reloadstatus[id][reload_start]=false
				player_reloadstatus[id][reload_ing]=true
				player_reloadstatus[id][reload_end]=false
				
				new param[3]
				param[0]=id
				param[1]=0
				param[2]=2
				
				msg_anim(id,anim_syringereload)
				PlaySequence(id,PLAYER_RELOAD)
				
				new Float:rtime=1.4*100.0/float(Reloadspeedmul_value_percent[id][weapon_secondry])
				
				remove_task(id+TASK_STARTRELOAD)
				if(Reloadspeedmul_switch[id][weapon_secondry])
				{
					set_task(rtime,"func_reload",id+TASK_STARTRELOAD,param,3)
				}else{
					set_task(1.4,"func_reload",id+TASK_STARTRELOAD,param,3)
				}
			}
			case human_engineer:
			{
				player_reloadstatus[id][reload_none]=false
				player_reloadstatus[id][reload_start]=false
				player_reloadstatus[id][reload_ing]=true
				player_reloadstatus[id][reload_end]=false
				
				new param[3]
				param[0]=id
				param[1]=0
				param[2]=2
				
				msg_anim(id,anim_pistolreload)
				PlaySequence(id,PLAYER_RELOAD)
				
				new Float:rtime=1.1*100.0/float(Reloadspeedmul_value_percent[id][weapon_secondry])
				
				remove_task(id+TASK_STARTRELOAD)
				if(Reloadspeedmul_switch[id][weapon_secondry])
				{
					set_task(rtime,"func_reload",id+TASK_STARTRELOAD,param,3)
				}else{
					set_task(1.1,"func_reload",id+TASK_STARTRELOAD,param,3)
				}
			}
			case human_demoman:
			{
				player_reloadstatus[id][reload_none]=false
				player_reloadstatus[id][reload_start]=true
				player_reloadstatus[id][reload_ing]=false
				player_reloadstatus[id][reload_end]=false
				
				new param[3]
				param[0]=id
				param[1]=1
				param[2]=2
				
				msg_anim(id,anim_stickystartreload)
				PlaySequence(id,PLAYER_RELOAD)
				
				new Float:rtime=get_pcvar_float(cvar_wpn_stickylauncher_strelo)*100.0/float(Reloadspeedmul_value_percent[id][weapon_secondry])
				
				remove_task(id+TASK_STARTRELOAD)
				if(Reloadspeedmul_switch[id][weapon_secondry])
				{
					set_task(rtime,"func_reload",id+TASK_STARTRELOAD,param,3)
				}else{
					set_task(get_pcvar_float(cvar_wpn_stickylauncher_strelo),"func_reload",id+TASK_STARTRELOAD,param,3)
				}
			}
			case human_assassin:
			{
				player_reloadstatus[id][reload_none]=false
				player_reloadstatus[id][reload_start]=false
				player_reloadstatus[id][reload_ing]=true
				player_reloadstatus[id][reload_end]=false
				
				new param[3]
				param[0]=id
				param[1]=0
				param[2]=2
				
				msg_anim(id,anim_assdeaglereload)
				PlaySequence(id,PLAYER_RELOAD)
				
				new Float:rtime=4.2*100.0/float(Reloadspeedmul_value_percent[id][weapon_secondry])
				
				remove_task(id+TASK_STARTRELOAD)
				if(Reloadspeedmul_switch[id][weapon_secondry])
				{
					set_task(rtime,"func_reload",id+TASK_STARTRELOAD,param,3)
				}else{
					set_task(4.2,"func_reload",id+TASK_STARTRELOAD,param,3)
				}
			}
			
		}
	}
	
}
public func_reload(param[])
{
	new id = param[0]
	new reloadtype = param[1]
	new wpnslot = param[2]
	
	if(!is_user_alive(id)) return;
	
	new pri_fact_reloadnum,sec_fact_reloadnum
	
	new priammo = gpri_bpammo[id]
	new need_priammo = gmaxpriclip[id]-gpri_clip[id]
	if(priammo-need_priammo>=0)
	{
		pri_fact_reloadnum=need_priammo
	}
	else{
		pri_fact_reloadnum=priammo
	}
	
	new secammo = gsec_bpammo[id]
	new need_secammo = gmaxsecclip[id]-gsec_clip[id]
	if(secammo-need_secammo>=0)
	{
		sec_fact_reloadnum=need_secammo
	}
	else{
		sec_fact_reloadnum=secammo
	}
		
	
	switch(wpnslot)
	{
		case 1:
		{
			switch(reloadtype)
			{
				case 0:
				{
					player_reloadstatus[id][reload_none]=true
					player_reloadstatus[id][reload_start]=false
					player_reloadstatus[id][reload_ing]=false
					player_reloadstatus[id][reload_end]=false
					
					gpri_clip[id]+=pri_fact_reloadnum
					gpri_bpammo[id]-=pri_fact_reloadnum
					ckrun_update_user_clip_ammo(id)
					PlaySequence(id,PLAYER_IDLE)
					
					switch(ghuman[id])
					{
						case human_spy:
						{
							//engfunc(EngFunc_EmitSound,id, CHAN_STATIC,snd_wpn_revolver_reload, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						}
						
					}
						
				}
				case 1:
				{
					player_reloadstatus[id][reload_none]=false
					player_reloadstatus[id][reload_start]=false
					player_reloadstatus[id][reload_ing]=true
					player_reloadstatus[id][reload_end]=false
					
					remove_task(id+TASK_RELOADING)
					
					switch(ghuman[id])
					{
						case human_scout:
						{
							msg_anim(id,anim_shotgunreloading)
							
							param[1]=50
							new Float:rtime=0.5*100.0/float(Reloadspeedmul_value_percent[id][weapon_primary])
							if(Reloadspeedmul_switch[id][weapon_primary])
							{
								param[1]=floatround(rtime*100.0)
								set_task(rtime,"func_reloading",id+TASK_RELOADING,param,3)
							}else{
								set_task(0.5,"func_reloading",id+TASK_RELOADING,param,3)
							}
							//engfunc(EngFunc_EmitSound,id, CHAN_STATIC,snd_wpn_scattergun_reload, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						}
						case human_soldier:
						{
							msg_anim(id,anim_rpgreloading)
							
							param[1]=70
							new Float:rtime=0.7*100.0/float(Reloadspeedmul_value_percent[id][weapon_primary])
							if(Reloadspeedmul_switch[id][weapon_primary])
							{
								param[1]=floatround(rtime*100.0)
								set_task(rtime,"func_reloading",id+TASK_RELOADING,param,3)
							}else{
								set_task(0.7,"func_reloading",id+TASK_RELOADING,param,3)
							}
							//engfunc(EngFunc_EmitSound,id, CHAN_STATIC,snd_wpn_rpg_reload, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						}
						case human_engineer:
						{
							msg_anim(id,anim_shotgunreloading)
							
							param[1]=50
							new Float:rtime=0.5*100.0/float(Reloadspeedmul_value_percent[id][weapon_primary])
							if(Reloadspeedmul_switch[id][weapon_primary])
							{
								param[1]=floatround(rtime*100.0)
								set_task(rtime,"func_reloading",id+TASK_RELOADING,param,3)
							}else{
								set_task(0.5,"func_reloading",id+TASK_RELOADING,param,3)
							}
							//engfunc(EngFunc_EmitSound,id, CHAN_STATIC,snd_wpn_shotgun_reload, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						}
						case human_demoman:
						{
							msg_anim(id,anim_grenadereloading)
							
							param[1]=65
							new Float:rtime=0.65*100.0/float(Reloadspeedmul_value_percent[id][weapon_primary])
							if(Reloadspeedmul_switch[id][weapon_primary])
							{
								param[1]=floatround(rtime*100.0)
								set_task(rtime,"func_reloading",id+TASK_RELOADING,param,3)
							}else{
								set_task(0.65,"func_reloading",id+TASK_RELOADING,param,3)
							}
							//engfunc(EngFunc_EmitSound,id, CHAN_STATIC,snd_wpn_grenadelauncher_reload, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						}
						case human_assassin:
						{
							msg_anim(id,anim_assm3reloading)
							
							param[1]=50
							new Float:rtime=0.5*100.0/float(Reloadspeedmul_value_percent[id][weapon_primary])
							if(Reloadspeedmul_switch[id][weapon_primary])
							{
								param[1]=floatround(rtime*100.0)
								set_task(rtime,"func_reloading",id+TASK_RELOADING,param,3)
							}else{
								set_task(0.5,"func_reloading",id+TASK_RELOADING,param,3)
							}
							//engfunc(EngFunc_EmitSound,id, CHAN_STATIC,snd_wpn_shotgun_reload, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						}
					}
				}
			}
		}
		case 2:
		{
			switch(reloadtype)
			{
				case 0:
				{
					player_reloadstatus[id][reload_none]=true
					player_reloadstatus[id][reload_start]=false
					player_reloadstatus[id][reload_ing]=false
					player_reloadstatus[id][reload_end]=false
					
					gsec_clip[id]+=sec_fact_reloadnum
					gsec_bpammo[id]-=sec_fact_reloadnum
					ckrun_update_user_clip_ammo(id)
					PlaySequence(id,PLAYER_IDLE)
					
					switch(ghuman[id])
					{
						case human_scout,human_engineer:
						{
							//engfunc(EngFunc_EmitSound,id, CHAN_STATIC,snd_wpn_pistol_reload, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						}
						case human_sniper:
						{
							//engfunc(EngFunc_EmitSound,id, CHAN_STATIC,snd_wpn_smg_reload, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						}
						case human_medic:
						{
							//engfunc(EngFunc_EmitSound,id, CHAN_STATIC,snd_wpn_syringegun_reload, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						}
						case human_assassin:
						{
							engfunc(EngFunc_EmitSound,id, CHAN_STATIC,snd_wpn_assdeagle_reload, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						}
					}

				}
				case 1:
				{
					player_reloadstatus[id][reload_none]=false
					player_reloadstatus[id][reload_start]=false
					player_reloadstatus[id][reload_ing]=true
					player_reloadstatus[id][reload_end]=false
					
					remove_task(id+TASK_RELOADING)
					switch(ghuman[id])
					{
						case human_heavy,human_soldier,human_pyro:
						{
							msg_anim(id,anim_shotgunreloading)
							
							param[1]=50
							new Float:rtime=0.5*100.0/float(Reloadspeedmul_value_percent[id][weapon_secondry])
							if(Reloadspeedmul_switch[id][weapon_secondry])
							{
								param[1]=floatround(rtime*100.0)
								set_task(rtime,"func_reloading",id+TASK_RELOADING,param,3)
							}else{
								set_task(0.5,"func_reloading",id+TASK_RELOADING,param,3)
							}
							//engfunc(EngFunc_EmitSound,id, CHAN_STATIC,snd_wpn_shotgun_reload, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						}
						case human_demoman:
						{
							msg_anim(id,anim_stickyreloading)
							
							param[1]=floatround(get_pcvar_float(cvar_wpn_stickylauncher_inrelo)*100.0)
							new Float:rtime=get_pcvar_float(cvar_wpn_stickylauncher_inrelo)*100.0/float(Reloadspeedmul_value_percent[id][weapon_secondry])
							if(Reloadspeedmul_switch[id][weapon_secondry])
							{
								param[1]=floatround(rtime*100.0)
								set_task(rtime,"func_reloading",id+TASK_RELOADING,param,3)
							}else{
								set_task(get_pcvar_float(cvar_wpn_stickylauncher_inrelo),"func_reloading",id+TASK_RELOADING,param,3)
							}
							//engfunc(EngFunc_EmitSound,id, CHAN_STATIC,snd_wpn_stickylauncher_reload, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						}
					}
				}
			}
		}
	}
}
public func_reloading(param[])
{
	new id = param[0]
	new Float:nextreload = float(param[1])/100.0
	new wpnslot = param[2]
	
	if(!is_user_alive(id)) return;
	
	
	switch(wpnslot)
	{
		case 1:
		{
			gpri_clip[id]++
			gpri_bpammo[id]--
			
			if(gpri_clip[id]>=gmaxpriclip[id]||gpri_bpammo[id]<=0)
			{
				player_reloadstatus[id][reload_none]=false
				player_reloadstatus[id][reload_start]=false
				player_reloadstatus[id][reload_ing]=false
				player_reloadstatus[id][reload_end]=true
				
				ckrun_update_user_clip_ammo(id)
				PlaySequence(id,PLAYER_IDLE)
				
				remove_task(id+TASK_ENDRELOAD)
				
				switch(ghuman[id])
				{
					case human_scout:
					{
						msg_anim(id,anim_shotgunendreload)
						
						param[2]=0
						set_task(0.3,"func_endreload",id+TASK_ENDRELOAD,param,3)
					}
					case human_soldier:
					{
						msg_anim(id,anim_rpgendreload)
						
						param[2]=0
						set_task(0.5,"func_endreload",id+TASK_ENDRELOAD,param,3)
					}
					case human_engineer:
					{
						msg_anim(id,anim_shotgunendreload)
						
						param[2]=0
						set_task(0.3,"func_endreload",id+TASK_ENDRELOAD,param,3)
					}
					case human_demoman:
					{
						msg_anim(id,anim_grenadeendreload)
						
						param[2]=0
						set_task(get_pcvar_float(cvar_wpn_stickylauncher_endrelo),"func_endreload",id+TASK_ENDRELOAD,param,3)
					}
					case human_assassin:
					{
						msg_anim(id,anim_assm3endreload)
						
						param[2]=0
						set_task(0.3,"func_endreload",id+TASK_ENDRELOAD,param,3)
					}
				}
				
				return;
			}
			ckrun_update_user_clip_ammo(id)
			PlaySequence(id,PLAYER_RELOAD)
			
			remove_task(id+TASK_RELOADING)
			set_task(nextreload,"func_reloading",id+TASK_RELOADING,param,3)
			
			switch(ghuman[id])
			{
				case human_scout,human_engineer:
				{
					msg_anim(id,anim_shotgunreloading)
				}
				case human_demoman:
				{
					msg_anim(id,anim_stickyreloading)
				}
				case human_assassin:
				{
					msg_anim(id,anim_assm3reloading)
				}
			}
		}
		case 2:
		{
			gsec_clip[id]++
			gsec_bpammo[id]--
			
			if(gsec_clip[id]>=gmaxsecclip[id]||gsec_bpammo[id]<=0)
			{
				player_reloadstatus[id][reload_none]=false
				player_reloadstatus[id][reload_start]=false
				player_reloadstatus[id][reload_ing]=false
				player_reloadstatus[id][reload_end]=true
				
				ckrun_update_user_clip_ammo(id)
				PlaySequence(id,PLAYER_IDLE)
				
				remove_task(id+TASK_ENDRELOAD)
				
				switch(ghuman[id])
				{
					case human_heavy,human_soldier,human_pyro:
					{
						msg_anim(id,anim_shotgunendreload)
						
						param[2]=0
						set_task(0.3,"func_endreload",id+TASK_ENDRELOAD,param,3)
					}
					case human_demoman:
					{
						msg_anim(id,anim_grenadeendreload)
						
						param[2]=0
						set_task(0.3,"func_endreload",id+TASK_ENDRELOAD,param,3)
					}
				}
				
				return;
			}
			ckrun_update_user_clip_ammo(id)
			PlaySequence(id,PLAYER_RELOAD)
			
			remove_task(id+TASK_RELOADING)
			set_task(nextreload,"func_reloading",id+TASK_RELOADING,param,3)
			
			switch(ghuman[id])
			{
				case human_heavy,human_soldier,human_pyro:
				{
					msg_anim(id,anim_shotgunreloading)
				}
				case human_demoman:
				{
					msg_anim(id,anim_stickyreloading)
				}
			}
		}
	}
	
}
public func_endreload(param[])
{
	ckrun_reset_user_weaponreload(param[0])
}

public func_knifeattack(id)
{
	if(knifeattacking[id]) return;
	
	ExecuteForward(g_fwKnifeAttacking,g_fwResult,id)
	
	PlaySequence(id,PLAYER_ATTACK1)
	
	
	new critnum,param[5]
	
	if(Boss != id)
	{
		if(!giszm[id])
		{
			switch(ghuman[id])
			{
				case human_scout:
				{
					knifeattacking[id]=true
					
					
					new num = random_num(1,100)
					if(num<=gcritical[id]||g_critical_on[id]||must_critical[id])
					{
						critnum=2
					}
					param[0]=id
					param[1]=critnum
					param[2]=ghuman[id]
					param[3]=0
					
					msg_anim(id,random_num(6,7))
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_swing, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					
					set_task(0.1,"knifeattack",id+TASK_KNIFEATTACKING,param,4)
				}
				case human_heavy:
				{
					knifeattacking[id]=true
					
					new num = random_num(1,100)
					if(num<=gcritical[id]||g_critical_on[id]||must_critical[id])
					{
						critnum=2
					}
					param[0]=id
					param[1]=critnum
					param[2]=ghuman[id]
					param[3]=0
					
					if(pev(id,pev_button)&IN_ATTACK)
						msg_anim(id,6)
					else if(pev(id,pev_button)&IN_ATTACK2)
						msg_anim(id,7)
						
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_swing, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					
					set_task(0.18,"knifeattack",id+TASK_KNIFEATTACKING,param,4)
				}
				case human_soldier:
				{
					new Float:vec[3]
					pev(id,pev_velocity,vec)
					new bool:shovelcrit=false
					if(vec[0]<0.0)
					{
						vec[0]*=-1.0
					}
					if(vec[1]<0.0)
					{
						vec[1]*=-1.0
					}
					if(vec[2]<0.0)
					{
						vec[2]*=-1.0
					}
					if(vec[0]>300.0||vec[2]>300.0||vec[2]>300.0)
					{
						shovelcrit=true
					}
					
					
					knifeattacking[id]=true
					
					new num = random_num(1,100)
					if(num<=gcritical[id]||g_critical_on[id]||must_critical[id]||shovelcrit)
					{
						critnum=2
					}
					param[0]=id
					param[1]=critnum
					param[2]=ghuman[id]
					param[3]=0
					
					msg_anim(id,random_num(6,7))
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_swing, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					
					set_task(0.22,"knifeattack",id+TASK_KNIFEATTACKING,param,4)
				}
				case human_pyro:
				{
					new Float:vec[3]
					pev(id,pev_velocity,vec)
					
					knifeattacking[id]=true
					
					new num = random_num(1,100)
					if(num<=gcritical[id]||g_critical_on[id]||must_critical[id])
					{
						critnum=2
					}
					param[0]=id
					param[1]=critnum
					param[2]=ghuman[id]
					param[3]=0
					
					msg_anim(id,random_num(6,7))
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_swing, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					
					set_task(0.18,"knifeattack",id+TASK_KNIFEATTACKING,param,4)
				}
				case human_sniper:
				{
					knifeattacking[id]=true
					
					new num = random_num(1,100)
					if(num<=gcritical[id]||g_critical_on[id]||must_critical[id])
					{
						critnum=2
					}
					param[0]=id
					param[1]=critnum
					param[2]=ghuman[id]
					param[3]=0
					
					msg_anim(id,random_num(6,7))
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_swing, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					
					set_task(0.18,"knifeattack",id+TASK_KNIFEATTACKING,param,4)
				}
				case human_medic:
				{
					knifeattacking[id]=true
					
					new num = random_num(1,100)
					if(num<=gcritical[id]||g_critical_on[id]||must_critical[id])
					{
						critnum=2
					}
					param[0]=id
					param[1]=critnum
					param[2]=ghuman[id]
					param[3]=0
					
					msg_anim(id,random_num(6,7))
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_swing, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					
					set_task(0.2,"knifeattack",id+TASK_KNIFEATTACKING,param,4)
				}
				case human_engineer:
				{
					knifeattacking[id]=true
					
					new num = random_num(1,100)
					if(num<=gcritical[id]||g_critical_on[id]||must_critical[id])
					{
						critnum=2
					}
					param[0]=id
					param[1]=critnum
					param[2]=ghuman[id]
					param[3]=0
					
					msg_anim(id,random_num(6,7))
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_wrench_hitswing, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					
					set_task(0.3,"knifeattack",id+TASK_KNIFEATTACKING,param,4)
					
				}
				case human_demoman:
				{
					knifeattacking[id]=true
					
					new num = random_num(1,100)
					if(num<=gcritical[id]||g_critical_on[id]||must_critical[id])
					{
						critnum=2
					}
					param[0]=id
					param[1]=critnum
					param[2]=ghuman[id]
					param[3]=0
					
					msg_anim(id,random_num(6,7))
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_swing, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					
					set_task(0.18,"knifeattack",id+TASK_KNIFEATTACKING,param,4)
					
				}
				case human_spy:
				{
					if(invisible_ing[id]||invisible_ed[id]||uninvisible_ing[id]) return;
					
					func_undisguise(id)
					
					knifeattacking[id]=true
					/*
					new num = random_num(1,100)
					if(num<=gcritical[id]||g_critical_on[id]||must_critical[id])
					{
						critnum=2
					}*/
					
					if(butterfly_backuped[id]||must_critical[id])
					{
						critnum=2
						msg_anim(id,butterfly_animbackstab)
					}else{
						msg_anim(id,random_num(6,7))
					}
					
					butterfly_backuping[id]=false
					butterfly_backuped[id]=false
					butterfly_backdownning[id]=false
					
					param[0]=id
					param[1]=critnum
					param[2]=ghuman[id]
					param[3]=0
					
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_butterfly_swing, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					
					if(critnum>=2)
					{
						knifeattack(param)
					}else{
						set_task(0.1,"knifeattack",id+TASK_KNIFEATTACKING,param,4)
					}
				}
			}
		}else{
			switch(gzombie[id])
			{
				case zombie_scout:
				{
					knifeattacking[id]=true
					
					new num = random_num(1,100)
					if(num<=gcritical[id]||g_critical_on[id]||must_critical[id])
					{
						critnum=2
					}
					param[0]=id
					param[1]=critnum
					param[2]=0
					param[3]=gzombie[id]
					
					msg_anim(id,random_num(6,7))
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_swing, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					
					set_task(0.1,"knifeattack",id+TASK_KNIFEATTACKING,param,4)
				}
				case zombie_heavy:
				{
					knifeattacking[id]=true
					
					new num = random_num(1,100)
					if(num<=gcritical[id]||g_critical_on[id]||must_critical[id])
					{
						critnum=2
					}
					param[0]=id
					param[1]=critnum
					param[2]=0
					param[3]=gzombie[id]
					
					if(pev(id,pev_button)&IN_ATTACK)
						msg_anim(id,6)
					else if(pev(id,pev_button)&IN_ATTACK2)
						msg_anim(id,7)
						
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_swing, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					
					set_task(0.18,"knifeattack",id+TASK_KNIFEATTACKING,param,4)
				}
				case zombie_soldier:
				{
					knifeattacking[id]=true
					
					new num = random_num(1,100)
					if(num<=gcritical[id]||g_critical_on[id]||must_critical[id])
					{
						critnum=2
					}
					param[0]=id
					param[1]=critnum
					param[3]=gzombie[id]
					
					msg_anim(id,random_num(6,7))
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_swing, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					
					set_task(0.22,"knifeattack",id+TASK_KNIFEATTACKING,param,4)
				}
				case zombie_pyro:
				{
					knifeattacking[id]=true
					
					new num = random_num(1,100)
					if(num<=gcritical[id]||g_critical_on[id]||must_critical[id])
					{
						critnum=2
					}
					param[0]=id
					param[1]=critnum
					param[2]=0
					param[3]=gzombie[id]
					
					msg_anim(id,random_num(6,7))
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_swing, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					
					set_task(0.18,"knifeattack",id+TASK_KNIFEATTACKING,param,4)
				}
				case zombie_sniper:
				{
					knifeattacking[id]=true
					
					new num = random_num(1,100)
					if(num<=gcritical[id]||g_critical_on[id]||must_critical[id])
					{
						critnum=2
					}
					param[0]=id
					param[1]=critnum
					param[3]=gzombie[id]
					
					msg_anim(id,random_num(6,7))
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_swing, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					
					set_task(0.18,"knifeattack",id+TASK_KNIFEATTACKING,param,4)
				}
				case zombie_medic:
				{
					knifeattacking[id]=true
					
					new num = random_num(1,100)
					if(num<=gcritical[id]||g_critical_on[id]||must_critical[id])
					{
						critnum=2
					}
					param[0]=id
					param[1]=critnum
					param[3]=gzombie[id]
					
					msg_anim(id,random_num(6,7))
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_swing, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					
					set_task(0.2,"knifeattack",id+TASK_KNIFEATTACKING,param,4)
				}
				case zombie_engineer:
				{
					knifeattacking[id]=true
					
					new num = random_num(1,100)
					if(num<=gcritical[id]||g_critical_on[id]||must_critical[id])
					{
						critnum=2
					}
					param[0]=id
					param[1]=critnum
					param[2]=0
					param[3]=gzombie[id]
					
					msg_anim(id,random_num(6,7))
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_wrench_hitswing, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					
					set_task(0.3,"knifeattack",id+TASK_KNIFEATTACKING,param,4)
					
				}
				case zombie_demoman:
				{
					knifeattacking[id]=true
					
					new num = random_num(1,100)
					if(num<=gcritical[id]||g_critical_on[id]||must_critical[id])
					{
						critnum=2
					}
					param[0]=id
					param[1]=critnum
					param[2]=0
					param[3]=gzombie[id]
					
					msg_anim(id,random_num(6,7))
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_swing, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					
					set_task(0.18,"knifeattack",id+TASK_KNIFEATTACKING,param,4)
					
				}
				case zombie_spy:
				{
					if(invisible_ing[id]||invisible_ed[id]||uninvisible_ing[id]) return;
					
					knifeattacking[id]=true
					/*
					new num = random_num(1,100)
					if(num<=gcritical[id]||g_critical_on[id]||must_critical[id])
					{
						critnum=2
					}*/
					
					if(butterfly_backuped[id]||must_critical[id])
					{
						critnum=2
						msg_anim(id,butterfly_animbackstab)
					}else{
						msg_anim(id,random_num(6,7))
					}
					butterfly_backuping[id]=false
					butterfly_backuped[id]=false
					butterfly_backdownning[id]=false
					
					param[0]=id
					param[1]=critnum
					param[2]=0
					param[3]=gzombie[id]
					
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_butterfly_swing, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					
					if(critnum>=2)
					{
						knifeattack(param)
					}else{
						set_task(0.1,"knifeattack",id+TASK_KNIFEATTACKING,param,4)
					}
				}
			}
		}
	}else{
		switch(gboss[id])
		{
			case boss_cbs:
			{
				knifeattacking[id]=true
				
				param[0]=id
				param[1]=critnum
				param[2]=0
				param[3]=0
				param[4]=gboss[id]
				
				msg_anim(id,random_num(6,7))
				engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_vs_CBS_shoot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				
				set_task(0.18,"knifeattack",id+TASK_KNIFEATTACKING,param,5)
			}
			case boss_scp173:
			{
				knifeattacking[id]=true
				
				param[0]=id
				param[1]=critnum
				param[2]=0
				param[3]=0
				param[4]=gboss[id]
				
				msg_anim(id,random_num(6,7))
				engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_swing, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				
				set_task(0.1,"knifeattack",id+TASK_KNIFEATTACKING,param,5)
			}
			case boss_creeper:
			{
				knifeattacking[id]=true
				
				param[0]=id
				param[1]=critnum
				param[2]=0
				param[3]=0
				param[4]=gboss[id]
				
				msg_anim(id,random_num(6,7))
				engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_swing, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				
				set_task(0.18,"knifeattack",id+TASK_KNIFEATTACKING,param,5)
			}
			case boss_guardian:
			{
				knifeattacking[id]=true
				
				param[0]=id
				param[1]=critnum
				param[2]=0
				param[3]=0
				param[4]=gboss[id]
				
				msg_anim(id,random_num(6,7))
				engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_swing, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				
				set_task(0.18,"knifeattack",id+TASK_KNIFEATTACKING,param,5)
			}
		}
	}
	
	
	if(critnum>=2)
	{
		engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_crit_shot, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	}
	
}
public knifeattack(param[])
{
	new id,critnum,human,zombie,bosstype
	id=param[0]
	critnum=param[1]
	human=param[2]
	zombie=param[3]
	bosstype=param[4]
	
	
	if(!knifeattacking[id]) return;
	
	if(!is_user_alive(id))
	{
		knifeattacking[id]=false
		return;
	}
	new target=0,num=0,Float:idorg[3],Float:sizemin[3],Float:sizemax[3],Float:targetorg[3],Float:touched[3],bool:hitbody=false
	ckrun_get_user_startpos(id,0.0,0.0,0.0,idorg)
	
	
	if(human>0)
	{
		switch(human)
		{
			case human_scout:
			{
				ckrun_get_user_startpos(id,65.0,0.0,0.0,targetorg)
				new ent = fm_trace_line(id,idorg,targetorg,touched)
				
				if(ent==0)
				{
					while((target = engfunc(EngFunc_FindEntityInSphere,target,idorg,65.0))!=0)
					{
						if(num>0) continue;
						
						pev(target,pev_origin,targetorg)
						new ent = fm_trace_line(id,idorg,targetorg,touched)
						
						new class[32]
						pev(ent,pev_classname,class,31)
						
						
						if(ent>0&&ent==target)
						{
							
							if(fm_is_in_viewcone(id,touched,90.0))
							{
								if(ent<=g_maxplayer&&gteam[id]==gteam[ent]) continue;
								
								ckrun_takedamage(ent,id,30,CKRW_BAT,CKRD_MELEE,critnum,1,0,0)
								
								num++
								hitbody=true
							}
						}
					}
				}else{
					ckrun_takedamage(ent,id,30,CKRW_BAT,CKRD_MELEE,critnum,1,0,0)
					hitbody=true
				}
				if(hitbody)
				{
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_bat_hit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
			}
			case human_heavy:
			{
				ckrun_get_user_startpos(id,65.0,0.0,0.0,targetorg)
				new ent = fm_trace_line(id,idorg,targetorg,touched)
				
				if(ent==0)
				{
					while((target = engfunc(EngFunc_FindEntityInSphere,target,idorg,65.0))!=0)
					{
						if(num>0) continue;
						
						pev(target,pev_origin,targetorg)
						new ent = fm_trace_line(id,idorg,targetorg,touched)
						
						new class[32]
						pev(ent,pev_classname,class,31)
						
						
						if(ent>0&&ent==target)
						{
							
							if(fm_is_in_viewcone(id,touched,90.0))
							{
								if(ent<=g_maxplayer&&gteam[id]==gteam[ent]) continue;
								
								ckrun_takedamage(ent,id,65,CKRW_FIST,CKRD_MELEE,critnum,1,0,0)
								
								num++
								hitbody=true
							}
						}
					}
				}else{
					ckrun_takedamage(ent,id,65,CKRW_FIST,CKRD_MELEE,critnum,1,0,0)
					hitbody=true
				}
				if(hitbody)
				{
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_fist_hitbody, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
			}		
			case human_soldier:
			{
				ckrun_get_user_startpos(id,65.0,0.0,0.0,targetorg)
				new ent = fm_trace_line(id,idorg,targetorg,touched)
				
				if(ent==0)
				{
					while((target = engfunc(EngFunc_FindEntityInSphere,target,idorg,65.0))!=0)
					{
						if(num>0) continue;
						
						pev(target,pev_origin,targetorg)
						new ent = fm_trace_line(id,idorg,targetorg,touched)
						
						new class[32]
						pev(ent,pev_classname,class,31)
						
						
						if(ent>0&&ent==target)
						{
							
							if(fm_is_in_viewcone(id,touched,90.0))
							{
								if(ent<=g_maxplayer&&gteam[id]==gteam[ent]) continue;
								
								ckrun_takedamage(ent,id,65,CKRW_SHOVEL,CKRD_MELEE,critnum,1,0,0)
								
								num++
								hitbody=true
							}
						}
					}
				}else{
					ckrun_takedamage(ent,id,65,CKRW_SHOVEL,CKRD_MELEE,critnum,1,0,0)
					hitbody=true
				}
				if(hitbody)
				{
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_shovel_hit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
			}
			case human_pyro:
			{
				ckrun_get_user_startpos(id,65.0,0.0,0.0,targetorg)
				new ent = fm_trace_line(id,idorg,targetorg,touched)
				
				if(ent==0)
				{
					while((target = engfunc(EngFunc_FindEntityInSphere,target,idorg,65.0))!=0)
					{
						if(num>0) continue;
						
						pev(target,pev_origin,targetorg)
						new ent = fm_trace_line(id,idorg,targetorg,touched)
						
						new class[32]
						pev(ent,pev_classname,class,31)
						
						
						if(ent>0&&ent==target)
						{
							
							if(fm_is_in_viewcone(id,touched,90.0))
							{
								if(ent<=g_maxplayer&&gteam[id]==gteam[ent]) continue;
								
								func_bleed(ent,id,CKRW_AXE,2,10)
								ckrun_takedamage(ent,id,65,CKRW_AXE,CKRD_MELEE,critnum,1,0,0)
								
								num++
								hitbody=true
							}
						}
					}
				}else{
					ckrun_takedamage(ent,id,65,CKRW_AXE,CKRD_MELEE,critnum,1,0,0)
					hitbody=true
				}
				if(hitbody)
				{
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_fireaxe_hitbody, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
			}
			case human_sniper:
			{
				ckrun_get_user_startpos(id,65.0,0.0,0.0,targetorg)
				new ent = fm_trace_line(id,idorg,targetorg,touched)
				
				if(ent==0)
				{
					while((target = engfunc(EngFunc_FindEntityInSphere,target,idorg,65.0))!=0)
					{
						if(num>0) continue;
						
						pev(target,pev_origin,targetorg)
						new ent = fm_trace_line(id,idorg,targetorg,touched)
						
						new class[32]
						pev(ent,pev_classname,class,31)
						
						if(ent>0&&ent==target)
						{
							if(fm_is_in_viewcone(id,touched,90.0))
							{
								if(ent<=g_maxplayer&&gteam[id]==gteam[ent]) continue;
								
								ckrun_takedamage(ent,id,65,CKRW_HUNTINGKNIFE,CKRD_MELEE,critnum,1,0,0)
								
								num++
								hitbody=true
							}
						}
					}
				}else{
					ckrun_takedamage(ent,id,65,CKRW_HUNTINGKNIFE,CKRD_MELEE,critnum,1,0,0)
					hitbody=true
				}
				if(hitbody)
				{
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_machete_hit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
			}
			case human_medic:
			{
				ckrun_get_user_startpos(id,65.0,0.0,0.0,targetorg)
				new ent = fm_trace_line(id,idorg,targetorg,touched)
				
				if(ent==0)
				{
					while((target = engfunc(EngFunc_FindEntityInSphere,target,idorg,65.0))!=0)
					{
						if(num>0) continue;
						
						pev(target,pev_origin,targetorg)
						new ent = fm_trace_line(id,idorg,targetorg,touched)
						
						new class[32]
						pev(ent,pev_classname,class,31)
						
						if(ent>0&&ent==target)
						{
							if(fm_is_in_viewcone(id,touched,90.0))
							{
								if(ent<=g_maxplayer&&gteam[id]==gteam[ent]) continue;
								
								ckrun_takedamage(ent,id,65,CKRW_BONESAW,CKRD_MELEE,critnum,1,0,0)
								
								num++
								hitbody=true
							}
						}
					}
				}else{
					ckrun_takedamage(ent,id,65,CKRW_BONESAW,CKRD_MELEE,critnum,1,0,0)
					hitbody=true
				}
				if(hitbody)
				{
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_bonesaw_hit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
			}
			case human_engineer:
			{
				ckrun_get_user_startpos(id,65.0,0.0,0.0,targetorg)
				new ent = fm_trace_line(id,idorg,targetorg,touched)
				
				if(ent==0)
				{
					while((target = engfunc(EngFunc_FindEntityInSphere,target,idorg,65.0))!=0)
					{
						if(num>0) continue;
						
						pev(target,pev_origin,targetorg)
						new ent = fm_trace_line(id,idorg,targetorg,touched)
						
						new class[32]
						pev(ent,pev_classname,class,31)
						
						if(ent>0&&ent==target)
						{
							if(fm_is_in_viewcone(id,touched,90.0))
							{
								if(ent<=g_maxplayer&&gteam[id]==gteam[ent]) continue;
								
								ckrun_takedamage(ent,id,65,CKRW_WRENCH,CKRD_MELEE,critnum,1,0,0)
								num++
								hitbody=true
								
								if(equali(class,"build_sentry") || equali(class,"build_dispenser"))
								{
									ckrun_repair_build(ent,id,25)
									engfunc(EngFunc_EmitSound,ent, CHAN_STATIC, snd_wpn_wrench_hitbuild, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
								}
								if(equali(class,"build_sentry"))
								{	
									ckrun_sapper_removed(id,id,build_sentry,50,CKRW_WRENCH,0)
								}
								else if(equali(class,"build_dispenser"))
								{	
									ckrun_sapper_removed(id,id,build_dispenser,50,CKRW_WRENCH,0)
								}
							}
						}
					}
				}else{
					new class[32]
					pev(ent,pev_classname,class,31)
								
					ckrun_takedamage(ent,id,65,CKRW_WRENCH,CKRD_MELEE,critnum,1,0,0)
					num++
					hitbody=true
					
					if(equali(class,"build_sentry") || equali(class,"build_dispenser"))
					{
						ckrun_repair_build(ent,id,25)
						engfunc(EngFunc_EmitSound,ent, CHAN_STATIC, snd_wpn_wrench_hitbuild, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
					if(equali(class,"build_sentry"))
					{	
						ckrun_sapper_removed(id,id,build_sentry,50,CKRW_WRENCH,0)
					}
					else if(equali(class,"build_dispenser"))
					{	
						ckrun_sapper_removed(id,id,build_dispenser,50,CKRW_WRENCH,0)
					}
					
					hitbody=true
				}
				if(hitbody)
				{
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_wrench_hitworld, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
			}
			case human_demoman:
			{
				ckrun_get_user_startpos(id,65.0,0.0,0.0,targetorg)
				new ent = fm_trace_line(id,idorg,targetorg,touched)
				
				if(ent==0)
				{
					while((target = engfunc(EngFunc_FindEntityInSphere,target,idorg,65.0))!=0)
					{
						if(num>0) continue;
						
						pev(target,pev_origin,targetorg)
						new ent = fm_trace_line(id,idorg,targetorg,touched)
						
						new class[32]
						pev(ent,pev_classname,class,31)
						
						if(ent>0&&ent==target)
						{
							if(fm_is_in_viewcone(id,touched,90.0))
							{
								if(ent<=g_maxplayer&&gteam[id]==gteam[ent]) continue;
								
								ckrun_takedamage(ent,id,65,CKRW_BOTTLE,CKRD_MELEE,critnum,1,0,0)
								
								
								
								num++
								hitbody=true
							}
						}
					}
				}else{
					ckrun_takedamage(ent,id,65,CKRW_BOTTLE,CKRD_MELEE,critnum,1,0,0)
					
					hitbody=true
				}
				if(hitbody)
				{
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_bottle_hit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
			}
			case human_spy:
			{
				ckrun_get_user_startpos(id,65.0,0.0,0.0,targetorg)
				new ent = fm_trace_line(id,idorg,targetorg,touched)
				
				if(ent==0)
				{
					while((target = engfunc(EngFunc_FindEntityInSphere,target,idorg,65.0))!=0)
					{
						if(num>0) continue;
						
						pev(target,pev_origin,targetorg)
						new ent = fm_trace_line(id,idorg,targetorg,touched)
						
						new class[32]
						pev(ent,pev_classname,class,31)
						
						if(ent>0&&ent==target)
						{
							if(fm_is_in_viewcone(id,touched,105.0))
							{
								if(equali(class,"player"))
								{
									if(g_gamemode == gamemode_arena && gteam[id]==gteam[ent] || g_gamemode == gamemode_zombie && giszm[id]==giszm[ent] || g_gamemode == gamemode_vsasb && ent != Boss) continue;
									
									if(is_back_face(id,ent,105.0)||must_critical[id])
									{
										if(critnum==2)
										{
											new Float:oldvec[3],Float:vec[3]
											pev(ent,pev_velocity,oldvec)
											get_speed_vector(idorg,touched,600.0,vec)
											oldvec[0]+=vec[0]
											oldvec[1]+=vec[1]
											oldvec[2]+=vec[2]
											set_pev(ent,pev_velocity,oldvec)
											
											if(Boss == ent)
											{
												ckrun_takedamage(ent,id,pev(ent,pev_health)/10,CKRW_BUTTERFLY,CKRD_MELEE,2,1,0,0)
												func_skill_angry(ent,Float:{2000.0,200.0,500.0},2.0,48.0)
												engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_vs_Boss_beicishengyin, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
												client_print(id,print_center,"你爆了BOSS的菊花")
												client_print(Boss,print_center,"有人爆了你的菊花")
											}
											else
											{
												ckrun_takedamage(ent,id,600,CKRW_BUTTERFLY,CKRD_MELEE,2,1,0,0)
											}
											
											func_disguise(id)
												
										}else{
											new Float:oldvec[3],Float:vec[3]
											pev(ent,pev_velocity,oldvec)
											get_speed_vector(idorg,touched,400.0,vec)
											oldvec[0]+=vec[0]
											oldvec[1]+=vec[1]
											oldvec[2]+=vec[2]
											set_pev(ent,pev_velocity,oldvec)
											
											if(Boss == ent)
											{
												ckrun_takedamage(ent,id,pev(ent,pev_health)/10,CKRW_BUTTERFLY,CKRD_MELEE,2,1,0,0)
												func_skill_angry(ent,Float:{2000.0,200.0,500.0},2.0,48.0)
												engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_vs_Boss_beicishengyin, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
												client_print(id,print_center,"你爆了BOSS的菊花")
												client_print(Boss,print_center,"有人爆了你的菊花")
											}
											else
											{
												ckrun_takedamage(ent,id,pev(ent,pev_health)*2,CKRW_BUTTERFLY,CKRD_MELEE,2,1,0,0)
											}
										}
									}else{
										ckrun_takedamage(ent,id,40,CKRW_BUTTERFLY,CKRD_MELEE,0,1,0,0)
									}
								}else{
									ckrun_takedamage(ent,id,40,CKRW_BUTTERFLY,CKRD_MELEE,2,1,0,0)
								}
								num++
								hitbody=true
							}
						}
					}
				}else{
					new class[32]
					pev(ent,pev_classname,class,31)
					
					if(equali(class,"player"))
					{
						if(g_gamemode == gamemode_arena && gteam[id]!=gteam[ent] || g_gamemode == gamemode_zombie && giszm[id]!=giszm[ent] || g_gamemode == gamemode_vsasb && ent == Boss)
						{
							if(is_back_face(id,ent,105.0)||must_critical[id])
							{
								if(critnum==2)
								{
									new Float:oldvec[3],Float:vec[3]
									pev(ent,pev_velocity,oldvec)
									get_speed_vector(idorg,touched,600.0,vec)
									oldvec[0]+=vec[0]
									oldvec[1]+=vec[1]
									oldvec[2]+=vec[2]
									set_pev(ent,pev_velocity,oldvec)
									
									if(Boss == ent)
									{
										ckrun_takedamage(ent,id,floatround(float(gmaxhealth[ent])*0.1),CKRW_BUTTERFLY,CKRD_MELEE,2,1,0,0)
										func_skill_angry(ent,Float:{2000.0,200.0,500.0},2.0,48.0)
										engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_vs_Boss_beicishengyin, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
										client_print(id,print_center,"你爆了BOSS的菊花")
										client_print(Boss,print_center,"有人爆了你的菊花")
									}
									else
									{
										ckrun_takedamage(ent,id,pev(ent,pev_health)*2,CKRW_BUTTERFLY,CKRD_MELEE,2,1,0,0)
									}
									func_disguise(id)
									
								}else{
									new Float:oldvec[3],Float:vec[3]
									pev(ent,pev_velocity,oldvec)
									get_speed_vector(idorg,touched,400.0,vec)
									oldvec[0]+=vec[0]
									oldvec[1]+=vec[1]
									oldvec[2]+=vec[2]
									set_pev(ent,pev_velocity,oldvec)
											
									if(Boss == ent)
									{
										ckrun_takedamage(ent,id,floatround(float(gmaxhealth[ent])*0.1),CKRW_BUTTERFLY,CKRD_MELEE,2,1,0,0)
										func_skill_angry(ent,Float:{2000.0,200.0,500.0},2.0,48.0)
										engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_vs_Boss_beicishengyin, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
										client_print(id,print_center,"你爆了BOSS的菊花")
										client_print(Boss,print_center,"有人爆了你的菊花")
									}
									else
									{
										ckrun_takedamage(ent,id,pev(ent,pev_health)*2,CKRW_BUTTERFLY,CKRD_MELEE,2,1,0,0)
									}
								}
							}else{
								ckrun_takedamage(ent,id,40,CKRW_BUTTERFLY,CKRD_MELEE,0,1,0,0)
							}
						}
					}else{
						ckrun_takedamage(ent,id,40,CKRW_BUTTERFLY,CKRD_MELEE,0,1,0,0)
					}
					
					hitbody=true
				}
				if(hitbody)
				{
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_butterfly_hit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
			}
		}
		
	}
	else if(zombie>0)
	{
		
		switch(zombie)
		{
			case zombie_scout:
			{
				ckrun_get_user_startpos(id,65.0,0.0,0.0,targetorg)
				new ent = fm_trace_line(id,idorg,targetorg,touched)
				
				if(ent==0)
				{
					while((target = engfunc(EngFunc_FindEntityInSphere,target,idorg,65.0))!=0)
					{
						if(num>0) continue;
						
						pev(target,pev_origin,targetorg)
						new ent = fm_trace_line(id,idorg,targetorg,touched)
						
						new class[32]
						pev(ent,pev_classname,class,31)
						
						
						if(ent>0&&ent==target)
						{
							
							if(fm_is_in_viewcone(id,touched,90.0))
							{
								ckrun_takedamage(ent,id,30,CKRW_PAW,CKRD_MELEE,critnum,1,0,0)
								
								num++
								hitbody=true
							}
						}
					}
				}else{
					ckrun_takedamage(ent,id,30,CKRW_PAW,CKRD_MELEE,critnum,1,0,0)
					hitbody=true
				}
				if(hitbody)
				{
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_zb_zombiehit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
			}
			case zombie_heavy:
			{
				ckrun_get_user_startpos(id,65.0,0.0,0.0,targetorg)
				new ent = fm_trace_line(id,idorg,targetorg,touched)
				
				if(ent==0)
				{
					while((target = engfunc(EngFunc_FindEntityInSphere,target,idorg,65.0))!=0)
					{
						if(num>0) continue;
						
						pev(target,pev_origin,targetorg)
						new ent = fm_trace_line(id,idorg,targetorg,touched)
						
						new class[32]
						pev(ent,pev_classname,class,31)
						
						
						if(ent>0&&ent==target)
						{
							
							if(fm_is_in_viewcone(id,touched,90.0))
							{
								ckrun_takedamage(ent,id,65,CKRW_PAW,CKRD_MELEE,critnum,1,0,0)
								
								num++
								hitbody=true
							}
						}
					}
				}else{
					ckrun_takedamage(ent,id,65,CKRW_PAW,CKRD_MELEE,critnum,1,0,0)
					hitbody=true
				}
				if(hitbody)
				{
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_zb_zombiehit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
			}		
			case zombie_soldier:
			{
				ckrun_get_user_startpos(id,65.0,0.0,0.0,targetorg)
				new ent = fm_trace_line(id,idorg,targetorg,touched)
				
				if(ent==0)
				{
					while((target = engfunc(EngFunc_FindEntityInSphere,target,idorg,65.0))!=0)
					{
						if(num>0) continue;
						
						pev(target,pev_origin,targetorg)
						new ent = fm_trace_line(id,idorg,targetorg,touched)
						
						new class[32]
						pev(ent,pev_classname,class,31)
						
						
						if(ent>0&&ent==target)
						{
							
							if(fm_is_in_viewcone(id,touched,90.0))
							{
								ckrun_takedamage(ent,id,65,CKRW_PAW,CKRD_MELEE,critnum,1,0,0)
								
								num++
								hitbody=true
							}
						}
					}
				}else{
					ckrun_takedamage(ent,id,65,CKRW_PAW,CKRD_MELEE,critnum,1,0,0)
					hitbody=true
				}
				if(hitbody)
				{
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_zb_zombiehit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
			}
			case zombie_pyro:
			{
				ckrun_get_user_startpos(id,65.0,0.0,0.0,targetorg)
				new ent = fm_trace_line(id,idorg,targetorg,touched)
				
				if(ent==0)
				{
					while((target = engfunc(EngFunc_FindEntityInSphere,target,idorg,65.0))!=0)
					{
						if(num>0) continue;
						
						pev(target,pev_origin,targetorg)
						new ent = fm_trace_line(id,idorg,targetorg,touched)
						
						new class[32]
						pev(ent,pev_classname,class,31)
						
						
						if(ent>0&&ent==target)
						{
							
							if(fm_is_in_viewcone(id,touched,90.0))
							{
								ckrun_takedamage(ent,id,65,CKRW_PAW,CKRD_MELEE,critnum,1,0,0)
								
								num++
								hitbody=true
							}
						}
					}
				}else{
					ckrun_takedamage(ent,id,65,CKRW_PAW,CKRD_MELEE,critnum,1,0,0)
					hitbody=true
				}
				if(hitbody)
				{
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_zb_zombiehit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
			}
			case zombie_sniper:
			{
				ckrun_get_user_startpos(id,65.0,0.0,0.0,targetorg)
				new ent = fm_trace_line(id,idorg,targetorg,touched)
				
				if(ent==0)
				{
					while((target = engfunc(EngFunc_FindEntityInSphere,target,idorg,65.0))!=0)
					{
						if(num>0) continue;
						
						pev(target,pev_origin,targetorg)
						new ent = fm_trace_line(id,idorg,targetorg,touched)
						
						new class[32]
						pev(ent,pev_classname,class,31)
						
						if(ent>0&&ent==target)
						{
							if(fm_is_in_viewcone(id,touched,90.0))
							{
								ckrun_takedamage(ent,id,65,CKRW_PAW,CKRD_MELEE,critnum,1,0,0)
								
								num++
								hitbody=true
							}
						}
					}
				}else{
					ckrun_takedamage(ent,id,65,CKRW_PAW,CKRD_MELEE,critnum,1,0,0)
					hitbody=true
				}
				if(hitbody)
				{
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_zb_zombiehit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
			}
			case zombie_medic:
			{
				ckrun_get_user_startpos(id,65.0,0.0,0.0,targetorg)
				new ent = fm_trace_line(id,idorg,targetorg,touched)
				
				if(ent==0)
				{
					while((target = engfunc(EngFunc_FindEntityInSphere,target,idorg,65.0))!=0)
					{
						if(num>0) continue;
						
						pev(target,pev_origin,targetorg)
						new ent = fm_trace_line(id,idorg,targetorg,touched)
						
						new class[32]
						pev(ent,pev_classname,class,31)
						
						if(ent>0&&ent==target)
						{
							if(fm_is_in_viewcone(id,touched,90.0))
							{
								ckrun_takedamage(ent,id,65,CKRW_BONESAW,CKRD_MELEE,critnum,1,0,0)
								
								num++
								hitbody=true
							}
						}
					}
				}else{
					ckrun_takedamage(ent,id,65,CKRW_BONESAW,CKRD_MELEE,critnum,1,0,0)
					hitbody=true
				}
				if(hitbody)
				{
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_zb_zombiehit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
			}
			case zombie_engineer:
			{
				ckrun_get_user_startpos(id,65.0,0.0,0.0,targetorg)
				new ent = fm_trace_line(id,idorg,targetorg,touched)
				
				if(ent==0)
				{
					while((target = engfunc(EngFunc_FindEntityInSphere,target,idorg,65.0))!=0)
					{
						if(num>0) continue;
						
						pev(target,pev_origin,targetorg)
						new ent = fm_trace_line(id,idorg,targetorg,touched)
						
						new class[32]
						pev(ent,pev_classname,class,31)
						
						if(ent>0&&ent==target)
						{
							if(fm_is_in_viewcone(id,touched,90.0))
							{
								ckrun_takedamage(ent,id,65,CKRW_PAW,CKRD_MELEE,critnum,1,0,0)
								num++
								hitbody=true
								
							}
						}
					}
				}else{
					ckrun_takedamage(ent,id,65,CKRW_PAW,CKRD_MELEE,critnum,1,0,0)
					num++
					hitbody=true
					
					
					hitbody=true
				}
				if(hitbody)
				{
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_zb_zombiehit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
			}
			case zombie_demoman:
			{
				ckrun_get_user_startpos(id,65.0,0.0,0.0,targetorg)
				new ent = fm_trace_line(id,idorg,targetorg,touched)
				
				if(ent==0)
				{
					while((target = engfunc(EngFunc_FindEntityInSphere,target,idorg,65.0))!=0)
					{
						if(num>0) continue;
						
						pev(target,pev_origin,targetorg)
						new ent = fm_trace_line(id,idorg,targetorg,touched)
						
						new class[32]
						pev(ent,pev_classname,class,31)
						
						if(ent>0&&ent==target)
						{
							if(fm_is_in_viewcone(id,touched,90.0))
							{
								ckrun_takedamage(ent,id,65,CKRW_PAW,CKRD_MELEE,critnum,1,0,0)
								
								num++
								hitbody=true
							}
						}
					}
				}else{
					ckrun_takedamage(ent,id,65,CKRW_PAW,CKRD_MELEE,critnum,1,0,0)
					
					hitbody=true
				}
				if(hitbody)
				{
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON,snd_zb_zombiehit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
			}
			case zombie_spy:
			{
				ckrun_get_user_startpos(id,65.0,0.0,0.0,targetorg)
				new ent = fm_trace_line(id,idorg,targetorg,touched)
				
				if(ent==0)
				{
					while((target = engfunc(EngFunc_FindEntityInSphere,target,idorg,65.0))!=0)
					{
						if(num>0) continue;
						
						pev(target,pev_origin,targetorg)
						new ent = fm_trace_line(id,idorg,targetorg,touched)
						
						new class[32]
						pev(ent,pev_classname,class,31)
						
						if(ent>0&&ent==target)
						{
							if(fm_is_in_viewcone(id,touched,90.0))
							{
								if(equali(class,"player"))
								{
									if(giszm[ent]) continue;
									
									if(is_back_face(id,ent,105.0)||must_critical[id])
									{
										if(critnum==2)
										{
											new Float:oldvec[3],Float:vec[3]
											pev(ent,pev_velocity,oldvec)
											get_speed_vector(idorg,touched,600.0,vec)
											oldvec[0]+=vec[0]
											oldvec[1]+=vec[1]
											oldvec[2]+=vec[2]
											set_pev(ent,pev_velocity,oldvec)
											
											ckrun_takedamage(ent,id,pev(ent,pev_health)*2,CKRW_PAW,CKRD_MELEE,2,1,0,0)
										}else{
											new Float:oldvec[3],Float:vec[3]
											pev(ent,pev_velocity,oldvec)
											get_speed_vector(idorg,touched,400.0,vec)
											oldvec[0]+=vec[0]
											oldvec[1]+=vec[1]
											oldvec[2]+=vec[2]
											set_pev(ent,pev_velocity,oldvec)
											
											ckrun_takedamage(ent,id,floatround(pev(ent,pev_health)/3.0+1.0),CKRW_PAW,CKRD_MELEE,2,1,0,0)
										}
									}else{
										ckrun_takedamage(ent,id,40,CKRW_PAW,CKRD_MELEE,0,1,0,0)
									}
								}else{
									ckrun_takedamage(ent,id,40,CKRW_PAW,CKRD_MELEE,2,1,0,0)
								}
								num++
								hitbody=true
							}
						}
					}
				}else{
					new class[32]
					pev(ent,pev_classname,class,31)
					
					if(equali(class,"player"))
					{
						if(!giszm[ent])
						{
							if(is_back_face(id,ent,105.0)||must_critical[id])
							{
								if(critnum==2)
								{
									new Float:oldvec[3],Float:vec[3]
									pev(ent,pev_velocity,oldvec)
									get_speed_vector(idorg,touched,600.0,vec)
									oldvec[0]+=vec[0]
									oldvec[1]+=vec[1]
									oldvec[2]+=vec[2]
									set_pev(ent,pev_velocity,oldvec)
									
									ckrun_takedamage(ent,id,pev(ent,pev_health)*2,CKRW_PAW,CKRD_MELEE,2,1,0,0)
								}else{
									new Float:oldvec[3],Float:vec[3]
									pev(ent,pev_velocity,oldvec)
									get_speed_vector(idorg,touched,400.0,vec)
									oldvec[0]+=vec[0]
									oldvec[1]+=vec[1]
									oldvec[2]+=vec[2]
									set_pev(ent,pev_velocity,oldvec)
											
									ckrun_takedamage(ent,id,floatround(pev(ent,pev_health)/3.0+1.0),CKRW_PAW,CKRD_MELEE,2,1,0,0)
								}
							}else{
								ckrun_takedamage(ent,id,40,CKRW_PAW,CKRD_MELEE,0,1,0,0)
							}
						}
					}else{
						ckrun_takedamage(ent,id,40,CKRW_PAW,CKRD_MELEE,0,1,0,0)
					}
					
					hitbody=true
				}
				if(hitbody)
				{
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_zb_zombiehit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
			}
		}
		
	}
	else if(bosstype>0)
	{
		switch(bosstype)
		{
			case boss_cbs:
			{
				ckrun_get_user_startpos(id,75.0,0.0,0.0,targetorg)
				new ent = fm_trace_line(id,idorg,targetorg,touched)
				
				if(ent==0)
				{
					while((target = engfunc(EngFunc_FindEntityInSphere,target,idorg,75.0))!=0)
					{
						if(num>0) continue;
						
						pev(target,pev_origin,targetorg)
						new ent = fm_trace_line(id,idorg,targetorg,touched)
						
						new class[32]
						pev(ent,pev_classname,class,31)
						
						if(ent>0&&ent==target)
						{
							if(fm_is_in_viewcone(id,touched,90.0))
							{
								switch(Boss_changeknife)
								{
									case 0:
									{
										ckrun_takedamage(ent,id,65,CKRW_HUNTINGKNIFE,CKRD_MELEE,critnum,1,0,0)
									}
									case 1:
									{
										ckrun_takedamage(ent,id,65,CKRW_CROC,CKRD_MELEE,critnum,1,0,0)
									}
									case 2:
									{
										ckrun_takedamage(ent,id,65,CKRW_WOOD,CKRD_MELEE,critnum,1,0,0)
									}
								}
								
								num++
								hitbody=true
							}
						}
					}
				}else{
					switch(Boss_changeknife)
					{
						case 0:
						{
							ckrun_takedamage(ent,id,65,CKRW_HUNTINGKNIFE,CKRD_MELEE,critnum,1,0,0)
						}
						case 1:
						{
							ckrun_takedamage(ent,id,65,CKRW_CROC,CKRD_MELEE,critnum,1,0,0)
						}
						case 2:
						{
							ckrun_takedamage(ent,id,65,CKRW_WOOD,CKRD_MELEE,critnum,1,0,0)
						}
					}
					
					hitbody=true
				}
				if(hitbody)
				{
					if(0<ent<=g_maxplayer)
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON,snd_vs_CBS_hitbody, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					else
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON,snd_vs_CBS_hitworld, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
			}
			case boss_scp173:
			{
				ckrun_get_user_startpos(id,65.0,0.0,0.0,targetorg)
				new ent = fm_trace_line(id,idorg,targetorg,touched)
				
				if(ent==0)
				{
					while((target = engfunc(EngFunc_FindEntityInSphere,target,idorg,65.0))!=0)
					{
						if(num>0) continue;
						
						pev(target,pev_origin,targetorg)
						new ent = fm_trace_line(id,idorg,targetorg,touched)
						
						new class[32]
						pev(ent,pev_classname,class,31)
						
						if(ent>0&&ent==target)
						{
							if(fm_is_in_viewcone(id,touched,90.0))
							{
								ckrun_takedamage(ent,id,65,CKRW_PAW,CKRD_MELEE,critnum,1,0,0)
								
								num++
								hitbody=true
							}
						}
					}
				}else{
					ckrun_takedamage(ent,id,65,CKRW_PAW,CKRD_MELEE,critnum,1,0,0)
					
					hitbody=true
				}
				if(hitbody)
				{
					if(0<ent<=g_maxplayer)
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON,snd_vs_SCP173_hitbody, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					else
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON,snd_vs_SCP173_hitworld, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
			}
			case boss_creeper:
			{
				ckrun_get_user_startpos(id,75.0,0.0,0.0,targetorg)
				new ent = fm_trace_line(id,idorg,targetorg,touched)
				
				if(ent==0)
				{
					while((target = engfunc(EngFunc_FindEntityInSphere,target,idorg,75.0))!=0)
					{
						if(num>0) continue;
						
						pev(target,pev_origin,targetorg)
						new ent = fm_trace_line(id,idorg,targetorg,touched)
						
						new class[32]
						pev(ent,pev_classname,class,31)
						
						if(ent>0&&ent==target)
						{
							if(fm_is_in_viewcone(id,touched,90.0))
							{
								ckrun_takedamage(ent,id,65,CKRW_FIST,CKRD_MELEE,critnum,1,0,0)
								
								num++
								hitbody=true
							}
						}
					}
				}else{
					ckrun_takedamage(ent,id,65,CKRW_FIST,CKRD_MELEE,critnum,1,0,0)
					
					hitbody=true
				}
				if(hitbody)
				{
					/*if(0<ent<=g_maxplayer)
						//engfunc(EngFunc_EmitSound,id, CHAN_WEAPON,snd_vs_, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					else
						//engfunc(EngFunc_EmitSound,id, CHAN_WEAPON,snd_vs_, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				*/}
			}
			case boss_guardian:
			{
				ckrun_get_user_startpos(id,65.0,0.0,0.0,targetorg)
				new ent = fm_trace_line(id,idorg,targetorg,touched)
				
				if(ent==0)
				{
					while((target = engfunc(EngFunc_FindEntityInSphere,target,idorg,65.0))!=0)
					{
						if(num>0) continue;
						
						pev(target,pev_origin,targetorg)
						new ent = fm_trace_line(id,idorg,targetorg,touched)
						
						new class[32]
						pev(ent,pev_classname,class,31)
						
						if(ent>0&&ent==target)
						{
							if(fm_is_in_viewcone(id,touched,180.0))
							{
								ckrun_takedamage(ent,id,65,CKRW_FIST,CKRD_MELEE,critnum,1,0,0)
								
								num++
								hitbody=true
							}
						}
					}
				}else{
					ckrun_takedamage(ent,id,65,CKRW_FIST,CKRD_MELEE,critnum,1,0,0)
					
					hitbody=true
				}
			}
		}
	}
	
	
	new Float:forwardorg[3],Float:distance
	
	if(!hitbody)
	{
		
		ckrun_get_user_startpos(id,9999.0,0.0,0.0,forwardorg)
		new ent = fm_trace_line(id,idorg,forwardorg,touched)
		
		if(human>0)
		{
			switch(human)
			{
				case human_scout:
				{
					distance = get_distance_f(idorg,touched)
					if(distance <= 65.0)
					{
						
						hitbody=true
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_bat_hit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
				}
				case human_heavy:
				{
					distance = get_distance_f(idorg,touched)
					if(distance <= 65.0)
					{
						
						hitbody=true
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_fist_hitbody, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
				}
				case human_soldier:
				{
					distance = get_distance_f(idorg,touched)
					if(distance <= 65.0)
					{
						
						hitbody=true
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_shovel_hit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
				}
				case human_pyro:
				{
					distance = get_distance_f(idorg,touched)
					if(distance <= 65.0)
					{
						
						hitbody=true
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_fireaxe_hitbody, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
				}
				case human_sniper:
				{
					distance = get_distance_f(idorg,touched)
					if(distance <= 65.0)
					{
						
						hitbody=true
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_machete_hit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
				}
				case human_medic:
				{
					distance = get_distance_f(idorg,touched)
					if(distance <= 65.0)
					{
						
						hitbody=true
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_bonesaw_hit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
				}
				case human_engineer:
				{
					distance = get_distance_f(idorg,touched)
					if(distance <= 65.0)
					{
						
						hitbody=true
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_wrench_hitworld, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
				}
				case human_demoman:
				{
					distance = get_distance_f(idorg,touched)
					if(distance <= 65.0)
					{
						
						hitbody=true
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_bottle_hit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
				}
				case human_spy:
				{
					distance = get_distance_f(idorg,touched)
					if(distance <= 65.0)
					{
						hitbody=true
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_butterfly_hit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
				}
			}
		}
		else if(zombie>0)
		{
			switch(zombie)
			{
				case zombie_scout:
				{
					distance = get_distance_f(idorg,touched)
					if(distance <= 65.0)
					{
						
						hitbody=true
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_zb_zombiehit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
				}
				case zombie_heavy:
				{
					distance = get_distance_f(idorg,touched)
					if(distance <= 65.0)
					{
						
						hitbody=true
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_zb_zombiehit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
				}
				case zombie_soldier:
				{
					distance = get_distance_f(idorg,touched)
					if(distance <= 65.0)
					{
						
						hitbody=true
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_zb_zombiehit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
				}
				case zombie_pyro:
				{
					distance = get_distance_f(idorg,touched)
					if(distance <= 65.0)
					{
						
						hitbody=true
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON,snd_zb_zombiehit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
				}
				case zombie_sniper:
				{
					distance = get_distance_f(idorg,touched)
					if(distance <= 65.0)
					{
						
						hitbody=true
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_zb_zombiehit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
				}
				case zombie_medic:
				{
					distance = get_distance_f(idorg,touched)
					if(distance <= 65.0)
					{
						
						hitbody=true
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_zb_zombiehit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
				}
				case zombie_engineer:
				{
					distance = get_distance_f(idorg,touched)
					if(distance <= 65.0)
					{
						
						hitbody=true
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_zb_zombiehit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
				}
				case zombie_demoman:
				{
					distance = get_distance_f(idorg,touched)
					if(distance <= 65.0)
					{
						
						hitbody=true
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_zb_zombiehit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
				}
				case zombie_spy:
				{
					distance = get_distance_f(idorg,touched)
					if(distance <= 65.0)
					{
						hitbody=true
						engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_zb_zombiehit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
				}
			}
		}
		else if(bosstype>0)
		{
			switch(gboss[id])
			{
				case boss_cbs:
				{
					distance = get_distance_f(idorg,touched)
					if(distance <= 75.0)
					{
						hitbody=true
						if(0<ent<=g_maxplayer)
							engfunc(EngFunc_EmitSound,id, CHAN_WEAPON,snd_vs_CBS_hitbody, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						else
							engfunc(EngFunc_EmitSound,id, CHAN_WEAPON,snd_vs_CBS_hitworld, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
				}
				case boss_scp173:
				{
					distance = get_distance_f(idorg,touched)
					if(distance <= 65.0)
					{
						hitbody=true
						if(0<ent<=g_maxplayer)
							engfunc(EngFunc_EmitSound,id, CHAN_WEAPON,snd_vs_SCP173_hitbody, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						else
							engfunc(EngFunc_EmitSound,id, CHAN_WEAPON,snd_vs_SCP173_hitworld, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
				}
				case boss_creeper:
				{
					distance = get_distance_f(idorg,touched)
					if(distance <= 75.0)
					{
						hitbody=true
						if(0<ent<=g_maxplayer)
							engfunc(EngFunc_EmitSound,id, CHAN_WEAPON,snd_vs_SCP173_hitbody, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						else
							engfunc(EngFunc_EmitSound,id, CHAN_WEAPON,snd_vs_SCP173_hitworld, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
				}
				case boss_guardian:
				{
					distance = get_distance_f(idorg,touched)
					if(distance <= 65.0)
					{
						hitbody=true
						if(0<ent<=g_maxplayer)
							engfunc(EngFunc_EmitSound,id, CHAN_WEAPON,snd_vs_SCP173_hitbody, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						else
							engfunc(EngFunc_EmitSound,id, CHAN_WEAPON,snd_vs_SCP173_hitworld, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
				}
			}
		}
		
	}
	
	//if(hitbody)
	//		func_papapa(0,id,0,0,touched,128.0,65.0,88.0,0.35,400.0,CKRW_RPG,critnum,1)
	
	knifeattacking[id]=false
		
}


public sniperifle_reload(taskid)
{
	static id
	if(taskid>g_maxplayer)
		id=taskid-TASK_SNIPERRELOAD
	else
		id=taskid
		
	engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_wpn_sniperifle_reload,VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	fm_set_user_zoom(id,CS_NO_ZOOM)
	set_fov(id,90)
	sniperifle_power[id]=0
	set_msg_armor(id,get_user_armor(id))
	NextCould_CurWeapon_Time[id]=get_gametime()
	
	Speedmul_switch[id]=false
	Speedmul_value_percent[id]=100
}
public func_AnimNextFrame(ent)
{
	if(pev_valid(ent))
	{
		set_pev(ent,pev_frame,pev(ent,pev_frame)+1.0)
		set_task(0.1,"func_AnimNextFrame",ent)
	}
}
public remove(ent)
{
	if(pev_valid(ent) && pev(ent,pev_temp)==1)
	{
		engfunc(EngFunc_RemoveEntity,ent)
	}
}
public Ham_WeaponCured(ent,id)
{
	if(!pev_valid(ent)) return;
	id = pev(ent,pev_owner)
	if(!pev_valid(id)) return;
	new Float:nowtime = get_gametime()
	
	new classname[32]
	pev(ent,pev_classname,classname,31)
	
	ckrun_update_user_clip_ammo(id)

	if(infire[id])
	{
		engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_empty, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		infire[id]=false
	}
	
	
	
	if(equali(classname,"weapon_m3") || equali(classname,"weapon_mp5navy"))
	{
		ExecuteForward(g_fwWeaponCur_Pre,g_fwResult,id,ent,g_wpnitem_pri[id][ghuman[id]])
		
		player_weaponid_last[id]=player_weaponid_now[id]
		player_weaponid_now[id]=g_wpnitem_pri[id][ghuman[id]]
		if(g_wpnitem_pri[id][ghuman[id]]==-1)
		{
			format(player_weaponclassname_chi[id],31,"%s",human_normal_priwpnname[ghuman[id]])
			format(player_weaponclassname_eng[id],31,"%s",human_normal_priwpnengname[ghuman[id]])
		}else{
			ArrayGetString(item_chinese_name,player_weaponid_now[id],player_weaponclassname_chi[id],31)
			ArrayGetString(item_english_name,player_weaponid_now[id],player_weaponclassname_eng[id],31)
		}
		PlaySequence(id,PLAYER_IDLE)
		
		if(g_wpnitem_pri[id][ghuman[id]]!=-1)
		{
			ExecuteForward(g_fwWeaponCur_Post,g_fwResult,id,ent,g_wpnitem_pri[id][ghuman[id]])
			return;
		}
		
		set_pdata_float(ent,46,9999.0)
		set_pdata_float(ent,47,9999.0)
		set_pdata_float(ent,48,9999.0,4)
		
		engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_weapondraw, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		
		
		switch(ghuman[id])
		{
			case human_scout:
			{
				set_pev(id,pev_viewmodel2,mdl_wpn_v_scattergun)
				set_pev(id,pev_weaponmodel2,mdl_wpn_wp_scattergun)
				//set_pev(ent,pev_body,0)
				set_pev(id,pev_weaponanim,anim_shotgundraw)
				
				player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_scattergun_curtime)
			}
			case human_heavy:
			{
				set_pev(id,pev_viewmodel2,mdl_wpn_v_minigun)
				set_pev(id,pev_weaponmodel2,mdl_wpn_wp_minigun)
				//set_pev(id,pev_weaponmodel2,mdl_wpn_w_p)
				//set_pev(ent,pev_body,53)
				set_pev(id,pev_weaponanim,anim_minidraw)
				
				player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_minigun_curtime)
			}
			case human_soldier:
			{
				set_pev(id,pev_viewmodel2,mdl_wpn_v_rpg)
				set_pev(id,pev_weaponmodel2,mdl_wpn_wp_rpg)
				//set_pev(id,pev_weaponmodel2,mdl_wpn_w_p)
				//set_pev(ent,pev_body,11)
				set_pev(id,pev_weaponanim,anim_rpgdraw)
				
				player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_rpg_curtime)
			}
			case human_pyro:
			{
				set_pev(id,pev_viewmodel2,mdl_wpn_v_flamethrower)
				set_pev(id,pev_weaponmodel2,mdl_wpn_wp_flamethrower)
				//set_pev(id,pev_weaponmodel2,mdl_wpn_w_p)
				//set_pev(ent,pev_body,21)
				set_pev(id,pev_weaponanim,anim_flamedraw)
				
				player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_firegun_curtime)
			}
			case human_sniper:
			{
				set_pev(id,pev_viewmodel2,mdl_wpn_v_sniperifle)
				set_pev(id,pev_weaponmodel2,mdl_wpn_wp_sniperifle)
				//set_pev(id,pev_weaponmodel2,mdl_wpn_w_p)
				//set_pev(ent,pev_body,35)
				set_pev(id,pev_weaponanim,anim_snipedraw)
				
				player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_sniperifle_curtime)
			}
			case human_medic:
			{
				//if(get_user_team(id)==team_red) set_pev(id,pev_viewmodel2,mdl_wpn_v_medicgun_red)
				//else if(get_user_team(id)==team_blue) set_pev(id,pev_viewmodel2,mdl_wpn_v_medicgun_blue)
				//else
				set_pev(id,pev_viewmodel2,mdl_wpn_v_medicgun)
				set_pev(id,pev_weaponmodel2,mdl_wpn_wp_medicgun)
				set_pev(id,pev_weaponanim,anim_medicdraw)
				
				player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_medicgun_curtime)
			}
			case human_engineer:
			{
				set_pev(id,pev_viewmodel2,mdl_wpn_v_shotgunengineer)
				set_pev(id,pev_weaponmodel2,mdl_wpn_wp_shotgunall)
				//set_pev(id,pev_weaponmodel2,mdl_wpn_w_p)
				//set_pev(ent,pev_body,12)
				set_pev(id,pev_weaponanim,anim_shotgundraw)
				
				player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_shotgun_curtime)
			}
			case human_demoman:
			{
				set_pev(id,pev_viewmodel2,mdl_wpn_v_grenadelauncher)
				set_pev(id,pev_weaponmodel2,mdl_wpn_wp_grenadelauncher)
				//set_pev(id,pev_weaponmodel2,mdl_wpn_w_p)
				//set_pev(ent,pev_body,14)
				set_pev(id,pev_weaponanim,anim_grenadedraw)
				
				player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_grenadelaunch_curtime)
			}
			case human_spy:
			{
				if(invisible_ing[id]||invisible_ed[id])
				{
					set_pev(id,pev_viewmodel2,mdl_wpn_v_revolver_watch)
				}else{
					set_pev(id,pev_viewmodel2,mdl_wpn_v_revolver)
				}
				set_pev(id,pev_weaponmodel2,mdl_wpn_wp_revolver)
				set_pev(id,pev_weaponanim,anim_revolverdraw)
				
				player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_revolver_curtime)
			}
			case human_assassin:
			{
				set_pev(id,pev_viewmodel2,mdl_wpn_v_assm3)
				set_pev(id,pev_weaponmodel2,mdl_wpn_p_assm3)
				
				set_pev(id,pev_weaponanim,anim_assm3draw)
						
				player_curweapontime[id]=nowtime+0.93
			}
		}
		
		if(disguise[id])
		{
			switch(disguise_type[id])
			{
				case human_scout:
				{
					set_pev(id,pev_weaponmodel2,mdl_wpn_wp_scattergun)
				}
				case human_heavy:
				{
					set_pev(id,pev_weaponmodel2,mdl_wpn_wp_minigun)
				}
				case human_soldier:
				{
					set_pev(id,pev_weaponmodel2,mdl_wpn_wp_rpg)
				}
				case human_pyro:
				{
					set_pev(id,pev_weaponmodel2,mdl_wpn_wp_flamethrower)
				}
				case human_sniper:
				{
					set_pev(id,pev_weaponmodel2,mdl_wpn_wp_sniperifle)
				}
				case human_medic:
				{
					set_pev(id,pev_weaponmodel2,mdl_wpn_wp_medicgun)
				}
				case human_engineer:
				{
					set_pev(id,pev_weaponmodel2,mdl_wpn_wp_shotgunall)
				}
				case human_demoman:
				{
					set_pev(id,pev_weaponmodel2,mdl_wpn_wp_grenadelauncher)
				}
				case human_spy:
				{
					set_pev(id,pev_weaponmodel2,mdl_wpn_wp_revolver)
				}
			}
		}
		
		
	}
	else if(equali(classname,"weapon_p228") || equali(classname,"weapon_deagle"))
	{
		ExecuteForward(g_fwWeaponCur_Pre,g_fwResult,id,ent,g_wpnitem_sec[id][ghuman[id]])
		
		player_weaponid_last[id]=player_weaponid_now[id]
		player_weaponid_now[id]=g_wpnitem_sec[id][ghuman[id]]
		if(g_wpnitem_sec[id][ghuman[id]]==-1)
		{
			format(player_weaponclassname_chi[id],31,"%s",human_normal_secwpnname[ghuman[id]])
			format(player_weaponclassname_eng[id],31,"%s",human_normal_secwpnengname[ghuman[id]])
		}else{
			ArrayGetString(item_chinese_name,player_weaponid_now[id],player_weaponclassname_chi[id],31)
			ArrayGetString(item_english_name,player_weaponid_now[id],player_weaponclassname_eng[id],31)
		}
		PlaySequence(id,PLAYER_IDLE)
		
		if(g_wpnitem_sec[id][ghuman[id]]!=-1)
		{
			ExecuteForward(g_fwWeaponCur_Post,g_fwResult,id,ent,g_wpnitem_sec[id][ghuman[id]])
			return;
		}
		set_pdata_float(ent,46,9999.0)
		set_pdata_float(ent,47,9999.0)
		set_pdata_float(ent,48,9999.0,4)
		
		engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_weapondraw, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		
		if(!giszm[id])
		{
			switch(ghuman[id])
			{
				case human_scout:
				{
					set_pev(id,pev_viewmodel2,mdl_wpn_v_pistol)
					set_pev(id,pev_weaponmodel2,mdl_wpn_wp_pistol)
					//set_pev(id,pev_weaponmodel2,mdl_wpn_w_p)
					//set_pev(ent,pev_body,2)
					set_pev(id,pev_weaponanim,anim_pistoldraw)
					
					player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_pistol_curtime)
				}
				case human_heavy:
				{
					set_pev(id,pev_viewmodel2,mdl_wpn_v_shotgunheavy)
					set_pev(id,pev_weaponmodel2,mdl_wpn_wp_shotgunall)
					//set_pev(id,pev_weaponmodel2,mdl_wpn_w_p)
					//set_pev(ent,pev_body,12)
					set_pev(id,pev_weaponanim,anim_shotgundraw)
					
					player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_shotgun_curtime)
				}
				case human_soldier:
				{
					set_pev(id,pev_viewmodel2,mdl_wpn_v_shotgunsoldier)
					set_pev(id,pev_weaponmodel2,mdl_wpn_wp_shotgunall)
					//set_pev(id,pev_weaponmodel2,mdl_wpn_w_p)
					//set_pev(ent,pev_body,12)
					set_pev(id,pev_weaponanim,anim_shotgundraw)
					
					player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_shotgun_curtime)
				}
				case human_pyro:
				{
					set_pev(id,pev_viewmodel2,mdl_wpn_v_shotgunpyro)
					set_pev(id,pev_weaponmodel2,mdl_wpn_wp_shotgunall)
					//set_pev(id,pev_weaponmodel2,mdl_wpn_w_p)
					//set_pev(ent,pev_body,12)
					set_pev(id,pev_weaponanim,anim_shotgundraw)
					
					player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_shotgun_curtime)
				}
				case human_sniper:
				{
					set_pev(id,pev_viewmodel2,mdl_wpn_v_smg)
					set_pev(id,pev_weaponmodel2,mdl_wpn_wp_smg)
					//set_pev(id,pev_weaponmodel2,mdl_wpn_w_p)
					//set_pev(ent,pev_body,34)
					set_pev(id,pev_weaponanim,anim_smgdraw)
					
					player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_smg_curtime)
				}
				case human_medic:
				{
					set_pev(id,pev_viewmodel2,mdl_wpn_v_syringegun)
					set_pev(id,pev_weaponmodel2,mdl_wpn_wp_syringegun)
					set_pev(id,pev_weaponanim,anim_syringedraw)
					
					player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_syringegun_curtime)
				}
				case human_engineer:
				{
					set_pev(id,pev_viewmodel2,mdl_wpn_v_pistol_engineer)
					set_pev(id,pev_weaponmodel2,mdl_wpn_wp_pistol)
					//set_pev(id,pev_weaponmodel2,mdl_wpn_w_p)
					//set_pev(ent,pev_body,2)
					set_pev(id,pev_weaponanim,anim_pistoldraw)
					
					player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_pistol_curtime)
				}
				case human_demoman:
				{
					set_pev(id,pev_viewmodel2,mdl_wpn_v_stickylauncher)
					set_pev(id,pev_weaponmodel2,mdl_wpn_wp_stickylauncher)
					//set_pev(id,pev_weaponmodel2,mdl_wpn_w_p)
					//set_pev(ent,pev_body,16)
					set_pev(id,pev_weaponanim,anim_stickydraw)
					
					player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_stickylauncher_curtime)
				}
				case human_spy:
				{
					if(invisible_ing[id]||invisible_ed[id])
					{
						set_pev(id,pev_viewmodel2,mdl_wpn_v_sapper_watch)
					}else{
						set_pev(id,pev_viewmodel2,mdl_wpn_v_sapper)
					}
					set_pev(id,pev_weaponmodel2,mdl_wpn_wp_sapper)
					set_pev(id,pev_weaponanim,anim_sapperdraw)
					
					player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_sapper_curtime)
				}
				case human_assassin:
				{
					set_pev(id,pev_viewmodel2,mdl_wpn_v_assdeagle)
					set_pev(id,pev_weaponmodel2,mdl_wpn_p_assdeagle)
					//set_pev(id,pev_weaponmodel2,mdl_wpn_w_p)
					//set_pev(ent,pev_body,34)
					set_pev(id,pev_weaponanim,anim_assdeagledraw)
						
					player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_assdeagle_curtime)
				}
				
			}
			
			if(disguise[id])
			{
				switch(disguise_iszm[id])
				{
					case false:
					{
						switch(disguise_type[id])
						{
							case human_scout:
							{
								set_pev(id,pev_weaponmodel2,mdl_wpn_wp_pistol)
							}
							case human_heavy:
							{
								set_pev(id,pev_weaponmodel2,mdl_wpn_wp_shotgunall)
							}
							case human_soldier:
							{
								set_pev(id,pev_weaponmodel2,mdl_wpn_wp_shotgunall)
							}
							case human_pyro:
							{
								set_pev(id,pev_weaponmodel2,mdl_wpn_wp_shotgunall)
							}
							case human_sniper:
							{
								set_pev(id,pev_weaponmodel2,mdl_wpn_wp_smg)
							}
							case human_medic:
							{
								set_pev(id,pev_weaponmodel2,mdl_wpn_wp_syringegun)
							}
							case human_engineer:
							{
								set_pev(id,pev_weaponmodel2,mdl_wpn_wp_pistol)
							}
							case human_demoman:
							{
								set_pev(id,pev_weaponmodel2,mdl_wpn_wp_stickylauncher)
							}
							case human_spy:
							{
								set_pev(id,pev_weaponmodel2,mdl_wpn_wp_sapper)
							}
							
						}
					}
					case true:
					{
						set_pev(id,pev_weaponmodel2,0)
					}
				}
			}
			
		}else{
			switch(gzombie[id])
			{
				case zombie_spy:
				{
					if(invisible_ing[id]||invisible_ed[id])
					{
						set_pev(id,pev_viewmodel2,mdl_wpn_spyzombiesapperhide)
					}else{
						set_pev(id,pev_viewmodel2,mdl_wpn_spyzombiesapper)
					}
					set_pev(id,pev_weaponmodel2,mdl_wpn_wp_sapper)
					set_pev(id,pev_weaponanim,anim_sapperdraw)
					
					player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_sapper_curtime)
				}
			}
			
			if(disguise[id])
			{
				switch(disguise_iszm[id])
				{
					case false:
					{
						switch(disguise_type[id])
						{
							case human_scout:
							{
								set_pev(id,pev_weaponmodel2,mdl_wpn_wp_pistol)
							}
							case human_heavy:
							{
								set_pev(id,pev_weaponmodel2,mdl_wpn_wp_shotgunall)
							}
							case human_soldier:
							{
								set_pev(id,pev_weaponmodel2,mdl_wpn_wp_shotgunall)
							}
							case human_pyro:
							{
								set_pev(id,pev_weaponmodel2,mdl_wpn_wp_shotgunall)
							}
							case human_sniper:
							{
								set_pev(id,pev_weaponmodel2,mdl_wpn_wp_smg)
							}
							case human_medic:
							{
								set_pev(id,pev_weaponmodel2,mdl_wpn_wp_syringegun)
							}
							case human_engineer:
							{
								set_pev(id,pev_weaponmodel2,mdl_wpn_wp_pistol)
							}
							case human_demoman:
							{
								set_pev(id,pev_weaponmodel2,mdl_wpn_wp_stickylauncher)
							}
							case human_spy:
							{
								set_pev(id,pev_weaponmodel2,mdl_wpn_wp_sapper)
							}
							
						}
					}
					case true:
					{
						switch(disguise_type[id])
						{
							case zombie_spy:
							{
								set_pev(id,pev_weaponmodel2,mdl_wpn_wp_sapper)
							}
							default:
							{
								set_pev(id,pev_weaponmodel2,0)
							}
						}
					}
				}
			}
		}
		
		
	}
	else if(equali(classname,"weapon_knife"))
	{
		ExecuteForward(g_fwWeaponCur_Pre,g_fwResult,id,ent,g_wpnitem_knife[id][ghuman[id]])
		
		player_weaponid_last[id]=player_weaponid_now[id]
		player_weaponid_now[id]=g_wpnitem_knife[id][ghuman[id]]
		
		PlaySequence(id,PLAYER_IDLE)
		
		if(g_wpnitem_knife[id][ghuman[id]]!=-1)
		{
			ExecuteForward(g_fwWeaponCur_Post,g_fwResult,id,ent,g_wpnitem_knife[id][ghuman[id]])
			return;
		}
		
		set_pdata_float(ent,46,9999.0)
		set_pdata_float(ent,47,9999.0)
		set_pdata_float(ent,48,999.0,4)
		
		if(Boss != id)
		{
			if(!giszm[id])
			{
				if(g_wpnitem_knife[id][ghuman[id]]==-1)
				{
					format(player_weaponclassname_chi[id],31,"%s",human_normal_knifewpnname[ghuman[id]])
					format(player_weaponclassname_eng[id],31,"%s",human_normal_knifewpnengname[ghuman[id]])
				}else{
					ArrayGetString(item_chinese_name,player_weaponid_now[id],player_weaponclassname_chi[id],31)
					ArrayGetString(item_english_name,player_weaponid_now[id],player_weaponclassname_eng[id],31)
				}
				
				switch(ghuman[id])
				{
					case human_scout:
					{
						set_pev(id,pev_viewmodel2,mdl_wpn_v_bat)
						set_pev(id,pev_weaponmodel2,mdl_wpn_wp_bat)
						//set_pev(ent,pev_body,4)
						set_pev(id,pev_weaponanim,anim_knifedraw)
						
						player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_bat_curtime)
						engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_wpn_bat_draw, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
					case human_heavy:
					{
						set_pev(id,pev_viewmodel2,mdl_wpn_v_fist)
						set_pev(id,pev_weaponmodel2,mdl_wpn_wp_fist)
						set_pev(ent,pev_weaponmodel2,0)
						set_pev(id,pev_weaponanim,anim_knifedraw)
						
						player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_fist_curtime)
					}
					case human_soldier:
					{
						set_pev(id,pev_viewmodel2,mdl_wpn_v_shovel)
						set_pev(id,pev_weaponmodel2,mdl_wpn_wp_shovel)
						//set_pev(ent,pev_body,13)
						set_pev(id,pev_weaponanim,anim_knifedraw)
						
						player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_shovel_curtime)
					}
					case human_pyro:
					{
						set_pev(id,pev_viewmodel2,mdl_wpn_v_fireaxe)
						set_pev(id,pev_weaponmodel2,mdl_wpn_wp_fireaxe)
						//set_pev(id,pev_weaponmodel2,mdl_wpn_w_p)
						//set_pev(ent,pev_body,19)
						set_pev(id,pev_weaponanim,anim_knifedraw)
						
						player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_fireaxe_curtime)
					}
					case human_sniper:
					{
						set_pev(id,pev_viewmodel2,mdl_wpn_v_machete)
						set_pev(id,pev_weaponmodel2,mdl_wpn_wp_machete)
						//set_pev(ent,pev_body,33)
						set_pev(id,pev_weaponanim,anim_knifedraw)
						
						player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_machete_curtime)
					}
					case human_medic:
					{
						set_pev(id,pev_viewmodel2,mdl_wpn_v_bonesaw)
						set_pev(id,pev_weaponmodel2,mdl_wpn_wp_bonesaw)
						set_pev(id,pev_weaponanim,anim_knifedraw)
						
						player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_bonesaw_curtime)
					}
					case human_engineer:
					{
						set_pev(id,pev_viewmodel2,mdl_wpn_v_wrench)
						set_pev(id,pev_weaponmodel2,mdl_wpn_wp_wrench)
						set_pev(id,pev_weaponanim,anim_knifedraw)
						
						player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_wrench_curtime)
					}
					case human_demoman:
					{
						set_pev(id,pev_viewmodel2,mdl_wpn_v_bottle)
						set_pev(id,pev_weaponmodel2,mdl_wpn_wp_bottle)
						set_pev(id,pev_weaponanim,anim_knifedraw)
						
						player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_bottle_curtime)
					}
					case human_spy:
					{
						if(invisible_ing[id]||invisible_ed[id])
						{
							set_pev(id,pev_viewmodel2,mdl_wpn_v_butterfly_watch)
						}else{
							set_pev(id,pev_viewmodel2,mdl_wpn_v_butterfly)
						}
						set_pev(id,pev_weaponmodel2,mdl_wpn_wp_butterfly)
						set_pev(id,pev_weaponanim,butterfly_animdraw)
						
						player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_butterfly_curtime)
						engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_wpn_butterfly_draw, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
				}
				
				if(disguise[id])
				{
					switch(disguise_iszm[id])
					{
						case false:
						{
							switch(disguise_type[id])
							{
								case human_scout:
								{
									set_pev(id,pev_weaponmodel2,mdl_wpn_wp_bat)
								}
								case human_heavy:
								{
									set_pev(id,pev_weaponmodel2,mdl_wpn_wp_fist)
								}
								case human_soldier:
								{
									set_pev(id,pev_weaponmodel2,mdl_wpn_wp_shovel)
								}
								case human_pyro:
								{
									set_pev(id,pev_weaponmodel2,mdl_wpn_wp_fireaxe)
								}
								case human_sniper:
								{
									set_pev(id,pev_weaponmodel2,mdl_wpn_wp_machete)
								}
								case human_medic:
								{
									set_pev(id,pev_weaponmodel2,mdl_wpn_wp_bonesaw)
								}
								case human_engineer:
								{
									set_pev(id,pev_weaponmodel2,mdl_wpn_wp_wrench)
								}
								case human_demoman:
								{
									set_pev(id,pev_weaponmodel2,mdl_wpn_wp_bottle)
								}
								case human_spy:
								{
									set_pev(id,pev_weaponmodel2,mdl_wpn_wp_butterfly)
								}
							}
						}
						case true:
						{
							switch(disguise_type[id])
							{
								case zombie_scout:
								{
									set_pev(id,pev_weaponmodel2,0)
								}
								case zombie_heavy:
								{
									set_pev(id,pev_weaponmodel2,mdl_wpn_wp_fist)
								}
								case zombie_soldier:
								{
									set_pev(id,pev_weaponmodel2,0)
								}
								case zombie_pyro:
								{
									set_pev(id,pev_weaponmodel2,0)
								}
								case zombie_sniper:
								{
									set_pev(id,pev_weaponmodel2,0)
								}
								case zombie_medic:
								{
									set_pev(id,pev_weaponmodel2,mdl_wpn_wp_bonesaw)
								}
								case zombie_engineer:
								{
									set_pev(id,pev_weaponmodel2,0)
								}
								case zombie_demoman:
								{
									set_pev(id,pev_weaponmodel2,0)
								}
								case zombie_spy:
								{
									set_pev(id,pev_weaponmodel2,0)
								}
							}
						}
					}
				}
				
			}else{
				player_weaponid_last[id]=player_weaponid_now[id]
				player_weaponid_now[id]=g_wpnitem_knife_zombie[id][ghuman[id]]
				if(g_wpnitem_knife[id][ghuman[id]]==-1)
				{
					format(player_weaponclassname_chi[id],31,"%s",zombie_normal_knifewpnname[ghuman[id]])
					format(player_weaponclassname_eng[id],31,"%s",zombie_normal_knifewpnengname[ghuman[id]])
				}else{
					ArrayGetString(item_chinese_name,player_weaponid_now[id],player_weaponclassname_chi[id],31)
					ArrayGetString(item_english_name,player_weaponid_now[id],player_weaponclassname_eng[id],31)
				}
				
				switch(gzombie[id])
				{
					case zombie_scout:
					{
						set_pev(id,pev_viewmodel2,mdl_wpn_scoutzombieknife)
						set_pev(id,pev_weaponmodel2,0)
						//set_pev(ent,pev_body,4)
						set_pev(id,pev_weaponanim,anim_knifedraw)
						
						player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_bat_curtime)
						engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_wpn_bat_draw, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
					case zombie_heavy:
					{
						set_pev(id,pev_viewmodel2,mdl_wpn_heavyzombieknife)
						set_pev(id,pev_weaponmodel2,mdl_wpn_wp_fist)
						set_pev(id,pev_weaponanim,anim_knifedraw)
						
						player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_fist_curtime)
					}
					case zombie_soldier:
					{
						set_pev(id,pev_viewmodel2,mdl_wpn_soldierzombieknife)
						set_pev(id,pev_weaponmodel2,0)
						//set_pev(ent,pev_body,13)
						set_pev(id,pev_weaponanim,anim_knifedraw)
						
						player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_shovel_curtime)
					}
					case zombie_pyro:
					{
						set_pev(id,pev_viewmodel2,mdl_wpn_pyrozombieknife)
						set_pev(id,pev_weaponmodel2,0)
						//set_pev(id,pev_weaponmodel2,mdl_wpn_w_p)
						//set_pev(ent,pev_body,19)
						set_pev(id,pev_weaponanim,anim_knifedraw)
						
						player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_fireaxe_curtime)
					}
					case zombie_sniper:
					{
						set_pev(id,pev_viewmodel2,mdl_wpn_sniperzombieknife)
						set_pev(id,pev_weaponmodel2,0)
						//set_pev(ent,pev_body,33)
						set_pev(id,pev_weaponanim,anim_knifedraw)
						
						player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_machete_curtime)
					}
					case zombie_medic:
					{
						set_pev(id,pev_viewmodel2,mdl_wpn_mediczombieknife)
						set_pev(id,pev_weaponmodel2,mdl_wpn_wp_bonesaw)
						set_pev(id,pev_weaponanim,anim_knifedraw)
						
						player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_bonesaw_curtime)
					}
					case zombie_engineer:
					{
						set_pev(id,pev_viewmodel2,mdl_wpn_engineerzombieknife)
						set_pev(id,pev_weaponmodel2,0)
						set_pev(id,pev_weaponanim,anim_knifedraw)
						
						player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_wrench_curtime)
					}
					case zombie_demoman:
					{
						set_pev(id,pev_viewmodel2,mdl_wpn_demomanzombieknife)
						set_pev(id,pev_weaponmodel2,0)
						set_pev(id,pev_weaponanim,anim_knifedraw)
						
						player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_bottle_curtime)
					}
					case zombie_spy:
					{
						if(invisible_ing[id]||invisible_ed[id])
						{
							set_pev(id,pev_viewmodel2,mdl_wpn_spyzombieknifehide)
						}else{
							set_pev(id,pev_viewmodel2,mdl_wpn_spyzombieknife)
						}
						set_pev(id,pev_weaponmodel2,0)
						set_pev(id,pev_weaponanim,butterfly_animdraw)
						
						player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_butterfly_curtime)
						engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_wpn_butterfly_draw, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
				}
				
				if(disguise[id])
				{
					switch(disguise_iszm[id])
					{
						case false:
						{
							switch(disguise_type[id])
							{
								case human_scout:
								{
									set_pev(id,pev_weaponmodel2,mdl_wpn_wp_bat)
								}
								case human_heavy:
								{
									set_pev(id,pev_weaponmodel2,mdl_wpn_wp_fist)
								}
								case human_soldier:
								{
									set_pev(id,pev_weaponmodel2,mdl_wpn_wp_shovel)
								}
								case human_pyro:
								{
									set_pev(id,pev_weaponmodel2,mdl_wpn_wp_fireaxe)
								}
								case human_sniper:
								{
									set_pev(id,pev_weaponmodel2,mdl_wpn_wp_machete)
								}
								case human_medic:
								{
									set_pev(id,pev_weaponmodel2,mdl_wpn_wp_bonesaw)
								}
								case human_engineer:
								{
									set_pev(id,pev_weaponmodel2,mdl_wpn_wp_wrench)
								}
								case human_demoman:
								{
									set_pev(id,pev_weaponmodel2,mdl_wpn_wp_bottle)
								}
								case human_spy:
								{
									set_pev(id,pev_weaponmodel2,mdl_wpn_wp_butterfly)
								}
							}
						}
						case true:
						{
							switch(disguise_type[id])
							{
								case zombie_scout:
								{
									set_pev(id,pev_weaponmodel2,0)
								}
								case zombie_heavy:
								{
									set_pev(id,pev_weaponmodel2,mdl_wpn_wp_fist)
								}
								case zombie_soldier:
								{
									set_pev(id,pev_weaponmodel2,0)
								}
								case zombie_pyro:
								{
									set_pev(id,pev_weaponmodel2,0)
								}
								case zombie_sniper:
								{
									set_pev(id,pev_weaponmodel2,0)
								}
								case zombie_medic:
								{
									set_pev(id,pev_weaponmodel2,mdl_wpn_wp_bonesaw)
								}
								case zombie_engineer:
								{
									set_pev(id,pev_weaponmodel2,0)
								}
								case zombie_demoman:
								{
									set_pev(id,pev_weaponmodel2,0)
								}
								case zombie_spy:
								{
									set_pev(id,pev_weaponmodel2,mdl_wpn_wp_butterfly)
								}
							}
						}
					}
				}
			}
		}else{
			
			switch(gboss[id])
			{
				case boss_cbs:
				{
					switch(Boss_changeknife)
					{
						case 0:
						{
							set_pev(id,pev_viewmodel2,mdl_wpn_CBS_bossknife_normal)
							set_pev(id,pev_weaponmodel2,0)
							set_pev(id,pev_weaponanim,anim_knifedraw)
							
							player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_machete_curtime)
							
							format(player_weaponclassname_chi[id],31,"%s","猎刀")
							format(player_weaponclassname_eng[id],31,"%s","Machete")
						}
						case 1:
						{
							set_pev(id,pev_viewmodel2,mdl_wpn_CBS_bossknife_croc)
							set_pev(id,pev_weaponmodel2,0)
							set_pev(id,pev_weaponanim,anim_knifedraw)
							
							player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_machete_curtime)
							
							format(player_weaponclassname_chi[id],31,"%s","灌木丛")
							format(player_weaponclassname_eng[id],31,"%s","Wood")
						}
						case 2:
						{
							set_pev(id,pev_viewmodel2,mdl_wpn_CBS_bossknife_wood)
							set_pev(id,pev_weaponmodel2,0)
							set_pev(id,pev_weaponanim,anim_knifedraw)
							
							player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_machete_curtime)
							
							format(player_weaponclassname_chi[id],31,"%s","部落刮胡刀")
							format(player_weaponclassname_eng[id],31,"%s","Croc")
						}
					}
				}
				case boss_scp173:
				{
					set_pev(id,pev_viewmodel2,mdl_wpn_SCP173_bossknife)
					set_pev(id,pev_weaponmodel2,0)
					set_pev(id,pev_weaponanim,anim_knifedraw)
					
					player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_bat_curtime)
					
					format(player_weaponclassname_chi[id],31,"%s","爪子")
					format(player_weaponclassname_eng[id],31,"%s","Paw")
				}
				case boss_creeper:
				{
					set_pev(id,pev_viewmodel2,mdl_wpn_creeper_bossknife)
					set_pev(id,pev_weaponmodel2,0)
					set_pev(id,pev_weaponanim,anim_knifedraw)
					
					player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_fist_curtime)
					
					format(player_weaponclassname_chi[id],31,"%s","拳头")
					format(player_weaponclassname_eng[id],31,"%s","Fist")
				}
				case boss_guardian:
				{
					set_pev(id,pev_viewmodel2,mdl_wpn_guardian_bossknife)
					set_pev(id,pev_weaponmodel2,0)
					set_pev(id,pev_weaponanim,anim_knifedraw)
					
					player_curweapontime[id]=nowtime+get_pcvar_float(cvar_wpn_fist_curtime)
					
					format(player_weaponclassname_chi[id],31,"%s","拳头")
					format(player_weaponclassname_eng[id],31,"%s","Fist")
				}
			}
		}
		
		
	}
	else if(equali(classname,"weapon_hegrenade")&&spawn_post[id])
	{
		player_weaponid_last[id]=player_weaponid_now[id]
		player_weaponid_now[id]=-1
		
		
		set_pdata_float(ent,46,9999.0)
		set_pdata_float(ent,47,9999.0)
		set_pdata_float(ent,48,9999.0,4)
		
		PlaySequence(id,PLAYER_HOLDBOMB)
		
		if(!giszm[id])
		{
			switch(ghuman[id])
			{
				case human_engineer:
				{		
					format(player_weaponclassname_chi[id],31,"个人电子助理(建造)")
					format(player_weaponclassname_eng[id],31,"PDA(Build)")
					
					set_pev(id,pev_viewmodel2,mdl_wpn_v_buildpda)
					set_pev(id,pev_weaponmodel2,mdl_wpn_wp_buildpda)
					set_pev(id,pev_weaponanim,anim_buildpdadraw)
					
					//engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, , VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					
					ckrun_show_buildmenu(id)
				}
				case human_spy:
				{
					format(player_weaponclassname_chi[id],31,"化妆盒")
					format(player_weaponclassname_eng[id],31,"Disguise Kit")
					
					set_pev(id,pev_viewmodel2,mdl_wpn_v_disguisekit)
					set_pev(id,pev_weaponmodel2,mdl_wpn_wp_disguisekit)
					set_pev(id,pev_weaponanim,1)
					
					
					ckrun_show_disguisemenu(id)
				}
	
			}
		}
		else
		{
			switch(gzombie[id])
			{
				case zombie_spy:
				{
					format(player_weaponclassname_chi[id],31,"化妆盒")
					format(player_weaponclassname_eng[id],31,"Disguise Kit")
					
					set_pev(id,pev_viewmodel2,mdl_wpn_v_disguisekit)
					set_pev(id,pev_weaponmodel2,mdl_wpn_wp_disguisekit)
					set_pev(id,pev_weaponanim,1)
					
					
					ckrun_show_disguisemenu(id)
				}
	
			}
		}
	}
	else if(equali(classname,"weapon_c4")&&spawn_post[id])
	{
		player_weaponid_last[id]=player_weaponid_now[id]
		player_weaponid_now[id]=-1
		
		set_pdata_float(ent,46,9999.0)
		set_pdata_float(ent,47,9999.0)
		set_pdata_float(ent,48,999.0,4)
		
		PlaySequence(id,PLAYER_HOLDBOMB)
		
		switch(ghuman[id])
		{
			case human_engineer:
			{	
				format(player_weaponclassname_chi[id],31,"个人电子助理(摧毁)")
				format(player_weaponclassname_eng[id],31,"PDA(destroy)")
				
				set_pev(id,pev_viewmodel2,mdl_wpn_v_destroypda)
				set_pev(id,pev_weaponmodel2,mdl_wpn_wp_destroypda)
				set_pev(id,pev_weaponanim,anim_destroypdadraw)
				
				//engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, , VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				
				ckrun_show_destroymenu(id)
			}
		}
	}else{
		player_weaponid_last[id]=player_weaponid_now[id]
		player_weaponid_now[id]=-1
		
		format(player_weaponclassname_chi[id],31,"没有武器")
		format(player_weaponclassname_eng[id],31,"No Weapon")
	}
	
}
public Ham_WeaponHolster(ent,id)
{
	id = pev(ent,pev_owner)
	
	ExecuteForward(g_fwWeaponHolster_Pre,g_fwResult,id,ent)
	
	fm_set_user_zoom(id,CS_NO_ZOOM)
	set_fov(id,90)
	
	knifeattacking[id]=false
	remove_task(id+TASK_KNIFEATTACKING)
	
	sniperifle_power[id]=0
	remove_task(id+TASK_SNIPEPOWER)
	remove_task(id+TASK_SNIPERRELOAD)
	set_msg_armor(id,get_user_armor(id))
	
	if(medictarget[id]>0)
	{
		if(bemedic[medictarget[id]]==id)
		{
			bemedic[medictarget[id]]=0
		}
		medictarget[id]=0
	}
	
	butterfly_backuping[id]=false
	butterfly_backuped[id]=false
	butterfly_backdownning[id]=false
	
	ckrun_reset_user_weaponreload(id)
	
	ExecuteForward(g_fwWeaponHolster_Post,g_fwResult,id,ent)
}
/*public blockweaponhud(id)
{
	set_msg_block(get_user_msgid("ItemPickup"), BLOCK_SET)
	set_msg_block(get_user_msgid("AmmoPickup"), BLOCK_SET)
	set_msg_block(get_user_msgid("WeapPickup"), BLOCK_SET)
	return PLUGIN_HANDLED
}*/
public block_kill(id)
{
	if(!is_user_alive(id)) return FMRES_IGNORED
	
	//client_print(id,print_chat,"想自杀?作死!")
	return FMRES_SUPERCEDE
}

public block_drop(id)
{
	if(Boss == id && Bossskilldealy[Boss] <= get_gametime() && g_roundstatus == round_running)
	{
		switch(gboss[id])
		{
			case boss_cbs:
			{
				if(Boss_fuckpower>=(Boss_maxfuckpower*100/100))
				{
					new success = func_skill_angry(id,Float:{4000.0,400.0,1200.0},5.0,512.0)
					
					if(success)
					{
						Boss_fuckpower-=(Boss_maxfuckpower*100/100)
						//player_knifewpnnextattacktime[id]=get_gametime()+1.0
					}
					
					set_msg_armor(Boss,floatround((float(Boss_fuckpower)/float(Boss_maxfuckpower))*100.0))
					Bossskilldealy[Boss]=get_gametime()+5.0
					
					engfunc(EngFunc_EmitSound,id, CHAN_VOICE, snd_vs_CBS_nuhou, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
			}
			case boss_scp173:
			{
				if(Boss_fuckpower>=(Boss_maxfuckpower*100/100))
				{
					new Float:idorg[3],Float:touch[3]
					ckrun_get_user_startpos(id,0.0,0.0,0.0,idorg)
					ckrun_get_user_startpos(id,9999.0,0.0,0.0,touch)
					new ent = fm_trace_line(id,idorg,touch,touch)
					if(!(0<ent<=g_maxplayer))
					{
						if(!(pev(Boss,pev_flags)&FL_DUCKING))
							touch[2]+=38.0
						else
							touch[2]+=19.0
						new success = func_skill_tele(id,touch)
						if(success)
						{
							func_skill_angry(Boss,Float:{1500.0,150.0,600.0},1.0,128.0)
							
							Boss_fuckpower-=(Boss_maxfuckpower*100/100)
							
							set_msg_armor(Boss,floatround((float(Boss_fuckpower)/float(Boss_maxfuckpower))*100.0))
							Bossskilldealy[Boss]=get_gametime()+3.0
							player_knifewpnnextattacktime[Boss]=get_gametime()+1.0
							engfunc(EngFunc_EmitSound,Boss, CHAN_STATIC, snd_vs_SCP173_kaojin, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						}
					}
				}
			}
			case boss_creeper:
			{
				if(Boss_fuckpower>=(Boss_maxfuckpower*100/100))
				{
					new Float:idorg[3]
					pev(id,pev_origin,idorg)
					new success = func_papapa(id,id,0,0,idorg,600.0,150.0,0.45,1000.0,CKRW_FIST,0,0,0,0)
				}
			}
			case boss_guardian:
			{
				new target,Float:idorg[3],Float:targetorg[3],Float:touched[3],bool:hitbody=false
				pev(id,pev_origin,idorg)
				while((target = engfunc(EngFunc_FindEntityInSphere,target,idorg,600.0))!=0)
				{
					pev(target,pev_origin,targetorg)
					new ent = fm_trace_line(id,idorg,targetorg,touched)
					
					new class[32]
					pev(ent,pev_classname,class,31)
					
					if(ent>0&&ent==target)
					{
						if(fm_is_in_viewcone(id,touched,360.0))
						{
							ckrun_takedamage(ent,id,65,CKRW_FIST,CKRD_MELEE,0,1,0,0)
							
							hitbody=true
						}
					}
				}
				if(hitbody)
				{
					engfunc(EngFunc_EmitSound,id, CHAN_WEAPON,snd_vs_guardian_jianta, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
			}
		}
	}
	else if(Boss != id && gboss[Boss] == boss_scp173)
	{
		if(player_zhayanchecktime[id] - get_gametime() <= 4.5)
		{
			func_zhayan(id,6,6.0)
		}
	}
	
	return PLUGIN_HANDLED
}
public block_jointeam(id)
{
	if(is_user_bot(id)) return PLUGIN_CONTINUE;
	if(gteam[id]==team_no||gteam[id]==team_spec) return PLUGIN_CONTINUE;
	
	if(first_playgame[id])
	{
		ckrun_show_chooseteammenu(id)
		return PLUGIN_HANDLED
	}else{
		ckrun_show_mainmenu(id)
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_HANDLED
}

First_Join(id, team)
{
	if (pev_valid(id) == PDATA_SAFE)
		set_pdata_int(id, m_iJoinedState, STATE_PICKINGTEAM, 5)
	switch(team)
	{
		case CS_TEAM_SPECTATOR: engclient_cmd(id, "jointeam", "6")
		case CS_TEAM_T: engclient_cmd(id, "jointeam", "1")
		case CS_TEAM_CT: engclient_cmd(id, "jointeam", "2")
	}
	engclient_cmd(id, "joinclass", "5")
	if (pev_valid(id) == PDATA_SAFE)
		set_pdata_int(id, m_iJoinedState, STATE_PICKINGCLASS, 5)
	
	gteam[id]=team
	
	ckrun_show_choosetypemenu(id)
}

//-----------------------------------------------------------------------------//
//菜单
public ckrun_show_mainmenu(id)//主菜单
{
	new menu[512],len
	len=0
	
	len += formatex(menu[len],sizeof menu - len - 1,"\y%s[主菜单] ^n^n",MSG_CKR2)
	
	len += formatex(menu[len],sizeof menu - len - 1,"\r1.\w人类兵种^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r2.\w僵尸兵种^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r3.\wBOSS类型^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r4.\w队伍^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r5.\w帮助^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r6.\w个人^n^n^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r8.\w配置^n^n")
	
	len += formatex(menu[len],sizeof menu - len - 1,"\r0.\w退出")
	
	
	show_menu(id,(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<7|1<<8|1<<9),menu,-1,"MENU MAIN")
	
	
}
public ckrun_mainmenu(id,key)
{
	key+=1
	
	switch(key)
	{
		case 1:
		{
			ckrun_show_choosetypemenu(id)
		}
		case 2:
		{
			ckrun_show_choosezbtypemenu(id)
		}
		case 3:
		{
			ckrun_show_choosebosstypemenu(id)
		}
		case 4:
		{
			ckrun_show_chooseteammenu(id)
		}
		case 5:
		{
			ckrun_show_helpmotd(id)
		}
		case 6:
		{
			ckrun_show_personalmenu(id)
		}
		case 8:
		{
			ckrun_show_setstatusmenu(id)
		}
		case 9:
		{
			ckrun_show_adminsetupmenu(id)
		}
		case 10:
		{
			return PLUGIN_HANDLED
		}
	}
	
	return PLUGIN_CONTINUE
}
public ckrun_show_choosetypemenu(id)//HM兵种菜单
{
	new idteam = gteam[id]
	ckrun_get_teamhumantypenum(idteam)
	
	new menu[512],len
	len=0
	
	len += formatex(menu[len],sizeof menu - len - 1,"\y%s[人类兵种] ^n",MSG_CKR2)
	len += formatex(menu[len],sizeof menu - len - 1,"\w您当前使用兵种[\r%s\w]^n",MSG_humantype_name[ghuman[id]])
	len += formatex(menu[len],sizeof menu - len - 1,"\w您复活后的兵种[\r%s\w]^n^n",MSG_humantype_name[gwillbehuman[id]])
	
	
	for(new i=1;i<sizeof MSG_humantype_name - 1;i++)
	{
		len += formatex(menu[len],sizeof menu - len - 1,"\r%d.\w%s(%d)^n",i,MSG_humantype_name[i],g_teamhumantypenum[idteam][i])
	}
	len += formatex(menu[len],sizeof menu - len - 1," ^n")
	
	len += formatex(menu[len],sizeof menu - len - 1,"\r0.\w返回")
	
	show_menu(id,ALLKEYS,menu,-1,"MENU TYPE")
	
}
public ckrun_typemenu(id,key)
{
	key+=1
	
	if(!ghuman[id])
	{
		ghuman[id]=key
		gwillbehuman[id]=key
		set_pdata_int(id, m_iJoinedState, STATE_JOINED, 5)
		ExecuteHamB(Ham_CS_RoundRespawn,id)
		first_playgame[id]=false
		return;
	}
	
	
	if(key==10) 
	{
		ckrun_show_mainmenu(id)
		return;
	}
	
	
	if(key==gwillbehuman[id])
	{
		ckrun_show_choosetypemenu(id)
		return;
	}
	
	gwillbehuman[id]=key
	if(g_roundstatus == round_start)
	{
		ExecuteHamB(Ham_CS_RoundRespawn,id)
	}else{
		client_print(id,print_chat,"你下一次重生时人类兵种会变成:%s",MSG_humantype_name[gwillbehuman[id]])
	}
	
	return;
}
public ckrun_show_choosezbtypemenu(id)//JS兵种菜单
{
	ckrun_get_teamzombietypenum()
	
	new menu[512],len
	len=0
	
	len += formatex(menu[len],sizeof menu - len - 1,"\y%s[僵尸兵种] ^n",MSG_CKR2)
	len += formatex(menu[len],sizeof menu - len - 1,"\w您当前使用僵尸[\r%s\w]^n",MSG_zombietype_name[gzombie[id]])
	len += formatex(menu[len],sizeof menu - len - 1,"\w您复活后的僵尸[\r%s\w]^n^n",MSG_zombietype_name[gwillbezombie[id]])
	
	
	for(new i=1;i<sizeof MSG_zombietype_name;i++)
	{
		len += formatex(menu[len],sizeof menu - len - 1,"\r%d.\w%s(%d)^n",i,MSG_zombietype_name[i],g_teamzombietypenum[i])
	}
	len += formatex(menu[len],sizeof menu - len - 1," ^n")
	
	len += formatex(menu[len],sizeof menu - len - 1,"\r0.\w返回")
	
	show_menu(id,ALLKEYS,menu,-1,"MENU ZBTYPE")
	
}
public ckrun_zbtypemenu(id,key)
{
	key+=1
	if(key==10) 
	{
		ckrun_show_mainmenu(id)
		return;
	}
	
	
	if(key==gwillbezombie[id])
	{
		ckrun_show_choosezbtypemenu(id)
		return;
	}
	
	gwillbezombie[id]=key
	client_print(id,print_chat,"你下一次重生时僵尸兵种会变成:%s",MSG_zombietype_name[gwillbezombie[id]])
	
	return;
}
public ckrun_show_choosebosstypemenu(id)//BOSS类别菜单
{
	ckrun_get_bosstypenum()
	
	new menu[512],len
	len=0
	
	len += formatex(menu[len],sizeof menu - len - 1,"\y%s[BOSS类别] ^n",MSG_CKR2)
	len += formatex(menu[len],sizeof menu - len - 1,"\w您当前使用BOSS[\r%s\w]^n",MSG_bosstype_name[gboss[id]])
	len += formatex(menu[len],sizeof menu - len - 1,"\w您复活后的BOSS[\r%s\w]^n^n",MSG_bosstype_name[gwillbeboss[id]])
	
	
	for(new i=1;i<sizeof MSG_bosstype_name;i++)
	{
		len += formatex(menu[len],sizeof menu - len - 1,"\r%d.\w%s(%d)^n",i,MSG_bosstype_name[i],g_teambosstypenum[i])
	}
	len += formatex(menu[len],sizeof menu - len - 1," ^n")
	
	len += formatex(menu[len],sizeof menu - len - 1,"\r0.\w返回")
	
	show_menu(id,ALLKEYS,menu,-1,"MENU BOSSTYPE")
	
}
public ckrun_bosstypemenu(id,key)
{
	key+=1
	if(key==10) 
	{
		ckrun_show_mainmenu(id)
		return;
	}
	
	
	if(key==gwillbeboss[id])
	{
		ckrun_show_choosebosstypemenu(id)
		return;
	}
	
	gwillbeboss[id]=key
	client_print(id,print_chat,"下次你会变成BOSS:%s",MSG_bosstype_name[gwillbeboss[id]])
	
	return;
}
public ckrun_show_chooseteammenu(id)//队伍菜单
{
	ckrun_get_teamplayernum()
	
	
	new menu[512],len
	len=0
	
	len += formatex(menu[len],sizeof menu - len - 1,"\y%s[队伍] ^n^n",MSG_CKR2)
	
	if(first_playgame[id])
	{
		for(new i=1;i<sizeof MSG_team_name-1;i++)
		{
			len += formatex(menu[len],sizeof menu - len - 1,"\r%d.\w%s(%d)^n",i,MSG_team_name[i],g_teamplayernum[i])
		}
	}else{
		if(g_gamemode == gamemode_arena)
		{
			for(new i=1;i<sizeof MSG_team_name-1;i++)
			{
				len += formatex(menu[len],sizeof menu - len - 1,"\r%d.\w%s(%d)^n",i,MSG_team_name[i],g_teamplayernum[i])
			}
		}
		else if(g_gamemode == gamemode_zombie)
		{
			len += formatex(menu[len],sizeof menu - len - 1,"\r1.\w人类(%d)^n",ckrun_get_humannum())
			len += formatex(menu[len],sizeof menu - len - 1,"\r2.\w僵尸(%d)^n",ckrun_get_zombienum())
		}
		else if(g_gamemode == gamemode_vsasb)
		{
			if(is_user_alive(Boss))
			{
				len += formatex(menu[len],sizeof menu - len - 1,"\r1.\w人类(%d)^n",ckrun_get_playernum_alive()-1)
			}else{
				len += formatex(menu[len],sizeof menu - len - 1,"\r1.\w人类(%d)^n",ckrun_get_playernum_alive())
			}
		}
	}
	
	len += formatex(menu[len],sizeof menu - len - 1," ^n")
	
	len += formatex(menu[len],sizeof menu - len - 1,"\r0.\w返回")
	
	show_menu(id,(1<<0|1<<1|1<<9),menu,-1,"MENU TEAM")
	
}
public ckrun_teammenu(id,key)
{
	key+=1
	
	if(first_playgame[id])
	{
		First_Join(id,key)
	}else{
		if(g_gamemode == gamemode_arena)
		{
		
			if(key==10)
			{
				return;
			}
			
			if(key>2||key==gteam[id])
			{
				ckrun_show_chooseteammenu(id)
				return;
			}
			
			
			ckrun_kill(id,id,-1,CKRD_OTHER,0,0)
			fm_set_user_team(id,key,0)
			gteam[id]=key
			
			return;
		}
		else if(g_gamemode == gamemode_zombie)
		{
			if(key==10)
			{
				return;
			}
			
			ckrun_show_chooseteammenu(id)
			
		}
		else if(g_gamemode == gamemode_vsasb)
		{
			if(key==10)
			{
				return;
			}
			
			ckrun_show_chooseteammenu(id)
		}
	}
	return;
	
}
public ckrun_show_helpmotd(id)
{
	static motd[4096], len
	len = 0
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_GAMEMODE_TITLE")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_GAMEMODE_ZOMBIE")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_GAMEMODE_ZOMBIE2")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_GAMEMODE_NORMAL")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_GAMEMODE_NORMAL2")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_GAMEMODE_VSASB")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_GAMEMODE_VSASB2")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_GAMEMODE_CSMODE")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_GAMEMODE_CSMODE2")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_GAMEMODE_WTF")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_GAMEMODE_WTF2")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_HUMAN_TITLE")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_HUMAN_SCOUT")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_HUMAN_HEAVY")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_HUMAN_SOLDIER")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_HUMAN_PYRO")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_HUMAN_SNIPER")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_HUMAN_MEDIC")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_HUMAN_ENGINEER")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_HUMAN_DEMOMAN")
	len += formatex(motd[len], sizeof motd - 1 - len, "%L", id, "MOTD_HUMAN_SPY")
	

	new temp[64]
	num_to_str(human_maxhealth[human_scout], temp, sizeof temp - 1)
	replace_all(motd, 4095, "$ckr2_scout_health", temp )
	num_to_str(human_maxspeed[human_scout], temp, sizeof temp - 1)
	replace_all(motd, 4095, "$ckr2_scout_speed", temp )
	num_to_str(human_maxhealth[human_heavy], temp, sizeof temp - 1)
	replace_all(motd, 4095, "$ckr2_heavy_health", temp )
	num_to_str(human_maxspeed[human_heavy], temp, sizeof temp - 1)
	replace_all(motd, 4095, "$ckr2_heavy_speed", temp )
	num_to_str(human_maxhealth[human_soldier], temp, sizeof temp - 1)
	replace_all(motd, 4095, "$ckr2_soldier_health", temp )
	num_to_str(human_maxspeed[human_soldier], temp, sizeof temp - 1)
	replace_all(motd, 4095, "$ckr2_soldier_speed", temp )
	num_to_str(human_maxhealth[human_pyro], temp, sizeof temp - 1)
	replace_all(motd, 4095, "$ckr2_pyro_health", temp )
	num_to_str(human_maxspeed[human_pyro], temp, sizeof temp - 1)
	replace_all(motd, 4095, "$ckr2_pyro_speed", temp )
	num_to_str(human_maxhealth[human_sniper], temp, sizeof temp - 1)
	replace_all(motd, 4095, "$ckr2_sniper_health", temp )
	num_to_str(human_maxspeed[human_sniper], temp, sizeof temp - 1)
	replace_all(motd, 4095, "$ckr2_sniper_speed", temp )
	num_to_str(human_maxhealth[human_medic], temp, sizeof temp - 1)
	replace_all(motd, 4095, "$ckr2_medic_health", temp )
	num_to_str(human_maxspeed[human_medic], temp, sizeof temp - 1)
	replace_all(motd, 4095, "$ckr2_medic_speed", temp )
	num_to_str(human_maxhealth[human_engineer], temp, sizeof temp - 1)
	replace_all(motd, 4095, "$ckr2_engineer_health", temp )
	num_to_str(human_maxspeed[human_engineer], temp, sizeof temp - 1)
	replace_all(motd, 4095, "$ckr2_engineer_speed", temp )
	num_to_str(human_maxhealth[human_demoman], temp, sizeof temp - 1)
	replace_all(motd, 4095, "$ckr2_demoman_health", temp )
	num_to_str(human_maxspeed[human_demoman], temp, sizeof temp - 1)
	replace_all(motd, 4095, "$ckr2_demoman_speed", temp )
	num_to_str(human_maxhealth[human_spy], temp, sizeof temp - 1)
	replace_all(motd, 4095, "$ckr2_spy_health", temp )
	num_to_str(human_maxspeed[human_spy], temp, sizeof temp - 1)
	replace_all(motd, 4095, "$ckr2_spy_speed", temp )
	
	show_motd(id, motd)
}
public ckrun_show_setstatusmenu(id)
{
	new menu[512],len
	len=0
	
	len += formatex(menu[len],sizeof menu - len - 1,"\y%s[配置] ^n^n",MSG_CKR2)
	
	len += formatex(menu[len],sizeof menu - len - 1,"\r1.\w中英文切换^n")
	
	len += formatex(menu[len],sizeof menu - len - 1,"\r0.\w返回")
	
	show_menu(id,(1<<0|1<<9),menu,-1,"MENU STATUS SETUP")
}
public ckrun_setstatusmenu(id,key)
{
	key++
	
	if(key==1)
	{
		if(player_use_chinese[id])
		{
			player_use_chinese[id]=false
			client_print(id,print_chat,"已切换为英文HUD")
		}else{
			player_use_chinese[id]=true
			client_print(id,print_chat,"已切换为中文HUD")
		}
	}
	
	
}
public ckrun_show_adminsetupmenu(id)
{
	if(!(get_user_flags(id) & ADMIN_BAN)) return;
	
	new menu[512],len
	len=0
	
	len += formatex(menu[len],sizeof menu - len - 1,"\y%s[论后台的重要性] ^n^n",MSG_CKR2)
	
	len += formatex(menu[len],sizeof menu - len - 1,"\r1.\w创建补给点\w^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r2.\w创建Boss重生位置(VS模式专用)\w^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r3.\w管理员技能^n^n^n")
	
	len += formatex(menu[len],sizeof menu - len - 1,"\r0.\w退出")
	
	
	show_menu(id,(1<<0|1<<1|1<<2|1<<9),menu,-1,"MENU ADMIN SETUP")
	
}
public ckrun_adminsetupmenu(id,key)
{
	key++
	
	switch(key)
	{
		case 1:ckrun_show_supplymenu(id)
		case 2:ckrun_show_bossspawnpointmenu(id)
		case 3:ckrun_show_adminskill(id)
		case 10:ckrun_show_mainmenu(id)
	}
	
	
}
public ckrun_show_supplymenu(id)
{
	new menu[512],len
	len=0
	
	len += formatex(menu[len],sizeof menu - len - 1,"\y%s[补给点] Studio Ing^n",MSG_CKR2)
	
	len += formatex(menu[len],sizeof menu - len - 1,"\w生命补给点个数:\y%d\w^n",healthpoint_num)
	len += formatex(menu[len],sizeof menu - len - 1,"\w弹药补给点个数:\y%d\w^n^n",ammopoint_num)
	len += formatex(menu[len],sizeof menu - len - 1,"\w生命&弹药补给点个数:\y%d\w^n^n",healthandammopoint_num)
	len += formatex(menu[len],sizeof menu - len - 1,"\r1.\w载入文件(没有就建立一个)\w^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r2.\w设置补给类型[\y%s\w]\w^n",MSG_SUPPLY_TYPE[supply_type[id]])
	len += formatex(menu[len],sizeof menu - len - 1,"\r3.\w设置补给大小[\y%s\w]\w^n",MSG_SUPPLY_SIZE[supply_size[id]])
	len += formatex(menu[len],sizeof menu - len - 1,"\r4.\w创建一个补给(当前位置)\w^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r5.\w删除一个补给(当前位置)\w^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r9.\w保存文件\w^n^n")
	
	len += formatex(menu[len],sizeof menu - len - 1,"\r0.\w退出")
	
	show_menu(id,(1<<0|1<<1|1<<2|1<<3|1<<4|1<<8|1<<9),menu,-1,"MENU SUPPLY SETUP")
}
public ckrun_supplymenu(id,key)
{
	key++
	new Float:idorg[3],Float:idorg2[3],Float:touchend[3]
	pev(id,pev_origin,idorg)
	xs_vec_copy(idorg,idorg2)
	idorg2[2]-=9999.0
	fm_trace_line(id,idorg,idorg2,touchend)
	
	switch(key)
	{
		case 1:
		{
			load_supply_file()
			ckrun_show_supplymenu(id)
		}
		case 2:
		{
			supply_type[id]++
			if(supply_type[id]>2)
				supply_type[id]=0
				
			ckrun_show_supplymenu(id)
		}
		case 3:
		{
			supply_size[id]++
			if(supply_size[id]>2)
				supply_size[id]=0
				
			ckrun_show_supplymenu(id)
		}
		case 4:
		{
			new param[5]
			param[0]=floatround(touchend[0])
			param[1]=floatround(touchend[1])
			param[2]=floatround(touchend[2])
			param[3]=supply_type[id]
			param[4]=supply_size[id]
			
			ckrun_create_item_edit(param)
			ckrun_show_supplymenu(id)
		}
		case 5:
		{
			ckrun_remove_item_edit(touchend)
			ckrun_show_supplymenu(id)
		}
		case 9:
		{
			save_supply_file()
			ckrun_show_supplymenu(id)
		}
		case 10:
		{
			ckrun_show_adminsetupmenu(id)
		}
	}
	
}
public ckrun_show_bossspawnpointmenu(id)
{
	if(g_gamemode != gamemode_vsasb) return;

	new menu[512],len
	len=0
	
	len += formatex(menu[len],sizeof menu - len - 1,"\y%s[Boss重生点] Studio Ing^n",MSG_CKR2)
	
	len += formatex(menu[len],sizeof menu - len - 1,"\wBoss重生点个数:\y%d\w^n",bossspawnpoint_num)
	len += formatex(menu[len],sizeof menu - len - 1,"\r1.\w载入文件(没有就建立一个)\w^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r2.\w创建一个重生点(当前位置)\w^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r3.\w删除一个重生点(当前位置)\w^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r9.\w保存文件\w^n^n")
	
	len += formatex(menu[len],sizeof menu - len - 1,"\r0.\w退出")
	
	show_menu(id,(1<<0|1<<1|1<<2|1<<8|1<<9),menu,-1,"MENU BOSS SPAWNPOINT")
}
public ckrun_bossspawnpointmenu(id,key)
{
	key+=1
	
	new Float:forg[3],idorg[3]
	pev(id,pev_origin,forg)
	idorg[0]=floatround(forg[0])
	idorg[1]=floatround(forg[1])
	idorg[2]=floatround(forg[2])
	
	switch(key)
	{
		case 1:
		{
			load_bossspawnpoint_file()
			ckrun_show_bossspawnpointmenu(id)
		}
		case 2:
		{
			ckrun_create_bossspawnpoint(idorg)
			ckrun_show_bossspawnpointmenu(id)
		}
		case 3:
		{
			ckrun_remove_bossspawnpoint(forg)
			ckrun_show_bossspawnpointmenu(id)
		}
		case 9:
		{
			save_bossspawnpoint_file()
			ckrun_show_bossspawnpointmenu(id)
		}
		case 10:
		{
			
		}
	}
	
}
public load_bossspawnpoint_file()
{
	new mapname[32],fuck[512],bossspawnpointfile[512]
	get_mapname(mapname,sizeof mapname -1)
	get_configsdir(fuck,sizeof fuck -1)
	
	formatex(bossspawnpointfile,sizeof bossspawnpointfile -1,"%s/chickenrun_2/map_bossspawnpoint/%s.cfg",fuck,mapname)
	
	if(!file_exists(bossspawnpointfile))
	{
		write_file(bossspawnpointfile,";;;;;===论Boss重生点的重要性===;;;;;^n",-1)
		client_print(0,print_chat,"地图Boss重生点文件已创立:%s",bossspawnpointfile)
	}else{
		if(loaded_mapbossspawnpoint)
		{
			client_print(0,print_chat,"文件已载入过了")
		}
		else
		{
			new file = fopen(bossspawnpointfile,"rt")
			new output[2048],x[8],y[8],z[8]
			for(new i;i < 128;i++)
			{
				bossspawnpoint_status[i][0] = 0
				bossspawnpoint_status[i][1] = 0
				bossspawnpoint_status[i][2] = 0
			}
			bossspawnpoint_num=0
			
			while(file && !feof(file))
			{
				fgets(file, output, sizeof output - 1);
				
				if(!output[0] || str_count(output,' ') < 2) continue;
				
				parse(output,x,7,y,7,z,7)
				
				bossspawnpoint_status[bossspawnpoint_num][0] = str_to_num(x)
				bossspawnpoint_status[bossspawnpoint_num][1] = str_to_num(y)
				bossspawnpoint_status[bossspawnpoint_num][2] = str_to_num(z)
				
				if(bossspawnpoint_status[bossspawnpoint_num][0] !=0 || bossspawnpoint_status[bossspawnpoint_num][1] !=0 || bossspawnpoint_status[bossspawnpoint_num][2] !=0)
					bossspawnpoint_num++
			}
			if (file) fclose(file);
			
			loaded_mapbossspawnpoint=true
			client_print(0,print_chat,"文件载入")
		}
	}
	
}
public save_bossspawnpoint_file()
{
	if(!loaded_mapbossspawnpoint)
	{
		client_print(0,print_chat,"请先载入文件")
		return;
	}
	
	new mapname[32],fuck[512],bossspawnpointfile[512]
	get_mapname(mapname,sizeof mapname -1)
	get_configsdir(fuck,sizeof fuck -1)
	
	formatex(bossspawnpointfile,sizeof bossspawnpointfile -1,"%s/chickenrun_2/map_bossspawnpoint/%s.cfg",fuck,mapname)
	
	new data[2048];
	new len = 0
	len+=formatex(data[len], sizeof data - len - 1,";;;;;===论Boss重生点的重要性===;;;;;^n")
	for(new i ; i < 128;i++)
	{
		if(bossspawnpoint_status[i][0]!=0 ||bossspawnpoint_status[i][1]!=0 ||bossspawnpoint_status[i][2]!=0)
		{
			len+=formatex(data[len], sizeof data - len - 1,"%i %i %i^n",bossspawnpoint_status[i][0],bossspawnpoint_status[i][1],bossspawnpoint_status[i][2])
		}
	}
	
	
	if(file_exists(bossspawnpointfile))
	{
		delete_file(bossspawnpointfile)
		write_file(bossspawnpointfile,data,-1)
		
		loaded_mapbossspawnpoint=false
		client_print(0,print_chat,"文件已保存")
	}
	
}
public ckrun_create_bossspawnpoint(param[])
{
	if(!loaded_mapbossspawnpoint) return 0;
	
	new Float:origin[3],index,faq
	origin[0]=float(param[0])
	origin[1]=float(param[1])
	origin[2]=float(param[2])
	
	for(new i ; i < 128;i++)
	{
		if(bossspawnpoint_status[i][0]==0 && bossspawnpoint_status[i][1]==0 && bossspawnpoint_status[i][2]==0 && faq==0)
		{
			index=i
			faq=1
		}
	}
	
	new point = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!point) return 0; //没创建成功的话..
					
	set_pev(point, pev_origin, origin)
	set_pev(point, pev_classname,"spawnpoint_boss")
			
	new modelindex[64],n=random_num(1,sizeof mdl_boss -1)
	format(modelindex,63,"models/player/%s/%s.mdl",mdl_boss[n],mdl_boss[n])
	engfunc(EngFunc_SetModel,point,modelindex)
	engfunc(EngFunc_SetSize,point,{-1.0, -1.0, -1.0},{1.0,1.0,1.0})
	
	set_pev(point, pev_solid, SOLID_NOT)
	set_pev(point, pev_movetype, MOVETYPE_FLY)
	
	set_pev(point,pev_temp,0)
	
	fm_set_rendering(point,kRenderFxNone, 0,0,0, kRenderTransTexture,85)
	
	fm_set_entity_visible(point,1)
	
	bossspawnpoint_status[index][0]=param[0]
	bossspawnpoint_status[index][1]=param[1]
	bossspawnpoint_status[index][2]=param[2]
	bossspawnpointent_index[point]=index
	
	bossspawnpoint_num++
	
	return 1;
}
public ckrun_remove_bossspawnpoint(Float:org[3])
{
	new target,num,class[32]
	while((target=engfunc(EngFunc_FindEntityInSphere,target,org,30.0))!=0)
	{
		pev(target,pev_classname,class,31)
		if(!equali(class,"spawnpoint_",11)) continue;
		if(num>0) continue;
		
		if(bossspawnpoint_status[bossspawnpointent_index[target]][0]!=0 || bossspawnpoint_status[bossspawnpointent_index[target]][1]!=0 || bossspawnpoint_status[bossspawnpointent_index[target]][2]!=0)
			bossspawnpoint_num--
		
		bossspawnpoint_status[bossspawnpointent_index[target]][0]=0
		bossspawnpoint_status[bossspawnpointent_index[target]][1]=0
		bossspawnpoint_status[bossspawnpointent_index[target]][2]=0
		bossspawnpointent_index[target]=0
		
		engfunc(EngFunc_RemoveEntity,target)
		num++
		
		
	}
}

public load_supply_file()
{
	new mapname[32],fuck[512],supplyfile[512]
	get_mapname(mapname,sizeof mapname -1)
	get_configsdir(fuck,sizeof fuck -1)
	
	formatex(supplyfile,sizeof supplyfile -1,"%s/chickenrun_2/map_supply/%s.cfg",fuck,mapname)
	
	if(!file_exists(supplyfile))
	{
		write_file(supplyfile,";;;;;===论补给的重要性===;;;;;^n",-1)
		client_print(0,print_chat,"地图补给文件已创立:%s",supplyfile)
	}else{
		if(loaded_mapsupply)
		{
			client_print(0,print_chat,"文件已载入过了")
		}
		else
		{
			new file = fopen(supplyfile,"rt")
			new output[2048],x[8],y[8],z[8],type[8],size[8]
			for(new i;i < 128;i++)
			{
				supply_status[i][supplyorg_x] = 0
				supply_status[i][supplyorg_y] = 0
				supply_status[i][supplyorg_z] = 0
				supply_status[i][supplytype] = 0
				supply_status[i][supplysize] = 0
				supply_status[i][supplyentityid] = 0
			}
			healthpoint_num=0
			ammopoint_num=0
			healthandammopoint_num=0
			
			while(file && !feof(file))
			{
				fgets(file, output, sizeof output - 1);
				
				if(!output[0] || str_count(output,' ') < 2) continue;
				
				parse(output,x,7,y,7,z,7,type,7,size,7)
				
				supply_status[putsupply][supplyorg_x] = str_to_num(x)
				supply_status[putsupply][supplyorg_y] = str_to_num(y)
				supply_status[putsupply][supplyorg_z] = str_to_num(z)
				supply_status[putsupply][supplytype] =  str_to_num(type)
				supply_status[putsupply][supplysize]= str_to_num(size)
				if(supply_status[putsupply][supplytype]==type_health)
					healthpoint_num++
				else if(supply_status[putsupply][supplytype]==type_ammo)
					ammopoint_num++
				else if(supply_status[putsupply][supplytype]==type_healthandammo)
					healthandammopoint_num++
				
				putsupply++
			}
			if (file) fclose(file);
			
			loaded_mapsupply=true
			client_print(0,print_chat,"文件载入")
		}
	}
	
}
public save_supply_file()
{
	if(!loaded_mapsupply)
	{
		client_print(0,print_chat,"请先载入文件")
		return;
	}
	
	new mapname[32],fuck[512],supplyfile[512]
	get_mapname(mapname,sizeof mapname -1)
	get_configsdir(fuck,sizeof fuck -1)
	
	formatex(supplyfile,sizeof supplyfile -1,"%s/chickenrun_2/map_supply/%s.cfg",fuck,mapname)
	
	new data[2048];
	new len = 0
	len+=formatex(data[len], sizeof data - len - 1,";;;;;===论补给的重要性===;;;;;^n")
	for(new i ; i < 128;i++)
	{
		if(supply_status[i][supplyorg_x]!=0 || supply_status[i][supplyorg_y]!=0 || supply_status[i][supplyorg_z]!=0)
		{
			len+=formatex(data[len], sizeof data - len - 1,"%i %i %i %i %i^n",supply_status[i][supplyorg_x],supply_status[i][supplyorg_y],supply_status[i][supplyorg_z],supply_status[i][supplytype],supply_status[i][supplysize])
		}
	}
	
	
	if(file_exists(supplyfile))
	{
		delete_file(supplyfile)
		write_file(supplyfile,data,-1)
		
		loaded_mapsupply=false
		client_print(0,print_chat,"文件已保存")
	}
	
}
public ckrun_create_item_edit(param[])//edit
{
	if(!loaded_mapsupply) return 0;
	
	new Float:origin[3],type,size,index,faq
	origin[0]=float(param[0])
	origin[1]=float(param[1])
	origin[2]=float(param[2])
	type=param[3]
	size=param[4]
	
	for(new i ; i < 128;i++)
	{
		if(supply_status[i][supplyorg_x]==0 && supply_status[i][supplyorg_y]==0 && supply_status[i][supplyorg_z] ==0 && faq==0)
		{
			index=i
			faq=1
		}
	}
	
	new supply = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!supply) return 0; //没创建成功的话..
					
	set_pev(supply, pev_origin, origin)
	set_pev(supply, pev_classname,CLASSNAME_SUPPLY[type])
			
	engfunc(EngFunc_SetModel, supply,MDL_SUPPLY[type])
	engfunc(EngFunc_SetSize,supply,{-4.0, -4.0, -4.0},{4.0,4.0, 4.0})
	
	if(type == type_healthandammo)
		set_pev(supply,pev_body,2-size)
	else
		set_pev(supply,pev_body,size)
	
	set_pev(supply, pev_solid, SOLID_NOT)
	set_pev(supply, pev_movetype, MOVETYPE_FLY)
	
	set_pev(supply,pev_gravity,1.0)
	
	set_pev(supply,pev_temp,0)
	
	fm_set_rendering(supply,kRenderFxNone, 0,0,0, kRenderTransTexture,85)
	
	fm_set_entity_visible(supply,1)
	
	supply_status[index][supplyorg_x]=param[0]
	supply_status[index][supplyorg_y]=param[1]
	supply_status[index][supplyorg_z]=param[2]
	supply_status[index][supplytype]=type
	supply_status[index][supplysize]=size
	supply_status[index][supplyentityid]=supply
	supply_index[supply]=index
	
	if(type == type_health)
	{
		healthpoint_num++
	}
	else if(type == type_ammo)
	{
		ammopoint_num++
	}
	else if(type == type_healthandammo)
	{
		healthandammopoint_num++
	}
	
	putsupply++
	
	supply_ready[supply]=false
	
	return 1;
}
public ckrun_remove_item_edit(Float:org[3])
{
	new target,num,class[32]
	while((target=engfunc(EngFunc_FindEntityInSphere,target,org,30.0))!=0)
	{
		pev(target,pev_classname,class,31)
		if(!equali(class,"supply_",6)) continue;
		if(num>0) continue;
		
		if(supply_status[supply_index[target]][supplytype]==type_health)
			healthpoint_num--
		else if(supply_status[supply_index[target]][supplytype]==type_ammo)
			ammopoint_num--
		else if(supply_status[supply_index[target]][supplytype]==type_healthandammo)
			healthandammopoint_num--
		
		supply_status[supply_index[target]][supplyorg_x]=0
		supply_status[supply_index[target]][supplyorg_y]=0
		supply_status[supply_index[target]][supplyorg_z]=0
		supply_status[supply_index[target]][supplytype]=0
		supply_status[supply_index[target]][supplysize]=0
		supply_status[supply_index[target]][supplyentityid]=0
		supply_index[target]=0
		putsupply-- 
		
		engfunc(EngFunc_RemoveEntity,target)
		num++
		
		
	}
}
public ckrun_create_item(param[])//task 
{
	new Float:origin[3],type,size,index
	origin[0]=float(param[0])
	origin[1]=float(param[1])
	origin[2]=float(param[2])
	type=param[3]
	size=param[4]
	index=param[5]
	
	new supply = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!supply) return 0; //没创建成功的话..
					
	set_pev(supply, pev_origin, origin)
	set_pev(supply, pev_classname,CLASSNAME_SUPPLY[type])
			
	engfunc(EngFunc_SetModel, supply,MDL_SUPPLY[type])
	engfunc(EngFunc_SetSize,supply,{-4.0, -4.0, -6.0},{4.0,4.0, 6.0})
	
	if(type == type_healthandammo)
		set_pev(supply,pev_body,2-size)
	else
		set_pev(supply,pev_body,size)
	
	set_pev(supply, pev_solid, SOLID_TRIGGER)
	set_pev(supply, pev_movetype, MOVETYPE_FLY)
	
	set_pev(supply,pev_gravity,1.0)
	
	set_pev(supply,pev_temp,0)
	
	set_pev(supply,pev_animtime, get_gametime())
	set_pev(supply,pev_frame,0.0)
	set_pev(supply,pev_framerate,1.0)
	
	supply_status[index][supplyorg_x]=param[0]
	supply_status[index][supplyorg_y]=param[1]
	supply_status[index][supplyorg_z]=param[2]
	supply_status[index][supplytype]=type
	supply_status[index][supplysize]=size
	supply_status[index][supplyentityid]=supply
	supply_index[supply]=index
	
	supply_ready[supply]=true
	//fm_set_rendering(supply)
	fm_set_entity_visible(supply,1)
	
	//engfunc(EngFunc_EmitSound,supply, CHAN_STATIC, snd_spawnitem, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	set_task(2.0,"item_xuanzhuan",supply+TASK_XUANZHUAN)
	
	return 1;
}
public item_xuanzhuan(tskid)
{/*
	new item = tskid-TASK_XUANZHUAN
	
	if(pev_valid(item))
	{
		set_pev(item,pev_frame,0.0)
		set_task(2.0,"item_xuanzhuan",item+TASK_XUANZHUAN)
	}*/
}
public ckrun_create_item_temp(Float:origin[3],model[64],type,size,Float:vec[3])//round remove
{
	
	new supply = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!supply) return 0; //没创建成功的话..
					
	set_pev(supply, pev_origin, origin)
	set_pev(supply, pev_classname,CLASSNAME_SUPPLY[type])
			
	engfunc(EngFunc_SetModel, supply,model)
	engfunc(EngFunc_SetSize,supply,{-4.0, -4.0, -6.0},{4.0,4.0, 6.0})
	
	set_pev(supply,pev_body,size)
	
	set_pev(supply, pev_solid, SOLID_TRIGGER)
	set_pev(supply, pev_movetype, MOVETYPE_TOSS)
	
	set_pev(supply,pev_gravity,1.0)
	
	set_pev(supply,pev_temp,1)
	
	new Float:r[3]
	r[1]=random_float(0.0,360.0)
	set_pev(supply,pev_frame,random_float(0.0,180.0))
	set_pev(supply,pev_angles,r)
	
	set_pev(supply,pev_velocity,vec)
	
	tempsupply_status[supply][supplyorg_x]=floatround(origin[0])
	tempsupply_status[supply][supplyorg_y]=floatround(origin[1])
	tempsupply_status[supply][supplyorg_z]=floatround(origin[2])
	tempsupply_status[supply][supplytype]=type
	tempsupply_status[supply][supplysize]=size
	
	supply_ready[supply]=true
	//fm_set_rendering(supply)
	fm_set_entity_visible(supply,1)
	
	set_task(15.0,"remove",supply)
	
	return 1;
}
public ckrun_show_adminskill(id)
{
	new menu[512],len
	len=0
	
	len += formatex(menu[len],sizeof menu - len - 1,"\y%s[卡密的qxg技能] Studio Ing^n",MSG_CKR2)
	
	len += formatex(menu[len],sizeof menu - len - 1,"\r1.\w强制大暴击(100^% & 无视禁止)\w^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r2.\w最佳状态(重置玩家参数)\w^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r3.\w掏出一把枪(攻击附带减速效果)\w^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r4.\w开/关二段跳(侦察禁止)\w^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r5.\w潜行吧!权限狗!(隐形)\w^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r6.\w神说你还不能死在这(无敌)\w^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r7.\w开/关@穿墙术\w^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r8.\wASSASSIN\w^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r9.\wOP大杀器(破坏平衡的存在)\w^n^n")
	
	len += formatex(menu[len],sizeof menu - len - 1,"\r0.\w退出")
	
	show_menu(id,ALLKEYS,menu,-1,"MENU ADMIN SKILL")
	
}
public ckrun_adminskill(id,key)
{
	key+=1
	
	switch(key)
	{
	
		case 1:
		{
			if(!must_critical[id])
			{
				must_critical[id]=true
				client_print(id,print_center,"无限制强制暴击状态 开启")
				
				return;
			}
			must_critical[id]=false
			client_print(id,print_center,"无限制制暴击状态 关闭")
		}
		case 2:
		{
			ckrun_reset_user_var(id)
			ckrun_give_user_health(id,10000,1)
			ckrun_give_user_bpammo_percent(id,10000)
			
			client_print(id,print_center,"你已经恢复到最佳状态 继续战斗吧!")
		}
		case 3:
		{
			new fuckyou = random_num(0,sizeof CSWEAPONCLASSNAME - 1)
			fm_give_item(id,CSWEAPONCLASSNAME[fuckyou])
			fm_give_item(id,CSWEAPONCLASSNAME[fuckyou])
			fm_give_item(id,CSWEAPONCLASSNAME[fuckyou])
			fm_give_item(id,CSWEAPONCLASSNAME[fuckyou])
			
			client_print(id,print_center,"@打枪")
		}
		case 4:
		{
			if(!giszm[id] && ghuman[id] == human_scout || giszm[id] && gzombie[id] == zombie_scout) return;
			
			if(!gsecjump_maxnum[id])
			{
				gsecjump_maxnum[id]++
				client_print(id,print_center,"现在你可以多段跳了")
				return;
			}
			gsecjump_maxnum[id]=0
			client_print(id,print_center,"多段跳解除")
		}
		case 5:
		{
			if(pev(id,pev_rendermode)!=kRenderTransTexture)
			{
				set_pev(id,pev_rendermode,kRenderTransTexture)
				set_pev(id,pev_renderamt,0)
				client_print(id,print_center,"你隐形咯")
			}else{
				fm_set_rendering(id)
				client_print(id,print_center,"恢复显示")
			}
				
		}
		case 6:
		{
			if(spawn_godmodetime[id] < get_gametime())
			{
				spawn_godmodetime[id]=get_gametime()+9999.0
				client_print(id,print_center,"无敌了")
			}else{
				spawn_godmodetime[id]=get_gametime()
				client_print(id,print_center,"有敌了")
			}
					
		}
		case 7:
		{
			if(!get_user_noclip(id))
			{
				set_user_noclip(id,1)
				client_print(id,print_center,"穿墙中")
			}else{
				set_user_noclip(id,0)
				client_print(id,print_center,"关闭穿墙")
			}
		}
		case 8:
		{
			ghuman[id]=human_assassin
			gwillbehuman[id]=human_assassin
			ckrun_reset_user_var(id)
			ckrun_reset_user_weapon(id)
		}
		case 9:
		{
			if(g_gamemode == gamemode_vsasb)
				ckrun_set_user_boss(id)
			else if(g_gamemode == gamemode_zombie)
				ckrun_set_user_special(id)
		}
		case 10:
		{
			return;
		}
	}
	
}
public ckrun_show_personalmenu(id)
{
	new menu[512],len
	len=0
	
	len += formatex(menu[len],sizeof menu - len - 1,"\y%s[个人]^n^n",MSG_CKR2)
	
	len += formatex(menu[len],sizeof menu - len - 1,"\r1.\w账密\w^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r2.\w背包\w^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r3.\w装备\w^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r4.\w战绩\w^n^n^n^n")
	
	len += formatex(menu[len],sizeof menu - len - 1,"\r0.\w退出")
	
	show_menu(id,ALLKEYS,menu,-1,"MENU PERSONAL")
}
public ckrun_personalmenu(id,key)
{
	key++
	
	switch(key)
	{
		case 3:
		{
			ckrun_show_suitmenu(id)
		}
		case 10:
		{
			ckrun_show_mainmenu(id)
		}
		default:ckrun_show_personalmenu(id)
	}
	
	return PLUGIN_HANDLED
}
public ckrun_show_suitmenu(id)
{
	new menu[512],len
	len=0
	
	len += formatex(menu[len],sizeof menu - len - 1,"\y%s[装备]^n",MSG_CKR2)
	
	len += formatex(menu[len],sizeof menu - len - 1,"\r1.\w主武器\w^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r2.\w副武器\w^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r3.\w近战武器\w^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r4.\w帽子\w^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r5.\w装饰\w^n")
	
	len += formatex(menu[len],sizeof menu - len - 1,"\r0.\w退出")
	
	show_menu(id,(1<<0|1<<1|1<<2|1<<3|1<<4|1<<9),menu,-1,"MENU SUIT")

}
public ckrun_suitmenu(id,key)
{
	key++
	
	WeaponMenu_PlayerType[id]=ghuman[id]
	
	switch(key)
	{
		case 1:
		{
			WeaponMenu_PlayerChooseSuit[id]=1
			ckrun_show_priwpnmenu(id)
		}
		case 2:
		{
			WeaponMenu_PlayerChooseSuit[id]=2
			ckrun_show_secwpnmenu(id)
		}
		case 3:
		{
			WeaponMenu_PlayerChooseSuit[id]=3
			ckrun_show_knifewpnmenu(id)
		}
		case 4:
		{
			WeaponMenu_PlayerChooseSuit[id]=4
			ckrun_show_hatmenu(id)
		}
		case 5:
		{
			WeaponMenu_PlayerChooseSuit[id]=5
			ckrun_show_modelmenu(id)
		}
		case 10:
		{
			ckrun_show_personalmenu(id)
		}
		default:ckrun_show_suitmenu(id)
	}

	return PLUGIN_HANDLED;
}
/*
public ckrun_show_suitmenu_usertype(id)
{	

	new menu[512],len
	len=0
	
	len += formatex(menu[len],sizeof menu - len - 1,"\y%s[兵种] ^n",MSG_CKR2)
	
	for(new i = 1;i < sizeof MSG_humantype_name;i++)
	{
		len += formatex(menu[len],sizeof menu - len - 1,"\r%d.\w%s ^n",i,MSG_humantype_name[i])
	}
	
	len += formatex(menu[len],sizeof menu - len - 1,"^n\r0.\w退出")

	show_menu(id,ALLKEYS,menu,-1,"MENU SUIT USERTYPE")

}
public ckrun_suitmenu_usertype(id,key)
{
	key++
	if(key==10)
	{
		ckrun_show_suitmenu(id)
	}else{
		WeaponMenu_PlayerType[id]=key
		
		switch(WeaponMenu_PlayerChooseSuit[id])
		{
			case suit_primary:
			{
				ckrun_show_priwpnmenu(id)
			}
			case suit_secondry:
			{
				ckrun_show_secwpnmenu(id)
			}
			case suit_knife:
			{
				ckrun_show_knifewpnmenu(id)
			}
			case suit_hat:
			{
				ckrun_show_hatmenu(id)
			}
			case suit_model:
			{
				ckrun_show_modelmenu(id)
			}
		}
	}
	
	return PLUGIN_HANDLED;
}
*/



public ckrun_show_priwpnmenu(id)
{
	new menu[512],len
	len=0
	
	len += formatex(menu[len],sizeof menu - len - 1,"\y%s[主武器] ^n",MSG_CKR2)
	
	if(g_wpnitem_pri[id][WeaponMenu_PlayerType[id]]==-1)
	{
		len += formatex(menu[len],sizeof menu - len - 1,"[当前装备]\r%s\w^n",human_normal_priwpnname[WeaponMenu_PlayerType[id]])
	}else{
		len += formatex(menu[len],sizeof menu - len - 1,"[当前装备]\r%a\w^n",ArrayGetStringHandle(item_chinese_name,g_wpnitem_pri[id][WeaponMenu_PlayerType[id]]))
	}
	if(g_wpnitem_willpri[id][WeaponMenu_PlayerType[id]]==-1)
	{
		len += formatex(menu[len],sizeof menu - len - 1,"\y[下次装备]\r%s\w^n",human_normal_priwpnname[WeaponMenu_PlayerType[id]])
	}else{
		len += formatex(menu[len],sizeof menu - len - 1,"\y[下次装备]\r%a\w^n",ArrayGetStringHandle(item_chinese_name,g_wpnitem_willpri[id][WeaponMenu_PlayerType[id]]))
	}
	
	new gay = 0,bool:backpage=false,bool:nextpage=false
	for(new i = WeaponMenu_Pri_PlayerPage[WeaponMenu_PlayerType[id]][id]*7;i<register_prinum[WeaponMenu_PlayerType[id]];i++)
	{
		if(!nextpage)
		{
			gay++
			if(gay>7)
			{
				nextpage=true
			}else{
				len += formatex(menu[len],sizeof menu - len - 1,"\r%d.%s ^n",gay,WeaponMenu_Pri_WpnName[WeaponMenu_PlayerType[id]][i])
			}
		}
		
	}
	
	if(WeaponMenu_Pri_PlayerPage[WeaponMenu_PlayerType[id]][id]>0)
	{
		backpage=true
	}
	
	len += formatex(menu[len],sizeof menu - len - 1," ^n^n")
	if(backpage)
	{
		len += formatex(menu[len],sizeof menu - len - 1,"\r8.\w上一页^n")
	}
	if(nextpage)
	{
		len += formatex(menu[len],sizeof menu - len - 1,"\r9.\w下一页^n")
	}
	len += formatex(menu[len],sizeof menu - len - 1,"\r0.\w退出")
	
	
	switch(gay)
	{
		case 0:
		{
			show_menu(id,(1<<7|1<<8|1<<9),menu,-1,"MENU PRIWPN")
		}
		case 1:
		{
			show_menu(id,(1<<0|1<<7|1<<8|1<<9),menu,-1,"MENU PRIWPN")
		}
		case 2:
		{
			show_menu(id,(1<<0|1<<1|1<<7|1<<8|1<<9),menu,-1,"MENU PRIWPN")
		}
		case 3:
		{
			show_menu(id,(1<<0|1<<1|1<<2|1<<7|1<<8|1<<9),menu,-1,"MENU PRIWPN")
		}
		case 4:
		{
			show_menu(id,(1<<0|1<<1|1<<2|1<<3|1<<7|1<<8|1<<9),menu,-1,"MENU PRIWPN")
		}
		case 5:
		{
			show_menu(id,(1<<0|1<<1|1<<2|1<<3|1<<4|1<<7|1<<8|1<<9),menu,-1,"MENU PRIWPN")
		}
		case 6:
		{
			show_menu(id,(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<7|1<<8|1<<9),menu,-1,"MENU PRIWPN")
		}
		default:
		{
			show_menu(id,ALLKEYS,menu,-1,"MENU PRIWPN")
		}
	}
	
	return PLUGIN_CONTINUE;
}
public ckrun_priwpnmenu(id,key)
{
	switch(key)
	{
		case 7:
		{
			if(WeaponMenu_Pri_PlayerPage[WeaponMenu_PlayerType[id]][id]>0)
				WeaponMenu_Pri_PlayerPage[WeaponMenu_PlayerType[id]][id]--
			ckrun_show_priwpnmenu(id)
		}
		case 8:
		{
			WeaponMenu_Pri_PlayerPage[WeaponMenu_PlayerType[id]][id]++
			if(WeaponMenu_Pri_PlayerPage[WeaponMenu_PlayerType[id]][id]*7>=register_prinum[WeaponMenu_PlayerType[id]])
				WeaponMenu_Pri_PlayerPage[WeaponMenu_PlayerType[id]][id]--
			ckrun_show_priwpnmenu(id)
		}
		case 9:
		{
			ckrun_show_suitmenu(id)
		}
		default:
		{
			g_wpnitem_willpri[id][ghuman[id]]=WeaponMenu_Pri_WpnIndex[WeaponMenu_PlayerType[id]][WeaponMenu_Pri_PlayerPage[WeaponMenu_PlayerType[id]][id]*7+key]
			client_print(id,print_chat,"下次重生时你的主武器[%a]",ArrayGetStringHandle(item_chinese_name,g_wpnitem_willpri[id][ghuman[id]]))
			ckrun_show_priwpnmenu(id)
		}
	}
	
	return PLUGIN_HANDLED;
}
public ckrun_show_secwpnmenu(id)
{
	new menu[512],len
	len=0
	
	len += formatex(menu[len],sizeof menu - len - 1,"\y%s[副武器] ^n",MSG_CKR2)
	
	if(g_wpnitem_sec[id][WeaponMenu_PlayerType[id]]==-1)
	{
		len += formatex(menu[len],sizeof menu - len - 1,"[当前装备]\r%s\w^n",human_normal_secwpnname[WeaponMenu_PlayerType[id]])
	}else{
		len += formatex(menu[len],sizeof menu - len - 1,"[当前装备]\r%a\w^n",ArrayGetStringHandle(item_chinese_name,g_wpnitem_sec[id][WeaponMenu_PlayerType[id]]))
	}
	if(g_wpnitem_willsec[id][WeaponMenu_PlayerType[id]]==-1)
	{
		len += formatex(menu[len],sizeof menu - len - 1,"\y[下次装备]\r%s\w^n",human_normal_secwpnname[WeaponMenu_PlayerType[id]])
	}else{
		len += formatex(menu[len],sizeof menu - len - 1,"\y[下次装备]\r%a\w^n",ArrayGetStringHandle(item_chinese_name,g_wpnitem_willsec[id][WeaponMenu_PlayerType[id]]))
	}
	
	new gay = 0,bool:backpage=false,bool:nextpage=false
	for(new i = WeaponMenu_Sec_PlayerPage[WeaponMenu_PlayerType[id]][id]*7;i<register_secnum[WeaponMenu_PlayerType[id]];i++)
	{
		gay++
		if(gay>7)
		{
			nextpage=true
		}else{
			len += formatex(menu[len],sizeof menu - len - 1,"\r%d.%s ^n",gay,WeaponMenu_Sec_WpnName[WeaponMenu_PlayerType[id]][i])
		}
		
	}
	
	if(WeaponMenu_Sec_PlayerPage[WeaponMenu_PlayerType[id]][id]>0)
	{
		backpage=true
	}
	
	len += formatex(menu[len],sizeof menu - len - 1," ^n^n")
	if(backpage)
	{
		len += formatex(menu[len],sizeof menu - len - 1,"\r8.\w上一页^n")
	}
	if(nextpage)
	{
		len += formatex(menu[len],sizeof menu - len - 1,"\r9.\w下一页^n")
	}
	len += formatex(menu[len],sizeof menu - len - 1,"\r0.\w退出")
	
	
	switch(gay)
	{
		case 0:
		{
			show_menu(id,(1<<7|1<<8|1<<9),menu,-1,"MENU SECWPN")
		}
		case 1:
		{
			show_menu(id,(1<<0|1<<7|1<<8|1<<9),menu,-1,"MENU SECWPN")
		}
		case 2:
		{
			show_menu(id,(1<<0|1<<1|1<<7|1<<8|1<<9),menu,-1,"MENU SECWPN")
		}
		case 3:
		{
			show_menu(id,(1<<0|1<<1|1<<2|1<<7|1<<8|1<<9),menu,-1,"MENU SECWPN")
		}
		case 4:
		{
			show_menu(id,(1<<0|1<<1|1<<2|1<<3|1<<7|1<<8|1<<9),menu,-1,"MENU SECWPN")
		}
		case 5:
		{
			show_menu(id,(1<<0|1<<1|1<<2|1<<3|1<<4|1<<7|1<<8|1<<9),menu,-1,"MENU SECWPN")
		}
		case 6:
		{
			show_menu(id,(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<7|1<<8|1<<9),menu,-1,"MENU SECWPN")
		}
		default:
		{
			show_menu(id,ALLKEYS,menu,-1,"MENU SECWPN")
		}
	}
	
	return PLUGIN_CONTINUE;
}
public ckrun_secwpnmenu(id,key)
{
	switch(key)
	{
		case 7:
		{
			if(WeaponMenu_Sec_PlayerPage[WeaponMenu_PlayerType[id]][id]>0)
				WeaponMenu_Sec_PlayerPage[WeaponMenu_PlayerType[id]][id]--
			ckrun_show_secwpnmenu(id)
		}
		case 8:
		{
			WeaponMenu_Sec_PlayerPage[WeaponMenu_PlayerType[id]][id]++
			if(WeaponMenu_Sec_PlayerPage[WeaponMenu_PlayerType[id]][id]*7>=register_secnum[WeaponMenu_PlayerType[id]])
				WeaponMenu_Sec_PlayerPage[WeaponMenu_PlayerType[id]][id]--
			ckrun_show_secwpnmenu(id)
		}
		case 9:
		{
			ckrun_show_suitmenu(id)
		}
		default:
		{
			g_wpnitem_willsec[id][ghuman[id]]=WeaponMenu_Sec_WpnIndex[WeaponMenu_PlayerType[id]][WeaponMenu_Sec_PlayerPage[WeaponMenu_PlayerType[id]][id]*7+key]
			client_print(id,print_chat,"下次重生时你的副武器[%a]",ArrayGetStringHandle(item_chinese_name,g_wpnitem_willsec[id][ghuman[id]]))
			ckrun_show_secwpnmenu(id)
		}
	}
	
	return PLUGIN_HANDLED;
}
public ckrun_show_knifewpnmenu(id)
{
	new menu[512],len
	len=0
	
	len += formatex(menu[len],sizeof menu - len - 1,"\y%s[近战武器] ^n",MSG_CKR2)
	
	if(g_wpnitem_knife[id][WeaponMenu_PlayerType[id]]==-1)
	{
		len += formatex(menu[len],sizeof menu - len - 1,"[当前装备]\r%s\w^n",human_normal_knifewpnname[WeaponMenu_PlayerType[id]])
	}else{
		len += formatex(menu[len],sizeof menu - len - 1,"[当前装备]\r%s\w^n",ArrayGetStringHandle(item_chinese_name,g_wpnitem_knife[id][WeaponMenu_PlayerType[id]]))
	}
	if(g_wpnitem_willknife[id][WeaponMenu_PlayerType[id]]==-1)
	{
		len += formatex(menu[len],sizeof menu - len - 1,"\y[下次装备]\r%s\w^n",human_normal_knifewpnname[WeaponMenu_PlayerType[id]])
	}else{
		len += formatex(menu[len],sizeof menu - len - 1,"\y[下次装备]\r%s\w^n",ArrayGetStringHandle(item_chinese_name,g_wpnitem_willknife[id][WeaponMenu_PlayerType[id]]))
	}
	
	new gay = 0,bool:backpage=false,bool:nextpage=false
	for(new i = WeaponMenu_Knife_PlayerPage[WeaponMenu_PlayerType[id]][id]*7;i<register_knifenum[WeaponMenu_PlayerType[id]];i++)
	{
		gay++
		if(gay>7)
		{
			nextpage=true
		}else{
			len += formatex(menu[len],sizeof menu - len - 1,"\r%d.%s ^n",gay,WeaponMenu_Knife_WpnName[WeaponMenu_PlayerType[id]][i])
		}
		
	}
	
	if(WeaponMenu_Knife_PlayerPage[WeaponMenu_PlayerType[id]][id]>0)
	{
		backpage=true
	}
	
	len += formatex(menu[len],sizeof menu - len - 1," ^n^n")
	if(backpage)
	{
		len += formatex(menu[len],sizeof menu - len - 1,"\r8.\w上一页^n")
	}
	if(nextpage)
	{
		len += formatex(menu[len],sizeof menu - len - 1,"\r9.\w下一页^n")
	}
	len += formatex(menu[len],sizeof menu - len - 1,"\r0.\w退出")
	
	
	switch(gay)
	{
		case 0:
		{
			show_menu(id,(1<<7|1<<8|1<<9),menu,-1,"MENU KNIFEWPN")
		}
		case 1:
		{
			show_menu(id,(1<<0|1<<7|1<<8|1<<9),menu,-1,"MENU KNIFEWPN")
		}
		case 2:
		{
			show_menu(id,(1<<0|1<<1|1<<7|1<<8|1<<9),menu,-1,"MENU KNIFEWPN")
		}
		case 3:
		{
			show_menu(id,(1<<0|1<<1|1<<2|1<<7|1<<8|1<<9),menu,-1,"MENU KNIFEWPN")
		}
		case 4:
		{
			show_menu(id,(1<<0|1<<1|1<<2|1<<3|1<<7|1<<8|1<<9),menu,-1,"MENU KNIFEWPN")
		}
		case 5:
		{
			show_menu(id,(1<<0|1<<1|1<<2|1<<3|1<<4|1<<7|1<<8|1<<9),menu,-1,"MENU KNIFEWPN")
		}
		case 6:
		{
			show_menu(id,(1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<7|1<<8|1<<9),menu,-1,"MENU KNIFEWPN")
		}
		default:
		{
			show_menu(id,ALLKEYS,menu,-1,"MENU KNIFEWPN")
		}
	}
	
	return PLUGIN_CONTINUE;
	
}
public ckrun_knifewpnmenu(id,key)
{
	switch(key)
	{
		case 7:
		{
			if(WeaponMenu_Knife_PlayerPage[WeaponMenu_PlayerType[id]][id]>0)
				WeaponMenu_Knife_PlayerPage[WeaponMenu_PlayerType[id]][id]--
			ckrun_show_knifewpnmenu(id)
		}
		case 8:
		{
			WeaponMenu_Knife_PlayerPage[WeaponMenu_PlayerType[id]][id]++
			if(WeaponMenu_Knife_PlayerPage[WeaponMenu_PlayerType[id]][id]*7>=register_knifenum[WeaponMenu_PlayerType[id]])
				WeaponMenu_Knife_PlayerPage[WeaponMenu_PlayerType[id]][id]--
			ckrun_show_knifewpnmenu(id)
		}
		case 9:
		{
			ckrun_show_suitmenu(id)
		}
		default:
		{
			g_wpnitem_willknife[id][WeaponMenu_PlayerType[id]]=WeaponMenu_Knife_WpnIndex[WeaponMenu_PlayerType[id]][WeaponMenu_Knife_PlayerPage[WeaponMenu_PlayerType[id]][id]*7+key]
			client_print(id,print_chat,"下次重生时你的近战武器[%a]",ArrayGetStringHandle(item_chinese_name,g_wpnitem_willknife[id][WeaponMenu_PlayerType[id]]))
			ckrun_show_knifewpnmenu(id)
		}
	}
	
	return PLUGIN_HANDLED;
}
public ckrun_show_hatmenu(id)
{
	
	
}
public ckrun_show_modelmenu(id)
{
	
	
}

stock ckrun_get_teamplayernum()
{
	g_teamplayernum[team_no]=0
	g_teamplayernum[team_red]=0
	g_teamplayernum[team_blue]=0
	g_teamplayernum[team_spec]=0
	
	for(new i = 1;i<=g_maxplayer;i++)
	{
		if(pev_valid(i)  && is_user_connected(i))
			g_teamplayernum[gteam[i]]++
	}
}
stock ckrun_get_teamaliveplayernum()
{
	g_teamplayernum[team_no]=0
	g_teamplayernum[team_red]=0
	g_teamplayernum[team_blue]=0
	g_teamplayernum[team_spec]=0
	
	for(new i = 1;i<=g_maxplayer;i++)
	{
		if(pev_valid(i) && is_user_connected(i) && is_user_alive(i))
			g_teamplayernum[gteam[i]]++
	}
}
stock ckrun_get_teamhumantypenum(team)
{
	for(new i = 1;i < 11;i++)
	{
		g_teamhumantypenum[team][i]=0
	}
	
	for(new i = 1;i<=g_maxplayer;i++)
	{
		if(pev_valid(i)  && is_user_connected(i))
			g_teamhumantypenum[gteam[i]][ghuman[i]]++
	}
}
stock ckrun_get_teamzombietypenum()
{
	for(new i = 1;i < 10;i++)
	{
		g_teamzombietypenum[i]=0
	}
	
	for(new i = 1;i<=g_maxplayer;i++)
	{
		if(pev_valid(i) && is_user_connected(i))
			g_teamzombietypenum[gzombie[i]]++
	}
}
stock ckrun_get_bosstypenum()
{
	for(new i = 1;i < 10;i++)
	{
		g_teambosstypenum[i]=0
	}
	
	for(new i = 1;i<=g_maxplayer;i++)
	{
		if(pev_valid(i) && is_user_connected(i))
			g_teambosstypenum[gboss[i]]++
	}
}
stock ckrun_get_humannum()
{
	new num
	for(new i = 1;i<=g_maxplayer;i++)
	{
		if(pev_valid(i) && !giszm[i] && is_user_connected(i))
			num++
	}
	return num
}
stock ckrun_get_zombienum()
{
	new num
	for(new i = 1;i<=g_maxplayer;i++)
	{
		if(pev_valid(i) && giszm[i])
			num++
	}
	return num
}
stock ckrun_get_humannum_alive()
{
	new num
	for(new i = 1;i<=g_maxplayer;i++)
	{
		if(pev_valid(i) && !giszm[i] && is_user_alive(i) && is_user_connected(i))
			num++
	}
	return num
}
stock ckrun_get_zombienum_alive()
{
	new num
	for(new i = 1;i<=g_maxplayer;i++)
	{
		if(pev_valid(i) && giszm[i] && is_user_alive(i)  && is_user_connected(i))
			num++
	}
	return num
}
stock ckrun_get_playernum()
{
	new num
	for(new i = 1;i<=g_maxplayer;i++)
	{
		if(pev_valid(i) && is_user_connected(i))
			num++
	}
	return num
}
stock ckrun_get_playernum_alive()
{
	new num
	for(new i = 1;i<=g_maxplayer;i++)
	{
		if(pev_valid(i) && is_user_alive(i) && is_user_connected(i))
			num++
	}
	return num
}

public ckrun_show_buildmenu(id)//建造菜单
{
	new menu[512],len
	len=0
	
	len += formatex(menu[len],sizeof menu - len - 1,"\y--------[建造]-------- ^n^n")
	
	len += formatex(menu[len],sizeof menu - len - 1,"\r1.\w步哨枪  (需要金属:\r%d\w) ^n",130)
	len += formatex(menu[len],sizeof menu - len - 1,"\r2.\w补给器  (需要金属:\r%d\w) ^n",100)
	len += formatex(menu[len],sizeof menu - len - 1,"\r3.\w传送装置[入] (还没出)^n")//  (需要金属:\r%d\w) ^n",120)
	len += formatex(menu[len],sizeof menu - len - 1,"\r4.\w传送装置[出] (还没出)^n^n")//  (需要金属:\r%d\w) ^n^n",120)
	
	len += formatex(menu[len],sizeof menu - len - 1,"\r0.\w返回")
	
	show_menu(id,(1<<0|1<<1|1<<9),menu,-1,"MENU BUILD")
	NextCould_CurWeapon_Time[id]=get_gametime()+999.0
}
public ckrun_buildmenu(id,key)
{
	
	
	key+=1
	switch(key)
	{
		case 1:
		{
			if(player_sentrystatus[id][sentry_id]>0 || gmetalnum[id]<130) return 0;
			
			gmetalnum[id]-=130
			player_movebuilding[id]=build_sentry
			
			set_pev(id,pev_viewmodel2,mdl_wpn_v_toolbox)
			NextCould_CurWeapon_Time[id]=get_gametime()+999.0
		}
		case 2:
		{
			if(player_dispenserstatus[id][dispenser_id]>0 || gmetalnum[id]<100) return 0;
			
			gmetalnum[id]-=100
			player_movebuilding[id]=build_dispenser
			
			set_pev(id,pev_viewmodel2,mdl_wpn_v_toolbox)
			NextCould_CurWeapon_Time[id]=get_gametime()+999.0
		}
		case 3:
		{
			
		}
		case 4:
		{
			
		}
		case 10:
		{
			engclient_cmd(id,"weapon_knife")
			NextCould_CurWeapon_Time[id]=get_gametime()
		}
	}
	
	
	return 1;
	
	
	
}
	
public ckrun_show_destroymenu(id)//摧毁菜单
{
	new menu[512],len
	len=0
	
	len += formatex(menu[len],sizeof menu - len - 1,"\y--------[摧毁]-------- ^n^n")
	
	len += formatex(menu[len],sizeof menu - len - 1,"\r1.\w步哨枪 ^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r2.\w补给器 ^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r3.\w传送装置[入] (还没出)^n")
	len += formatex(menu[len],sizeof menu - len - 1,"\r4.\w传送装置[出] (还没出)^n^n")
	
	len += formatex(menu[len],sizeof menu - len - 1,"\r0.\w返回")
	
	show_menu(id,(1<<0|1<<1|1<<9),menu,-1,"MENU DESTROY")
	
	NextCould_CurWeapon_Time[id]=get_gametime()+999.0
}
public ckrun_destroymenu(id,key)
{
	key++
	
	switch(key)
	{
		case 1:
		{
			ckrun_destroy_sentry(id,id)
		}
		case 2:
		{
			ckrun_destroy_dispenser(id,id)
		}
		case 3:
		{
			
		}
		case 4:
		{
			
		}
		case 10:
		{
			
		}
	}
	NextCould_CurWeapon_Time[id]=get_gametime()
	engclient_cmd(id,"lastinv")
}

public ckrun_show_disguisemenu(id)//伪装菜单
{
	new menu[512],len
	len=0
	
	len += formatex(menu[len],sizeof menu - len - 1,"\y--------[伪装]--------^n^n")
	
	new i
	for(i = 1;i < 10;i++)
	{
		len += formatex(menu[len],sizeof menu - len - 1,"\r%d.\w%s ^n",i,MSG_humantype_name[i])
	}
	
	len += formatex(menu[len],sizeof menu - len - 1," ^n")
	
	len += formatex(menu[len],sizeof menu - len - 1,"\r0.\w返回")
	
	show_menu(id,ALLKEYS,menu,-1,"MENU DISGUISE")
	
	NextCould_CurWeapon_Time[id]=get_gametime()+999.0
}
public ckrun_disguisemenu(id,key)
{
	key+=1
	
	switch(key)
	{
		case 10:
		{
			
		}
		default:
		{
			disguise_type[id]=key
			remove_task(id+TASK_DISGUISE)
			set_task(2.0,"func_disguise",id+TASK_DISGUISE)
			engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_disguise, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		}
	}
	
	engclient_cmd(id,"weapon_knife")
	NextCould_CurWeapon_Time[id]=get_gametime()
}



public ckrun_build_sentry(id,Float:BuildOrg[3])
{
	if(player_sentrystatus[id][sentry_id]>0) return 0;
	
	new Float:Angle[3]
	pev(id,pev_angles,Angle)
	Angle[0]=0.0
	
	new sentry = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!sentry) return 0; //没创建成功的话..
							
	set_pev(sentry, pev_angles, Angle)
	set_pev(sentry, pev_origin, BuildOrg)
	set_pev(sentry, pev_classname, "build_sentry")
							
	engfunc(EngFunc_SetModel, sentry,mdl_sentry_level1)
	engfunc(EngFunc_SetSize, sentry, {-16.0, -16.0, -26.0}, {16.0, 16.0, 26.0})
	
	new color
	if(gteam[id] == team_red) color = 1 | (1<<8)
	else if(gteam[id] == team_blue) color = 135 | (135<<8)
	else color = 0 | (0<<8)
	set_pev(sentry, pev_colormap, color)
	
	set_pev(sentry, pev_solid, SOLID_SLIDEBOX)//180°瞬间转向BUG- -
	set_pev(sentry, pev_movetype, MOVETYPE_FLYMISSILE)
			
	set_pev(sentry, pev_controller_0, 0)
	set_pev(sentry, pev_controller_1, 0)
			
	set_pev(sentry, pev_owner, 0) //block line cross owner
	set_pev(sentry, pev_entowner, id)
			
	set_pev(sentry,pev_sequence,anim_sentrybuild)
			
	set_pev(sentry,pev_animtime, get_gametime())
	set_pev(sentry,pev_frame,0.0)
	set_pev(sentry,pev_framerate,1.0)
			
	set_pev(sentry, pev_fuser1,0.0)
	set_pev(sentry,pev_temp,0)
			
	fm_set_entity_visible(sentry,1)
			
	player_sentrystatus[id][sentry_id]=sentry
	player_sentrystatus[id][sentry_level]=1
	player_sentrystatus[id][sentry_levelnum]=0
	player_sentrystatus[id][sentry_maxlevelnum]=200
	player_sentrystatus[id][sentry_buildpercent]=0
	player_sentrystatus[id][sentry_startangle_leftright]=floatround(Angle[1])
	player_sentrystatus[id][sentry_controller0_num]=0
	player_sentrystatus[id][sentry_controller1_num]=0
	player_sentrystatus[id][sentry_health]=150
	player_sentrystatus[id][sentry_maxhealth]=150
	player_sentrystatus[id][sentry_ammo]=150
	player_sentrystatus[id][sentry_maxammo]=150
		
	engfunc(EngFunc_EmitSound,sentry, CHAN_STATIC, snd_build_deploy, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	return 1;
}
public ckrun_destroy_sentry(id,enemy)
{
	ExecuteForward(g_fwBuildingDestroy_Pre,g_fwResult,id,build_sentry,enemy)
	
	new sentry = player_sentrystatus[id][sentry_id]
	if(!sentry || !pev_valid(sentry)) return 0;
	
	new Float:sentryorg[3]
	pev(sentry,pev_origin,sentryorg)
	
	player_sentrystatus[id][sentry_id]=0
	player_sentrystatus[id][sentry_level]=0
	player_sentrystatus[id][sentry_levelnum]=0
	player_sentrystatus[id][sentry_maxlevelnum]=0
	player_sentrystatus[id][sentry_buildpercent]=0
	player_sentrystatus[id][sentry_startangle_leftright]=0
	player_sentrystatus[id][sentry_controller0_num]=0
	player_sentrystatus[id][sentry_controller1_num]=0
	player_sentrystatus[id][sentry_health]=0
	player_sentrystatus[id][sentry_maxhealth]=0
	player_sentrystatus[id][sentry_ammo]=0
	player_sentrystatus[id][sentry_maxammo]=0
	
	engfunc(EngFunc_RemoveEntity,sentry)
	
	
	func_papapa(0,id,0,15,sentryorg,128.0,50.0,0.1,300.0,CKRW_BUILDINGEXPLODE,0,1,0,0)
	
	ExecuteForward(g_fwBuildingDestroy_Post,g_fwResult,id,build_sentry,enemy)
	
	return 1;
}
public ckrun_build_dispenser(id,Float:BuildOrg[3])
{
	if(player_dispenserstatus[id][dispenser_id]>0) return 0;
	
	new Float:Angle[3]
	pev(id,pev_angles,Angle)
	Angle[0]=0.0
	
	new dispenser = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!dispenser) return 0; //没创建成功的话..
							
	set_pev(dispenser, pev_angles, Angle)
	set_pev(dispenser, pev_origin, BuildOrg)
	set_pev(dispenser, pev_classname, "build_dispenser")
							
	engfunc(EngFunc_SetModel,dispenser,mdl_dispenser)
	engfunc(EngFunc_SetSize, dispenser, {-16.0, -16.0, 0.0}, {16.0, 16.0, 42.0})
	
	new color
	if(gteam[id] == team_red) color = 1 | (1<<8)
	else if(gteam[id] == team_blue) color = 135 | (135<<8)
	else color = 0 | (0<<8)
	set_pev(dispenser, pev_colormap, color)
	
	set_pev(dispenser, pev_solid, SOLID_SLIDEBOX)
	set_pev(dispenser, pev_movetype, MOVETYPE_FLY)
			
	set_pev(dispenser, pev_owner, 0) //block line cross owner
	set_pev(dispenser, pev_entowner, id)
			
	set_pev(dispenser,pev_sequence,anim_dispenserbuild)
			
	set_pev(dispenser,pev_animtime, get_gametime())
	set_pev(dispenser,pev_frame,0.0)
	set_pev(dispenser,pev_framerate,1.0)
	set_pev(dispenser,pev_temp,0)
	
	fm_set_entity_visible(dispenser,1)
			
	player_dispenserstatus[id][dispenser_id]=dispenser
	player_dispenserstatus[id][dispenser_level]=1
	player_dispenserstatus[id][dispenser_levelnum]=0
	player_dispenserstatus[id][dispenser_maxlevelnum]=200
	player_dispenserstatus[id][dispenser_buildpercent]=0
	player_dispenserstatus[id][dispenser_health]=150
	player_dispenserstatus[id][dispenser_maxhealth]=150
	player_dispenserstatus[id][dispenser_ammo]=150
	player_dispenserstatus[id][dispenser_maxammo]=150
	
	engfunc(EngFunc_EmitSound,dispenser, CHAN_STATIC, snd_build_deploy, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	return 1;
}
public ckrun_destroy_dispenser(id,enemy)
{
	ExecuteForward(g_fwBuildingDestroy_Pre,g_fwResult,id,build_dispenser,enemy)
	
	new dispenser = player_dispenserstatus[id][dispenser_id]
	if(!dispenser || !pev_valid(dispenser)) return 0;
	
	new Float:dispenserorg[3]
	pev(dispenser,pev_origin,dispenserorg)
	
	player_dispenserstatus[id][dispenser_id]=0
	player_dispenserstatus[id][dispenser_level]=0
	player_dispenserstatus[id][dispenser_levelnum]=0
	player_dispenserstatus[id][dispenser_maxlevelnum]=0
	player_dispenserstatus[id][dispenser_buildpercent]=0
	player_dispenserstatus[id][dispenser_health]=0
	player_dispenserstatus[id][dispenser_maxhealth]=0
	player_dispenserstatus[id][dispenser_ammo]=0
	player_dispenserstatus[id][dispenser_maxammo]=0
	
	engfunc(EngFunc_RemoveEntity,dispenser)
	
	
	func_papapa(0,id,0,15,dispenserorg,128.0,50.0,0.1,300.0,CKRW_BUILDINGEXPLODE,0,1,0,0)
	
	ExecuteForward(g_fwBuildingDestroy_Post,g_fwResult,id,build_dispenser,enemy)
	
	return 1;
}

//-----------------------------------------------------------------------------//
//功能型事件
public ckrun_takedamage(id,enemy,damage,ckrwpnid,dmgtype,critnum,crittype,hidekillmsg,is_native)//杀死 返回1,否则返回0
{
	forward_change_num[1]=id
	forward_change_num[2]=enemy
	forward_change_num[3]=damage
	forward_change_num[4]=ckrwpnid
	forward_change_num[5]=dmgtype
	forward_change_num[6]=critnum
	forward_change_num[7]=crittype
	forward_change_num[8]=hidekillmsg
	forward_change_num[9]=is_native

	ExecuteForward(g_fwPlayerHurt_Pre,g_fwResult,id,enemy,damage,ckrwpnid,dmgtype,critnum,crittype,hidekillmsg,is_native)
	
	switch(g_fwResult)
	{
		case CKRFW_CHANGE:
		{
			id=forward_change_num[1]
			enemy=forward_change_num[2]
			damage=forward_change_num[3]
			ckrwpnid=forward_change_num[4]
			dmgtype=forward_change_num[5]
			critnum=forward_change_num[6]
			crittype=forward_change_num[7]
			hidekillmsg=forward_change_num[8]
			is_native=forward_change_num[9]
		}
		case CKRFW_RECOVER:
		{/*
			id
			enemy
			damage
			ckrwpnid
			dmgtype
			critnum
			crittype
			hidekillmsg
			is_native
		*/}
		case CKRFW_STOPRUN:
		{
			return 0;
		}
		default:
		{
			id=forward_change_num[1]
			enemy=forward_change_num[2]
			damage=forward_change_num[3]
			ckrwpnid=forward_change_num[4]
			dmgtype=forward_change_num[5]
			critnum=forward_change_num[6]
			crittype=forward_change_num[7]
			hidekillmsg=forward_change_num[8]
			is_native=forward_change_num[9]
		}
			
	}

	
	if(!id || !damage) return 0;
	if(0<id<=g_maxplayer)
		if(supercharge[bemedic[id]] || supercharge[id] || spawn_godmodetime[id]-get_gametime()>=0.0) return 0;
	
	new class[32]
	pev(id,pev_classname,class,31)
	
	new backnum,Float:nowtime=get_gametime()
	
	
	if(g_gamemode == gamemode_arena)
	{
		if(equali(class,"player"))
		{
			if(!is_user_alive(id)||pev(id,pev_health)<1.0) return 0
			if(gteam[id]==gteam[enemy]&&id!=enemy) return 0
		
			new gib=0,bool:cancrit,Float:health
			cancrit=true
			
			switch(dmgtype)
			{
				case CKRD_BULLET:
				{
					gib=0
					//damage=damage
					FX_Blood(id,1,12)
				}
				case CKRD_EXPLODE:
				{
					gib=2
					//damage=damage
					FX_Blood(id,1,15)
				}
				case CKRD_FIRE:
				{
					gib=0
					//damage=damage
					FX_Blood(id,1,8)
				}
				case CKRD_TOUCH:
				{
					gib=0
					//damage=damage
					FX_Blood(id,1,10)
				}
				case CKRD_MELEE:
				{
					gib=0
					//damage=damage
					FX_Blood(id,1,5)
				}
				case CKRD_FALL:
				{
					gib=0
					damage=damage*45/100
					FX_Blood(id,1,8)
					engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_pain[random_num(0,3)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
				case CKRD_CSWEAPON:
				{
					gib=0
					//damage=damage
				}
				case CKRD_OTHER:
				{
					gib=2
					//damage=damage
					FX_Blood(id,3,10)
					engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_pain[random_num(0,3)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
				default:gib=0
			}
			
			if(!crittype)
			{
				if(g_critical_on[enemy])
				{
					cancrit=true
					critnum=2
				}
			}
			
			if(critnum==-1)
			{
				cancrit=false
			}
			
			if(must_critical[enemy])
			{
				cancrit=true
				critnum=2
			}
			
			//new wpn[32]
			//ArrayGetString(item_chinese_name,ckrwpnid,wpn,31)
			
				
			if(enemy==id)
			{
				cancrit=false
			}
			
			new Float:idorg[3],Float:enemyorg[3]
			pev(id,pev_origin,idorg)
			pev(enemy,pev_origin,enemyorg)
			pev(id,pev_health,health)
			new Float:returnnum
			
			new iscrit
			if(critnum>=2&&cancrit)
			{
				iscrit=1
			}
			
			FX_Critical(enemy,id,critnum)
			
			if(id!=enemy)
			{
				if(lastattacker[id]!=enemy)
				{
					lastattacker_2[id]=lastattacker[id]
					lastattacker[id]=enemy
				}
				
			}
			remove_task(id+TASK_RESETLASTATTACK)
			set_task(10.0,"func_resetlastattack",id+TASK_RESETLASTATTACK)
			
			if(!cancrit)
			{
				returnnum = health-float(damage)
				if(returnnum>0.0)
				{
					set_pev(id,pev_health,returnnum)
					backnum=0
					
					if(nowtime - playerpain_checktime[id] >= 0.0)
					{
						playerpain_checktime[id]=nowtime+0.8
						
						if(id != Boss)
						{
							new r = random_num(0,1)
							if(!r)
								engfunc(EngFunc_EmitSound,id, CHAN_VOICE, snd_playerpain1[ghuman[id]], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
							else
								engfunc(EngFunc_EmitSound,id, CHAN_VOICE, snd_playerpain2[ghuman[id]], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						}
					}
				}else{
					//user_silentkill(id)
					ckrun_kill(id,enemy,ckrwpnid,dmgtype,critnum,gib)
					if(!hidekillmsg)
						ckrun_killmsg(enemy,id,ckrwpnid,iscrit,is_native)
					backnum=1
					
					if(id!=enemy)
					{
						g_roundscore[enemy]+=2
						g_allscore[enemy]+=2
						
						if(lastattacker_2[id]>0 && !bemedic[enemy])
						{
							g_roundscore[lastattacker_2[id]]+=1
							g_allscore[lastattacker_2[id]]+=1
							FX_UpdateScore(lastattacker_2[id])
						}
						else if(bemedic[enemy]>0)
						{
							g_roundscore[bemedic[enemy]]+=2
							g_allscore[bemedic[enemy]]+=2
							FX_UpdateScore(bemedic[enemy])
						}
						
						
						FX_UpdateScore(enemy)
					}
				}
				
				if(id!=enemy)
				{
					g_takedamage[enemy]+=damage
					g_roundtakedamage[enemy]+=damage
					g_alltakedamage[enemy]+=damage
					g_bedamage[id]+=damage
					g_roundbedamage[id]+=damage
					g_allbedamage[id]+=damage
				}
				
			}else{
				
				if(id!=enemy)
				{
					switch(critnum)
					{
						case 1:
						{
							damage=damage*get_pcvar_num(cvar_minicrit_mul)/100
						}
						case 2,3,4,5:
						{
							damage=damage*get_pcvar_num(cvar_crit_mul)/100
						}
						default:
						{
							damage=damage*get_pcvar_num(cvar_normal_mul)/100
						}
					}
				}
				returnnum = health-float(damage)
				if(returnnum>0.0)
				{
					set_pev(id,pev_health,returnnum)
					backnum=0
					
					if(nowtime - playerpain_checktime[id] >= 0.0)
					{
						playerpain_checktime[id]=nowtime+0.8
						
						if(id != Boss)
						{
							new r = random_num(0,1)
							if(!r)
								engfunc(EngFunc_EmitSound,id, CHAN_VOICE, snd_playerpain1[ghuman[id]], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
							else
								engfunc(EngFunc_EmitSound,id, CHAN_VOICE, snd_playerpain2[ghuman[id]], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						}
					}
				}else{
					ckrun_kill(id,enemy,ckrwpnid,dmgtype,critnum,gib)
					if(!hidekillmsg)
						ckrun_killmsg(enemy,id,ckrwpnid,iscrit,is_native)
					backnum=1
					
					if(id!=enemy)
					{
						g_roundscore[enemy]+=2
						g_allscore[enemy]+=2
						
						if(lastattacker_2[id]>0 && !bemedic[enemy])
						{
							g_roundscore[lastattacker_2[id]]+=1
							g_allscore[lastattacker_2[id]]+=1
							FX_UpdateScore(lastattacker_2[id])
						}
						else if(bemedic[enemy]>0)
						{
							g_roundscore[bemedic[enemy]]+=2
							g_allscore[bemedic[enemy]]+=2
							FX_UpdateScore(bemedic[enemy])
						}
						
						FX_UpdateScore(enemy)
					}
					
				}
				
				if(id!=enemy)
				{
					g_takedamage[enemy]+=damage
					g_roundtakedamage[enemy]+=damage
					g_alltakedamage[enemy]+=damage
					g_bedamage[id]+=damage
					g_roundbedamage[id]+=damage
					g_allbedamage[id]+=damage
				}
				
			}
			medic_callustimes[id]=0
			
			if(id != enemy)
				play_spk(enemy,snd_hitsound)
		}
		else if(equali(class,"build_sentry"))
		{
			damage=damage*75/100
			new sentryowner = pev(id,pev_entowner)
			if(gteam[sentryowner]==gteam[enemy]) return 0;
			
			
			new health=player_sentrystatus[sentryowner][sentry_health]
			
			if(health-damage<=0)
			{
				ckrun_destroy_sentry(sentryowner,enemy)
				ckrun_destroymsg(enemy,id,ckrwpnid,is_native)
				backnum=1
				
				g_roundscore[enemy]+=1
				g_allscore[enemy]+=1
				
				if(bemedic[enemy]>0)
				{
					g_roundscore[bemedic[enemy]]+=1
					g_allscore[bemedic[enemy]]+=1
					FX_UpdateScore(bemedic[enemy])
				}
				
				
				FX_UpdateScore(enemy)
			}else{
				player_sentrystatus[sentryowner][sentry_health]-=damage
				backnum=0
			}
			
			g_takedamage[enemy]+=damage
			g_roundtakedamage[enemy]+=damage
			g_alltakedamage[enemy]+=damage
			
			if(id != enemy)
				play_spk(enemy,snd_hitsound)
		}
		else if(equali(class,"build_dispenser"))
		{
			damage=damage*75/100
			new dispenserowner = pev(id,pev_entowner)
			if(gteam[dispenserowner]==gteam[enemy]) return 0;
			
			new health=player_dispenserstatus[dispenserowner][dispenser_health]
			
			if(health-damage<=0)
			{
				ckrun_destroy_dispenser(dispenserowner,enemy)
				ckrun_destroymsg(enemy,id,ckrwpnid,is_native)
				backnum=1
				
				g_roundscore[enemy]+=1
				g_allscore[enemy]+=1
				
				if(bemedic[enemy]>0)
				{
					g_roundscore[bemedic[enemy]]+=1
					g_allscore[bemedic[enemy]]+=1
					FX_UpdateScore(bemedic[enemy])
				}
				
				
				FX_UpdateScore(enemy)
			}else{
				player_dispenserstatus[dispenserowner][dispenser_health]-=damage
				backnum=0
			}
			
			g_takedamage[enemy]+=damage
			g_roundtakedamage[enemy]+=damage
			g_alltakedamage[enemy]+=damage
			
			if(id != enemy)
				play_spk(enemy,snd_hitsound)
		}
		else if(id>g_maxplayer)
		{
			ExecuteHamB(Ham_TakeDamage,id,0,enemy,float(damage),DMG_BULLET)
		}
	}
	else if(g_gamemode == gamemode_zombie)
	{
		if(equali(class,"player"))
		{
			if(!giszm[id] && !giszm[enemy] && id != enemy) return 0;
			if(giszm[id] && giszm[enemy] && id != enemy) return 0;
			
			if(!giszm[enemy] && giszm[id] || id == enemy)
			{
			
				new gib=0,bool:cancrit,Float:health
				cancrit=true
				
				switch(dmgtype)
				{
					case CKRD_BULLET:
					{
						gib=0
						//damage=damage
						FX_Blood(id,1,12)
					}
					case CKRD_EXPLODE:
					{
						gib=2
						//damage=damage
						FX_Blood(id,1,15)
					}
					case CKRD_FIRE:
					{
						gib=0
						//damage=damage
						FX_Blood(id,1,8)
					}
					case CKRD_TOUCH:
					{
						gib=0
						//damage=damage
						FX_Blood(id,1,10)
					}
					case CKRD_MELEE:
					{
						gib=0
						//damage=damage
						FX_Blood(id,1,5)
					}
					case CKRD_FALL:
					{
						gib=0
						damage=damage*45/100
						FX_Blood(id,1,8)
						engfunc(EngFunc_EmitSound,id, CHAN_VOICE, snd_pain[random_num(0,3)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
					case CKRD_CSWEAPON:
					{
						gib=0
						//damage=damage
					}
					case CKRD_OTHER:
					{
						gib=2
						//damage=damage
						FX_Blood(id,3,10)
						engfunc(EngFunc_EmitSound,id, CHAN_VOICE, snd_pain[random_num(0,3)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					}
					default:gib=0
				}
				
				if(!crittype)
				{
					if(g_critical_on[enemy])
					{
						cancrit=true
						critnum=2
					}
				}
				
				if(critnum==-1)
				{
					cancrit=false
				}
				
				if(must_critical[enemy] || g_roundstatus == round_end && lastwinteam == win_human || dmgtype == CKRD_MELEE && !giszm[enemy])
				{
					cancrit=true
					critnum+=2
				}
				
				//new wpn[32]
				//ArrayGetString(item_chinese_name,ckrwpnid,wpn,31)
				
					
				if(enemy==id)
				{
					cancrit=false
				}
				
				new Float:idorg[3],Float:enemyorg[3]
				pev(id,pev_origin,idorg)
				pev(enemy,pev_origin,enemyorg)
				pev(id,pev_health,health)
				new Float:returnnum
				
				new iscrit
				if(critnum>=2&&cancrit)
				{
					iscrit=1
				}
				
				FX_Critical(enemy,id,critnum)
				
				if(id!=enemy)
				{
					if(lastattacker[id]!=enemy)
					{
						lastattacker_2[id]=lastattacker[id]
						lastattacker[id]=enemy
					}
					
				}
				remove_task(id+TASK_RESETLASTATTACK)
				set_task(10.0,"func_resetlastattack",id+TASK_RESETLASTATTACK)
				
				if(!cancrit)
				{
					returnnum = health-float(damage)
					if(returnnum>0.0)
					{
						set_pev(id,pev_health,returnnum)
						backnum=0
						
						if(nowtime - playerpain_checktime[id] >= 0.0)
						{
							playerpain_checktime[id]=nowtime+0.8
							
							if(!giszm[id])
							{
								if(id != enemy)
								{
									new r = random_num(0,1)
									if(!r)
										engfunc(EngFunc_EmitSound,id, CHAN_VOICE, snd_playerpain1[ghuman[id]], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
									else
										engfunc(EngFunc_EmitSound,id, CHAN_VOICE, snd_playerpain2[ghuman[id]], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
								}
							}else{
								if(id != enemy)
								{
									new r = random_num(0,1)
									if(!r)
										engfunc(EngFunc_EmitSound,id, CHAN_VOICE, snd_playerpain1[gzombie[id]], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
									else
										engfunc(EngFunc_EmitSound,id, CHAN_VOICE, snd_playerpain2[gzombie[id]], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
								}
							}
						}
					}else{
						ckrun_kill(id,enemy,ckrwpnid,dmgtype,critnum,gib)
						if(!hidekillmsg)
							ckrun_killmsg(enemy,id,ckrwpnid,iscrit,is_native)
						backnum=1
						
						if(id!=enemy)
						{
							g_roundscore[enemy]+=3
							g_allscore[enemy]+=3
							
							if(lastattacker_2[id]>0 && !bemedic[enemy])
							{
								g_roundscore[lastattacker_2[id]]+=1
								g_allscore[lastattacker_2[id]]+=1
								FX_UpdateScore(lastattacker_2[id])
							}
							else if(bemedic[enemy]>0)
							{
								g_roundscore[bemedic[enemy]]+=2
								g_allscore[bemedic[enemy]]+=2
								FX_UpdateScore(bemedic[enemy])
							}
							
							FX_UpdateScore(enemy)
						}
					}
					
					if(id!=enemy)
					{
						g_takedamage[enemy]+=damage
						g_roundtakedamage[enemy]+=damage
						g_alltakedamage[enemy]+=damage
						g_bedamage[id]+=damage
						g_roundbedamage[id]+=damage
						g_allbedamage[id]+=damage
					}
					
				}else{
					
					if(id!=enemy)
					{
						switch(critnum)
						{
							case 1:
							{
								damage=damage*get_pcvar_num(cvar_minicrit_mul)/100
							}
							case 2,3,4,5:
							{
								damage=damage*get_pcvar_num(cvar_crit_mul)/100
							}
							default:
							{
								damage=damage*get_pcvar_num(cvar_normal_mul)/100
							}
						}
					}
					returnnum = health-float(damage)
					if(returnnum>0.0)
					{
						set_pev(id,pev_health,returnnum)
						backnum=0
						
						if(nowtime - playerpain_checktime[id] >= 0.0)
						{
							playerpain_checktime[id]=nowtime+0.8
							
							if(!giszm[id])
							{
								if(id != enemy)
								{
									new r = random_num(0,1)
									if(!r)
										engfunc(EngFunc_EmitSound,id, CHAN_VOICE, snd_playerpain1[ghuman[id]], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
									else
										engfunc(EngFunc_EmitSound,id, CHAN_VOICE, snd_playerpain2[ghuman[id]], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
								}
							}else{
								if(id != enemy)
								{
									new r = random_num(0,1)
									if(!r)
										engfunc(EngFunc_EmitSound,id, CHAN_VOICE, snd_playerpain1[gzombie[id]], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
									else
										engfunc(EngFunc_EmitSound,id, CHAN_VOICE, snd_playerpain2[gzombie[id]], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
								}
							}
						}
					}else{
						ckrun_kill(id,enemy,ckrwpnid,dmgtype,critnum,gib)
						if(!hidekillmsg)
							ckrun_killmsg(enemy,id,ckrwpnid,iscrit,is_native)
						backnum=1
						
						if(id!=enemy)
						{
							g_roundscore[enemy]+=3
							g_allscore[enemy]+=3
							
							if(lastattacker_2[id]>0 && !bemedic[enemy])
							{
								g_roundscore[lastattacker_2[id]]+=1
								g_allscore[lastattacker_2[id]]+=1
								FX_UpdateScore(lastattacker_2[id])
							}
							else if(bemedic[enemy]>0)
							{
								g_roundscore[bemedic[enemy]]+=2
								g_allscore[bemedic[enemy]]+=2
								FX_UpdateScore(bemedic[enemy])
							}
							
							FX_UpdateScore(enemy)
						}
					}
					
					
				}
				
				medic_callustimes[id]=0
				
				if(id!=enemy)
				{
					g_takedamage[enemy]+=damage
					g_roundtakedamage[enemy]+=damage
					g_alltakedamage[enemy]+=damage
					g_bedamage[id]+=damage
					g_roundbedamage[id]+=damage
					g_allbedamage[id]+=damage
				}
				
				if(id != enemy)
					play_spk(enemy,snd_hitsound)
			}
			else if(giszm[enemy] && !giszm[id])
			{
				if(dmgtype != CKRD_MELEE) return 0;
				
				if(id!=enemy)
				{
					if(lastattacker[id]!=enemy)
					{
						lastattacker_2[id]=lastattacker[id]
						lastattacker[id]=enemy
					}
					
				}
				remove_task(id+TASK_RESETLASTATTACK)
				set_task(10.0,"func_resetlastattack",id+TASK_RESETLASTATTACK)
				
				if(ghuman_armornum[id]>0)
				{
					ghuman_armornum[id]--
				}else{
					new hp = pev(id,pev_health)
					
					switch(gzombielevel[enemy])
					{
						case level_new:damage=damage*get_pcvar_num(cvar_zombie_lvnew_dmgmul_per)/100
						case level_old:damage=damage*get_pcvar_num(cvar_zombie_lvold_dmgmul_per)/100
						case level_strong:damage=damage*get_pcvar_num(cvar_zombie_lvstr_dmgmul_per)/100
						case level_super:damage=damage*get_pcvar_num(cvar_zombie_lvsup_dmgmul_per)/100
					}
					
					if(damage >= hp)//(hp < gmaxhealth[id]/2 || hp < 100 || damage >= hp)
					{
						ckrun_set_user_zombie(id)
						ckrun_ganranmsg(enemy,id,ckrwpnid,is_native)
						
						g_roundscore[enemy]++
						g_allscore[enemy]++
						
						gzombielevelnum[enemy]++
						switch(gzombielevel[enemy])
						{
							case level_new:
							{
								if(gzombielevelnum[enemy]>=3)
								{
									gzombielevel[enemy]++
									new Float:basehp = float(zombie_maxhealth[gzombie[enemy]])*get_pcvar_float(cvar_zombie_basehp_mul)*float(gzombielevel[enemy]*gzombielevel[enemy])
									gmaxhealth[enemy]=floatround(basehp)
									goverhealed[enemy]=gmaxhealth[enemy]*15/10
									gzombielevelnum[enemy]=0
									
									ckrun_give_user_health_percent(enemy,25)
								}
							}
							case level_old:
							{
								if(gzombielevelnum[enemy]>=4)
								{
									gzombielevel[enemy]++
									new Float:basehp = float(zombie_maxhealth[gzombie[enemy]])*get_pcvar_float(cvar_zombie_basehp_mul)*float(gzombielevel[enemy]*gzombielevel[enemy])
									gmaxhealth[enemy]=floatround(basehp)
									goverhealed[enemy]=gmaxhealth[enemy]*15/10
									gzombielevelnum[enemy]=0
									
									ckrun_give_user_health_percent(enemy,25)
								}
							}
							case level_strong:
							{
								if(gzombielevelnum[enemy]>=5)
								{
									gzombielevel[enemy]++
									new Float:basehp = float(zombie_maxhealth[gzombie[enemy]])*get_pcvar_float(cvar_zombie_basehp_mul)*float(gzombielevel[enemy]*gzombielevel[enemy])
									gmaxhealth[enemy]=floatround(basehp)
									goverhealed[enemy]=gmaxhealth[enemy]*15/10
									gzombielevelnum[enemy]=0
									
									ckrun_give_user_health_percent(enemy,25)
								}
							}
						}
						ckrun_give_user_health_percent(enemy,15)
						
						
						FX_UpdateScore(enemy)
						
						g_takedamage[enemy]+=damage
						g_roundtakedamage[enemy]+=damage
						g_alltakedamage[enemy]+=damage
						g_bedamage[id]+=damage
						g_roundbedamage[id]+=damage
						g_allbedamage[id]+=damage
						
						medic_callustimes[id]=0
						
						FX_Blood(id,3,6)
					}else{
						set_pev(id,pev_health,float(hp-damage))
						
						g_takedamage[enemy]+=damage
						g_roundtakedamage[enemy]+=damage
						g_alltakedamage[enemy]+=damage
						g_bedamage[id]+=damage
						g_roundbedamage[id]+=damage
						g_allbedamage[id]+=damage
						
						new r = random_num(0,1)
						if(!r)
							engfunc(EngFunc_EmitSound,id, CHAN_VOICE, snd_playerpain1[ghuman[id]], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						else
							engfunc(EngFunc_EmitSound,id, CHAN_VOICE, snd_playerpain2[ghuman[id]], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						
						FX_Blood(id,1,5)
					}
				}
			}
		}
		else if(equali(class,"build_sentry"))
		{
			damage=damage*100/100
			new sentryowner = pev(id,pev_entowner)
			if(!giszm[enemy]  && !giszm[sentryowner]) return 0;
			
			new health=player_sentrystatus[sentryowner][sentry_health]
			
			if(health-damage<=0)
			{
				ckrun_destroymsg(enemy,id,ckrwpnid,is_native)
				
				ckrun_destroy_sentry(sentryowner,enemy)
				backnum=1
				
				g_roundscore[enemy]+=1
				g_allscore[enemy]+=1
				
				FX_UpdateScore(enemy)
				
			}else{
				player_sentrystatus[sentryowner][sentry_health]-=damage
				backnum=0
			}
			
			g_takedamage[enemy]+=damage
			g_roundtakedamage[enemy]+=damage
			g_alltakedamage[enemy]+=damage
			
		}
		else if(equali(class,"build_dispenser"))
		{
			damage=damage*100/100
			new dispenserowner = pev(id,pev_entowner)
			if(!giszm[enemy]  && !giszm[dispenserowner]) return 0;
			
			new health=player_dispenserstatus[dispenserowner][dispenser_health]
			
			if(health-damage<=0)
			{
				ckrun_destroymsg(enemy,id,ckrwpnid,is_native)
				
				ckrun_destroy_dispenser(dispenserowner,enemy)
				backnum=1
				
				g_roundscore[enemy]+=1
				g_allscore[enemy]+=1
				
				FX_UpdateScore(enemy)
				
			}else{
				player_dispenserstatus[dispenserowner][dispenser_health]-=damage
				backnum=0
			}
			
			g_takedamage[enemy]+=damage
			g_roundtakedamage[enemy]+=damage
			g_alltakedamage[enemy]+=damage
			
		}
		else if(id>g_maxplayer)
		{
			ExecuteHamB(Ham_TakeDamage,id,0,enemy,float(damage),DMG_BULLET)
		}
	}
	else if(g_gamemode == gamemode_vsasb)
	{
		if(equali(class,"player"))
		{
			if(!is_user_alive(id)||pev(id,pev_health)<1.0) return 0
			if(Boss != id && Boss != enemy && id!=enemy) return 0
		
			new gib=0,bool:cancrit,iscrit,Float:health
			cancrit=true
			
			switch(dmgtype)
			{
				case CKRD_BULLET:
				{
					gib=0
					//damage=damage
					FX_Blood(id,1,12)
				}
				case CKRD_EXPLODE:
				{
					gib=2
					//damage=damage
					FX_Blood(id,1,15)
				}
				case CKRD_FIRE:
				{
					gib=0
					//damage=damage
					FX_Blood(id,1,8)
				}
				case CKRD_TOUCH:
				{
					gib=0
					//damage=damage
					FX_Blood(id,1,10)
				}
				case CKRD_MELEE:
				{
					gib=0
					//damage=damage
					FX_Blood(id,1,5)
				}
				case CKRD_FALL:
				{
					gib=0
					damage=damage*45/100
					FX_Blood(id,1,8)
					engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_pain[random_num(0,3)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
				case CKRD_CSWEAPON:
				{
					gib=0
					//damage=damage
				}
				case CKRD_OTHER:
				{
					gib=2
					//damage=damage
					FX_Blood(id,3,10)
					engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_pain[random_num(0,3)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				}
				default:gib=0
			}
			
			if(!crittype)
			{
				if(g_critical_on[enemy])
				{
					cancrit=true
					critnum=2
				}
			}
			
			if(critnum==-1)
			{
				cancrit=false
			}
			
			if(must_critical[enemy])
			{
				cancrit=true
				critnum=2
			}
			
			if(Boss == enemy)
			{
				cancrit=false
				if(gboss[Boss] != boss_scp173)
				{
					critnum=2
					iscrit=1
				}
				damage=damage*310/100
			}else{
				switch(ckrun_get_ckrwpnid_pritype(ckrwpnid,1))
				{
					case 2:
					{
						critnum++
					}
					case 3:
					{
						critnum+=2
					}
				}
			}
			
			//new wpn[32]
			//ArrayGetString(item_chinese_name,ckrwpnid,wpn,31)
			
				
			if(enemy==id)
			{
				cancrit=false
			}
			
			new Float:idorg[3],Float:enemyorg[3]
			pev(id,pev_origin,idorg)
			pev(enemy,pev_origin,enemyorg)
			pev(id,pev_health,health)
			new Float:returnnum
			
			if(critnum>=2&&cancrit)
			{
				iscrit=1
			}
			
			FX_Critical(enemy,id,critnum)
			
			if(id!=enemy)
			{
				if(lastattacker[id]!=enemy)
				{
					lastattacker_2[id]=lastattacker[id]
					lastattacker[id]=enemy
				}
				
			}
			remove_task(id+TASK_RESETLASTATTACK)
			set_task(10.0,"func_resetlastattack",id+TASK_RESETLASTATTACK)
			
			if(!cancrit)
			{
				returnnum = health-float(damage)
				if(returnnum>0.0)
				{
					set_pev(id,pev_health,returnnum)
					backnum=0
					
					if(nowtime - playerpain_checktime[id] >= 0.0)
					{
						playerpain_checktime[id]=nowtime+0.8
						
						if(id != Boss)
						{
							new r = random_num(0,1)
							if(!r)
								engfunc(EngFunc_EmitSound,id, CHAN_VOICE, snd_playerpain1[ghuman[id]], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
							else
								engfunc(EngFunc_EmitSound,id, CHAN_VOICE, snd_playerpain2[ghuman[id]], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						}
					}
				}else{
					//user_silentkill(id)
					ckrun_kill(id,enemy,ckrwpnid,dmgtype,critnum,gib)
					if(!hidekillmsg)
						ckrun_killmsg(enemy,id,ckrwpnid,iscrit,is_native)
					backnum=1
					
					if(id!=enemy)
					{
						g_roundscore[enemy]+=2
						g_allscore[enemy]+=2
						
						if(lastattacker_2[id]>0 && !bemedic[enemy])
						{
							g_roundscore[lastattacker_2[id]]+=1
							g_allscore[lastattacker_2[id]]+=1
							FX_UpdateScore(lastattacker_2[id])
						}
						else if(bemedic[enemy]>0)
						{
							g_roundscore[bemedic[enemy]]+=2
							g_allscore[bemedic[enemy]]+=2
							FX_UpdateScore(bemedic[enemy])
						}
						
						if(Boss==enemy && gboss[Boss]==boss_cbs)
						{
							Boss_changeknife++
							if(Boss_changeknife>2)
								Boss_changeknife=0
							Ham_WeaponCured(get_pdata_cbase(enemy,373),enemy)
							
						}
						
						FX_UpdateScore(enemy)
					}
				}
				
				if(id!=enemy)
				{
					g_takedamage[enemy]+=damage
					g_roundtakedamage[enemy]+=damage
					g_alltakedamage[enemy]+=damage
					g_bedamage[id]+=damage
					g_roundbedamage[id]+=damage
					g_allbedamage[id]+=damage
				}
				
				if(g_takedamage[enemy]>=500)
				{
					g_roundscore[enemy]++
					g_allscore[enemy]++
					
					
					FX_UpdateScore(enemy)
					
					g_takedamage[enemy]-=500
				}
				
			}else{
				
				if(id!=enemy)
				{
					switch(critnum)
					{
						case 1:
						{
							damage=damage*get_pcvar_num(cvar_minicrit_mul)/100
						}
						case 2,3,4,5:
						{
							damage=damage*get_pcvar_num(cvar_crit_mul)/100
						}
						default:
						{
							damage=damage*get_pcvar_num(cvar_normal_mul)/100
						}
					}
				}
				returnnum = health-float(damage)
				if(returnnum>0.0)
				{
					set_pev(id,pev_health,returnnum)
					backnum=0
					
					if(nowtime - playerpain_checktime[id] >= 0.0)
					{
						playerpain_checktime[id]=nowtime+0.8
						
						if(id != Boss)
						{
							new r = random_num(0,1)
							if(!r)
								engfunc(EngFunc_EmitSound,id, CHAN_VOICE, snd_playerpain1[ghuman[id]], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
							else
								engfunc(EngFunc_EmitSound,id, CHAN_VOICE, snd_playerpain2[ghuman[id]], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						}
					}
				}else{
					ckrun_kill(id,enemy,ckrwpnid,dmgtype,critnum,gib)
					if(!hidekillmsg)
						ckrun_killmsg(enemy,id,ckrwpnid,iscrit,is_native)
					backnum=1
					
					if(id!=enemy)
					{
						g_roundscore[enemy]+=2
						g_allscore[enemy]+=2
						
						if(lastattacker_2[id]>0 && !bemedic[enemy])
						{
							g_roundscore[lastattacker_2[id]]+=1
							g_allscore[lastattacker_2[id]]+=1
							FX_UpdateScore(lastattacker_2[id])
						}
						else if(bemedic[enemy]>0)
						{
							g_roundscore[bemedic[enemy]]+=2
							g_allscore[bemedic[enemy]]+=2
							FX_UpdateScore(bemedic[enemy])
						}
						
						if(Boss==enemy)
						{
							Boss_changeknife++
							if(Boss_changeknife>2)
								Boss_changeknife=0
							Ham_WeaponCured(get_pdata_cbase(enemy,373),enemy)
							
						}
						
						FX_UpdateScore(enemy)
					}
					
				}
				
				
			}
			
			medic_callustimes[id]=0
			
			if(id!=enemy)
			{
				g_takedamage[enemy]+=damage
				g_roundtakedamage[enemy]+=damage
				g_alltakedamage[enemy]+=damage
				g_bedamage[id]+=damage
				g_roundbedamage[id]+=damage
				g_allbedamage[id]+=damage
			}
			
			if(g_takedamage[enemy]>=500)
			{
				g_roundscore[enemy]++
				g_allscore[enemy]++
				
				
				FX_UpdateScore(enemy)
				
				g_takedamage[enemy]-=500
			}
			
			if(id != enemy)
				play_spk(enemy,snd_hitsound)
		}
		else if(equali(class,"build_sentry"))
		{
			damage=damage*100/100
			new sentryowner = pev(id,pev_entowner)
			if(Boss != id && Boss != enemy) return 0;
			if(Boss == enemy)
			{
				damage=damage*2
			}
			
			new health=player_sentrystatus[sentryowner][sentry_health]
			
			if(health-damage<=0)
			{
				ckrun_destroymsg(enemy,id,ckrwpnid,is_native)
				
				ckrun_destroy_sentry(sentryowner,enemy)
				backnum=1
				
				g_roundscore[enemy]+=1
				g_allscore[enemy]+=1
				
				if(bemedic[enemy]>0)
				{
					g_roundscore[bemedic[enemy]]+=1
					g_allscore[bemedic[enemy]]+=1
					FX_UpdateScore(bemedic[enemy])
				}
				
				
				FX_UpdateScore(enemy)
			}else{
				player_sentrystatus[sentryowner][sentry_health]-=damage
				backnum=0
			}
			
			g_takedamage[enemy]+=damage
			g_roundtakedamage[enemy]+=damage
			g_alltakedamage[enemy]+=damage
			
			if(id != enemy)
				play_spk(enemy,snd_hitsound)
		}
		else if(equali(class,"build_dispenser"))
		{
			damage=damage*100/100
			new dispenserowner = pev(id,pev_entowner)
			if(Boss != id && Boss != enemy) return 0;
			if(Boss == enemy)
			{
				damage=damage*2
			}
			
			new health=player_dispenserstatus[dispenserowner][dispenser_health]
			
			if(health-damage<=0)
			{
				ckrun_destroymsg(enemy,id,ckrwpnid,is_native)
				
				ckrun_destroy_dispenser(dispenserowner,enemy)
				backnum=1
				
				g_roundscore[enemy]+=1
				g_allscore[enemy]+=1
				
				if(bemedic[enemy]>0)
				{
					g_roundscore[bemedic[enemy]]+=1
					g_allscore[bemedic[enemy]]+=1
					FX_UpdateScore(bemedic[enemy])
				}
				
				
				FX_UpdateScore(enemy)
			}else{
				player_dispenserstatus[dispenserowner][dispenser_health]-=damage
				backnum=0
			}
			
			g_takedamage[enemy]+=damage
			g_roundtakedamage[enemy]+=damage
			g_alltakedamage[enemy]+=damage
			
			if(id != enemy)
				play_spk(enemy,snd_hitsound)
		}
		else if(id>g_maxplayer)
		{
			ExecuteHamB(Ham_TakeDamage,id,0,enemy,float(damage),DMG_BULLET)
		}
		
		if(Boss == id)
		{
			Boss_fuckpower+=damage
			if(Boss_fuckpower>Boss_maxfuckpower)
				Boss_fuckpower=Boss_maxfuckpower
				
			set_msg_armor(id,floatround((float(Boss_fuckpower)/float(Boss_maxfuckpower))*100.0))
		}
		
	}
	
	ExecuteForward(g_fwPlayerHurt_Post,g_fwResult,id,enemy,damage,ckrwpnid,dmgtype,critnum,crittype,hidekillmsg,is_native)
	
	return backnum
}
stock ckrun_killmsg(killer,victim,ckrwpnid,crit,is_native)
{
	new wpnclassname[32]
	
	if(is_native)
	{
		ArrayGetString(item_chinese_name,ckrwpnid,wpnclassname,31)
	}else{
		if(ckrwpnid<=32)
			formatex(wpnclassname,sizeof wpnclassname - 1,"%s",MSG_CKRWPNNAME[ckrwpnid])
		else
			formatex(wpnclassname,sizeof wpnclassname - 1,"%s",MSG_CKRWPNNAME_2[ckrwpnid-33])
	}
	
	new kname[32],vname[32],medicname[32],helpattacker[32]
	get_user_name(killer,kname,31)
	get_user_name(victim,vname,31)
	
	new bool:helpmedic=false,bool:helpattack=false
	
	if(0<bemedic[killer]<=g_maxplayer)
	{
		get_user_name(bemedic[killer],medicname,31)
		helpmedic=true
	}
	if(0<lastattacker_2[victim]<=g_maxplayer)
	{
		get_user_name(lastattacker_2[victim],helpattacker,31)
		helpattack=true
	}
	
	
	new msg[256],len
	len=0
	
	if(equali(kname,vname))
	{
		len += formatex(msg[len],sizeof msg - len - 1,"%s 失手自尽了...",kname,wpnclassname,vname)
	}else{	
		if(crit>0)
		{
			len += formatex(msg[len],sizeof msg - len - 1,"(暴击)")
		}
		
		if(helpmedic)
		{
			len += formatex(msg[len],sizeof msg - len - 1,"%s+%s用 %s 消灭了%s",kname,medicname,wpnclassname,vname)
		}
		else if(helpattack)
		{
			if(equali(kname,helpattacker))
			{
				len += formatex(msg[len],sizeof msg - len - 1,"%s用 %s 消灭了%s",kname,wpnclassname,vname)
			}else{
				len += formatex(msg[len],sizeof msg - len - 1,"%s+%s用 %s 消灭了%s",kname,helpattacker,wpnclassname,vname)
			}
		}
		else
		{
			len += formatex(msg[len],sizeof msg - len - 1,"%s用 %s 消灭了%s",kname,wpnclassname,vname)
		}
	}
	
	ckrun_add_hudmsg_text(msg)
	func_update_hudmsg()
	
	
	/*message_begin(MSG_ALL,get_user_msgid("DeathMsg"),_,0)
	write_byte(killer)
	write_byte(victim)
	write_byte(crit)
	write_string(wpnclassname)
	message_end()*/
	
	
}
public ckrun_destroymsg(enemy,buildid,ckrwpnid,is_native)
{
	new wpnclassname[32]

	if(is_native)
	{
		ArrayGetString(item_chinese_name,ckrwpnid,wpnclassname,31)
	}else{
		formatex(wpnclassname,sizeof wpnclassname - 1,"%s",MSG_CKRWPNNAME[ckrwpnid])
	}
	
	new ename[32],medicname[32],ownername[32]
	get_user_name(enemy,ename,31)
	get_user_name(pev(buildid,pev_entowner),ownername,31)
	
	
	new bool:helpmedic=false
	
	if(0<bemedic[enemy]<=g_maxplayer)
	{
		get_user_name(bemedic[enemy],medicname,31)
		helpmedic=true
	}
	
	new msg[256],len
	len=0
	
	new class[32]
	pev(buildid,pev_classname,class,31)
	if(equali(class,"build_sentry"))
	{
		if(helpmedic)
		{
			len += formatex(msg[len],sizeof msg - len - 1,"%s+%s用 %s 摧毁了步哨枪(属于%s)",ename,medicname,wpnclassname,ownername)
		}else{
			len += formatex(msg[len],sizeof msg - len - 1,"%s用 %s 摧毁了步哨枪(属于%s)",ename,wpnclassname,ownername)
		}
	}
	else if(equali(class,"build_dispenser"))
	{
		if(helpmedic)
		{
			len += formatex(msg[len],sizeof msg - len - 1,"%s+%s用 %s 摧毁了补给器(属于%s)",ename,medicname,wpnclassname,ownername)
		}else{
			len += formatex(msg[len],sizeof msg - len - 1,"%s用 %s 摧毁了补给器(属于%s)",ename,wpnclassname,ownername)
		}
	}
	
	ckrun_add_hudmsg_text(msg)
	func_update_hudmsg()
	
}
public ckrun_ganranmsg(enemy,id,ckrwpnid,is_native)
{
	new wpnclassname[32]
	
	if(is_native)
	{
		ArrayGetString(item_chinese_name,ckrwpnid,wpnclassname,31)
	}else{
		formatex(wpnclassname,sizeof wpnclassname - 1,"%s",MSG_CKRWPNNAME[ckrwpnid])
	}
	
	new ename[32],idname[32]
	get_user_name(enemy,ename,31)
	get_user_name(id,idname,31)
	
	new msg[256],len
	len=0
	
	len += formatex(msg[len],sizeof msg - len - 1,"%s用 %s 感染了%s",ename,wpnclassname,idname)
	
	ckrun_add_hudmsg_text(msg)
	func_update_hudmsg()
}
public ckrun_removesappermsg(enemy,id,ckrwpnid,is_native)
{
	new wpnclassname[32]
	
	if(is_native)
	{
		ArrayGetString(item_chinese_name,ckrwpnid,wpnclassname,31)
	}else{
		formatex(wpnclassname,sizeof wpnclassname - 1,"%s",MSG_CKRWPNNAME[ckrwpnid])
	}
	
	new ename[32],idname[32]
	get_user_name(enemy,ename,31)
	get_user_name(id,idname,31)
	
	new msg[256],len
	len=0
	
	len += formatex(msg[len],sizeof msg - len - 1,"%s用 %s 拆除了电子工兵(属于%s)",ename,wpnclassname,idname)
	
	ckrun_add_hudmsg_text(msg)
	func_update_hudmsg()
}
public ckrun_repair_build(build,repairer,num)
{
	if(num>gmetalnum[repairer])
		num=gmetalnum[repairer]
	new shit = num
	
	new owner = pev(build,pev_entowner)
	if(g_gamemode == gamemode_arena)
	{
		if(gteam[repairer]!=gteam[owner]) return 0;
	}
	else if(g_gamemode == gamemode_zombie)
	{
		if(giszm[repairer]) return 0;
	}
	else if(g_gamemode == gamemode_vsasb)
	{
		if(repairer == Boss) return 0;
	}
	
	new class[32]
	pev(build,pev_classname,class,31)
	
	new sen_level,sen_health,sen_maxhealth,sen_ammo,sen_maxammo,sen_levelnum,sen_maxlevelnum
	sen_level=player_sentrystatus[owner][sentry_level]
	sen_health=player_sentrystatus[owner][sentry_health]
	sen_ammo=player_sentrystatus[owner][sentry_ammo]
	sen_levelnum=player_sentrystatus[owner][sentry_levelnum]
	sen_maxhealth=player_sentrystatus[owner][sentry_maxhealth]
	sen_maxammo=player_sentrystatus[owner][sentry_maxammo]
	sen_maxlevelnum=player_sentrystatus[owner][sentry_maxlevelnum]
	
	new dis_level,dis_health,dis_maxhealth,dis_ammo,dis_maxammo,dis_levelnum,dis_maxlevelnum
	dis_level=player_dispenserstatus[owner][dispenser_level]
	dis_health=player_dispenserstatus[owner][dispenser_health]
	dis_ammo=player_dispenserstatus[owner][dispenser_ammo]
	dis_levelnum=player_dispenserstatus[owner][dispenser_levelnum]
	dis_maxhealth=player_dispenserstatus[owner][dispenser_maxhealth]
	dis_maxammo=player_dispenserstatus[owner][dispenser_maxammo]
	dis_maxlevelnum=player_dispenserstatus[owner][dispenser_maxlevelnum]
	
	new Float:nowtime = get_gametime()
	
	
	if(equali(class,"build_sentry") && nowtime >  sentry_leveltime[owner] && player_sentrystatus[owner][sentry_buildpercent] >= 100)
	{
		if(sen_health < sen_maxhealth)
		{
			new metal = (num-(sen_maxhealth-sen_health)/4)
			if(metal<0)
			{
				metal = 0
				
				player_sentrystatus[owner][sentry_health]=sen_health+num*4
				num=metal
				
			}else{
				
				player_sentrystatus[owner][sentry_health]=sen_maxhealth
				num=metal
				
			}
		}
		else if(sen_ammo < sen_maxammo)
		{
			
			new metal = (num-(sen_maxammo-sen_ammo)/4)
			if(metal<0)
			{
				metal = 0
				
				player_sentrystatus[owner][sentry_ammo]=sen_ammo+num*4
				num=metal
				
			}else{
				
				player_sentrystatus[owner][sentry_ammo]=sen_maxammo
				num=metal
				
			}
			
			
		}
		else if(sen_levelnum < sen_maxlevelnum && sen_level < 3)
		{
			new fuck = num
			if(fuck>25)
				fuck = 25
			
			new metal = (fuck-(sen_maxlevelnum-sen_levelnum ))
			new addtolevelnum = metal
			
			if(sen_levelnum + fuck > sen_maxlevelnum)
			{
				player_sentrystatus[owner][sentry_levelnum]=sen_maxlevelnum
				num=num-fuck+metal
			}
			else if(sen_levelnum + fuck <= sen_maxlevelnum)
			{
				player_sentrystatus[owner][sentry_levelnum]=sen_maxlevelnum+addtolevelnum
				num=num-fuck
			}
		}
		
		
		
	}
	else if(equali(class,"build_dispenser") && nowtime >  dispenser_leveltime[owner] && player_dispenserstatus[owner][dispenser_buildpercent] >= 100)
	{
		
		if(dis_health < dis_maxhealth)
		{
			new metal = (num-(dis_maxhealth-dis_health)/4)
			if(metal<0)
			{
				metal = 0
				
				player_dispenserstatus[owner][dispenser_health]=dis_health+num*4
				num=metal
				
			}else{
				
				player_dispenserstatus[owner][dispenser_health]=dis_maxhealth
				num=metal
				
			}
		}
		else if(dis_levelnum < dis_maxlevelnum && dis_level < 3)
		{
			new fuck = num
			if(fuck>25)
				fuck = 25
			
			new metal = (fuck-(dis_maxlevelnum-dis_levelnum ))
			new addtolevelnum  = metal
				
			if(dis_levelnum + fuck > dis_maxlevelnum)
			{
				player_dispenserstatus[owner][dispenser_levelnum]=dis_maxlevelnum
				num=num-fuck+metal
			}
			else if(dis_levelnum + fuck <= dis_maxlevelnum)
			{
				player_dispenserstatus[owner][dispenser_levelnum]=dis_maxlevelnum+addtolevelnum
				num=num-fuck
			}
			
		}
	}
	
	gmetalnum[repairer]=gmetalnum[repairer]-shit+num
	
	return num;
	
	
}

public ckrun_add_hudmsg_text(const msg[])
{
	format(g_hudmsg_text1,sizeof g_hudmsg_text1 - 1,"%s",g_hudmsg_text2)
	format(g_hudmsg_text2,sizeof g_hudmsg_text2 - 1,"%s",g_hudmsg_text3)
	format(g_hudmsg_text3,sizeof g_hudmsg_text3 - 1,"%s",g_hudmsg_text4)
	format(g_hudmsg_text4,sizeof g_hudmsg_text1 - 1,"%s",g_hudmsg_text5)
	format(g_hudmsg_text5,sizeof g_hudmsg_text1 - 1,"%s",msg)
}

stock ckrun_get_weapon_slot(wpn){//返回对应武器槽
	new pri
	switch(wpn){
		case CSW_P228:		pri = 2
		case CSW_HEGRENADE:	pri = 4
		case CSW_XM1014:	pri = 1
		case CSW_C4:		pri = 5
		case CSW_MAC10:		pri = 1
		case CSW_AUG:		pri = 1
		case CSW_SMOKEGRENADE:	pri = 4
		case CSW_ELITE:		pri = 2
		case CSW_FIVESEVEN:	pri = 2
		case CSW_UMP45:		pri = 1
		case CSW_GALIL:		pri = 1
		case CSW_FAMAS:		pri = 1	
		case CSW_USP:		pri = 2
		case CSW_GLOCK18:	pri = 2
		case CSW_AWP:		pri = 1
		case CSW_MP5NAVY:	pri = 1
		case CSW_M249:		pri = 1
		case CSW_M3:		pri = 1
		case CSW_M4A1:		pri = 1	
		case CSW_TMP:		pri = 1
		case CSW_FLASHBANG:	pri = 4
		case CSW_DEAGLE:	pri = 2
		case CSW_SG552:		pri = 1
		case CSW_AK47:		pri = 1
		case CSW_KNIFE:		pri = 3
		case CSW_P90:		pri = 1
		default :		pri = 0
	}
	return pri
}
public ckrun_reset_user_weaponreload(id)
{
	remove_task(id+TASK_STARTRELOAD)
	remove_task(id+TASK_RELOADING)
	remove_task(id+TASK_ENDRELOAD)
	
	player_reloadstatus[id][reload_none]=true
	player_reloadstatus[id][reload_start]=false
	player_reloadstatus[id][reload_ing]=false
	player_reloadstatus[id][reload_end]=false
}

public ckrun_sapper_plant(planter)
{
	
	new ent,entowner,Float:startpoint[3],Float:endorg[3],Float:touchend[3],class[32],backnum
	ckrun_get_user_startpos(planter,0.0,0.0,0.0,startpoint)
	ckrun_get_user_startpos(planter,75.0,0.0,0.0,endorg)
	ent=fm_trace_line(planter,startpoint,endorg,touchend)
	pev(ent,pev_classname,class,31)
	entowner=pev(ent,pev_entowner)
	
	if(g_gamemode == gamemode_arena && gteam[planter]==gteam[entowner] || g_gamemode == gamemode_zombie && !giszm[planter] && !giszm[entowner] || g_gamemode == gamemode_vsasb && entowner != Boss) return 0;
	if(invisible_ing[planter] || invisible_ed[planter] || uninvisible_ing[planter]) return 0;
	
	
	if(equali(class,"build_sentry") && !build_insapper[entowner][build_sentry])
	{
		ExecuteForward(g_fwPutSapperInBuilding_pre,g_fwResult,planter,build_sentry,entowner)
		
		build_insapper[entowner][build_sentry]=true
		build_spapper_remove_percent[entowner][build_sentry]=0
		client_print(entowner,print_center,"[警告]你的步哨枪已被电子工兵入侵")
		engfunc(EngFunc_EmitSound,ent, CHAN_STATIC, snd_wpn_sapper_plant, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		engfunc(EngFunc_EmitSound,entowner, CHAN_VOICE, snd_wpn_sapped_warning, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		build_sapperowner[entowner][build_sentry]=planter
		backnum = 1;
		
		ExecuteForward(g_fwPutSapperInBuilding_post,g_fwResult,planter,build_sentry,entowner)
	}
	else if(equali(class,"build_dispenser") && !build_insapper[entowner][build_dispenser])
	{
		ExecuteForward(g_fwPutSapperInBuilding_pre,g_fwResult,planter,build_dispenser,entowner)
		
		build_insapper[entowner][build_dispenser]=true
		build_spapper_remove_percent[entowner][build_dispenser]=0
		client_print(entowner,print_center,"[警告]你的补给器已被电子工兵入侵")
		engfunc(EngFunc_EmitSound,ent, CHAN_STATIC, snd_wpn_sapper_plant, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		engfunc(EngFunc_EmitSound,entowner, CHAN_VOICE, snd_wpn_sapped_warning, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		build_sapperowner[entowner][build_dispenser]=planter
		backnum = 1;
		
		ExecuteForward(g_fwPutSapperInBuilding_post,g_fwResult,planter,build_dispenser,entowner)
	}
	else if(equali(class,"build_telein"))
	{
		
	}
	else if(equali(class,"build_teleout"))
	{
		
	}
	
	
	return backnum;
	
}
public ckrun_sapper_removed(repairer,whosebuild,whatbuild,addpercent,ckrwpnid,is_native)
{
	if(!build_insapper[whosebuild][whatbuild]) return 0;
	
	new nowpercent = build_spapper_remove_percent[whosebuild][whatbuild]
	if(nowpercent+addpercent>=100)
	{
		build_spapper_remove_percent[whosebuild][whatbuild]=100
		build_insapper[whosebuild][whatbuild]=false
		switch(whatbuild)
		{
			case build_sentry:
			{
				engfunc(EngFunc_EmitSound,player_sentrystatus[whosebuild][sentry_id], CHAN_STATIC, snd_wpn_sapper_removed, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			}
			case build_dispenser:
			{
				engfunc(EngFunc_EmitSound,player_dispenserstatus[whosebuild][dispenser_id], CHAN_STATIC, snd_wpn_sapper_removed, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			}
		}
		
		ckrun_removesappermsg(repairer,build_sapperowner[whosebuild][whatbuild],ckrwpnid,is_native)
		build_sapperowner[whosebuild][whatbuild]=0
		
		g_roundscore[repairer]++
		FX_UpdateScore(repairer)
		
	}else{
		build_spapper_remove_percent[whosebuild][whatbuild]+=addpercent
	}
	return 1;
}

//native & !native
public ckrun_give_user_health(id,num,overhealed)
{
	forward_change_num[1]=id
	forward_change_num[2]=num
	forward_change_num[3]=overhealed
	
	ExecuteForward(g_fwPlayerBeHealedNum_Pre,g_fwResult,id,num,overhealed)

	switch(g_fwResult)
	{
		case CKRFW_CHANGE:
		{
			id=forward_change_num[1]
			num=forward_change_num[2]
			overhealed=forward_change_num[3]
		}
		case CKRFW_RECOVER:
		{/*
			id
			num
			overhealed
		*/}
		case CKRFW_STOPRUN:
		{
			return 0;
		}
		default:
		{
			id=forward_change_num[1]
			num=forward_change_num[2]
			overhealed=forward_change_num[3]
		}
			
	}
	
	if(!is_user_alive(id)) return 0;
	
	
	new hp = pev(id,pev_health),backnum=0
	new addtohp=hp+num
	new overhealedmax = goverhealed[id]
	
	
	if(overhealed==0)
	{
		if(hp>=gmaxhealth[id]) return 0
		
		if(addtohp>gmaxhealth[id])
			addtohp=gmaxhealth[id]
	}
	
	
	if(hp<overhealedmax)
	{
		if(addtohp>=overhealedmax)
		{
			addtohp=overhealedmax
		}
		
		set_pev(id,pev_health,float(addtohp))
		backnum = 1
	}
	
	ExecuteForward(g_fwPlayerBeHealedNum_Post,g_fwResult,id,num,overhealed)
	
	return backnum
}
public ckrun_give_user_health_percent(id,percent)
{
	forward_change_num[1]=id
	forward_change_num[2]=percent
	
	ExecuteForward(g_fwPlayerBeHealedPer_Pre,g_fwResult,id,percent)

	switch(g_fwResult)
	{
		case CKRFW_CHANGE:
		{
			id=forward_change_num[1]
			percent=forward_change_num[2]
		}
		case CKRFW_RECOVER:
		{/*
			id
			percent
		*/}
		case CKRFW_STOPRUN:
		{
			return 0;
		}
		default:
		{
			id=forward_change_num[1]
			percent=forward_change_num[2]
		}
			
	}
	
	if(!is_user_alive(id)) return 0;
	
	new hp = pev(id,pev_health),backnum
	new maxhp = gmaxhealth[id]
	new addtohp = hp+(maxhp*percent/100)
	
	if(hp>=maxhp) return 0
	
	func_disfire(id,id)
	func_disbleed(id)
	
	
	if(addtohp>=maxhp)
	{
		set_pev(id,pev_health,float(maxhp))
		backnum = 1
	}else{
		set_pev(id,pev_health,float(addtohp))
		backnum = 1
	}
	
	ExecuteForward(g_fwPlayerBeHealedPer_Post,g_fwResult,id,percent)
	
	return backnum
	
}
public ckrun_give_user_bpammo_percent(id,num)
{
	forward_change_num[1]=id
	forward_change_num[2]=num
	
	ExecuteForward(g_fwPlayerAddAmmoPer_Pre,g_fwResult,id,num)

	switch(g_fwResult)
	{
		case CKRFW_CHANGE:
		{
			id=forward_change_num[1]
			num=forward_change_num[2]
		}
		case CKRFW_RECOVER:
		{/*
			id
			num
		*/}
		case CKRFW_STOPRUN:
		{
			return 0;
		}
		default:
		{
			id=forward_change_num[1]
			num=forward_change_num[2]
		}
			
	}
	
	if(!is_user_alive(id) || giszm[id] || Boss == id) return 0;
	
	new pri_ammo = gpri_bpammo[id]
	new pri_maxammo = gmaxpribpammo[id]
	new sec_ammo = gsec_bpammo[id]
	new sec_maxammo = gmaxsecbpammo[id]
	
	new addtopriammo = pri_maxammo*num/100
	new addtosecammo = sec_maxammo*num/100
	
	new nowent = get_pdata_cbase(id,373)
	if(!pev_valid(nowent)) return 0;
	
	
	
	new class[32],backnum=0
	pev(nowent,pev_classname,class,31)
	
	if(equali(class,"weapon_m3") || equali(class,"weapon_mp5navy"))
	{
		if(pri_maxammo>0&&pri_ammo<pri_maxammo)
		{
			if(pri_ammo+addtopriammo < pri_maxammo)
			{
				gpri_bpammo[id]+=addtopriammo
				ckrun_update_user_clip_ammo(id)
			}else{
				gpri_bpammo[id]=pri_maxammo
				ckrun_update_user_clip_ammo(id)
			}
			
			backnum=1
		}else{
			return backnum;
		}
		
		if(sec_maxammo>0&&sec_ammo<sec_maxammo)
		{
			if(sec_ammo+addtosecammo < sec_maxammo)
			{
				gsec_bpammo[id]+=addtosecammo
				ckrun_update_user_clip_ammo(id)
			}else{
				gsec_bpammo[id]=sec_maxammo
				ckrun_update_user_clip_ammo(id)
			}
		}
		
	}
	else if(equali(class,"weapon_p228") || equali(class,"weapon_deagle"))
	{
		if(sec_maxammo>0&&sec_ammo<sec_maxammo)
		{
			if(sec_ammo+addtosecammo < sec_maxammo)
			{
				gsec_bpammo[id]+=addtosecammo
				ckrun_update_user_clip_ammo(id)
			}else{
				gsec_bpammo[id]=sec_maxammo
				ckrun_update_user_clip_ammo(id)
			}
			
			backnum=1
		}else{
			return backnum;
		}
		
		if(pri_maxammo>0&&pri_ammo<pri_maxammo)
		{
			if(pri_ammo+addtopriammo < pri_maxammo)
			{
				gpri_bpammo[id]+=addtopriammo
				ckrun_update_user_clip_ammo(id)
			}else{
				gpri_bpammo[id]=pri_maxammo
				ckrun_update_user_clip_ammo(id)
			}
		}
		
	}else{
		return backnum;
	}
	
	ExecuteForward(g_fwPlayerAddAmmoPer_Post,g_fwResult,id,num)
	
	return backnum;
	
}
public ckrun_give_user_metal(id,num)
{
	forward_change_num[1]=id
	forward_change_num[2]=num
	
	ExecuteForward(g_fwPlayerAddMetalNum_Pre,g_fwResult,id,num)

	switch(g_fwResult)
	{
		case CKRFW_CHANGE:
		{
			id=forward_change_num[1]
			num=forward_change_num[2]
		}
		case CKRFW_RECOVER:
		{/*
			id
			num
		*/}
		case CKRFW_STOPRUN:
		{
			return 0;
		}
		default:
		{
			id=forward_change_num[1]
			num=forward_change_num[2]
		}
			
	}
	
	if(!is_user_alive(id) || giszm[id]) return 0;
	
	new backnum
	
	if(gmetalnum[id]<gmetalmaxnum[id])
	{
		gmetalnum[id]+=num
		if(gmetalnum[id]>gmetalmaxnum[id])
			gmetalnum[id]=gmetalmaxnum[id]
		
		backnum = 1
	}
	
	ExecuteForward(g_fwPlayerAddMetalNum_Post,g_fwResult,id,num)
	
	return backnum;
}
public ckrun_give_user_metal_percent(id,num)
{
	forward_change_num[1]=id
	forward_change_num[2]=num
	
	ExecuteForward(g_fwPlayerAddMetalPer_Pre,g_fwResult,id,num)

	switch(g_fwResult)
	{
		case CKRFW_CHANGE:
		{
			id=forward_change_num[1]
			num=forward_change_num[2]
		}
		case CKRFW_RECOVER:
		{/*
			id
			num
		*/}
		case CKRFW_STOPRUN:
		{
			return 0;
		}
		default:
		{
			id=forward_change_num[1]
			num=forward_change_num[2]
		}
			
	}
	
	if(!is_user_alive(id) || giszm[id]) return 0;
	
	new backnum
	
	if(gmetalnum[id]<gmetalmaxnum[id])
	{
		gmetalnum[id]+=gmetalmaxnum[id]*num/100
		if(gmetalnum[id]>gmetalmaxnum[id])
			gmetalnum[id]=gmetalmaxnum[id]
		
		backnum = 1
	}
	
	ExecuteForward(g_fwPlayerAddMetalPer_Post,g_fwResult,id,num)
	
	return backnum;
}




//native & !native



public ckrun_reset_user_weapon(id)
{
	if(!is_user_alive(id)) return;
	
	if(giszm[id])
	{
		/*ham_strip_weapon(id,"weapon_m3")
		ham_strip_weapon(id,"weapon_p228")
		ham_strip_weapon(id,"weapon_hegrenade")
		ham_strip_weapon(id,"weapon_c4")*/
		
		for(new i = 1;i<10;i++)
		{
			g_wpnitem_knife_zombie[id][i]=g_wpnitem_willknife_zombie[id][i]
		}
		
		if(g_wpnitem_knife_zombie[id][ghuman[id]]==-1)
		{
			if(gzombie[id] == zombie_spy)
			{
				fm_give_item(id,"weapon_p228")
				fm_give_item(id,"weapon_hegrenade")
			}				

			fm_give_item(id,"weapon_knife")
			
		}else{
			//ExecuteForward()
		}
		engclient_cmd(id,"weapon_knife")
		NextCould_CurWeapon_Time[id]=get_gametime()+999.0
		Ham_WeaponCured(get_pdata_cbase(id,373),id)
		
		return;
	}
	
	if(Boss==id)
	{
		ham_strip_weapon(id,"weapon_m3")
		ham_strip_weapon(id,"weapon_p228")
		ham_strip_weapon(id,"weapon_hegrenade")
		ham_strip_weapon(id,"weapon_c4")
		
		//NextCould_CurWeapon_Time[id]=get_gametime()+999.0
		fm_give_item(id,"weapon_knife")
		engclient_cmd(id,"weapon_knife")
		Ham_WeaponCured(get_pdata_cbase(id,373),id)
		
		
		return;
	}
	
	fm_strip_user_weapons(id)
	for(new i = 1;i<11;i++)
	{
		g_wpnitem_pri[id][i]=g_wpnitem_willpri[id][i]
		g_wpnitem_sec[id][i]=g_wpnitem_willsec[id][i]
		g_wpnitem_knife[id][i]=g_wpnitem_willknife[id][i]
	}
	
	new priwpnnum = g_wpnitem_pri[id][ghuman[id]]
	new secwpnnum = g_wpnitem_sec[id][ghuman[id]]
	new knifewpnnum = g_wpnitem_knife[id][ghuman[id]]
	
	
	new bool:is_classis_priwpn=true
	new bool:is_classis_secwpn=true
	new bool:is_classis_knifewpn=true
	
	if(priwpnnum>-1)
	{
		is_classis_priwpn=false
	}
	if(secwpnnum>-1)
	{
		is_classis_secwpn=false
	}
	if(knifewpnnum>-1)
	{
		is_classis_knifewpn=false
	}

	new bool:breaker=false
	
	if(is_classis_priwpn)
	{
		forward_change_num[1]=id
		forward_change_num[2]=-1

		ExecuteForward(g_fwGivePriWpn,g_fwResult,id,-1)
		
		switch(g_fwResult)
		{
			case CKRFW_CHANGE:
			{
				id=forward_change_num[1]
			}
			case CKRFW_RECOVER:
			{
				
			}
			case CKRFW_STOPRUN:
			{
				breaker=true
			}
			default:
			{
				id=forward_change_num[1]
			}
		}

		if(!breaker)
		{
			fm_give_item(id,"weapon_m3")
			gmaxpriclip[id]=human_normal_priwpnmaxclip[ghuman[id]]
			gmaxpribpammo[id]=human_normal_priwpnmaxbpammo[ghuman[id]]
		}
	}else{

		forward_change_num[1]=id
		forward_change_num[2]=priwpnnum

		ExecuteForward(g_fwGivePriWpn,g_fwResult,id,priwpnnum)
		
		switch(g_fwResult)
		{
			case CKRFW_CHANGE:
			{
				id=forward_change_num[1]
				priwpnnum=forward_change_num[2]
			}
			case CKRFW_RECOVER:
			{
				
			}
			case CKRFW_STOPRUN:
			{
				breaker=true
			}
			default:
			{
				id=forward_change_num[1]
				priwpnnum=forward_change_num[2]
			}
		}
		
		if(!breaker)
		{
			gmaxpriclip[id]=ArrayGetCell(item_wpnmaxclip,priwpnnum)
			gmaxpribpammo[id]=ArrayGetCell(item_wpnmaxammo,priwpnnum)
		}
	}

	breaker=false

	if(is_classis_secwpn)
	{
		forward_change_num[1]=id
		forward_change_num[2]=-1

		ExecuteForward(g_fwGiveSecWpn,g_fwResult,id,-1)
		
		switch(g_fwResult)
		{
			case CKRFW_CHANGE:
			{
				id=forward_change_num[1]
			}
			case CKRFW_RECOVER:
			{
				
			}
			case CKRFW_STOPRUN:
			{
				breaker=true
			}
			default:
			{
				id=forward_change_num[1]
			}
		}
		
		if(!breaker)
		{
			fm_give_item(id,"weapon_p228")
			gmaxsecclip[id]=human_normal_secwpnmaxclip[ghuman[id]]
			gmaxsecbpammo[id]=human_normal_secwpnmaxbpammo[ghuman[id]]
		}
	}else{
		forward_change_num[1]=id
		forward_change_num[2]=secwpnnum

		ExecuteForward(g_fwGiveSecWpn,g_fwResult,id,secwpnnum)
		
		switch(g_fwResult)
		{
			case CKRFW_CHANGE:
			{
				id=forward_change_num[1]
				secwpnnum=forward_change_num[2]
			}
			case CKRFW_RECOVER:
			{
				
			}
			case CKRFW_STOPRUN:
			{
				breaker=true
			}
			default:
			{
				id=forward_change_num[1]
				secwpnnum=forward_change_num[2]
			}
		}

		if(!breaker)
		{
			gmaxsecclip[id]=ArrayGetCell(item_wpnmaxclip,secwpnnum)
			gmaxsecbpammo[id]=ArrayGetCell(item_wpnmaxammo,secwpnnum)
		}
	}

	breaker=false

	if(is_classis_knifewpn)
	{
		forward_change_num[1]=id
		forward_change_num[2]=-1

		ExecuteForward(g_fwGiveKnifeWpn,g_fwResult,id,-1)
		
		switch(g_fwResult)
		{
			case CKRFW_CHANGE:
			{
				id=forward_change_num[1]
			}
			case CKRFW_RECOVER:
			{
				
			}
			case CKRFW_STOPRUN:
			{
				breaker=true
			}
			default:
			{
				id=forward_change_num[1]
			}
		}
		
		if(!breaker)
		{
			fm_give_item(id,"weapon_knife")
		}
	}else{
		forward_change_num[1]=id
		forward_change_num[2]=knifewpnnum

		ExecuteForward(g_fwGiveKnifeWpn,g_fwResult,id,knifewpnnum)
		
		switch(g_fwResult)
		{
			case CKRFW_CHANGE:
			{
				id=forward_change_num[1]
				secwpnnum=forward_change_num[2]
			}
			case CKRFW_RECOVER:
			{
				
			}
			case CKRFW_STOPRUN:
			{
				breaker=true
			}
			default:
			{
				id=forward_change_num[1]
				secwpnnum=forward_change_num[2]
			}
		}
	}
	
	//SLOT 1 CLIP ->
	gpri_clip[id]=gmaxpriclip[id]
	//SLOT 1 BPAMMO ->
	gpri_bpammo[id]=gmaxpribpammo[id]
	//SLOT 2 CLIP ->
	gsec_clip[id]=gmaxsecclip[id]
	//SLOT 2 BPAMMO ->
	gsec_bpammo[id]=gmaxsecbpammo[id]
	
	
	
	if(ghuman[id]==human_engineer)
	{
		fm_give_item(id,"weapon_hegrenade")
		fm_give_item(id,"weapon_c4")
	}
	if(ghuman[id]==human_spy)
	{
		fm_give_item(id,"weapon_hegrenade")
	}
	
	client_cmd(id,"weapon_m3")
	Ham_WeaponCured(get_pdata_cbase(id,373),id)
	
	
	minigun_downing[id]=false
	minigun_downed[id]=false
	minigun_uping[id]=false
	
	Speedmul_switch[id]=false
	Speedmul_value_percent[id]=100
	
}
public ckrun_reset_user_var(id)
{
	forward_change_num[1]=id

	ExecuteForward(g_fwResetVar_Pre,g_fwResult,id)

	switch(g_fwResult)
	{
		case CKRFW_CHANGE:
		{
			id=forward_change_num[1]
		}
		case CKRFW_RECOVER:
		{/*
			id
		*/}
		case CKRFW_STOPRUN:
		{
			return 0;
		}
		default:
		{
			id=forward_change_num[1]
		}
	}
	
	switch(g_gamemode)
	{
		case gamemode_arena:
		{
			gmaxhealth[id]=human_maxhealth[ghuman[id]]
			goverhealed[id]=human_overhealed[ghuman[id]]
			gcritical[id]=get_pcvar_num(cvar_crit_percent)
			gfactspeed[id]=human_maxspeed[ghuman[id]]
			
			if(gteam[id]==team_red)
			{
				engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "topcolor", "255")
				engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "bottomcolor", "255")
			}
			else if(gteam[id]==team_blue)
			{
				engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "topcolor", "135")
				engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "bottomcolor", "135")
			}
			
			format(gcurmodel[id],31,"%s",mdl_human[ghuman[id]])
			fm_set_user_model(id,gcurmodel[id])
		
			if(ghuman[id]==human_scout)
			{
				gsecjump_maxnum[id]=1
			}else{
				gsecjump_maxnum[id]=0
			}
		}
		case gamemode_zombie:
		{
			if(!giszm[id])
			{
				gmaxhealth[id]=human_maxhealth[ghuman[id]]
				goverhealed[id]=human_overhealed[ghuman[id]]
				gcritical[id]=get_pcvar_num(cvar_crit_percent)
				gfactspeed[id]=human_maxspeed[ghuman[id]]
				
				if(gteam[id]==team_red)
				{
					engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "topcolor", "255")
					engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "bottomcolor", "255")
				}
				else if(gteam[id]==team_blue)
				{
					engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "topcolor", "135")
					engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "bottomcolor", "135")
				}
				
				format(gcurmodel[id],31,"%s",mdl_human[ghuman[id]])
				fm_set_user_model(id,gcurmodel[id])
			
				if(ghuman[id]==human_scout)
				{
					gsecjump_maxnum[id]=1
				}else{
					gsecjump_maxnum[id]=0
				}
			}else{
				gmaxhealth[id]=zombie_maxhealth[gzombie[id]]
				goverhealed[id]=zombie_overhealed[gzombie[id]]
				gcritical[id]=0
				gfactspeed[id]=zombie_maxspeed[gzombie[id]]
				
				engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "topcolor", "0")
				engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "bottomcolor", "0")
				
				format(gcurmodel[id],31,"%s",mdl_zombie[gzombie[id]])
				fm_set_user_model(id,gcurmodel[id])
				
				if(gzombie[id]==zombie_scout)
				{
					gsecjump_maxnum[id]=1
				}else{
					gsecjump_maxnum[id]=0
				}
			}
		}
		case gamemode_vsasb:
		{
			if(Boss==id)
			{
				new playernum = ckrun_get_playernum_alive()
				if(playernum < 5)
				{
					playernum++
				}
				gmaxhealth[id]=(760+playernum)*(playernum-1)*random_num(100,125)/100
				goverhealed[id]=gmaxhealth[id]
				gcritical[id]=0
				gfactspeed[id]=boss_maxspeed[gboss[id]]
				
				engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "topcolor", "55")
				engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "bottomcolor", "55")
				
				
				format(gcurmodel[id],31,"%s",mdl_boss[gboss[id]])
				fm_set_user_model(id,gcurmodel[id])
				
				
				gsecjump_maxnum[id]=0
			}else{
				gmaxhealth[id]=human_maxhealth[ghuman[id]]
				goverhealed[id]=human_overhealed[ghuman[id]]
				gcritical[id]=get_pcvar_num(cvar_crit_percent)
				gfactspeed[id]=human_maxspeed[ghuman[id]]
				
				if(gteam[id]==team_red)
				{
					engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "topcolor", "255")
					engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "bottomcolor", "255")
				}
				else if(gteam[id]==team_blue)
				{
					engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "topcolor", "135")
					engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "bottomcolor", "135")
				}
				
				format(gcurmodel[id],31,"%s",mdl_human[ghuman[id]])
				fm_set_user_model(id,gcurmodel[id])
			
				if(ghuman[id]==human_scout)
				{
					gsecjump_maxnum[id]=1
				}else{
					gsecjump_maxnum[id]=0
				}
			}
				
		}
	}
	
	if(Boss==id)
	{
		new playernum = ckrun_get_playernum_alive()
		if(playernum < 5)
		{
			playernum++
		}
		gmaxhealth[id]=(760+playernum)*(playernum-1)*random_num(100,125)/100
		goverhealed[id]=gmaxhealth[id]
		gcritical[id]=0
		gfactspeed[id]=boss_maxspeed[gboss[id]]
				
		engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "topcolor", "55")
		engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "bottomcolor", "55")
				
				
		format(gcurmodel[id],31,"%s",mdl_boss[gboss[id]])
		fm_set_user_model(id,gcurmodel[id])
				
				
		gsecjump_maxnum[id]=0
	}
	
	set_pev(id,pev_health,float(gmaxhealth[id]))
	
	
	medictarget[id]=0
	bemedic[id]=0
	
	lastattacker[id]=0
	lastattacker_2[id]=0
	
	func_disfire(id,id)
	func_disbleed(id)
	
	stickylauncher_power[id]=0
	
	remove_task(id+TASK_CRITICAL)
	g_critical_on[id]=false
	func_critical(id)
	
	remove_task(id+TASK_SNIPERRELOAD)
	remove_task(id+TASK_SNIPEPOWER)
	sniperifle_power[id]=0
	set_fov(id,90)
	
	
	butterfly_backuping[id]=false
	butterfly_backuped[id]=false
	butterfly_backdownning[id]=false
	
	remove_task(id+TASK_UNINVISIBLE)
	remove_task(id+TASK_INVISIBLE)
	remove_task(id+TASK_SKILLDEALY)
	invisible_ing[id]=false
	invisible_ed[id]=false
	uninvisible_ing[id]=false
	skill_canuse[id]=true
	
	set_user_footsteps(id,0)
	
	must_critical[id]=false
	
	remove_task(id+TASK_KILLSPAWN)
	willspawn[id]=false
	spawn_second[id]=0
	client_print(id,print_center,"")
	
	remove_task(id+TASK_CALLMEDIC)
	cancallmedic[id]=true
	
	player_priwpnnextattacktime[id]=get_gametime()
	player_secwpnnextattacktime[id]=get_gametime()
	player_knifewpnnextattacktime[id]=get_gametime()
	
	player_reloadstatus[id][reload_none]=true
	player_reloadstatus[id][reload_start]=false
	player_reloadstatus[id][reload_ing]=false
	player_reloadstatus[id][reload_end]=false
	
	gmetalmaxnum[id]=200
	gmetalnum[id]=gmetalmaxnum[id]
	
	
	gstickymaxnum[id]=get_pcvar_num(cvar_wpn_stickylauncher_maxnum)
	ckrun_remove_user_stickybomb(id)
	
	player_timer[id]=get_gametime()
	medic_callustimes[id]=0
	
	NextCould_CurWeapon_Time[id]=get_gametime()
	NextCould_Jump_Time[id]=get_gametime()
	NextCould_Duck_Time[id]=get_gametime()
	infire[id]=false
	
	if(supercharge[id])
	{
		gchargepower[id]=0
		supercharge[id]=false
		engfunc(EngFunc_EmitSound,id, CHAN_STATIC, snd_wpn_medicgun_chargeoff, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	}
	engfunc(EngFunc_EmitSound,id, CHAN_WEAPON, snd_empty, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	engfunc(EngFunc_EmitSound,id, CHAN_VOICE, snd_empty, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	player_movebuilding[id]=false
	
	gchargepower[id]=0
	invisible_power[id]=MAX_INVISIBLE_POWER
	
	remove_task(id+TASK_DISGUISE)
	disguise[id]=false
	disguise_target[id]=0
	disguise_team[id]=0
	disguise_type[id]=0
	disguise_iszm[id]=false
	
	for(new i;i<5;i++)
	{
		build_insapper[id][i]=false
		build_spapper_remove_percent[id][i]=100
		build_sapperowner[id][i]=0
	}
	
	getpowertosuperjump[id]=99999.0
	
	player_zhayanchecktime[id]=get_gametime()+8.0
	
	switch(g_gamemode)
	{
		case gamemode_vsasb:
		{
			gchargepower[id]=floatround(float(MAX_CHARGEPOWER)*0.4)
		}
	}
	
	Speedmul_switch[id]=false
	Speedmul_value_percent[id]=100
	
	Attackspeedmul_switch[id][1]=false
	Attackspeedmul_value_percent[id][1]=100
	Attackspeedmul_switch[id][2]=false
	Attackspeedmul_value_percent[id][2]=100
	Attackspeedmul_switch[id][3]=false
	Attackspeedmul_value_percent[id][3]=100
	Reloadspeedmul_switch[id][1]=false
	Reloadspeedmul_value_percent[id][1]=100
	Reloadspeedmul_switch[id][2]=false
	Reloadspeedmul_value_percent[id][2]=100
	Reloadspeedmul_switch[id][3]=false
	Reloadspeedmul_value_percent[id][3]=100
	
	ExecuteForward(g_fwResetVar_Post,g_fwResult,id)
	
	return 1;
}
public ckrun_update_user_clip_ammo(id)
{
	new wpnent = get_pdata_cbase(id,373,5)
	
	if(!pev_valid(wpnent)) return 0;
	
	new update_priclip = gpri_clip[id]
	new update_pribpammo = gpri_bpammo[id]
	new update_secclip = gsec_clip[id]
	new update_secbpammo = gsec_bpammo[id]
	new wpnname[32]
	pev(wpnent,pev_classname,wpnname,31)
	
	if(equali(wpnname,"weapon_m3"))
	{
		set_pdata_int(wpnent,OFFSET_CLIPAMMO,update_priclip)
		set_pdata_int(id,OFFSET_M3_AMMO,update_pribpammo)
	}
	else if(equali(wpnname,"weapon_mp5navy"))
	{
		set_pdata_int(wpnent,OFFSET_CLIPAMMO,update_priclip)
		set_pdata_int(id,OFFSET_GLOCK_AMMO,update_pribpammo)
	}
	else if(equali(wpnname,"weapon_p228"))
	{
		set_pdata_int(wpnent,OFFSET_CLIPAMMO,update_secclip)
		set_pdata_int(id,OFFSET_P228_AMMO,update_secbpammo)
	}
	else if(equali(wpnname,"weapon_deagle"))
	{
		set_pdata_int(wpnent,OFFSET_CLIPAMMO,update_secclip)
		set_pdata_int(id,OFFSET_DEAGLE_AMMO,update_secbpammo)
	}
	
	
	return 1;
}
public fm_give_item(index, const item[]) 
{
	if (!equal(item, "weapon_", 7) && !equal(item, "ammo_", 5) && !equal(item, "item_", 5) && !equal(item, "tf_weapon_", 10))
		return 0
	
	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, item))
	if (!pev_valid(ent))
		return 0
	
	new Float:origin[3]
	pev(index, pev_origin, origin)
	set_pev(ent, pev_origin, origin)
	set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN)
	dllfunc(DLLFunc_Spawn, ent)
	
	new save = pev(ent, pev_solid)
	dllfunc(DLLFunc_Touch, ent, index)
	if (pev(ent, pev_solid) != save)
		return ent
	
	engfunc(EngFunc_RemoveEntity, ent)
	
	return -1
}
public get_entity_index(owner,entclassname[])
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
stock ham_strip_weapon(id, weapon[]){
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
stock bool:is_hull_default(Float:origin[3], const Float:BOUNDS){
	new Float:traceEnds[8][3], Float:traceHit[3], hitEnt
	traceEnds[0][0] = origin[0] - BOUNDS
	traceEnds[0][1] = origin[1] - BOUNDS
	traceEnds[0][2] = origin[2] 

	traceEnds[1][0] = origin[0] - BOUNDS
	traceEnds[1][1] = origin[1] - BOUNDS
	traceEnds[1][2] = origin[2] + BOUNDS

	traceEnds[2][0] = origin[0] + BOUNDS
	traceEnds[2][1] = origin[1] - BOUNDS
	traceEnds[2][2] = origin[2] + BOUNDS

	traceEnds[3][0] = origin[0] + BOUNDS
	traceEnds[3][1] = origin[1] - BOUNDS
	traceEnds[3][2] = origin[2] 

	traceEnds[4][0] = origin[0] - BOUNDS
	traceEnds[4][1] = origin[1] + BOUNDS
	traceEnds[4][2] = origin[2] 

	traceEnds[5][0] = origin[0] - BOUNDS
	traceEnds[5][1] = origin[1] + BOUNDS
	traceEnds[5][2] = origin[2] + BOUNDS

	traceEnds[6][0] = origin[0] + BOUNDS
	traceEnds[6][1] = origin[1] + BOUNDS
	traceEnds[6][2] = origin[2] 

	traceEnds[7][0] = origin[0] + BOUNDS
	traceEnds[7][1] = origin[1] + BOUNDS
	traceEnds[7][2] = origin[2] 

	new classname[32]
	
	for (new i = 0; i < 8; i++) {
		if (engfunc(EngFunc_PointContents,traceEnds[i]) != CONTENTS_EMPTY)
			return true

		hitEnt = fm_trace_line(0, origin, traceEnds[i], traceHit)
		pev(hitEnt,pev_classname,classname,31)
		if (equal(classname,"player") || equal(classname,"build_",6))
			return true
		for (new j = 0; j < 3; j++)
			if (traceEnds[i][j] != traceHit[j])
				return true
	}
	return false
}
public ckrun_knockback(id,enemy,Float:vec[3],is_native)
{
	forward_change_num[1]=id
	forward_change_num[2]=enemy
	forward_change_vectype[3]=vec
	
	ExecuteForward(g_fwPlayerKnockBack_Pre,g_fwResult,id,enemy,vec,is_native)

	switch(g_fwResult)
	{
		case CKRFW_CHANGE:
		{
			id=forward_change_num[1]
			enemy=forward_change_num[2]
			vec=forward_change_vectype[3]
		}
		case CKRFW_RECOVER:
		{/*
			id
			num
			overhealed
		*/}
		case CKRFW_STOPRUN:
		{
			return 0;
		}
		default:
		{
			id=forward_change_num[1]
			enemy=forward_change_num[2]
			vec=forward_change_vectype[3]
		}
			
	}
	
	if(id>g_maxplayer) return 0;
	if(vec[0]==0.0&&vec[1]==0.0&&vec[2]==0.0) return 0;
	if(g_gamemode == gamemode_arena && gteam[id]==gteam[enemy] && id!=enemy) return 0;
	if(g_gamemode == gamemode_zombie && giszm[id]==giszm[enemy] && id!=enemy) return 0;
	if(g_gamemode == gamemode_vsasb && Boss != id && id!=enemy) return 0;
	if(insuperjump[id] || supercharge[id] || supercharge[bemedic[id]]) return 0;
	if(!pev_valid(id) || !pev_valid(enemy)) return 0;
	if(ckrun_is_user_firstzombie(id))
	{
		vec[0]*=0.7
		vec[1]*=0.7
		vec[2]*=0.7
	}
	if(giszm[id])
	{
		vec[0]*=zombie_bullet_kb_mul[gzombie[id]]
		vec[1]*=zombie_bullet_kb_mul[gzombie[id]]
		vec[2]*=zombie_bullet_kb_mul[gzombie[id]]
	}
	
	if(enemy!=id && must_critical[enemy] || g_critical_on[enemy])
		xs_vec_mul_scalar(vec,2.5,vec)
	
	new Float:oldvec[3]
	pev(id,pev_velocity,oldvec)
	
	if(pev(id,pev_flags)&FL_ONGROUND)
	{
		oldvec[0]+=vec[0]
		oldvec[1]+=vec[1]
		oldvec[2]+=(vec[2]*0.8)
	}
	else
	{
		oldvec[0]+=(vec[0]*0.75)
		oldvec[1]+=(vec[1]*0.75)
		oldvec[2]+=(vec[2]*1.2)
	}
	
	
	
	set_pev(id,pev_velocity,oldvec)
	
	ExecuteForward(g_fwPlayerKnockBack_Post,g_fwResult,id,enemy,vec,is_native)
	
	return 1;
}
public ckrun_slowvelocity(id,enemy,Float:velocitymul,z,is_native)
{
	forward_change_num[1]=id
	forward_change_num[2]=enemy
	forward_change_float[3]=velocitymul
	forward_change_num[4]=z
	
	ExecuteForward(g_fwPlayerSlowVec_Pre,g_fwResult,id,enemy,velocitymul,z,is_native)

	switch(g_fwResult)
	{
		case CKRFW_CHANGE:
		{
			id=forward_change_num[1]
			enemy=forward_change_num[2]
			velocitymul=forward_change_float[3]
			z=forward_change_num[4]
		}
		case CKRFW_RECOVER:
		{/*
			id
			num
			overhealed
		*/}
		case CKRFW_STOPRUN:
		{
			return 0;
		}
		default:
		{
			id=forward_change_num[1]
			enemy=forward_change_num[2]
			velocitymul=forward_change_float[3]
			z=forward_change_num[4]
		}
			
	}
	
	if(g_gamemode == gamemode_arena && gteam[id]==gteam[enemy] && id!=enemy) return 0;
	if(g_gamemode == gamemode_zombie && giszm[id]==giszm[enemy] && id!=enemy) return 0;
	if(g_gamemode == gamemode_vsasb && Boss != id && id!=enemy) return 0;
	if(insuperjump[id] || supercharge[id] || supercharge[bemedic[id]]) return 0;
	if(!pev_valid(id) || !pev_valid(enemy)) return 0;
	if(id>g_maxplayer) return 0;
	
	new Float:oldvec[3]
	pev(id,pev_velocity,oldvec)
	
	oldvec[0]*=velocitymul
	oldvec[1]*=velocitymul
	if(z>0)
		oldvec[2]*=velocitymul
	
	set_pev(id,pev_velocity,oldvec)
	
	ExecuteForward(g_fwPlayerSlowVec_Post,g_fwResult,id,enemy,velocitymul,z,is_native)
	
	return 1;
}
public ckrun_knockback_explode(who,const Float:O_org[3],Float:force,is_native)
{
	forward_change_num[1]=who
	forward_change_vectype[2]=O_org
	forward_change_float[3]=force
	forward_change_num[4]=is_native
	
	ExecuteForward(g_fwPlayerExplode_Pre,g_fwResult,who,O_org,force,is_native)

	switch(g_fwResult)
	{
		case CKRFW_CHANGE:
		{
			who=forward_change_num[1]
			force=forward_change_float[3]
			is_native=forward_change_num[4]
		}
		case CKRFW_RECOVER:
		{/*
			id
			num
			overhealed
		*/}
		case CKRFW_STOPRUN:
		{
			return 0;
		}
		default:
		{
			who=forward_change_num[1]
			force=forward_change_float[3]
			is_native=forward_change_num[4]
		}
			
	}
	
	force*=0.85
	new flags = pev(who,pev_flags),backnum=0
	if(who>g_maxplayer) return 0
	
	if(flags&FL_DUCKING)
	{
		force*=1.2
	}
	
	if(ckrun_is_user_firstzombie(who) == who)
	{
		force*=0.7
	}
	if(giszm[who])
	{
		force*=zombie_explode_kb_mul[gzombie[who]]
	}
	
	new Float:who_org[3]
	pev(who,pev_origin,who_org)
	who_org[2]+=5.0
	new Float:oldvelocity[3]
	pev(who,pev_velocity,oldvelocity)
	
	new Float:x_zheng = 1.0
	new Float:y_zheng = 1.0
	new Float:z_zheng = 1.0
	
	new Float:x = (who_org[0]-O_org[0])
	new Float:y = (who_org[1]-O_org[1])
	new Float:z = (who_org[2]-O_org[2])
	
	if(force == 0.0) return 0
	
	
	if(is_user_alive(who))
	{
		if (x<0.0)
		{
			x*=-1.0
			x_zheng=-1.0
		}
		if (y<0.0)
		{
			y*=-1.0
			y_zheng=-1.0
		}
		if (z<0.0)
		{
			z*=-1.0
			z_zheng=-1.0
		}
		
		
		if (x>y&&x>z)
		{
			oldvelocity[0]+=force*x_zheng
			oldvelocity[1]+=((y/x)*force)*y_zheng
			oldvelocity[2]+=((z/x)*force)*z_zheng
		}
		else if (y>x&&y>z)
		{
			oldvelocity[0]+=((x/y)*force)*x_zheng
			oldvelocity[1]+=force*y_zheng
			oldvelocity[2]+=((z/y)*force)*z_zheng
		}
		else if (z>x&&z>y)
		{
			oldvelocity[0]+=((x/z)*force)*x_zheng
			oldvelocity[1]+=((y/z)*force)*y_zheng
			oldvelocity[2]+=force*z_zheng
		}//
		else if (x==y&&x>z)
		{
			oldvelocity[0]+=force*x_zheng
			oldvelocity[1]+=force*y_zheng
			oldvelocity[2]+=((z/x)*force)*z_zheng
		}
		else if (x==z&&x>y)
		{
			oldvelocity[0]+=force*x_zheng
			oldvelocity[1]+=((y/x)*force)*y_zheng
			oldvelocity[2]+=force*z_zheng
		}
		else if (y==z&&y>x)
		{
			oldvelocity[0]+=((x/y)*force)*x_zheng
			oldvelocity[1]+=force*y_zheng
			oldvelocity[2]+=force*z_zheng
		}//=====
		else if (x==y&&x==z)
		{
			oldvelocity[0]+=force*x_zheng
			oldvelocity[1]+=force*y_zheng
			oldvelocity[2]+=force*z_zheng
		}
		
		if(flags&FL_ONGROUND)
		{
			oldvelocity[0]*=1.25
			oldvelocity[1]*=1.25
		}
		
		set_pev(who,pev_velocity,oldvelocity)
		
		backnum=1
	}
	
	
	ExecuteForward(g_fwPlayerExplode_Post,g_fwResult,who,O_org,force,is_native)
	
	return backnum
	
}


//僵尸模式用
public ckrun_set_user_human(id)
{
	if(!is_user_alive(id)) return;
	
	giszm[id]=false
	ckrun_reset_user_var(id)
	ckrun_reset_user_weapon(id)
	
	
}
stock ckrun_is_user_hero(id)
{
	new bool:Result=false

	for(new i = 0; i < MAX_HUMANHERO;i++)
	{
		if(human_hero[i]==id)
		{
			Result=true
		}
	}
	
	return Result;
}
public ckrun_set_user_hero(id)
{
	if(giszm[id] || !is_user_alive(id)) return;
	
	human_hero[0]=id
}
stock ckrun_is_user_special(id)
{
	new bool:Result=false

	for(new i = 0; i < MAX_HUMANSPECIAL;i++)
	{
		if(human_special[i]==id)
		{
			Result=true
		}
	}
	
	return Result;
}
public ckrun_set_user_special(id)
{
	if(giszm[id] || !is_user_alive(id) || human_special[0]!=0) return;
	
	human_special[0]=id
	gmaxhealth[id]+=100
	goverhealed[id]+=100
	ckrun_give_user_health(id,100,0)
	gfactspeed[id]+=35
	gcritical[id]=get_pcvar_num(cvar_crit_percent)*2
	gmaxpriclip[id]=gmaxpriclip[id]*15/10
	gmaxpribpammo[id]=gmaxpribpammo[id]*15/10
	gmaxsecclip[id]=gmaxsecclip[id]*15/10
	gmaxsecbpammo[id]=gmaxsecbpammo[id]*15/10
	Attackspeedmul_switch[id][weapon_primary]=true
	Attackspeedmul_value_percent[id][weapon_primary]=135
	Attackspeedmul_switch[id][weapon_secondry]=true
	Attackspeedmul_value_percent[id][weapon_secondry]=135
	Attackspeedmul_switch[id][weapon_knife]=true
	Attackspeedmul_value_percent[id][weapon_knife]=135
	Reloadspeedmul_switch[id][weapon_primary]=true
	Reloadspeedmul_value_percent[id][weapon_primary]=135
	Reloadspeedmul_switch[id][weapon_secondry]=true
	Reloadspeedmul_value_percent[id][weapon_secondry]=135
	//Reloadspeedmul_switch[id][weapon_knife]=true
	//Reloadspeedmul_value_percent[id][weapon_knife]=135
	
	client_print(id,print_chat,"你成为了人类领袖,获得了强化！")
}

public ckrun_set_user_zombie(id)
{
	if(!is_user_alive(id)) return;
	
	engfunc(EngFunc_EmitSound,id, CHAN_VOICE, snd_zb_human_ah[ghuman[id]], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	fm_set_user_team(id,team_blue,0)
	
	giszm[id]=true
	ckrun_reset_user_var(id)

	new Float:basehp = float(pev(id,pev_health))*get_pcvar_float(cvar_zombie_basehp_mul)*float(gzombielevel[id])
	gmaxhealth[id]=floatround(basehp)
	goverhealed[id]=gmaxhealth[id]*15/10
	
	if(ckrun_is_user_firstzombie(id))
		set_pev(id,pev_health,basehp + float(get_pcvar_num(cvar_zombie_first_hm_num_addhp)*ckrun_get_humannum_alive()))
	else
		set_pev(id,pev_health,basehp)
	
	if(ckrun_get_humannum_alive()==1 && human_hero[0]==0)
	{
		for(new i = 1;i <= g_maxplayer;i++)
		{
			if(pev_valid(i))
			{
				if(!giszm[i])
				{
					 ckrun_set_user_hero(i)
					 play_mp3(i,snd_zb_thelasthumanbgm)
				}
					
			}
				
		}
	}
	ckrun_reset_user_weapon(id)
	ckrun_destroy_sentry(id,id)
	ckrun_destroy_dispenser(id,id)
	
	if(ckrun_is_user_hero(id)) 
		human_hero[0]=0
	if(ckrun_is_user_special(id)) 
		human_special[0]=0
	
}
stock ckrun_is_user_firstzombie(id)
{
	new bool:Result=false

	for(new i = 1; i < MAX_FIRSTZOMBIE+1;i++)
	{
		if(firstzombie[i]==id)
		{
			Result=true
		}
	}
	
	return Result;
}
//VS模式用
public ckrun_set_user_normal(id)
{
	if(!is_user_alive(id)) return;
	
	if(Boss==id)
		Boss=0
	
	ckrun_reset_user_var(id)
	ckrun_reset_user_weapon(id)
}
public ckrun_set_user_boss(id)
{
	if(!is_user_alive(id)) return;

	Boss=id
	
	fm_set_user_team(id,team_blue,0)
	
	ckrun_destroy_sentry(id,id)
	ckrun_destroy_dispenser(id,id)
	ckrun_reset_user_var(id)
	ckrun_reset_user_weapon(id)
}
//-----------------------------------------------------------------------------//
//注册相关
public plugin_natives()
{
	//register item
	register_native("ckrun_item_creat","_ckrun_item_creat",1)
	register_native("ckrun_created_item_engname","_ckrun_created_item_engname",1)
	register_native("ckrun_created_item_chiname","_ckrun_created_item_chiname",1)
	register_native("ckrun_created_item_type","_ckrun_created_item_type",1)
	register_native("ckrun_created_item_usertype","_ckrun_created_item_usertype",1)
	register_native("ckrun_created_item_weaponslot","_ckrun_created_item_weaponslot",1)
	register_native("ckrun_created_item_wpnmaxclip","_ckrun_created_item_wpnmaxclip",1)
	register_native("ckrun_created_item_wpnmaxammo","_ckrun_created_item_wpnmaxammo",1)
	
	register_native("ckrun_user_nowwpnid","_ckrun_user_nowwpnid",1)
	register_native("ckrun_user_lastwpnid","_ckrun_user_lastwpnid",1)
	register_native("ckrun_user_priwpnid","_ckrun_user_priwpnid",1)
	register_native("ckrun_user_secwpnid","_ckrun_user_secwpnid",1)
	register_native("ckrun_user_knifewpnid","_ckrun_user_knifewpnid",1)
	register_native("ckrun_user_willpriwpnid","_ckrun_user_willpriwpnid",1)
	register_native("ckrun_user_willsecwpnid","_ckrun_user_willsecwpnid",1)
	register_native("ckrun_user_willknifewpnid","_ckrun_user_willknifewpnid",1)
	
	register_native("ckrun_set_priwpn_clip","_ckrun_set_priwpn_clip",1)
	register_native("ckrun_get_priwpn_clip","_ckrun_get_priwpn_clip",1)
	register_native("ckrun_set_priwpn_ammo","_ckrun_set_priwpn_ammo",1)
	register_native("ckrun_get_priwpn_ammo","_ckrun_get_priwpn_ammo",1)
	register_native("ckrun_set_secwpn_clip","_ckrun_set_secwpn_clip",1)
	register_native("ckrun_get_secwpn_clip","_ckrun_get_secwpn_clip",1)
	register_native("ckrun_set_secwpn_ammo","_ckrun_set_secwpn_ammo",1)
	register_native("ckrun_get_secwpn_ammo","_ckrun_get_secwpn_ammo",1)
	register_native("ckrun_get_priwpn_maxclip","_ckrun_get_priwpn_maxclip",1)
	register_native("ckrun_get_priwpn_maxammo","_ckrun_get_priwpn_maxammo",1)
	register_native("ckrun_get_secwpn_maxclip","_ckrun_get_secwpn_maxclip",1)
	register_native("ckrun_get_secwpn_maxammo","_ckrun_get_secwpn_maxammo",1)
	
	register_native("ckrun_set_curtime","_ckrun_set_curtime_NT",1)
	register_native("ckrun_set_priwpn_nextatktime","_ckrun_set_priwpn_NAT",1)
	register_native("ckrun_set_secwpn_nextatktime","_ckrun_set_secwpn_NAT",1)
	register_native("ckrun_set_knifewpn_nextatktime","_ckrun_set_knifewpn_NAT",1)
	register_native("ckrun_get_priwpn_nextatktime","_ckrun_get_priwpn_NAT",1)//error
	register_native("ckrun_get_curtime","_ckrun_get_curtime_NT",1)//error
	register_native("ckrun_get_secwpn_nextatktime","_ckrun_get_secwpn_NAT",1)//error
	register_native("ckrun_get_knifewpn_nextatktime","_ckrun_get_knifewpn_NAT",1)//error
	
	register_native("ckrun_set_speedmul_switch","_ckrun_set_speedmul_switch",1)
	register_native("ckrun_set_speedmul_value_per","_ckrun_set_speedmul_value_per",1)
	register_native("ckrun_get_speedmul_switch","_ckrun_get_speedmul_switch",1)
	register_native("ckrun_get_speedmul_value_per","_ckrun_get_speedmul_value_per",1)
	
	
	register_native("ckrun_set_entity_status","_ckrun_set_entity_status",1)
	register_native("ckrun_get_entity_status","_ckrun_get_entity_status",1)
	//
	
	register_native("ckrun_get_gamemode","_ckrun_get_gamemode",1)
	
	register_native("ckrun_takedamage_native","_ckrun_takedamage_native",1)
	register_native("ckrun_break_killmsg","_ckrun_break_killmsg",1)
	
	register_native("ckrun_is_user_critical","_ckrun_is_user_critical",1)
	register_native("ckrun_set_user_randomcrit_num","_ckrun_set_user_randomcrit_num",1)
	register_native("ckrun_get_user_randomcrit_num","_ckrun_get_user_randomcrit_num",1)
	
	register_native("ckrun_get_user_humantype","_ckrun_get_user_humantype",1)
	register_native("ckrun_get_user_zombietype","_ckrun_get_user_zombietype",1)
	register_native("ckrun_is_user_zombie","_ckrun_is_user_zombie",1)
	register_native("ckrun_get_bossid","_ckrun_get_bossid",1)
	
	register_native("ckrun_get_user_team","_ckrun_get_user_team",1)
	
	
	register_native("ckrun_set_NC_curwpn_time","_ckrun_set_NCCWT",1)
	register_native("ckrun_set_NC_duck_time","_ckrun_set_NCDT",1)
	register_native("ckrun_set_NC_jump_time","_ckrun_set_NCJT",1)
	register_native("ckrun_get_NC_curwpn_time","_ckrun_get_NCCWT",1)
	register_native("ckrun_get_NC_duck_time","_ckrun_get_NCDT",1)
	register_native("ckrun_get_NC_jump_time","_ckrun_get_NCJT",1)
	
	register_native("ckrun_setfunc_knockback","_ckrun_setfunc_knockback",1)
	register_native("ckrun_setfunc_slowvec","_ckrun_setfunc_slowvec",1)
	register_native("ckrun_setfunc_explode","_ckrun_setfunc_explode",1)
	
	register_native("ckrun_setfunc_fire","_ckrun_setfunc_fire",1)
	register_native("ckrun_setfunc_disfire","_ckrun_setfunc_disfire",1)
	register_native("ckrun_getfunc_fire","_ckrun_getfunc_fire",1)
	
	register_native("ckrun_setfunc_givehealth_per","_ckrun_setfunc_givehealth_per",1)
	register_native("ckrun_setfunc_givehealth_num","_ckrun_setfunc_givehealth_num",1)
	register_native("ckrun_setfunc_giveammo_per","_ckrun_setfunc_giveammo_per",1)
	register_native("ckrun_setfunc_givemetal_per","_ckrun_setfunc_givemetal_per",1)
	register_native("ckrun_setfunc_givemetal_num","_ckrun_setfunc_givemetal_num",1)
	
	register_native("ckrun_setfunc_disguise","_ckrun_setfunc_disguise",1)
	register_native("ckrun_setfunc_undisguise","_ckrun_setfunc_undisguise",1)
	
	register_native("ckrun_set_user_maxhealth","_ckrun_set_user_maxhealth",1)
	register_native("ckrun_get_user_maxhealth","_ckrun_get_user_maxhealth",1)
	register_native("ckrun_set_user_overhealed","_ckrun_set_user_overhealed",1)
	register_native("ckrun_get_user_overhealed","_ckrun_get_user_overhealed",1)
	register_native("ckrun_set_user_maxspeed","_ckrun_set_user_maxspeed",1)
	register_native("ckrun_get_user_maxspeed","_ckrun_get_user_maxspeed",1)
	register_native("ckrun_set_user_maxsecjump","_ckrun_set_user_maxsecjump",1)
	register_native("ckrun_get_user_maxsecjump","_ckrun_get_user_maxsecjump",1)
	register_native("ckrun_set_user_atkspeed_switch","_ckrun_set_user_atkspeed_switch",1)
	register_native("ckrun_set_user_atkspeed","_ckrun_set_user_atkspeed",1)
	register_native("ckrun_get_user_atkspeed_switch","_ckrun_get_user_atkspeed_switch",1)
	register_native("ckrun_get_user_atkspeed","_ckrun_get_user_atkspeed",1)
	register_native("ckrun_set_user_rlspeed_switch","_ckrun_set_user_rlspeed_switch",1)
	register_native("ckrun_set_user_rlspeed","_ckrun_set_user_rlspeed",1)
	register_native("ckrun_get_user_rlspeed_switch","_ckrun_get_user_rlspeed_switch",1)
	register_native("ckrun_get_user_rlspeed","_ckrun_get_user_rlspeed",1)
	
	
	
	register_native("ckrun_set_pl_knifeattacking","_ckrun_set_pl_knifeattacking",1)
	register_native("ckrun_get_pl_knifeattacking","_ckrun_get_pl_knifeattacking",1)
	
	register_native("ckrun_playsequence","_ckrun_playsequence",1)

	//changeforward
	register_native("ckrun_set_forward_num","_ckrun_set_forward_num",1)
	register_native("ckrun_get_forward_num","_ckrun_get_forward_num",1)
	register_native("ckrun_set_forward_float","_ckrun_set_forward_float",1)
	register_native("ckrun_get_forward_float","_ckrun_get_forward_float",1)
	register_native("ckrun_set_forward_vectype","_ckrun_set_forward_vectype",1)
	register_native("ckrun_get_forward_vectype","_ckrun_get_forward_vectype",1)
	register_native("ckrun_set_forward_string","_ckrun_set_forward_string",1)
	register_native("ckrun_get_forward_string","_ckrun_get_forward_string",1)
}

public _ckrun_get_gamemode()
{
	return g_gamemode
}

public _ckrun_takedamage_native(id,enemy,damage,wpnid,dmgtype,critnum,crittype,hidekillmsg,isnative)
{
	return ckrun_takedamage(id,enemy,damage,wpnid,dmgtype,critnum,crittype,hidekillmsg,isnative)
}

public _ckrun_break_killmsg()
{
	func_update_hudmsg()
}

public _ckrun_is_user_critical(id)
{
	new backnum = 0
	if(g_critical_on[id])
	{
		backnum=1
	}
	if(must_critical[id])
	{
		backnum=2
	}
	
	return backnum
}
public _ckrun_set_user_randomcrit_num(id,num)
{
	gcritical[id]=num
	return 1;
}
public _ckrun_get_user_randomcrit_num(id)
	return gcritical[id]
public _ckrun_get_user_humantype(id)
{
	return ghuman[id]
}
public _ckrun_get_user_zombietype(id)
{
	return gzombie[id]
}
public _ckrun_is_user_zombie(id)
{
	return giszm[id]
}
public _ckrun_get_bossid()
{
	return Boss
}
public _ckrun_get_user_team(id)
{
	return gteam[id]
}

public _ckrun_set_NCCWT(id,Float:nexttime)
{
	NextCould_CurWeapon_Time[id]=nexttime
	
	return 1;
}
public _ckrun_set_NCDT(id,Float:nexttime)
{
	NextCould_Duck_Time[id]=nexttime
	
	return 1;
}
public _ckrun_set_NCJT(id,Float:nexttime)
{
	NextCould_Jump_Time[id]=nexttime
	
	return 1;
}
public _ckrun_get_NCCWT(id,Float:ret)
{
	ret=NextCould_CurWeapon_Time[id]
	return 1;
}
public _ckrun_get_NCDT(id,Float:ret)
{
	ret=NextCould_Duck_Time[id]
	return 1;
}
public _ckrun_get_NCJT(id,Float:ret)
{
	ret=NextCould_Jump_Time[id]
	return 1;
}

public _ckrun_set_speedmul_switch(id,bool:yesorno)
{
	Speedmul_switch[id]=yesorno
	return 1;
}
public _ckrun_set_speedmul_value_per(id,value)
{
	Speedmul_value_percent[id]=value
	return 1;
}
public _ckrun_get_speedmul_switch(id)
{
	return Speedmul_switch[id]
}
public _ckrun_get_speedmul_value_per(id)
{
	return Speedmul_value_percent[id]
}

public _ckrun_set_entity_status(Entityid,StatValue,value)
{
	Entity_Status[Entityid][StatValue]=value
	return 1;
}
public _ckrun_get_entity_status(Entityid,StatValue)
{
	return Entity_Status[Entityid][StatValue]
}

public _ckrun_setfunc_knockback(id,enemy,vx,vy,vz,is_native)
{
	new Float:vec2[3]
	vec2[0] = float(vx)
	vec2[1] = float(vy)
	vec2[2] = float(vz)
	return ckrun_knockback(id,enemy,vec2,is_native)
}
public _ckrun_setfunc_slowvec(id,enemy,velocitymul_per,zallow,is_native)
{
	return ckrun_slowvelocity(id,enemy,float(velocitymul_per)/100.0,zallow,is_native)
}
public _ckrun_setfunc_explode(id,ox,oy,oz,force,is_native)
{
	new Float:org[3]
	org[0] = float(ox)
	org[1] = float(oy)
	org[2] = float(oz)
	return ckrun_knockback_explode(id,org,float(force),is_native)
}

public _ckrun_setfunc_fire(id,enemy,ckrwid,dmg,times,is_native)
{
	return func_fire(id,enemy,ckrwid,dmg,times,is_native);
}
public _ckrun_setfunc_disfire(id,helper)
{
	return func_disfire(id,helper);
}
public _ckrun_getfunc_fire(who,ret_firer,ret_nowtimes)
{
	ret_firer=befire[who]
	ret_nowtimes=firedmg_times[who]
	
	return ret_firer;
}

public _ckrun_setfunc_givehealth_per(id,num)
	return ckrun_give_user_health_percent(id,num)

public _ckrun_setfunc_givehealth_num(id,num,overhealed)
	return ckrun_give_user_health(id,num,overhealed)

public _ckrun_setfunc_giveammo_per(id,num)
	return ckrun_give_user_bpammo_percent(id,num)

public _ckrun_setfunc_givemetal_per(id,num)
	return ckrun_give_user_metal_percent(id,num)

public _ckrun_setfunc_givemetal_num(id,num)
	return ckrun_give_user_metal(id,num)

public _ckrun_setfunc_disguise(id)
{
	return func_disguise(id)
}
public _ckrun_setfunc_undisguise(id)
{
	return func_undisguise(id)
}
	
public _ckrun_set_user_maxhealth(id,num)
{
	gmaxhealth[id]=num
	return 1;
}
public _ckrun_get_user_maxhealth(id)
{
	return gmaxhealth[id]
}
public _ckrun_set_user_overhealed(id,num)
{
	goverhealed[id]=num
	return 1;
}
public _ckrun_get_user_overhealed(id)
	return goverhealed[id]
public _ckrun_set_user_maxspeed(id,num)
{
	gfactspeed[id]=num
	return 1;
}
public _ckrun_get_user_maxspeed(id)
	return gfactspeed[id]

public _ckrun_set_user_maxsecjump(id,num)
{
	gsecjump_maxnum[id]=num
	return 1;
}
public _ckrun_get_user_maxsecjump(id)
	return gsecjump_maxnum[id]

public _ckrun_set_user_atkspeed_switch(id,wpn_type,num)
{
	if(num>=1)
		Attackspeedmul_switch[id][wpn_type]=true
	else
		Attackspeedmul_switch[id][wpn_type]=false
	return 1;
}
public _ckrun_set_user_atkspeed(id,wpn_type,per)
{
	Attackspeedmul_value_percent[id][wpn_type]=per
	
	return 1;
}
public _ckrun_get_user_atkspeed_switch(id,wpn_type)
{
	if(Attackspeedmul_switch[id][wpn_type])
		return 1
	else
		return 0;
	return -1
}
	
public _ckrun_get_user_atkspeed(id,wpn_type)
	return Attackspeedmul_value_percent[id][wpn_type]
	
public _ckrun_set_user_rlspeed_switch(id,wpn_type,num)
{
	if(num>=1)
		Reloadspeedmul_switch[id][wpn_type]=true
	else
		Reloadspeedmul_switch[id][wpn_type]=false
	return 1;
}
public _ckrun_set_user_rlspeed(id,wpn_type,per)
{
	Reloadspeedmul_value_percent[id][wpn_type]=per
	
	return 1;
}
public _ckrun_get_user_rlspeed_switch(id,wpn_type)
{
	if(Reloadspeedmul_switch[id][wpn_type])
		return 1
	else
		return 0;
	return -1
}
	
public _ckrun_get_user_rlspeed(id,wpn_type)
	return Reloadspeedmul_value_percent[id][wpn_type]
	


public _ckrun_set_pl_knifeattacking(id,yesorno)
{
	if(yesorno==1)
		knifeattacking[id]=true
	else
		knifeattacking[id]=false
	return 1;
}
public _ckrun_get_pl_knifeattacking(id)
{
	return knifeattacking[id]
}


public _ckrun_playsequence(id,PlayerAnim:iAnim)
{
	PlaySequence(id,PlayerAnim:iAnim)
	return 1;
}
	
public _ckrun_item_creat()
{
	
	ArrayPushCell(item_id,extra_item_num)
	ArrayPushString(item_english_name,"none")
	ArrayPushString(item_chinese_name,"none")
	
	ArrayPushCell(item_type,item_none)
	ArrayPushCell(item_usertype,0)
	ArrayPushCell(item_weaponslot,itemwpn_none)
	ArrayPushCell(item_wpnmaxclip,0)
	ArrayPushCell(item_wpnmaxammo,0)
	
	extra_item_num++
	
	return (extra_item_num-1)
}
public _ckrun_created_item_engname(itemid,engname[])
{
	param_convert(2)
	ArraySetString(item_english_name,itemid,engname)
	return 1
}
public _ckrun_created_item_chiname(itemid,chiname[])
{
	param_convert(2)
	ArraySetString(item_chinese_name,itemid,chiname)
	return 1
}
public _ckrun_created_item_type(itemid,type)
{
	ArraySetCell(item_type,itemid,type)
}
public _ckrun_created_item_usertype(itemid,type)
{
	ArraySetCell(item_usertype,itemid,type)
}
public _ckrun_created_item_weaponslot(itemid,slot)
{
	ArraySetCell(item_weaponslot,itemid,slot)
}
public _ckrun_created_item_wpnmaxclip(itemid,maxclip)
{
	ArraySetCell(item_wpnmaxclip,itemid,maxclip)
}
public _ckrun_created_item_wpnmaxammo(itemid,maxammo)
{
	ArraySetCell(item_wpnmaxammo,itemid,maxammo)
}



public _ckrun_user_nowwpnid(id)
{
	return player_weaponid_now[id]
}
public _ckrun_user_lastwpnid(id)
{
	return player_weaponid_last[id]
}
public _ckrun_user_priwpnid(id)
{
	return g_wpnitem_pri[id][ghuman[id]]
}
public _ckrun_user_secwpnid(id)
{
	return g_wpnitem_sec[id][ghuman[id]]
}
public _ckrun_user_knifewpnid(id)
{
	return g_wpnitem_knife[id][ghuman[id]]
}
public _ckrun_user_willpriwpnid(id)
{
	return g_wpnitem_willpri[id][ghuman[id]]
}
public _ckrun_user_willsecwpnid(id)
{
	return g_wpnitem_willsec[id][ghuman[id]]
}
public _ckrun_user_willknifewpnid(id)
{
	return g_wpnitem_willknife[id][ghuman[id]]
}

public _ckrun_set_priwpn_clip(id,num)
{
	gpri_clip[id]=num
	ckrun_update_user_clip_ammo(id)
	return 1;
}
public _ckrun_get_priwpn_clip(id)
	return gpri_clip[id]
public _ckrun_set_priwpn_ammo(id,num)
{
	gpri_bpammo[id]=num
	ckrun_update_user_clip_ammo(id)
	return 1;
}
public _ckrun_get_priwpn_ammo(id)
	return gpri_bpammo[id]

public _ckrun_set_secwpn_clip(id,num)
{
	gsec_clip[id]=num
	ckrun_update_user_clip_ammo(id)
	return 1;
}
public _ckrun_get_secwpn_clip(id)
	return gsec_clip[id]
	
public _ckrun_set_secwpn_ammo(id,num)
{
	gsec_bpammo[id]=num
	ckrun_update_user_clip_ammo(id)
	return 1;
}
public _ckrun_get_secwpn_ammo(id)
	return gsec_bpammo[id]


public _ckrun_get_priwpn_maxclip(id)
	return gmaxpriclip[id]

public _ckrun_get_priwpn_maxammo(id)
	return gmaxpribpammo[id]

public _ckrun_get_secwpn_maxclip(id)
	return gmaxsecclip[id]
	
public _ckrun_get_secwpn_maxammo(id)
	return gmaxsecbpammo[id]


public _ckrun_set_curtime_NT(id,Float:nexttime)
{
	player_curweapontime[id]=get_gametime()+nexttime
	return 1;
}

public _ckrun_get_curtime_NT(id,Float:nexttime)
{
	nexttime=player_curweapontime[id]
	return 2;
}
public _ckrun_set_priwpn_NAT(id,Float:nexttime)
{
	player_priwpnnextattacktime[id]=get_gametime()+nexttime
	return 1;
}
public _ckrun_get_priwpn_NAT(id,Float:ret_nexttime)
{
	ret_nexttime=player_priwpnnextattacktime[id]
	return 2;
}
public _ckrun_set_secwpn_NAT(id,Float:nexttime)
{
	player_secwpnnextattacktime[id]=get_gametime()+nexttime
	return 1;
}
public _ckrun_get_secwpn_NAT(id,Float:ret_nexttime)
{
	ret_nexttime=player_secwpnnextattacktime[id]
	return 2;
}
public _ckrun_set_knifewpn_NAT(id,Float:nexttime)
{
	player_knifewpnnextattacktime[id]=get_gametime()+nexttime
	return 1;
}
public _ckrun_get_knifewpn_NAT(id,Float:ret_nexttime)
{
	ret_nexttime=player_knifewpnnextattacktime[id]
	return 2;
}
	
	

public _ckrun_set_forward_num(which,changetonum)
{
	forward_change_num[which] = changetonum
	return 1;
}
public _ckrun_get_forward_num(which)
{
	return forward_change_num[which]
}

public _ckrun_set_forward_float(which,Float:changetofloat)
{
	forward_change_float[which] = changetofloat
	return 1;
}
public _ckrun_get_forward_float(which,Float:ret)
{
	ret = forward_change_float[which]
	return 1;
}

public _ckrun_set_forward_vectype(which,Float:changetovec[3])
{
	param_convert(2)
	forward_change_vectype[which] = changetovec
	return 1;
}
public _ckrun_get_forward_vectype(which,Float:ret[3])
{
	param_convert(2)
	ret = forward_change_vectype[which]
	return 1;
}

public _ckrun_set_forward_string(which,changetostring[64])
{
	param_convert(2)
	forward_change_string[which] = changetostring
	return 1;
}
public _ckrun_get_forward_string(which,ret[64])
{
	param_convert(2)
	ret = forward_change_string[which]
	return 1;
}

stock ckrun_reset_forward_change_var()
{
	new empty[3],empty2[64]
	
	for(new i;i<10;i++)
	{
		forward_change_num[i]=-1
		forward_change_float[i]=-1.0
		forward_change_vectype[i]=empty
		forward_change_string[i]=empty2
	}
}






























stock fm_trace_line(ignoreent, const Float:start[3], const Float:end[3], Float:ret[3]){
	engfunc(EngFunc_TraceLine, start, end, 0, ignoreent, 0);

	new ent = get_tr2(0, TR_pHit);
	get_tr2(0, TR_vecEndPos, ret);

	return pev_valid(ent) ? ent : 0;
}
stock bool:fm_is_in_viewcone(index, const Float:targetpoint[3],Float:fov = 90.0) {
	new Float:angles[3];
	pev(index, pev_angles, angles);
	engfunc(EngFunc_MakeVectors, angles);
	global_get(glb_v_forward, angles);
	angles[2] = 0.0;

	new Float:origin[3], Float:diff[3], Float:norm[3];
	pev(index, pev_origin, origin);
	xs_vec_sub(targetpoint, origin, diff);
	diff[2] = 0.0;
	xs_vec_normalize(diff, norm);

	new Float:dot
	dot = xs_vec_dot(norm, angles);
	if (dot >= floatcos(fov * M_PI / 360))
		return true;

	return false;
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
stock msg_anim(index,wtf)
{
	if(!(0<index<=g_maxplayer)||!is_user_connected(index)) return;

	set_pev(index, pev_weaponanim, wtf)
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, index)
	write_byte(wtf)
	write_byte(pev(index,pev_body))
	message_end()
	
}
/*about hidetype
(1<<0)  -  crosshair, ammo, weapons list
(1<<1)  -  flashlight, +
(1<<2)  -  ALL
(1<<3)  -  radar, health, armor, +
(1<<4)  -  timer, +
(1<<5)  -  money, +
(1<<6)  -  crosshair
(1<<7)  -  +
*/
stock set_user_hidehud_type(id, type)
{
	if(!(0<id<=g_maxplayer)) return;
	if(!pev_valid(id)) return;
	message_begin(MSG_ONE,get_user_msgid("HideWeapon"),_,id)
	write_byte(type)
	message_end()
}
	
stock set_fov(id,fov=90)
{
	if(!(0<id<=g_maxplayer)) return;
	if(!pev_valid(id)) return;
	
	fov-=1
	
	message_begin(MSG_ONE,get_user_msgid("SetFOV"),_,id)
	write_byte(fov)
	message_end()
}

new const PRIMARY_WEAPONS = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
//上面是与主要武器有关的主要武器ID序列号
new const SECONDARY_WEAPONS = ((1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE))
//上面是与次要武器有关的次要武器ID序列号
stock drop_weapons(id, dropwhat)
{
	static weapons[32], num, i
	num = 0 // reset passed weapons count (bugfix)
	get_user_weapons(id, weapons, num)
	for (i = 0; i < num; i++){
		if ((dropwhat == 1 && ((1<<weapons[i]) & PRIMARY_WEAPONS)) || (dropwhat == 2 && ((1<<weapons[i]) & SECONDARY_WEAPONS))){
			static wname[32]
			get_weaponname(weapons[i], wname, sizeof wname - 1)
			engclient_cmd(id, "drop", wname)
		}/*
		if ((dropwhat == 3 && !((1<<weapons[i]) & PRIMARY_WEAPONS)) && !((1<<weapons[i]) & SECONDARY_WEAPONS))))
		{*/
			
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
stock FX_ColoredTrace_point(const Float:idorigin[3],const Float:targetorigin[3]){
	new Float:velfloat[3]
	get_speed_vector(idorigin, targetorigin, 4000.0, velfloat)
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
	write_byte(12)
	write_byte(1)
	write_byte(25)
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
}
stock FX_Blood(id, level,size){
	if(level > 3 || level < 1) return;
	if(disguise[id] || invisible_ed[id]) return;
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
			write_byte(size) // size
			message_end()
		}
	}
}
stock FX_Critical(id, target,type){//暴击
	if(!is_user_alive(id) || !is_user_alive(target) || id == target) return;
	if(type == 1)
	{
		//engfunc(EngFunc_EmitSound,id, CHAN_STATIC,snd_minicrit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		play_spk(id,snd_minicrit)
		engfunc(EngFunc_EmitSound,target, CHAN_STATIC,snd_minicrit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
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
		write_short(spr_minicrit)
		write_byte(1)
		write_coord(30)
		message_end()
	}
	else if(type >=2)
	{
		engfunc(EngFunc_EmitSound,id, CHAN_STATIC,snd_crit_hit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		//play_spk(id,snd_crit_hit)
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
		write_short(spr_crit)
		write_byte(1)
		write_coord(30)
		message_end()
	}
}
new const dcl_gun[] = { 41, 42, 43, 44, 45 }
new const dcl_exp[] = { 46, 47, 48 }
stock FX_GunDecal(id,Float:origin[3]){
	/*
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_WORLDDECAL)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	write_byte(dcl_gun[random_num(0, sizeof dcl_gun - 1)])
	message_end()
	
	FX_GunShotHitSound(origin)
	*/
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, origin, 0)
	write_byte(TE_GUNSHOTDECAL)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	write_short(id)
	write_byte(dcl_gun[random_num(0, sizeof dcl_gun  - 1)])
	message_end()
}
stock FX_GunShotHitSound(Float:Origin[3])
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, Origin)
	write_byte(TE_GUNSHOT)
	engfunc(EngFunc_WriteCoord, Origin[0])
	engfunc(EngFunc_WriteCoord, Origin[1])
	engfunc(EngFunc_WriteCoord, Origin[2])
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
stock FX_SPARKS(checkid,const org[3])
{
	if(!(0<checkid<=g_maxplayer))
	{
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY,org);
		write_byte(TE_SPARKS)
		write_coord(org[0])
		write_coord(org[1])
		write_coord(org[2])
		message_end()
	}
}
stock FX_ScreenShake(id,level,times,frame)
{
	if(!(0<id<=g_maxplayer)) return;
	
	level*=85
	times*=85
	frame*=85
	message_begin(MSG_ONE,get_user_msgid("ScreenShake"),_,id);
	write_short(level)
	write_short(times)
	write_short(frame)
	message_end()
}
stock add_line_two_point(startent,endent,spr,red,green,blue,size)
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte(TE_BEAMENTS)
	write_short(endent)
	write_short(startent)
	write_short(spr) 
	write_byte( 0 ); // 开始帧(填0即可)
	write_byte( 25 );  // 帧率(貌似一秒执行10次,超过最大值就木有了)
	write_byte( 1);  // 帧数最大值
	write_byte( size);  // 光线宽度
	write_byte( 0);  // 抖动频率
	write_byte(red)
	write_byte(green)
	write_byte(blue)
	write_byte(225)
	write_byte(12)
	message_end()
}
stock add_line_follow(ent,spr,times,width,r,g,b,brightness)
{
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(ent); // 对象
	write_short(spr); // SPR特效文件
	write_byte(times); // 时间(*0.1s)
	write_byte(width); // 光线宽度
	write_byte(r); // 红
	write_byte(g); // 绿
	write_byte(b); // 蓝
	write_byte(brightness); // 亮度(透明度)
	message_end();
}

stock FX_Smoke(Float:Origin[3]){
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, Origin)
	write_byte(TE_SMOKE)
	engfunc(EngFunc_WriteCoord, Origin[0])
	engfunc(EngFunc_WriteCoord, Origin[1])
	engfunc(EngFunc_WriteCoord, Origin[2])
	write_short(smoke)
	write_byte(10)
	write_byte(6)
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


stock FX_DLight(Float:Origin[3], size, r, g, b, times){
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
	write_byte(times)
	write_byte(60)
	message_end()
}


stock bool:fm_is_entity_visible(entity){
	if ((pev(entity, pev_effects) & EF_NODRAW))
		return false
	return true
}
stock set_user_screenfadefix(id,draw[4],holdtime)
{
	holdtime*=100
	message_begin(MSG_ONE,get_user_msgid("ScreenFade"), _,id)
	write_short(holdtime)
	write_short(holdtime)
	write_short(1<<12)
	write_byte(draw[0])
	write_byte(draw[1])
	write_byte(draw[2])
	write_byte(draw[3])
	message_end()
	
	return 1;
}
stock set_msg_armor(id,armor)
{
	if(id==0) return;
	if(!pev_valid(id)) return;
	
	message_begin(MSG_ONE,get_user_msgid("Battery"),_,id)
	write_short(armor)
	message_end()
}
stock show_spr(Float:org[3],spr,scale,alpha)
{
	new position[3]
	FVecIVec(org,position)
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_SPRITE)
	write_coord(position[0])
	write_coord(position[1])
	write_coord(position[2])
	write_short(spr) 
	write_byte(scale) 
	write_byte(alpha)
	message_end()
}
stock is_back_face(enemy, id, Float:fov=90.0){
	new Float:anglea[3],Float:anglev[3]
	pev(enemy,pev_v_angle,anglea)
	pev(id,pev_v_angle,anglev)
	new Float:angle = anglea[1] - anglev[1] 
	if(angle < -180.0) angle += 360.0
	if(angle <= fov && angle >= -fov) return true
	return false
}
	

//by chickrnrun_1.sma
stock fm_set_user_model(id, const modelname[]){
	engfunc(EngFunc_SetClientKeyValue, id, engfunc(EngFunc_GetInfoKeyBuffer, id), "model", modelname)
}
stock fm_get_user_model(id, model[], len){
	return engfunc(EngFunc_InfoKeyValue, engfunc(EngFunc_GetInfoKeyBuffer, id), "model", model, len)
}
public fm_set_user_team(id, team, fake)
{
	if(!id) return; 
	set_pdata_int(id, OFFSET_CSTEAMS, team)
	
	dllfunc(DLLFunc_ClientUserInfoChanged, id, engfunc(EngFunc_GetInfoKeyBuffer, id) )
	message_begin(MSG_BROADCAST, g_msgTeamInfo,_,0)
	write_byte(id)
	write_string(CS_Teams[team])
	message_end()
	
}  
stock fm_set_user_money(index, money, show = false){
	set_pdata_int(index, OFFSET_CSMONEY, money);
	if(show){
		message_begin(MSG_BROADCAST, get_user_msgid("Money"), {0,0,0}, index);
		write_long(money);
		write_byte(0);
		message_end();
	}
}
stock FX_ChangeRoundTime(changetotime)
{
	engfunc(EngFunc_MessageBegin, MSG_BROADCAST, g_msgRoundTime, 0, 0)
	write_short(changetotime)
	message_end()
}
stock FX_UpdateScore(id){
	if(!is_user_connected(id) || !pev_valid(id) || id > g_maxplayer) return;
	
	fm_set_user_frags(id,g_allscore[id])
	
	message_begin(MSG_BROADCAST, g_msgScoreInfo)
	write_byte(id)
	write_short(g_roundscore[id])
	write_short(get_user_deaths(id))
	write_short(0)
	write_short(gteam[id])
	message_end()

	
}
stock fm_strip_user_weapons(id){
	new g_wpnstriper
	if (!pev_valid(g_wpnstriper)){
		g_wpnstriper = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "player_weaponstrip"))
		dllfunc(DLLFunc_Spawn, g_wpnstriper)
	}

	dllfunc(DLLFunc_Use, g_wpnstriper, id)
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
stock fm_set_user_frags(id, value){
	set_pev(id, pev_frags, float(value))
}
stock fm_get_user_frags(id){
	return pev(id, pev_frags)
}
stock fm_set_entity_visible(index, visible) {
	set_pev(index, pev_effects, visible == 1 ? pev(index, pev_effects) & ~EF_NODRAW : pev(index, pev_effects) | EF_NODRAW);
	return 1;
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
	if(new_angles[1]==180.0 || new_angles[1]==-180.0) new_angles[1]=-17999999

	set_pev(ent,pev_angles,new_angles)
	set_pev(ent,pev_fixangle,1)

	return 1;
}
stock Float:fm_get_entity_speed(entity){
	static Float:velocity[3]
	pev(entity, pev_velocity, velocity)
	
	return vector_length(velocity);
}
stock fm_set_user_zoom(id, type){
	set_pdata_int(id, OFFSET_ZOOMTYPE, type, 5)
}/*
stock fm_get_entity_origin(ent,Float:addsizemul,Float:Return[3])
{
	new Float:Startorg[3],Float:entorg[3],Float:Endorg[3],touch,Float:TraceTouch[3],Float:TraceTouch2[3],Float:box[3]
	
	
	pev(ent,pev_origin,Startorg)
	xs_vec_copy(Startorg,entorg)
	pev(ent,pev_maxs,box)
	xs_vec_copy(Startorg,Endorg)
	
	Endorg[2]-=9999.0
	engfunc(EngFunc_TraceLine, Startorg, Endorg, 0, ent, 0);
	touch = get_tr2(0, TR_pHit);
	get_tr2(0, TR_vecEndPos, TraceTouch);
	
	Startorg[2]+=9999.0
	engfunc(EngFunc_TraceLine, TraceTouch, Startorg, 0, 0, 0);
	touch = get_tr2(0, TR_pHit);
	get_tr2(0, TR_vecEndPos, TraceTouch);
	
	if(touch == ent)
	{
		if(!(0<ent<=g_maxplayer))
		{
			engfunc(EngFunc_TraceLine, TraceTouch, entorg, 0, 0, 0);
			get_tr2(0, TR_vecEndPos, TraceTouch2);
			if(get_distance_f(TraceTouch,TraceTouch2)>1.0)
			{
				TraceTouch2[2]-=(box[2]-box[2]*addsizemul)
				xs_vec_copy(TraceTouch2,Return)
			}else{
				TraceTouch[2]+=(box[2]*addsizemul)
				xs_vec_copy(TraceTouch,Return)
			}
		}else{
			if(pev(ent,pev_flags)&FL_DUCKING)
			{
				entorg[2]+=0.0
				xs_vec_copy(entorg,Return)
			}else{
				engfunc(EngFunc_TraceLine, TraceTouch, entorg, 0, 0, 0);
				get_tr2(0, TR_vecEndPos, TraceTouch2);
				if(get_distance_f(TraceTouch,TraceTouch2)>1.0)
				{
					TraceTouch2[2]-=(box[2]-box[2]*addsizemul)
					xs_vec_copy(TraceTouch2,Return)
				}else{
					TraceTouch[2]+=(box[2]*addsizemul)
					xs_vec_copy(TraceTouch,Return)
				}
			}
		}
		
	}else{
		engfunc(EngFunc_TraceLine, TraceTouch, entorg, 0, touch, 0);
		get_tr2(0, TR_vecEndPos, TraceTouch2);
		touch = get_tr2(0, TR_pHit);
		if(touch == ent)
		{
			TraceTouch2[2]-=(box[2]-box[2]*addsizemul)
			xs_vec_copy(TraceTouch2,Return)
		}
	}
	
	
	
	
	
	
	
	return 1;
}*/
stock ckrun_get_ckrwpnid_pritype(ckrwpnid,class)
{
	new len = 0
	
	if(class == 1)
	{
		switch(ckrwpnid)
		{
			case CKRW_DB_SHOTGUN:	len = 1		//双管猎枪
			case CKRW_SHOTGUN:	len = 1		//散弹枪
			case CKRW_M134:	len = 1			//转轮机枪
			case CKRW_SMG:	len = 2			//微型冲锋枪
			case CKRW_SNIPE:	len = 1		//狙击枪
			case CKRW_RPG:	len = 1			//火箭发射器
			case CKRW_FLAMETHROWER:	len = 1		//火焰喷射器
			case CKRW_MEDICGUN:	len = 1		//医疗枪
			case CKRW_GRENADE:	len = 1		//榴弹发射器
			case CKRW_REVOLVER:	len = 2		//左轮手枪
			case CKRW_PISTOL:	len = 2		//手枪
			case CKRW_SYRINGE:	len = 1		//针筒发射器
			case CKRW_STICKYGRENADE:	len = 1	//粘弹发射器
			case CKRW_SAPPER:	len = 2		//电子工兵
			case CKRW_BAT:	len = 3			//棒球棍
			case CKRW_FIST:	len = 3			//拳头
			case CKRW_SHOVEL:	len = 3		//铁铲
			case CKRW_AXE:	len = 3			//消防斧
			case CKRW_HUNTINGKNIFE:	len = 3		//猎刀
			case CKRW_BONESAW:	len = 3		//骨锯
			case CKRW_WRENCH:	len = 3		//扳手
			case CKRW_BOTTLE:	len = 3		//酒瓶
			case CKRW_BUTTERFLY:	len = 1		//蝴蝶刀
			case CKRW_RETURNED_ROCKET:	len = 1	//反射火箭弹
			case CKRW_RETURNED_GRENADE:	len = 1	//反射榴弹
			case CKRW_SENTRYGUN:	len = 0		//步哨枪
			case CKRW_SENTRYROCKET:	len = 0		//步哨火箭
			case CKRW_PAW:	len = 3			//爪子
			case CKRW_BUILDINGEXPLODE:	len = 0	//建筑爆炸
			case CKRW_ASSM3:	len = 1		//admin
			case CKRW_ASSDEAGLE:	len = 2		//admin
		}
	}else{
		
	}
	
	return len;
}
stock ckrun_get_ckrwpnid_slot(ckrwpnid,class)
{
	new slot = 0
	
	if(class == 1)
	{
		switch(ckrwpnid)
		{
			case CKRW_DB_SHOTGUN:	slot = 1		//双管猎枪
			case CKRW_SHOTGUN:	slot = 1		//散弹枪
			case CKRW_M134:	slot = 1			//转轮机枪
			case CKRW_SMG:	slot = 2			//微型冲锋枪
			case CKRW_SNIPE:	slot = 1		//狙击枪
			case CKRW_RPG:	slot = 1			//火箭发射器
			case CKRW_FLAMETHROWER:	slot = 1		//火焰喷射器
			case CKRW_MEDICGUN:	slot = 1		//医疗枪
			case CKRW_GRENADE:	slot = 1		//榴弹发射器
			case CKRW_REVOLVER:	slot = 1		//左轮手枪
			case CKRW_PISTOL:	slot = 2		//手枪
			case CKRW_SYRINGE:	slot = 2		//针筒发射器
			case CKRW_STICKYGRENADE:	slot = 2	//粘弹发射器
			case CKRW_ELECTRONIC:	slot = 2		//电子工兵
			case CKRW_BAT:	slot = 3			//棒球棍
			case CKRW_FIST:	slot = 3			//拳头
			case CKRW_SHOVEL:	slot = 3			//铁铲
			case CKRW_AXE:	slot = 3			//消防斧
			case CKRW_HUNTINGKNIFE:	slot = 3		//猎刀
			case CKRW_BONESAW:	slot = 3		//骨锯
			case CKRW_WRENCH:	slot = 3		//扳手
			case CKRW_BOTTLE:	slot = 3		//酒瓶
			case CKRW_BUTTERFLY:	slot = 3		//蝴蝶刀
			case CKRW_RETURNED_ROCKET:	slot = 1	//反射火箭弹
			case CKRW_RETURNED_GRENADE:	slot = 1	//反射榴弹
			case CKRW_SENTRYGUN:	slot = 0		//步哨枪
			case CKRW_SENTRYROCKET:	slot = 0		//步哨火箭
			case CKRW_SAPPER:	slot = 2		//电子工兵
			case CKRW_PAW:	slot = 3			//爪子
			case CKRW_BUILDINGEXPLODE:	slot = 0	//建筑爆炸
			case CKRW_ASSDEAGLE:	slot = 2			//admin
			case CKRW_ASSM3:	slot = 1			//admin
		}
	}else{
		
	}
	
	return slot;
}
stock ckrun_get_turntotarget_angle(ent,const Float:targetorigin[3],Float:NeedAngle[3]) {
	if (pev_valid(ent))
	{
		new Float:entorg[3],Float:vec[3]
		pev(ent,pev_origin,entorg)
		get_speed_vector(entorg,targetorigin,1800.0,vec)
		vector_to_angle(vec,NeedAngle)
		
		return 1
	}
	return 0
}
public Sentry_Aim(entity, target){
	if (!pev_valid(target)) return 0
	new Float:vecSpot[3], Float:vecSee[3], Float:absmin[3], Float:absmax[3]
	pev(target, pev_absmin, absmin)
	pev(target, pev_absmax, absmax)
	vecSpot[0] = (absmin[0] + absmax[0]) * 0.5
	vecSpot[1] = (absmin[1] + absmax[1]) * 0.5
	vecSpot[2] = (absmin[2] + absmax[2]) * 0.5
	if(pev(target, pev_bInDuck) || (pev(target, pev_flags) & IN_DUCK)) vecSpot[2] += 24.0
	pev(entity, pev_origin, vecSee)
	vecSee[2] += 28.0

	new Float:vecAngles[3]
	pev(entity, pev_angles, vecAngles)
	vecAngles[1] *= -1.0

	new Float:x = vecSpot[0] - vecSee[0]
	new Float:y = vecSpot[1] - vecSee[1]

	new Float:degs_y = floatatan(y/x, radian) * 180.0 / 3.141592653
	if (vecSpot[0] < vecSee[0]) degs_y -= 180.0
	
	new Float:Rot
	pev(entity, pev_fuser1, Rot)
	if(0.0 <= Rot - degs_y <= 180.0)
	{
		if(Rot - 4.0 < degs_y)
			Rot = degs_y
		else
			Rot -= 4.0
	}
	else
	{
		if(Rot + 4.0 > degs_y)
			Rot = degs_y
		else
			Rot += 4.0
	}
	set_pev(entity, pev_fuser1, Rot)

	new Float:h = vecSee[2] - vecSpot[2]
	new Float:b = vector_distance(vecSee, vecSpot)
	new Float:degs_x = floatatan(h/b, radian) * 180.0 / 3.141592653
	
	if(degs_x > 75.0) degs_x = 75.0
	else if(degs_x < -75.0) degs_x = -75.0

	set_pev(entity, pev_controller_0, floatround(0.706 * (Rot + vecAngles[1])) )
	set_pev(entity, pev_controller_1, floatround(128.0 - 3.2421 * degs_x))
	if(floatabs(Rot - degs_y) < 15.0)
	{
		return 1
	}
	return 0
}
stock play_mp3(const id, const mp3[]) {
	client_cmd(id, "mp3 play ^"%s^"", mp3)
}
stock stop_mp3(const id){
	client_cmd(id, "mp3 stop")
}
stock play_spk(const id,const wav[]){
	client_cmd(id, "spk ^"%s^"",wav)
}
stock stop_spk(const id){
	client_cmd(id, "stopsound")
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
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg936\\ deff0{\\ fonttbl{\\ f0\\ fnil\\ fcharset134 Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2052\\ f0\\ fs16 \n\\ par }
*/
