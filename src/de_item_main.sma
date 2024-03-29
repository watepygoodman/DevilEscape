#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <devilescape>
// #include <bitset>

#define PLUGIN_NAME "Item List(For De)"
#define PLUGIN_VERSION "0.0"
#define PLUGIN_AUTHOR "DevilEscape"

//ItemID
enum{
	ITEM_NONE, ITEM_G_HERB, ITEM_R_HERB, ITEM_GOLD_HERB, ITEM_LATIAO, ITEM_DIOKELA, ITEM_XUMING
}

//商店没得卖在背包的
new g_Itemid[32];
new cvar_g_herb_reco, cvar_r_herb_reco, cvar_gold_herb_reco, cvar_latiao_reco, cvar_diokela_reco, cvar_xuming_reco
new cvar_item_odds[32]
//商店卖的直接用的
new g_Shopitemid_Nvision, g_Shopitemid_Respawn
new cvar_nvision_price, cvar_respawn_price, cvar_respawn_max

new const SHOP_ITEM_NAME_NVISION[] = "Night Vision"
new const SHOP_ITEM_NAME_RESPAWN[] = "Respawn"

new const ITEM_NAME[][] = {"None", "Green Herb", "Red Herb", "Gold Herb", "Latiao", "Kiola", "Newlife"}
new const ITEM_INFO[][] = {"", "Restore HP to 100", "Restore HP to 150", "Restore HP to 200", 
									   "Restore HP to 250", "Restore HP to 350",
									   "Restore HP to 500"}
new const ITEM_ODDS[] = {0, 20, 15, 10, 5, 3, 2}
									   
public plugin_natives()
{
	register_native("de_item_random_choose", "native_item_random_choose", 1)
}

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	cvar_g_herb_reco = register_cvar("de_item_gherb_reco","100.0")
	cvar_r_herb_reco = register_cvar("de_item_rherb_reco","150.0")
	cvar_gold_herb_reco = register_cvar("de_item_goldherb_reco","200.0")
	cvar_latiao_reco = register_cvar("de_item_latiao_reco","250.0")
	cvar_diokela_reco = register_cvar("de_item_diokela_reco","350.0")
	cvar_xuming_reco = register_cvar("de_item_xuming_reco","500.0")
	
	cvar_nvision_price = register_cvar("de_item_nvision_price", "3")
	cvar_respawn_price = register_cvar("de_item_respawn_price", "100")
	cvar_respawn_max = register_cvar("de_item_respawn_max_round", "2")
	
	for(new i = 0; i < sizeof ITEM_NAME; i++)
		g_Itemid[i] = de_register_item(ITEM_NAME[i], ITEM_INFO[i])
	
	for(new i = 0; i < sizeof ITEM_NAME; i++)
	{
		static _Command[32]
		static _Odds[3]
		formatex(_Command, charsmax(_Command), "de_item_%d_odds", i)
		num_to_str(ITEM_ODDS[i], _Odds, charsmax(_Odds))
		
		cvar_item_odds[i] = register_cvar(_Command, _Odds)
	}
	
	g_Shopitemid_Nvision = de_register_shop_item(SHOP_ITEM_NAME_NVISION, get_pcvar_num(cvar_nvision_price), 0)
	g_Shopitemid_Respawn = de_register_shop_item(SHOP_ITEM_NAME_RESPAWN, get_pcvar_num(cvar_respawn_price), get_pcvar_num(cvar_respawn_max))
	
}

public de_item_select(id, itemid)
{
	if(itemid == g_Itemid[ITEM_G_HERB])			 set_pev(id, pev_health, get_pcvar_float(cvar_g_herb_reco))
	else if(itemid == g_Itemid[ITEM_R_HERB])		 set_pev(id, pev_health, get_pcvar_float(cvar_r_herb_reco))
	else if(itemid == g_Itemid[ITEM_GOLD_HERB]) set_pev(id, pev_health, get_pcvar_float(cvar_gold_herb_reco))
	else if(itemid == g_Itemid[ITEM_LATIAO])		 set_pev(id, pev_health, get_pcvar_float(cvar_latiao_reco))
	else if(itemid == g_Itemid[ITEM_DIOKELA])	 set_pev(id, pev_health, get_pcvar_float(cvar_diokela_reco))
	else if(itemid == g_Itemid[ITEM_XUMING])	 set_pev(id, pev_health, get_pcvar_float(cvar_xuming_reco))
}

public de_shop_item_select(id, itemid)
{
	new team = get_pdata_int(id, m_CsTeam)
	if(itemid == g_Shopitemid_Nvision && team == 2)
	{
		de_set_user_nightvision(id, 1)
		return 1
	}
	else if(itemid == g_Shopitemid_Respawn && team == 2)
	{
		if(!is_user_alive(id))
		{
			ExecuteHamB(Ham_CS_RoundRespawn,id)
			return 1
		}
	}
	
	return 0
}

/* ==========================

					[Natives]
			 
==========================*/

public native_item_random_choose()
{
	new _RandomNum = random_num(1, 100)
	// client_print(0, print_chat, "Num:%d", _RandomNum)
	for(new i = 1; i < sizeof ITEM_NAME ; i++)
	{
		new _Chance1, _Chance2
		for(new j = 0; j < i; j++)
		{
			_Chance1 += get_pcvar_num(cvar_item_odds[j])
			_Chance2 += get_pcvar_num(cvar_item_odds[j+1])
		}
		client_print(0, print_center, "%d <= %d < %d", _Chance1,  _RandomNum, _Chance2)
		if(_Chance1<= _RandomNum < _Chance2)
			return i
	}
	return 0
}

