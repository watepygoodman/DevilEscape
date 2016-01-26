#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <xs>
#include <devilescape>
#include <de_wpn_tool>

#define PLUGIN_NAME "AT4CS火箭筒"
#define PLUGIN_VERSION "0.0"
#define PLUGIN_AUTHOR "watepy"

#define pev_victim pev_iuser2
enum{
	IDLE_ANIM, SHOOT1_ANIM, SHOOT2_ANIM, RELOAD_ANIM, DRAW_ANIM
}

new const weapon_at4cs[] = "weapon_m249"
new const CSW_AT4CS = CSW_M249

new const g_WpnModel[][] = {
	"models/v_at4ex.mdl",
	"models/p_at4ex.mdl",
	"models/w_at4ex.mdl"
}

new const g_RocketModel[] = "models/s_rocket.mdl"

new const g_WpnSound[][] = {
	"weapons/at4-1.wav",
	"weapons/at4_clipin1.wav",
	"weapons/at4_clipin2.wav",
	"weapons/at4_clipin3.wav", 
	"weapons/at4_draw.wav"  
}

new g_Spr_Smoke, g_Spr_Trail, g_Spr_Exp
new cvar_price, cvar_damage, cvar_radius, cvar_clip, cvar_speed
new g_Wpnid
new g_MaxPlayer

public plugin_precache()
{
	new i
	for(i = 0 ; i < sizeof g_WpnModel; i++)
		engfunc(EngFunc_PrecacheModel, g_WpnModel[i])
	for(i = 0; i < sizeof g_WpnSound; i++)
		engfunc(EngFunc_PrecacheSound, g_WpnSound[i])
	
	engfunc(EngFunc_PrecacheModel, g_RocketModel)
	
	g_Spr_Smoke = engfunc(EngFunc_PrecacheModel, "sprites/effects/rainsplash.spr")
	g_Spr_Trail = engfunc(EngFunc_PrecacheModel,"sprites/xbeam3.spr")
	g_Spr_Exp = engfunc(EngFunc_PrecacheModel,"sprites/zerogxplode.spr")
	
	cvar_price = register_cvar("de_wpn_at4cs_price", "688")
	cvar_damage = register_cvar("de_wpn_at4cs_dmg", "20000.0")
	cvar_radius = register_cvar("de_wpn_at4cs_radius", "300.0")
	cvar_clip = register_cvar("de_wpn_at4cs_clip", "1")
	cvar_speed = register_cvar("de_wpn_at4cs_rocket_speed", "1000.0")
}

public plugin_init() 
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	register_forward(FM_PlaybackEvent, "fw_PlaybackEvent")
	register_forward(FM_SetModel, "fw_SetModel")
	
	register_event("CurWeapon", "event_curweapon", "be", "1=1")
	
	RegisterHam(Ham_Item_Deploy, weapon_at4cs, "fw_Item_Deploy_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_at4cs, "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_Reload, weapon_at4cs, "fw_Weapon_Reload")
	RegisterHam(Ham_Weapon_Reload, weapon_at4cs, "fw_Weapon_Reload_Post", 1)
	RegisterHam(Ham_Item_PostFrame, weapon_at4cs, "fw_Item_PostFrame")
	RegisterHam(Ham_Item_AddToPlayer, weapon_at4cs, "fw_Item_AddToPlayer", 1)
	RegisterHam(Ham_Think,	"info_target", "fw_Rocket_Think")
	RegisterHam(Ham_Touch, "info_target", "fw_Rocket_Touch_Post", 1)
	
	register_clcmd("weapon_at4cs", "hook_weapon")
	
	g_MaxPlayer = get_maxplayers()
	g_Wpnid = de_register_sp_wpn(PLUGIN_NAME, get_pcvar_num(cvar_price))
}

