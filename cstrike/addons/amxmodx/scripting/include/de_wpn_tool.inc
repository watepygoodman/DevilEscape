#if defined _de_wpn_tool_included
	#endinput
#endif
#define _de_wpn_tool_included

#define pev_gashgun pev_iuser1
const GASHGUN_CODE = 10086

//获取视角位置
stock GetAimOrg(id, Float:origin[3])
{
	new Float:org[3], Float:ofs[3]
	pev(id, pev_origin, org)
	pev(id, pev_view_ofs, ofs)
	xs_vec_add(org, ofs, origin)
}

//设置武器动作
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

//后坐力
stock SetPlayerRecoil(id, const Float:multi, const Float:cl_pushangle[])
{
	new Float: push[3]
	pev(id, pev_punchangle, push)
	xs_vec_sub(push, cl_pushangle, push)
	xs_vec_mul_scalar(push, multi, push)
	xs_vec_add(push, cl_pushangle, push)
	set_pev(id, pev_punchangle, push)
}