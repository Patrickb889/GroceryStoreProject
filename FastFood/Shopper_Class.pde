class Shopper {
  //Fields
  PVector position, direction;
  PVector velocity = new PVector(0, 0);
  PVector destination = entrance.copy();
  float speed, regularSpeed;
  int targetFixtureIndex = 0;
  int[] pathSegment = {0};
  int indexInFullPath = 0;
  int indexInPathSegment = 0;
  
  //Constructor
  Shopper(float x, float y, float s) {
   this.position = new PVector(x, y); //Position of the shopper
   this.speed = s; //Speed of the shoper for the drawing
   this.regularSpeed = s;
   this.updateVel();
  }
  
  
  
  //Methods
  void reinitialize() {
    this.position = entrance.copy();
    this.velocity = new PVector(0, 0);
    this.destination = entrance.copy();
    
    this.targetFixtureIndex = 0;
    this.pathSegment = new int[]{0};
    this.indexInFullPath = 0;
    this.indexInPathSegment = 0;
  }
  
  
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
  
  
  // Get next target destination point (for path animation)
  void getNextDestination() {  // Very similar process to drawing the lines of the path
    // At entrance
    if (this.position.equals(entrance)) {
      this.indexInFullPath = 1;  // fullPath[this.indexInFullPath]: index of next fixture to go to
      this.indexInPathSegment = 1;  // this.pathSegment[this.indexInPathSegment]: index of next corner to go to
      
      int newFixtureIndex = fullPath[1];  // Index of first fixture after entrance
      String stringPath = optimalPaths[0][newFixtureIndex];  // Point indices connected by dashes
      
      if (stringPath == null)  // Just in case
        return;
      
      this.pathSegment = reverse(int(split(stringPath, "-")));  // Convention of this program is to put paths between two points at indices [i][j] where i < j (these paths would be from ending point to starting point, point j to point i)
                                                                // Since index of entrance point is always 0, a path between a point and the entrance would always be represented as from that point to the entrance which is why the path needs to be reversed to be from the entrance to that point
      int newPointIndex = this.pathSegment[1];  // Index of first point after entrance in path to first fixture
      
      // Fixture indices are different from point indices so they have different methods of getting the coordinates
      if (this.indexInPathSegment == this.pathSegment.length - 1)
        this.destination = fixtures.get(newPointIndex).defaultPoint;
      else
        this.destination = pointCoords(newPointIndex);
        
      this.targetFixtureIndex = newFixtureIndex;
      
      this.speed = this.regularSpeed;  // Set speed back to normal after speed up from exit back to entrance
    }
    
    // At exit
    else if (this.position.equals(exit)) {
      // Reset all values
      this.destination = entrance.copy();
      this.indexInFullPath = 0;
      this.indexInPathSegment = 0;
      this.targetFixtureIndex = 0;
      this.speed = this.regularSpeed * 5;  // Speed boost from exit back to entrance
    }
      
    // At end of path segment
    else if (this.indexInPathSegment == this.pathSegment.length - 1 && !this.position.equals(entrance)) {
      this.indexInFullPath += 1;  // Next fixture in overall path
      this.indexInPathSegment = 0;  // First point in path to next fixture
      
      // Get new path segment to new fixture
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
    
    // Start (except entrance) or middle of path segment
    else {
      this.indexInPathSegment += 1;  // Next corner
      
      int newPointIndex = this.pathSegment[this.indexInPathSegment];
      
      if (this.indexInPathSegment == this.pathSegment.length - 1)
        this.destination = fixtures.get(newPointIndex).defaultPoint;  // Get fixture coord
        
      else
        this.destination = pointCoords(newPointIndex);  // Get regular corner coord
    }
    
  }
  
  
  boolean destinationReached() {
    return this.position.x == this.destination.x && this.position.y == this.destination.y ||  // Current position exactly equals destination coordinates
           min(this.position.x, this.position.x + this.velocity.x) < this.destination.x && this.destination.x < max(this.position.x, this.position.x + this.velocity.x) ||  // Destination x is between previous position x and current position x
           min(this.position.y, this.position.y + this.velocity.y) < this.destination.y && this.destination.y < max(this.position.y, this.position.y + this.velocity.y);  // Destination y is between prev y and curr y
  }
}
