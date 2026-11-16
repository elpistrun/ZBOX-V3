--leak by matveicher
--vk group - https://vk.com/gmodffdev
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/V329W7Ce8g
--ds - matveicher#5801

zmc = zmc or {}
zmc.language = zmc.language or {}
zmc = zmc or {}
zmc.language = zmc.language or {}

if (zmc.config.SelectedLanguage == "ru") then

    zmc.language["Review_0_01"] = "Очень плохо, мой $FoodName так и не принесли."
    zmc.language["Review_0_02"] = "Ужасно!"
    zmc.language["Review_0_03"] = "Мне не понравилось питание здесь :("

    zmc.language["Review_1_01"] = "Я так долго ждал своего $FoodName!"
    zmc.language["Review_1_02"] = "Я думаю, что в моем $FoodName есть волосы!"
    zmc.language["Review_1_03"] = "Почему это заняло так много времени?"

    zmc.language["Review_2_01"] = "$FoodName была и официантка была чертовски горячей."
    zmc.language["Review_2_02"] = "Сервис довольно приятный, еда с хорошей поражённостью."
    zmc.language["Review_2_03"] = "$FoodName была хорошей."

    zmc.language["Review_3_01"] = "$FoodName сделана с любовью, я скоро вернусь :)"
    zmc.language["Review_3_02"] = "Этот парень действительно знает, как сделать что-то хорошее $FoodName!"
    zmc.language["Review_3_03"] = "Эта еда хороша!"

    zmc.language["Review_4_01"] = "$FoodName пришла мгновенно, и это было так вкусно!"
    zmc.language["Review_4_02"] = "Сервис просто замечательный!"
    zmc.language["Review_4_03"] = "$FoodName это было лучшее, что я когда-либо пробовал!"


    zmc.language["Edit Appearance"] = "Изменить внешний вид"
    zmc.language["Edit Whitelist"] = "Изменить белый список"
    zmc.language["Possible Orders:"] = "Возможные заказы:"
    zmc.language["Appearance"] = "Внешний вид"
    zmc.language["Update"] = "Обновить"
    zmc.language["NO SEAT"] = "МЕСТ НЕТ"

    zmc.language["Restrict_Orders"] = "Ограничивает, какие блюда заказывают клиенты."
    zmc.language["Whitelist_AddDish"] = "Добавить блюдо в белый список"

    zmc.language["Cook Menu"] = "Меню повара"
    zmc.language["Cancel"] = "Отменить"
    zmc.language["Missing Ingredients:"] = "Недостающие ингредиенты:"
    zmc.language["Dishtable"] = "Стол с посудой"


    zmc.language["tooltip_clipboard"] = "Скопировать конфигурацию в буфер обмена"

    zmc.language["Copy"] = "Скопировать"

    zmc.language["Select Dish"] = "Выбрать блюдо"

    zmc.language["Dishes"] = "Блюда"
    zmc.language["Ingredients"] = "Ингредиенты"
    zmc.language["Dish Editor"] = "Редактор блюд"
    zmc.language["Order Time"] = "Время заказа"
    zmc.language["tooltip_OrderTime"] = "Сколько времени у игрока есть, чтобы приготовить это блюдо?"

    zmc.language["ingredient_count_warning"] = "Вы не можете иметь на тарелке более 10 продуктов питания!"
    zmc.language["Add Food"] = "Добавить еду"

    zmc.language["Pitch"] = "Pitch"
    zmc.language["Yaw"] = "Yaw"
    zmc.language["Roll"] = "Roll"
    zmc.language["Height"] = "Высота"
    zmc.language["Scale"] = "Размер"

    zmc.language["Dish Name"] = "Название блюда"
    zmc.language["Delete this Dish?"] = "Удалите это блюдо?"
    zmc.language["Config code copied to clipboard!"] = "Код конфигурации скопирован в буфер обмена!"

    zmc.language["Ready"] = "Готово"
    zmc.language["Need"] = "Необходимо $ItemName"

    zmc.language["Fridge"] = "Холодильник"
    zmc.language["Buy"] = "Купить"
    zmc.language["All"] = "Всё"
    zmc.language["Search"] = "Поиск"
    zmc.language["ItemName"] = "Ингредиент"
    zmc.language["Restrict_Buy"] = "Ограничивает количество предметов, которые игрок может купить"
    zmc.language["Whitelist_AddItem"] = "Добавить ингредиент в белый список"

    zmc.language["item_limit_reached"] = "Достигнут лимит товара!"
    zmc.language["ItemBoughtNotify"] = "Вы купили $ItemName за $CurrencyAmount!"

    zmc.language["Start"] = "Начать"
    zmc.language["Stop"] = "Остановить"

    zmc.language["MissingIngredients"] = "Вам не хватает ингредиентов!"
    zmc.language["Temperature"] = "Температура"

    zmc.language["Choose Recipe"] = "Выбрать рецепт"

    zmc.language["Missing Gastank"] = "Нету газового балона!"

    // Относится к предупреждению на гриле для мяса, которое сгорит, если игрок не перевернет его
    zmc.language["FLIP!"] = "ПЕРЕВЕРНУТЬ!"


    zmc.language["Inventory:"] = "Инвентарь:"

    zmc.language["Drop"] = "Выкинуть"
    zmc.language["tooltip_drop"] = "Выбросить выбранный предмет."

    zmc.language["Items"] = "Предметы"
    zmc.language["Item Editor"] = "Редактор предметов"
    zmc.language["Update Bodygroups"] = "Обновить Bodygroups"
    zmc.language["Name"] = "Название"
    zmc.language["Skin"] = "Скин"
    zmc.language["Model"] = "Модель"
    zmc.language["Material"] = "Материал"
    zmc.language["Components"] = "Компоненты"
    zmc.language["tooltip_temperature"] = "Указывает, при какой температуре изделие начинает выпекаться / готовиться."

    zmc.language["Result"] = "Результат"
    zmc.language["Select Item"] = "Выбрать предмет"
    zmc.language["ingredient_count_warning_craft"] = "У вас не может быть более 4 ингредиентов для крафта!"
    zmc.language["ingredient_count_warning_generic"] = "У вас не может быть более 12 ингредиентов!"
    zmc.language["Add Ingredient"] = "Добавить ингредиент"
    zmc.language["Appearance Editor"] = "Редактор внешнего вида"
    zmc.language["Add Component"] = "Добавить компанент"
    zmc.language["Delete this Item?"] = "Удалить этот предмет?"
    zmc.language["Duplicate this Item?"] = "Дублировать этот пункт?"

    zmc.language["Position"] = "Позиция"
    zmc.language["Bodygroup Editor"] = "Редактор Bodygroup"
    zmc.language["Bodygroups"] = "Bodygroups"

    zmc.language["Whitelist Editor"] = "Редактор белого списка"
    zmc.language["Whitelist Empty"] = "Нет предметов в белом списке!"

    zmc.language["Ordered Dishes:"] = "Заказанные блюда:"
    zmc.language["Allow Custom Orders"] = "Разрешить свои заказы"

    zmc.language["tooltip_CustomOrders"] = "Позволяет клиентам заказывать случайные блюда, по которым они будут судить / оценивать ваш сервис." .. [[\]] .. "что может увеличить / уменьшить Счастье клиентов!" .. [[\]] .. "Привязка пользовательских заказов делает таблицу заказов более похожей на буфетную."

    zmc.language["Orders:"] = "Заказы:"
    zmc.language["Open for Business"] = "Открыт для бизнеса"
    zmc.language["Closed"] = "Закрыто"
    zmc.language["ON"] = "ON"
    zmc.language["OFF"] = "OFF"
    zmc.language["Customer Happiness:"] = "Счастье клиентов:"
    zmc.language["Earnings:"] = "Прибыль:"
    zmc.language["Custom Orders:"] = "Индивидуальные заказы:"

    zmc.language["Process"] = "Процесс"
    zmc.language["Cut"] = "Резать"
    zmc.language["Knead"] = "Месить"
    zmc.language["Craft:"] = "Создать:"
    zmc.language["Select Recipe"] = "Выбрать рецепт"



    zmc.language["comp_title_fridge"] = "Холодильник"
    zmc.language["comp_desc_fridge"] = "Можно купить ингредиенты в холодильнике."

    zmc.language["comp_title_cut"] = "Резать"
    zmc.language["comp_desc_cut"] = "Можно разрезать на кусочки."

    zmc.language["comp_title_knead"] = "Месить"
    zmc.language["comp_desc_knead"] = "Можно что-нибудь вымешать."

    zmc.language["comp_title_bake"] = "Запечь"
    zmc.language["comp_desc_bake"] = "Можно запечь " .. [[/ᐠ｡ꞈ｡ᐟ\]]

    zmc.language["comp_title_mix"] = "Смесь"
    zmc.language["comp_desc_mix"] = "Смешивается из нескольких ингредиентов."

    zmc.language["comp_title_sell"] = "Продать"
    zmc.language["comp_desc_sell"] = "Может быть продан."

    zmc.language["comp_title_edible"] = "Съедобный"
    zmc.language["comp_desc_edible"] = "Можно употреблять."

    zmc.language["comp_title_grill"] = "Гриль"
    zmc.language["comp_desc_grill"] = "Можно поджарить на гриле."

    zmc.language["comp_title_wok"] = "Сковородка"
    zmc.language["comp_desc_wok"] = "Можно что-нибудь приготовить."

    zmc.language["comp_title_soup"] = "Кастрюля для супа"
    zmc.language["comp_desc_soup"] = "Можно приготовить в кастрюле для супа."

    zmc.language["comp_title_boil"] = "Кастрюля"
    zmc.language["comp_desc_boil"] = "Можно варить."

    zmc.language["comp_title_craft"] = "Изготовить"
    zmc.language["comp_desc_craft"] = "Может быть изготовлен на рабочем столе."

    zmc.language["temp_req_title"] = "Жара"
    zmc.language["temp_req_tooltip"] = "Время, в которое изделие начинает выпекаться."

    zmc.language["time_title"] = "Время"
    zmc.language["time_tooltip"] = "Время, необходимое для обработки элемента."

    zmc.language["item_tooltip"] = "Предмет, который мы получим потом."

    zmc.language["cycle_title"] = "Цикл"
    zmc.language["cycle_tooltip"] = "Сколько взаимодействий необходимо для создания элемента ниже."

    zmc.language["speed_title"] = "Скорость"
    zmc.language["speed_tooltip"] = "Какая скорость смешивания необходима?"

    zmc.language["amount_title"] = "Сумма"
    zmc.language["amount_tooltip"] = "Сколько предметов мы получаем?"

    zmc.language["price_title"] = "Цена"
    zmc.language["price_tooltip"] = "Денежная стоимость этого предмета."

    zmc.language["items_generic_tooltip"] = "Какие предметы необходимы для изготовления этого предмета?"
    zmc.language["items_cut_tooltip"] = "Какие товары мы получаем?"

    zmc.language["health_title"] = "Здоровье"
    zmc.language["health_tooltip"] = "Сколько здоровья получает игрок после употребления этого предмета?"

    zmc.language["health_cap_title"] = "Колпачок для здоровья"
    zmc.language["health_cap_tooltip"] = "Какое максимальное количество здоровья игрок может получить от этого предмета?"

    zmc.language["range_title"] = "Диапазон"
    zmc.language["range_tooltip"] = "Размер цели мини-игры."

    zmc.language["Worktable"] = "Рабочий стол"
    zmc.language["Wok"] = zmc.language["comp_title_wok"]
    zmc.language["Grill"] = zmc.language["comp_title_grill"]
    zmc.language["Mixer"] = "Миксер"
    zmc.language["Oven"] = "Духовка"
    zmc.language["BoilPot"] = "Котелок"
    zmc.language["SoupPot"] = "Кастрюля"
    zmc.language["Customertable"] = "Таблица клиентов"

    // Update 1.0.1
    zmc.language["Throw"] = "Бросить"
    zmc.language["Throw_tooltip"] = "Быстро перенесите выбранный предмет в другой инвентарь."
    zmc.language["Spoiled"] = "[ИСПОРЧЕННЫЙ]"
    zmc.language["Spoiled_desc"] = "Он наполовину вернулся на мать-землю."

    // Update 1.0.3
    zmc.language["Cookbook"] = "Кулинарная книга"

    // Update 1.0.6
    zmc.language["YouDontOwnThis"] = "Тебе это не принадлежит!"
    zmc.language["NotEnoughMoney"] = "У тебя не хватает денег!"
    zmc.language["ItemLimit"] = "Вы достигли предела сущности для $ItemName!"
    zmc.language["Cancel"] = "Отменить"
    zmc.language["Deconstruct"] = "Разобрать"
    zmc.language["Construct"] = "Построить"
    zmc.language["Choosepostion"] = "Выберите новую позицию"
    zmc.language["ChooseEntity"] = "Выберите машину"
    zmc.language["Equipment_Build"] = "Построить"
    zmc.language["Equipment_Move"] = "Передвинуть"
    zmc.language["Equipment_Repair"] = "Починить"
    zmc.language["Equipment_Remove"] = "Удалить"

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
