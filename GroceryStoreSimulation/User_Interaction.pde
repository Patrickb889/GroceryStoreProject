// File data arrays //<>//
float[][] allDistances;
String[][] optimalPaths;

boolean loaded;  // Keeps track of whether a store being saved is a pre-existing one that was modified or a completely new one that was created
String storeName = "Untitled";  // Default name of new store

Textbox textbox = new Textbox();  // Initialize a Textbox object
String cursor = "";  // Either "" or "|" depending on frameCount

int selectedFixture = -1;  // -1 indicates no fixture is selected
int presetIndex;//todo: delete after gui

boolean recalcRequired = false;  // Whether or not the user has modified the store in a way that requires a recalculation of paths

boolean altHeld = false;
int defaultMoveDistance = 10;  // Number of pixels a fixture moves when using wasd keys


void keyPressed() {
  Fixture f = fixtures.get(0);
  
  if (selectedFixture != -1) {
    f = fixtures.get(selectedFixture);  // Currently selected fixture
  }
  
  // SHIFT + s
  if (key == 'S' && !textbox.show && selectedFixture == -1) {
    saveStore();
  }
  
  else if (key == 'c' && !textbox.show)
    changeFixtureColour("Random");
  
  else if (key == 'C' && !textbox.show)  // SHIFT + c
    changeFixtureColour("Custom");

  else if (keyCode == ENTER && textbox.show) {
    textbox.show = false;

    if (queuedFunction != null)
      queuedFunction.call();  // Calls whatever function required the user to enter something into a textbox (the program would have returned from that function to draw the textbox)
  }

  else if (keyCode == BACKSPACE) {
    if (textbox.show && textbox.text.length() > 0)
      textbox.text = textbox.text.substring(0, textbox.text.length() - 1);  // Removes last character entered into the textbox
    else if (!textbox.show)
      deleteLastFixture();//todo: delete if can't figure out
  }

  else if (keyCode == 0 && key != '/' && textbox.show)  // No slashes can be entered because they mess with file names
    textbox.text += str(key);
  
  else if (keyCode == LEFT && selectedFixture != -1)
    f.changeMainSide("Counterclockwise");
    
  else if (keyCode == RIGHT && selectedFixture != -1)
    f.changeMainSide("Clockwise");
    
  else if (keyCode == UP && selectedFixture != -1) {
    int increase;
    
    // Regular UP arrow increases stock by maximum 10, ALT + UP increases stock by 1
    if (altHeld)
      increase = 1;
    else
      increase = min(f.maxStock - f.stock, 10);  // Make sure stock doesn't go over maxStock
      
    f.stock += increase;
    f.urgency -= float(increase)/f.maxStock;  // 1 - (n+x)/m = 1 - (n/m + x/m) = (1 - n/m) - x/m
    
    if (!ignoreStock)  // If supply urgency is being ignored, the path would not change
      recalcRequired = true;
  }
  
  else if (keyCode == DOWN && selectedFixture != -1) {
    int decrease;
    
    if (altHeld)
      decrease = 1;
    else
      decrease = min(f.stock, 10);
      
    f.stock -= decrease;
    f.urgency += float(decrease)/f.maxStock;  // 1 - (n-x)/m = 1 - (n/m - x/m) = (1 - n/m) + x/m
    
    if (!ignoreStock)
      recalcRequired = true;
  }
  
  //todo: delete after gui
  else if ('0' <= key && key <= '9') {
    presetIndex = key - 48;
    
    addFixture();
    
  }
  
  else if (key == 'r') {
    if (altHeld) {
      int numFixtures = fixtures.size();
      allDistances = new float[numFixtures][numFixtures];
      optimalPaths = new String[numFixtures][numFixtures];
      
      recalculatePath();  // ALT + r to manually force program to recalculate path
    }
    
    else
      renameFixture();  // Regular r to rename the fixture selected
  }
    
  else if (key == 'R')  // SHIFT + r
    reenterProducts();  // Completely overwrites previous products
    
  else if (key == 'A')  // SHIFT + a
    addProducts();  // Adds new products to previous products
    
  else if (keyCode == ALT) {
    altHeld = true;
    defaultMoveDistance = 1;  // ALT + wasd moves fixture by 1 pixel instead of 10
  }
    
  else if (key == 'w' && selectedFixture > 0)  // Move up
    f.move(new int[]{0, -defaultMoveDistance});
    
  else if (key == 's' && selectedFixture > 0)  // Move down
    f.move(new int[]{0, defaultMoveDistance});
    
  else if (key == 'a' && selectedFixture > 0)  // Move left
    f.move(new int[]{-defaultMoveDistance, 0});
    
  else if (key == 'd' && selectedFixture > 0)  // Move right
    f.move(new int[]{defaultMoveDistance, 0});
    
    
  else if (key == 'V' && selectedFixture > 0) {  // SHIFT + v to duplicate the selected fixture
    // Same position, main side, type, name, max stock, restock chance, colour, and default point, but blank list of products
    fixtures.add(new Fixture(subset(f.position, 0), subset(f.mainSideCoords, 0), f.type, f.name, new String[]{}, f.maxStock, f.restockChance, f.colour, new PVector(f.defaultPoint.x, f.defaultPoint.y)));
    
    selectedFixture = fixtures.size() - 1;
    Fixture newF = fixtures.get(selectedFixture);
    
    newF.move(new int[]{10, 10});  // Move it a little so that the new fixture isn't sitting right on top of the old one
    obstacles.add(newF.position);
    
    // Prepare for path recalculation
    recalcRequired = true;
    int numFixtures = fixtures.size();
    allDistances = new float[numFixtures][numFixtures];
    optimalPaths = new String[numFixtures][numFixtures];
  }
    
}


