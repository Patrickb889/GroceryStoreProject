class Fixture {
  // FIELDS
  int[] position;
  int[] mainSideCoords;  // Coords of corners that are apart of the main side (the side a customer would go to to get something)
  String type, name;
  String[] products;  // list of products found on/in the fixture
  ArrayList<Item> items = new ArrayList<Item>();
  PVector defaultPoint;
  color colour;
  
  
  // CONSTRUCTOR
  Fixture(int[] p, int[] msc, String t, String n, String[] pr, color c, PVector dp) {
    this.position = p;
    this.mainSideCoords = msc;
    this.type = t;
    this.name = n;
    this.products = pr;
    this.colour = c;
    this.defaultPoint = dp;
  }
  
  Fixture(int[] p, int[] msc, String t, String n, String[] pr, color c) {
    this.position = p;
    this.mainSideCoords = msc;
    this.type = t;
    this.name = n;
    this.products = pr;
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
    stroke(0);
    strokeWeight(1);
    fill(this.colour);
    
    rect(this.position[0], this.position[1], this.position[2] - this.position[0], this.position[3] - this.position[1]);
    
    
    textAlign(CENTER, CENTER);
    fill(0);
    textSize(20);
    
    float currWidth = textWidth(this.name);
    float maxWidth = 0.8 * (this.position[2] - this.position[0]);
    
    if (currWidth > maxWidth) {
      textSize(20 * maxWidth/currWidth);
    }
    
    int centreX = (this.position[0] + this.position[2])/2;
    int centreY = (this.position[1] + this.position[3])/2;
    
    text(this.name, centreX, centreY);
  }
}
