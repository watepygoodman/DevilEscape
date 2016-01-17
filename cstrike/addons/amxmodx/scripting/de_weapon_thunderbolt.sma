#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <cstrike>
#include <xs>
#include <devilescape>

#define PLUGIN_NAME "雷神(for devilescape)"
#define PLUGIN_VERSION "0.0"
#define PLUGIN_AUTHOR "watepy"

new const g_WpnModel[][]= 
{
	"models/v_thunderbolt.mdl",
	"models/p_thunderbolt.mdl",
	"models/w_thunderbolt.mdl"
}

new const g_WpnSound[][]=
{
	"weapons/thunderbolt-1.wav",
	"weapons/thunderbolt_idle.wav",
    "weapons/thunderbolt_draw.wav",
	"weapons/thunderbolt_zoom.wav"
}

new const CSW_THUNDERBOLT = CSW_AWP

// const m_BloodColor = 89
// const m_iClip = 51
// const m_fInReload = 54
// const m_flNextAttack = 83
// const m_pActiveItem = 373
// const m_flNextPrimaryAttack = 46
// const m_flNextSecondaryAttack = 47
// const m_flTimeWeaponIdle = 48

new g_LaserSpr
new cvar_damage, cvar_clip

public plugin_precache()
{
	for(new i = 0; i < sizeof g_WpnSound; i++)
		engfunc(EngFunc_PrecacheSound, g_WpnSound[i])
	for(new i = 0; i < sizeof g_WpnModel; i++)
		engfunc(EngFunc_PrecacheModel, g_WpnModel[i])
	
	g_LaserSpr = precache_model("sprites/laserbeam.spr")
}

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	register_event("CurWeapon", "event_curweapon", "be", "1=1")
	
	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_PlaybackEvent, "fw_PlaybackEvent")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	
	RegisterHam(Ham_Item_Deploy, "weapon_awp", "fw_Item_Deploy_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_awp", "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_awp", "fw_Weapon_SecondaryAttack")
	RegisterHam(Ham_Weapon_WeaponIdle, "weapon_awp", "fw_Weapon_WeaponIdle_Post", 1)
	RegisterHam(Ham_Weapon_Reload, "weapon_awp", "fw_Weapon_Reload")
	
	cvar_damage = register_cvar("wpn_thunderbolt_dmg","9000.0")
	cvar_clip = register_cvar("wpn_thunderbolt_clip","20")
	
	register_clcmd("weapon_thunderbolt", "hook_weapon")
	
}

public hook_weapon(id)
{
	if(is_user_alive(id))
		engclient_cmd(id, "weapon_awp")
	
	return PLUGIN_HANDLED
}

public plugin_natives()
{
	register_native("wpn_give_thunderbolt", "native_give_weapon", 1)
}

public native_give_weapon(id)
{
	give_weapon(id)
}

public give_weapon(id)
{
	if (!is_user_alive(id))
		return 
	
	new iEntity = fm_give_item(id, "weapon_awp")
	if (iEntity > 0)
	{
		set_pev(iEntity, pev_weapons, WEAPON_THUNDERBOLT)
		set_pev(iEntity, pev_owner, id)
		set_pdata_int(iEntity, m_iClip, get_pcvar_num(cvar_clip), 4)
	}
}

public event_curweapon(id)
{
	if(!is_user_alive(id) || read_data(2) != CSW_THUNDERBOLT)
		return
	new Ent = get_pdata_cbase(id, m_pActiveItem)
	if(Ent <= 0)
		return
	
	if(pev(Ent, pev_weapons) == WEAPON_THUNDERBOLT)
	{
		set_pev(id, pev_viewmodel2, g_WpnModel[0])
		set_pev(id, pev_weaponmodel2, g_WpnModel[1])
		SetWeaponAnimation(id, 2)
	}
}

