#include <amxmodx>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <xs>
#include <devilescape>
#include <cstrike>
#include <engine>

#define PLUGIN_NAME		"QBS09(for devilescape)"
#define PLUGIN_VERSION	"1.0"
#define PLUGIN_AUTHOR	"Apppppppppp"

new const CSW_QBS09 = CSW_XM1014
new const weapon_qbs09[] = "weapon_xm1014"

enum{
	IDLE_ANIM, SHOOT_ANIM, SHOOT2_ANIM, RELOAD_ANIM, ENDRELOAD_ANIM, STARTRELOAD_ANIM, DRAW_ANIM
}

new const g_WpnSound[][] = {
	"weapons/qbs09_shoot.wav",
	"weapons/qbs09_draw.wav", 
	"weapons/qbs09_start_reload.wav",
	"weapons/qbs09_insert.wav" , 
	"weapons/qbs09_reload.wav"
}

new const g_WpnModel[][] = {
	"models/v_qbs09.mdl",
	"models/p_xm1014.mdl",
	"models/w_qbs09.mdl"
}

new const g_EntNames[][] =
{	 
	"worldspawn","player","func_wall","info_target","func_wall_toggle",
	"func_rotating","func_door","func_door_rotating","func_pendulum",
	"func_vehicle","func_breakable","func_button"
}

new bool:g_isReload[33]

new g_smokepuff_id;

new cvar_damage, cvar_clip, cvar_reloadspd, cvar_reloadtime, cvar_attacktime, cvar_startreloadtime

public plugin_precache()
{
	cvar_damage = register_cvar("wpn_qbs09_damage", "50.0")
	cvar_clip = register_cvar("wpn_qbs09_clip", "5")
	cvar_reloadspd = register_cvar("wpn_qbs09_reloadspd","0.5")
	cvar_reloadtime = register_cvar("wpn_qbs09_reloadtime","3.5")
	cvar_attacktime = register_cvar("wpn_qbs09_attacktime","0.3")
	cvar_startreloadtime = register_cvar("wpn_qbs09_startreloadtime","0.6")
	
	g_smokepuff_id = engfunc(EngFunc_PrecacheModel, "sprites/wall_puff1.spr")
	
	new i
	for( i = 0; i < sizeof g_WpnSound; i++)
		engfunc(EngFunc_PrecacheSound, g_WpnSound[i])
	for( i = 0; i < sizeof g_WpnModel; i++)
		engfunc(EngFunc_PrecacheModel, g_WpnModel[i])
}

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

	register_event("CurWeapon", "CurrentWeapon", "be", "1=1")
	
	register_forward(FM_PlaybackEvent, "fw_PlaybackEvent")
	register_forward(FM_SetModel,"fw_SetModel")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)

	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	RegisterHam(Ham_Item_Deploy, weapon_qbs09, "fw_Item_Deploy_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_qbs09, "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_Reload, weapon_qbs09, "fw_Weapon_Reload")
	RegisterHam(Ham_Item_PostFrame, weapon_qbs09, "fw_ItemPostFrame")
	RegisterHam(Ham_Item_Holster, weapon_qbs09, "Fw_Holster_Post", 1)
	RegisterHam(Ham_Item_AddToPlayer, weapon_qbs09, "fw_Item_AddToPlayer", 1)
	
	for(new i = 0; i < sizeof(g_EntNames); i++)
	{
		RegisterHam(Ham_TraceAttack, g_EntNames[i], "fw_TraceAttack")
		RegisterHam(Ham_TakeDamage, g_EntNames[i], "fw_TakeDamage")
	}
	
	register_clcmd("weapon_qbs09", "hook_weapon")
}

public plugin_natives ()
{
	register_native("wpn_give_qbs09", "native_give_weapon_add", 1)
}

public native_give_weapon_add(id)
{
	give_weapon(id)
}

public hook_weapon(id)
{
	if(is_user_alive(id))
		engclient_cmd(id, "weapon_xm1014")
	
	return PLUGIN_HANDLED
}

public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
	if(!is_user_alive(id))
		return FMRES_IGNORED	
	
	if(pev(get_pdata_cbase(id, m_pActiveItem), pev_weapons) == WEAPON_QBS09)
		set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001) 
	
	return FMRES_HANDLED
}

