//float enteranceX = 0;
//float enteranceY = 0;
PVector entrance = new PVector(0, 0); //<>//
PVector exit = new PVector(100, 0);
float userSpeed = 1;
ArrayList<String> importedList = new ArrayList<String>();

ArrayList<Shopper> shoppers = new ArrayList<Shopper>();
//Shopper shopper = new Shopper(entrance.x, entrance.y, userSpeed, importedList);

ArrayList<Fixture> fixtures = new ArrayList<Fixture>(); //<>//
ArrayList<FixturePreset> fixturePresets = new ArrayList<FixturePreset>();

int[][] obstacles = new int[0][4];
//int[][] obstacles = new int[][]{new int[]{675, 100, 700, 500}, new int[]{75, 250, 200, 375}, new int[]{75, 395, 200, 520}, new int[]{0, 100, 25, 300}, new int[]{0, 320, 35, 599}, new int[]{200, 565, 790, 599}, new int[]{150, 170, 280, 180}, new int[]{395, 365, 430, 475}, new int[]{300, 100, 310, 350}, new int[]{320, 100, 330, 350}, new int[]{340, 100, 350, 350}, new int[]{360, 100, 370, 350}, new int[]{380, 100, 390, 350}, new int[]{400, 100, 410, 350}, new int[]{450, 250, 550, 450}, new int[]{290, 390, 390, 500}, new int[]{250, 200, 260, 400}};

void setup() {
  size(800, 600); //<>//
  frameRate(40);
  
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
  fixturePresets.get(6).newFixture(new int[]{675, 100, 725, 500}, new int[]{675, 100, 675, 500}, "Pharmacy", new String[]{"Medicine"});
  fixturePresets.get(0).newFixture(new int[]{75, 250, 200, 375}, new int[]{75, 250, 200, 250}, new String[]{"Oranges", "Apples", "Bananas", "Canteloupes"});
  fixturePresets.get(1).newFixture(new int[]{75, 395, 200, 520}, new int[]{75, 395, 200, 395}, new String[]{"Cabbage", "Lettuce", "Broccoli", "Caufliflower"});
  fixturePresets.get(2).newFixture(new int[]{0, 100, 25, 300}, new int[]{25, 100, 25, 300}, new String[]{"Green beans", "Green onion", "Ginger", "Radish", "Spinach", "Carrots"});
  fixturePresets.get(3).newFixture(new int[]{0, 320, 35, 599}, new int[]{35, 320, 35, 599}, new String[]{"Milk", "Yogurt", "Cheese", "Butter", "Ice cream"});
  fixturePresets.get(4).newFixture(new int[]{200, 565, 790, 599}, new int[]{200, 565, 790, 565}, new String[]{"Ground beef", "Steak", "Chicken wings", "Porkchops", "Kebabs", "Eggs"});
  fixturePresets.get(5).newFixture(new int[]{290, 390, 390, 500}, new int[]{290, 390, 390, 390}, new String[]{"Cookies", "Muffins", "Cupcakes", "Bread", "Brownies", "Pie", "Cake"});
  
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
    //todo: file stuff
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
