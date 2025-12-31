import 'package:flutter_test/flutter_test.dart';
import 'package:tamagotchi/services/ml_data_export_service.dart';

void main() {
  group('ExportResult', () {
    test('se crea con éxito', () {
      final result = ExportResult(
        success: true,
        recordCount: 100,
        filePath: '/path/to/file.json',
      );

      expect(result.success, true);
      expect(result.recordCount, 100);
      expect(result.filePath, '/path/to/file.json');
      expect(result.error, isNull);
    });

    test('se crea con error', () {
      final result = ExportResult(
        success: false,
        recordCount: 0,
        error: 'No hay datos para exportar',
      );

      expect(result.success, false);
      expect(result.recordCount, 0);
      expect(result.filePath, isNull);
      expect(result.error, 'No hay datos para exportar');
    });

    test('todos los campos son accesibles', () {
      final result = ExportResult(
        success: true,
        recordCount: 50,
        filePath: '/tmp/data.json',
        error: null,
      );

      expect(result.success, isA<bool>());
      expect(result.recordCount, isA<int>());
      expect(result.filePath, isA<String?>());
      expect(result.error, isA<String?>());
    });
  });

  group('MLDataExportService', () {
    test('es singleton', () {
      final service1 = MLDataExportService();
      final service2 = MLDataExportService();

      expect(identical(service1, service2), true);
    });

    // Nota: Los tests de exportTrainingData y generateSyntheticData
    // requieren mocking del file system y path_provider, lo cual
    // es más apropiado para tests de integración.
  });
}