void keyReleased() {
  if (keyCode == ALT) {
    altHeld = false;
    defaultMoveDistance = 10;
  }
}

String editMode = "";  // "Move", "Resize", "Change default point"
boolean showFixtureInfo = false;
int clickX, clickY;

void mousePressed() {
  if (!textbox.show) {
    //todo: delete after gui
    if (mouseButton == RIGHT) {
      for (int i = 0; i < fixturePresets.size(); i++) {
        FixturePreset preset = fixturePresets.get(i);
        println(str(i) + ")", preset.name, preset.type);
      }
    }
    
    // Serves as record of previous mouse coords when mouse dragged
    clickX = mouseX;
    clickY = mouseY;
    
    int tempFixture = -1;  // Old value of selectedFixture before selected fixture is changed is required so tempFixture is used to store new fixture index
    
    for (Fixture f : fixtures) {
      if (fixtureClicked(f, clickX, clickY)) {
        if (mouseButton == RIGHT) {
          if (f.index != selectedFixture && selectedFixture != -1) {  // Right clicking on another fixture copies some of its attributes over the the selected fixture
            Fixture thisF = fixtures.get(selectedFixture);
            
            thisF.colour = f.colour;
            thisF.type = f.type;
            thisF.name = f.name;
            thisF.maxStock = f.maxStock;
            thisF.restockChance = f.restockChance;
            thisF.stock = min(thisF.stock, thisF.maxStock);
          }
          
          else if (f.index == selectedFixture)  // Right clicking on selected fixture shows info about it
            showFixtureInfo = !showFixtureInfo;
            
          return;

        }
        
        else {
          if (f.index == selectedFixture) {  // Left click and drag is how user can edit a fixture's position
            if (dist(clickX, clickY, f.defaultPoint.x, f.defaultPoint.y) <= 8)
              editMode = "Change default point";
            else if (dist(clickX, clickY, f.position[0], f.position[1]) <= 12)
              editMode = "Resize";
            else
              editMode = "Move";
            
            return;
          }
          
          else if (altHeld && selectedFixture != -1) {  // ALT + left click on another fixture moves selected fixture side by side with it
            fixtures.get(selectedFixture).moveTo(f);
            
            return;
          }
          
          else  // Left click on other fixture without ALT changes selected fixture to that
            tempFixture = f.index;
        }
          
      }
    }

    // This is only reached if user clicked on background or selected another fixture
    // tempFixture == -1 means user did not select another fixture and recalculation is done if required
    if (recalcRequired && tempFixture == -1) {
      recalculatePath();
    }
    
    // Update variable values
    editMode = "";
    selectedFixture = tempFixture;
    showFixtureInfo = false;
    
  }
}


