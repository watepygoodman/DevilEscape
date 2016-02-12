#include <amxmodx>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <xs>
#include <devilescape>
#include <de_wpn_tool>

#define PLUGIN_NAME "钉枪"
#define PLUGIN_VERSION "0.0"
#define PLUGIN_AUTHOR "watepy"

enum{
	IDLE, SHOOT1, SHOOT2, RELOAD, DRAW
}

new const g_WpnModel[][]= 
{
	"models/v_coilgun.mdl",
	"models/p_coilgun.mdl"
}

new const g_WpnSound[][]=
{
	"weapons/coilgun-1.wav",
	"weapons/coilgun_clipin1.wav",
	"weapons/coilgun_clipin2.wav",
	"weapons/coilgun_clipout.wav"
}

new const g_Mdl_Coil[]= "models/s_coil.mdl"

new const CSW_COILGUN = CSW_M249
new const weapon_coilgun[] = "weapon_m249"

// const m_BloodColor = 89
// const m_iClip = 51
// const m_fInReload = 54
// const m_flNextAttack = 83
// const m_pActiveItem = 373
// const m_flNextPrimaryAttack = 46
// const m_flNextSecondaryAttack = 47
// const m_flTimeWeaponIdle = 48

new g_TrailSpr
new cvar_damage, cvar_price, cvar_speed
// new cvar_clip
new g_Wpnid

public plugin_precache()
{
	for(new i = 0; i < sizeof g_WpnSound; i++)
		engfunc(EngFunc_PrecacheSound, g_WpnSound[i])
	for(new i = 0; i < sizeof g_WpnModel; i++)
		engfunc(EngFunc_PrecacheModel, g_WpnModel[i])
	engfunc(EngFunc_PrecacheModel, g_Mdl_Coil)

	g_TrailSpr = engfunc(EngFunc_PrecacheModel,"sprites/xbeam3.spr")
	
	cvar_damage = register_cvar("de_wpn_coilgun_dmg","80.0")
	// cvar_clip = register_cvar("de_wpn_coilgun_clip","100")
	cvar_price = register_cvar("de_wpn_coilgun_price", "388")
	cvar_speed = register_cvar("de_wpn_coilgun_coilspeed", "600.0")
}

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	register_event("CurWeapon", "event_curweapon", "be", "1=1")
	
	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_PlaybackEvent, "fw_PlaybackEvent")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	
	// RegisterHam(Ham_Item_AddToPlayer, "weapon_awp", "fw_Item_AddToPlayer", 1)
	RegisterHam(Ham_Item_Deploy, weapon_coilgun, "fw_Item_Deploy_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_coilgun, "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Think, "info_target", "fw_Coil_Think")
	RegisterHam(Ham_Touch, "info_target", "fw_Coil_Touch_Post", 1)
	// RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_awp", "fw_Weapon_SecondaryAttack")
	// RegisterHam(Ham_Weapon_WeaponIdle, "weapon_awp", "fw_Weapon_WeaponIdle_Post", 1)
	// RegisterHam(Ham_Weapon_Reload, "weapon_awp", "fw_Weapon_Reload")
	
	g_Wpnid = de_register_sp_wpn(PLUGIN_NAME, get_pcvar_num(cvar_price))
	
	register_clcmd("weapon_coilgun", "hook_weapon")
	
}

public hook_weapon(id)
{
	if(is_user_alive(id))
		engclient_cmd(id, "weapon_m249")
	
	return PLUGIN_HANDLED
}

public de_spwpn_select(id, wid)
{
	if(g_Wpnid == wid)
		give_weapon(id)
}

public give_weapon(id)
{
	if (!is_user_alive(id))
		return 
	
	new iEntity = fm_give_item(id, weapon_coilgun)
	if (iEntity > 0)
	{
		set_pev(iEntity, pev_weapons, WEAPON_COILGUN)
		set_pev(iEntity, pev_owner, id)
		SetWeaponAnimation(id, DRAW)
		set_pdata_int(id, m_iAmmoType_M249, 200)
	}
}

public event_curweapon(id)
{
	if(!is_user_alive(id) || read_data(2) != CSW_COILGUN)
		return
	new Ent = get_pdata_cbase(id, m_pActiveItem)
	if(Ent <= 0)
		return
	
	if(pev(Ent, pev_weapons) == WEAPON_COILGUN)
	{
		set_pev(id, pev_viewmodel2, g_WpnModel[0])
		set_pev(id, pev_weaponmodel2, g_WpnModel[1])
	}
}

public fw_Item_AddToPlayer(Ent, id)
{
	if(!pev_valid(Ent))
		return HAM_IGNORED
	
	if(pev(Ent, pev_weapons) == WEAPON_COILGUN)
	{
		set_pev(Ent, pev_owner, id)
		SetWeaponAnimation(id, DRAW)
		set_pdata_float(id, m_flNextAttack, 1.0)
	}
	return HAM_HANDLED
}

