// File data arrays //<>// //<>// //<>// //<>// //<>//
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


Textbox textbox = new Textbox();
//boolean showTextbox = false;
boolean textEntered = false;
//boolean saveQueued = false;  // Whether or not the user wanted to save before the program needed to do something else like get the store name
//String textboxText = "";
String cursor = "";
//String textboxLabel = "";

int selectedFixture = -1;
int presetIndex;

boolean recalcRequired = false;

boolean altHeld = false;

void keyPressed() {
  if (key == 'S' && !textbox.show && selectedFixture == -1) {
    saveStore();
  }
  
  else if (key == 'c' && !textbox.show)
    changeFixtureColour("Random");
  
  else if (key == 'C' && !textbox.show)
    changeFixtureColour("Custom");

  else if (keyCode == ENTER && textbox.show) {
    //textEntered = true;
    textbox.show = false;

    if (queuedFunction != null)
      queuedFunction.call();  // Calls whatever function required the user to enter something into a textbox
  }

  else if (keyCode == BACKSPACE) {
    if (textbox.show && textbox.text.length() > 0)
      textbox.text = textbox.text.substring(0, textbox.text.length() - 1);
    else if (!textbox.show)
      deleteLastFixture();
  }

  else if (keyCode == 0 && key != '/' && textbox.show) {
    //println(str(key));
    textbox.text += str(key);
  }
  
  else if (keyCode == LEFT && selectedFixture != -1)
    fixtures.get(selectedFixture).changeMainSide("Counterclockwise");
    
  else if (keyCode == RIGHT && selectedFixture != -1)
    fixtures.get(selectedFixture).changeMainSide("Clockwise");
    
  else if ('0' <= key && key <= '9') {
    presetIndex = key - 48;
    
    addFixture();
    
  }
  
  else if (key == 'r') {
    if (altHeld)
      recalculatePath();  // alt + r to manually recalculate path
    else
      renameFixture();
  }
    
  else if (key == 'R')
    reenterProducts();
    
  else if (key == 'A')
    addProducts();
    
  else if (keyCode == ALT) {
    altHeld = true;
    defaultMoveDistance = 1;
  }
    
  else if (key == 'w' && selectedFixture > 0)
    fixtures.get(selectedFixture).move(new int[]{0, -defaultMoveDistance});
    
  else if (key == 's' && selectedFixture > 0)
    fixtures.get(selectedFixture).move(new int[]{0, defaultMoveDistance});
    
  else if (key == 'a' && selectedFixture > 0)
    fixtures.get(selectedFixture).move(new int[]{-defaultMoveDistance, 0});
    
  else if (key == 'd' && selectedFixture > 0)
    fixtures.get(selectedFixture).move(new int[]{defaultMoveDistance, 0});
}

int defaultMoveDistance = 10;

void keyReleased() {
  if (keyCode == ALT) {
    altHeld = false;
    defaultMoveDistance = 10;
  }
}

String editMode = "";  // "Move", "Resize", "Change default point"
int clickX, clickY;

void mousePressed() {
  //if (mouseButton == RIGHT && !textbox.show) {
  //  for (int i = 0; i < fixturePresets.size(); i++) {
  //    FixturePreset preset = fixturePresets.get(i);
  //    println(str(i) + ")", preset.name, preset.type);
  //  }
  //}
  
  if (!textbox.show) {
    if (mouseButton == RIGHT) {
      for (int i = 0; i < fixturePresets.size(); i++) {
        FixturePreset preset = fixturePresets.get(i);
        println(str(i) + ")", preset.name, preset.type);
      }
    }
    
    clickX = mouseX;
    clickY = mouseY;
    
    int tempFixture = -1;
    
    for (Fixture f : fixtures) {
      if (fixtureClicked(f, clickX, clickY)) {
        if (mouseButton == RIGHT) {
          //requiredPoints = append(requiredPoints, f.index);
          //pointsList.add(fixtures.get(f.index).defaultPoint);
          //editMode = "Add point";  // Doesn't actually do anything, just lets program know that something major was modified
          //if (selectedFixture == -1)
          //  recalculatePath();
          
          if (f.index != selectedFixture && selectedFixture != -1) {
            Fixture thisF = fixtures.get(selectedFixture);
            
            thisF.colour = f.colour;
            thisF.type = f.type;
            thisF.name = f.name;
            thisF.maxStock = f.maxStock;
            thisF.restockChance = f.restockChance;
            thisF.stock = min(thisF.stock, thisF.maxStock);
            
            return;
          }

        }
        
        else {
          if (f.index == selectedFixture) {
            if (dist(clickX, clickY, f.defaultPoint.x, f.defaultPoint.y) <= 8)
              editMode = "Change default point";
            else if (dist(clickX, clickY, f.position[0], f.position[1]) <= 12)
              editMode = "Resize";
            else
              editMode = "Move";
            
            return;
          }
          
          else if (altHeld && selectedFixture != -1) {
            fixtures.get(selectedFixture).moveTo(f);
            
            return;
          }
          
          else
            tempFixture = f.index;
        }
          
      }
    }
    //println(editMode);
    if (recalcRequired && tempFixture == -1) {
      recalculatePath();
    }
    
    editMode = "";
    modifiedFixture = selectedFixture;
    selectedFixture = tempFixture;
    
    
  }
}

