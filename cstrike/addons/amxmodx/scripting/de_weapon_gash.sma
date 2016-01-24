#include <amxmodx>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <xs>
#include <devilescape>
#include <de_wpn_tool>
#include <cstrike>
#include <engine>

#define PLUGIN_NAME		"Gash枪列表"
#define PLUGIN_VERSION	"0.1"
#define PLUGIN_AUTHOR	"DevilEscape"

new const LR300_NAME[] = "LR300"
new const ETHEREAL_NAME[] = "尘埃之光"

new const g_EntNames[][] =
{	 
	"worldspawn","player","func_wall","info_target","func_wall_toggle",
	"func_rotating","func_door","func_door_rotating","func_pendulum",
	"func_vehicle","func_breakable","func_button"
}

new const g_Mdl_LR300[][] = {
	"models/v_lr300.mdl",
	"models/p_lr300.mdl",
	"models/w_lr300.mdl"
}

new const g_Mdl_Ethereal[][] = {
	"models/v_ethereal.mdl",
	"models/p_ethereal.mdl",
	"models/w_ethereal.mdl"
} 

new const g_Snd_LR300[][] = {
	"weapons/lr300-1.wav",
	"weapons/lr300_magin.wav",
	"weapons/lr300_magout.wav",
	"weapons/lr300_catch.wav"
}

new const g_Snd_Ethereal[][] = {
	"weapons/ethereal_shoot1.wav",
	"weapons/ethereal_draw.wav",
	"weapons/ethereal_reload.wav"
}

new const weapon_ent[][] = {"weapon_sg552", "weapon_mp5navy"}

//Bot Register
new bool:g_hasBot

//Cvar
new cvar_LR300_price, cvar_LR300_dmg, cvar_Ethereal_price, cvar_Ethereal_dmg

//Wpn ID
new g_Wpnid_LR300, g_Wpnid_Ethereal

//Spr
new g_LaserSpr

//Weapon
new Float:g_PunchAngle[33][3]

public plugin_precache()
{
	new i
	for( i = 0; i < sizeof g_Mdl_LR300; i++)
		engfunc(EngFunc_PrecacheModel, g_Mdl_LR300[i])
	for( i = 0; i < sizeof g_Mdl_Ethereal; i++)
		engfunc(EngFunc_PrecacheModel, g_Mdl_Ethereal[i])
	
	for( i = 0; i < sizeof g_Snd_LR300; i++)
		engfunc(EngFunc_PrecacheSound, g_Snd_LR300[i])
	for( i = 0; i < sizeof g_Snd_Ethereal; i++)
		engfunc(EngFunc_PrecacheSound, g_Snd_Ethereal[i])
	
	
	g_LaserSpr = precache_model("sprites/laserbeam.spr")
	
	cvar_LR300_price = register_cvar("de_wpn_lr300_price", "60")
	cvar_LR300_dmg = register_cvar("de_wpn_lr300_dmg", "80.0")
	cvar_Ethereal_price = register_cvar("de_wpn_ethereal_price", "88")
	cvar_Ethereal_dmg = register_cvar("de_wpn_ethereal_dmg", "110.0")
}

public plugin_init()
{
	register_event("CurWeapon", "event_curweapon", "be", "1=1")
	
	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_PlaybackEvent, "fw_PlaybackEvent")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	
	for(new i = 0; i < sizeof weapon_ent; i++)
	{
		RegisterHam(Ham_Item_Deploy, weapon_ent[i], "fw_Item_Deploy_Post", 1)
		RegisterHam(Ham_Weapon_PrimaryAttack, weapon_ent[i], "fw_Weapon_PrimaryAttack")
		RegisterHam(Ham_Weapon_PrimaryAttack, weapon_ent[i], "fw_Weapon_PrimaryAttack_Post", 1)
		RegisterHam(Ham_Item_AddToPlayer, weapon_ent[i], "fw_Item_AddToPlayer", 1)
		// RegisterHam(Ham_Weapon_Reload, weapon_ent[i], "fw_Weapon_Reload")
		RegisterHam(Ham_Weapon_Reload, weapon_ent[i], "fw_Weapon_Reload_Post", 1)
	}
	
	for(new i = 0; i < sizeof(g_EntNames); i++)
	{
		RegisterHam(Ham_TraceAttack, g_EntNames[i], "fw_TraceAttack")
		RegisterHam(Ham_TakeDamage, g_EntNames[i], "fw_TakeDamage")
	}
	
	g_Wpnid_LR300 = de_register_gash_wpn(LR300_NAME, get_pcvar_num(cvar_LR300_price))
	g_Wpnid_Ethereal = de_register_gash_wpn(ETHEREAL_NAME, get_pcvar_num(cvar_Ethereal_price))
}

public de_gashwpn_select(id, wid)
{
	if (!is_user_alive(id))
		return
	
	drop_weapons(id, 1)
	
	if(wid == g_Wpnid_LR300) give_weapon_lr300(id)
	if(wid == g_Wpnid_Ethereal) give_weapon_ethereal(id)
	
}

