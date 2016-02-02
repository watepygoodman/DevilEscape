#include <amxmodx>
#include <engine>
#include <fakemeta_util>
#include <hamsandwich>
#include <xs>
#include <devilescape>
#include <de_wpn_tool>
#include <cstrike>

#define PLUGIN_NAME	"金红双蝎"
#define PLUGIN_VERSION	"0.0"
#define PLUGIN_AUTHOR "watepy"

new const weapon_infinity[] = "weapon_elite"
new const CSW_INFINITY = CSW_ELITE

new const g_WpnModel[][] = {
	"models/v_infinity.mdl",
	"models/p_infinity.mdl",
	"models/w_infinity.mdl"
}

new const g_WpnSound[][] = {
	"weapons/infi-1.wav",
	"weapons/infi_draw.wav",
	"weapons/infi_clipin.wav",
	"weapons/infi_clipon.wav",
	"weapons/infi_clipout.wav"
}

enum
{
	IDLE,
	IDLE_LEFT_EMPTY,
	SHOOT_LEFT1,
	SHOOT_LEFT2,
	SHOOT_LEFT3,
	SHOOT_LEFT4,
	SHOOT_LEFT5,
	SHOOT_LEFT_LAST,
	SHOOT_RIGHT1,
	SHOOT_RIGHT2,
	SHOOT_RIGHT3,
	SHOOT_RIGHT4,
	SHOOT_RIGHT5,
	SHOOT_RIGHT_LAST,
	RELOAD,
	DRAW,
	SP_SHOOT_LEFT1,
	SP_SHOOT_RIGHT1,
	SP_SHOOT_LEFT2,
	SP_SHOOT_RIGHT2,
	SP_SHOOT_LEaFT_LAST
}

public plugin_precache()
{
	new i
	for( i = 0; i < sizeof g_WpnSound; i++)
		engfunc(EngFunc_PrecacheSound, g_WpnSound[i])
	for( i = 0; i < sizeof g_WpnModel; i++)
		engfunc(EngFunc_PrecacheModel, g_WpnModel[i])
	
}

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	
	register_event("CurWeapon", "event_curweapon", "be", "1=1")
	
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	register_forward(FM_PlaybackEvent, "fw_PlaybackEvent")
	
}

public event_curweapon(id)


public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
	if(!is_user_alive(id))
		return FMRES_IGNORED	
	
	new Ent = get_pdata_cbase(id, m_pActiveItem)
	if(Ent <= 0)
		return FMRES_IGNORED
	
	if(pev(Ent, pev_weapons) == WEAPON_INFINITY)
		set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001) 
	
	return FMRES_HANDLED
}

public fw_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if (!is_user_connected(invoker))
		return FMRES_IGNORED	
	if(pev(get_pdata_cbase(invoker, m_pActiveItem), pev_weapons) != WEAPON_INFINITY)
		return FMRES_IGNORED
	
	engfunc(EngFunc_PlaybackEvent, flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
	
	return HAM_SUPERCEDE
}


