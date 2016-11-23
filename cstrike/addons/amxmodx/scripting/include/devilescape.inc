#if defined _devilescape_included
	#endinput
#endif
#define _devilescape_included

/* ====================
*
*				OFFSET
*
==================== */
stock m_CsTeam = 114 				//队伍
stock m_MapZone = 235			//所在区域
stock m_ModelIndex = 491 			//模型索引
stock m_BloodColor = 89
stock m_iClip = 51
stock m_fInReload = 54
stock m_flNextAttack = 83
stock m_pActiveItem = 373
stock m_flNextPrimaryAttack = 46
stock m_flNextSecondaryAttack = 47
stock m_flTimeWeaponIdle = 48
stock m_LastHitGroup = 75 // int
stock m_iWeaponState = 74 //int
stock m_iShotsFired = 64 // int
// stock m_flNextReload = 75 //float

//Ammo Type
stock m_iAmmoType_M249 = 379
stock m_iAmmoType_M4A1 = 380
stock m_iAmmoType_XM1014 = 381

/* ====================
*
*				武器ID
*
==================== */
const WEAPON_INFINITY = 4000
const WEAPON_FIRECRACKER = 4010

const WEAPON_LR300 = 6644
const WEAPON_ETHEREAL = 6655
const WEAPON_M4A1BLACKKNIGHT = 6666
const WEAPON_QBS09 = 6677
const WEAPON_PLASMAGUN = 6688
const WEAPON_THUNDERBOLT = 6699
const WEAPON_SALAMANDER = 7011
const WEAPON_WATERCANNON = 7022
const WEAPON_AT4CS = 7033
const WEAPON_COILGUN = 7044

const DE_DMG_ROCKET = 95123

/* ====================
*
*				物品注册
*
==================== */
native de_register_sp_wpn(const name[], const cost)
native de_register_gash_wpn(const name[], const cost)
native de_register_second_wpn(const name[], const lvneed)
native de_register_item(const name[], const info[])
native de_register_shop_item(const name[], const price, const max)
native de_register_character(const name[], const info[], const price)
native de_set_user_nightvision(const id, const set)
native de_item_random_choose() //按几率随机选择一个物品(在线奖励用)








