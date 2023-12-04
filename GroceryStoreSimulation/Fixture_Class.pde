class Fixture {
  // FIELDS
  int[] position;
  int[] mainSideCoords;  // Coords of corners that are apart of the main side (the side a customer would go to to get something)
  String type, name;
  String[] products;  // list of products found on/in the fixture
  Item[] items;
  PVector defaultPoint;
  int index = fixtures.size();
  color colour;
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
    this.colour = color(0);
  }
  
  // Default point determined
  Fixture(int[] p, int[] msc, String t, String n, String[] pr, int ms, float rc, color c, PVector dp) {
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
  Fixture(int[] p, int[] msc, String t, String n, String[] pr, int ms, float rc, color c) {
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
      
    stroke(0);
    strokeWeight(1);
    fill(this.colour);
    
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
      textSize(fontSize);
    }
    
    else if (textAscent() > twoThirdsY - oneThirdY) {
      fontSize *= ((twoThirdsY - oneThirdY) / textAscent());
      textSize(fontSize);
    }
    
    
    
    text(this.name, centreX, oneThirdY);
    text(str(this.stock) + "/" + str(this.maxStock), centreX, twoThirdsY);
  }
  
  
  void restock() {
    float percent = random(1, 20);
    int restockAmount = round(percent * this.maxStock);
    this.stock = min(this.maxStock, this.stock + restockAmount);
    this.urgency = 1 - this.stock/this.maxStock;
  }
  
}
