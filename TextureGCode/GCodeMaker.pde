class GCodeMaker {
  ArrayList <String> gcode;
  //zero for PLA and 1 for clay
  int mode;
  float nozzleSize;
  float pathWidth;
  float layerHeight;
  float layerHeightPercent;
  float extrudeRate;
  float speed;
  float extrusionMultiplier;
  float filamentDiameter;
  float extrusion;

  float extruded_path_section;
  float filament_section;

  //Clay
  GCodeMaker(int _mode, float _nozzleSize, float _pathWidth, float _layerHeightPercent, float _extrudeRate, float _speed, float _extrusionMultiplier, float _filamentDiameter) {
    mode = _mode;
    nozzleSize = _nozzleSize; 
    pathWidth = _pathWidth;  
    layerHeightPercent = _layerHeightPercent;
    extrudeRate= _extrudeRate; //usually 3 to start
    speed = _speed; 
    extrusionMultiplier = _extrusionMultiplier; 
    filamentDiameter = _filamentDiameter;
    extrusion = 0;
    layerHeight = nozzleSize*layerHeightPercent;

    gcode = new ArrayList<String>();
  }

  //PLA
  GCodeMaker(int _mode, float _nozzleSize, float _pathWidth, float _layerHeight, float _extrudeRate, float _filamentDiameter) {
    mode = _mode;
    nozzleSize = _nozzleSize; 
    pathWidth = _pathWidth;  
    layerHeight = _layerHeight;
    extrudeRate= _extrudeRate; 
    filamentDiameter = _filamentDiameter;
    extrusion = 0;
    extrusionMultiplier =1.0;
    filament_section = PI * sq(filamentDiameter/2.0f);//why this math?

    gcode = new ArrayList<String>();
  }

  void printTitle(String title, String name) {
    gCommand(";_______________________________");
    gCommand(";" + title);
    gCommand(";" + name);
  }

  void printParameters(float radius, float radInc, float layerHeight, int layers, int numPtsPerLayer) {
    gCommand(";radius " + radius);
    gCommand(";radInc " + radInc);
    gCommand(";layerHeight " + layerHeight);
    gCommand(";layers " + layers);
    gCommand(";numPtsPerLayer " + numPtsPerLayer); 
    gCommand(";extrusionMultiplier" + extrusionMultiplier);
    gCommand(";_______________________________//");
  }
  void printParameters(float radius, float radInc, float layerHeight, int layers, int numPtsPerLayer, float wX2, float wY2, float div) {
    gCommand(";radius " + radius);
    gCommand(";radInc " + radInc);
    gCommand(";layerHeight " + layerHeight);
    gCommand(";layers " + layers);
    gCommand(";numPtsPerLayer " + numPtsPerLayer);
    gCommand(";wX2 " + wX2);
    gCommand(";wY2 " + wY2);
    gCommand(";div " + div);
    gCommand(";extrusionMultiplier" + extrusionMultiplier);
    gCommand(";_______________________________//");
  }

  void start(int _feedRate, float _startX, float _startY, float _startZ, int _widthTable, int _lengthTable, int _heightPrinter) {
    //I removed everything that seemed extraneous
    int feedRate = _feedRate;
    float startX = _startX;
    float startY = _startY;
    float startZ = _startZ;
    int widthTable = _widthTable;
    int lengthTable = _lengthTable;
    int heightPrinter = _heightPrinter;

    if (mode==0) {
      //gCommand("G91"); //Relative mode
      gCommand("M83");  //relative coords for E
      gCommand("G21");   //set units to mm

      gCommand("M104 S"+ 205);  //set hotend
      gCommand("M140 S"+60);    //set bed temp
      gCommand("M109 S"+ 205);    //wait for hotend temp
      gCommand("M190 S"+60);    //wait for bed temp

      //gCommand("G1 Z1"); //Up one millimeter
      gCommand("G28"); //Home X and Y axes
      gCommand("G90"); //Absolute mode
      //gCommand("G1 X" + (widthTable/2) + " Y"+ (lengthTable/2)); //Go to the center (modify according to your printer)
      //gCommand("G1 Z0"); //Go to height 0
      gCommand("G1 F" + feedRate);    //set the feedrate
      gCommand("G92 E0"); //Reset extruder value to 0
    } else {
      gCommand("G90");
      gCommand("M83");
      gCommand("G1 F3000 X" + startX + " Y" + startY + " Z" + startZ);
      gCommand("G1 F40000 E3000");//prime
    }
  }

  void writePoints(PVector pts0, PVector pts1) {
    if (mode==0) {
      extrusion=(extrudePLA(new PVector(pts0.x, pts0.y), new PVector(pts1.x, pts1.y))*extrusionMultiplier);
    } else {
      extrusion=(extrudeClay(new PVector(pts0.x, pts0.y ), new PVector(pts1.x, pts1.y ))*extrusionMultiplier);
    }
    gCommand("G1 X" + pts0.x + " Y" + pts0.y + " Z" + pts0.z +" E" + extrusion);
  }

  void end() {

    if (mode==0) {
      gCommand("G91"); //Relative mode
      gCommand("G1 E-4 F3000"); //Retract filament to avoid filament drop on last layer
      gCommand("G1 X0 Y100 Z20"); //Facilitate object removal
      gCommand("G1 E4"); //Restore filament position
      gCommand("M 107"); //Turn fans off
    } else {
      gCommand("M83");
      gCommand("G91"); //Relative mode
      gCommand("G1 Z150 E-4000 F66666"); //Retract clay
      gCommand("G1 X0 Y100 Z200"); //Facilitate object removal
      gCommand("G90");
      gCommand("G28");
    }
  }

  void export() {

    if (mode==0) {
      String name_save = "GCodeTwinFormsClayPLA6" +day()+""+hour()+""+minute()+"_"+second()+"_.gcode";
      //convert from arraylist to array to save struings
      String[] arr_gcode = gcode.toArray(new String[gcode.size()]);
      saveStrings(name_save, arr_gcode);
    } else {
      String name_save = "gcode_CLAY" +day()+""+hour()+""+minute()+"_"+second()+"_.gcode";
      //convert from arraylist to array to save struings
      String[] arr_gcode = gcode.toArray(new String[gcode.size()]);
      saveStrings(name_save, arr_gcode);
    }
  }

  float extrudeClay(PVector p1, PVector p2) {
    float points_distance = dist(p1.x, p1.y, p2.x, p2.y);
    //float extrude_rate=3;//mm per mm travelled
    return points_distance*extrudeRate;
  }


  float extrudePLA(PVector p1, PVector p2) {
    float points_distance = dist(p1.x, p1.y, p2.x, p2.y);
    extruded_path_section = pathWidth*layerHeight;
    float volume_extruded_path = extruded_path_section*points_distance;
    return volume_extruded_path;
  }

  void gCommand(String command) {
    gcode.add(command);
  }
}
