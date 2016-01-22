#if defined _devilescape_included
	#endinput
#endif
#define _devilescape_included

//Offset
stock m_BloodColor = 89
stock m_iClip = 51
stock m_fInReload = 54
stock m_flNextAttack = 83
stock m_pActiveItem = 373
stock m_flNextPrimaryAttack = 46
stock m_flNextSecondaryAttack = 47
stock m_flTimeWeaponIdle = 48
// stock m_flNextReload = 75

stock m_iAmmoType_M249 = 379
stock m_iAmmoType_M4A1 = 380
stock m_iAmmoType_XM1014 = 381

//Wpn Key
const WEAPON_PLASMAGUN = 6688
const WEAPON_THUNDERBOLT = 6699
const WEAPON_SALAMANDER = 7011
const WEAPON_M4A1BLACKKNIGHT = 7022
const WEAPON_QBS09 = 7033
const WEAPON_WATERCANNON = 7088

//Wpn Register
native de_register_sp_wpn(const name[], const cost)
native de_register_gash_wpn(const name[], const cost)





