local lang = locale
local function translate(String)  -- use this fn can be automatically translated according to the language in the table
	String.zhr = String.zh
	String.zht = String.zht or String.zh
	return String[lang] or String.en
end

--The name of the mod displayed in the 'mods' screen.
name = translate({en = "better wendy", zh = "更好的温蒂"})

--A description of the mod.
description = "version v1.3.0"

--Who wrote this awesome mod?
author = "TUTU"

--A version number so you can ask people if they are running an old version of your mod.
version = "v1.4.0"

--This lets other players know if your mod is out of date. This typically needs to be updated every time there's a new game update.
api_version = 10

dst_compatible = true

--This lets clients know if they need to get the mod from the Steam Workshop to join the game
all_clients_require_mod = true

--This determines whether it causes a server to be marked as modded (and shows in the mod list)
client_only_mod = false

--This lets people search for servers with this mod by these tags
server_filter_tags = {}


priority = 0  --模组优先级0-10 mod 加载的顺序   0最后载入  覆盖大值

configuration_options={ --模组变量配置
	{
		name = "ghostflowerhat",--modmain脚本里调用变量
		hover = translate({en = "Configure Ghostly Wreath's Defense and Planardefense", zh = "配置幽魂花冠的防御力和位面防御"}),
		label = translate({en = "Wraith's Wreath", zh = "幽魂花冠改动"}),--游戏里显示的名字
		options ={	
					{description = translate({en = "Disable", zh = "禁用"}), data = false},
					{description = translate({en = "Only 70%", zh = "仅70%"}), data = 1},
					{description = translate({en = "Only 80%", zh = "仅80%"}), data = 2},
					{description = translate({en = "80% + 5 ", zh = "80%+5"}), data = 3},
				},
		default = 2,
	},

	{
		name = "moondial",--modmain脚本里调用变量
		hover = translate({en = "Mutate Abigail at the Moondial any night.", zh = "任何晚上都可以在月晷对阿比盖尔进行升级或者恢复普通形态"}),
		label = translate({en = "Abigail's Flexible Mutation", zh = "更灵活地升级阿比盖尔"}),--游戏里显示的名字
		options ={	
					{description = translate({en = "Enable", zh = "启用"}), data = true},
					{description = translate({en = "Disable", zh = "禁用"}), data = false},
				},
		default = true,
	},

	{
		name = "gravestone",--modmain脚本里调用变量
		hover = translate({en = "Decorated Graves yield extra Mourning Glory.", zh = "装饰后的坟墓额外掉落哀悼荣耀"}),
		label = translate({en = "Grave Stone drop Mourning Glory", zh = "坟墓掉落哀悼荣耀"}),--游戏里显示的名字
		options ={	
					{description = translate({en = "Disable", zh = "禁用"}), data = false},
					{description = translate({en = "Low Drop Rate", zh = "较低掉落率"}), data = 1},
					{description = translate({en = "Normal Drop Rate", zh = "普通掉落率"}), data = 2},
					{description = translate({en = "High Drop Rate", zh = "较高掉落率"}), data = 3},
				},
		default = 2,
	},

	{
		name = "blossom_sisturn",--modmain脚本里调用变量
		hover = translate({en = "After placing Moon Blossom in the Sisturn, Abigail's healing effect is no longer halved.", zh = "骨灰盒放入月树花瓣后，阿比盖尔的治疗效果不再减半"}),
		label = translate({en = "Moon Blossom Sisturn", zh = "月树花骨灰盒"}),--游戏里显示的名字
		options ={	
					{description = translate({en = "Enable", zh = "启用"}), data = true},
					{description = translate({en = "Disable", zh = "禁用"}), data = false},
				},
		default = true,
	},

	{
		name = "evil_sisturn",--modmain脚本里调用变量
		hover = translate({en = "After placing Evil Petals in the Sisturn, every creature that dies near Abigail will heal her.", zh = "骨灰盒放入恶魔花瓣后，阿比盖尔附近的每个生物在死亡时将治疗阿比盖尔"}),
		label = translate({en = "Evil Flower Sisturn", zh = "恶魔花骨灰盒"}),--游戏里显示的名字
		options ={	
					{description = translate({en = "Enable", zh = "启用"}), data = true},
					{description = translate({en = "Disable", zh = "禁用"}), data = false},
				},
		default = true,
	},

	{
		name = "skill_connects",--modmain脚本里调用变量
		hover = translate({en = "Remove preconditions for Mourning Glory and Grave Skills", zh = "取消哀悼荣耀技能和坟墓技能的前置条件"}),
		label = translate({en = "Remove prerequisite skill", zh = "取消前置技能"}),--游戏里显示的名字
		options ={	
					{description = translate({en = "Enable", zh = "启用"}), data = true},
					{description = translate({en = "Disable", zh = "禁用"}), data = false},
				},
		default = true,
	},

}

mod_dependencies = {

}

icon_atlas = "Wendy.xml"
icon = "Wendy.tex"
