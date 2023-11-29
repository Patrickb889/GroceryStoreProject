float enteranceX = 0;
float enteranceY = 0;
float userSpeed = 1;
ArrayList<String> importedList = new ArrayList();
Shopper user = new Shopper(enteranceX, enteranceY, userSpeed, importedList);

void setup() {
  size(800, 600);
  
  
}


void draw() {
  background(173, 176, 186);
  user.updateMe(800, 600);
  user.drawMe();
  
}
