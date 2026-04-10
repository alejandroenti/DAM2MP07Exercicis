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
  }
];
