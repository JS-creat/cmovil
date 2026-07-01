import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lucky/utils/api_config.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class PusherConfig {
  PusherChannelsFlutter? pusher;

  // TODO: Mover estas dos variables a ApiConfig más adelante para máxima seguridad
  final String appKey = '43bc7bcfe4694589cbf6';
  final String cluster = 'mt1';
  final String authUrl = ApiConfig.broadcastAuthUrl;

  Future<void> initPusher({
    required String channelName,
    required String eventName,
    required Function(dynamic) onEventTriggered,
    String? authToken,
  }) async {
    // Inicializamos la instancia
    pusher = PusherChannelsFlutter.getInstance();

    try {
      // Usamos el operador ! porque justo arriba nos aseguramos de que no sea nulo
      await pusher!.init(
        apiKey: appKey,
        cluster: cluster,
        authEndpoint: authUrl,
        onEvent: (event) {
          if (event.eventName == eventName) {
            onEventTriggered(event);
          }
        },
        onAuthorizer: (channelName, socketId, options) async {
          final response = await http.post(
            Uri.parse(authUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
            body: jsonEncode({
              'channel_name': channelName,
              'socket_id': socketId,
            }),
          );

          if (response.statusCode == 200) {
            return jsonDecode(response.body);
          } else {
            throw Exception('Failed to authorize');
          }
        },
      );

      await pusher!.connect();
      await pusher!.subscribe(channelName: channelName);
    } catch (e) {
      print('Error iniciando Pusher: $e');
    }
  }

  Future<void> disconnect() async {
    // Usamos ?. para que si 'pusher' es nulo, simplemente no haga nada y no rompa la app
    await pusher?.disconnect();
  }
}