public fw_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if (!is_user_alive(invoker))
		return HAM_IGNORED	
	if(get_user_weapon(invoker) != CSW_QBS09)
		return HAM_IGNORED
	
	engfunc(EngFunc_PlaybackEvent, flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
	
	return HAM_SUPERCEDE
}

public fw_SetModel(iEntity, szModel[])
{
	if (strcmp(szModel, "models/w_xm1014.mdl"))
	return FMRES_IGNORED
	
	static szClassName[32]
	pev(iEntity, pev_classname, szClassName, charsmax(szClassName))
	if (strcmp(szClassName, "weaponbox"))
	return FMRES_IGNORED
	
	new const m_rgpPlayerItems_CWeaponBox[6] = { 34, 35, 36, 37, 38, 39 }
	new iEntity2 = get_pdata_cbase(iEntity, m_rgpPlayerItems_CWeaponBox[1], 4)
	// new id = pev(iEntity, pev_owner)
	
	if (!pev_valid(iEntity2))
	return FMRES_IGNORED
	
	if (pev(iEntity2, pev_weapons) != WEAPON_QBS09)
	return FMRES_IGNORED

	engfunc(EngFunc_SetModel, iEntity, g_WpnModel[2])
	return FMRES_SUPERCEDE
}

public give_weapon(id)
{
	if (!is_user_alive(id))
		return 

	drop_weapons(id, 1)
	new iEntity = fm_give_item(id, weapon_qbs09)
	if (iEntity > 0)
	{
		set_pev(iEntity, pev_weapons, WEAPON_QBS09)
		set_pev(iEntity, pev_owner, id)
		set_pdata_int(iEntity, m_iClip, get_pcvar_num(cvar_clip), 4)
	}
}

public fw_Item_Deploy_Post(iEntity)
{
	if (pev(iEntity, pev_weapons) != WEAPON_QBS09)
		return HAM_IGNORED
	
	new id = pev(iEntity, pev_owner)
	set_pev(id, pev_viewmodel2, g_WpnModel[0])
	set_pev(id, pev_weaponmodel2, g_WpnModel[1])
	UTIL_PlayWeaponAnimation(id, DRAW_ANIM)
	set_pdata_float(iEntity, m_flNextPrimaryAttack, 0.75, 4)
	
	return HAM_SUPERCEDE
}

public CurrentWeapon(id)
{
	if(!is_user_alive(id) || read_data(2) != CSW_QBS09)
		return

	new iEntity = get_pdata_cbase(id, m_pActiveItem)
	if (iEntity <= 0)
		return
	
	if(pev(iEntity, pev_weapons) == WEAPON_QBS09)
	{
		set_pev(id, pev_viewmodel2, g_WpnModel[0])
		set_pev(id, pev_weaponmodel2, g_WpnModel[1])
	}
}

