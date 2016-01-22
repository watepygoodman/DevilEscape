#include <amxmodx>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <xs>
#include <devilescape>
#include <engine>
#include <cstrike>

#define PLUGIN_NAME		"M4A1黑騎士"
#define PLUGIN_VERSION	"450.0"
#define PLUGIN_AUTHOR	"Apppppppppp"

new const CSW_M4A1BK = CSW_M4A1
new const weapon_m4a1bk[] = "weapon_m4a1"

new bool:g_hasBot, bool:g_isSecAtt[33]

enum{
	IDLE_ANIM, SHOOT_ANIM, SHOOT_ANIM2, SHOOT_ANIM3, RELOAD_ANIM, DRAW_ANIM, SECONDHIT_ANIM
}

new const g_EntNames[][] =
{	 
	"worldspawn","player","func_wall","info_target","func_wall_toggle",
	"func_rotating","func_door","func_door_rotating","func_pendulum",
	"func_vehicle","func_breakable","func_button"
}

new const g_WpnSound[][] = { 
	"weapons/m4a1bk_shoot1.wav", 
	"weapons/m4a1bk_shoot2.wav" , 
	"weapons/m4a1bk_shoot3.wav",
	"weapons/m4a1bk_secondshoot.wav"
}

new const g_WpnModel[][] = {
	"models/v_m4a1BK.mdl",
	"models/p_m4a1BK.mdl",
	"models/w_m4a1BK.mdl"
}

new bool:g_reloadbug[33]

new g_smokepuff_id

new cvar_damage, cvar_clip, cvar_seconddamage, cvar_rad, cvar_price
new g_Wpnid

public plugin_precache()
{
	cvar_damage = register_cvar("wpn_m4a1bk_damage", "450.0")
	cvar_clip = register_cvar("wpn_m4a1bk_clip", "38")
	cvar_seconddamage = register_cvar("wpn_m4a1bk_secdamage","12450.0")
	cvar_rad = register_cvar("wpn_m4a1bk_secondrad", "75.0")
	cvar_price = register_cvar("de_wpn_m4a1bk_price","450")
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

	RegisterHam(Ham_TakeDamage,"player","fw_TakeDamage")
	RegisterHam(Ham_Item_Deploy, weapon_m4a1bk, "fw_Item_Deploy_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_m4a1bk, "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_SecondaryAttack, weapon_m4a1bk, "fw_Weapon_SecondaryAttack")
	RegisterHam(Ham_Weapon_Reload, weapon_m4a1bk, "fw_Weapon_Reload")
	RegisterHam(Ham_Weapon_Reload, weapon_m4a1bk, "fw_Weapon_Reload_Post", 1)
	RegisterHam(Ham_Item_PostFrame, weapon_m4a1bk, "fw_ItemPostFrame")
	RegisterHam(Ham_Item_AddToPlayer, weapon_m4a1bk, "fw_Item_AddToPlayer", 1)
	
	for(new i = 0; i < sizeof(g_EntNames); i++)
	{
		RegisterHam(Ham_TraceAttack, g_EntNames[i], "fw_TraceAttack")
		RegisterHam(Ham_TakeDamage, g_EntNames[i], "fw_TakeDamage")
	}
	
	register_clcmd("weapon_m4a1bk", "hook_weapon")
	g_Wpnid = de_register_sp_wpn(PLUGIN_NAME, get_pcvar_num(cvar_price))
}

public de_spwpn_select(id, wid)
{
	if(g_Wpnid == wid)
		Give_BlackKnight(id)
}

public hook_weapon(id)
{
	if(is_user_alive(id))
		engclient_cmd(id, "weapon_m4a1")
	
	return PLUGIN_HANDLED
}

public client_putinserver(id)
{
	if(is_user_bot(id) && !g_hasBot)
		set_task(0.1, "task_bots_ham", id)
}

public task_bots_ham(id)
{
	if(g_hasBot)
		return
	RegisterHamFromEntity(Ham_TakeDamage, id, "fw_TakeDamage")
	g_hasBot = true
}

public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
	if(!is_user_alive(id))
		return FMRES_IGNORED	
	
	if(pev(get_pdata_cbase(id, m_pActiveItem), pev_weapons) == WEAPON_M4A1BLACKKNIGHT)
		set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001) 
	
	return FMRES_HANDLED
}

