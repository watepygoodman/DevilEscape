#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <xs>
#include <devilescape>

#define PLUGIN_NAME "焚烬者"
#define PLUGIN_VERSION "0.0"
#define PLUGIN_AUTHOR "watepy"

new const CSW_SALAMANDER = CSW_M249
new const weapon_salamander[] = "weapon_m249"

enum{
	IDLE_ANIM, SHOOT_ANIM, SHOOT_END_ANIM, RELOAD_ANIM, DRAW_ANIM
}

enum(+= 21234){
	TASK_STOPFIRE = 32123
}

enum{
	ENT_FIRE_NO_TOUCH, ENT_FIRE_TOUCHED
}

new const g_WpnModel[][] = {
	"models/v_salamander.mdl",
	"models/p_salamander.mdl",
	"models/w_salamander.mdl"
}

new const g_WpnSound[][] = {
	"weapons/flamegun-1.wav",
	"weapons/flamegun-2.wav",
	"weapons/flamegun_draw.wav",
	"weapons/flamegun_clipin1.wav",
	"weapons/flamegun_clipout1.wav",
	"weapons/flamegun_clipout2.wav"
}

new const g_FireSprName[] = "sprites/DevilEscape/fire_salamander.spr"
new cvar_clip, cvar_damage, cvar_price
new bool:g_isFiring[33], bool:g_ReloadBug[33]
new g_Wpnid

public plugin_precache()
{
	new i
	for( i = 0; i < sizeof g_WpnSound; i++)
		engfunc(EngFunc_PrecacheSound, g_WpnSound[i])
	for( i = 0; i < sizeof g_WpnModel; i++)
		engfunc(EngFunc_PrecacheModel, g_WpnModel[i])
	
	precache_model(g_FireSprName)
}

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	
	register_event("CurWeapon", "event_curweapon", "be", "1=1")
	
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	register_forward(FM_PlaybackEvent, "fw_PlaybackEvent")
	
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_SetModel, "fw_SetModel")
	
	RegisterHam(Ham_Item_Deploy, weapon_salamander, "fw_Item_Deploy_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_salamander, "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_Reload, weapon_salamander, "fw_Weapon_Reload")
	RegisterHam(Ham_Weapon_Reload, weapon_salamander, "fw_Weapon_Reload_Post", 1)
	// RegisterHam(Ham_Weapon_WeaponIdle, weapon_salamander, "fw_Weapon_WeaponIdle_Post", 1)
	RegisterHam(Ham_Item_PostFrame, weapon_salamander, "fw_Item_PostFrame")
	RegisterHam(Ham_Item_AddToPlayer, weapon_salamander, "fw_Item_AddToPlayer", 1)
	RegisterHam(Ham_Think,	"env_sprite", "fw_Fire_Think")
	RegisterHam(Ham_Touch, "env_sprite", "fw_Touch_Post", 1)
	
	cvar_damage = register_cvar("wpn_salamander_dmg", "299.0")
	cvar_clip = register_cvar("wpn_salamander_clip", "100")
	cvar_price = register_cvar("de_wpn_salamander_price", "399")
	
	register_clcmd("weapon_salamander", "hook_weapon")
	
	g_Wpnid = de_register_sp_wpn(PLUGIN_NAME, get_pcvar_num(cvar_price))
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
	
	new iEntity = fm_give_item(id, weapon_salamander)
	if (iEntity > 0)
	{
		set_pev(iEntity, pev_weapons, WEAPON_SALAMANDER)
		set_pev(iEntity, pev_owner, id)
		set_pdata_int(iEntity, m_iClip, get_pcvar_num(cvar_clip), 4)
		SetWeaponAnimation(id, DRAW_ANIM)
		set_pdata_int(id, m_iAmmoType_M249, 200)
	}
}

public hook_weapon(id)
{
	if(is_user_alive(id))
		engclient_cmd(id, "weapon_m249")
	
	return PLUGIN_HANDLED
}

/*=================================

					Function
	
=================================*/

public event_curweapon(id)
{
	if(!is_user_alive(id) || read_data(2) != CSW_SALAMANDER)
		return
	new Ent = get_pdata_cbase(id, m_pActiveItem)
	if(Ent <= 0)
		return
	
	if(pev(Ent, pev_weapons) == WEAPON_SALAMANDER)
	{
		set_pev(id, pev_viewmodel2, g_WpnModel[0])
		set_pev(id, pev_weaponmodel2, g_WpnModel[1])
		// SetWeaponAnimation(id, DRAW_ANIM)
	}
}

