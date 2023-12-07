class Fixture {
  // FIELDS
  int[] position;
  int[] mainSideCoords;  // Coords of corners that are apart of the main side (the side a customer would go to to get something)
  String type, name;
  String[] products;  // List of products found on/in the fixture
  PVector defaultPoint;  // The point that will be used in all path calculations
  int index = fixtures.size();  // Integer value the fixture will be linked to
  PVector colour;
  int maxStock, stock;
  float restockChance, urgency;  // urgency = 1 - (sum of current stock of all items / sum of max stock of all items)
  boolean defPointModified = false;  // If this is true, appropriate recalculations will be done
  
  
  // CONSTRUCTOR
  // Entrance/exit
  Fixture(PVector dp) {  // The only field that will be used is defaultPoint (which is just the coords of the entrance/exit)
    this.defaultPoint = dp;
    this.products = new String[0];
    this.position = new int[0];
    this.mainSideCoords = new int[0];
    this.type = "Door";
    this.name = "";
    this.colour = new PVector();
  }
  
  // Default point has been previously determined
  Fixture(int[] p, int[] msc, String t, String n, String[] pr, int ms, float rc, PVector c, PVector dp) {
    this.position = p;
    this.mainSideCoords = msc;
    this.type = t;
    this.name = n;
    this.products = pr;
    this.restockChance = rc;
    this.maxStock = ms;
    
    if (this.type.equals("Counter"))
      this.stock = this.maxStock;  // "Counters" (like pharmacy, post office, etc) will always have 1/1 stock
    else
      this.stock = round(random(0, this.maxStock));
    
    this.urgency = 1 - (float)this.stock/this.maxStock;  // The lower the stock, the higher the urgency
    this.colour = c;
    this.defaultPoint = dp;
  }
  
  // Default point not determined
  Fixture(int[] p, int[] msc, String t, String n, String[] pr, int ms, float rc, PVector c) {
    this.position = p;
    this.mainSideCoords = msc;
    this.type = t;
    this.name = n;
    this.products = pr;
    this.restockChance = rc;
    this.maxStock = ms;
    
    if (this.type.equals("Counter"))
      this.stock = this.maxStock;
    else
      this.stock = round(random(0, ms));
      
    this.urgency = 1 - (float)this.stock/this.maxStock;
    this.colour = c;
    
    if (this.mainSideCoords[0] == this.mainSideCoords[2])  // Main side is vertical
      this.defaultPoint = new PVector(this.mainSideCoords[0], (this.mainSideCoords[1] + this.mainSideCoords[3])/2);
    else  // Main side is horizontal
      this.defaultPoint = new PVector((this.mainSideCoords[0] + this.mainSideCoords[2])/2, this.mainSideCoords[1]);
  }
  
  
  // METHODS
  void drawMe() {
    if (this.position.length != 4)  // This happens when the fixture is the entrance/exit
      return;
      
    if (selectedFixture == this.index) {
      // Thick cyan outline when fixture is selected
      stroke(0, 255, 255);
      strokeWeight(4);
    } else {
      stroke(0);
      strokeWeight(1);
    }
    
    fill(color(this.colour.x, this.colour.y, this.colour.z));
    
    rect(this.position[0], this.position[1], this.position[2] - this.position[0], this.position[3] - this.position[1]);
    
    
    textAlign(CENTER, CENTER);
    fill(0);
    float fontSize = 20;
    textSize(fontSize);
    
    float currWidth = textWidth(this.name);
    
    // Max width and height of text on fixture (0.8 gives some buffer room)
    float maxWidth = 0.8 * (this.position[2] - this.position[0]);
    float maxHeight = 0.8 * (this.position[3] - this.position[1]);
    
    int centreX = (this.position[0] + this.position[2])/2;
    int centreY = (this.position[1] + this.position[3])/2;
    
    // Scale text size to fit in fixture's outline
    if (currWidth > maxWidth) {
      fontSize *= (maxWidth/currWidth);
      textSize(max(0.1, fontSize));
    }
    
    if (textAscent() > maxHeight) {
      fontSize *= (maxHeight/textAscent());
      textSize(max(0.1, fontSize));
    }
    
    text(this.name, centreX, centreY);
    
    
    if (selectedFixture == this.index) {
      stroke(0, 107, 255);
      line(this.mainSideCoords[0], this.mainSideCoords[1], this.mainSideCoords[2], this.mainSideCoords[3]);  // Thick blue line indicating main side
      
      strokeWeight(2);
      
      stroke(0, 0, 255);
      fill(0, 197, 255);
      circle(this.position[0], this.position[1], 12);  // Blue circle at top left corner (user clicks and drags this to resize)
      
      stroke(255, 0, 0);
      fill(255, 150, 0);
      circle(this.defaultPoint.x, this.defaultPoint.y, 8);  // Red/orange circle at default point (user can drag this around as well)
    }
  }
  
  //todo: delete if not used
  //void restock() {
  //  float percent = random(1, 20);
  //  int restockAmount = round(percent * this.maxStock);
  //  this.stock = min(this.maxStock, this.stock + restockAmount);
  //  this.urgency = 1 - this.stock/this.maxStock;
  //}
  
  
  void move(int[] displacements) {
    // Reinitialize distances and paths arrays so that all required paths can be recalculated after the fixture has been moved
    int numFixtures = fixtures.size();
    allDistances = new float[numFixtures][numFixtures];
    optimalPaths = new String[numFixtures][numFixtures];
    
    recalcRequired = true;  // Recalculation would be required after moving a fixture around
    
    // Make sure the fixture won't be moved off screen
    if (displacements[0] < 0)  // Check x displacement
      displacements[0] = -min(this.position[0] - 1, -displacements[0]);
    else
      displacements[0] = min(width - this.position[2] - 1, displacements[0]);
      
    if (displacements[1] < 0)  // Check y displacement
      displacements[1] = -min(this.position[1] - 1, -displacements[1]);
    else
      displacements[1] = min(height - this.position[3] - 1, displacements[1]);
      
    // Even coords will have x disp added, odd coords will have y disp added
    for (int i = 0; i < 4; i++) {
      this.position[i] += displacements[i % 2];
    }
    
    // Same with main side coords
    for (int i = 0; i < 4; i++) {
      this.mainSideCoords[i] += displacements[i % 2];
    }
    
    // Same with default point
    this.defaultPoint.x += displacements[0];
    this.defaultPoint.y += displacements[1];
  }
  
  
  void rescale(int[] displacements) {
    // Reinitialize distances and paths arrays so that all required paths can be recalculated after the fixture has been rescaled
    int numFixtures = fixtures.size();
    allDistances = new float[numFixtures][numFixtures];
    optimalPaths = new String[numFixtures][numFixtures];
    
    recalcRequired = true;
    
    // Make sure fixture doesn't go off screen
    displacements[0] = -min(this.position[0] - 1, -displacements[0]);
    displacements[1] = -min(this.position[1] - 1, -displacements[1]);
      
    // Update main side coords
    for (int i = 0; i < 4; i++) {
      if (this.mainSideCoords[i] == this.position[i % 2])
        this.mainSideCoords[i] += displacements[i % 2];
    }
    
    // Only first two coords (x1 and y1) need updating for resizing
    for (int i = 0; i < 2; i++) {
      this.position[i] += displacements[i];
    }
    
    // Default point attaches to a corner on the main side
    this.defaultPoint.x = this.mainSideCoords[2];
    this.defaultPoint.y = this.mainSideCoords[3];
  }
  
  
  // Different from this.move() (moves a fixture so that it is side by side with another fixture)
  void moveTo(Fixture f) {
    // Centre coords of this fixture
    int thisX = (this.position[0] + this.position[2]) / 2;
    int thisY = (this.position[1] + this.position[3]) / 2;
    // Centre coords of target fixture
    int fX = (f.position[0] + f.position[2]) / 2;
    int fY = (f.position[1] + f.position[3]) / 2;
    
    int xDisp, yDisp;
    
    // Attach to right or left side if slope between centres is more horizontal (or perfectly 1)
    if (abs(thisX - fX) >= abs(thisY - fY)) {
      if (thisX > fX)
        xDisp = f.position[2] - this.position[0];  // Attach to right side (this left to target right)
      else
        xDisp = f.position[0] - this.position[2];  // Attach to left side (this right to target left)
        
      yDisp = fY - thisY;  // This y becomes level with target y
        
    }
    
    // Attach to top or bottom if slope is more vertical
    else {
      if (thisY > fY)
        yDisp = f.position[3] - this.position[1];  // Attach to bottom (this top to target bottom)
      else
        yDisp = f.position[1] - this.position[3];  // Attach to top (this bottom to target top)
        
      xDisp = fX - thisX;  // This x becomes level with target x
    }
    
    this.move(new int[]{xDisp, yDisp});  // Call own move() method with displacements calculated
  }
  
  
  // Change main side to be top, bottom, left, right
  void changeMainSide(String direction) {
    if (direction.equals("Clockwise")) {
      int[] tempStorage = {this.mainSideCoords[2], this.mainSideCoords[3]};
      
      // First point (x index 0, y index 1) is set to point diagonally across from it and becomes new second point
      if (this.mainSideCoords[0] == this.position[0])
        this.mainSideCoords[2] = this.position[2];
      else
        this.mainSideCoords[2] = this.position[0];
        
      if (this.mainSideCoords[1] == this.position[1])
        this.mainSideCoords[3] = this.position[3];
      else
        this.mainSideCoords[3] = this.position[1];
        
      this.mainSideCoords[0] = tempStorage[0];
      this.mainSideCoords[1] = tempStorage[1];
    }
    
    else {
      int[] tempStorage = {this.mainSideCoords[0], this.mainSideCoords[1]};
      
      // Second point (index 2, index 3) is set to point diagonally across from it and becomes new first point
      if (this.mainSideCoords[2] == this.position[2])
        this.mainSideCoords[0] = this.position[0];
      else
        this.mainSideCoords[0] = this.position[2];
        
      if (this.mainSideCoords[3] == this.position[3])
        this.mainSideCoords[1] = this.position[1];
      else
        this.mainSideCoords[1] = this.position[3];
        
      this.mainSideCoords[2] = tempStorage[0];
      this.mainSideCoords[3] = tempStorage[1];
    }
  }
  
}
