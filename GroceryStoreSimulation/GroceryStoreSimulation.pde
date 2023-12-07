// Names of all saved stores which will be pulled from a file
String[] storeNames;

// Blank template class which will be used to store specific functions in a general object
class QueuedFunction {
  void call() {}
}

QueuedFunction queuedFunction = null;  // Initialize that general object

String pathAccuracy = "Approx";  // "Approx" or "Accurate"
                                 // For approx, path searching function will just assume distances between points as the length of the straight line segment connecting them
                                 // For accurate, the exact distances of the shortest paths which avoid all obstacles are calculated first (much slower)

PVector entrance = new PVector(150, 590);  // Default entrance coords, can be modified by the user
PVector exit = new PVector(300, 590);  // Default exit coords, can be modified

float userSpeed = 1;  // Speed of the guy walking along the path

ArrayList<Shopper> shoppers = new ArrayList<Shopper>();  // List of other shoppers

ArrayList<Fixture> fixtures = new ArrayList<Fixture>();  // List of all fixtures in the store
ArrayList<FixturePreset> fixturePresets = new ArrayList<FixturePreset>();  // List of all fixture presets that the user can use to make their fixtures

ArrayList<int[]> obstacles = new ArrayList<int[]>();  // List containing coordinates of all obstacles (all the fixture coordinates)

String[] shoppingList;  // Imported shopping list from the user

boolean showOtherShoppers = false;  // Whether or not to animate the other shoppers
int numShoppers = 5;

boolean pathCalculated = pathAccuracy.equals("Approx");  // When pathCalculated is false, the program will calculate the best path between every single pair of fixtures (approx mode does not need this so it would be set to true)
boolean pathFound = false;  // Indicates whether or not an overall path (not the paths between fixtures) has been calculated

boolean[] fixtureCounter;  // Keeps track of all the fixtures that have been accounted for already when checking which fixtures need to be visited
ArrayList<ArrayList<int[]>> paths = new ArrayList<ArrayList<int[]>>();  // Stores every complete path (stored as indices of all points passed) between two points found by the pathfinding function
                                                                        // Technically 2D, int[] is just there because ArrayList<int> doesn't exist

ArrayList<PVector> pointsList = new ArrayList<PVector>();  // Used to draw circles at all major points in the path

int[] listPointFixtureIndices;  // Indidices of all fixtures that need to be visited according to shopping list (contains repeated indices)
int[] requiredPoints;  // Same as above but does not contain repeats
int[] fullPath;  // Used to draw the complete path from entrance to exit

void setup() {
  size(800, 600);
  
  // Load in store names and shopping list items
  storeNames = loadStrings("Stores/store_names.txt");
  shoppingList = loadStrings("ShoppingList/shopping_list.txt");
  
  // In case the user has not added a shopping list, or put it in the wrong place, or named it incorrectly
  if (shoppingList == null) {
    println("No shopping list found! To make a shopping list, enter your items into a text file with each individual item on a new line. Name this file 'shopping_list' and place it in the folder called 'ShoppingList'");
    shoppingList = new String[]{};  // Blank shopping list, program will not calculate path
  }
  
  // Loading message in case it takes a while to start up
  fill(0);
  textSize(30);
  textAlign(CENTER, CENTER);
  text("Loading...", 400, 275);
  
  // Initialize indicated number of shoppers if user wants to see other shoppers
  if (showOtherShoppers) {
    for (int i = 0; i < 5; i++) {
      shoppers.add(new Shopper(entrance.x, entrance.y, random(0.5, 2)));
    }
  }
  
  // Hard-coded fixture presets (cannot be modified by the user unless they change the code)
  // (fixture type, product category, maximum stock, restock chance, colour)
  fixturePresets.add(new FixturePreset("Display", "Fruit", 200, 1/(frameRate*10), new PVector(255, 255, 0)));  // Colours are set as PVectors because this allows the colours of a preset and all its fixtures to be linked
  fixturePresets.add(new FixturePreset("Display", "Veg", 200, 1/(frameRate*10), new PVector(100, 255, 0)));
  fixturePresets.add(new FixturePreset("Shelf", "Veg", 400, 1/(frameRate*10), new PVector(100, 255, 0)));
  fixturePresets.add(new FixturePreset("Fridge", "Dairy", 30, 1/(frameRate*20), new PVector(200, 200, 255)));
  fixturePresets.add(new FixturePreset("Fridge", "Meat", 50, 1/(frameRate*15), new PVector(255, 0, 0)));
  fixturePresets.add(new FixturePreset("Display", "Pastries", 20, 1/(frameRate*30), new PVector(177, 137, 75)));
  fixturePresets.add(new FixturePreset("Counter", 1, 0, new PVector(0, 255, 100)));
  fixturePresets.add(new FixturePreset("Custom", 200, 1/(frameRate*10), new PVector(255, 255, 255)));  //todo: create sliders to adjust maxStock and restockChance for any selected fixture
  //todo: if not doing shopper pathing, take out restock chance
  
  // Program starts with nothing but an entrance and an exit (user can add things to the store, or load a saved store)
  fixtures.add(new Fixture(entrance));
  fixtures.add(new Fixture(exit));
  
  load("Shoppers");  //demo saved store//todo: change this to gui
  
  if (!loaded)
    checkShoppingList("Initial");  // Check user's shopping list to figure out which fixtures need visiting
                                   // The function checks the previous amount of fixtures that needed visiting to determine whether or not the path had to be recalculated so "Initial" just tells the function not to do this
}


