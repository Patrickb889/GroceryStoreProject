float restockChance = 1/(frameRate*10);

class Item {
  //Fields
  //PVector position;
  int size;
  int maxStock, stock;
  String name;//, category;
  //color colour;
  Fixture container;
  
  //Constructor
  Item(String n, Fixture c) {
   //this.position = new PVector(); 
   this.size = round(random(10, 100));
   this.maxStock = round(1000/this.size);
   this.stock = round(random(0, maxStock));
   this.name = n;
   this.container = c;
   //this.category = c;
   //this.colour = co;
  }
  

  //void placeItemInSpot(Fixture f) {
  //  this.position.x = f.defaultPoint.x;
  //  this.position.y = f.defaultPoint.y;
  //  F.items.add(this);
  //  //F.colour = this.colour;
  //}
  
  void restock() {
    float percent = random(0, 20);
    //restock whatever percent of maxStock
  }
}

//todo: delete if not used