public fw_Weapon_PrimaryAttack(iEntity)
{
	if (pev(iEntity, pev_weapons) != WEAPON_QBS09)
		return HAM_IGNORED

	if (!get_pdata_int(iEntity, m_iClip, 4))
		return HAM_IGNORED

	new id = pev(iEntity,pev_owner)
	
	if(task_exists(iEntity + 15000)) remove_task(iEntity + 15000)
	if(g_isReload[id]) g_isReload[id] = false

	//Weapon_OpenFire(id,iEntity)
	UTIL_PlayWeaponAnimation(id, random_num(1, 2))
	
	set_pdata_float(iEntity, m_flNextPrimaryAttack, get_pcvar_float(cvar_attacktime), 4)
	set_pdata_float(id, m_flNextAttack, get_pcvar_float(cvar_attacktime), 5)
	
	engfunc(EngFunc_EmitSound, iEntity, CHAN_ITEM, g_WpnSound[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	return HAM_IGNORED
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	if(!is_user_connected(attacker) || !is_user_connected(victim))
	return HAM_HANDLED
	
	if (victim != attacker && is_user_connected(attacker))
	{
		if(get_user_weapon(attacker) == CSW_QBS09)
		SetHamParamFloat(4,  damage + get_pcvar_float(cvar_damage))
	}
	
	return HAM_HANDLED
}

public fw_TraceAttack(ent, attacker, Float:Damage, Float:fDir[3], ptr, iDamageType)
{
	if(!is_user_alive(attacker) || !is_user_connected(attacker))
		return HAM_IGNORED	
	if(get_user_weapon(attacker) != CSW_QBS09)
		return HAM_IGNORED
		
	static Float:flEnd[3], Float:vecPlane[3]
	
	get_tr2(ptr, TR_vecEndPos, flEnd)
	get_tr2(ptr, TR_vecPlaneNormal, vecPlane)		
		
	if(!is_user_alive(ent))
	{
		make_bullet(attacker, flEnd)
		fake_smoke(attacker, ptr)
	}

	return HAM_HANDLED
}

public fw_ItemPostFrame(iEntity) 
{
	if (pev(iEntity, pev_weapons) != WEAPON_QBS09)
		return HAM_IGNORED

	new id = pev(iEntity, pev_owner)
	new Float:flNextAttack = get_pdata_float(id, m_flNextAttack, 5)
	new iBpAmmo = get_pdata_int(id, m_iAmmoType_XM1014)
	new iClip = get_pdata_int(iEntity, m_iClip, 4)
	new fInReload = get_pdata_int(iEntity, m_fInReload, 4)

	if (fInReload && flNextAttack <= 0.0)
	{
		new j = min(get_pcvar_num(cvar_clip) - iClip, iBpAmmo)
		set_pdata_int(iEntity, m_iClip, iClip + j, 4)
		set_pdata_int(id, m_iAmmoType_XM1014, iBpAmmo-j)
		set_pdata_int(iEntity, m_fInReload, 0, 4)
		fInReload = 0
	}
	return HAM_IGNORED
}

public fw_Weapon_Reload(iEntity) 
{
	if (pev(iEntity, pev_weapons) != WEAPON_QBS09)
		return HAM_IGNORED

	new id = pev(iEntity, pev_owner)
	new iClip = get_pdata_int(iEntity, m_iClip, 4)

	if(pev(id, pev_fuser3) > get_gametime() || iClip >= get_pcvar_num(cvar_clip) || !get_pdata_int(id, m_iAmmoType_XM1014))
		return HAM_SUPERCEDE
	
	UTIL_PlayWeaponAnimation(id, STARTRELOAD_ANIM)
	set_pdata_float(iEntity, m_flTimeWeaponIdle, get_pcvar_float(cvar_reloadtime) + 1.0, 5)
	set_pdata_float(id, m_flNextAttack, get_pcvar_float(cvar_reloadtime), 5)
	
	if(!g_isReload[id])
	{
		if(!task_exists(iEntity+ 15000))
		set_task(get_pcvar_float(cvar_startreloadtime), "reloading", iEntity + 15000)
		g_isReload[id] = true
	}
	
	return HAM_SUPERCEDE
}

public reloading(iEntity)
{
	iEntity -= 15000
	
	if(!pev_valid(iEntity))
		return

	new id = pev(iEntity, pev_owner)
	
	if(get_user_weapon(id) != CSW_QBS09)
		return
	
	if(get_pdata_int(iEntity,m_iClip,4) < get_pcvar_num(cvar_clip))
	{
		UTIL_PlayWeaponAnimation(id, RELOAD_ANIM)
		set_pdata_int(iEntity, m_iClip, get_pdata_int(iEntity,m_iClip,4) + 1, 4)
		
		new bpammo = cs_get_user_bpammo(id, CSW_QBS09)
		if(bpammo) cs_set_user_bpammo(id, CSW_QBS09, bpammo - 1)
		set_pdata_float(iEntity, m_flTimeWeaponIdle, 0.9, 5)
		
		set_task(get_pcvar_float(cvar_reloadspd), "reloading", iEntity + 15000)
	}
	else
	{
		UTIL_PlayWeaponAnimation(id, ENDRELOAD_ANIM)
		set_pdata_float(iEntity, m_flTimeWeaponIdle, 0.6, 5)
		set_pdata_float(id, m_flNextAttack, 0.6, 5)
		remove_task(iEntity + 15000)
		g_isReload[id] = false
		remove_task(iEntity + 15000)
	}
}

public Fw_Holster_Post(iEntity)
{
	if(!pev_valid(iEntity))
		return
	
	new id = pev(iEntity,pev_owner)
	
	if(g_isReload[id]) g_isReload[id] = false
	
	remove_task(iEntity + 15000)
}

public fw_Item_AddToPlayer(Ent, id)
{
	if(!is_valid_ent(Ent))
		return HAM_IGNORED
	
	if(pev(Ent, pev_weapons) == WEAPON_QBS09)
	{
		set_pev(Ent, pev_owner, id)
		set_pdata_float(id, m_flNextAttack, 0.75)
		UTIL_PlayWeaponAnimation(id, DRAW_ANIM)
	}
	return HAM_HANDLED
}

stock UTIL_PlayWeaponAnimation(const Player, const Sequence)
{
	set_pev(Player, pev_weaponanim, Sequence)
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = Player)
	write_byte(Sequence)
	write_byte(pev(Player, pev_body))
	message_end()
}

stock drop_weapons(iPlayer, Slot)
{
	new item = get_pdata_cbase(iPlayer, 367+Slot, 4)
	while(item > 0)
	{
		static classname[24]
		pev(item, pev_classname, classname, charsmax(classname))
		engclient_cmd(iPlayer, "drop", classname)
		item = get_pdata_cbase(item, 42, 5)
	}
	set_pdata_cbase(iPlayer, 367, -1, 4)
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

stock make_bullet(id, Float:Origin[3])
{
	new decal = random_num(41, 45)
	const loop_time = 2
	
	static Body, Target
	get_user_aiming(id, Target, Body, 999999)
	
	if(is_user_connected(Target))
		return
	
	for(new i = 0; i < loop_time; i++)
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_WORLDDECAL)
		engfunc(EngFunc_WriteCoord, Origin[0])
		engfunc(EngFunc_WriteCoord, Origin[1])
		engfunc(EngFunc_WriteCoord, Origin[2])
		write_byte(decal)
		message_end()
	
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_GUNSHOTDECAL)
		engfunc(EngFunc_WriteCoord, Origin[0])
		engfunc(EngFunc_WriteCoord, Origin[1])
		engfunc(EngFunc_WriteCoord, Origin[2])
		write_short(id)
		write_byte(decal)
		message_end()
	}
}