//开火
public fw_Weapon_PrimaryAttack(Ent)
{
	if(pev(Ent, pev_weapons) != WEAPON_COILGUN)
		return HAM_IGNORED
	
	new iClip = get_pdata_int(Ent, m_iClip, 4)
	if(!iClip) return HAM_IGNORED
	
	new id = pev(Ent, pev_owner)
	set_pdata_float(Ent, m_flNextPrimaryAttack, 0.12, 4)
	// set_pdata_float(Ent, m_flNextSecondaryAttack, 0.12, 4)
	SetWeaponAnimation(id, random_num(SHOOT1, SHOOT2))
	
	set_pdata_int(Ent, m_iClip, iClip-1, 4)
	Shoot_Coil(id)
	set_pev(id, pev_punchangle, {-0.5, 1.0, -0.5})
	engfunc(EngFunc_EmitSound, Ent, CHAN_ITEM, g_WpnSound[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	return HAM_SUPERCEDE
}

Shoot_Coil(id)
{
	new Ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	new Float:fOrg[3], Float:fAng[3], Float:fVec[3]
	
	get_position(id, 30.0, 11.5, -10.0, fOrg)
	pev(id, pev_angles, fAng)
	
	set_pev(Ent, pev_origin, fOrg)
	set_pev(Ent, pev_angles, fAng)
	set_pev(Ent, pev_solid, SOLID_BBOX)
	set_pev(Ent, pev_classname, "coil_ent")
	set_pev(Ent, pev_movetype, MOVETYPE_BOUNCEMISSILE)
	set_pev(Ent, pev_owner, id)
	engfunc(EngFunc_SetModel, Ent, g_Mdl_Coil)
	set_pev(Ent, pev_mins, {-1.0, -1.0, -1.0})
	set_pev(Ent, pev_maxs, {1.0, 1.0, 1.0})
	
	velocity_by_aim(id, get_pcvar_num(cvar_speed), fVec)
	set_pev(Ent, pev_velocity, fVec)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW) // TE id
	write_short(Ent) // entity:attachment to follow
	write_short(g_TrailSpr) // sprite index
	write_byte(10) // life in 0.1's
	write_byte(1) // line width in 0.1's
	write_byte(255) // r
	write_byte(255) // g
	write_byte(255) // b
	write_byte(200) // brightness
	message_end()
	
	set_pev(Ent, pev_nextthink, get_gametime() + 3.0)
}

public fw_Coil_Think(Ent)
{
	if(!pev_valid(Ent))
		return
	new classname[32]
	pev(Ent, pev_classname, classname, 31)
	if (!equal(classname,"coil_ent"))
		return
	
	engfunc(EngFunc_RemoveEntity, Ent)
	
}

public fw_Coil_Touch_Post(Ent, Touch)
{
	if(!pev_valid(Ent))
		return
	
	new classname[32]
	pev(Ent, pev_classname, classname, 31)
	if (!equal(classname,"coil_ent"))
		return
	
	new id = pev(Ent, pev_owner)
	if(id == Touch || Touch <= 0 || !is_user_alive(Touch))
		return
	
	if(get_pdata_int(id, m_CsTeam) != get_pdata_int(Touch, m_CsTeam))
	{
		engfunc(EngFunc_RemoveEntity, Ent)
		ExecuteHamB(Ham_TakeDamage, Touch, 0, id, get_pcvar_float(cvar_damage), DMG_BULLET)
	}
	
}

// public fw_Weapon_SecondaryAttack(Ent)
// {
	// if(pev(Ent, pev_weapons) == WEAPON_THUNDERBOLT)

// }

public fw_Item_Deploy_Post(Ent)
{
	if (pev(Ent, pev_weapons) != WEAPON_COILGUN)
		return HAM_IGNORED
	
	new id = pev(Ent, pev_owner)
	set_pev(id, pev_viewmodel2, g_WpnModel[0])
	set_pev(id, pev_weaponmodel2, g_WpnModel[1])
	SetWeaponAnimation(id, DRAW)
	
	return HAM_SUPERCEDE
}

public fw_Weapon_Reload(Ent)
{
	if (pev(Ent, pev_weapons) == WEAPON_THUNDERBOLT)
		return HAM_SUPERCEDE

	return HAM_IGNORED
}

public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
	if(!is_user_alive(id))
		return FMRES_IGNORED	
	
	new Ent = get_pdata_cbase(id, m_pActiveItem)
	if(Ent <= 0)
		return FMRES_IGNORED
	
	if(pev(Ent, pev_weapons) == WEAPON_COILGUN)
		set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001) 
	
	return FMRES_HANDLED
}

public fw_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if (!is_user_connected(invoker))
		return FMRES_IGNORED	
	if(pev(get_pdata_cbase(invoker, m_pActiveItem), pev_weapons) != WEAPON_COILGUN)
		return FMRES_IGNORED
	
	engfunc(EngFunc_PlaybackEvent, flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
	
	return HAM_SUPERCEDE
}