public fw_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if (!is_user_connected(invoker))
		return FMRES_IGNORED	
	if(pev(get_pdata_cbase(invoker, m_pActiveItem), pev_weapons) == WEAPON_M4A1BLACKKNIGHT)
		return FMRES_IGNORED
	
	engfunc(EngFunc_PlaybackEvent, flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
	
	return HAM_SUPERCEDE
}

public fw_SetModel(iEntity, szModel[])
{
	if (strcmp(szModel, "models/w_m4a1.mdl"))
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
	
	if (pev(iEntity2, pev_weapons) != WEAPON_M4A1BLACKKNIGHT)
	return FMRES_IGNORED

	engfunc(EngFunc_SetModel, iEntity, g_WpnModel[2])
	return FMRES_SUPERCEDE
}

public Give_BlackKnight(id)
{
	if (!is_user_alive(id))
		return 

	drop_weapons(id, 1)
	new iEntity = fm_give_item(id, weapon_m4a1bk)
	if (iEntity > 0)
	{
		set_pev(iEntity, pev_weapons, WEAPON_M4A1BLACKKNIGHT)
		set_pev(iEntity, pev_owner, id)
		set_pdata_int(iEntity, m_iClip, get_pcvar_num(cvar_clip), 4)
		cs_set_user_bpammo(id, CSW_M4A1BK, 90)
	}
}

public fw_Item_Deploy_Post(iEntity)
{
	if (pev(iEntity, pev_weapons) != WEAPON_M4A1BLACKKNIGHT)
		return HAM_IGNORED
	
	new id = pev(iEntity, pev_owner)
	set_pev(id, pev_viewmodel2, g_WpnModel[0])
	set_pev(id, pev_weaponmodel2, g_WpnModel[1])
	UTIL_PlayWeaponAnimation(id, DRAW_ANIM)
	set_pdata_float(iEntity, m_flNextPrimaryAttack, 0.7, 4)
	
	return HAM_SUPERCEDE
}

public CurrentWeapon(id)
{
	if(!is_user_alive(id) || read_data(2) != CSW_M4A1BK)
		return

	new iEntity = get_pdata_cbase(id, m_pActiveItem)
	if (iEntity <= 0)
		return
	
	if(pev(iEntity, pev_weapons) == WEAPON_M4A1BLACKKNIGHT)
	{
		set_pev(id, pev_viewmodel2, g_WpnModel[0])
		set_pev(id, pev_weaponmodel2, g_WpnModel[1])
	}
}