void draw() {
  background(173, 176, 186);
  
  
  // Draw all fixtures
  for (Fixture f : fixtures)
    f.drawMe();
    
  // Draws the final path if calculation is finished
  // Only done if no fixture is being selected for editing (when selectedFixture == -1)
  if (pathCalculated && selectedFixture == -1) {
    // Second step of path calculation: after distance and paths between pairs of fixtures have been calculated, calculate the best path through all the required points
    if (!pathFound) {
      for (int pathLength = 0; pathLength < requiredPoints.length - 1; pathLength++) {  // only requiredPoints.size() - 1 iterations because between the last two points not counting the exit, if one is chosen, the other has to be last (no need to check what is already known)
        search(pathLength);  // Changes order of points in requiredPoints based on order of points in the optimal path
      }
      
      pathFound = true;  // Set pathFound to true so no unnecessary calculations are done
      fullPath = concat(new int[]{0}, append(requiredPoints, 1));  // Add entrane and exit coords to list of points (which would have been ordered properly by the search function)
      
      // For approx mode, paths between two points is only calculated between adjacent points in terms of order in the path
      // However, due to the fact that only requiredPoints.length - 1 iterations are done, requiredPoints lists with length 0 (no fixtures in the store) or 1 (one fixture in the store) do not end up having the required paths calculated
      // Therefore, these exceptions need to be caught with an if statement here
      if (pathAccuracy.equals("Approx")) {
        if (requiredPoints.length == 0)
          updatePathInfo(0, 1);
          
        else if (requiredPoints.length == 1) {
          updatePathInfo(0, requiredPoints[0]);
          updatePathInfo(1, requiredPoints[0]);
        }
      }
    }
  
    stroke(0, 150, 255);  // Colour of lines in the path
    strokeWeight(3);
    
    // Draw the lines in the path
    for (int pointIndex = 1; pointIndex < fullPath.length; pointIndex++) {
      int ind1 = fullPath[pointIndex-1];  // Indices of the two fixtures the path segments is being drawn between
      int ind2 = fullPath[pointIndex];
      
      // Pull the path between the two points found previously from the 2D array it would be stored in
      String stringPath = optimalPaths[min(ind1, ind2)][max(ind1, ind2)];
      // Just in case there is an error and a path ends up not getting calculated (this allows the program to just not draw it instead of crashing)
      if (stringPath == null)
        continue;
      
      int[] path = int(split(stringPath, "-"));  // Gets indices of all intermediate corners passed in the path
                                                 // Indices at start and end are indices of the fixtures the path is between, intermediate indices are the indices of the corners passed (obstacle index + 0/1/2/3 based on which corner it is)
      
      // Once all indices have been obtained, iterate through each adjacent pair of points in the path
      for (int i = 1; i < path.length; i++) {
        int i1 = path[i-1];
        int i2 = path[i];
        PVector p1;
        PVector p2;
        
        // Gets coordinates of points using the indices
        p1 = pointCoords(i1);
        p2 = pointCoords(i2);
          
        // Get actual coords of point if it is the starting or ending fixture's point (point indices are different from fixture indices)
        if (i == 1)
          p1 = fixtures.get(i1).defaultPoint;
        
        if (i == path.length - 1)
          p2 = fixtures.get(i2).defaultPoint;
        
        
        line(p1.x, p1.y, p2.x, p2.y);
      }
    }
    
    
    fill(0, 0, 255);
    stroke(0);
    strokeWeight(1);
    
    // Draw the major points (points where the user would grab an item) in the path
    for (PVector point : pointsList)
      circle(point.x, point.y, 8);
  } //<>//

  stroke(0);
  strokeWeight(1);
  
  // Green dot at entrance point
  fill(0, 255, 0);
  circle(entrance.x, entrance.y, 10);
  
  // Red dot at exit point
  fill(255, 0, 0);
  circle(exit.x, exit.y, 10);

  // Draw textbox if needed
  if (textbox.show) {
    stroke(0);
    strokeWeight(3);
    fill(200);
    rect(300, 250, 200, 100);  // Grey background box
    
    strokeWeight(1);
    fill(255);
    rect(320, 290, 160, 20);  // White text entering area
    
    fill(0);
    textSize(12);
    textAlign(LEFT, CENTER);
    text(textbox.label, 320, 275);  // Prompt for what the user should be entering
    
    // Cursor which disappears and reappears every 30 frames
    if (frameCount/30 % 2 == 0)
      cursor = "|";
    else
      cursor = "";
      
    text(textbox.text + cursor, 325, 300);  // The text entered so far
    
    textAlign(CENTER, CENTER);
    text(textbox.notes, 400, 325);  // Additional instructions for the user
  }
  
  // todo (fix)://todo: keep for now but delete before submitting if not used
  //pathFind(new PVector(700, 500), new PVector(round(random(0, 100)), round(random(0, 599))));
  //shortestDistancesCopy = new float[obstacles.length * 4 + 1][2];
  //for (int i = 0; i < shortestDistances.length; i++) {
  //  for (int j = 0; j < 2; j++)
  //    shortestDistancesCopy[i][j] = shortestDistances[i][j];
  //}
  
  
  // Show additional information for selected fixture
  if (showFixtureInfo) {
    Fixture f = fixtures.get(selectedFixture);
    
    stroke(0);
    strokeWeight(0);
    fill(0, 0, 0, 200);
    rect(0, 0, width, 150);  // Semi transparent black background rectangle
    
    fill(255);
    textAlign(LEFT, CENTER);
    textSize(20);
    text("Fixture Type: " + f.type, 20, 20);
    text("Product/Service Type: " + f.name, 20, 50);
    text("Products Available: " + join(f.products, ", "), 20, 80);
    text("Current Stock: " + f.stock + "/" + f.maxStock, 20, 110);
    
  }
  
  if (!pathCalculated && pathAccuracy.equals("Accurate")) {
    //todo: use for user manual then delete
    //todo: customization (when fixture moved or resized or rotated, obstacles and pointsList need to be updated as well an pathCalculated should be set to false)
    //      click on fixture to select, when selected, default edge will be highlighted in diff colour and with thicker line, top left corner will have circle around it, also default point with have circle around it (default point circle will be diff colour)
    //      click on main body to set move to true, on top left to set resize to true, on default point to set moveDefaultPoint to true
    //      when moveDefaultPoint true, if main side horizontal, default point x follows mouseX as long as in bounds of main side, if main side vert, same but with y
    //      right to rotate clockwise 90 deg (centreX + (point.y - centreY), centreY + (point.x - centreX)), update default edge (it will still be the same points around the edge)
    //      left to rotate counterclockwise 90 deg (centreX - (point.y - centreY), centreY - (point.x - centreX)
    //      click on main body and drag to move (all x and y shift by mouseX - prevMouseX or mouseY - prevMouseY)
    //      click near top left corner (within certain radius) and drag to resize (top left corner x and y changed to mouseX and mouseY, top right corner y changed to mouseY, bottom left corner x changed to mouseX)
    //      everything is recalculated (pathCalculated set to false, relevant lists updated) when deselected (when click on background) and when text has been entered into popup box
    //  pre gui: rmb to bring up fixture options (just text showing which button for which fixture type)(done)
    //  num key creates new fixture with random coords and main side and auto selects it(done)
    //  box will then pop up and user can enter products for the fixture (item names can have spaces but separate items with a dash and no space)(done)
    //  c to change to random colour(done)
    //  C to change to custom rgb value (same entering mechanism as items, separate values by a dash with no space)(done)
    //next todo: speed up recalculation, give other shoppers simple path finding
    
    // Initialize 2D arrays for storing distances and paths between pairs of points
    int numFixtures = fixtures.size();
    allDistances = new float[numFixtures][numFixtures];
    optimalPaths = new String[numFixtures][numFixtures];

    // Calculate path and distance of path between each pair of fixtures in the store
    for (int i = 0; i < numFixtures; i++) {
      for (int j = i+1; j < numFixtures; j++) { //<>//
        // Each fixture has a default point which can be changed by the user
        PVector p1 = fixtures.get(i).defaultPoint;
        PVector p2 = fixtures.get(j).defaultPoint;
        
        String[] pathInfo = pathFind(p1, p2, i, j);  // Get the path info from pathFind() function
        
        // Store info acquired
        allDistances[i][j] = float(pathInfo[0]);
        optimalPaths[i][j] = pathInfo[1];
      }
    }

    
    pathCalculated = true;  // Set to true so no unnecessary calculations are done
  }
  
  // Update and draw npc shoppers
  for (Shopper s : shoppers) {
    s.updateMe();
    s.drawMe();
  }
  
}
