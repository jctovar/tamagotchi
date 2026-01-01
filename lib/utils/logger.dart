/// Configuración centralizada de logging para la aplicación
library;

import 'package:logger/logger.dart';

/// Logger configurado para toda la aplicación
final appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 0, // Sin stack trace por defecto
    errorMethodCount: 5, // Stack trace solo en errores
    lineLength: 80,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
  level: Level.debug, // Cambiar a Level.info en producción
);

/// Logger simplificado sin emojis ni colores (útil para logs de producción)
final simpleLogger = Logger(
  printer: SimplePrinter(
    colors: false,
    printTime: true,
  ),
  level: Level.info,
);
