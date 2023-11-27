class Item {
  //Fields
  PVector position;
  Float size;
  int stock;
  String name, category;
  
  //Constructor
  Item(float x, float y, float s, int sto, String n, String c) {
   this.position = new PVector(x, y); 
   this.size = s;
   this.stock = sto;
   this.name = n;
   this.category = c;
  }
  
  //Methods
  
  
}



class Shopper {
  //Fields
  PVector position;
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
  
  
}