//Give Wpn
public give_weapon_lr300(id)
{
	new iEntity = fm_give_item(id, "weapon_sg552")
	if (iEntity > 0)
	{
		set_pev(iEntity, pev_weapons, WEAPON_LR300)
		set_pev(iEntity, pev_gashgun, GASHGUN_CODE)
		set_pev(iEntity, pev_owner, id)
		set_pdata_int(iEntity, m_iClip, 30, 4)
		cs_set_user_bpammo(id, CSW_SG552, 90)
	}
}

public give_weapon_ethereal(id)
{
	new iEntity = fm_give_item(id, "weapon_mp5navy")
	if (iEntity > 0)
	{
		set_pev(iEntity, pev_weapons, WEAPON_ETHEREAL)
		set_pev(iEntity, pev_gashgun, GASHGUN_CODE)
		set_pev(iEntity, pev_owner, id)
		set_pdata_int(iEntity, m_iClip, 30, 4)
		cs_set_user_bpammo(id, CSW_MP5NAVY, 120)
	}
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
	RegisterHamFromEntity(Ham_TraceAttack, id, "fw_TraceAttack")
	g_hasBot = true
}

public event_curweapon(id)
{
	if(!is_user_alive(id))
		return
	new Ent = get_pdata_cbase(id, m_pActiveItem)
	if(Ent <= 0)
		return
	
	if(pev(Ent, pev_gashgun) != GASHGUN_CODE)
		return

	switch(pev(Ent, pev_weapons))
	{
		case WEAPON_LR300:{
			set_pev(id, pev_viewmodel2, g_Mdl_LR300[0])
			set_pev(id, pev_weaponmodel2, g_Mdl_LR300[1])	
		}
		case WEAPON_ETHEREAL:{
			set_pev(id, pev_viewmodel2, g_Mdl_Ethereal[0])
			set_pev(id, pev_weaponmodel2, g_Mdl_Ethereal[1])	
		}
	}
}

public fw_SetModel(Ent, szModel[])
{
	new szClassName[32]
	pev(Ent, pev_classname, szClassName, charsmax(szClassName))
	
	if (!equal(szClassName, "weaponbox"))
		return FMRES_IGNORED
	
	new const m_rgpPlayerItems_CWeaponBox[6] = { 34, 35, 36, 37, 38, 39 }
	new iEnt = get_pdata_cbase(Ent, m_rgpPlayerItems_CWeaponBox[1], 4)
	
	if(!pev_valid(iEnt))
		return FMRES_IGNORED;
	
	switch( pev(iEnt, pev_weapons) )
	{
		case WEAPON_LR300:
		{
			engfunc(EngFunc_SetModel, Ent, g_Mdl_LR300[2])
			return FMRES_SUPERCEDE
		}
		case WEAPON_ETHEREAL:
		{
			engfunc(EngFunc_SetModel, Ent, g_Mdl_Ethereal[2])
			return FMRES_SUPERCEDE
		}
	}

	return FMRES_IGNORED;
}


public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	if(!is_user_connected(attacker) || !is_user_connected(victim) || victim == attacker)
		return HAM_IGNORED
	
	new WpnEnt = get_pdata_cbase(attacker, m_pActiveItem)
	
	if(pev(WpnEnt, pev_gashgun) != GASHGUN_CODE)
		return HAM_IGNORED
	
	new Float:truedamage
	//LR300
	switch(pev(WpnEnt, pev_weapons))
	{
		case WEAPON_LR300: truedamage = get_pcvar_float(cvar_LR300_dmg)
		case WEAPON_ETHEREAL: truedamage = get_pcvar_float(cvar_Ethereal_dmg)
	}
	
	switch(get_pdata_int(victim, m_LastHitGroup, 5))
	{
		case HIT_HEAD: truedamage*= 1.5
		case HIT_CHEST..HIT_STOMACH: truedamage*= 1.25
		case HIT_LEFTARM..HIT_RIGHTARM: truedamage*= 1.1
		case HIT_LEFTLEG..HIT_RIGHTLEG: truedamage*= 0.9
	}
	
	SetHamParamFloat(4,  truedamage)
	return HAM_IGNORED
}

public fw_TraceAttack(ent, attacker, Float:Damage, Float:fDir[3], ptr, iDamageType)
{
	if(!is_user_alive(attacker))
		return HAM_IGNORED
	
	new Ent = get_pdata_cbase(attacker, m_pActiveItem)
	
	if(pev(Ent, pev_gashgun) != GASHGUN_CODE)
		return HAM_IGNORED
	
	static Float:flEnd[3], Float:vecPlane[3]
	
	get_tr2(ptr, TR_vecEndPos, flEnd)
	get_tr2(ptr, TR_vecPlaneNormal, vecPlane)
	
	if(!is_user_alive(ent))
		make_bullet(attacker, flEnd)
	
	if(pev(Ent, pev_weapons) == WEAPON_ETHEREAL)
	{
		new Float:StartOrigin[3]
		get_position(pev(Ent, pev_owner), 52.0, 7.5, -7.0, StartOrigin)
		DrawLineFromWeapon(StartOrigin, flEnd, {0, 0, 255})
	}
	
	return HAM_HANDLED
}

