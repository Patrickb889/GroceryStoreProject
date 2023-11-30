//float enteranceX = 0;
//float enteranceY = 0;
PVector entrance = new PVector(0, 0);
PVector exit = new PVector(100, 0);
float userSpeed = 1;
ArrayList<String> importedList = new ArrayList<String>();

ArrayList<Shopper> shoppers = new ArrayList<Shopper>();
//Shopper shopper = new Shopper(entrance.x, entrance.y, userSpeed, importedList);

void setup() {
  size(800, 600);
  frameRate(20);
  
  fill(0);
  textSize(30);
  textAlign(CENTER);
  text("Loading...", 400, 300);
  
  for (int i = 0; i < 5; i++) {
    shoppers.add(new Shopper(entrance.x, entrance.y, round(random(1, 5)), importedList));
  }
}

boolean pathCalculated = false;

ArrayList<ArrayList<PVector>> paths = new ArrayList<ArrayList<PVector>>();
//PVector[] list = new PVector[]{entrance, new PVector(260, 200), new PVector(340, 225), new PVector(360, 225), new PVector(390, 390), new PVector(550, 450)};
PVector[] list = new PVector[]{entrance, new PVector(25, 200), new PVector(75, 250), new PVector(35, 460), new PVector(260, 200), new PVector(340, 300), new PVector(360, 225), new PVector(390, 390), new PVector(550, 450), new PVector(675, 300), exit};
//todo: fix undefined slope or 0 slope cases for intersection checking
//todo: instead of using PVector array for obstacles, create each as a fixture object and store in ArrayList<Fixture>

void draw() {
  background(173, 176, 186);
  //user.updateMe(800, 600);
  //user.drawMe();
  

  
  fill(255, 0, 0);
  stroke(0);
  strokeWeight(1);
  for (int[] ob : obstacles)
    rect(ob[0], ob[1], ob[2] - ob[0], ob[3] - ob[1]);
    
    
  stroke(0, 255, 0);
  strokeWeight(3);
  for (ArrayList<PVector> ap : paths) {
    for (int i = 1; i < ap.size(); i++) {
      line(ap.get(i-1).x, ap.get(i-1).y, ap.get(i).x, ap.get(i).y);
    }
  }
  
  fill(0, 0, 255);
  stroke(0);
  strokeWeight(1);
  for (PVector item : list)
    circle(item.x, item.y, 8);

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
    
    for (int i = 1; i < list.length; i++) {
      pathFind(list[i-1], list[i]);
    }
    
    pathCalculated = true;
  }
  
  for (Shopper s : shoppers) {
    s.updateMe();
    s.drawMe();
  }
  
}
