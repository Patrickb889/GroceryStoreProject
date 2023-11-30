class Fixture {
  // FIELDS
  int[] position;
  int[] mainSideCoords;  // Coords of corners that are apart of the main side (the side a customer would go to to get something)
  String type;  // shelf, fridge, display, counter
  String[] categories;
  ArrayList<Item> items = new ArrayList<Item>();
  PVector defaultPoint;
  color colour;
  
  
  // CONSTRUCTOR
  Fixture(int[] p, int[] msc, String t, String[] ctgs, color c) {
    this.position = p;
    this.mainSideCoords = msc;
    this.type = t;
    this.categories = ctgs;
    this.colour = c;
    
    if (this.type.equals("display"))
      this.defaultPoint = new PVector(this.mainSideCoords[0], this.mainSideCoords[1]);
    
    else {
      if (this.mainSideCoords[0] == this.mainSideCoords[2])  // main side is vertical
        this.defaultPoint = new PVector(this.mainSideCoords[0], (this.mainSideCoords[1] + this.mainSideCoords[3])/2);
      else  // main side is horizontal
        this.defaultPoint = new PVector((this.mainSideCoords[0] + this.mainSideCoords[2])/2, this.mainSideCoords[1]);
    }
  }
}
