#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <devilescape>

#define PLUGIN_NAME		"M4A1黑騎士"
#define PLUGIN_VERSION	"450.0"
#define PLUGIN_AUTHOR	"Apppppppppp"

new const CSW_M4A1BK = CSW_M4A1
new const weapon_m4a1bk[] = "weapon_m4a1"

enum{
	IDLE_ANIM, SHOOT_ANIM, SHOOT_ANIM2, SHOOT_ANIM3, RELOAD_ANIM, DRAW_ANIM, SECONDHIT_ANIM
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

new cvar_damage, cvar_clip, cvar_seconddamage, cvar_rad

public plugin_precache()
{
	cvar_damage = register_cvar("wpn_m4a1bk_damage", "450.0")
	cvar_clip = register_cvar("wpn_m4a1bk_clip", "38")
	cvar_seconddamage = register_cvar("wpn_m4a1bk_secdamage","12450.0")
	cvar_rad = register_cvar("wpn_m4a1bk_secondrad", "70.0")
	
	new i
	for( i = 0; i < sizeof g_WpnSound; i++)
		engfunc(EngFunc_PrecacheSound, g_WpnSound[i])
	for( i = 0; i < sizeof g_WpnModel; i++)
		engfunc(EngFunc_PrecacheModel, g_WpnModel[i])
	
	register_clcmd("weapon_m4a1bk", "weapon_hook")
}

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

	register_event("CurWeapon", "CurrentWeapon", "be", "1=1")
	
	register_forward(FM_PlaybackEvent, "fw_PlaybackEvent")
	register_forward(FM_SetModel,"fw_SetModel")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)

	RegisterHam(Ham_Item_Deploy, weapon_m4a1bk, "fw_Item_Deploy_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_m4a1bk, "fw_Weapon_PrimaryAttack")
	RegisterHam(Ham_Weapon_SecondaryAttack, weapon_m4a1bk, "fw_Weapon_SecondaryAttack")
	RegisterHam(Ham_Weapon_Reload, weapon_m4a1bk, "fw_Weapon_Reload")
	RegisterHam(Ham_Weapon_Reload, weapon_m4a1bk, "fw_Weapon_Reload_Post", 1)
	RegisterHam(Ham_Item_PostFrame, weapon_m4a1bk, "fw_ItemPostFrame")
	
	register_clcmd("weapon_m4a1bk", "hook_weapon")
}

public plugin_natives ()
{
	register_native("wpn_give_m4a1blackknight", "native_give_weapon_add", 1)
}

public native_give_weapon_add(id)
{
	Give_BlackKnight(id)
}

public hook_weapon(id)
{
	if(is_user_alive(id))
		engclient_cmd(id, "weapon_m4a1")
	
	return PLUGIN_HANDLED
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
	cross = 2
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
	Weapon_OpenFire(id,iEntity)
	set_pdata_int(iEntity, m_iClip, get_pdata_int(iEntity, m_iClip, 4) - 1, 4)

	UTIL_PlayWeaponAnimation(id, random_num(1, 3))
	
	set_pdata_float(iEntity, m_flNextPrimaryAttack, 0.09, 4)
	set_pdata_float(iEntity, m_flNextSecondaryAttack, 0.09, 4)
	set_pdata_float(id, m_flNextAttack, 0.09, 5)
	
	engfunc(EngFunc_EmitSound, iEntity, CHAN_ITEM, g_WpnSound[random_num(0, 2)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	return HAM_SUPERCEDE
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
		ExecuteHamB(Ham_TakeDamage, target, Ent, id, get_pcvar_float(cvar_seconddamage), DMG_BULLET)
	}
	emit_sound(Ent, CHAN_ITEM, g_WpnSound[3], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	return HAM_SUPERCEDE
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

stock GetAimOrg(id, Float:origin[3])
{
	new Float:org[3], Float:ofs[3]
	pev(id, pev_origin, org)
	pev(id, pev_view_ofs, ofs)
	xs_vec_add(org, ofs, origin)
}