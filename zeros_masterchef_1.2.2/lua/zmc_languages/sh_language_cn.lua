--leak by matveicher
--vk group - https://vk.com/gmodffdev
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/V329W7Ce8g
--ds - matveicher#5801

zmc = zmc or {}
zmc.language = zmc.language or {}
if (zmc.config.SelectedLanguage == "cn") then

    zmc.language["Review_0_01"] = "真糟糕, 我的 $FoodName 怎么还没来."
    zmc.language["Review_0_02"] = "太糟糕了!"
    zmc.language["Review_0_03"] = "我在这里哭 :("

    zmc.language["Review_1_01"] = "我等了 $FoodName 这么久!"
    zmc.language["Review_1_02"] = "我觉得有根头发在我的 $FoodName 里!"
    zmc.language["Review_1_03"] = "为什么需要那么久?"

    zmc.language["Review_2_01"] = "食物 $FoodName 还可以,女服务员非常热情."
    zmc.language["Review_2_02"] = "服务还可以,食物比微波炉食物更好."
    zmc.language["Review_2_03"] = "食物 $FoodName 非常不错."

    zmc.language["Review_3_01"] = "食物 $FoodName 是用爱制作的,我很快就会再来 :)"
    zmc.language["Review_3_02"] = "这家伙真的知道如何做一些好的 $FoodName!"
    zmc.language["Review_3_03"] = "这太好了!"

    zmc.language["Review_4_01"] = "食物 $FoodName 马上就来了,味道很好!"
    zmc.language["Review_4_02"] = "这里的服务很棒!"
    zmc.language["Review_4_03"] = "食物 $FoodName 是我吃过的最好的!"


    zmc.language["Edit Appearance"] = "编辑外观"
    zmc.language["Edit Whitelist"] = "编辑白名单"
    zmc.language["Possible Orders:"] = "可能的订单:"
    zmc.language["Appearance"] = "外观"
    zmc.language["Update"] = "更新"
    zmc.language["NO SEAT"] = "不设置座位"

    zmc.language["Restrict_Orders"] = "限制顾客点的菜."
    zmc.language["Whitelist_AddDish"] = "将菜添加到白名单"

    zmc.language["Cook Menu"] = "烹饪菜单"
    zmc.language["Cancel"] = "取消"
    zmc.language["Missing Ingredients:"] = "缺少成分:"
    zmc.language["Dishtable"] = "餐桌"


    zmc.language["tooltip_clipboard"] = "将配置代码复制到剪贴板"

    zmc.language["Copy"] = "复制"

    zmc.language["Select Dish"] = "选择菜"

    zmc.language["Dishes"] = "菜肴"
    zmc.language["Ingredients"] = "原料"
    zmc.language["Dish Editor"] = "菜品编辑"
    zmc.language["Order Time"] = "订购时间"
    zmc.language["tooltip_OrderTime"] = "玩家需要多少时间来制作这道菜?"

    zmc.language["ingredient_count_warning"] = "盘子上不能放超过 10 种食物!"
    zmc.language["Add Food"] = "添加食物"

    zmc.language["Pitch"] = "旋转"
    zmc.language["Yaw"] = "偏移"
    zmc.language["Roll"] = "翻转"
    zmc.language["Height"] = "高度"
    zmc.language["Scale"] = "比例"

    zmc.language["Dish Name"] = "菜名"
    zmc.language["Delete this Dish?"] = "删除这道菜?"
    zmc.language["Config code copied to clipboard!"] = "配置代码复制到剪贴板!"

    zmc.language["Ready"] = "准备好"
    zmc.language["Need"] = "需要 $ItemName"

    zmc.language["Fridge"] = "冰箱"
    zmc.language["Buy"] = "购买"
    zmc.language["All"] = "全部"
    zmc.language["Search"] = "搜索"
    zmc.language["ItemName"] = "物品名字"
    zmc.language["Restrict_Buy"] = "限制玩家可以购买的物品"
    zmc.language["Whitelist_AddItem"] = "将物品添加到白名单"

    zmc.language["item_limit_reached"] = "已达到物品限制!"
    zmc.language["ItemBoughtNotify"] = "你买了 $ItemName 花费了 $CurrencyAmount!"

    zmc.language["Start"] = "开始"
    zmc.language["Stop"] = "停止"

    zmc.language["MissingIngredients"] = "你缺少成分!"
    zmc.language["Temperature"] = "温度"

    zmc.language["Choose Recipe"] = "选择食谱"

    zmc.language["Missing Gastank"] = "气罐不见了!"

    // Refers to a warning on the grill for meat on the grill which will burn if the player doesent flip it
    zmc.language["FLIP!"] = "翻动!"


    zmc.language["Inventory:"] = "库存:"

    zmc.language["Drop"] = "丢下"
    zmc.language["tooltip_drop"] = "丢下所选物品."

    zmc.language["Items"] = "物品"
    zmc.language["Item Editor"] = "物品编辑器"
    zmc.language["Update Bodygroups"] = "更新Bodygroups"
    zmc.language["Name"] = "名称"
    zmc.language["Skin"] = "外观"
    zmc.language["Model"] = "模型"
    zmc.language["Material"] = "材质"
    zmc.language["Components"] = "成分"

    zmc.language["tooltip_temperature"] = "指定物品开始烘焙/烹饪的温度."

    zmc.language["Result"] = "结果"
    zmc.language["Select Item"] = "选择物品"
    zmc.language["ingredient_count_warning_craft"] = "你不能有超过 4 种材料来制作!"
    zmc.language["ingredient_count_warning_generic"] = "你不能有超过 12 种成分!"
    zmc.language["Add Ingredient"] = "添加成分"
    zmc.language["Appearance Editor"] = "外观编辑器"
    zmc.language["Add Component"] = "添加成分"
    zmc.language["Delete this Item?"] = "删除此物品?"
    zmc.language["Duplicate this Item?"] = "复制这个物品?"

    zmc.language["Position"] = "位置"
    zmc.language["Bodygroup Editor"] = "Bodygroup编辑器"
    zmc.language["Bodygroups"] = "Bodygroups"

    zmc.language["Whitelist Editor"] = "白名单编辑器"
    zmc.language["Whitelist Empty"] = "没有物品列入白名单!"

    zmc.language["Ordered Dishes:"] = "点菜:"
    zmc.language["Allow Custom Orders"] = "允许自定义订单"

    zmc.language["tooltip_CustomOrders"] = "允许客户订购随机菜肴,他们将根据这些菜肴判断/评论您的服务,\n这可以增加/降低客户的幸福感!\n禁用自定义订单使订单表更像自助餐台."

    zmc.language["Orders:"] = "订单:"
    zmc.language["Open for Business"] = "营业"
    zmc.language["Closed"] = "休业"
    zmc.language["ON"] = "开"
    zmc.language["OFF"] = "关"
    zmc.language["Customer Happiness:"] = "客户幸福感:"
    zmc.language["Earnings:"] = "收益:"
    zmc.language["Custom Orders:"] = "定制订单:"


    zmc.language["Process"] = "进程"
    zmc.language["Cut"] = "切"
    zmc.language["Knead"] = "揉"
    zmc.language["Craft:"] = "制作:"
    zmc.language["Select Recipe"] = "选择食谱"



    zmc.language["comp_title_fridge"] = "冰箱"
    zmc.language["comp_desc_fridge"] = "可以从冰箱里买到."

    zmc.language["comp_title_cut"] = "切"
    zmc.language["comp_desc_cut"] = "可以切成小块."

    zmc.language["comp_title_knead"] = "揉"
    zmc.language["comp_desc_knead"] = "可以揉成什么东西."

    zmc.language["comp_title_bake"] = "烤"
    zmc.language["comp_desc_bake"] = "可以烤."

    zmc.language["comp_title_mix"] = "混合"
    zmc.language["comp_desc_mix"] = "可混合多种成分."

    zmc.language["comp_title_sell"] = "出售"
    zmc.language["comp_desc_sell"] = "可以出售."

    zmc.language["comp_title_edible"] = "食用"
    zmc.language["comp_desc_edible"] = "可食用."

    zmc.language["comp_title_grill"] = "炙烤"
    zmc.language["comp_desc_grill"] = "可以烤."

    zmc.language["comp_title_wok"] = "炒锅"
    zmc.language["comp_desc_wok"] = "可以在炒锅里做."

    zmc.language["comp_title_soup"] = "汤"
    zmc.language["comp_desc_soup"] = "可以在汤锅里制作."

    zmc.language["comp_title_boil"] = "熬"
    zmc.language["comp_desc_boil"] = "可以煮."

    zmc.language["comp_title_craft"] = "制作"
    zmc.language["comp_desc_craft"] = "可以在工作台上制作."



    zmc.language["temp_req_title"] = "需要的温度"
    zmc.language["temp_req_tooltip"] = "物品开始烘焙的时间."

    zmc.language["time_title"] = "时间"
    zmc.language["time_tooltip"] = "处理物品所需的时间."

    zmc.language["item_tooltip"] = "我们之后得到的物品."

    zmc.language["cycle_title"] = "循环数"
    zmc.language["cycle_tooltip"] = "创建以下项目需要多少次交互."

    zmc.language["speed_title"] = "速度"
    zmc.language["speed_tooltip"] = "需要哪种混合速度?"

    zmc.language["amount_title"] = "数量"
    zmc.language["amount_tooltip"] = "我们得到多少物品?"

    zmc.language["price_title"] = "价格"
    zmc.language["price_tooltip"] = "该物品的货币价值."

    zmc.language["items_generic_tooltip"] = "制作此物品需要哪些物品?"
    zmc.language["items_cut_tooltip"] = "我们得到什么物品?"

    zmc.language["health_title"] = "健康值"
    zmc.language["health_tooltip"] = "玩家食用此物品后获得多少生命值?"

    zmc.language["health_cap_title"] = "健康值"
    zmc.language["health_cap_tooltip"] = "玩家可以从该物品中获得的最大生命值是多少?"

    zmc.language["range_title"] = "范围"
    zmc.language["range_tooltip"] = "小游戏的目标大小."


    zmc.language["Worktable"] = "工作台"
    zmc.language["Wok"] = zmc.language["comp_title_wok"]
    zmc.language["Grill"] = zmc.language["comp_title_grill"]
    zmc.language["Mixer"] = "混合器"
    zmc.language["Oven"] = "烤箱"
    zmc.language["BoilPot"] = "熬锅"
    zmc.language["SoupPot"] = "汤锅"
    zmc.language["Customertable"] = "客户桌子"


    // Update 1.0.1
    zmc.language["Throw"] = "扔"
    zmc.language["Throw_tooltip"] = "将选中的物品快速移到到另一个物品栏."

    // This text is shown next to a items name if its rotten / spoiled
    zmc.language["Spoiled"] = "[变质的]"
    zmc.language["Spoiled_desc"] = "它一半回到了地球母亲."

    // Update 1.0.3
    zmc.language["Cookbook"] = "食谱"


    // Update 1.0.6
    zmc.language["YouDontOwnThis"] = "这不是你的！"
    zmc.language["NotEnoughMoney"] = "你没有足够的钱!"
    zmc.language["ItemLimit"] = "您达到了 $ItemName 的实体限制！"
    zmc.language["Cancel"] = "取消"
    zmc.language["Deconstruct"] = "解构"
    zmc.language["Construct"] = "构造"
    zmc.language["Choosepostion"] = "选择新职位"
    zmc.language["ChooseEntity"] = "选择对象"
    zmc.language["Equipment_Build"] = "建造"
    zmc.language["Equipment_Move"] = "移动"
    zmc.language["Equipment_Repair"] = "修理"
    zmc.language["Equipment_Remove"] = "消除"

    // Update 1.2.0
    // If a none player (NPC) orders food then this will be shown as the name
    zmc.language["NPC"] = "NPC"
    zmc.language["OrderMenu"] = "Order Menu"
    zmc.language["Order Dish"] = "Order Dish"
    zmc.language["OrdertableClosed"] = "Ordertable is currently closed!"
    zmc.language["Orderlimit"] = "Order limit reached!"
    zmc.language["NoCleanPlates"] = "There are currently no clean plates available, come back later."
    zmc.language["DishNotAvailable"] = "$DishName is currently not available!"
    zmc.language["OrderAccepted"] = "You ordered $DishName and paid $Money!"
    zmc.language["DishBought"] = "You bought $DishName and paid $Money!"
    zmc.language["OrdertableFull"] = "Ordertable cant accept any more orders, come back later!"
    zmc.language["OrderFailed01"] = "Your $DishName could not be completed!"
    zmc.language["OrderFailed02"] = "We are very sorry :("
    zmc.language["OrderFailed03"] = "Refunded $Money!"
    zmc.language["OrderCompleted01"] = "You received your $DishName!"
    zmc.language["OrderCompleted02"] = "$DishName got added to your inventory!"
    zmc.language["Ordertable_AllowNPC"] = "Allow NPC Customers"
    zmc.language["Ordertable_DenyNPC"] = "Deny NPC Customers"
    zmc.language["Restrict_Dishes"] = "Restricts which dishes the player can make."

    // UPDATE 1.2.2
    zmc.language["Custom Price"] = "Custom Price"
    zmc.language["tooltip_CustomPrice"] = "Overwrites the price of the dish. If set to 0 then the ingredient price will be used."
end
--leak by matveicher
--vk group - https://vk.com/gmodffdev
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/V329W7Ce8g
--ds - matveicher#5801
