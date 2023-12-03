// File data arrays
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
boolean saveQueued = false;  // Whether or not the user wanted to save before the program needed to do something else like get the store name
String textboxText = "";
String cursor = "";
String textboxLabel = "";



void keyPressed() {
  if (key == 'S' && !showTextbox) {
    saveStore();
  }
  
  if (key == 's' && !showTextbox) {
    initTextbox();
  }
  
  if (keyCode == ENTER && showTextbox) {
    //textEntered = true;
    showTextbox = false;
    
    if (saveQueued)
      saveStore();
  }
  
  if (keyCode == BACKSPACE && showTextbox && textboxText.length() > 0)
    textboxText = textboxText.substring(0, textboxText.length() - 1);
    
  if (keyCode == 0 && showTextbox) { //<>//
    println(str(key));
    textboxText += str(key);
  }
}

void initTextbox() {
  showTextbox = true; //<>//
  textboxLabel = "Store Name:";
  textboxText = "";
  
  //while (!textEntered) {}
  
  //textEntered = false;
  //String text = textboxText;
  //textboxText = "";
  //return text;
}

void saveStore() {
  saveQueued = false; //<>//
  if (!loaded) {
    if (storeName.equals("Untitled") && textboxText.equals("")) {
      saveQueued = true;
      initTextbox();
      return;
    }
    
    storeName = textboxText;  // should prompt user to enter a name
    textboxText = "";
    
    
    if (in(storeNames, storeName)) {
      println(storeName);
      println("Store already exists! Please choose a different name.");
      saveQueued = true;
      initTextbox();
      return;
    }
    
    storeNames = append(storeNames, storeName);
  }
  
  
  PrintWriter[] outputs = new PrintWriter[10];
  
  outputs[0] = createWriter("store_names.txt");
  outputs[1] = createWriter(storeName + "/distances.txt");
  outputs[2] = createWriter(storeName + "/paths.txt");
  outputs[3] = createWriter(storeName + "/coords.txt");
  outputs[4] = createWriter(storeName + "/main_sides.txt");
  outputs[5] = createWriter(storeName + "/types.txt");
  outputs[6] = createWriter(storeName + "/names.txt");
  outputs[7] = createWriter(storeName + "/products.txt");
  outputs[8] = createWriter(storeName + "/colours.txt");
  outputs[9] = createWriter(storeName + "/default_points.txt");
  
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
    
    color c = fixtures.get(i).colour;
    outputs[8].println(str(red(c)) + "," + str(green(c)) + "," + str(blue(c)));
    
    PVector p = fixtures.get(i).defaultPoint;
    outputs[9].println(str(p.x) + "," + str(p.y));
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
  
  String[] dists = loadStrings(storeName + "/distances.txt");
  String[] paths = loadStrings(storeName + "/paths.txt");
  String[] coords = loadStrings(storeName + "/coords.txt");
  String[] mainSides = loadStrings(storeName + "/main_sides.txt");
  String[] fixtureTypes = loadStrings(storeName + "/types.txt");
  String[] fixtureNames = loadStrings(storeName + "/names.txt");
  String[] products = loadStrings(storeName + "/products.txt");
  String[] colours = loadStrings(storeName + "/colours.txt");
  String[] defPoints = loadStrings(storeName + "/default_points.txt");
  
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
    
    float[] rgb = float(split(colours[row], ","));
    color currColour = color(rgb[0], rgb[1], rgb[2]);
    
    float[] defPointCoords = float(split(defPoints[row], ","));
    PVector currDefaultPoint = new PVector(defPointCoords[0], defPointCoords[1]);
    
    
    allDistances[row] = currDists;
    optimalPaths[row] = currPaths;
    
    fixtures.add(new Fixture(currCoords, currMainSides, currType, currName, currProducts, currColour, currDefaultPoint));
    
  }
}
