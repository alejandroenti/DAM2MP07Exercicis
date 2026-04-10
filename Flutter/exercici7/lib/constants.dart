// Prompt de sistema per a la IA
const systemPrompt = """Ets un assistent de dibuix. L'àrea de dibuix té una mida dinàmica que se t'indicarà.
Quan l'usuari faci servir percentatges (%), calcula la posició real en píxels a partir de la mida del canvas.
Per exemple, si el canvas és 800x600 i l'usuari diu "al 50% de l'amplada", x=400. Si diu "al 25% de l'alçada", y=150.
Quan l'usuari digui coses com "a la meitat del dibuix", "al centre", interpreta-ho com 50% d'amplada i 50% d'alçada.
"A la cantonada superior-esquerra" = 0%,0%. "A la cantonada inferior-dreta" = 100%,100%.
"La diagonal del quadre" = una línia de (0,0) a (100%amplada, 100%alçada).
"A un terç" = 33%. "A tres quarts" = 75%.
Quan l'usuari demani seleccionar, esborrar o modificar elements, fes servir les eines corresponents amb l'id de l'element.
Si l'usuari diu "selecciona l'últim cercle" o "esborra el primer rectangle", identifica l'element pel seu id a la llista.
La llista d'elements actuals amb els seus IDs se t'indicarà al missatge.""";

