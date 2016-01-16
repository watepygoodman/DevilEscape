#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <devilescape>

#define PLUGINNAME		"破晓黎明(PlasmaGun)"
#define VERSION			"1.0"
#define AUTHOR			"TmNine!~"

// #define	DAMAGE			9999.0	// 伤害
// #define MAXCLIP			45	// 弹药数量
// #define	EXP_RANGE		50.0	// 爆炸范围
// #define	SHIT_SPEED		1600.0	// 绿翔的飞行速度
#define CLASS_NAME		"plasmagun"
#define V_MODEL			"models/v_plasmagun.mdl"
#define P_MODEL			"models/p_plasmagun.mdl"
#define W_MODEL			"models/w_plasmagun.mdl"
#define S_MODEL			"sprites/DevilEscape/plasmaball.spr"
#define EXP_MODEL		"sprites/DevilEscape/plasmabomb.spr"

new cvar_damage, cvar_clip, cvar_exprange, cvar_speed
new const Fire_Sounds[][] = { "weapons/plasmagun-1.wav", "weapons/plasmagun_exp.wav" }

new g_ExpSpr
new bool:g_reloadbug[33]

public plugin_init()
{
	register_plugin(PLUGINNAME, VERSION, AUTHOR)

	register_message(get_user_msgid("DeathMsg"), "message_DeathMsg")
	register_event("CurWeapon", "CurrentWeapon", "be", "1=1")
	register_event("HLTV", "Event_Round_Start", "a", "1=0", "2=0")

	RegisterHam(Ham_Item_Deploy, "weapon_sg552", "HAM_Item_Deploy_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_sg552", "HAM_Weapon_PrimaryAttack")
	RegisterHam(Ham_Item_PostFrame, "weapon_sg552", "HAM_ItemPostFrame")
	RegisterHam(Ham_Weapon_Reload, "weapon_sg552", "HAM_Weapon_Reload")
	RegisterHam(Ham_Weapon_Reload, "weapon_sg552", "HAM_Weapon_Reload_Post", 1)

	RegisterHam(Ham_Touch, "info_target", "HAM_Touch_Post", 1)

	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
}

public plugin_precache()
{
	engfunc(EngFunc_PrecacheModel, V_MODEL)
	engfunc(EngFunc_PrecacheModel, P_MODEL)
	engfunc(EngFunc_PrecacheModel, W_MODEL)
	engfunc(EngFunc_PrecacheModel, S_MODEL)
	g_ExpSpr = engfunc(EngFunc_PrecacheModel, EXP_MODEL)
	for(new i = 0; i < sizeof Fire_Sounds; i++) engfunc(EngFunc_PrecacheSound, Fire_Sounds[i])	
	register_clcmd("weapon_plasmagun", "weapon_hook")

	cvar_damage = register_cvar("wpn_plasmagun_damage", "3000.0")
	cvar_clip = register_cvar("wpn_plasmagun_clip", "20")
	cvar_exprange = register_cvar("wpn_plasmagun_range", "55.0")
	cvar_speed = register_cvar("wpn_plasmagun_speed", "1550.0")
}

public weapon_hook(id)
{
    	engclient_cmd(id, "weapon_sg552")
    	return PLUGIN_HANDLED
}

public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
	if (!is_user_alive(id))
	return

	new iEntity = get_pdata_cbase(id, 373)
	if (iEntity <= 0)
	return

	if (pev(iEntity, pev_weapons) != WEAPON_PLASMAGUN || get_pdata_int(iEntity, 43, 4) != CSW_SG552)
	return

	set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001) 
}

public plugin_natives ()
{
	register_native("wpn_give_plasmagun", "native_give_weapon_add", 1)
}

public native_give_weapon_add(id)
{
	Give_PlasmaGun(id)
}

public Event_Round_Start()
{
	new iEntity = -1
	while((iEntity = engfunc(EngFunc_FindEntityByString, iEntity, "classname", CLASS_NAME))) engfunc(EngFunc_RemoveEntity, iEntity)
}

public fw_SetModel(iEntity, szModel[])
{
	if (strcmp(szModel, "models/w_sg552.mdl"))
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
	
	if (pev(iEntity2, pev_weapons) != WEAPON_PLASMAGUN)
	return FMRES_IGNORED

	engfunc(EngFunc_SetModel, iEntity, W_MODEL)
	return FMRES_SUPERCEDE
}

public Give_PlasmaGun(id)
{
	if (!is_user_alive(id))
	return 

	drop_weapons(id, 1)
	new iEntity = fm_give_item(id, "weapon_sg552")
	if (iEntity > 0)
	{
		set_pev(iEntity, pev_weapons, WEAPON_PLASMAGUN)
		set_pdata_int(iEntity, 51, get_pcvar_num(cvar_clip), 4)
		UTIL_PlayWeaponAnimation(id, 2)
	}
}
public HAM_Item_Deploy_Post(iEntity)
{
	if (pev(iEntity, pev_weapons) != WEAPON_PLASMAGUN)
	return

	new id = get_pdata_cbase(iEntity, 41, 4)
	
	UTIL_PlayWeaponAnimation(id, 2)
	set_pdata_float(id, 83, 0.86, 5)
	set_pev(id, pev_viewmodel2, V_MODEL)
	set_pev(id, pev_weaponmodel2, P_MODEL)
}

