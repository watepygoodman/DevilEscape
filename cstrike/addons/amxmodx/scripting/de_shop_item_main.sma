#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <devilescape>

#define PLUGIN_NAME "商店列表(For De)"
#define PLUGIN_VERSION "0.0"
#define PLUGIN_AUTHOR "DevilEscape"

enum{
	SHOP_ITEM_NVISION
}

new const SHOP_ITEM_NAME_NVISION[] = "夜视仪"

new g_Shopitemid_Nvision
new cvar_nvision_price
public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	cvar_nvision_price = register_cvar("de_item_nvision_price", "3")
	
	
	g_Shopitemid_Nvision = de_register_shop_item(SHOP_ITEM_NAME_NVISION, get_pcvar_num(cvar_nvision_price))
}

public de_shop_item_select(id, itemid)
{
	if(itemid == g_Shopitemid_Nvision)
		 de_set_user_nightvision(id, 1)
}
