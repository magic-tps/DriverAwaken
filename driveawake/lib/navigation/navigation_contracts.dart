enum MapsSearchCategory {
  cafes('Cafeterías cercanas', 'cafeterías cercanas'),
  fuel('Grifos cercanos', 'grifos cercanos'),
  restAreas('Áreas de descanso', 'áreas de descanso cercanas'),
  parking('Estacionamientos', 'estacionamientos cercanos'),
  restaurants('Restaurantes', 'restaurantes cercanos'),
  lodging('Hospedajes', 'hospedajes cercanos');

  const MapsSearchCategory(this.label, this.query);

  final String label;
  final String query;
}

/// Official Google Maps URL. No Maps SDK, Places API or API key is involved.
Uri mapsSearchUri(String query) {
  final normalized = query.trim();
  if (normalized.isEmpty || normalized.length > 160) {
    throw ArgumentError('La búsqueda debe contener entre 1 y 160 caracteres.');
  }
  return Uri.https('www.google.com', '/maps/search/', {
    'api': '1',
    'query': normalized,
  });
}

/// Official Google Maps directions URL. Google Maps resolves the destination.
Uri mapsDirectionsUri(String destination) {
  final normalized = destination.trim();
  if (normalized.isEmpty || normalized.length > 160) {
    throw ArgumentError('El destino debe contener entre 1 y 160 caracteres.');
  }
  return Uri.https('www.google.com', '/maps/dir/', {
    'api': '1',
    'destination': normalized,
    'travelmode': 'driving',
    'dir_action': 'navigate',
  });
}
