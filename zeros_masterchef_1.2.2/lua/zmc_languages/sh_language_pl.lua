--leak by matveicher
--vk group - https://vk.com/gmodffdev
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/V329W7Ce8g
--ds - matveicher#5801

zmc = zmc or {}
zmc.language = zmc.language or {}

if (zmc.config.SelectedLanguage == "pl") then

    zmc.language["Review_0_01"] = "Kaszana, moje $FoodName nawet nie przyszło."
    zmc.language["Review_0_02"] = "Po prostu obleśne!"
    zmc.language["Review_0_03"] = "Ja tu płaczę :("

    zmc.language["Review_1_01"] = "Tak długo czekałem na $FoodName!"
    zmc.language["Review_1_02"] = "Tu był włos w moim $FoodName!"
    zmc.language["Review_1_03"] = "Czemu tak długo się zeszło?"

    zmc.language["Review_2_01"] = "$FoodName było w porządku i kelner był nawet przystojny."
    zmc.language["Review_2_02"] = "Obsługa była niezła, jedzenie było lepsze niż z mikrofali."
    zmc.language["Review_2_03"] = "$FoodName było całkiem niezłe."

    zmc.language["Review_3_01"] = "Czuć że $FoodName było zrobione z miłością, napewno wrócę :)"
    zmc.language["Review_3_02"] = "Ten kucharz wie jak przygotować najlepsze $FoodName!"
    zmc.language["Review_3_03"] = "To było przepyszne!"

    zmc.language["Review_4_01"] = "$FoodName przyszło szybko i było przepyszne!"
    zmc.language["Review_4_02"] = "Obsługa była cudowna!"
    zmc.language["Review_4_03"] = "$FoodName to dzieło sztuki!"


    zmc.language["Edit Appearance"] = "Edytuj przedstawienie"
    zmc.language["Edit Whitelist"] = "Edytuj whiteliste"
    zmc.language["Possible Orders:"] = "Możliwe zamówienia:"
    zmc.language["Appearance"] = "Przedstawienie"
    zmc.language["Update"] = "Aktualizuj"
    zmc.language["NO SEAT"] = "BRAK MIEJSCA"

    zmc.language["Restrict_Orders"] = "Ogranicz które dania może zamówić klient."
    zmc.language["Whitelist_AddDish"] = "Dodaj danie do whitelisty"

    zmc.language["Cook Menu"] = "Menu gotowania"
    zmc.language["Cancel"] = "Anuluj"
    zmc.language["Missing Ingredients:"] = "Brakujące składniki:"
    zmc.language["Dishtable"] = "Stół na dania"


    zmc.language["tooltip_clipboard"] = "Skopiuj kod konfiguracji do schowka"

    zmc.language["Copy"] = "Kopiuj"

    zmc.language["Select Dish"] = "Wybierz danie"

    zmc.language["Dishes"] = "Dania"
    zmc.language["Ingredients"] = "Składniki"
    zmc.language["Dish Editor"] = "Edytor dań"
    zmc.language["Order Time"] = "Czas zamówienia"
    zmc.language["tooltip_OrderTime"] = "How much time does the player have to make this Dish?"

    zmc.language["ingredient_count_warning"] = "Nie możesz posiadać więcej jedzenia na talerzu!"
    zmc.language["Add Food"] = "Dodaj jedzenie"

    zmc.language["Pitch"] = "Poziom"
    zmc.language["Yaw"] = "Odchylenie"
    zmc.language["Roll"] = "Obrót"
    zmc.language["Height"] = "Wysokość"
    zmc.language["Scale"] = "Skala"

    zmc.language["Dish Name"] = "Nazwa dania"
    zmc.language["Delete this Dish?"] = "Czy chcesz usunąć to danie?"
    zmc.language["Config code copied to clipboard!"] = "Plik konfiguracji skopiowany do schowka!"

    zmc.language["Ready"] = "Gotowe"
    zmc.language["Need"] = "Potrzeba $ItemName"

    zmc.language["Fridge"] = "Lodówka"
    zmc.language["Buy"] = "Kup"
    zmc.language["All"] = "Wszystko"
    zmc.language["Search"] = "Szukaj"
    zmc.language["ItemName"] = "Nazwa przedmiotu"
    zmc.language["Restrict_Buy"] = "Ogranicz, które przedmioty może zakupić gracz"
    zmc.language["Whitelist_AddItem"] = "Dodaj przedmiot do whitelisty"

    zmc.language["item_limit_reached"] = "Osiągnąłeś limit przedmiotu!"
    zmc.language["ItemBoughtNotify"] = "Zakupiłeś $ItemName za $CurrencyAmount!"

    zmc.language["Start"] = "Start"
    zmc.language["Stop"] = "Stop"

    zmc.language["MissingIngredients"] = "Brakuje Ci składników!"
    zmc.language["Temperature"] = "Temperatura"

    zmc.language["Choose Recipe"] = "Wybierz przepis"

    zmc.language["Missing Gastank"] = "Brakuje butli z gazem!"

    // Refers to a warning on the grill for meat on the grill which will burn if the player doesent flip it
    zmc.language["FLIP!"] = "OBRÓĆ!"


    zmc.language["Inventory:"] = "Ekwipunek:"

    zmc.language["Drop"] = "Upuść"
    zmc.language["tooltip_drop"] = "Upuść wybrany przedmiot."

    zmc.language["Items"] = "Itemy"
    zmc.language["Item Editor"] = "Edytor przedmiotu"
    zmc.language["Update Bodygroups"] = "Aktualizuj wyglądy"
    zmc.language["Name"] = "Nazwa"
    zmc.language["Skin"] = "Skórka"
    zmc.language["Model"] = "Model"
    zmc.language["Material"] = "Tekstura"
    zmc.language["Components"] = "Czynności"

    zmc.language["tooltip_temperature"] = "Specifies at which Temperatur the item starts baking / cooking."

    zmc.language["Result"] = "Wynik"
    zmc.language["Select Item"] = "Wybierz przedmiot"
    zmc.language["ingredient_count_warning_craft"] = "Nie możesz posiadać więcej niż 4 przedmioty do wytwarzania!"
    zmc.language["ingredient_count_warning_generic"] = "Nie możesz posiadać więcej niż 12 składników!"
    zmc.language["Add Ingredient"] = "Dodaj składnik"
    zmc.language["Appearance Editor"] = "Edytor przedstawienia"
    zmc.language["Add Component"] = "Dodaj czynność"
    zmc.language["Delete this Item?"] = "Czy chcesz usunąć ten przedmiot?"
    zmc.language["Duplicate this Item?"] = "Czy chcesz zduplikować ten przedmiot?"

    zmc.language["Position"] = "Pozycja"
    zmc.language["Bodygroup Editor"] = "Edytor wyglądu"
    zmc.language["Bodygroups"] = "Rodzaje wyglądu:"

    zmc.language["Whitelist Editor"] = "Edytor whitelisty"
    zmc.language["Whitelist Empty"] = "Brak przedmiotów!"

    zmc.language["Ordered Dishes:"] = "Zamówione dania:"
    zmc.language["Allow Custom Orders"] = "Zezwól na inne zamówienia"

    zmc.language["tooltip_CustomOrders"] = "Pozwól klientom zamawiać losowe potrawy z których będą oceniać / recenzować twoją obsługę.\nKtóre może zwiększyć / zmniejszyć zadowolenie klienta!\nWyłączenie niestandardowych zamówień robi ze stołu z zamówieniami bufet."

    zmc.language["Orders:"] = "Zamówienia:"
    zmc.language["Open for Business"] = "Otwarte na biznes"
    zmc.language["Closed"] = "Zamknięte"
    zmc.language["ON"] = "WŁĄCZONE"
    zmc.language["OFF"] = "WYŁĄCZONE"
    zmc.language["Customer Happiness:"] = "Zadowolenie klienta:"
    zmc.language["Earnings:"] = "Zarobki:"
    zmc.language["Custom Orders:"] = "Niestandardowe zamówienia:"


    zmc.language["Process"] = "Proces"
    zmc.language["Cut"] = "Cięcie"
    zmc.language["Knead"] = "Ugniatanie"
    zmc.language["Craft:"] = "Wytwarzanie:"
    zmc.language["Select Recipe"] = "Wybierz przepis"



    zmc.language["comp_title_fridge"] = "Lodówka"
    zmc.language["comp_desc_fridge"] = "Może zostać zakupione z lodówki."

    zmc.language["comp_title_cut"] = "Cięcie"
    zmc.language["comp_desc_cut"] = "Może zostać pocięte na kawałki."

    zmc.language["comp_title_knead"] = "Ugniatanie"
    zmc.language["comp_desc_knead"] = "Może zostać ugniecone w coś."

    zmc.language["comp_title_bake"] = "Pieczenie"
    zmc.language["comp_desc_bake"] = "Może zostać upieczone."

    zmc.language["comp_title_mix"] = "Miksowanie"
    zmc.language["comp_desc_mix"] = "Jest miksowane z wielu składników."

    zmc.language["comp_title_sell"] = "Sprzedaż"
    zmc.language["comp_desc_sell"] = "Może zostać sprzedane."

    zmc.language["comp_title_edible"] = "Jadalne"
    zmc.language["comp_desc_edible"] = "Może zostać zjedzone."

    zmc.language["comp_title_grill"] = "Grill"
    zmc.language["comp_desc_grill"] = "Może zostać ugrilowane."

    zmc.language["comp_title_wok"] = "Wok"
    zmc.language["comp_desc_wok"] = "Może zostać przygotowane w woku."

    zmc.language["comp_title_soup"] = "Zupa"
    zmc.language["comp_desc_soup"] = "Może zostać przygotowane w garnku na zupę."

    zmc.language["comp_title_boil"] = "Gotowanie"
    zmc.language["comp_desc_boil"] = "Może zostać ugotowane."

    zmc.language["comp_title_craft"] = "Wytwarzanie"
    zmc.language["comp_desc_craft"] = "Może być wytworzone na stole roboczym."



    zmc.language["temp_req_title"] = "Ciepło"
    zmc.language["temp_req_tooltip"] = "Czas po jakim przedmiot zaczyna się piec."

    zmc.language["time_title"] = "Czas"
    zmc.language["time_tooltip"] = "Potrzebny czas do przerobienia przedmiotu."

    zmc.language["item_tooltip"] = "Przedmiot, który później otrzymujemy."

    zmc.language["cycle_title"] = "Ilość interakcji"
    zmc.language["cycle_tooltip"] = "Ile potrzeba interakcji, aby wykonać przedmiot poniżej?"

    zmc.language["speed_title"] = "Prędkość"
    zmc.language["speed_tooltip"] = "Jaka prędkość miksowania jest wymagana?"

    zmc.language["amount_title"] = "Ilość"
    zmc.language["amount_tooltip"] = "Ile przedmiotów otrzymujemy?"

    zmc.language["price_title"] = "Cena"
    zmc.language["price_tooltip"] = "Wartość tego przedmiotu."

    zmc.language["items_generic_tooltip"] = "Jakie przedmioty są potrzebne do zrobienia tego?"
    zmc.language["items_cut_tooltip"] = "Jakie przedmioty otrzymujemy?"

    zmc.language["health_title"] = "Życie"
    zmc.language["health_tooltip"] = "Ile punktów życia otrzyma gracz po zjedzeniu tego?"

    zmc.language["health_cap_title"] = "Pojemność życia"
    zmc.language["health_cap_tooltip"] = "Jaki jest maksymalny poziom życia, jaki gracz może otrzymać przez ten przedmiot?"

    zmc.language["range_title"] = "Wielkość"
    zmc.language["range_tooltip"] = "Docelowa wielkość minigry."


    zmc.language["Worktable"] = "Stół roboczy"
    zmc.language["Wok"] = zmc.language["comp_title_wok"]
    zmc.language["Grill"] = zmc.language["comp_title_grill"]
    zmc.language["Mixer"] = "Mikser"
    zmc.language["Oven"] = "Piec"
    zmc.language["BoilPot"] = "Garnek do gotowania"
    zmc.language["SoupPot"] = "Garnek na zupę"
    zmc.language["Customertable"] = "Stolik dla gości"


    // Update 1.0.1
    zmc.language["Throw"] = "Przerzuć"
    zmc.language["Throw_tooltip"] = "Przerzuć wybrane przedmioty szybko do innego ekwipunku."
    zmc.language["Spoiled"] = "[ZEPSUTE]"
    zmc.language["Spoiled_desc"] = "To zaczęło się rozkładać."

    // Update 1.0.3
    zmc.language["Cookbook"] = "Książka z przepisami"


    // Update 1.0.6
    zmc.language["YouDontOwnThis"] = "Nie posiadasz tego!"
    zmc.language["NotEnoughMoney"] = "Nie masz wystarczająco pieniędzy!"
    zmc.language["ItemLimit"] = "Osiągnąłeś limit przedmiotów dla $ItemName!"
    zmc.language["Cancel"] = "Anuluj"
    zmc.language["Deconstruct"] = "Zniszcz"
    zmc.language["Construct"] = "Skonstruuj"
    zmc.language["Choosepostion"] = "Wybierz nową pozycję"
    zmc.language["ChooseEntity"] = "Wybierz obiekt "
    zmc.language["Equipment_Build"] = "Zbuduj"
    zmc.language["Equipment_Move"] = "Przenieś"
    zmc.language["Equipment_Repair"] = "Napraw"
    zmc.language["Equipment_Remove"] = "Usuń"

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
