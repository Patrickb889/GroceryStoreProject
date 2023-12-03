class FixturePreset {
  String type;  // shelf, fridge, display, counter
  String name;  // (ex: meat, dairy, fruit, pharmacy, etc)
  color colour;
  
  FixturePreset(String t, String n, color c) {
    this.type = t;
    this.name = n;
    this.colour = c;
  }
  
  FixturePreset(String t, color c) {
    this.type = t;
    this.colour = c;
  }
  
  void newFixture(int[] pos, int[] mainSideCoords, String[] products) {
    fixtures.add(new Fixture(pos, mainSideCoords, this.type, this.name, products, this.colour));
  }
  
  void newFixture(int[] pos, int[] mainSideCoords, String name, String[] products) {
    fixtures.add(new Fixture(pos, mainSideCoords, this.type, name, products, this.colour));
  }
}
