/// Modelo sencillo que representa todos los tickets de una misma tienda.
///
/// Para un MVP es suficiente agrupar por comercio y guardar:
/// - nombre de la tienda,
/// - número de tickets,
/// - imagen asociada,
/// - listas de precios y fechas.
/// Más adelante se podría refinar a un modelo por ticket individual.
class Ticket {
  Ticket({
    required this.storeName,
    required this.ticketCount,
    required this.imageUrl,
    required this.prices,
    required this.dates,
  });

  String storeName;
  int ticketCount;
  String imageUrl;
  List<String> prices;
  List<String> dates;
}

