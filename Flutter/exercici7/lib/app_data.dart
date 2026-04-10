import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'constants.dart';
import 'drawable.dart';

const streamingModel = 'granite4:3b';
const functionCallingModel = 'granite4:3b';
const jsonFixModel = 'granite4:3b';

class AppData extends ChangeNotifier {
  String _responseText = "";
  bool _isLoading = false;
  bool _isInitial = true;
  http.Client? _client;
  IOClient? _ioClient;
  HttpClient? _httpClient;
  StreamSubscription<String>? _streamSubscription;

  final List<Drawable> drawables = [];
  int _nextId = 1;
  Size _canvasSize = const Size(800, 600);

  Size get canvasSize => _canvasSize;

  void updateCanvasSize(Size size) {
    if (size != _canvasSize) {
      _canvasSize = size;
    }
  }

  String get responseText =>
      _isInitial ? "..." : (_isLoading ? "Esperant ..." : _responseText);

  bool get isLoading => _isLoading;

  AppData() {
    _httpClient = HttpClient();
    _ioClient = IOClient(_httpClient!);
    _client = _ioClient;
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void addDrawable(Drawable drawable) {
    drawables.add(drawable);
    notifyListeners();
  }

  int getNextId() => _nextId++;

  void selectDrawableAt(Offset point) {
    // Desseleccionar tot primer
    for (var d in drawables) {
      d.isSelected = false;
    }
    // Seleccionar el primer que faci hit (de dalt a baix = últim afegit primer)
    for (var i = drawables.length - 1; i >= 0; i--) {
      if (drawables[i].hitTest(point)) {
        drawables[i].isSelected = true;
        break;
      }
    }
    notifyListeners();
  }

  void selectById(int id) {
    for (var d in drawables) {
      d.isSelected = (d.id == id);
    }
    notifyListeners();
  }

  void deselectAll() {
    for (var d in drawables) {
      d.isSelected = false;
    }
    notifyListeners();
  }

  void deleteById(int id) {
    drawables.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  void deleteSelected() {
    drawables.removeWhere((d) => d.isSelected);
    notifyListeners();
  }

  Drawable? findById(int id) {
    for (var d in drawables) {
      if (d.id == id) return d;
    }
    return null;
  }

  String _buildDrawablesList() {
    if (drawables.isEmpty) return "No hi ha elements al canvas.";
    final sb = StringBuffer("Elements actuals al canvas:\n");
    for (var d in drawables) {
      if (d is Line) {
        sb.writeln("- [id=${d.id}] Línia de (${d.start.dx},${d.start.dy}) a (${d.end.dx},${d.end.dy})");
      } else if (d is Circle) {
        sb.writeln("- [id=${d.id}] Cercle centre=(${d.center.dx},${d.center.dy}) radi=${d.radius}");
      } else if (d is Rectangle) {
        sb.writeln("- [id=${d.id}] Rectangle de (${d.topLeft.dx},${d.topLeft.dy}) a (${d.bottomRight.dx},${d.bottomRight.dy})");
      } else if (d is TextElement) {
        sb.writeln("- [id=${d.id}] Text \"${d.text}\" a (${d.position.dx},${d.position.dy})");
      }
    }
    return sb.toString();
  }

  Future<void> callStream({required String question}) async {
    _isInitial = false;
    setLoading(true);

    try {
      var request = http.Request(
        'POST',
        Uri.parse('http://localhost:11434/api/generate'),
      );

      request.headers.addAll({'Content-Type': 'application/json'});
      request.body = jsonEncode(
          {'model': streamingModel, 'prompt': question, 'stream': true});

      var streamedResponse = await _client!.send(request);
      _streamSubscription =
          streamedResponse.stream.transform(utf8.decoder).listen((value) {
        var jsonResponse = jsonDecode(value);
        var jsonResponseStr = jsonResponse['response'];
        _responseText = "$_responseText\n$jsonResponseStr";
        notifyListeners();
      }, onError: (error) {
        if (error is http.ClientException &&
            error.message == 'Connection closed while receiving data') {
          _responseText += "\nRequest cancelled.";
        } else {
          _responseText += "\nError during streaming: $error";
        }
        setLoading(false);
        notifyListeners();
      }, onDone: () {
        setLoading(false);
      });
    } catch (e) {
      _responseText = "\nError during streaming.";
      setLoading(false);
      notifyListeners();
    }
  }

  Future<dynamic> fixJsonInStrings(dynamic data) async {
    if (data is Map<String, dynamic>) {
      final result = <String, dynamic>{};
      for (final entry in data.entries) {
        result[entry.key] = await fixJsonInStrings(entry.value);
      }
      return result;
    } else if (data is List) {
      return Future.wait(data.map((value) => fixJsonInStrings(value)));
    } else if (data is String) {
      final trimmed = data.trim();
      if (trimmed.isEmpty) {
        return data;
      }

      try {
        // Si és JSON dins d'una cadena, el deserialitzem
        final parsed = jsonDecode(data);
        return fixJsonInStrings(parsed);
      } catch (_) {
        if (_looksLikeJsonCandidate(trimmed)) {
          final repairedJson = await _repairJsonWithAi(trimmed);
          if (repairedJson != null) {
            return fixJsonInStrings(repairedJson);
          }
        }

        // Si no és JSON o no es pot reparar, retornem la cadena tal qual
        return data;
      }
    }
    // Retorna qualsevol altre tipus sense canvis (números, booleans, etc.)
    return data;
  }

  bool _looksLikeJsonCandidate(String value) {
    return value.startsWith('{') ||
        value.startsWith('[') ||
        ((value.contains('{') || value.contains('[')) && value.contains(':'));
  }

  Future<dynamic> _repairJsonWithAi(String rawJson) async {
    const apiUrl = 'http://localhost:11434/api/chat';
    final body = {
      "model": jsonFixModel,
      "stream": false,
      "format": "json",
      "messages": [
        {
          "role": "system",
          "content":
              "You repair malformed JSON. Return only valid JSON that preserves the original intent and values as closely as possible."
        },
        {
          "role": "user",
          "content":
              "Repair this malformed JSON and return only the fixed JSON:\n$rawJson"
        }
      ]
    };

    try {
      final response = await _client!.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        return null;
      }

      final jsonResponse = jsonDecode(response.body);
      final content = jsonResponse['message']?['content'];
      if (content is! String || content.trim().isEmpty) {
        return null;
      }

      return jsonDecode(content);
    } catch (_) {
      return null;
    }
  }

  dynamic cleanKeys(dynamic value) {
    if (value is Map<String, dynamic>) {
      final result = <String, dynamic>{};
      value.forEach((k, v) {
        result[k.trim()] = cleanKeys(v);
      });
      return result;
    }
    if (value is List) {
      return value.map(cleanKeys).toList();
    }
    return value;
  }

  Future<void> callWithCustomTools({required String userPrompt}) async {
    const apiUrl = 'http://localhost:11434/api/chat';
    _isInitial = false;
    setLoading(true);

    final canvasInfo = "La mida del canvas és ${_canvasSize.width.toInt()}x${_canvasSize.height.toInt()} píxels.";
    final elementsList = _buildDrawablesList();

    final body = {
      "model": functionCallingModel,
      "stream": false,
      "messages": [
        {"role": "system", "content": "$systemPrompt\n\n$canvasInfo\n\n$elementsList"},
        {"role": "user", "content": userPrompt}
      ],
      "tools": tools
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['message'] != null &&
            jsonResponse['message']['tool_calls'] != null) {
          final toolCalls = (jsonResponse['message']['tool_calls'] as List)
              .map((e) => cleanKeys(e))
              .toList();
          for (final tc in toolCalls) {
            if (tc['function'] != null) {
              await _processFunctionCall(tc['function']);
            }
          }
        }
        setLoading(false);
      } else {
        setLoading(false);
        throw Exception("Error: ${response.body}");
      }
    } catch (e) {
      print("Error during API call: $e");
      setLoading(false);
    }
  }

  void cancelRequests() {
    _streamSubscription?.cancel();
    _httpClient?.close(force: true);
    _httpClient = HttpClient();
    _ioClient = IOClient(_httpClient!);
    _client = _ioClient;
    _responseText += "\nRequest cancelled.";
    setLoading(false);
    notifyListeners();
  }

  double parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  double _randomBetween(double min, double max) {
    return min + Random().nextDouble() * (max - min);
  }

  Color? parseHexColor(dynamic value) {
    if (value == null) return null;
    String hex = value.toString().trim().replaceAll('#', '');
    if (hex.isEmpty) return null;
    if (hex.length == 6) hex = 'FF$hex';
    if (hex.length == 8) {
      final intVal = int.tryParse(hex, radix: 16);
      if (intVal != null) return Color(intVal);
    }
    return null;
  }

  GradientInfo? parseGradient(Map<String, dynamic> parameters) {
    final gradientColors = parameters['gradientColors'];
    if (gradientColors == null || gradientColors is! List || gradientColors.length < 2) {
      return null;
    }
    final colors = <Color>[];
    for (final c in gradientColors) {
      final parsed = parseHexColor(c);
      if (parsed != null) {
        colors.add(parsed);
      }
    }
    if (colors.length < 2) return null;
    final typeStr = (parameters['gradientType'] ?? 'linear').toString().toLowerCase();
    final type = typeStr == 'radial' ? GradientType.radial : GradientType.linear;
    return GradientInfo(type: type, colors: colors);
  }

  Future<void> _processFunctionCall(Map<String, dynamic> functionCall) async {
    final fixedJson = await fixJsonInStrings(functionCall);
    final parametersData = fixedJson['arguments'];
    final parameters = parametersData is Map<String, dynamic>
        ? parametersData
        : <String, dynamic>{};

    String name = fixedJson['name'];
    String infoText = "Draw $name: $parameters";

    print(infoText);
    _responseText = "$_responseText\n$infoText";

    switch (name) {
      case 'draw_circle':
        final dx =
            parameters['x'] != null ? parseDouble(parameters['x']) : 50.0;
        final dy =
            parameters['y'] != null ? parseDouble(parameters['y']) : 50.0;
        final radius = parameters['radius'] != null
            ? parseDouble(parameters['radius'])
            : 10.0;
        final strokeColor = parseHexColor(parameters['strokeColor']) ?? Colors.black;
        final strokeWidth = parameters['strokeWidth'] != null
            ? parseDouble(parameters['strokeWidth'])
            : 2.0;
        final fillColor = parseHexColor(parameters['fillColor']);
        final gradient = parseGradient(parameters);
        addDrawable(
          Circle(
            id: getNextId(),
            center: Offset(dx, dy),
            radius: max(0.0, radius),
            strokeColor: strokeColor,
            strokeWidth: strokeWidth,
            fillColor: fillColor,
            gradient: gradient,
          ),
        );
        break;

      case 'draw_line':
        final startX = parameters['startX'] != null
            ? parseDouble(parameters['startX'])
            : _randomBetween(10.0, 100.0);
        final startY = parameters['startY'] != null
            ? parseDouble(parameters['startY'])
            : _randomBetween(10.0, 100.0);
        final endX = parameters['endX'] != null
            ? parseDouble(parameters['endX'])
            : _randomBetween(10.0, 100.0);
        final endY = parameters['endY'] != null
            ? parseDouble(parameters['endY'])
            : _randomBetween(10.0, 100.0);
        final lineColor = parseHexColor(parameters['color']) ?? Colors.black;
        final lineStrokeWidth = parameters['strokeWidth'] != null
            ? parseDouble(parameters['strokeWidth'])
            : 2.0;
        final start = Offset(startX, startY);
        final end = Offset(endX, endY);
        addDrawable(Line(
          id: getNextId(),
          start: start,
          end: end,
          color: lineColor,
          strokeWidth: lineStrokeWidth,
        ));
        break;

      case 'draw_rectangle':
        if (parameters['topLeftX'] != null &&
            parameters['topLeftY'] != null &&
            parameters['bottomRightX'] != null &&
            parameters['bottomRightY'] != null) {
          final topLeftX = parseDouble(parameters['topLeftX']);
          final topLeftY = parseDouble(parameters['topLeftY']);
          final bottomRightX = parseDouble(parameters['bottomRightX']);
          final bottomRightY = parseDouble(parameters['bottomRightY']);
          final topLeft = Offset(topLeftX, topLeftY);
          final bottomRight = Offset(bottomRightX, bottomRightY);
          final rectStrokeColor =
              parseHexColor(parameters['strokeColor']) ?? Colors.black;
          final rectStrokeWidth = parameters['strokeWidth'] != null
              ? parseDouble(parameters['strokeWidth'])
              : 2.0;
          final rectFillColor = parseHexColor(parameters['fillColor']);
          final rectGradient = parseGradient(parameters);
          addDrawable(Rectangle(
            id: getNextId(),
            topLeft: topLeft,
            bottomRight: bottomRight,
            strokeColor: rectStrokeColor,
            strokeWidth: rectStrokeWidth,
            fillColor: rectFillColor,
            gradient: rectGradient,
          ));
        } else {
          print("Missing rectangle properties: $parameters");
        }
        break;

      case 'draw_text':
        final text = parameters['text']?.toString() ?? 'Text';
        final tx =
            parameters['x'] != null ? parseDouble(parameters['x']) : 50.0;
        final ty =
            parameters['y'] != null ? parseDouble(parameters['y']) : 50.0;
        final fontSize = parameters['fontSize'] != null
            ? parseDouble(parameters['fontSize'])
            : 14.0;
        final textColor = parseHexColor(parameters['color']) ?? Colors.black;
        final fontFamily =
            parameters['fontFamily']?.toString() ?? 'Roboto';
        final fontWeightStr =
            (parameters['fontWeight'] ?? 'normal').toString().toLowerCase();
        final fontWeight =
            fontWeightStr == 'bold' ? FontWeight.bold : FontWeight.normal;
        final fontStyleStr =
            (parameters['fontStyle'] ?? 'normal').toString().toLowerCase();
        final fontStyle =
            fontStyleStr == 'italic' ? FontStyle.italic : FontStyle.normal;
        addDrawable(TextElement(
          id: getNextId(),
          text: text,
          position: Offset(tx, ty),
          color: textColor,
          fontSize: fontSize,
          fontFamily: fontFamily,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
        ));
        break;

      case 'select_element':
        if (parameters['id'] != null) {
          final id = parseDouble(parameters['id']).toInt();
          selectById(id);
        }
        break;

      case 'deselect_all':
        deselectAll();
        break;

      case 'delete_element':
        if (parameters['id'] != null) {
          final id = parseDouble(parameters['id']).toInt();
          deleteById(id);
        }
        break;

      case 'delete_selected':
        deleteSelected();
        break;

      case 'modify_element':
        if (parameters['id'] != null) {
          final id = parseDouble(parameters['id']).toInt();
          final element = findById(id);
          if (element != null) {
            _applyModifications(element, parameters);
            notifyListeners();
          } else {
            print("Element amb id=$id no trobat");
          }
        }
        break;

      default:
        print("Unknown function call: ${fixedJson['name']}");
    }
  }

  void _applyModifications(Drawable element, Map<String, dynamic> params) {
    if (element is Line) {
      if (params['startX'] != null) element.start = Offset(parseDouble(params['startX']), element.start.dy);
      if (params['startY'] != null) element.start = Offset(element.start.dx, parseDouble(params['startY']));
      if (params['endX'] != null) element.end = Offset(parseDouble(params['endX']), element.end.dy);
      if (params['endY'] != null) element.end = Offset(element.end.dx, parseDouble(params['endY']));
      if (params['color'] != null) element.color = parseHexColor(params['color']) ?? element.color;
      if (params['strokeWidth'] != null) element.strokeWidth = parseDouble(params['strokeWidth']);
    } else if (element is Circle) {
      if (params['x'] != null) element.center = Offset(parseDouble(params['x']), element.center.dy);
      if (params['y'] != null) element.center = Offset(element.center.dx, parseDouble(params['y']));
      if (params['radius'] != null) element.radius = parseDouble(params['radius']);
      if (params['strokeColor'] != null) element.strokeColor = parseHexColor(params['strokeColor']) ?? element.strokeColor;
      if (params['strokeWidth'] != null) element.strokeWidth = parseDouble(params['strokeWidth']);
      if (params['fillColor'] != null) element.fillColor = parseHexColor(params['fillColor']);
      final newGradient = parseGradient(params);
      if (newGradient != null) element.gradient = newGradient;
    } else if (element is Rectangle) {
      if (params['topLeftX'] != null) element.topLeft = Offset(parseDouble(params['topLeftX']), element.topLeft.dy);
      if (params['topLeftY'] != null) element.topLeft = Offset(element.topLeft.dx, parseDouble(params['topLeftY']));
      if (params['bottomRightX'] != null) element.bottomRight = Offset(parseDouble(params['bottomRightX']), element.bottomRight.dy);
      if (params['bottomRightY'] != null) element.bottomRight = Offset(element.bottomRight.dx, parseDouble(params['bottomRightY']));
      if (params['strokeColor'] != null) element.strokeColor = parseHexColor(params['strokeColor']) ?? element.strokeColor;
      if (params['strokeWidth'] != null) element.strokeWidth = parseDouble(params['strokeWidth']);
      if (params['fillColor'] != null) element.fillColor = parseHexColor(params['fillColor']);
      final newGradient = parseGradient(params);
      if (newGradient != null) element.gradient = newGradient;
    } else if (element is TextElement) {
      if (params['x'] != null) element.position = Offset(parseDouble(params['x']), element.position.dy);
      if (params['y'] != null) element.position = Offset(element.position.dx, parseDouble(params['y']));
      if (params['text'] != null) element.text = params['text'].toString();
      if (params['color'] != null) element.color = parseHexColor(params['color']) ?? element.color;
      if (params['fontSize'] != null) element.fontSize = parseDouble(params['fontSize']);
      if (params['fontFamily'] != null) element.fontFamily = params['fontFamily'].toString();
      if (params['fontWeight'] != null) {
        element.fontWeight = params['fontWeight'].toString().toLowerCase() == 'bold' ? FontWeight.bold : FontWeight.normal;
      }
      if (params['fontStyle'] != null) {
        element.fontStyle = params['fontStyle'].toString().toLowerCase() == 'italic' ? FontStyle.italic : FontStyle.normal;
      }
    }
  }
}
