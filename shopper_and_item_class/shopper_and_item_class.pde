class Item {
  //Fields
  PVector position;
  Float size;
  int stock;
  String name, category;
  color colour;
  
  //Constructor
  Item(String n, String c, float s, int sto, color co) {
   this.position = new PVector(); 
   this.size = s;
   this.stock = sto;
   this.name = n;
   this.category = c;
   this.colour = co;
  }
  
  //Methods
  void grabbed(Shopper s) {
   this.stock--; 
   s.cartSpace -= this.size;
   s.items.add(this);
  }
  
  void placeItemInSpot(Furniture F) {
    this.position.x = F.position.x;
    this.position.y = F.position.y;
    F.item = this;
    F.colour = this.colour;
  }
}



class Shopper {
  //Fields
  PVector position, direction, velocity;
  float cartSpace, speed;
  ArrayList<Item> items = new ArrayList();
  ArrayList<String> shoppingList;
  
  //Constructor
  Shopper(float x, float y, float s, ArrayList<String> sL) {
   this.position = new PVector(x, y); //Position of the shopper
   this.cartSpace = 1500; //volume of the cart in cubic centimeters
   this.speed = s; //Speed of the shoper for the drawing
   this.shoppingList = sL; //The items the shopper needs to get as strings in an array list
  }
  
  //Methods
  void updateMe(float nextX, float nextY) {
   //Making a unit vector in the direction the shopper should move
   this.direction = new PVector(nextX, nextY);
   float magnitude = mag(this.direction.x, this.direction.y);
   this.direction.div(magnitude);
   
   //the distance the shopper should move
   this.velocity = this.direction.mult(this.speed);
   
   //Updating the positon
   this.position.add(this.velocity);
  }
  
  void drawMe() {
    fill(22, 133, 201);
    circle(this.position.x, this.position.y, 10);
  }
}