public hook_weapon(id)
{
	engclient_cmd(id, weapon_at4cs)
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
	
	new iEntity = fm_give_item(id, weapon_at4cs)
	if (iEntity > 0)
	{
		set_pev(iEntity, pev_weapons, WEAPON_AT4CS)
		set_pev(iEntity, pev_owner, id)
		set_pdata_int(iEntity, m_iClip, get_pcvar_num(cvar_clip), 4)
		SetWeaponAnimation(id, DRAW_ANIM)
		set_pdata_int(id, m_iAmmoType_M249, 200)
	}
}

public fw_Item_Deploy_Post(Ent)
{
	if (pev(Ent, pev_weapons) != WEAPON_AT4CS)
		return HAM_IGNORED
	
	new id = pev(Ent, pev_owner)
	set_pev(id, pev_viewmodel2, g_WpnModel[0])
	set_pev(id, pev_weaponmodel2, g_WpnModel[1])
	SetWeaponAnimation(id, DRAW_ANIM)
	set_pdata_float(Ent, m_flNextPrimaryAttack, 1.0, 4)
	
	return HAM_SUPERCEDE
}


public fw_Weapon_PrimaryAttack(Ent)
{
	if(pev(Ent, pev_weapons) != WEAPON_AT4CS)
		return HAM_IGNORED
	
	new iClip = get_pdata_int(Ent, m_iClip, 4)
	if(!iClip) return HAM_IGNORED
	
	new id = pev(Ent, pev_owner)
	SetWeaponAnimation(id, random_num(SHOOT1_ANIM, SHOOT2_ANIM))
	set_pdata_float(Ent, m_flTimeWeaponIdle, 1.0, 5) 
	set_pdata_float(Ent, m_flNextPrimaryAttack, 1.0, 4)
	
	set_pdata_int(Ent, m_iClip, iClip-1, 4)
	engfunc(EngFunc_EmitSound, Ent, CHAN_ITEM, g_WpnSound[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	set_pev(id, pev_punchangle, {-32.0, 0.0, 0.0}) //后坐力 
	Weapon_ShootRocket(id)

	
	return HAM_SUPERCEDE
}

public Weapon_ShootRocket(id)
{
	new Ent, Float:fOrigin[3], Float:fAngle[3], Float:fVec[3]
	Ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	
	get_position(id, 50.0, 7.5, -7.0, fOrigin)
	pev(id, pev_angles, fAngle)
	
	set_pev(Ent, pev_origin, fOrigin)
	set_pev(Ent, pev_angles, fAngle)
	set_pev(Ent, pev_solid, SOLID_BBOX)
	set_pev(Ent, pev_classname, "at4_rocket")
	set_pev(Ent, pev_movetype, MOVETYPE_FLY)
	set_pev(Ent, pev_owner, id)
	engfunc(EngFunc_SetModel, Ent, g_RocketModel)
	set_pev(Ent, pev_mins, {-1.0, -1.0, -1.0})
	set_pev(Ent, pev_maxs, {1.0, 1.0, 1.0})
	
	velocity_by_aim(id, get_pcvar_num(cvar_speed), fVec)
	set_pev(Ent, pev_velocity, fVec)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW) // TE id
	write_short(Ent) // entity:attachment to follow
	write_short(g_Spr_Trail) // sprite index
	write_byte(25) // life in 0.1's
	write_byte(2) // line width in 0.1's
	write_byte(255) // r
	write_byte(255) // g
	write_byte(255) // b
	write_byte(200) // brightness
	message_end()
	
	set_pev(Ent, pev_victim, 0)
	set_pev(Ent, pev_nextthink, get_gametime() + 0.1)
}

public fw_Weapon_Reload(Ent)
{
	if(pev(Ent, pev_weapons) != WEAPON_AT4CS)
		return HAM_IGNORED
	
	new id = pev(Ent, pev_owner)
	new iClip = get_pdata_int(Ent, m_iClip, 4)
	
	if(iClip >= get_pcvar_num(cvar_clip) || !get_pdata_int(id, m_iAmmoType_M249))
		return HAM_SUPERCEDE
	
	return HAM_IGNORED
}


public fw_Weapon_Reload_Post(Ent)
{
	if(pev(Ent, pev_weapons) != WEAPON_AT4CS)
		return HAM_IGNORED
	
	new id = pev(Ent, pev_owner)
	new iClip = get_pdata_int(Ent, m_iClip, 4)
	
	if(iClip >= get_pcvar_num(cvar_clip) || !get_pdata_int(id, m_iAmmoType_M249))
		return HAM_SUPERCEDE
	
	set_pdata_float(id, m_flNextAttack, 4.2, 4)
	set_pdata_float(Ent, m_flTimeWeaponIdle, 4.2, 4)
	SetWeaponAnimation(id, RELOAD_ANIM)
	
	return HAM_SUPERCEDE
}

public fw_Item_PostFrame(Ent)
{
	if(pev(Ent, pev_weapons) != WEAPON_AT4CS)
		return HAM_IGNORED
	
	new id = pev(Ent, pev_owner)
	new Float:flNextAttack = get_pdata_float(id, m_flNextAttack, 5)
	new iBpAmmo = get_pdata_int(id, m_iAmmoType_M249)
	new iClip = get_pdata_int(Ent, m_iClip, 4)
	static fInReload; fInReload = get_pdata_int(Ent, m_fInReload, 4)
	
	if(fInReload && flNextAttack <= 0.0)
	{
		new j = min(get_pcvar_num(cvar_clip) - iClip, iBpAmmo)
		set_pdata_int(Ent, m_iClip, iClip + j, 4)
		set_pdata_int(id, m_iAmmoType_M249, iBpAmmo-j)
		set_pdata_int(Ent, m_fInReload, 0, 4)
		fInReload = 0
	}
	return HAM_IGNORED
}

public fw_Item_AddToPlayer(Ent, id)
{
	if(!is_valid_ent(Ent))
		return HAM_IGNORED
	
	if(pev(Ent, pev_weapons) == WEAPON_AT4CS)
	{
		set_pev(Ent, pev_owner, id)
		set_pdata_float(id, m_flNextAttack, 1.2)
		SetWeaponAnimation(id, DRAW_ANIM)
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

public fw_Rocket_Think(Ent)
{
	if(!pev_valid(Ent))
		return
	new classname[32]
	pev(Ent, pev_classname, classname, 31)
	if (!equal(classname,"at4_rocket"))
		return
	
	new Float:Origin[3]
	new attacker = pev(Ent, pev_owner)
	pev(Ent, pev_origin, Origin)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_SPRITE)
	engfunc(EngFunc_WriteCoord, Origin[0])
	engfunc(EngFunc_WriteCoord, Origin[1])
	engfunc(EngFunc_WriteCoord, Origin[2])
	write_short(g_Spr_Smoke)
	write_byte(2) 
	write_byte(200)
	message_end()
	
	if(!pev(Ent, pev_victim))
	{
		new victim, Float:iOrg[3]
		pev(Ent, pev_origin, iOrg)
		while(0<(victim = engfunc(EngFunc_FindEntityInSphere, victim, iOrg, 600.0))< g_MaxPlayer)
		{
			if(!is_user_alive(victim))
				continue
			if(get_pdata_int(victim, m_CsTeam) != get_pdata_int(attacker, m_CsTeam))	//射对面
				break
		}
		
		if(is_user_alive(victim))
			Rocket_Follow_Victim(Ent, victim)
	}
	
	set_pev(Ent, pev_nextthink, get_gametime() + 0.075)
}

public Rocket_Follow_Victim(Ent, Victim)
{
	if(Victim)
	{
		new Float:Ent_Org[3], Float:Vic_Org[3], Float:fVec[3]
		
		pev(Ent, pev_origin, Ent_Org)
		pev(Victim, pev_origin, Vic_Org)
		
		entity_get_vector(Ent, EV_VEC_angles, fVec)
		
		new Float:x = Vic_Org[0] - Ent_Org[0]
		new Float:z = Vic_Org[1] - Ent_Org[1]
		new Float:radians = floatatan(z/x, radian)
		
		fVec[1] = radians * 180 / 3.14
		if(Vic_Org[0] < Ent_Org[0])
			fVec[1] -= 180.0
		
		entity_set_vector(Ent, EV_VEC_angles, fVec)
		
		new Float:distance_f
		distance_f = get_distance_f(Ent_Org, Vic_Org)
		
		if(distance_f > 10.0)
		{
			new Float:fTime = distance_f / get_pcvar_float(cvar_speed)
			new Float:fVec1[3]
			xs_vec_sub(Vic_Org, Ent_Org, fVec1)
			xs_vec_div_scalar(fVec1, fTime, fVec1)
			entity_set_vector(Ent, EV_VEC_velocity, fVec1)
		}
	}
}

public fw_Rocket_Touch_Post(Ent, Touch)
{
	if(!pev_valid(Ent))
		return
	
	new id = pev(Ent, pev_owner)
	if(id == Touch)
		return
	
	new classname[32]
	pev(Ent, pev_classname, classname, 31)
	if (!equal(classname,"at4_rocket"))
		return
	
	
	static Float:Origin[3]
	pev(Ent, pev_origin, Origin)	
	
	message_begin(MSG_BROADCAST ,SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, Origin[0])
	engfunc(EngFunc_WriteCoord, Origin[1])
	engfunc(EngFunc_WriteCoord, Origin[2])
	write_short(g_Spr_Exp)
	write_byte(20)	// scale in 0.1's
	write_byte(30)
	write_byte(0)
	message_end()
	
	static Victim
	Victim = -1
	new id_team = get_pdata_int(id, m_CsTeam)
	
	while(0<(Victim = engfunc(EngFunc_FindEntityInSphere, Victim, Origin, get_pcvar_float(cvar_radius))) < g_MaxPlayer)
	{
		if(!is_user_alive(Victim) && id_team == get_pdata_int(Victim, m_CsTeam) || id == Victim)
			continue
		
		ExecuteHamB(Ham_TakeDamage, Victim, 0, id, get_pcvar_float(cvar_damage), DE_DMG_ROCKET)
	}
	
	engfunc(EngFunc_RemoveEntity, Ent)
}

public fw_SetModel(Ent, szModel[])
{
	if (!equal(szModel, "models/w_m249.mdl"))
		return FMRES_IGNORED
	
	new szClassName[32]
	pev(Ent, pev_classname, szClassName, charsmax(szClassName))
	
	if (!equal(szClassName, "weaponbox"))
		return FMRES_IGNORED
	
	new iEnt = fm_find_ent_by_owner( -1, weapon_at4cs, Ent )
	
	if(!pev_valid(iEnt))
		return FMRES_IGNORED;
	
	if( pev(iEnt, pev_weapons) == WEAPON_AT4CS )
	{
		engfunc(EngFunc_SetModel, Ent, g_WpnModel[2])
		return FMRES_SUPERCEDE
	}

	return FMRES_IGNORED;
}

public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
	if(!is_user_alive(id))
		return FMRES_IGNORED	
	
	new Ent = get_pdata_cbase(id, m_pActiveItem)
	if(Ent <= 0)
		return FMRES_IGNORED
	
	if(pev(Ent, pev_weapons) == WEAPON_AT4CS)
		set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001) 
	
	return FMRES_HANDLED
}

public fw_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{	
	if (!is_user_connected(invoker))
		return FMRES_IGNORED	
	if(pev(get_pdata_cbase(invoker, m_pActiveItem), pev_weapons) != WEAPON_AT4CS)
		return FMRES_IGNORED
	
	engfunc(EngFunc_PlaybackEvent, flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
	
	return HAM_SUPERCEDE
}

public event_curweapon(id)
{
	if(!is_user_alive(id) || read_data(2) != CSW_AT4CS)
		return
	new Ent = get_pdata_cbase(id, m_pActiveItem)
	if(Ent <= 0)
		return
	
	if(pev(Ent, pev_weapons) == WEAPON_AT4CS)
	{
		set_pev(id, pev_viewmodel2, g_WpnModel[0])
		set_pev(id, pev_weaponmodel2, g_WpnModel[1])
	}
}

