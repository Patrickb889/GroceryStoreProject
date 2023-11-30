//float enteranceX = 0;
//float enteranceY = 0;
PVector entrance = new PVector(0, 0);
float userSpeed = 1;
ArrayList<String> importedList = new ArrayList<String>();

ArrayList<Shopper> shoppers = new ArrayList<Shopper>();
//Shopper shopper = new Shopper(entrance.x, entrance.y, userSpeed, importedList);

void setup() {
  size(800, 600);
  
  
  for (int i = 0; i < 5; i++) {
    shoppers.add(new Shopper(entrance.x, entrance.y, round(random(1, 3)), importedList));
  }
}


void draw() {
  background(173, 176, 186);
  //user.updateMe(800, 600);
  //user.drawMe();
  
  for (Shopper s : shoppers) {
    s.updateMe();
    s.drawMe();
  }
  
}
