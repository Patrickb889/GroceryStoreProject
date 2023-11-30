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
  
  void placeItemInSpot(Fixture F) {
    this.position.x = F.defaultPoint.x;
    this.position.y = F.defaultPoint.y;
    F.items.add(this);
    //F.colour = this.colour;
  }
}