void mouseDragged() {
  if (selectedFixture == -1)  // Drag does nothing if nothing selected
    return;
    
  Fixture f = fixtures.get(selectedFixture);
  
  
  if (editMode.equals("Move")) {
    f.move(new int[]{mouseX - clickX, mouseY - clickY});
    
    // Update so that displacement can be calculated accurately next frame as well
    clickX = mouseX;
    clickY = mouseY;
  }
  
  else if (editMode.equals("Resize")) {
    f.rescale(new int[]{min(mouseX, f.position[2] - 1) - f.position[0], min(mouseY, f.position[3] - 1) - f.position[1]});
  }
  
  else if (editMode.equals("Change default point")) {
    recalcRequired = true;
    f.defPointModified = true;
      
    if (f.mainSideCoords[0] == f.mainSideCoords[2]) {  // Vertical main side
      f.defaultPoint.x = f.mainSideCoords[0];
      f.defaultPoint.y = max(f.position[1], min(f.position[3], mouseY));  // Stuck between y-values of main side
    }
    
    else {  // Horizontal main side
      f.defaultPoint.x = max(f.position[0], min(f.position[2], mouseX));  // Stuck between x-values of main side
      f.defaultPoint.y = f.mainSideCoords[1];
    }
  }

}


// Checks if a specific fixture was clicked
boolean fixtureClicked(Fixture f, int clickX, int clickY) {
  if (f.position.length != 4)  // If f is entrance or exit
    return false;
    
  int x1 = f.position[0];
  int y1 = f.position[1];
  int x2 = f.position[2];
  int y2 = f.position[3];
  
  // Click inside fixture, or within distance of resize point/default point
  return x1 <= clickX && clickX <= x2 && y1 <= clickY && clickY <= y2 || dist(clickX, clickY, f.position[0], f.position[1]) <= 12 || dist(clickX, clickY, f.defaultPoint.x, f.defaultPoint.y) <= 8;
}


// Initialize the textbox for use
void initTextbox(String label, String notes) {
  textbox.show = true;
  textbox.label = label;
  textbox.notes = notes;
  textbox.text = "";
}