public fw_Weapon_PrimaryAttack(Ent)
{
	if (!get_pdata_int(Ent, m_iClip, 4))
		return HAM_IGNORED
	
	if(pev(Ent, pev_gashgun) != GASHGUN_CODE)
		return HAM_IGNORED
	
	new id = pev(Ent, pev_owner)
	switch(pev(Ent, pev_weapons))
	{
		case WEAPON_LR300:{
			engfunc(EngFunc_EmitSound, Ent, CHAN_ITEM, g_Snd_LR300[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			SetWeaponAnimation(id, random_num(3, 5))		
		}
		case WEAPON_ETHEREAL:
		{
			set_pdata_float(Ent, m_flNextPrimaryAttack, 0.09, 4)
			set_pdata_float(id, m_flNextAttack, 0.09, 5)
			SetWeaponAnimation(id, random_num(3, 5))
			engfunc(EngFunc_EmitSound, Ent, CHAN_ITEM, g_Snd_Ethereal[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			pev(id, pev_punchangle, g_PunchAngle[id])
		}
	}
	
	return HAM_IGNORED
}

public fw_Weapon_PrimaryAttack_Post(Ent)
{
	if (!get_pdata_int(Ent, m_iClip, 4))
		return
	if(pev(Ent, pev_gashgun) != GASHGUN_CODE)
		return
	
	new id = pev(Ent, pev_owner)
	if(pev(Ent, pev_weapons) == WEAPON_ETHEREAL)
		SetPlayerRecoil(id, 0.1, g_PunchAngle[id])
}

public fw_Item_AddToPlayer(Ent, id)
{
	if(!pev_valid(Ent))
		return HAM_IGNORED
	if(pev(Ent, pev_weapons) == WEAPON_LR300)
	{
		set_pev(Ent, pev_owner, id)
		set_pdata_float(id, m_flNextAttack, 0.85)
	}
	
	return HAM_HANDLED
}

public fw_Item_Deploy_Post(Ent)
{
	new id = pev(Ent, pev_owner)
	
	switch(pev(Ent, pev_weapons))
	{
		case WEAPON_LR300:{
			set_pev(id, pev_viewmodel2, g_Mdl_LR300[0])
			set_pev(id, pev_weaponmodel2, g_Mdl_LR300[1])
			SetWeaponAnimation(id, 2)
			set_pdata_float(Ent, m_flNextPrimaryAttack, 0.75, 4)
		}
		case WEAPON_ETHEREAL:{
			set_pev(id, pev_viewmodel2, g_Mdl_Ethereal[0])
			set_pev(id, pev_weaponmodel2, g_Mdl_Ethereal[1])
			SetWeaponAnimation(id, 2)
			set_pdata_float(Ent, m_flNextPrimaryAttack, 0.45, 4)
		}
	}
	return HAM_SUPERCEDE
}

public fw_Weapon_Reload_Post(Ent)
{
	new id = pev(Ent, pev_owner)
	switch(pev(Ent, pev_weapons))
	{
		case WEAPON_LR300:{
			if(get_pdata_int(Ent, m_iClip, 4) >= 30)
				return
			SetWeaponAnimation(id, 1)
			set_pdata_float(Ent, m_flNextPrimaryAttack, 2.5, 4)
		}
		case WEAPON_ETHEREAL:{
			if(get_pdata_int(Ent, m_iClip, 4) >= 30)
				return
			SetWeaponAnimation(id, 1)
			set_pdata_float(Ent, m_flNextPrimaryAttack, 2.85, 4)
		}
	}
}

public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
	if(!is_user_alive(id))
		return FMRES_IGNORED	
	
	new Ent = get_pdata_cbase(id, m_pActiveItem)
	
	if(!pev_valid(Ent))
		return FMRES_IGNORED
	
	if(pev(Ent, pev_gashgun) == GASHGUN_CODE)
		set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001) 
	
	return FMRES_HANDLED
}

public fw_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if (!is_user_connected(invoker))
		return FMRES_IGNORED
	
	new Ent = get_pdata_cbase(invoker, m_pActiveItem)
	if(!pev_valid(Ent))
		return FMRES_IGNORED
		
	if(pev(Ent, pev_gashgun) == GASHGUN_CODE)
		return FMRES_IGNORED
	
	engfunc(EngFunc_PlaybackEvent, flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
	
	
	return HAM_SUPERCEDE
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

stock DrawLineFromWeapon(const Float:StartOrigin[], const Float:TargetOrigin[], const rgb[])
{
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
	write_byte(1);	//Life
	write_byte(10);	//Width
	write_byte(0);	//wave
	write_byte(rgb[0]); // r
	write_byte(rgb[1]); // g
	write_byte(rgb[2]); // b
	write_byte(200);
	write_byte(255);
	message_end();
}

