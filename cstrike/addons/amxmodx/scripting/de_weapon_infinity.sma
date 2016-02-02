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

#define PEV_LEFT_ATTACk pev_iuser1

const WPNSTATE_ELITE_LEFT = (1<<3)
const WPNSTATE_ELITE_SP_LEFT = 1

new const weapon_infinity[] = "weapon_elite"
new const CSW_INFINITY = CSW_ELITE

new const PEV_SP_LEFT = pev_iuser1

new const g_EntNames[][] =
{	 
	"worldspawn","func_wall","info_target","func_wall_toggle",
	"func_rotating","func_door","func_door_rotating","func_pendulum",
	"func_vehicle","func_breakable","func_button"
}

new const g_WpnModel[][] = {
	"models/v_infinityex2.mdl",
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
	SP_SHOOT_LEFT_LAST
}

new g_Wpnid

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
	
	RegisterHam(Ham_Item_Deploy, weapon_infinity, "fw_Item_Deploy_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_infinity, "fw_Weapon_PrimaryAttack")
	
	// RegisterHam(Ham_Weapon_PrimaryAttack, weapon_infinity, "fw_Weapon_PrimaryAttack_Post", 1)
	// RegisterHam(Ham_Weapon_Reload, weapon_infinity, "fw_Weapon_Reload")
	register_forward(FM_CmdStart, "fw_CmdStart")
	
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	register_forward(FM_PlaybackEvent, "fw_PlaybackEvent")
	
	register_clcmd("weapon_infinity", "hook_weapon")
	
	for(new i = 0; i < sizeof(g_EntNames); i++)
		RegisterHam(Ham_TraceAttack, g_EntNames[i], "fw_TraceAttack")
	
	g_Wpnid = de_register_second_wpn(PLUGIN_NAME, 100)
}

public de_secondwpn_select(id, wid)
{
	if(g_Wpnid == wid)
		give_weapon(id)
}

public give_weapon(id)
{
	if (!is_user_alive(id))
		return 
	
	new iEntity = fm_give_item(id, weapon_infinity)
	if (iEntity > 0)
	{
		set_pev(iEntity, pev_weapons, WEAPON_INFINITY)
		set_pev(iEntity, pev_owner, id)
		// set_pdata_int(iEntity, m_iClip, get_pcvar_num(cvar_clip), 4)
		cs_set_user_bpammo(id, CSW_INFINITY, 120)
		set_pev(iEntity, PEV_SP_LEFT, 1)
	}
}

public hook_weapon(id)
{
	if(is_user_alive(id))
		engclient_cmd(id, "weapon_m249")
	
	return PLUGIN_HANDLED
}


public event_curweapon(id)
{
	if(!is_user_alive(id) || read_data(2) != CSW_INFINITY)
		return
	new Ent = get_pdata_cbase(id, m_pActiveItem)
	if(Ent <= 0)
		return
	
	if(pev(Ent, pev_weapons) == WEAPON_INFINITY)
	{
		set_pev(id, pev_viewmodel2, g_WpnModel[0])
		set_pev(id, pev_weaponmodel2, g_WpnModel[1])
	}
}

public fw_Item_Deploy_Post(Ent)
{
	if (pev(Ent, pev_weapons) != WEAPON_INFINITY)
		return HAM_IGNORED
	
	new id = pev(Ent, pev_owner)
	set_pev(id, pev_viewmodel2, g_WpnModel[0])
	set_pev(id, pev_weaponmodel2, g_WpnModel[1])
	SetWeaponAnimation(id, DRAW)
	set_pdata_float(Ent, m_flNextPrimaryAttack, 0.7, 4)
	
	return HAM_SUPERCEDE
}