public fw_Weapon_PrimaryAttack(iEntity)
{
	if (pev(iEntity, pev_weapons) != WEAPON_M4A1BLACKKNIGHT)
		return HAM_IGNORED

	if (!get_pdata_int(iEntity, m_iClip, 4))
		return HAM_IGNORED
	
	new id = pev(iEntity,pev_owner)

	UTIL_PlayWeaponAnimation(id, random_num(1, 3))
	
	set_pdata_float(iEntity, m_flNextPrimaryAttack, 0.1, 4)
	set_pdata_float(iEntity, m_flNextSecondaryAttack, 0.1, 4)
	set_pdata_float(id, m_flNextAttack, 0.1, 5)
	
	engfunc(EngFunc_EmitSound, iEntity, CHAN_ITEM, g_WpnSound[random_num(0, 2)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	g_isSecAtt[id] = false
	
	return HAM_IGNORED
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	if(!is_user_connected(attacker) || !is_user_connected(victim))
		return HAM_IGNORED
	
	if (victim != attacker && is_user_connected(attacker))
	{
		if(g_isSecAtt[attacker])
			return HAM_IGNORED
		
		new WpnEnt = get_pdata_cbase(attacker, m_pActiveItem)
		if(pev(WpnEnt, pev_weapons) == WEAPON_M4A1BLACKKNIGHT)
		{
			SetHamParamFloat(4,  get_pcvar_float(cvar_damage))
			return HAM_SUPERCEDE
		}
	}
	return HAM_IGNORED
}

public fw_TraceAttack(ent, attacker, Float:Damage, Float:fDir[3], ptr, iDamageType)
{
	if(!is_user_alive(attacker) || !is_user_connected(attacker))
		return HAM_IGNORED	
	
	new Ent = get_pdata_cbase(attacker, m_pActiveItem)
	
	if(pev(Ent, pev_weapons) != WEAPON_M4A1BLACKKNIGHT)
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
	if (pev(iEntity, pev_weapons) != WEAPON_M4A1BLACKKNIGHT)
		return HAM_IGNORED

	new id = pev(iEntity, pev_owner)
	new Float:flNextAttack = get_pdata_float(id, m_flNextAttack, 5)
	new iBpAmmo = get_pdata_int(id, m_iAmmoType_M4A1)
	new iClip = get_pdata_int(iEntity, m_iClip, 4)
	new fInReload = get_pdata_int(iEntity, m_fInReload, 4)

	if (fInReload && flNextAttack <= 0.0)
	{
		new j = min(get_pcvar_num(cvar_clip) - iClip, iBpAmmo)
		set_pdata_int(iEntity, m_iClip, iClip + j, 4)
		set_pdata_int(id, m_iAmmoType_M4A1, iBpAmmo-j)
		set_pdata_int(iEntity, m_fInReload, 0, 4)
		fInReload = 0
	}
	return HAM_IGNORED
}

public fw_Weapon_Reload(iEntity) 
{
	if (pev(iEntity, pev_weapons) != WEAPON_M4A1BLACKKNIGHT)
		return HAM_IGNORED

	new id = pev(iEntity, pev_owner)
	new iClip = get_pdata_int(iEntity, m_iClip, 4)

	if(iClip >= get_pcvar_num(cvar_clip) || !get_pdata_int(id, m_iAmmoType_M4A1))
		return HAM_SUPERCEDE

	if (iClip == 30)
	{
		g_reloadbug[id] = true
		set_pdata_int(iEntity, iClip, 0, 4)
	}
	
	return HAM_IGNORED
}

public fw_Weapon_Reload_Post(iEntity) 
{
	if (pev(iEntity, pev_weapons) != WEAPON_M4A1BLACKKNIGHT)
	return

	new id = pev(iEntity, pev_owner)
	new iClip = get_pdata_int(iEntity, m_iClip, 4)
	
	if(iClip >= get_pcvar_num(cvar_clip) || !get_pdata_int(id, m_iAmmoType_M4A1))
		return
	
	if (g_reloadbug[id])
	{
		g_reloadbug[id] = false
		set_pdata_int(iEntity, m_iClip, 30, 4)
	}
	
	set_pdata_float(id, m_flNextAttack, 3.0, 4)
	set_pdata_float(iEntity, m_flTimeWeaponIdle, 3.0, 4)
	UTIL_PlayWeaponAnimation(id, RELOAD_ANIM)
}

public fw_Weapon_SecondaryAttack(Ent)
{
	if(pev(Ent, pev_weapons) != WEAPON_M4A1BLACKKNIGHT)
		return HAM_IGNORED
	
	new id = pev(Ent, pev_owner)
	
	set_pdata_float(id, m_flNextAttack, 1.3, 5)
	UTIL_PlayWeaponAnimation(id, SECONDHIT_ANIM)
	
	new Float:origin[3],Float:pOrigin[3], target, body ,aimOrigin[3],Float:aimOrigin2[3]
	get_user_aiming(id, target, body)
	get_user_origin(id, aimOrigin, 3)

	aimOrigin2[0] = float(aimOrigin[0])
	aimOrigin2[1] = float(aimOrigin[1])
	aimOrigin2[2] = float(aimOrigin[2])

	pev(id, pev_origin, pOrigin);
	pev(target, pev_origin, origin);

	new Float:dist = get_distance_f(origin, pOrigin);

	if(is_user_alive(target) && dist <= get_pcvar_float(cvar_rad))
	{
		g_isSecAtt[id] = true
		ExecuteHamB(Ham_TakeDamage, target, Ent, id, get_pcvar_float(cvar_seconddamage), DMG_BULLET)
	}
	emit_sound(Ent, CHAN_ITEM, g_WpnSound[3], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	return HAM_SUPERCEDE
}

public fw_Item_AddToPlayer(Ent, id)
{
	if(!is_valid_ent(Ent))
		return HAM_IGNORED
	
	if(pev(Ent, pev_weapons) == WEAPON_M4A1BLACKKNIGHT)
	{
		set_pev(Ent, pev_owner, id)
		set_pdata_float(id, m_flNextAttack, 0.7)
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