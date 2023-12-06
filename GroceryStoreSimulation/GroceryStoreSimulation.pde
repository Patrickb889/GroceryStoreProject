// File data arrays
String[] storeNames;


class QueuedFunction {
  void call() {}
}

QueuedFunction queuedFunction = null;

String pathAccuracy = "Approx";  //"Approx" or "Accurate"

PVector entrance = new PVector(150, 590);
PVector exit = new PVector(300, 590);
float userSpeed = 1;
ArrayList<String> importedList = new ArrayList<String>();

ArrayList<Shopper> shoppers = new ArrayList<Shopper>();

ArrayList<Fixture> fixtures = new ArrayList<Fixture>();
ArrayList<FixturePreset> fixturePresets = new ArrayList<FixturePreset>();

ArrayList<int[]> obstacles = new ArrayList<int[]>();

String[] shoppingList;

boolean showOtherShoppers = true;

void setup() {
  size(800, 600);
  frameRate(40);
  
  storeNames = loadStrings("Stores/store_names.txt");
  shoppingList = loadStrings("ShoppingList/shopping_list.txt");
  
  if (shoppingList == null) {
    println("No shopping list found! To make a shopping list, enter your items into a text file with each individual item on a new line. Name this file 'shopping_list' and place it in the folder called 'ShoppingList'");
    shoppingList = new String[]{};
  }
  
  //pointsList = new PVector[shoppingList.length + 2];
  //listPointFixtureIndices = new int[shoppingList.length + 2];
  
  fill(0);
  textSize(30);
  textAlign(CENTER, CENTER);
  text("Loading...", 400, 275);
  textSize(15);
  text("(First time will be slower)", 390, 325);
  
  if (showOtherShoppers) {
    for (int i = 0; i < 5; i++) {
      shoppers.add(new Shopper(entrance.x, entrance.y, random(0.5, 2), importedList));
    }
  }
  
  fixturePresets.add(new FixturePreset("Display", "Fruit", 200, 1/(frameRate*10), new PVector(255, 255, 0)));
  fixturePresets.add(new FixturePreset("Display", "Veg", 200, 1/(frameRate*10), new PVector(100, 255, 0)));
  fixturePresets.add(new FixturePreset("Shelf", "Veg", 400, 1/(frameRate*10), new PVector(100, 255, 0)));
  fixturePresets.add(new FixturePreset("Fridge", "Dairy", 30, 1/(frameRate*20), new PVector(200, 200, 255)));
  fixturePresets.add(new FixturePreset("Fridge", "Meat", 50, 1/(frameRate*15), new PVector(255, 0, 0)));
  fixturePresets.add(new FixturePreset("Display", "Pastries", 20, 1/(frameRate*30), new PVector(177, 137, 75)));
  fixturePresets.add(new FixturePreset("Counter", 1, 0, new PVector(0, 255, 100)));
  fixturePresets.add(new FixturePreset("Custom", 200, 1/(frameRate*10), new PVector(255, 255, 255)));  //todo: create sliders to adjust maxStock and restockChance for any selected fixture
  
  //int[] p, int[] msc, String t, String n, String[] ctgs, color c
  //fixtures.add(new Fixture(entrance));
  //fixtures.add(new Fixture(exit));
  //1,484,522,540
  //328,196,478,346
  //3,155,61,413
  //fixturePresets.get(2).newFixture(new int[]{3,155,61,413}, new int[]{61,155,61,413}, new String[]{"Carrots"});
  //fixturePresets.get(0).newFixture(new int[]{328,196,478,346}, new int[]{328,346,478,346}, new String[]{"Oranges"});
  //fixturePresets.get(5).newFixture(new int[]{1,484,522,540}, new int[]{1,540,522,540}, new String[]{"cake"});
  //fixtures.get(2).defaultPoint = new PVector(61, 300);
  //fixtures.get(3).defaultPoint = new PVector(440, 346);
  //fixtures.get(4).defaultPoint = new PVector(270, 540);
  //fixturePresets.get(6).newFixture(new int[]{675, 100, 725, 500}, new int[]{675, 100, 675, 500}, "Pharmacy", new String[]{"Medicine"});
  //fixturePresets.get(0).newFixture(new int[]{75, 250, 200, 375}, new int[]{75, 250, 200, 250}, new String[]{"Oranges", "Apples", "Bananas", "Canteloupes"});
  //fixturePresets.get(1).newFixture(new int[]{75, 395, 200, 520}, new int[]{75, 395, 200, 395}, new String[]{"Cabbage", "Lettuce", "Broccoli", "Caufliflower"});
  //fixturePresets.get(2).newFixture(new int[]{0, 100, 25, 300}, new int[]{25, 100, 25, 300}, new String[]{"Green beans", "Green onion", "Ginger", "Radish", "Spinach", "Carrots"});
  //fixturePresets.get(3).newFixture(new int[]{0, 320, 35, 599}, new int[]{35, 320, 35, 599}, new String[]{"Milk", "Yogurt", "Cheese", "Butter", "Ice cream"});
  //fixturePresets.get(4).newFixture(new int[]{200, 565, 790, 599}, new int[]{200, 565, 790, 565}, new String[]{"Ground beef", "Steak", "Chicken wings", "Porkchops", "Kebabs", "Eggs"});
  //fixturePresets.get(5).newFixture(new int[]{290, 390, 390, 500}, new int[]{290, 390, 390, 390}, new String[]{"Cookies", "Muffins", "Cupcakes", "Bread", "Brownies", "Pie", "Cake"});
  load("Shoppers");  //demo saved store
  //obstacles = new int[fixtures.size()-2][4];
  //for (Fixture f : fixtures)
  //  println(f.stock, f.maxStock, f.urgency, f.type);
  for (int i = 2; i < fixtures.size(); i++) {
    obstacles.add(fixtures.get(i).position);
  }
  
  checkShoppingList("Initial");
  //pointsList.add(entrance);
  //pointsList.add(exit);
  //listPointFixtureIndices[0] = 0;
  //listPointFixtureIndices[listPointFixtureIndices.length-1] = 1;
  //for (int i = 0; i < shoppingList.length; i++) {
  //  PVector pos = findPosition(shoppingList[i]);
    
  //  if (pos.x != -1) {
  //    pointsList.add(pos);
  //    listPointFixtureIndices[i+1] = int(pos.z);
  //  }
    
  //  else {  // if pos.x is -1, then the function was unable to find the item in any of the fixtures
  //    println("Sorry,", "'" + shoppingList[i] + "'", "is not a product in this store. Perhaps you made a typo in your shopping list?");
  //    //pointsList[i+1] = pointsList[i];
  //    listPointFixtureIndices[i+1] = listPointFixtureIndices[i];
  //  }
      
  //}
  
  //fixtureCounter = new boolean[fixtures.size()];
  //requiredPoints = new int[0];
  //for (int i = 1; i < listPointFixtureIndices.length - 1; i++) {
  //  int fixtureIndex = listPointFixtureIndices[i];
    
  //  if (!fixtureCounter[fixtureIndex] && fixtureIndex > 1) {
  //    fixtureCounter[fixtureIndex] = true;
  //    requiredPoints = append(requiredPoints, fixtureIndex);
  //  }
  //}
  
  if (loaded) {
    recalcRequired = false;
    
    for (int pathLength = 0; pathLength < requiredPoints.length - 1; pathLength++) {  // only pointsList.size() - 1 iterations because between the last two points not counting the exit, if one is chosen, the other has to be last (no need to check what is already known)
      search(pathLength);
    }
    
    fullPath = concat(new int[]{0}, append(requiredPoints, 1));
    
    pathFound = true;
  }
  
  else {
    int numFixtures = fixtures.size();
    
    allDistances = new float[numFixtures][numFixtures];
    optimalPaths = new String[numFixtures][numFixtures];
    
    //allDistances[0][1] = dist(entrance.x, entrance.y, exit.x, exit.y);
    //optimalPaths[0][1] = "1-0";
  }
  
}