int modifiedFixture;

void mouseDragged() {
  if (selectedFixture == -1)
    return;
    
  Fixture f = fixtures.get(selectedFixture);
  
  
  if (editMode.equals("Move")) {
    f.move(new int[]{mouseX - clickX, mouseY - clickY});
    
    clickX = mouseX;
    clickY = mouseY;
  }
  
  else if (editMode.equals("Resize")) {
    f.rescale(new int[]{min(mouseX, f.position[2] - 1) - f.position[0], min(mouseY, f.position[3] - 1) - f.position[1]});
  }
  
  else if (editMode.equals("Change default point")) {
    recalcRequired = true;
      
    if (f.mainSideCoords[0] == f.mainSideCoords[2]) {  // vertical main side
      f.defaultPoint.x = f.mainSideCoords[0];
      f.defaultPoint.y = max(f.position[1], min(f.position[3], mouseY));
    }
    
    else {  // horizontal main side
      f.defaultPoint.x = max(f.position[0], min(f.position[2], mouseX));
      f.defaultPoint.y = f.mainSideCoords[1];
    }
  }

}

boolean fixtureClicked(Fixture f, int clickX, int clickY) {
  if (f.position.length != 4)
    return false;
    
  int x1 = f.position[0];
  int y1 = f.position[1];
  int x2 = f.position[2];
  int y2 = f.position[3];
  
  return x1 <= clickX && clickX <= x2 && y1 <= clickY && clickY <= y2 || dist(clickX, clickY, f.position[0], f.position[1]) <= 12 || dist(clickX, clickY, f.defaultPoint.x, f.defaultPoint.y) <= 8;
}

void initTextbox(String label, String notes) {
  textbox.show = true;
  textbox.label = label;
  textbox.notes = notes;
  textbox.text = "";

  //while (!textEntered) {}

  //textEntered = false;
  //String text = textboxText;
  //textboxText = "";
  //return text;
}

String fixtureName = "";
void addFixture() {
  FixturePreset preset = fixturePresets.get(presetIndex);
  
  if (preset.name.equals("Default") && fixtureName.equals("")) {
    if (textbox.text.equals("")) {
      queuedFunction = new QueuedFunction() {
        public void call() {
          addFixture();
        }
      };
      
      initTextbox("Enter fixture category:", "(e.g. 'Fruits', 'Veg', etc.)");
      return;
    }
    
    fixtureName = textbox.text;

    textbox.text = "";
  }
  
  
  if (textbox.text.equals("")) {
    queuedFunction = new QueuedFunction() {
      public void call() {
        addFixture();
      }
    };
    
    initTextbox("Enter fixture's products:", "(separate with dashes)");
    return;
  }
  
  String[] prods = split(textbox.text, "-");
  
  if (preset.name.equals("Default"))
    preset.newFixture(new int[]{325, 225, 475, 375}, new int[]{325, 225, 475, 225}, fixtureName, prods);
  else
    preset.newFixture(new int[]{325, 225, 475, 375}, new int[]{325, 225, 475, 225}, prods);
    
  selectedFixture = fixtures.size() - 1;
  obstacles.add(fixtures.get(selectedFixture).position);
  
  //println("New fixture added successfully! Save and restart the program to reiterate through your shopping list.");
  checkShoppingList();
  
  textbox.text = "";
  fixtureName = "";
  recalcRequired = true;;  // Doesn't do anything except let program know that major change has happened
}

void renameFixture() {
  if (selectedFixture == -1)
    return;
    
  Fixture f = fixtures.get(selectedFixture);
    
  if (textbox.text.equals("")) {
    queuedFunction = new QueuedFunction() {
      public void call() {
        renameFixture();
      }
    };
    
    initTextbox("New Name:", "");
    return;
  }
  
  f.name = textbox.text;
  
  textbox.text = "";
}