stock fake_smoke(id, trace_result)
{
	static Float:vecSrc[3], Float:vecEnd[3], TE_FLAG
	
	get_weapon_attachment(id, vecSrc)
	global_get(glb_v_forward, vecEnd)
    
	xs_vec_mul_scalar(vecEnd, 8192.0, vecEnd)
	xs_vec_add(vecSrc, vecEnd, vecEnd)

	get_tr2(trace_result, TR_vecEndPos, vecSrc)
	get_tr2(trace_result, TR_vecPlaneNormal, vecEnd)
    
	xs_vec_mul_scalar(vecEnd, 2.5, vecEnd)
	xs_vec_add(vecSrc, vecEnd, vecEnd)
    
	TE_FLAG |= TE_EXPLFLAG_NODLIGHTS
	TE_FLAG |= TE_EXPLFLAG_NOSOUND
	TE_FLAG |= TE_EXPLFLAG_NOPARTICLES
	
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, vecEnd, 0)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, vecEnd[0])
	engfunc(EngFunc_WriteCoord, vecEnd[1])
	engfunc(EngFunc_WriteCoord, vecEnd[2] - 10.0)
	write_short(g_smokepuff_id)
	write_byte(2)
	write_byte(50)
	write_byte(TE_FLAG)
	message_end()
}

stock get_weapon_attachment(id, Float:output[3], Float:fDis = 40.0)
{ 
	new Float:vfEnd[3], viEnd[3] 
	get_user_origin(id, viEnd, 3)  
	IVecFVec(viEnd, vfEnd) 
	
	new Float:fOrigin[3], Float:fAngle[3]
	
	pev(id, pev_origin, fOrigin) 
	pev(id, pev_view_ofs, fAngle)
	
	xs_vec_add(fOrigin, fAngle, fOrigin) 
	
	new Float:fAttack[3]
	
	xs_vec_sub(vfEnd, fOrigin, fAttack)
	xs_vec_sub(vfEnd, fOrigin, fAttack) 
	
	new Float:fRate
	
	fRate = fDis / vector_length(fAttack)
	xs_vec_mul_scalar(fAttack, fRate, fAttack)
	
	xs_vec_add(fOrigin, fAttack, output)
}

stock GetAimOrg(id, Float:origin[3])
{
	new Float:org[3], Float:ofs[3]
	pev(id, pev_origin, org)
	pev(id, pev_view_ofs, ofs)
	xs_vec_add(org, ofs, origin)
}