boolean pathCalculated = pathAccuracy.equals("Approx");
boolean pathFound = false;

boolean[] fixtureCounter;  // keeps track of all the fixtures that need to be visited in the path
ArrayList<ArrayList<int[]>> paths = new ArrayList<ArrayList<int[]>>();
//String[] shoppingList = {"Carrots", "Bananas", "Milk", "Butter", "Cake", "Eggs", "Medicine"};
ArrayList<PVector> pointsList = new ArrayList<PVector>();
int[] listPointFixtureIndices;  // index of fixture the point is associated with (but +2 so that entrance and exit can be 0 and 1
int[] requiredPoints;
int[] fullPath;


PVector findPosition(String item) {
  for (Fixture f : fixtures) {
    for (String product : f.products) {
      if (product.toLowerCase().equals(item.toLowerCase())) {
        PVector position = f.defaultPoint;
        position.z = f.index;
        return f.defaultPoint;
      }
    }
  }
  return new PVector(-1, -1);
}

//todo: fix undefined slope or 0 slope cases for intersection checking(done)
//todo: instead of using PVector array for obstacles, create each as a fixture object and store in ArrayList<Fixture>(done)

void draw() {
  background(173, 176, 186);
  
  fill(255, 0, 0);
  stroke(0);
  strokeWeight(1);
  for (Fixture f : fixtures)
    f.drawMe();
  //println(pathCalculated);
  if (pathCalculated && selectedFixture == -1) {
    if (!pathFound) {
      for (int pathLength = 0; pathLength < requiredPoints.length - 1; pathLength++) {  // only pointsList.size() - 1 iterations because between the last two points not counting the exit, if one is chosen, the other has to be last (no need to check what is already known)
        search(pathLength);
      }
      
      pathFound = true;
      
      fullPath = concat(new int[]{0}, append(requiredPoints, 1));
      
      if (requiredPoints.length == 0)
        updatePathInfo(0, 1);
        
      else if (requiredPoints.length == 1) {
        updatePathInfo(0, requiredPoints[0]);
        updatePathInfo(1, requiredPoints[0]);
      }
    }
  
    stroke(0, 150, 255);
    strokeWeight(3);

    for (int pointIndex = 1; pointIndex < fullPath.length; pointIndex++) {
      int ind1 = fullPath[pointIndex-1];
      int ind2 = fullPath[pointIndex];
      //println(ind1, ind2);
      String stringPath = optimalPaths[min(ind1, ind2)][max(ind1, ind2)];
      int[] path = int(split(stringPath, "-"));
      
      for (int i = 1; i < path.length; i++) {
        int i1 = path[i-1];
        int i2 = path[i];
        PVector p1;
        PVector p2;
        
        
        p1 = pointCoords(i1);
        p2 = pointCoords(i2);
          
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
    for (PVector point : pointsList)
      circle(point.x, point.y, 8);
  } //<>// //<>// //<>//

  stroke(0);
  strokeWeight(1);
  
  fill(0, 255, 0);
  circle(entrance.x, entrance.y, 10);
  
  fill(255, 0, 0);
  circle(exit.x, exit.y, 10);

  if (textbox.show) {
    stroke(0);
    strokeWeight(3);
    fill(200);
    rect(300, 250, 200, 100);
    strokeWeight(1);
    fill(255);
    rect(320, 290, 160, 20);
    fill(0);
    textSize(12);
    textAlign(LEFT, CENTER);
    text(textbox.label, 320, 275);
    
    if (frameCount/30 % 2 == 0)
      cursor = "|";
    else
      cursor = "";
      
    text(textbox.text + cursor, 325, 300);
    
    textAlign(CENTER, CENTER);
    text(textbox.notes, 400, 325);
  }
  // todo (fix):
  //pathFind(new PVector(700, 500), new PVector(round(random(0, 100)), round(random(0, 599))));
  //shortestDistancesCopy = new float[obstacles.length * 4 + 1][2];
  //for (int i = 0; i < shortestDistances.length; i++) {
  //  for (int j = 0; j < 2; j++)
  //    shortestDistancesCopy[i][j] = shortestDistances[i][j];
  //}
  
  
  //println(pathCalculated, pathAccuracy.equals("Accurate"));
  if (!pathCalculated && pathAccuracy.equals("Accurate")) {
    //println("AA");
    //todo: fixture class implement(done)
    //todo: file stuff (need to store objects and distances as well as paths)(done)
    //todo: figure out way to store distances and paths(done)
    //todo: tsp greedy approximation(done)
    //todo: give each fixture an urgency factor based on stock of its items (priority gets multiplied by urgency to determine new priority)(done)
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
    //  boolean loaded(done)
    //  when user loads in store, store name is stored and loaded set to true(done)
    //  when user hits save, if loaded is false, will be prompted for a name (done)
    //  name will then be saved to file in same folder as program(done)
    //  store info will be saved to folder with same name as store(done)
    //todo: function that converts corner index to coords(done)
    //user contols done
    //next todo: speed up recalculation, give other shoppers simple path finding
    
    int numFixtures = fixtures.size();
    allDistances = new float[numFixtures][numFixtures];
    optimalPaths = new String[numFixtures][numFixtures];

    for (int i = 0; i < numFixtures; i++) {
      for (int j = i+1; j < numFixtures; j++) { //<>// //<>//
        PVector p1 = fixtures.get(i).defaultPoint;
        PVector p2 = fixtures.get(j).defaultPoint;
        
        String[] pathInfo = pathFind(p1, p2, i, j);
        
        allDistances[i][j] = float(pathInfo[0]);
        optimalPaths[i][j] = pathInfo[1];
      }
    }

    
    pathCalculated = true;
  }
  
  for (Shopper s : shoppers) {
    s.updateMe();
    s.drawMe();
  }
  
}
