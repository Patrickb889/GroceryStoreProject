class Shopper {
  //Fields
  PVector position, direction;
  PVector velocity = new PVector(0, 0);
  PVector destination = entrance.copy();
  float speed;
  int targetFixtureIndex = 0;
  int[] pathSegment = {0};
  int indexInFullPath = 0;
  int indexInPathSegment = 0;
  
  //Constructor
  Shopper(float x, float y, float s) {
   this.position = new PVector(x, y); //Position of the shopper
   this.speed = s; //Speed of the shoper for the drawing
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
    if (magnitude == 0)
      this.velocity = new PVector(0, 0);
    else
      this.velocity = this.direction.mult(this.speed);
  }
  
  void updateMe() {
    //check if destination reached
    if (this.destinationReached()) {
      this.position = this.destination.copy();
      this.getNextDestination();
      
      this.updateVel();
    }
    
    else {
      //Updating the positon
      this.position.add(this.velocity);
    }
   
    
    
  }
  
  void drawMe() {
    fill(22, 133, 201);
    stroke(0);
    strokeWeight(1);
    circle(this.position.x, this.position.y, 10);
    
  }
  
  
  void getNextDestination() {  // Very similar process to drawing the lines of the path
    // At entrance
    if (this.position.equals(entrance)) {
      this.indexInFullPath = 1;
      this.indexInPathSegment = 1;
      
      int newPointIndex = fullPath[1];
      String stringPath = optimalPaths[0][newPointIndex];
      
      if (stringPath == null)
        return;
      
      this.pathSegment = reverse(int(split(stringPath, "-")));
      
      if (this.indexInPathSegment == this.pathSegment.length - 1)
        this.destination = fixtures.get(newPointIndex).defaultPoint;
        
      else
        this.destination = pointCoords(newPointIndex);
        
      this.targetFixtureIndex = newPointIndex;
    }
    
    // At exit
    else if (this.position.equals(exit)) {
      this.destination = entrance.copy();
      this.indexInFullPath = 0;
      this.indexInPathSegment = 0;
      this.targetFixtureIndex = 0;
    }
      
    // At end of path segment
    else if (this.indexInPathSegment == this.pathSegment.length - 1 && !this.position.equals(entrance)) {
      this.indexInFullPath += 1;
      this.indexInPathSegment = 0;
      
      int newFixtureIndex = fullPath[this.indexInFullPath];
      String stringPath = optimalPaths[min(this.targetFixtureIndex, newFixtureIndex)][max(this.targetFixtureIndex, newFixtureIndex)];
      
      if (stringPath == null)
        return;
      
      this.pathSegment = int(split(stringPath, "-"));
      
      if (this.targetFixtureIndex < newFixtureIndex)
        this.pathSegment = reverse(int(split(stringPath, "-")));
        
      this.destination = fixtures.get(this.targetFixtureIndex).defaultPoint;
      
      this.targetFixtureIndex = newFixtureIndex;
    }
    
    else {
      this.indexInPathSegment += 1;
      int newPointIndex = this.pathSegment[this.indexInPathSegment];
      
      if (this.indexInPathSegment == this.pathSegment.length - 1)
        this.destination = fixtures.get(newPointIndex).defaultPoint;  // Get fixture coord
        
      else
        this.destination = pointCoords(newPointIndex);  // Get regular corner coord
    }
    
  }
  
  boolean destinationReached() {
    return this.position.x == this.destination.x && this.position.y == this.destination.y ||
           min(this.position.x, this.position.x + this.velocity.x) < this.destination.x && this.destination.x < max(this.position.x, this.position.x + this.velocity.x) ||
           min(this.position.y, this.position.y + this.velocity.y) < this.destination.y && this.destination.y < max(this.position.y, this.position.y + this.velocity.y);
  }
}