// Obtains name and products from user and adds a new fixture
String fixtureName = "";
void addFixture() {
  FixturePreset preset = fixturePresets.get(presetIndex);
  
  if (preset.name.equals("Default") && fixtureName.equals("")) {
    // Store function call in object
    if (textbox.text.equals("")) {
      queuedFunction = new QueuedFunction() {
        public void call() {
          addFixture();
        }
      };
      
      initTextbox("Enter fixture category:", "(e.g. 'Fruits', 'Veg', etc.)");
      return;  // return so that textbox can be drawn
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
  
  if (preset.name.equals("Default"))  // "Default" means no name specified in preset creation
    preset.newFixture(new int[]{325, 225, 475, 375}, new int[]{325, 225, 475, 225}, fixtureName, prods);
  else
    preset.newFixture(new int[]{325, 225, 475, 375}, new int[]{325, 225, 475, 225}, prods);
    
  selectedFixture = fixtures.size() - 1;  // Select new fixture
  obstacles.add(fixtures.get(selectedFixture).position);  // Add new fixture's coords to obstacles
  
  int numFixtures = selectedFixture + 1;
  allDistances = new float[numFixtures][numFixtures];
  optimalPaths = new String[numFixtures][numFixtures];
  
  checkShoppingList();  // See if products of new fixture has changed anything
  
  textbox.text = "";
  fixtureName = "";
  recalcRequired = true;  // Doesn't do anything except let program know that major change has happened
}


// Changes name of selected fixture
void renameFixture() {
  if (selectedFixture == -1)
    return;
    
  Fixture f = fixtures.get(selectedFixture);
    
  if (textbox.text.equals("")) {
    // Store function call
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

//todo: if time, try to get delete working
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


// Adds products to selected fixture's inventory
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
  
  f.products = concat(f.products, newProds);  // concat to add instead of overwrite
  
  checkShoppingList();
  
  textbox.text = "";
}


// Overwrites current inventory of selected fixture
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
  
  f.products = newProds;
  
  checkShoppingList();
  
  textbox.text = "";
}


// Changes colour of selected fixture
void changeFixtureColour(String mode) {
  if (selectedFixture == -1)
    return;
    
  Fixture f = fixtures.get(selectedFixture);
    
  if (mode.equals("Random")) {
    if (f.type.equals("Custom"))
      f.colour = new PVector(round(random(0, 255)), round(random(0, 255)), round(random(0, 255)));  // For custom fixtures, new unlinked PVector is created
      
    else {
      // Keep link between colour of objects from same preset intact
      f.colour.x = round(random(0, 255));
      f.colour.y = round(random(0, 255));
      f.colour.z = round(random(0, 255));
    }
  }
    
  else {  // Manually change colour
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
      rgb = append(rgb, 0);  // Fill in any missing values with 0
      
      
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


// Saves all info about the store to a folder
void saveStore() {
  if (!loaded) {
    if (storeName.equals("Untitled") && textbox.text.equals("")) {
      queuedFunction = new QueuedFunction() {
        public void call() {
          saveStore();
        }
      };
      
      initTextbox("Store Name:", "");  // Get store name if store is not named
      return;
    }

    storeName = textbox.text;
    textbox.text = "";


    if (in(storeNames, storeName)) {
      println("Store already exists! Please choose a different name.");
      
      queuedFunction = new QueuedFunction() {
        public void call() {
          saveStore();
        }
      };
      
      initTextbox("Store Name:", "");  // Prompt for new name
      return;
    }

    storeNames = append(storeNames, storeName);
  }


  PrintWriter[] outputs = new PrintWriter[12];

  // Create writers for each file
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

  // Save store names to file first
  for (int i = 0; i < storeNames.length; i++) {
    outputs[0].println(storeNames[i]);
  }

  // Loop through all fixtures and store info
  for (int i = 0; i < fixtures.size(); i++) {
    outputs[1].println(join(str(allDistances[i]), ","));  // Store the distances from the current fixture to all other fixtures
    outputs[2].println(join(optimalPaths[i], ","));  // Same idea for paths
    outputs[3].println(join(str(fixtures.get(i).position), ","));
    outputs[4].println(join(str(fixtures.get(i).mainSideCoords), ","));
    outputs[5].println(fixtures.get(i).type);
    outputs[6].println(fixtures.get(i).name);
    outputs[7].println(join(fixtures.get(i).products, ","));
    outputs[8].println(str(fixtures.get(i).maxStock));
    outputs[9].println(str(fixtures.get(i).restockChance));

    // PVectors don't have join()
    PVector c = fixtures.get(i).colour;
    outputs[10].println(str(c.x) + "," + str(c.y) + "," + str(c.z));

    PVector p = fixtures.get(i).defaultPoint;
    outputs[11].println(str(p.x) + "," + str(p.y));
  }

  // Flush and close each output
  for (int i = 0; i < outputs.length; i++) {
    outputs[i].flush();
    outputs[i].close();
  }

  println("Store saved successfully!");
}


// Loads a saved store given the name
void load(String name) {
  if (!loadQueued) {
    loadQueued = true;
    return;
  }
  
  loadQueued = false;
  
  loaded = true;
  pathCalculated = true;
  storeName = name;
  
  // Reset lists in case the user had been playing around with some fixtures before loading
  fixtures = new ArrayList<Fixture>();
  obstacles = new ArrayList<int[]>();
  requiredPoints = new int[0];
  pointsList = new ArrayList<PVector>();
  listPointFixtureIndices = new int[0];
  fullPath = new int[0];
  
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

    // PVectors can't be created directly from split()
    float[] rgb = float(split(colours[row], ","));
    PVector currColour = new PVector(rgb[0], rgb[1], rgb[2]);

    float[] defPointCoords = float(split(defPoints[row], ","));
    PVector currDefaultPoint = new PVector(defPointCoords[0], defPointCoords[1]);
    
    // Set entrance and exit coords
    if (row == 0)
      entrance = currDefaultPoint;
    else if (row == 1)
      exit = currDefaultPoint;

    // Store saved distances and paths calculated in previous runs
    allDistances[row] = currDists;
    optimalPaths[row] = currPaths;
    
    for (FixturePreset fp : fixturePresets) {
      if (fp.type.equals(currType) && fp.name.equals(currName))
        currColour = fp.colour;  // Link the colour PVectors together
    }

    fixtures.add(new Fixture(currCoords, currMainSides, currType, currName, currProducts, currMaxStock, currRestockChance, currColour, currDefaultPoint));
  }
  
  // Add coordinates of all fixtures except entrance and exit into obstacles ArrayList
  for (int i = 2; i < fixtures.size(); i++) {
    obstacles.add(fixtures.get(i).position);
  }
  
  
  checkShoppingList("Initial");  // Check user's shopping list to figure out which fixtures need visiting
                                 // The function checks the previous amount of fixtures that needed visiting to determine whether or not the path had to be recalculated so "Initial" just tells the function not to do this
  
  // Calculate the path
  recalcRequired = false;
  pathFound = true;
  
  for (int pathLength = 0; pathLength < requiredPoints.length - 1; pathLength++) {  // only requiredPoints.length - 1 iterations because between the last two points not counting the exit, if one is chosen, the other has to be last (no need to check what is already known)
    search(pathLength);
  }
  
  fullPath = concat(new int[]{0}, append(requiredPoints, 1));
  
}