public CurrentWeapon(id)
{
	if (!is_user_alive(id))
	return

	new iEntity = get_pdata_cbase(id, 373)
	if (iEntity <= 0)
	return
	
	if (pev(iEntity, pev_weapons) == WEAPON_PLASMAGUN && get_pdata_int(iEntity, 43, 4) == CSW_SG552)
	{
		set_pev(id, pev_viewmodel2, V_MODEL)
		set_pev(id, pev_weaponmodel2, P_MODEL)
	}
}

public HAM_Weapon_PrimaryAttack(iEntity)
{
	if (pev(iEntity, pev_weapons) != WEAPON_PLASMAGUN)
	return HAM_IGNORED

	new id = get_pdata_cbase(iEntity, 41, 4)

	if (!get_pdata_int(iEntity, 51, 4))
	return HAM_SUPERCEDE

	static Float:push[3]
	push[0] = random_float(3.5, -2.0)
	push[1] = 0.0
	push[2] = 0.0
	set_pev(id, pev_punchangle, push)

	set_pdata_int(iEntity, 51, get_pdata_int(iEntity, 51, 4) - 1, 4)
	UTIL_PlayWeaponAnimation(id, random_num(3, 5))
	set_pdata_float(iEntity, 46, 0.62, 4)
	set_pdata_float(id, 83, 0.62, 5)
	emit_sound(id, CHAN_WEAPON, Fire_Sounds[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	Create_Plasma(id)
	return HAM_SUPERCEDE
}

public Create_Plasma(id)
{
	new Float:StartOrigin[3], Float:TargetOrigin[3], Float:angles[3], Float:angles_fix[3]
	get_position(id, 36.0, 3.0, -3.0, StartOrigin)

	pev(id, pev_v_angle, angles)
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))

	if (!pev_valid(iEntity))
	return

	angles_fix[0] = 360.0 - angles[0]
	angles_fix[1] = angles[1]
	angles_fix[2] = angles[2]

	set_pev(iEntity, pev_movetype, MOVETYPE_TOSS)
	set_pev(iEntity, pev_owner, id)
	set_pev(iEntity, pev_classname, CLASS_NAME)
	engfunc(EngFunc_SetModel, iEntity, S_MODEL)
	engfunc(EngFunc_SetSize, iEntity, {-1.0,-1.0,-1.0}, {1.0,1.0,1.0})
	set_pev(iEntity, pev_origin, StartOrigin)
	set_pev(iEntity, pev_angles, angles_fix)
	set_pev(iEntity, pev_gravity, 0.01)
	set_pev(iEntity, pev_solid, SOLID_BBOX)
	set_pev(iEntity, pev_frame, 0.0)

	set_pev(iEntity, pev_rendermode, kRenderTransAdd)
	set_pev(iEntity, pev_renderamt, 192.0)
	set_pev(iEntity, pev_scale, 0.25)

	static Float:Velocity[3]
	fm_get_aim_origin(id, TargetOrigin)
	get_speed_vector(StartOrigin, TargetOrigin, get_pcvar_float(cvar_speed), Velocity)
	set_pev(iEntity, pev_velocity, Velocity)
}

public HAM_Touch_Post(iEntity, id)
{
	if (!pev_valid(iEntity))
	return

	new Classname[32]
	new iAttack = pev(iEntity, pev_owner)
	pev(iEntity, pev_classname, Classname, sizeof(Classname))	
	if (!equal(Classname, CLASS_NAME))
	return

	if (iAttack == id)
	return

	new Float:fOrigin[3]
	pev(iEntity, pev_origin, fOrigin)

	new iVicim = -1
	while((iVicim = engfunc(EngFunc_FindEntityInSphere, iVicim, fOrigin, get_pcvar_float(cvar_exprange))) > 0)
	{
		if (!pev_valid(iVicim))
		continue

		if (iVicim == iAttack /* || STE_GetUserZombie(iAttack)*/)
		continue

		new Ptdclassname[32]
		pev(iVicim, pev_classname, Ptdclassname, charsmax(Ptdclassname))

		if (pev(iVicim, pev_takedamage) == DAMAGE_NO)
		continue

		if (!strcmp(Ptdclassname, "func_breakable")) dllfunc(DLLFunc_Use, iVicim, iEntity)
		if (is_user_alive(iVicim)) set_pdata_int(iVicim, 75, 2)

		ExecuteHamB(Ham_TakeDamage, iVicim, iEntity, iAttack, get_pcvar_float(cvar_damage), DMG_BULLET)
	}

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, fOrigin[0])
	engfunc(EngFunc_WriteCoord, fOrigin[1])
	engfunc(EngFunc_WriteCoord, fOrigin[2])
	write_short(g_ExpSpr)
	write_byte(5)
	write_byte(20)
	write_byte(2|4|8)
	message_end()

	engfunc(EngFunc_EmitSound, iEntity, CHAN_WEAPON, Fire_Sounds[1], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	engfunc(EngFunc_RemoveEntity, iEntity)
}

