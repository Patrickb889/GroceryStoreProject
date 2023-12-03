// File data arrays
String[] storeNames;


//float enteranceX = 0;
//float enteranceY = 0;
PVector entrance = new PVector(0, 0);
PVector exit = new PVector(100, 0);
float userSpeed = 1;
ArrayList<String> importedList = new ArrayList<String>();

ArrayList<Shopper> shoppers = new ArrayList<Shopper>();
//Shopper shopper = new Shopper(entrance.x, entrance.y, userSpeed, importedList);

ArrayList<Fixture> fixtures = new ArrayList<Fixture>();
ArrayList<FixturePreset> fixturePresets = new ArrayList<FixturePreset>();

int[][] obstacles = new int[0][4];
//int[][] obstacles = new int[][]{new int[]{675, 100, 700, 500}, new int[]{75, 250, 200, 375}, new int[]{75, 395, 200, 520}, new int[]{0, 100, 25, 300}, new int[]{0, 320, 35, 599}, new int[]{200, 565, 790, 599}, new int[]{150, 170, 280, 180}, new int[]{395, 365, 430, 475}, new int[]{300, 100, 310, 350}, new int[]{320, 100, 330, 350}, new int[]{340, 100, 350, 350}, new int[]{360, 100, 370, 350}, new int[]{380, 100, 390, 350}, new int[]{400, 100, 410, 350}, new int[]{450, 250, 550, 450}, new int[]{290, 390, 390, 500}, new int[]{250, 200, 260, 400}};

void setup() {
  size(800, 600);
  frameRate(40);
  
  storeNames = loadStrings("store_names.txt");
  
  fill(0);
  textSize(30);
  textAlign(CENTER);
  text("Loading...", 400, 300);
  
  for (int i = 0; i < 5; i++) {
    shoppers.add(new Shopper(entrance.x, entrance.y, random(0.5, 2), importedList));
  }
  
  fixturePresets.add(new FixturePreset("Display", "Fruit", color(255, 255, 0)));
  fixturePresets.add(new FixturePreset("Display", "Veggies (Display)", color(100, 255, 0)));
  fixturePresets.add(new FixturePreset("Shelf", "Veggies (Shelf)", color(100, 255, 0)));
  fixturePresets.add(new FixturePreset("Fridge", "Dairy", color(200, 200, 255)));
  fixturePresets.add(new FixturePreset("Fridge", "Meat", color(255, 0, 0)));
  fixturePresets.add(new FixturePreset("Display", "Baked Goods", color(177, 137, 75)));
  fixturePresets.add(new FixturePreset("Counter", color(0, 255, 100)));
  
  //int[] p, int[] msc, String t, String n, String[] ctgs, color c
  //fixtures.add(new Fixture(new int[]{675, 100, 725, 500}, new int[]{675, 100, 675, 500}, "Counter", "Pharmacy", new String[]{"Medicine"}, color(0, 255, 0)));
  //fixtures.add(new Fixture(new int[]{75, 250, 200, 375}, new int[]{75, 250, 200, 250}, "Display", "Fruit", new String[]{"Oranges", "Apples", "Bananas", "Canteloupes"}, color(255, 255, 0)));
  //fixtures.add(new Fixture(new int[]{75, 395, 200, 520}, new int[]{75, 520, 200, 520}, "Display", "Vegetables", new String[]{"Cabbage", "Lettuce", "Broccoli", "Caufliflower"}, color(100, 255, 0)));
  //fixtures.add(new Fixture(new int[]{0, 100, 25, 300}, new int[]{25, 100, 25, 300}, "Shelf", "Vegetacles", new String[]{"Green beans", "Green onion", "Ginger", "Radish", "Spinach"}, color(100, 255, 0)));
  //fixturePresets.get(6).newFixture(new int[]{675, 100, 725, 500}, new int[]{675, 100, 675, 500}, "Pharmacy", new String[]{"Medicine"});
  //fixturePresets.get(0).newFixture(new int[]{75, 250, 200, 375}, new int[]{75, 250, 200, 250}, new String[]{"Oranges", "Apples", "Bananas", "Canteloupes"});
  //fixturePresets.get(1).newFixture(new int[]{75, 395, 200, 520}, new int[]{75, 395, 200, 395}, new String[]{"Cabbage", "Lettuce", "Broccoli", "Caufliflower"});
  //fixturePresets.get(2).newFixture(new int[]{0, 100, 25, 300}, new int[]{25, 100, 25, 300}, new String[]{"Green beans", "Green onion", "Ginger", "Radish", "Spinach", "Carrots"});
  //fixturePresets.get(3).newFixture(new int[]{0, 320, 35, 599}, new int[]{35, 320, 35, 599}, new String[]{"Milk", "Yogurt", "Cheese", "Butter", "Ice cream"});
  //fixturePresets.get(4).newFixture(new int[]{200, 565, 790, 599}, new int[]{200, 565, 790, 565}, new String[]{"Ground beef", "Steak", "Chicken wings", "Porkchops", "Kebabs", "Eggs"});
  //fixturePresets.get(5).newFixture(new int[]{290, 390, 390, 500}, new int[]{290, 390, 390, 390}, new String[]{"Cookies", "Muffins", "Cupcakes", "Bread", "Brownies", "Pie", "Cake"});
  load("Martin");  //demo saved store
  obstacles = new int[fixtures.size()][4];
  
  for (int i = 0; i < obstacles.length; i++) {
    obstacles[i] = fixtures.get(i).position;
  }
  
  pointsList[0] = entrance;
  for (int i = 0; i < exampleShoppingList.length; i++) {
    PVector pos = findPosition(exampleShoppingList[i]);
    
    if (pos.x != -1) {
      pointsList[i+1] = pos;
    }
  }
  
}