void deleteLastFixture() {
  //if (fixtures.size() == 2)
  //  return;
    
  //PVector pointToRemove = fixtures.get(selectedFixture).defaultPoint;
  //for (int i = 0; i < pointsList.size(); i++) {
  //  if (pointsList.get(i).equals(pointToRemove)) {
  //    pointsList.remove(i);
  //    break;
  //  }
  //}
  
  //for (int i = 0; i < requiredPoints.length; i++) {
  //  if (requiredPoints[i] == selectedFixture) {
  //    println(requiredPoints);
  //    requiredPoints = concat(subset(requiredPoints, 0, selectedFixture), subset(requiredPoints, selectedFixture + 1));
  //    println(requiredPoints);
  //  }
  //}
  
  ////println(fixtures.get(selectedFixture).position);
  //fixtures.remove(fixtures.size() - 1);
  ////println(obstacles.get(selectedFixture - 2));
  //obstacles.remove(obstacles.size() - 1);
  //selectedFixture = -1;
  
  //recalcRequired = true;  // Let program know that recalculation is required
  ////todo: call recheck shopping list, no need to go through and delete requiredPoints / pointsList elements
  //checkShoppingList();
}

void addProducts() {
  if (selectedFixture == -1)
    return;
    
  Fixture f = fixtures.get(selectedFixture);
    
  if (textbox.text.equals("")) {
    queuedFunction = new QueuedFunction() {
      public void call() {
        addProducts();
      }
    };
    
    initTextbox("Additional Products:", "(separate with dashes)");
    return;
  }
  
  String[] newProds = split(textbox.text, "-");
  
  f.products = concat(f.products, newProds);
  //println("Store inventory updated successfully! Save and restart the program to reiterate through your shopping list.");
  checkShoppingList();
  
  textbox.text = "";
}

void reenterProducts() {
  if (selectedFixture == -1)
    return;
    
  Fixture f = fixtures.get(selectedFixture);
    
  if (textbox.text.equals("")) {
    queuedFunction = new QueuedFunction() {
      public void call() {
        reenterProducts();
      }
    };
    
    initTextbox("Products:", "(separate with dashes)");
    return;
  }
  
  String[] newProds = split(textbox.text, "-");
  printArray(newProds);
  
  f.products = newProds;
  //println("Store inventory updated successfully! Restart the program to recheck your shopping list.");
  checkShoppingList();
  
  textbox.text = "";
}

void changeFixtureColour(String mode) {
  if (selectedFixture == -1)
    return;
    
  Fixture f = fixtures.get(selectedFixture);
    
  if (mode.equals("Random")) {
    if (f.type.equals("Custom"))
      f.colour = new PVector(round(random(0, 255)), round(random(0, 255)), round(random(0, 255)));
      
    else {
      f.colour.x = round(random(0, 255));
      f.colour.y = round(random(0, 255));
      f.colour.z = round(random(0, 255));
    }
  }
    
  else {
    if (textbox.text.equals("")) {
      queuedFunction = new QueuedFunction() {
        public void call() {
          changeFixtureColour("Custom");
        }
      };
      
      initTextbox("Enter new RGB:", "(separate values with commas)");
      return;
    }
    
    int[] rgb = int(splitTokens(textbox.text, ", "));
    
    while (rgb.length < 3)
      rgb = append(rgb, 0);
      
      
    if (f.type.equals("Custom"))
      f.colour = new PVector(rgb[0], rgb[1], rgb[2]);
      
    else {
      f.colour.x = rgb[0];
      f.colour.y = rgb[1];
      f.colour.z = rgb[2];
    }
    
    textbox.text = "";
  }
}

void saveStore() {
  queuedFunction = null;
  if (!loaded) {
    if (storeName.equals("Untitled") && textbox.text.equals("")) {
      // Store saveStore() function in a general QueuedFunction object
      // When user enters text into a textbox, the program will just call whatever function is stored in object instead of checking booleans for each possible function
      queuedFunction = new QueuedFunction() {
        public void call() {
          saveStore();
        }
      };
      
      initTextbox("Store Name:", "");
      return;
    }

    storeName = textbox.text;  // should prompt user to enter a name
    textbox.text = "";


    if (in(storeNames, storeName)) {
      //println(storeName);
      println("Store already exists! Please choose a different name.");
      
      queuedFunction = new QueuedFunction() {
        public void call() {
          saveStore();
        }
      };
      
      initTextbox("Store Name:", "");
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

    PVector c = fixtures.get(i).colour;
    outputs[10].println(str(c.x) + "," + str(c.y) + "," + str(c.z));

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
    PVector currColour = new PVector(rgb[0], rgb[1], rgb[2]);

    float[] defPointCoords = float(split(defPoints[row], ","));
    PVector currDefaultPoint = new PVector(defPointCoords[0], defPointCoords[1]);


    allDistances[row] = currDists;
    optimalPaths[row] = currPaths;
    
    for (FixturePreset fp : fixturePresets) {
      if (fp.type.equals(currType) && fp.name.equals(currName))
        currColour = fp.colour;  // link the pvectors together
    }

    fixtures.add(new Fixture(currCoords, currMainSides, currType, currName, currProducts, currMaxStock, currRestockChance, currColour, currDefaultPoint));
  }
}