public fw_Weapon_PrimaryAttack(Ent)
{
	if(pev(Ent, pev_weapons) != WEAPON_INFINITY)
		return //HAM_IGNORED
	
	static iClip 
	iClip = get_pdata_int(Ent, m_iClip, 4)
	if (!iClip) 
		return //HAM_IGNORED
	
	if(get_pdata_int(Ent, m_iShotsFired, 4) >= 1)
		return
	
	static id 
	id = pev(Ent, pev_owner)
	// set_pdata_float(Ent, m_flTimeWeaponIdle, 2.0, 5) 
	// set_pdata_float(Ent, m_flNextPrimaryAttack, 0.12, 4)
	emit_sound(id, CHAN_WEAPON, g_WpnSound[0], 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	static wpn_state
	wpn_state = get_pdata_int(Ent, m_iWeaponState) & WPNSTATE_ELITE_LEFT
	
	if(iClip != 1)
	{
		if(wpn_state)
			SetWeaponAnimation(id, random_num(SHOOT_LEFT1, SHOOT_LEFT5))
		else SetWeaponAnimation(id, SHOOT_RIGHT3)
	}
	else
	{
		if(wpn_state)
			SetWeaponAnimation(id, SHOOT_LEFT_LAST)
		else SetWeaponAnimation(id, SHOOT_RIGHT_LAST)
	}
}

public fw_TraceAttack(ent, attacker, Float:Damage, Float:fDir[3], ptr, iDamageType)
{
	if(!is_user_alive(attacker))
		return HAM_IGNORED
	
	new Ent = get_pdata_cbase(attacker, m_pActiveItem)
	
	if(pev(Ent, pev_weapons) != WEAPON_INFINITY)
		return HAM_IGNORED
	
	static Float:flEnd[3]
	get_tr2(ptr, TR_vecEndPos, flEnd)
	
	make_bullet(attacker, flEnd)
	
	return HAM_HANDLED
}

public fw_CmdStart(id, uc_handle, seed)
{
	if(!is_user_alive(id) || !is_user_connected(id))
		return
	
	new Ent = get_pdata_cbase(id, m_pActiveItem)
	
	if(Ent <= 0)
		return
	
	if(pev(Ent, pev_weapons) != WEAPON_INFINITY)
		return
	
	static Button, OldButton
	Button = get_uc(uc_handle, UC_Buttons)
	OldButton = pev(id, pev_oldbuttons)
	if((Button & IN_ATTACK2))
	{
		static iClip, SpAttackMode
		static Float:fNextSpAttack
		iClip = get_pdata_int(Ent, m_iClip, 4)
		fNextSpAttack = get_pdata_float(Ent, m_flNextSecondaryAttack)
		if(fNextSpAttack > 0.0)
			return
		
		if (!iClip)
		{
			set_pdata_float(Ent, m_flNextSecondaryAttack, 0.2)
			emit_sound(Ent, CHAN_WEAPON, "weapons/dryfire_pistol.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			return
		}
		
		emit_sound(id, CHAN_WEAPON, g_WpnSound[0], 1.0, ATTN_NORM, 0, PITCH_NORM)
		set_pdata_float(Ent, m_flNextSecondaryAttack, 0.09)
		set_pdata_float(Ent, m_flTimeWeaponIdle, 1.0, 5) 
		set_pdata_int(Ent, m_iClip, iClip-1 ,4)
		
		if(pev(Ent, PEV_SP_LEFT))
		{
			SetWeaponAnimation(id, SpAttackMode?SP_SHOOT_LEFT1:SP_SHOOT_LEFT2)
			set_pev(Ent, PEV_SP_LEFT, 0)
		}
		else 
		{
			SetWeaponAnimation(id, SpAttackMode?SP_SHOOT_RIGHT1:SP_SHOOT_RIGHT2)
			set_pev(Ent, PEV_SP_LEFT, 1)
		}
		
		static Float:vAngle[3]
		vAngle[1] = random_float(-3.0, 3.0)
		set_pev(id, pev_punchangle, vAngle)
		set_pev(id, pev_fixangle, 1)
		
		static Float:Start[3], Float:End[3], Float:PlrOrg[3]
		pev(id, pev_origin, PlrOrg)
		pev(id, pev_view_ofs, Start)
		xs_vec_add(PlrOrg, Start, Start)
		velocity_by_aim(id, 1024, End)
		xs_vec_add(Start, End, End)
		
		static tr, victim
		engfunc(EngFunc_TraceLine, Start, End, 0, id, tr)
		victim = get_tr2(tr, TR_pHit)
		if( !is_user_alive(victim) )
		{
			get_tr2(tr, TR_vecEndPos, End)
			make_bullet(id, End)
		}
		else
		{
			new Float:dmg = 36.0
			switch(get_tr2(tr,TR_iHitgroup))
			{
				case HIT_HEAD: dmg*= 1.5
				case HIT_CHEST..HIT_STOMACH: dmg*= 1.25
				case HIT_LEFTARM..HIT_RIGHTARM: dmg*= 1.1
				case HIT_LEFTLEG..HIT_RIGHTLEG: dmg*= 0.9
			}
			ExecuteHamB(Ham_TakeDamage, victim, Ent, id, dmg, DMG_BULLET)
			//定身效果
			//懒得写了
		}
		
		if(!(OldButton & IN_ATTACK2))
			SpAttackMode = random_num(0, 1)
	}
}

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


