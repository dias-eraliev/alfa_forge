class City {
  final String name;
  final String region;

  const City({
    required this.name,
    required this.region,
  });
}

class CitiesData {
  static const List<City> kazakhstanCities = [
    // Мегаполисы (население свыше 1 млн)
    City(name: 'Алматы', region: 'Алматы'),
    City(name: 'Астана', region: 'Астана'),
    City(name: 'Шымкент', region: 'Шымкент'),
    
    // Крупные города (население 200-500 тыс)
    City(name: 'Актобе', region: 'Актюбинская область'),
    City(name: 'Караганда', region: 'Карагандинская область'),
    City(name: 'Тараз', region: 'Жамбылская область'),
    City(name: 'Павлодар', region: 'Павлодарская область'),
    City(name: 'Усть-Каменогорск', region: 'Восточно-Казахстанская область'),
    City(name: 'Семей', region: 'Восточно-Казахстанская область'),
    City(name: 'Атырау', region: 'Атырауская область'),
    City(name: 'Костанай', region: 'Костанайская область'),
    City(name: 'Петропавловск', region: 'Северо-Казахстанская область'),
    City(name: 'Актау', region: 'Мангистауская область'),
    City(name: 'Кокшетау', region: 'Акмолинская область'),
    City(name: 'Уральск', region: 'Западно-Казахстанская область'),
    City(name: 'Кызылорда', region: 'Кызылординская область'),
    City(name: 'Туркестан', region: 'Туркестанская область'),
    City(name: 'Темиртау', region: 'Карагандинская область'),
    
    // Средние города (население 100-200 тыс)
    City(name: 'Экибастуз', region: 'Павлодарская область'),
    City(name: 'Талдыкорган', region: 'Алматинская область'),
    City(name: 'Рудный', region: 'Костанайская область'),
    City(name: 'Жезказган', region: 'Карагандинская область'),
    City(name: 'Капчагай', region: 'Алматинская область'),
    City(name: 'Балхаш', region: 'Карагандинская область'),
    City(name: 'Лисаковск', region: 'Костанайская область'),
    City(name: 'Степногорск', region: 'Акмолинская область'),
    City(name: 'Кентау', region: 'Туркестанская область'),
    City(name: 'Жанаозен', region: 'Мангистауская область'),
    City(name: 'Риддер', region: 'Восточно-Казахстанская область'),
    
    // Малые города (население менее 100 тыс)
    City(name: 'Аксу', region: 'Павлодарская область'),
    City(name: 'Байконыр', region: 'Кызылординская область'),
    City(name: 'Каратау', region: 'Жамбылская область'),
    City(name: 'Щучинск', region: 'Акмолинская область'),
    City(name: 'Кульсары', region: 'Атырауская область'),
    City(name: 'Сатпаев', region: 'Карагандинская область'),
    City(name: 'Арысь', region: 'Туркестанская область'),
    City(name: 'Текели', region: 'Алматинская область'),
    City(name: 'Зыряновск', region: 'Восточно-Казахстанская область'),
    City(name: 'Жанатас', region: 'Жамбылская область'),
    City(name: 'Аксай', region: 'Западно-Казахстанская область'),
    City(name: 'Хромтау', region: 'Актюбинская область'),
    City(name: 'Алга', region: 'Актюбинская область'),
    City(name: 'Ушарал', region: 'Алматинская область'),
    City(name: 'Булаево', region: 'Северо-Казахстанская область'),
    City(name: 'Житикара', region: 'Костанайская область'),
  ];
  
  static List<String> get cityNames => 
      kazakhstanCities.map((city) => city.name).toList();
}
