--leak by matveicher
--vk group - https://vk.com/gmodffdev
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/V329W7Ce8g
--ds - matveicher#5801

zmc = zmc or {}
zmc.language = zmc.language or {}

if (zmc.config.SelectedLanguage == "ptbr") then

    zmc.language["Review_0_01"] = "Horriviel, minha $FoodName nem chegou."
    zmc.language["Review_0_02"] = "Péssimo!"
    zmc.language["Review_0_03"] = "Eu só queria uma coisa pra comer :("

    zmc.language["Review_1_01"] = "Eu esperei muito pelo(a) $FoodName!"
    zmc.language["Review_1_02"] = "Eu acho que tinha um cabelo na meu(inha) $FoodName!"
    zmc.language["Review_1_03"] = "Porque demorou tanto?"

    zmc.language["Review_2_01"] = "O(a) $FoodName tava até bom, mas a garçonete era bem melhor."
    zmc.language["Review_2_02"] = "Eu fui bem atendido, a comida era melhor que os pratos congelados do mercado."
    zmc.language["Review_2_03"] = "O(a) $FoodName tava muito bom."

    zmc.language["Review_3_01"] = "Deu pra sentir o amor no(a) minha $FoodName, eu com certeza voltarei! :)"
    zmc.language["Review_3_02"] = "Esse maluco sabe fazer um(a) $FoodName do(a) boa!"
    zmc.language["Review_3_03"] = "Foi maravilhoso!"

    zmc.language["Review_4_01"] = "O(a) $FoodName ficou pronto em instantes, maravilhoso!"
    zmc.language["Review_4_02"] = "O serviço daqui é maravilhoso!"
    zmc.language["Review_4_03"] = "Eu nunca comi um(a) $FoodName tão bom!"


    zmc.language["Edit Appearance"] = "Editar Aparência"
    zmc.language["Edit Whitelist"] = "Editar Whitelist"
    zmc.language["Possible Orders:"] = "Possíveis Ordens:"
    zmc.language["Appearance"] = "Aparência"
    zmc.language["Update"] = "Atualizar"
    zmc.language["NO SEAT"] = "Remover Cadeiras"

    zmc.language["Restrict_Orders"] = "Restringe quais pratos o cliente pode pedir."
    zmc.language["Whitelist_AddDish"] = "Adicionar prato a whitelist"

    zmc.language["Cook Menu"] = "Menu da Cozinha"
    zmc.language["Cancel"] = "Cancelar"
    zmc.language["Missing Ingredients:"] = "Ingredientes Faltando:"
    zmc.language["Dishtable"] = "Balcão"


    zmc.language["tooltip_clipboard"] = "Copiar o Código"

    zmc.language["Copy"] = "Copiar"

    zmc.language["Select Dish"] = "Selecionar PRato"

    zmc.language["Dishes"] = "Pratos"
    zmc.language["Ingredients"] = "Ingredientes"
    zmc.language["Dish Editor"] = "Editor de Pratos"
    zmc.language["Order Time"] = "Tempo do pedido"
    zmc.language["tooltip_OrderTime"] = "Quanto tempo o player tem para fazer o prato?"

    zmc.language["ingredient_count_warning"] = "Voce não pode trabalhar em mais de 10 pratos ao mesmo tempo!"
    zmc.language["Add Food"] = "Adicionar Comida"

    zmc.language["Pitch"] = "Pitch"
    zmc.language["Yaw"] = "Yaw"
    zmc.language["Roll"] = "Rotação"
    zmc.language["Height"] = "Altura"
    zmc.language["Scale"] = "Tamanho"

    zmc.language["Dish Name"] = "Nome do Prato"
    zmc.language["Delete this Dish?"] = "Deletar o Prato?"
    zmc.language["Config code copied to clipboard!"] = "Configuração copiada!"

    zmc.language["Ready"] = "Pronto"
    zmc.language["Need"] = "Precisa de $ItemName"


    zmc.language["Fridge"] = "Geladeira"
    zmc.language["Buy"] = "Comprar"
    zmc.language["All"] = "Tudo"
    zmc.language["Search"] = "Pesquisar"
    zmc.language["ItemName"] = "Nome do item"
    zmc.language["Restrict_Buy"] = "Restringe quais"
    zmc.language["Whitelist_AddItem"] = "Adicionar item na Whitelist"

    zmc.language["item_limit_reached"] = "Limite de items atingido!"
    zmc.language["ItemBoughtNotify"] = "Você comprou $ItemName por $CurrencyAmount!"

    zmc.language["Start"] = "Iniciar"
    zmc.language["Stop"] = "Parar"

    zmc.language["MissingIngredients"] = "Ingredientes Faltando!"
    zmc.language["Temperature"] = "Temperatura"

    zmc.language["Choose Recipe"] = "Escolher Receita"

    zmc.language["Missing Gastank"] = "Sem Gás!"

    // Refers to a warning on the grill for meat on the grill which will burn if the player doesent flip it
    zmc.language["FLIP!"] = "VIRE A COMIDA!"


    zmc.language["Inventory:"] = "inventário:"

    zmc.language["Drop"] = "Soltar"
    zmc.language["tooltip_drop"] = "Soltar o item selecionado."

    zmc.language["Items"] = "Itens"
    zmc.language["Item Editor"] = "Editor de Itens"
    zmc.language["Update Bodygroups"] = "Update Bodygroups"
    zmc.language["Name"] = "Nome"
    zmc.language["Skin"] = "Skin"
    zmc.language["Model"] = "Modelo"
    zmc.language["Material"] = "Textura"
    zmc.language["Components"] = "Componentes"
    zmc.language["tooltip_temperature"] = "Especifica a qual temperatura o prato começa a ser cozinhado."

    zmc.language["Result"] = "Resultado"
    zmc.language["Select Item"] = "Selecionar item"
    zmc.language["ingredient_count_warning_craft"] = "Você não pode ter mais de 4 ingredientes pra craftar!"
    zmc.language["ingredient_count_warning_generic"] = "Você bão pode ter mais de 12 Ingredientes!"
    zmc.language["Add Ingredient"] = "Adicionar Ingrediente"
    zmc.language["Appearance Editor"] = "Editor de Aparência"
    zmc.language["Add Component"] = "Adicionar Componente"
    zmc.language["Delete this Item?"] = "Deletar este item?"
    zmc.language["Duplicate this Item?"] = "Duplicar este item?"

    zmc.language["Position"] = "Posição"
    zmc.language["Bodygroup Editor"] = "Editor de Bodygroups"
    zmc.language["Bodygroups"] = "Bodygroups"

    zmc.language["Whitelist Editor"] = "Editor de Whitelist"
    zmc.language["Whitelist Empty"] = "Nenhum item na whitelisted!"

    zmc.language["Ordered Dishes:"] = "Pedidos:"
    zmc.language["Allow Custom Orders"] = "Permitir Pedidos"

    zmc.language["tooltip_CustomOrders"] = "Permite os clientes escolherem o prato que querem pedir / e julgam seu serviço.\nIsso pode aumentar / diminuir a felicidade dos clientes!\nDesabilitar essa opção transforma a mesa em um buffet."

    zmc.language["Orders:"] = "Pedidos:"
    zmc.language["Open for Business"] = "Aberto"
    zmc.language["Closed"] = "Fechado"
    zmc.language["ON"] = "Ligado"
    zmc.language["OFF"] = "Desligado"
    zmc.language["Customer Happiness:"] = "Felicidade dos Clientes:"
    zmc.language["Earnings:"] = "Ganhos:"
    zmc.language["Custom Orders:"] = "Pedidos:"


    zmc.language["Process"] = "Processar"
    zmc.language["Cut"] = "Cortar"
    zmc.language["Knead"] = "Amassar"
    zmc.language["Craft:"] = "Craft:"
    zmc.language["Select Recipe"] = "Selecionar Receita"



    zmc.language["comp_title_fridge"] = "Geladeira"
    zmc.language["comp_desc_fridge"] = "Pode ser comprado na geladeira."

    zmc.language["comp_title_cut"] = "Cortar"
    zmc.language["comp_desc_cut"] = "Pode ser cortado."

    zmc.language["comp_title_knead"] = "Amassar"
    zmc.language["comp_desc_knead"] = "Pode ser amassado."

    zmc.language["comp_title_bake"] = "Cozinhar"
    zmc.language["comp_desc_bake"] = "Pode ser cozinhado."

    zmc.language["comp_title_mix"] = "Misturar"
    zmc.language["comp_desc_mix"] = "é misturado com vários ingredientes."

    zmc.language["comp_title_sell"] = "Vender"
    zmc.language["comp_desc_sell"] = "Pode ser vendido."

    zmc.language["comp_title_edible"] = "Comestível"
    zmc.language["comp_desc_edible"] = "Pode ser ingerido."

    zmc.language["comp_title_grill"] = "Grill"
    zmc.language["comp_desc_grill"] = "Can be grilled."

    zmc.language["comp_title_wok"] = "Wok"
    zmc.language["comp_desc_wok"] = "Pode ser feito na Wok."

    zmc.language["comp_title_soup"] = "Sopa"
    zmc.language["comp_desc_soup"] = "Pode ser feito na panela."

    zmc.language["comp_title_boil"] = "Ferver"
    zmc.language["comp_desc_boil"] = "Pode ser fervido."

    zmc.language["comp_title_craft"] = "Craft"
    zmc.language["comp_desc_craft"] = "Pode ser craftado na mesa de trabalho."



    zmc.language["temp_req_title"] = "Temperatura"
    zmc.language["temp_req_tooltip"] = "Tempo que demora pro prato cozinhar."

    zmc.language["time_title"] = "Tempo"
    zmc.language["time_tooltip"] = "Tempo que demora pra processar o item."

    zmc.language["item_tooltip"] = "O item que é gerado depois."

    zmc.language["cycle_title"] = "Ciclos"
    zmc.language["cycle_tooltip"] = "Quantas interações são necessarias pra formar o item."

    zmc.language["speed_title"] = "Velocidade"
    zmc.language["speed_tooltip"] = "Qual a velocidade que o mixer tem que estar?"

    zmc.language["amount_title"] = "Quantidade"
    zmc.language["amount_tooltip"] = "Quantos items são gerados?"

    zmc.language["price_title"] = "Preço"
    zmc.language["price_tooltip"] = "O quanto este item vale."

    zmc.language["items_generic_tooltip"] = "Quais itens são necessarios pra fazer?"
    zmc.language["items_cut_tooltip"] = "Quais itens são gerados?"

    zmc.language["health_title"] = "Cura"
    zmc.language["health_tooltip"] = "O quanto o palyer é curado quando comer este item?"

    zmc.language["health_cap_title"] = "Limite da cura"
    zmc.language["health_cap_tooltip"] = "O maximo de cura que o player pode obter"

    zmc.language["range_title"] = "Campo"
    zmc.language["range_tooltip"] = "O tamanho do objetivo do minigame."


    zmc.language["Worktable"] = "Mesa de trabalho"
    zmc.language["Wok"] = zmc.language["comp_title_wok"]
    zmc.language["Grill"] = zmc.language["comp_title_grill"]
    zmc.language["Mixer"] = "Mixer"
    zmc.language["Oven"] = "Forno"
    zmc.language["BoilPot"] = "Pote pra ferver"
    zmc.language["SoupPot"] = "Pote de sopa"
    zmc.language["Customertable"] = "Mesa Do Cliente"

    // Update 1.0.1
    zmc.language["Throw"] = "Arremessar"
    zmc.language["Throw_tooltip"] = "Joga o item selecionado para outro inventário."
    zmc.language["Spoiled"] = "[Podre]"
    zmc.language["Spoiled_desc"] = "Tá fedendo."

    // Update 1.0.3
    zmc.language["Cookbook"] = "Livro de receitas"

    // Update 1.0.6
    zmc.language["YouDontOwnThis"] = "Você não é o dono desta entidade!"
    zmc.language["NotEnoughMoney"] = "Dinheiro insuficiente!"
    zmc.language["ItemLimit"] = "Você atingiu o limite de $ItemName!"
    zmc.language["Cancel"] = "Cancelar"
    zmc.language["Deconstruct"] = "Desconstruir"
    zmc.language["Construct"] = "Construir"
    zmc.language["Choosepostion"] = "Escolha uma nova posição"
    zmc.language["ChooseEntity"] = "Escolha uma maquina"
    zmc.language["Equipment_Build"] = "Construir"
    zmc.language["Equipment_Move"] = "Mover"
    zmc.language["Equipment_Repair"] = "Reparar"
    zmc.language["Equipment_Remove"] = "Remover"

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