public fw_Item_Deploy_Post(Ent)
{
	if (pev(Ent, pev_weapons) != WEAPON_SALAMANDER)
		return HAM_IGNORED
	
	new id = pev(Ent, pev_owner)
	set_pev(id, pev_viewmodel2, g_WpnModel[0])
	set_pev(id, pev_weaponmodel2, g_WpnModel[1])
	SetWeaponAnimation(id, DRAW_ANIM)
	set_pdata_float(Ent, m_flNextPrimaryAttack, 1.0, 4)
	
	return HAM_SUPERCEDE
}

//开火
public fw_Weapon_PrimaryAttack(Ent)
{
	if(pev(Ent, pev_weapons) != WEAPON_SALAMANDER)
		return HAM_IGNORED
	
	new iClip = get_pdata_int(Ent, m_iClip, 4)
	if (!iClip) return HAM_IGNORED
	
	new id = pev(Ent, pev_owner)
	remove_task(id+TASK_STOPFIRE)
	set_pdata_float(Ent, m_flTimeWeaponIdle, 1.0, 5) 
	set_pdata_float(Ent, m_flNextPrimaryAttack, 0.12, 4)
	set_pdata_int(Ent, m_iClip, iClip-1, 4)
	SetWeaponAnimation(id, SHOOT_ANIM)
	engfunc(EngFunc_EmitSound, Ent, CHAN_ITEM, g_WpnSound[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	Weapon_ThrowFire(id)
	g_isFiring[id] = true
	return HAM_SUPERCEDE
}

public Weapon_ThrowFire(id)
{
	new Float:vfVelocity[3], Float:StartOrigin[3], Float:vfAngle[3], Float:AimOrg[3]
	new Float:PlrOrg[3]
	get_position(id, 50.0, 5.0, -5.0, StartOrigin)	//枪口坐标
	
	new Ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_sprite"))
	
	pev(id, pev_origin, PlrOrg)
	pev(id, pev_view_ofs, vfVelocity)
	pev(id, pev_angles, vfAngle)
	
	xs_vec_add(PlrOrg, vfVelocity, PlrOrg)
	velocity_by_aim(id, 800, vfVelocity)
	xs_vec_mul_scalar(vfVelocity, 0.8, vfVelocity)
	xs_vec_add(PlrOrg, vfVelocity, AimOrg)
	
	set_pev(Ent, pev_movetype, MOVETYPE_FLY)
	set_pev(Ent, pev_rendermode, kRenderTransAdd)
	set_pev(Ent, pev_renderamt, 150.0)
	set_pev(Ent, pev_fuser1, get_gametime() + 1.5)	//Life
	set_pev(Ent, pev_nextthink, get_gametime() + 0.1)
	set_pev(Ent, pev_scale, 0.2)
	
	set_pev(Ent, pev_classname, "salamander_fire")
	engfunc(EngFunc_SetModel, Ent, g_FireSprName)
	set_pev(Ent, pev_mins, Float:{-1.0, -1.0, -1.0})
	set_pev(Ent, pev_maxs, Float:{1.0, 1.0, 1.0})
	set_pev(Ent, pev_origin, StartOrigin)
	set_pev(Ent, pev_gravity, 0.01)
	set_pev(Ent, pev_velocity, vfVelocity)
	
	vfAngle[1] += 30.0
	set_pev(Ent, pev_angles, vfAngle)
	set_pev(Ent, pev_solid, SOLID_BBOX)
	set_pev(Ent, pev_owner, id)
	set_pev(Ent, pev_iuser2, ENT_FIRE_NO_TOUCH)
}

public fw_Weapon_Reload(Ent)
{
	if(pev(Ent, pev_weapons) != WEAPON_SALAMANDER)
		return HAM_IGNORED
	
	new id = pev(Ent, pev_owner)
	new iClip = get_pdata_int(Ent, m_iClip, 4)
	
	if(iClip >= get_pcvar_num(cvar_clip) || !get_pdata_int(id, m_iAmmoType_M249))
		return HAM_SUPERCEDE
	
	if(iClip == 100) //Bug
	{
		g_ReloadBug[id] = true
		set_pdata_int(Ent, iClip, 0, 4)
	}
	
	return HAM_IGNORED
}

public fw_Weapon_Reload_Post(Ent)
{
	if (pev(Ent, pev_weapons) != WEAPON_SALAMANDER)
		return
	
	new id = pev(Ent, pev_owner)
	new iClip = get_pdata_int(Ent, m_iClip, 4)
	if(iClip >= get_pcvar_num(cvar_clip) || !get_pdata_int(id, m_iAmmoType_M249))
		return
	
	if (g_ReloadBug[id])
	{
		g_ReloadBug[id] = false
		set_pdata_int(Ent, m_iClip, 30, 4)
	}
	
	set_pdata_float(id, m_flNextAttack, 5.0, 4)
	set_pdata_float(Ent, m_flTimeWeaponIdle, 5.0, 4)
	SetWeaponAnimation(id, RELOAD_ANIM)
}

public fw_SetModel(Ent, szModel[])
{
	if (!equal(szModel, "models/w_m249.mdl"))
		return FMRES_IGNORED
	
	new szClassName[32]
	pev(Ent, pev_classname, szClassName, charsmax(szClassName))
	
	if (!equal(szClassName, "weaponbox"))
		return FMRES_IGNORED
	
	new iEnt = fm_find_ent_by_owner( -1, weapon_salamander, Ent )
	
	if(!pev_valid(iEnt))
		return FMRES_IGNORED;
	
	if( pev(iEnt, pev_weapons) == WEAPON_SALAMANDER )
	{
		engfunc(EngFunc_SetModel, Ent, g_WpnModel[2])
		return FMRES_SUPERCEDE
	}

	return FMRES_IGNORED;
}

public fw_Item_PostFrame(Ent)
{
	if (pev(Ent, pev_weapons) != WEAPON_SALAMANDER)
		return HAM_IGNORED
	
	new id = pev(Ent, pev_owner)
	new Float:flNextAttack = get_pdata_float(id, m_flNextAttack, 5)
	new iBpAmmo = get_pdata_int(id, m_iAmmoType_M249)
	new iClip = get_pdata_int(Ent, m_iClip, 4)
	new fInReload = get_pdata_int(Ent, m_fInReload, 4)
	
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
	
	if(pev(Ent, pev_weapons) == WEAPON_SALAMANDER)
	{
		set_pev(Ent, pev_owner, id)
		set_pdata_float(id, m_flNextAttack, 1.0)
		SetWeaponAnimation(id, DRAW_ANIM)
	}
	return HAM_HANDLED
}

public fw_CmdStart(id, uc_handle, seed)
{
	if(!is_user_alive(id) || !is_user_connected(id))
		return
	
	new Ent = get_pdata_cbase(id, m_pActiveItem)
	
	if(!pev_valid(Ent))
		return
	
	if(pev(Ent, pev_weapons) != WEAPON_SALAMANDER)
		return
	
	static Button
	Button = get_uc(uc_handle, UC_Buttons)
	
	if(!(Button & IN_ATTACK) && g_isFiring[id])
	{
		if(!task_exists(id+TASK_STOPFIRE))
		{
			set_task(0.1, "task_stopfire", id+TASK_STOPFIRE)
			emit_sound(id, CHAN_WEAPON, g_WpnSound[1], 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
	}
}

public fw_Fire_Think(Ent)
{
	new classname[32]
	pev(Ent, pev_classname, classname, 31)
	if (!equal(classname,"salamander_fire"))
		return
	
	new Float:Life
	pev(Ent, pev_fuser1, Life)
	
	if (Life < get_gametime())
	{
		if(pev_valid(Ent))
		engfunc(EngFunc_RemoveEntity, Ent)
		return
	}
	
	new Float:Frame, Float:Scale, Float:NextThink
	
	pev(Ent, pev_frame, Frame)
	
	if(pev(Ent, pev_fuser2) == ENT_FIRE_TOUCHED)
	{
		NextThink = 0.015
		Frame += 1.0
		
		if (Frame > 21.0)
		{
			engfunc(EngFunc_RemoveEntity, Ent)
			return
		}
	}
	else
	{
		NextThink = 0.045
		Frame += 1.0
		Frame = floatmin(21.0, Frame)
	}
	Scale = floatmin(entity_range(Ent, pev(Ent, pev_owner)) / 750 * 3.0, 10.0)
	
	
	set_pev(Ent, pev_nextthink, get_gametime() + NextThink)
	set_pev(Ent, pev_frame, Frame)
	set_pev(Ent, pev_scale, Scale)
}

public fw_Touch_Post(Ent, id)
{
	if (!pev_valid(Ent))
		return
	
	new classname[32]
	pev(Ent, pev_classname, classname, 31)
	if (!equal(classname, "salamander_fire"))
		return
	
	new Attacker = pev(Ent, pev_owner)
	if(Attacker == id || !is_user_alive(id) || !is_user_connected(id))
		return
	
	set_pev(Ent, pev_movetype, MOVETYPE_NONE)
	set_pev(Ent, pev_solid, SOLID_NOT)
	
	// client_print(0, print_chat, "Touched")
	
	if(pev(Ent, pev_iuser2) == ENT_FIRE_NO_TOUCH)
	{
		set_pev(Ent, pev_iuser2, ENT_FIRE_TOUCHED)
		ExecuteHamB(Ham_TakeDamage, id, Ent, Attacker, get_pcvar_float(cvar_damage), DMG_BULLET)
		
	}
}

public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
	if(!is_user_alive(id))
		return FMRES_IGNORED	
	
	new Ent = get_pdata_cbase(id, m_pActiveItem)
	if(Ent <= 0)
		return FMRES_IGNORED
	
	if(pev(Ent, pev_weapons) == WEAPON_SALAMANDER)
		set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001) 
	
	return FMRES_HANDLED
}

public fw_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if (!is_user_connected(invoker))
		return FMRES_IGNORED	
	if(pev(get_pdata_cbase(invoker, m_pActiveItem), pev_weapons) != WEAPON_SALAMANDER)
		return FMRES_IGNORED
	
	engfunc(EngFunc_PlaybackEvent, flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
	
	return HAM_SUPERCEDE
}

public task_stopfire(id)
{
	id-=TASK_STOPFIRE
	g_isFiring[id] = false
	if(pev(id, pev_weaponanim) != SHOOT_END_ANIM)
		SetWeaponAnimation(id, SHOOT_END_ANIM)
}

stock SetWeaponAnimation(id, anim)
{
	if(!is_user_alive(id))
		return
	
	// client_print(id, print_center, "Anim:%d", anim)
	set_pev(id, pev_weaponanim, anim)
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, {0, 0, 0}, id)
	write_byte(anim)
	write_byte(pev(id, pev_body))
	message_end()
}

stock get_position(id, Float:forw, Float:right, Float:up, Float:vStart[])
{
	static Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3]
	
	pev(id, pev_origin, vOrigin)
	pev(id, pev_view_ofs, vUp) //for player
	xs_vec_add(vOrigin, vUp, vOrigin)
	pev(id, pev_v_angle, vAngle) // if normal entity ,use pev_angles
	
	angle_vector(vAngle, ANGLEVECTOR_FORWARD, vForward) //or use EngFunc_AngleVectors
	angle_vector(vAngle, ANGLEVECTOR_RIGHT, vRight)
	angle_vector(vAngle, ANGLEVECTOR_UP, vUp)
	
	vStart[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up
	vStart[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up
	vStart[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up
}

// stock fm_give_item(index, const wEntity[])
// {
	// new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, wEntity))
	// new Float:origin[3]
	// pev(index, pev_origin, origin)
	// set_pev(iEntity, pev_origin, origin)
	// set_pev(iEntity, pev_spawnflags, pev(iEntity, pev_spawnflags) | SF_NORESPAWN)
	// dllfunc(DLLFunc_Spawn, iEntity)
	// new save = pev(iEntity, pev_solid)
	// dllfunc(DLLFunc_Touch, iEntity, index)
	// if(pev(iEntity, pev_solid) != save) return iEntity
	// engfunc(EngFunc_RemoveEntity, iEntity)
	// return -1
// }

// stock fm_find_ent_by_owner(index, const classname[], owner, jghgtype = 0) {
	// new strtype[11] = "classname", ent = index
	// switch (jghgtype) {
		// case 1: strtype = "target"
		// case 2: strtype = "targetname"
	// }

	// while ((ent = engfunc(EngFunc_FindEntityByString, ent, strtype, classname)) && pev(ent, pev_owner) != owner) {}

	// return ent
// }