public fw_SetModel(Ent, model[])
{
	if(!pev_valid(Ent) || !equal(model, "models/w_awp.mdl"))
		return FMRES_IGNORED
	
	static classname[32]
	pev(Ent, pev_classname, classname, sizeof(classname))
	
	if(!equal(classname, "weaponbox"))
		return FMRES_IGNORED
	
	new iEnt = fm_find_ent_by_owner( -1, "weapon_awp", Ent )
	
	if(!pev_valid(iEnt))
		return FMRES_IGNORED;

	if( pev(iEnt, pev_weapons) == WEAPON_THUNDERBOLT )
	{
		engfunc(EngFunc_SetModel, Ent, g_WpnModel[2])
		return FMRES_SUPERCEDE
	}

	return FMRES_IGNORED;
}

//开火
public fw_Weapon_PrimaryAttack(Ent)
{
	engfunc(EngFunc_EmitSound, Ent, CHAN_ITEM, g_WpnSound[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	if(pev(Ent, pev_weapons) != WEAPON_THUNDERBOLT)
		return HAM_IGNORED
	
	if (!get_pdata_int(Ent, m_iClip, 4))
		return HAM_SUPERCEDE
	
	new id = pev(Ent, pev_owner)
	Weapon_ShootLine(id)
	Weapon_OpenFire(id, Ent)
	set_pdata_float(Ent, m_flTimeWeaponIdle, 3.1, 5) 
	set_pdata_float(Ent, m_flNextPrimaryAttack, 2.88, 4)
	set_pdata_float(Ent, m_flNextSecondaryAttack, 2.88, 4)
	cs_set_user_zoom(id, 1,1) 
	SetWeaponAnimation(id, 1)
	return HAM_SUPERCEDE
}

//开镜
public fw_Weapon_SecondaryAttack(Ent)
{
	if(pev(Ent, pev_weapons) == WEAPON_THUNDERBOLT)
		emit_sound(Ent, CHAN_ITEM, g_WpnSound[3], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}

public fw_Item_Deploy_Post(Ent)
{
	if (pev(Ent, pev_weapons) != WEAPON_THUNDERBOLT)
		return HAM_IGNORED
	
	new id = pev(Ent, pev_owner)
	set_pev(id, pev_viewmodel2, g_WpnModel[0])
	set_pev(id, pev_weaponmodel2, g_WpnModel[1])
	SetWeaponAnimation(id, 2)
	emit_sound(Ent, CHAN_ITEM, g_WpnSound[2], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	return HAM_SUPERCEDE
}

public Weapon_ShootLine(id)
{
	if(!is_user_alive(id))
		return
	
	new Float:StartOrigin[3], Float:TargetOrigin[3], Float:Angles[3], Float:Vec[3], Float:PlrOrg[3]
	// new Ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	
	get_position(id, 50.0, 5.0, -5.0, StartOrigin)
	pev(id, pev_origin, PlrOrg)
	
	pev(id, pev_view_ofs, Vec)
	pev(id, pev_angles, Angles)
	
	xs_vec_add(PlrOrg, Vec, PlrOrg)
	velocity_by_aim(id, 800, Vec)
	xs_vec_add(PlrOrg, Vec, TargetOrigin)
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_BEAMPOINTS);
	engfunc(EngFunc_WriteCoord,StartOrigin[0]);
	engfunc(EngFunc_WriteCoord,StartOrigin[1]);
	engfunc(EngFunc_WriteCoord,StartOrigin[2]);
	engfunc(EngFunc_WriteCoord,TargetOrigin[0]); //Random
	engfunc(EngFunc_WriteCoord,TargetOrigin[1]); //Random
	engfunc(EngFunc_WriteCoord,TargetOrigin[2]); //Random
	write_short(g_LaserSpr);
	write_byte(0);
	write_byte(0);
	write_byte(10);	//Life
	write_byte(15);	//Width
	write_byte(0);	//wave
	write_byte(0); // r
	write_byte(0); // g
	write_byte(255); // b
	write_byte(200);
	write_byte(255);
	message_end();
	
}

public Weapon_OpenFire(id, Ent)
{
	new tr, cross, ignoredent, i, hitgroup
	new Float:dmg = get_pcvar_float(cvar_damage)
	new Float:vec[3], Float:start[3], Float:end[3], Float:aim[3]
	
	GetAimOrg(id, start)
	velocity_by_aim(id, 998, vec)
	xs_vec_add(start, vec, end)
	velocity_by_aim(id, 8, vec)
	
	ignoredent = id
	cross = 5
	while (cross && dmg>0.0)
	{
		cross--
		engfunc(EngFunc_TraceLine, start, end, 0, ignoredent, tr)
		if(get_tr2(tr,TR_AllSolid)) break
		i = get_tr2(tr, TR_pHit)
		ignoredent = i
		if( i<0 ){
			i = 0
			continue
		}
		
		if(id == i)
		{
			cross ++
			continue
		}
		
		hitgroup = get_tr2(tr,TR_iHitgroup)
		get_tr2(tr, TR_vecEndPos, aim)
		if(pev_valid(i) && pev(i,pev_takedamage))
		{
			new Float:idmg = dmg
			switch(hitgroup)
			{
				case 1: idmg*= 1.5
				case 2: idmg*= 1.25
				case 3: idmg*= 1.25
				case 4: idmg*= 1.10
				case 5: idmg*= 1.10
				case 6: idmg*= 0.9
				case 7: idmg*= 0.9
			}
			
			ExecuteHamB(Ham_TakeDamage, i, Ent, id, idmg, DMG_BULLET)
			dmg-= get_pcvar_float(cvar_damage) / float(cross)
		}
		
	}
}

public fw_Weapon_WeaponIdle_Post(Ent)
{
	new id = pev(Ent, pev_owner)
	
	if(!is_user_alive(id) || pev(Ent, pev_weapons) != WEAPON_THUNDERBOLT || get_pdata_float(id, m_flNextAttack) > 0.0)
		return HAM_IGNORED
	
	if(get_pdata_float(Ent, m_flTimeWeaponIdle, 4) <= 0.1) 
	{
		SetWeaponAnimation(id, 0)
		set_pdata_float(Ent, m_flTimeWeaponIdle, 20.0, 4)
		emit_sound(Ent, CHAN_ITEM, g_WpnSound[1], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	}
	
	return HAM_IGNORED
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
	
	if(pev(get_pdata_cbase(id, m_pActiveItem), pev_weapons) == WEAPON_THUNDERBOLT)
		set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001) 
	
	return FMRES_HANDLED
}

public fw_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if (!is_user_connected(invoker))
		return FMRES_IGNORED	
	if(pev(get_pdata_cbase(invoker, m_pActiveItem), pev_weapons) == WEAPON_THUNDERBOLT)
		return FMRES_IGNORED
	
	engfunc(EngFunc_PlaybackEvent, flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
	
	return HAM_SUPERCEDE
}

stock SetWeaponAnimation(id, anim)
{
	if(!is_user_alive(id))
		return
	
	set_pev(id, pev_weaponanim, anim)
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, {0, 0, 0}, id)
	write_byte(anim)
	write_byte(pev(id, pev_body))
	message_end()
}

stock GetAimOrg(id, Float:origin[3])
{
	new Float:org[3], Float:ofs[3]
	pev(id, pev_origin, org)
	pev(id, pev_view_ofs, ofs)
	xs_vec_add(org, ofs, origin)
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

stock fm_give_item(index, const wEntity[])
{
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, wEntity))
	new Float:origin[3]
	pev(index, pev_origin, origin)
	set_pev(iEntity, pev_origin, origin)
	set_pev(iEntity, pev_spawnflags, pev(iEntity, pev_spawnflags) | SF_NORESPAWN)
	dllfunc(DLLFunc_Spawn, iEntity)
	new save = pev(iEntity, pev_solid)
	dllfunc(DLLFunc_Touch, iEntity, index)
	if(pev(iEntity, pev_solid) != save) return iEntity
	engfunc(EngFunc_RemoveEntity, iEntity)
	return -1
}

stock fm_find_ent_by_owner(index, const classname[], owner, jghgtype = 0) {
	new strtype[11] = "classname", ent = index
	switch (jghgtype) {
		case 1: strtype = "target"
		case 2: strtype = "targetname"
	}

	while ((ent = engfunc(EngFunc_FindEntityByString, ent, strtype, classname)) && pev(ent, pev_owner) != owner) {}

	return ent
}