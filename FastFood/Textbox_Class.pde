class Textbox {  // Textbox the user can enter information into
  // FIELDS
  boolean show;
  String label;  // Indicates what information should be entered
  String notes;  // Additional instructions
  String text;  // Text displayed in text entry field
  
  Textbox() {
    this.show = false;
    this.label = "";
    this.notes = "";
    this.text = "";
  }
}
