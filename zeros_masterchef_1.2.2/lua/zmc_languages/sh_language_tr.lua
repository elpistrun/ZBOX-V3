--leak by matveicher
--vk group - https://vk.com/gmodffdev
--steam - https://steamcommunity.com/profiles/76561198968457747/
--ds server - https://discord.gg/V329W7Ce8g
--ds - matveicher#5801

zmc = zmc or {}
zmc.language = zmc.language or {}

if (zmc.config.SelectedLanguage == "tr") then

    zmc.language["Review_0_01"] = "Rezaletti, $FoodName sipariş ettim ve neredeyse gelmedi bile."
    zmc.language["Review_0_02"] = "Berbat, tek kelimeyle berbat!"
    zmc.language["Review_0_03"] = "Verdiğim paraya ağlıyorum :("

    zmc.language["Review_1_01"] = "Bir porsiyon $FoodName için çok bekledim!"
    zmc.language["Review_1_02"] = "Sanırım $FoodNamein içinde saç vardı!"
    zmc.language["Review_1_03"] = "Şef oyun mu oynuyor? Neden bu kadar uzun sürdü?"

    zmc.language["Review_2_01"] = "$FoodName ateşti ancak garson daha da ateşliydi:)."
    zmc.language["Review_2_02"] = "Servis hoştu, yemek ise özensiz olsa bile güzeldi."
    zmc.language["Review_2_03"] = "$FoodName gayet güzeldi."

    zmc.language["Review_3_01"] = "Şef yemeğine aşk katmıştı. Yediğim en iyi $FoodName falandı. Yeniden geleceğim :)"
    zmc.language["Review_3_02"] = "Burası gerçekten $FoodNameyı nasıl yapacağını biliyor!"
    zmc.language["Review_3_03"] = "Bu gayet sıkıydı beğendim!"

    zmc.language["Review_4_01"] = "$FoodName söyledim ve direk geldi. Tek kelimeyle mu-az-zam!"
    zmc.language["Review_4_02"] = "Hızlı ve güzel servis. Teşekkürler!"
    zmc.language["Review_4_03"] = "Tattığım en iyi $FoodName böyle bir tat yok!"


    zmc.language["Edit Appearance"] = "Görünümü Değiştir"
    zmc.language["Edit Whitelist"] = "Beyaz Listeyi Değiştir"
    zmc.language["Possible Orders:"] = "Olası Siparişler:"
    zmc.language["Appearance"] = "Görünüm"
    zmc.language["Update"] = "Güncele"
    zmc.language["NO SEAT"] = "KOLTUK YOK"

    zmc.language["Restrict_Orders"] = "Müşterilerin söyleyebilecekleri yemekleri kısıtlar."
    zmc.language["Whitelist_AddDish"] = "Listeye yemek ekle"

    zmc.language["Cook Menu"] = "Pişirme Menüsü"
    zmc.language["Cancel"] = "İptal"
    zmc.language["Missing Ingredients:"] = "Eksik Malzemeler:"
    zmc.language["Dishtable"] = "Bulaşık Masası"


    zmc.language["tooltip_clipboard"] = "Config kodu panoya kopyala"

    zmc.language["Copy"] = "Kopyala"

    zmc.language["Select Dish"] = "Yemeği Seç"

    zmc.language["Dishes"] = "Yemekler"
    zmc.language["Ingredients"] = "Malzemeler"
    zmc.language["Dish Editor"] = "Yemek Düzenleyicisi"
    zmc.language["Order Time"] = "Sipariş Süresi"
    zmc.language["tooltip_OrderTime"] = "Oyuncu ne kadar sürede yemeği yapsın?"

    zmc.language["ingredient_count_warning"] = "Tabağında 10dan fazla yemek eşyası bulunduramazsın!"
    zmc.language["Add Food"] = "Yemek Ekle"

    zmc.language["Pitch"] = "Pitch"
    zmc.language["Yaw"] = "Yaw"
    zmc.language["Roll"] = "Roll"
    zmc.language["Height"] = "Uzunluk"
    zmc.language["Scale"] = "Boyut"

    zmc.language["Dish Name"] = "Yemek İsmi"
    zmc.language["Delete this Dish?"] = "Yemeği Sil??"
    zmc.language["Config code copied to clipboard!"] = "Config kodu panoya kopyalandı!"

    zmc.language["Ready"] = "Hazır"
    zmc.language["Need"] = "$ItemName lazım"

    zmc.language["Fridge"] = "Buz Dolabı"
    zmc.language["Buy"] = "Satın Al"
    zmc.language["All"] = "Hepsi"
    zmc.language["Search"] = "Ara"
    zmc.language["ItemName"] = "Eşya Adı"
    zmc.language["Restrict_Buy"] = "Oyuncunun alacağı eşyaları kısıtlar"
    zmc.language["Whitelist_AddItem"] = "Beyaz listeye eşya ekle"

    zmc.language["item_limit_reached"] = "Eşya limitine ulaşıldı!"
    zmc.language["ItemBoughtNotify"] = "$CurrencyAmount karşılığında $ItemName aldın!"

    zmc.language["Start"] = "Başlat"
    zmc.language["Stop"] = "Durdur"

    zmc.language["MissingIngredients"] = "Malzemelerde eksiğin var!"
    zmc.language["Temperature"] = "Derece"

    zmc.language["Choose Recipe"] = "Tarif Seç"

    zmc.language["Missing Gastank"] = "Gaz tüpü eksiğin var!"

    // Refers to a warning on the grill for meat on the grill which will burn if the player doesent flip it
    zmc.language["FLIP!"] = "DÖNDÜR!"


    zmc.language["Inventory:"] = "Envanter:"

    zmc.language["Drop"] = "Bırak"
    zmc.language["tooltip_drop"] = "Seçili eşyayı bırak."

    zmc.language["Items"] = "Eşyalar"
    zmc.language["Item Editor"] = "Eşya Düzenleyicisi"
    zmc.language["Update Bodygroups"] = "Bodygroupları Güncelle"
    zmc.language["Name"] = "İsim"
    zmc.language["Skin"] = "Cilt"
    zmc.language["Model"] = "Model"
    zmc.language["Material"] = "Materyal"
    zmc.language["Components"] = "Bileşenler"

    zmc.language["tooltip_temperature"] = "Yemeğin kaç derecede pişeceğini ayarlar."

    zmc.language["Result"] = "Sonuç"
    zmc.language["Select Item"] = "Eşya Seç"
    zmc.language["ingredient_count_warning_craft"] = "Üretim için 4ten fazla malzeme seçemezsin!"
    zmc.language["ingredient_count_warning_generic"] = "12den fazla malzeme içeremez!"
    zmc.language["Add Ingredient"] = "Malzeme Ekle"
    zmc.language["Appearance Editor"] = "Görünüş Editör"
    zmc.language["Add Component"] = "Bileşen Ekle"
    zmc.language["Delete this Item?"] = "Eşyayı sil?"
    zmc.language["Duplicate this Item?"] = "Eşyayı kopyala?"

    zmc.language["Position"] = "Pozisyon"
    zmc.language["Bodygroup Editor"] = "Bodygroup Düzenleyicisi"
    zmc.language["Bodygroups"] = "Bodygrouplar"

    zmc.language["Whitelist Editor"] = "Beyaz liste editörü"
    zmc.language["Whitelist Empty"] = "Hiçbir eşya beyaz listede değil!"

    zmc.language["Ordered Dishes:"] = "Sipariş Edilen Yemekler:"
    zmc.language["Allow Custom Orders"] = "Özel Siparişlere Onay Ver"

    zmc.language["tooltip_CustomOrders"] = "Müşterilerin rastgele yemekler söyleyip değerlendirmesine izin ver.\nMüşterinin mutluluğunu azaltıp / arttırabilir!\nBunu devre dışı yapmak siapriş tablosunu daha çok büfe açık büfe gibi yapar."

    zmc.language["Orders:"] = "Siparişler:"
    zmc.language["Open for Business"] = "Açık"
    zmc.language["Closed"] = "Kapalı"
    zmc.language["ON"] = "AÇ"
    zmc.language["OFF"] = "KAPA"
    zmc.language["Customer Happiness:"] = "Müşteri Memnuniyeti:"
    zmc.language["Earnings:"] = "Kazanç:"
    zmc.language["Custom Orders:"] = "Özel Siparişler:"


    zmc.language["Process"] = "İşle"
    zmc.language["Cut"] = "Kes"
    zmc.language["Knead"] = "Yoğur"
    zmc.language["Craft:"] = "Üret:"
    zmc.language["Select Recipe"] = "Tarif Seç"



    zmc.language["comp_title_fridge"] = "Buz Dolabı"
    zmc.language["comp_desc_fridge"] = "Buz dolabından satın alınabilir."

    zmc.language["comp_title_cut"] = "Kes"
    zmc.language["comp_desc_cut"] = "Kesilebilir."

    zmc.language["comp_title_knead"] = "Yoğur"
    zmc.language["comp_desc_knead"] = "Yoğurulabilir."

    zmc.language["comp_title_bake"] = "Pişir"
    zmc.language["comp_desc_bake"] = "Pişirilebilir."

    zmc.language["comp_title_mix"] = "Karıştır"
    zmc.language["comp_desc_mix"] = "Bir çok malzemeyle karıştırılabilir."

    zmc.language["comp_title_sell"] = "Sat"
    zmc.language["comp_desc_sell"] = "Satılabilir."

    zmc.language["comp_title_edible"] = "Tüketilebilir"
    zmc.language["comp_desc_edible"] = "Tüketilebilir."

    zmc.language["comp_title_grill"] = "Izgara"
    zmc.language["comp_desc_grill"] = "Izgara  yapılabilir."

    zmc.language["comp_title_wok"] = "Wok"
    zmc.language["comp_desc_wok"] = "Çin tavasında yapılabilir."

    zmc.language["comp_title_soup"] = "Çorba"
    zmc.language["comp_desc_soup"] = "Çorba kasesinde yapılabilir."

    zmc.language["comp_title_boil"] = "Haşla"
    zmc.language["comp_desc_boil"] = "Haşlanabilir."

    zmc.language["comp_title_craft"] = "Üret"
    zmc.language["comp_desc_craft"] = "Çalışma masasında işlenebilir."



    zmc.language["temp_req_title"] = "Isı"
    zmc.language["temp_req_tooltip"] = "Eşyanın pişmeye başlayacağı ısı."

    zmc.language["time_title"] = "Süre"
    zmc.language["time_tooltip"] = "Eşyanın işlemi ne kadar sürecek."

    zmc.language["item_tooltip"] = "Sonrasında alacağımız eşya."

    zmc.language["cycle_title"] = "Devir"
    zmc.language["cycle_tooltip"] = "Eşyayı yaratmak için kaç kez etkileşime girilecek."

    zmc.language["speed_title"] = "Hız"
    zmc.language["speed_tooltip"] = "Karıştırmak için ne kadar hız lazım?"

    zmc.language["amount_title"] = "Miktar"
    zmc.language["amount_tooltip"] = "Kaç tane eşyaya ihtiyacımız var?"

    zmc.language["price_title"] = "Ücret"
    zmc.language["price_tooltip"] = "Eşyanın ücreti."

    zmc.language["items_generic_tooltip"] = "Bu eşyayı üretmek için hangi eşyalar lazım?"
    zmc.language["items_cut_tooltip"] = "Hangi eşyaları alacağız?"

    zmc.language["health_title"] = "Sağlık"
    zmc.language["health_tooltip"] = "Oyuncu tükettikten sonra kaç can kazanacak?"

    zmc.language["health_cap_title"] = "Sağlık Sınırı"
    zmc.language["health_cap_tooltip"] = "Oyuncu bunu tükettikten sonra maksimum alabileceği can seviyesi?"

    zmc.language["range_title"] = "Mesafe"
    zmc.language["range_tooltip"] = "Mini oyunun hedef boyutu."


    zmc.language["Worktable"] = "Çalışma Masası"
    zmc.language["Wok"] = zmc.language["comp_title_wok"]
    zmc.language["Grill"] = zmc.language["comp_title_grill"]
    zmc.language["Mixer"] = "Mikser"
    zmc.language["Oven"] = "Fırın"
    zmc.language["BoilPot"] = "Tencere"
    zmc.language["SoupPot"] = "Çorba Tenceresi"
    zmc.language["Customertable"] = "Müşteri Masası"


    // Update 1.0.1
    zmc.language["Throw"] = "Fırlat"
    zmc.language["Throw_tooltip"] = "Seçili eşyayı hızlıca diğer envantere fırlat."

    // This text is shown next to a items name if its rotten / spoiled
    zmc.language["Spoiled"] = "[ÇÜRÜMÜŞ]"
    zmc.language["Spoiled_desc"] = "Yemek doğa anaya geri döndü."

    // Update 1.0.3
    zmc.language["Cookbook"] = "Yemek kitabı"

    // Update 1.0.6
    zmc.language["YouDontOwnThis"] = "Buna sahip değilsin!"
    zmc.language["NotEnoughMoney"] = "Yeterli paraya sahip değilsin!"
    zmc.language["ItemLimit"] = "$ItemName için varlık limitine ulaştın!"
    zmc.language["Cancel"] = "İptal"
    zmc.language["Deconstruct"] = "Yık"
    zmc.language["Construct"] = "İnşa Et"
    zmc.language["Choosepostion"] = "Yeni Pozisyon Seçin"
    zmc.language["ChooseEntity"] = "Makine Seçin"
    zmc.language["Equipment_Build"] = "İnşa Et"
    zmc.language["Equipment_Move"] = "Hareket Ettir"
    zmc.language["Equipment_Repair"] = "Tamir Et"
    zmc.language["Equipment_Remove"] = "Kaldır"

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