// Defineix les eines/funcions que hi ha disponibles a flutter
const tools = [
  {
    "type": "function",
    "function": {
      "name": "draw_circle",
      "description":
          "Dibuixa un cercle amb un radi determinat. Si falta el radi posar-ne un de 10 per defecte. Si el radi ha de ser aleatori posar-ne un aleatori entre 10 i 25. Es pot especificar color del contorn, gruix del contorn, color d'emplenat i gradient d'emplenat.",
      "parameters": {
        "type": "object",
        "properties": {
          "x": {"type": "number", "description": "Coordenada X del centre"},
          "y": {"type": "number", "description": "Coordenada Y del centre"},
          "radius": {"type": "number", "description": "Radi del cercle"},
          "strokeColor": {
            "type": "string",
            "description":
                "Color del contorn en format hexadecimal sense #, per exemple: FF0000 per vermell, 00FF00 per verd, 0000FF per blau, 000000 per negre"
          },
          "strokeWidth": {
            "type": "number",
            "description": "Gruix del contorn en píxels, per defecte 2"
          },
          "fillColor": {
            "type": "string",
            "description":
                "Color d'emplenat en format hexadecimal sense #, per exemple: FF0000 per vermell. Si no s'especifica, no hi ha emplenat."
          },
          "gradientType": {
            "type": "string",
            "description":
                "Tipus de gradient: 'linear' o 'radial'. Només s'aplica si es donen gradientColors."
          },
          "gradientColors": {
            "type": "array",
            "items": {"type": "string"},
            "description":
                "Llista de colors del gradient en hexadecimal sense #, per exemple: ['FF0000', '0000FF']. Mínim 2 colors."
          }
        }
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "draw_line",
      "description":
          "Dibuixa una línia entre dos punts. Si no s'especifica la posició escull els punts aleatoris entre x=10, y=10 i x=100, y=100. Es pot especificar el color i el gruix de la línia.",
      "parameters": {
        "type": "object",
        "properties": {
          "startX": {"type": "number", "description": "Coordenada X d'inici"},
          "startY": {"type": "number", "description": "Coordenada Y d'inici"},
          "endX": {"type": "number", "description": "Coordenada X de final"},
          "endY": {"type": "number", "description": "Coordenada Y de final"},
          "color": {
            "type": "string",
            "description":
                "Color de la línia en format hexadecimal sense #, per exemple: FF0000 per vermell, 000000 per negre"
          },
          "strokeWidth": {
            "type": "number",
            "description": "Gruix de la línia en píxels, per defecte 2"
          }
        }
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "draw_rectangle",
      "description":
          "Dibuixa un rectangle (o quadrat) definit per les coordenades superior-esquerra i inferior-dreta. Per un quadrat, fes que l'amplada i l'alçada siguin iguals. Es pot especificar color del contorn, gruix del contorn, color d'emplenat i gradient.",
      "parameters": {
        "type": "object",
        "properties": {
          "topLeftX": {
            "type": "number",
            "description": "Coordenada X de la cantonada superior-esquerra"
          },
          "topLeftY": {
            "type": "number",
            "description": "Coordenada Y de la cantonada superior-esquerra"
          },
          "bottomRightX": {
            "type": "number",
            "description": "Coordenada X de la cantonada inferior-dreta"
          },
          "bottomRightY": {
            "type": "number",
            "description": "Coordenada Y de la cantonada inferior-dreta"
          },
          "strokeColor": {
            "type": "string",
            "description":
                "Color del contorn en format hexadecimal sense #, per exemple: FF0000 per vermell"
          },
          "strokeWidth": {
            "type": "number",
            "description": "Gruix del contorn en píxels, per defecte 2"
          },
          "fillColor": {
            "type": "string",
            "description":
                "Color d'emplenat en format hexadecimal sense #. Si no s'especifica, no hi ha emplenat."
          },
          "gradientType": {
            "type": "string",
            "description":
                "Tipus de gradient: 'linear' o 'radial'. Només s'aplica si es donen gradientColors."
          },
          "gradientColors": {
            "type": "array",
            "items": {"type": "string"},
            "description":
                "Llista de colors del gradient en hexadecimal sense #, per exemple: ['FF0000', '0000FF']. Mínim 2 colors."
          }
        },
        "required": ["topLeftX", "topLeftY", "bottomRightX", "bottomRightY"]
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "draw_text",
      "description":
          "Dibuixa un text a la posició indicada. Es pot escollir la tipografia, la mida, el color i l'estil (normal, negreta, cursiva).",
      "parameters": {
        "type": "object",
        "properties": {
          "text": {
            "type": "string",
            "description": "El text a dibuixar"
          },
          "x": {"type": "number", "description": "Coordenada X de la posició"},
          "y": {"type": "number", "description": "Coordenada Y de la posició"},
          "fontSize": {
            "type": "number",
            "description": "Mida de la font en píxels, per defecte 14"
          },
          "color": {
            "type": "string",
            "description":
                "Color del text en format hexadecimal sense #, per exemple: FF0000 per vermell"
          },
          "fontFamily": {
            "type": "string",
            "description":
                "Nom de la tipografia, per exemple: 'Roboto', 'Courier', 'serif', 'monospace'"
          },
          "fontWeight": {
            "type": "string",
            "description":
                "Pes de la font: 'normal' o 'bold' (negreta)"
          },
          "fontStyle": {
            "type": "string",
            "description":
                "Estil de la font: 'normal' o 'italic' (cursiva)"
          }
        },
        "required": ["text", "x", "y"]
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "select_element",
      "description":
          "Selecciona un element del dibuix pel seu ID. L'element quedarà ressaltat visualment.",
      "parameters": {
        "type": "object",
        "properties": {
          "id": {
            "type": "number",
            "description": "L'ID de l'element a seleccionar"
          }
        },
        "required": ["id"]
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "deselect_all",
      "description":
          "Desselecciona tots els elements del dibuix.",
      "parameters": {
        "type": "object",
        "properties": {}
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "delete_element",
      "description":
          "Esborra un element del dibuix pel seu ID. L'element desapareixerà del canvas.",
      "parameters": {
        "type": "object",
        "properties": {
          "id": {
            "type": "number",
            "description": "L'ID de l'element a esborrar"
          }
        },
        "required": ["id"]
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "delete_selected",
      "description":
          "Esborra tots els elements seleccionats del dibuix.",
      "parameters": {
        "type": "object",
        "properties": {}
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "modify_element",
      "description":
          "Modifica les propietats d'un element existent pel seu ID. Només cal especificar les propietats que es volen canviar. Per línia: color, strokeWidth, startX, startY, endX, endY. Per cercle: strokeColor, strokeWidth, fillColor, gradientType, gradientColors, x, y, radius. Per rectangle: strokeColor, strokeWidth, fillColor, gradientType, gradientColors, topLeftX, topLeftY, bottomRightX, bottomRightY. Per text: text, color, fontSize, fontFamily, fontWeight, fontStyle, x, y.",
      "parameters": {
        "type": "object",
        "properties": {
          "id": {
            "type": "number",
            "description": "L'ID de l'element a modificar"
          },
          "strokeColor": {
            "type": "string",
            "description": "Nou color del contorn en hexadecimal sense #"
          },
          "strokeWidth": {
            "type": "number",
            "description": "Nou gruix del contorn"
          },
          "fillColor": {
            "type": "string",
            "description": "Nou color d'emplenat en hexadecimal sense #"
          },
          "color": {
            "type": "string",
            "description": "Nou color (per línies i textos) en hexadecimal sense #"
          },
          "gradientType": {
            "type": "string",
            "description": "Nou tipus de gradient: 'linear' o 'radial'"
          },
          "gradientColors": {
            "type": "array",
            "items": {"type": "string"},
            "description": "Nova llista de colors del gradient"
          },
          "x": {"type": "number", "description": "Nova coordenada X"},
          "y": {"type": "number", "description": "Nova coordenada Y"},
          "radius": {"type": "number", "description": "Nou radi (cercle)"},
          "startX": {"type": "number", "description": "Nova X d'inici (línia)"},
          "startY": {"type": "number", "description": "Nova Y d'inici (línia)"},
          "endX": {"type": "number", "description": "Nova X de final (línia)"},
          "endY": {"type": "number", "description": "Nova Y de final (línia)"},
          "topLeftX": {"type": "number", "description": "Nova X superior-esquerra (rectangle)"},
          "topLeftY": {"type": "number", "description": "Nova Y superior-esquerra (rectangle)"},
          "bottomRightX": {"type": "number", "description": "Nova X inferior-dreta (rectangle)"},
          "bottomRightY": {"type": "number", "description": "Nova Y inferior-dreta (rectangle)"},
          "text": {"type": "string", "description": "Nou text (text)"},
          "fontSize": {"type": "number", "description": "Nova mida de font (text)"},
          "fontFamily": {"type": "string", "description": "Nova tipografia (text)"},
          "fontWeight": {"type": "string", "description": "'normal' o 'bold'"},
          "fontStyle": {"type": "string", "description": "'normal' o 'italic'"}
        },
        "required": ["id"]
      }
    }
  }
];
