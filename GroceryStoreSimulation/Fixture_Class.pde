class Fixture {
  // FIELDS
  int[] position;
  int[] mainSideCoords;  // Coords of corners that are apart of the main side (the side a customer would go to to get something)
  String type, name;
  String[] products;  // list of products found on/in the fixture
  Item[] items;
  PVector defaultPoint;
  int index = fixtures.size();
  PVector colour;
  int maxStock, stock;
  float urgency, restockChance;  // urgency = 1 - sum of current stock of all items / sum of max stock of all items
  
  
  // CONSTRUCTOR
  // Entrance/exit
  Fixture(PVector dp) {
    this.defaultPoint = dp;
    this.products = new String[0];
    this.position = new int[0];
    this.mainSideCoords = new int[0];
    this.type = "Door";
    this.name = "";
    this.colour = new PVector();
  }
  
  // Default point determined
  Fixture(int[] p, int[] msc, String t, String n, String[] pr, int ms, float rc, PVector c, PVector dp) {
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
    
    if (this.maxStock != 0)
      this.urgency = 1 - (float)this.stock/this.maxStock;
      
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
    
    if (this.type.equals("Display"))
      this.defaultPoint = new PVector(this.mainSideCoords[0], this.mainSideCoords[1]);
    
    else {
      if (this.mainSideCoords[0] == this.mainSideCoords[2])  // main side is vertical
        this.defaultPoint = new PVector(this.mainSideCoords[0], (this.mainSideCoords[1] + this.mainSideCoords[3])/2);
      else  // main side is horizontal
        this.defaultPoint = new PVector((this.mainSideCoords[0] + this.mainSideCoords[2])/2, this.mainSideCoords[1]);
    }
  }
  
  
  // METHODS
  void drawMe() {
    if (this.position.length != 4)
      return;
      
    if (selectedFixture == this.index) {
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
    float maxWidth = 0.8 * (this.position[2] - this.position[0]);
    
    int centreX = (this.position[0] + this.position[2])/2;
    //int centreY = (this.position[1] + this.position[3])/2;
    int oneThirdY = (2*this.position[1] + this.position[3])/3;
    int twoThirdsY = (this.position[1] + 2*this.position[3])/3;
    
    if (currWidth > maxWidth) {
      fontSize *= (maxWidth/currWidth);
      textSize(max(0.1, fontSize));
    }
    
    else if (textAscent() > twoThirdsY - oneThirdY) {
      fontSize *= ((twoThirdsY - oneThirdY) / textAscent());
      textSize(max(0.1, fontSize));
    }
    
    
    
    text(this.name, centreX, oneThirdY);
    text(str(this.stock) + "/" + str(this.maxStock), centreX, twoThirdsY);
    
    if (selectedFixture == this.index) {
      stroke(0, 107, 255);
      line(this.mainSideCoords[0], this.mainSideCoords[1], this.mainSideCoords[2], this.mainSideCoords[3]);
      
      strokeWeight(2);
      
      stroke(0, 0, 255);
      fill(0, 197, 255);
      circle(this.position[0], this.position[1], 12);
      
      stroke(255, 0, 0);
      fill(255, 150, 0);
      circle(this.defaultPoint.x, this.defaultPoint.y, 8);
    }
  }
  
  
  void restock() {
    float percent = random(1, 20);
    int restockAmount = round(percent * this.maxStock);
    this.stock = min(this.maxStock, this.stock + restockAmount);
    this.urgency = 1 - this.stock/this.maxStock;
  }
  
  void move(int[] displacements) {
    if (displacements[0] < 0)
      displacements[0] = -min(this.position[0] - 1, -displacements[0]);
    else
      displacements[0] = min(width - this.position[2] - 1, displacements[0]);
      
    if (displacements[1] < 0)
      displacements[1] = -min(this.position[1] - 1, -displacements[1]);
    else
      displacements[1] = min(height - this.position[3] - 1, displacements[1]);
      
    for (int i = 0; i < 4; i++) {
      this.position[i] += displacements[i % 2];
    }
    
    for (int i = 0; i < 4; i++) {
      this.mainSideCoords[i] += displacements[i % 2];
    }
    
    this.defaultPoint.x += displacements[0];
    this.defaultPoint.y += displacements[1];
  }
  
  void rescale(int[] displacements) {
    for (int i = 0; i < 4; i++) {
      if (this.mainSideCoords[i] == this.position[i % 2])
        this.mainSideCoords[i] += displacements[i % 2];
    }
    
    for (int i = 0; i < 2; i++) {
      this.position[i] += displacements[i];
    }
    
    this.defaultPoint.x = this.mainSideCoords[2];
    this.defaultPoint.y = this.mainSideCoords[3];
    //if (this.mainSideCoords[0] == this.mainSideCoords[2]) {  // vertical main side
    //  float scaleFactor = (this.position[3] - this.defaultPoint.y) / (this.position[3] - this.position[1]);
    //  this.defaultPoint.x += displacements[0];
    //  this.defaultPoint.y = max(this.position[1], min(this.position[3], this.defaultPoint.y + scaleFactor * displacements[1]));
    //} else {  // horizontal main side
    //  float scaleFactor = (this.position[2] - this.defaultPoint.x) / (this.position[2] - this.position[0]);
    //  this.defaultPoint.x = max(this.position[0], min(this.position[2], this.defaultPoint.x + scaleFactor * displacements[0]));
    //  this.defaultPoint.y += displacements[1];
    //}
  }
  
  void moveTo(Fixture f) {
    int thisX = (this.position[0] + this.position[2]) / 2;
    int thisY = (this.position[1] + this.position[3]) / 2;
    int fX = (f.position[0] + f.position[2]) / 2;
    int fY = (f.position[1] + f.position[3]) / 2;
    
    int xDisp, yDisp;
    
    if (abs(thisX - fX) >= abs(thisY - fY)) {
      // attach to right or left side
      if (thisX > fX)
        xDisp = f.position[2] - this.position[0];
      else
        xDisp = f.position[0] - this.position[2];
        
      yDisp = fY - thisY;
        
    }
    
    else {
      // attach to top or bottom
      if (thisY > fY)
        yDisp = f.position[3] - this.position[1];
      else
        yDisp = f.position[1] - this.position[3];
        
      xDisp = fX - thisX;
    }
    
    this.move(new int[]{xDisp, yDisp});
  }
  
  void changeMainSide(String direction) {
    if (direction.equals("Clockwise")) {
      int[] tempStorage = {this.mainSideCoords[2], this.mainSideCoords[3]};
      
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