public HAM_ItemPostFrame(iEntity) 
{
	if (pev(iEntity, pev_weapons) != WEAPON_PLASMAGUN)
	return HAM_IGNORED

	new id = get_pdata_cbase(iEntity, 41, 4)
	new Float:flNextAttack = get_pdata_float(id, 83, 5)
	new iBpAmmo = get_pdata_int(id, 380)
	new iClip = get_pdata_int(iEntity, 51, 4)
	new fInReload = get_pdata_int(iEntity, 54, 4) 

	if (fInReload && flNextAttack <= 0.0)
	{
		new j = min(get_pcvar_num(cvar_clip) - iClip, iBpAmmo)
		set_pdata_int(iEntity, 51, iClip + j, 4)
		set_pdata_int(id, 380, iBpAmmo-j)
		set_pdata_int(iEntity, 54, 0, 4)
		fInReload = 0
	}
	return HAM_IGNORED
}

public HAM_Weapon_Reload(iEntity) 
{
	if (pev(iEntity, pev_weapons) != WEAPON_PLASMAGUN)
	return HAM_IGNORED

	new id = get_pdata_cbase(iEntity, 41, 4)

	if (get_pdata_int(iEntity, 51, 4) >= get_pcvar_num(cvar_clip) || !get_pdata_int(id, 380))
	return HAM_SUPERCEDE

	if (get_pdata_int(iEntity, 51, 4) == 30)
	{
		g_reloadbug[id] = true
		set_pdata_int(iEntity, 51, 0, 4)
	}
	return HAM_IGNORED
}

public HAM_Weapon_Reload_Post(iEntity) 
{
	if (pev(iEntity, pev_weapons) != WEAPON_PLASMAGUN)
	return

	new id = get_pdata_cbase(iEntity, 41, 4)

	if (get_pdata_int(iEntity, 51, 4) >= get_pcvar_num(cvar_clip) || !get_pdata_int(id, 380))
	return

	if (g_reloadbug[id])
	{
		g_reloadbug[id] = false
		set_pdata_int(iEntity, 51, 30, 4)
	}
	set_pdata_float(id, 83, 3.3, 5)
	set_pdata_float(iEntity, 48, 3.3, 4)
	UTIL_PlayWeaponAnimation(id, 1)
}

public message_DeathMsg(msg_id, msg_dest, msg_ent)
{
	new szWeapon[64]
	get_msg_arg_string(4, szWeapon, charsmax(szWeapon))
	
	if (strcmp(szWeapon, "sg552"))
	return PLUGIN_CONTINUE

	new iEntity = get_pdata_cbase(get_msg_arg_int(1), 373)
	if (!pev_valid(iEntity) || get_pdata_int(iEntity, 43, 4) != CSW_SG552 || pev(iEntity, pev_weapons) != WEAPON_PLASMAGUN)
	return PLUGIN_CONTINUE

	set_msg_arg_string(4, "plasmagun")
	return PLUGIN_CONTINUE
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

stock fm_find_ent_by_owner(index, const classname[], owner, jghgtype = 0) {
	new strtype[11] = "classname", ent = index
	switch (jghgtype) {
		case 1: strtype = "target"
		case 2: strtype = "targetname"
	}

	while ((ent = engfunc(EngFunc_FindEntityByString, ent, strtype, classname)) && pev(ent, pev_owner) != owner) {}

	return ent
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

stock fm_get_aim_origin(id, Float:origin[3])
{
	new Float:start[3], Float:view_ofs[3], Float:dest[3]
	pev(id, pev_origin, start)
	pev(id, pev_view_ofs, view_ofs)
	xs_vec_add(start, view_ofs, start)
	pev(id, pev_v_angle, dest)
	engfunc(EngFunc_MakeVectors, dest)
	global_get(glb_v_forward, dest)
	xs_vec_mul_scalar(dest, 9999.0, dest)
	xs_vec_add(start, dest, dest)
	engfunc(EngFunc_TraceLine, start, dest, 0, id, 0)
	get_tr2(0, TR_vecEndPos, origin)
	return 1
}

stock get_speed_vector(const Float:origin1[3],const Float:origin2[3],Float:speed, Float:new_velocity[3])
{
	new_velocity[0] = origin2[0] - origin1[0]
	new_velocity[1] = origin2[1] - origin1[1]
	new_velocity[2] = origin2[2] - origin1[2]
	static Float:num; num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
	new_velocity[0] *= num
	new_velocity[1] *= num
	new_velocity[2] *= num
	
	return 1;
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