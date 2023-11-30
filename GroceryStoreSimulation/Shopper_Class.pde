class Shopper {
  //Fields
  PVector position, direction, velocity, destination;
  float cartSpace, speed;
  ArrayList<Item> items = new ArrayList();
  ArrayList<String> shoppingList;
  
  //Constructor
  Shopper(float x, float y, float s, ArrayList<String> sL) {
   this.position = new PVector(x, y); //Position of the shopper
   this.cartSpace = 1500; //volume of the cart in cubic centimeters
   this.speed = s; //Speed of the shoper for the drawing
   this.shoppingList = sL; //The items the shopper needs to get as strings in an array list
   this.destination = new PVector(round(random(0, width)), round(random(0, height)));
   this.updateVel();
  }
  
  //Methods
  void updateVel() {
    float nextX = this.destination.x;
    float nextY = this.destination.y;
    
    //Making a unit vector in the direction the shopper should move
    this.direction = new PVector(nextX - this.position.x, nextY - this.position.y);
    float magnitude = mag(this.direction.x, this.direction.y);
    this.direction.div(magnitude);
   
    //the distance the shopper should move
    this.velocity = this.direction.mult(this.speed);
  }
  
  void updateMe() {
    float prevX = this.position.x;
    
    //Updating the positon
    this.position.add(this.velocity);
    
    //check if destination reached
    if (prevX <= this.destination.x && this.destination.x <= this.position.x || this.position.x <= this.destination.x && this.destination.x <= prevX) {
      this.destination = new PVector(round(random(0, width)), round(random(0, height)));
      updateVel();
    }
   
    
    
  }
  
  void drawMe() {
    fill(22, 133, 201);
    stroke(0);
    strokeWeight(1);
    circle(this.position.x, this.position.y, 10);
  }
}
