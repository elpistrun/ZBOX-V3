--leak by matveicher
--vk group - https://vk.com/gmodffdev
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/V329W7Ce8g
--ds - matveicher#5801

zmc = zmc or {}
zmc.language = zmc.language or {}
zmc = zmc or {}
zmc.language = zmc.language or {}

if (zmc.config.SelectedLanguage == "fr") then

    zmc.language["Review_0_01"] = "Service mauvais, mon plat $FoodName ne m'a jamais été remis."
    zmc.language["Review_0_02"] = "Même mon chien ne mangerait pas ici !"
    zmc.language["Review_0_03"] = "Je vais partir sans payer.."

    zmc.language["Review_1_01"] = "J'ai attendu longtemps pour avoir mon plat $FoodName !"
    zmc.language["Review_1_02"] = "Je pense qu'il y a un cheveu dans $FoodName !"
    zmc.language["Review_1_03"] = "Pourquoi ça a pris autant de temps ?"

    zmc.language["Review_2_01"] = "Le plat $FoodName était bon, et la serveuse très chaude."
    zmc.language["Review_2_02"] = "Le service était correct, la nourriture est meilleure qu'aux micro-ondes."
    zmc.language["Review_2_03"] = "Le $FoodName était plutôt bon."

    zmc.language["Review_3_01"] = "Le $FoodName a été fait avec amour, je reviens bientôt :)"
    zmc.language["Review_3_02"] = "Le plat était tellement bon, le cuisinier maitrise parfaitement le $FoodName !"
    zmc.language["Review_3_03"] = "Le cuisinier maîtrise son travail parfaitement."

    zmc.language["Review_4_01"] = "Mon $FoodName a été servi rapidement et est divin !"
    zmc.language["Review_4_02"] = "Respectueux et délicieux, je recommande !"
    zmc.language["Review_4_03"] = "J'ai commandé un $FoodName et c'était le meilleur que j'ai mangé !"


    zmc.language["Edit Appearance"] = "Éditer l'apparence"
    zmc.language["Edit Whitelist"] = "Éditer la whitelist"
    zmc.language["Possible Orders:"] = "Commandes possibles :"
    zmc.language["Appearance"] = "Apparence"
    zmc.language["Update"] = "Actualiser"
    zmc.language["NO SEAT"] = "SANS CHAISE"

    zmc.language["Restrict_Orders"] = "Restreint les plats commandés par les clients."
    zmc.language["Whitelist_AddDish"] = "Ajouter un plat à la whitelist"

    zmc.language["Cook Menu"] = "Menu de la cuisine"
    zmc.language["Cancel"] = "Annuler"
    zmc.language["Missing Ingredients:"] = "Ingrédients manquants :"
    zmc.language["Dishtable"] = "Table de recettes"


    zmc.language["tooltip_clipboard"] = "Copier la configuration dans son presse-papier."

    zmc.language["Copy"] = "Copier"

    zmc.language["Select Dish"] = "Sélectionner le plat"

    zmc.language["Dishes"] = "Plats"
    zmc.language["Ingredients"] = "Ingrédients"
    zmc.language["Dish Editor"] = "Éditeur de plats"
    zmc.language["Order Time"] = "Préparation"
    zmc.language["tooltip_OrderTime"] = "Combien de temps le joueur a pour préparer ce plat ?"

    zmc.language["ingredient_count_warning"] = "Vous ne pouvez pas avoir plus de 10 aliments dans l'assiette !"
    zmc.language["Add Food"] = "Ajouter nourriture"

    zmc.language["Pitch"] = "Pitch"
    zmc.language["Yaw"] = "Yaw"
    zmc.language["Roll"] = "Rotation"
    zmc.language["Height"] = "Hauteur"
    zmc.language["Scale"] = "Scale"

    zmc.language["Dish Name"] = "Nom du plat"
    zmc.language["Delete this Dish?"] = "Supprimer le plat ?"
    zmc.language["Config code copied to clipboard!"] = "Configuration copiée dans le presse-papier."

    zmc.language["Ready"] = "Prêt"
    zmc.language["Need"] = "Besoin de $ItemName"

    zmc.language["Fridge"] = "Réfrigérateur"
    zmc.language["Buy"] = "Acheter"
    zmc.language["All"] = "Tout"
    zmc.language["Search"] = "Chercher"
    zmc.language["ItemName"] = "Nom de l'objet"
    zmc.language["Restrict_Buy"] = "Restreint les objets que le joueur peut acheter"
    zmc.language["Whitelist_AddItem"] = "Ajouter l'objet dans la whitelist"

    zmc.language["item_limit_reached"] = "Limite d'objets atteinte !"
    zmc.language["ItemBoughtNotify"] = "Vous avez acheter $ItemName pour $CurrencyAmount !"

    zmc.language["Start"] = "Commencer"
    zmc.language["Stop"] = "Arrêter"

    zmc.language["MissingIngredients"] = "Vous avez oublié des ingrédients !"
    zmc.language["Temperature"] = "Température"

    zmc.language["Choose Recipe"] = "Sélectionner la recette"

    zmc.language["Missing Gastank"] = "Bidon de gaz manquant !"

    // C'est un avertissement sur le gril pour la viande, qui brûlera si le joueur ne la retourne pas.
    zmc.language["FLIP!"] = "RETOURNER !"


    zmc.language["Inventory:"] = "Inventaire :"

    zmc.language["Drop"] = "Jeter"
    zmc.language["tooltip_drop"] = "Jeter l'objet sélectionné."

    zmc.language["Items"] = "Objets"
    zmc.language["Item Editor"] = "Éditeur d'objets"
    zmc.language["Update Bodygroups"] = "Update Bodygroups"
    zmc.language["Name"] = "Nom"
    zmc.language["Skin"] = "Skin"
    zmc.language["Model"] = "Modèle"
    zmc.language["Material"] = "Material"
    zmc.language["Components"] = "Composants"
    zmc.language["tooltip_temperature"] = "Spécifie à quelle température l'objet commence à cuire."

    zmc.language["Result"] = "Résultat"
    zmc.language["Select Item"] = "Sélectionner l'objet"
    zmc.language["ingredient_count_warning_craft"] = "You cant have more then 4 Ingredients for crafting!"
    zmc.language["ingredient_count_warning_generic"] = "You cant have more then 12 Ingredients!"
    zmc.language["Add Ingredient"] = "Ajouter un ingrédient"
    zmc.language["Appearance Editor"] = "Éditeur d'apparence"
    zmc.language["Add Component"] = "Ajouter un composant"
    zmc.language["Delete this Item?"] = "Supprimer cet objet ?"
    zmc.language["Duplicate this Item?"] = "Dupliquer cet objet ?"

    zmc.language["Position"] = "Position"
    zmc.language["Bodygroup Editor"] = "Éditeur Bodygroup"
    zmc.language["Bodygroups"] = "Bodygroups"

    zmc.language["Whitelist Editor"] = "Éditeur de whitelist"
    zmc.language["Whitelist Empty"] = "Aucun objet dans la whitelist !"

    zmc.language["Ordered Dishes:"] = "Plats commandés:"
    zmc.language["Allow Custom Orders"] = "Commandes personnalisées"

    zmc.language["tooltip_CustomOrders"] = "Autorise aux clients de commander des plats au hasard, à partir desquels ils jugeront / évalueront votre service.\nCe qui peut augmenter / diminuer la satisfaction des clients !\nLa désactivation des commandes personnalisées fera que la table de commande se comportera davantage comme une table de buffet."

    zmc.language["Orders:"] = "Commandes :"
    zmc.language["Open for Business"] = "Ouvert pour commander"
    zmc.language["Closed"] = "Fermé"
    zmc.language["ON"] = "ALLUMÉ"
    zmc.language["OFF"] = "ÉTEINT"
    zmc.language["Customer Happiness:"] = "Clients satisfaits :"
    zmc.language["Earnings:"] = "Gains :"
    zmc.language["Custom Orders:"] = "Commandes personnalisées :"


    zmc.language["Process"] = "Traiter"
    zmc.language["Cut"] = "Couper"
    zmc.language["Knead"] = "Pétrir"
    zmc.language["Craft:"] = "Fabriquer :"
    zmc.language["Select Recipe"] = "Sélectionner la recette"

    zmc.language["comp_title_fridge"] = "Réfrigérateur"
    zmc.language["comp_desc_fridge"] = "Peut-être acheté depuis le réfrigérateur."

    zmc.language["comp_title_cut"] = "Couper"
    zmc.language["comp_desc_cut"] = "Peut-être coupé en pièces."

    zmc.language["comp_title_knead"] = "Pétrir"
    zmc.language["comp_desc_knead"] = "Peut-être pétri en quelque chose."

    zmc.language["comp_title_bake"] = "Cuire"
    zmc.language["comp_desc_bake"] = "Peut-être cuit."

    zmc.language["comp_title_mix"] = "Mélanger"
    zmc.language["comp_desc_mix"] = "Est mélangé à partir de plusieurs ingrédients."

    zmc.language["comp_title_sell"] = "Vendre"
    zmc.language["comp_desc_sell"] = "Peut-être vendu."

    zmc.language["comp_title_edible"] = "Comestible"
    zmc.language["comp_desc_edible"] = "Peut-être mangé."

    zmc.language["comp_title_grill"] = "Gril"
    zmc.language["comp_desc_grill"] = "Peut-être grillé."

    zmc.language["comp_title_wok"] = "Wok"
    zmc.language["comp_desc_wok"] = "Peut-être utilisé dans le Wok."

    zmc.language["comp_title_soup"] = "Soupe"
    zmc.language["comp_desc_soup"] = "Peut-être utilisé dans le pot à soupe."

    zmc.language["comp_title_boil"] = "Bouillir"
    zmc.language["comp_desc_boil"] = "Vous pouvez le faire bouillir."

    zmc.language["comp_title_craft"] = "Fabriquer"
    zmc.language["comp_desc_craft"] = "Peut-être fabriqué depuis le plan de travail."



    zmc.language["temp_req_title"] = "Chaleur"
    zmc.language["temp_req_tooltip"] = "La chaleur à laquelle l'objet commence à cuire."

    zmc.language["time_title"] = "Temps"
    zmc.language["time_tooltip"] = "Le temps que cela prend à traiter l'objet."

    zmc.language["item_tooltip"] = "L'objet que nous obtenons."

    zmc.language["cycle_title"] = "Cycle"
    zmc.language["cycle_tooltip"] = "Combien d'interactions sont nécessaires pour fabriquer l'objet."

    zmc.language["speed_title"] = "Vitesse"
    zmc.language["speed_tooltip"] = "Quelle vitesse de mélange est nécessaire ?"

    zmc.language["amount_title"] = "Montant"
    zmc.language["amount_tooltip"] = "Combien d'objets obtient-on ?"

    zmc.language["price_title"] = "Prix"
    zmc.language["price_tooltip"] = "Le montant de l'objet."

    zmc.language["items_generic_tooltip"] = "Quel objet est requis pour faire cet objet ?"
    zmc.language["items_cut_tooltip"] = "Quel objet obtient-on ?"

    zmc.language["health_title"] = "Santé"
    zmc.language["health_tooltip"] = "Combien de santé reçois le joueur après avoir mangé cet objet ?"

    zmc.language["health_cap_title"] = "Santé max"
    zmc.language["health_cap_tooltip"] = "Quelle est la santé maximum que le joueur peut obtenir après avoir mangée cet objet ?"

    zmc.language["range_title"] = "Taille"
    zmc.language["range_tooltip"] = "La taille de l'objectif du mini-jeu sur le wok."

    zmc.language["Worktable"] = "Plan de travail"
    zmc.language["Wok"] = zmc.language["comp_title_wok"]
    zmc.language["Grill"] = zmc.language["comp_title_grill"]
    zmc.language["Mixer"] = "Mixeur"
    zmc.language["Oven"] = "Four"
    zmc.language["BoilPot"] = "Marmite"
    zmc.language["SoupPot"] = "Pot à soupe"
    zmc.language["Customertable"] = "Table des clients"


    // Update 1.0.1
    zmc.language["Throw"] = "Déplacer"
    zmc.language["Throw_tooltip"] = "Déplacer rapidement l'objet sur un autre inventaire."
    zmc.language["Spoiled"] = "[MOISI]"
    zmc.language["Spoiled_desc"] = "Ce plat est moisi."

    // Update 1.0.3
    zmc.language["Cookbook"] = "Livre de recettes"

    // Update 1.0.6
    zmc.language["YouDontOwnThis"] = "Vous ne possédez pas ceci !"
    zmc.language["NotEnoughMoney"] = "Vous n'avez pas assez d'argent!"
    zmc.language["ItemLimit"] = "Vous avez atteint la limite d'entité pour $ItemName!"
    zmc.language["Cancel"] = "Annuler"
    zmc.language["Deconstruct"] = "Déconstruire"
    zmc.language["Construct"] = "Construire"
    zmc.language["Choosepostion"] = "Choisissez une nouvelle position"
    zmc.language["ChooseEntity"] = "Choisissez une nouvelle machine"
    zmc.language["Equipment_Build"] = "Construire"
    zmc.language["Equipment_Move"] = "Bouger"
    zmc.language["Equipment_Repair"] = "Réparer"
    zmc.language["Equipment_Remove"] = "Retirer"

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
