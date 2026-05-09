# Lucky

Aplicación móvil desarrollada en Flutter.

## Tecnologías

- Flutter
- Dart SDK ^3.10.4
- Provider
- Go Router
- Dio
- Shared Preferences
- Pusher Channels
- Pusher Beams
- Cached Network Image

---

# Instalación

## 1. Clonar repositorio

```bash
git clone <URL_DEL_REPOSITORIO>
```

## 2. Entrar al proyecto

```bash
cd lucky
```

## 3. Instalar dependencias

```bash
flutter pub get
```

## 4. Ejecutar aplicación

```bash
flutter run
```

---

# Estructura recomendada

```bash
lib/
│
├── core/
├── models/
├── providers/
├── routes/
├── screens/
├── widgets/
├── repositories/
├── api/
└── main.dart
```

---

# Dependencias principales

## go_router
Manejo de rutas y navegación.

## provider
Manejo de estado global.

## dio
Consumo de APIs REST y manejo de interceptores.

## shared_preferences
Persistencia local para tokens y configuración.

## pusher_channels_flutter
Eventos en tiempo real.

## pusher_beams
Push notifications.

## cached_network_image
Cache de imágenes remotas.

---

# Assets

Los assets están configurados en:

```yaml
flutter:
  assets:
    - assets/
```

---

# Comandos útiles

## Obtener dependencias

```bash
flutter pub get
```

## Limpiar proyecto

```bash
flutter clean
```

## Ejecutar tests

```bash
flutter test
```

## Build APK

```bash
flutter build apk
```

---

# Buenas prácticas

- Mantener widgets pequeños
- Separar lógica de UI
- Reutilizar widgets
- Centralizar llamadas API
- Usar providers por feature

---

# Flujo recomendado

1. Revisar `main.dart`
2. Revisar `routes/`
3. Revisar `providers/`
4. Revisar `api/`
5. Revisar `screens/`

---

# Requisitos

- Flutter instalado
- Android Studio o VS Code
- Emulador o dispositivo físico

# Nota 
- Realizar el cambio de credenciales de pusher