boolean pathCalculated = false;

ArrayList<ArrayList<PVector>> paths = new ArrayList<ArrayList<PVector>>();
//PVector[] list = new PVector[]{entrance, new PVector(260, 200), new PVector(340, 225), new PVector(360, 225), new PVector(390, 390), new PVector(550, 450)};
//PVector[] list = new PVector[]{entrance, new PVector(25, 200), new PVector(75, 250), new PVector(35, 460), new PVector(260, 200), new PVector(340, 225), new PVector(360, 225), new PVector(390, 390), new PVector(550, 450), new PVector(675, 300), exit};
String[] exampleShoppingList = {"Carrots", "Bananas", "Milk", "Butter", "Cake", "Eggs", "Medicine"};
PVector[] pointsList = new PVector[exampleShoppingList.length + 1];



PVector findPosition(String item) {
  for (Fixture f : fixtures) {
    for (String product : f.products) {
      if (product.equals(item))
        return f.defaultPoint;
    }
  }
  return new PVector(-1, -1);
}

//todo: fix undefined slope or 0 slope cases for intersection checking
//todo: instead of using PVector array for obstacles, create each as a fixture object and store in ArrayList<Fixture>

void draw() {
  background(173, 176, 186);
  //user.updateMe(800, 600);
  //user.drawMe();
  
  if (showTextbox) { //<>//
    strokeWeight(3);
    fill(200);
    rect(300, 250, 200, 100);
    strokeWeight(1);
    fill(255);
    rect(320, 290, 160, 20);
    fill(0);
    textSize(12);
    textAlign(LEFT, CENTER);
    text(textboxLabel, 320, 275);
    
    if (frameCount/30 % 2 == 0)
      cursor = "|";
    else
      cursor = "";
      
    text(textboxText + cursor, 325, 300);
  }

  
  fill(255, 0, 0);
  stroke(0);
  strokeWeight(1);
  for (Fixture f : fixtures)
    f.drawMe();
    
    
  stroke(0, 150, 255);
  strokeWeight(3);
  for (ArrayList<PVector> ap : paths) {
    for (int i = 1; i < ap.size(); i++) {
      line(ap.get(i-1).x, ap.get(i-1).y, ap.get(i).x, ap.get(i).y);
    }
  }
  
  fill(0, 0, 255);
  stroke(0);
  strokeWeight(1);
  for (PVector point : pointsList)
    circle(point.x, point.y, 8);

  // todo (fix):
  //pathFind(new PVector(700, 500), new PVector(round(random(0, 100)), round(random(0, 599))));
  //shortestDistancesCopy = new float[obstacles.length * 4 + 1][2];
  //for (int i = 0; i < shortestDistances.length; i++) {
  //  for (int j = 0; j < 2; j++)
  //    shortestDistancesCopy[i][j] = shortestDistances[i][j];
  //}
  
  if (!pathCalculated) {
    //for (int i = 0; i < 10; i++) {
      //pathFind(new PVector(420, 300), new PVector(round(random(0, 100)), round(random(0, 599))));
      //pathFind(new PVector(420, 300), new PVector(round(random(0, 799)), round(random(0, 70))));
      //pathFind(new PVector(420, 300), new PVector(round(random(700, width)), round(random(0, 599))));
      //pathFind(new PVector(420, 300), new PVector(round(random(500, height)), round(random(0, 600))));
      //pathFind(new PVector(700, 500), new PVector(420, 300));
      //pathFind(new PVector(420, 300), new PVector(100, 150));
    //}
    //todo: fixture class implement
    //todo: file stuff (need to store objects and distances as well as paths)
    //todo: figure out way to store distances and paths
    //todo: customization (when fixture moved or resized or rotated, obstacles and pointsList need to be updated as well an pathCalculated should be set to false)
    //      click on fixture to select, when selected, default edge will be highlighted in diff colour and with thicker line, top left corner will have circle around it, also default point with have circle around it (default point circle will be diff colour)
    //      click on main body to set move to true, on top left to set resize to true, on default point to set moveDefaultPoint to true
    //      when moveDefaultPoint true, if main side horizontal, default point x follows mouseX as long as in bounds of main side, if main side vert, same but with y
    //      r to rotate clockwise 90 deg (centreX + (point.y - centreY), centreY + (point.x - centreX)), update default edge (it will still be the same points around the edge)
    //      R to rotate counterclockwise 90 deg (centreX - (point.y - centreY), centreY - (point.x - centreX)
    //      click on main body and drag to move (all x and y shift by mouseX - prevMouseX or mouseY - prevMouseY)
    //      click near top left corner (within certain radius) and drag to resize (top left corner x and y changed to mouseX and mouseY, top right corner y changed to mouseY, bottom left corner x changed to mouseX)
    //      everything is recalculated (pathCalculated set to false, relevant lists updated) when deselected (when click on background) and when text has been entered into popup box
    //  pre gui: rmb to bring up fixture options (just text showing which button for which fixture type)
    //  num key creates new fixture with random coords and main side and auto selects it
    //  box will then pop up and user can enter products for the fixture (item names can have spaces but separate items with a slash and no space)
    //  c to change to random colour
    //  C to change to custom rgb value (same entering mechanism as items, separate values by a slash with no space)
    //  boolean loaded
    //  when user loads in store, store name is stored and loaded set to true
    //  when user hits save, if loaded is false, will be prompted for a name (no slashes)
    //  name will then be saved to file in same folder as program
    //  store info will be saved to folder with same name as store
    //todo: function that converts corner index to coords
    for (int i = 1; i < pointsList.length; i++) {
      //for (int j = i+1; j < list.length; j++)
        pathFind(pointsList[i-1], pointsList[i]);
    }
    
    pathCalculated = true;
  }
  
  for (Shopper s : shoppers) {
    s.updateMe();
    s.drawMe();
  }
  
}
