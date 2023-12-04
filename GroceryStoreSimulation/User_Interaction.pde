// File data arrays //<>// //<>// //<>// //<>//
float[][] allDistances;
String[][] optimalPaths;
//int[][] fixtureCoords;
//int[][] mainSideCoords;
//PVector[] defaultPoints;
//String[] fixtureNames;
//String[] fixtureTypes;
//String[][] fixtureProducts;
//color[] fixtureColours;

boolean loaded;  // Keeps track of whether a store being saved is a pre-existing one that was modified or a completely new one that was created
String storeName = "Untitled";

boolean showTextbox = false;
boolean textEntered = false;
//boolean saveQueued = false;  // Whether or not the user wanted to save before the program needed to do something else like get the store name
String textboxText = "";
String cursor = "";
String textboxLabel = "";



void keyPressed() {
  if (key == 'S' && !showTextbox) {
    saveStore();
  }

  //if (key == 's' && !showTextbox) {
  //  initTextbox();
  //}

  else if (keyCode == ENTER && showTextbox) {
    //textEntered = true;
    showTextbox = false;

    if (queuedFunction != null)
      queuedFunction.call();  // Calls whatever function required the user to enter something into a textbox
  }

  else if (keyCode == BACKSPACE && showTextbox && textboxText.length() > 0)
    textboxText = textboxText.substring(0, textboxText.length() - 1);

  else if (keyCode == 0 && showTextbox) {
    println(str(key));
    textboxText += str(key);
  }
}

void initTextbox() {
  showTextbox = true;
  textboxLabel = "Store Name:";
  textboxText = "";

  //while (!textEntered) {}

  //textEntered = false;
  //String text = textboxText;
  //textboxText = "";
  //return text;
}

void saveStore() {
  queuedFunction = null;
  if (!loaded) {
    if (storeName.equals("Untitled") && textboxText.equals("")) {
      // Store saveStore() function in a general QueuedFunction object
      // When user enters text into a textbox, the program will just call whatever function is stored in object instead of checking booleans for each possible function
      queuedFunction = new QueuedFunction() {
        public void call() {
          saveStore();
        }
      };
      
      initTextbox();
      return;
    }

    storeName = textboxText;  // should prompt user to enter a name
    textboxText = "";


    if (in(storeNames, storeName)) {
      println(storeName);
      println("Store already exists! Please choose a different name.");
      
      queuedFunction = new QueuedFunction() {
        public void call() {
          saveStore();
        }
      };
      
      initTextbox();
      return;
    }

    storeNames = append(storeNames, storeName);
  }


  PrintWriter[] outputs = new PrintWriter[12];

  outputs[0] = createWriter("Stores/store_names.txt");
  outputs[1] = createWriter("Stores/" + storeName + "/distances.txt");
  outputs[2] = createWriter("Stores/" + storeName + "/paths.txt");
  outputs[3] = createWriter("Stores/" + storeName + "/coords.txt");
  outputs[4] = createWriter("Stores/" + storeName + "/main_sides.txt");
  outputs[5] = createWriter("Stores/" + storeName + "/types.txt");
  outputs[6] = createWriter("Stores/" + storeName + "/names.txt");
  outputs[7] = createWriter("Stores/" + storeName + "/products.txt");
  outputs[8] = createWriter("Stores/" + storeName + "/max_stocks.txt");
  outputs[9] = createWriter("Stores/" + storeName + "/restock_chances.txt");
  outputs[10] = createWriter("Stores/" + storeName + "/colours.txt");
  outputs[11] = createWriter("Stores/" + storeName + "/default_points.txt");

  for (int i = 0; i < storeNames.length; i++) {
    outputs[0].println(storeNames[i]);
  }

  //todo: determine if dists and paths need extra added before and after (to account for start and end points)(done)(yes)
  //outputs[1].println(join(str(allDistances[0]), ","));
  //outputs[2].println(join(optimalPaths[0], ","));
  for (int i = 0; i < fixtures.size(); i++) {
    outputs[1].println(join(str(allDistances[i]), ","));
    outputs[2].println(join(optimalPaths[i], ","));
    outputs[3].println(join(str(fixtures.get(i).position), ","));
    outputs[4].println(join(str(fixtures.get(i).mainSideCoords), ","));
    outputs[5].println(fixtures.get(i).type);
    outputs[6].println(fixtures.get(i).name);
    outputs[7].println(join(fixtures.get(i).products, ","));
    outputs[8].println(str(fixtures.get(i).maxStock));
    outputs[9].println(str(fixtures.get(i).restockChance));

    color c = fixtures.get(i).colour;
    outputs[10].println(str(red(c)) + "," + str(green(c)) + "," + str(blue(c)));

    PVector p = fixtures.get(i).defaultPoint;
    outputs[11].println(str(p.x) + "," + str(p.y));
  }

  for (int i = 0; i < outputs.length; i++) {
    outputs[i].flush();
    outputs[i].close();
  }

  println("Store saved successfully!");
}


void load(String name) {
  loaded = true;
  pathCalculated = true;
  storeName = name;

  String[] dists = loadStrings("Stores/" + storeName + "/distances.txt");
  String[] paths = loadStrings("Stores/" + storeName + "/paths.txt");
  String[] coords = loadStrings("Stores/" + storeName + "/coords.txt");
  String[] mainSides = loadStrings("Stores/" + storeName + "/main_sides.txt");
  String[] fixtureTypes = loadStrings("Stores/" + storeName + "/types.txt");
  String[] fixtureNames = loadStrings("Stores/" + storeName + "/names.txt");
  String[] products = loadStrings("Stores/" + storeName + "/products.txt");
  String[] maxStocks = loadStrings("Stores/" + storeName + "/max_stocks.txt");
  String[] restockChances = loadStrings("Stores/" + storeName + "/restock_chances.txt");
  String[] colours = loadStrings("Stores/" + storeName + "/colours.txt");
  String[] defPoints = loadStrings("Stores/" + storeName + "/default_points.txt");

  int numFixtures = defPoints.length;
  allDistances = new float[numFixtures][numFixtures];
  optimalPaths = new String[numFixtures][numFixtures];

  //allDistances[0] = float(split(dists[0], ","));
  //optimalPaths[0] = split(paths[0], ",");
  for (int row = 0; row < numFixtures; row++) {
    float[] currDists = float(split(dists[row], ","));
    String[] currPaths = split(paths[row], ",");
    int[] currCoords = int(split(coords[row], ","));
    int[] currMainSides = int(split(mainSides[row], ","));
    String currType = fixtureTypes[row];
    String currName = fixtureNames[row];
    String[] currProducts = split(products[row], ",");
    int currMaxStock = int(maxStocks[row]);
    float currRestockChance = float(restockChances[row]);

    float[] rgb = float(split(colours[row], ","));
    color currColour = color(rgb[0], rgb[1], rgb[2]);

    float[] defPointCoords = float(split(defPoints[row], ","));
    PVector currDefaultPoint = new PVector(defPointCoords[0], defPointCoords[1]);


    allDistances[row] = currDists;
    optimalPaths[row] = currPaths;

    fixtures.add(new Fixture(currCoords, currMainSides, currType, currName, currProducts, currMaxStock, currRestockChance, currColour, currDefaultPoint));
  }
}
