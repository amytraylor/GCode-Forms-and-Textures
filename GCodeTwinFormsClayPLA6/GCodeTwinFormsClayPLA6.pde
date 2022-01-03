ArrayList <String> gcode;
import damkjer.ocd.*;
Camera camera0, camera1, camera2;
int currentCam = 1;
int camX, camY, camZ, aimX, aimY, aimZ;
float xpos, ypos, zpos;
PGraphics textLayer;

GCodeMaker clay;
GCodeMaker pla;
PVector[] pts;
float startingZ = 25.0;//reset for different matrix heights
float layerHeightClay = 6;
float layerHeightPLA = 2;

//Waves Form
float current_z = startingZ;
float layerHeight = layerHeightPLA;
float radInc = 1.0;  

float waveX1=-100, waveX2=-10, waveY1, waveY2=-10;
float pX1, pX2, pY1, pY2;
float wX2 = 5, wY2 = 150;
float radius = 50, startRadius = radius;
float div = 10; //radius divisor for inner waves
float theta = 0, theta2 =0;
int numPtsPerLayer = 180;
float angleStep = TWO_PI/numPtsPerLayer, angleStep2 = 0.5*TWO_PI/numPtsPerLayer;
float layerInc = layerHeight/(TWO_PI/angleStep);
int layers = 50;
float zoom;

//float extrusion  = 0;

//end waves

void setup() {
  size(800, 800, P3D);
  //fullScreen(P3D);
  textLayer = createGraphics(width, height, P3D);
  background(0);
  gcode = new ArrayList<String>();

  //frameRate(5);
  //modes
  //zero is PLA, one is Clay
  //GCodeMaker(int _mode, float _nozzleSize, float _pathWidth, float _layerHeightPercent, 
  //float _extrudeRate, float _speed, float _extrusionMultiplier, float _filamentDiameter)
  // clay = new GCodeMaker(1, 3, 3, 2, 1, 500, 3.0, 3);
  //  GCodeMaker(int _mode, float _nozzleSize, float _pathWidth, float _layerHeight, float _extrudeRate, float _filamentDiameter)
  pla = new GCodeMaker(0, 0.4, 0.4, layerHeight, 1, 1.75);

  //void start(float _startX, float _startY, float _startZ, int _widthTable, int _lengthTable, int _heightPrinter)
  //clay.start(25, 25, 25, 400, 400, 500);
  //prusa
  pla.printTitle("GCodeTwinFormsClayPLA6_"+day()+hour()+minute()+second(), "Amy Traylor");
  pla.printParameters(startRadius, radInc, layerHeight, layers, numPtsPerLayer, wX2, wY2, div );
  pla.start(500, 0, 0, 0, 250, 250, 200);

  //createPoints();
  createWaveForm();
  loadPoints();
  //clay.end();
  pla.end();
  //clay.export();
  pla.export();

  //  camera0 = new Camera(this, width/2, height/2, 0, 0, 1, 0);
  //  camera1 = new Camera(this, 0, height*0.25, 0);
  //  camera2 = new Camera(this, width, height/2, -100);
  //  camera0.aim(width/2, height/2, -300);
  //  camera1.aim(width/2, height*0.25, 0);
  //  camera2.aim(width/2, height*0.25, 0);
  xpos =500; 
  ypos=450; 
  zpos = 675;
  zoom = 25;

  //println("angleStep: " + angleStep);
}


void draw() {
  //// println(layerInc);
  //switch(currentCam) {
  //case 0:
  //  camera0.feed();
  //  break;
  //case 1:
  //  camera1.feed();
  //  break;
  //case 2:
  //  camera2.feed();
  //  break;
  //}
  background(0);
  //translate(width/5, height/2);
  //drawForm();
  pushMatrix();
  //translate(75, 225, -100);
  translate(xpos, ypos, zpos);
  rotateX(PI/2);
  rotateZ(PI);
  drawPoints();
  popMatrix();

  textLayer.beginDraw();
  textLayer.background(0);
  textLayer.pushMatrix();
  textLayer.translate(0, 10, 0);
  //textLayer.translate(xpos, ypos, zpos);
  //textLayer.rotateX(-PI/2);
  textLayer.textSize(25);
  textLayer.stroke(255);
  textLayer.text("startRadius: " + startRadius, 50, 20);
  textLayer.text("endRadius: " + radius, 50, 50);
  textLayer.text("radInc: " + radInc, 50, 80);
  textLayer.text("layerHeight: " + layerHeight, 50, 110); 
  textLayer.text("layers: " + layers, 50, 140); 
  textLayer.text("numPtsPerLayer: " + numPtsPerLayer, 50, 170); 
  textLayer.text("wX2: " + wX2, 50, 200); 
  textLayer.text("wY2: " + wY2, 50, 230);
  textLayer.text("div: " + div, 50, 260);
  textLayer.popMatrix();
  textLayer.endDraw();
  image(textLayer, 0, 0);
}

void createWaveForm() {
  //layers=57;
  pts = new PVector[layers*numPtsPerLayer];
  //println(pts.length);
  for (int l = 0; l<layers; l++) {  

    for (int i=0; i<numPtsPerLayer; i++) {
      int count = l*numPtsPerLayer + i;
      //float speed = 0.25;
      waveX1 = sin(theta) *radius;
      waveY1 = cos(theta) *radius;
      
     // wX2+=random(1);
      //wY2+=random(1);
      waveX2 = sin(theta2 *wX2) * radius/div;//first number is busyness of line, last number is distance from line center
      waveY2 = cos(theta2 * wY2) * radius/div;//println(waveY1);
      
      pts[count] = new PVector(100+waveX1+waveX2, 100+waveY1+waveY2, current_z);
      theta+=angleStep;
      theta2+=angleStep2;
    } 
    current_z+=layerHeight;
    radius-=radInc;
  }
}


void createPoints() {
  //println(numPtsPerLayer);

  pts = new PVector[layers*numPtsPerLayer];

  for (int l = 0; l<layers; l++) {  
    //radius-=radInc;
    for (int i=0; i<numPtsPerLayer; i++) {
      int count = l*numPtsPerLayer + i;
      pts[count] = new PVector(sin(theta)*radius, cos(theta)*radius, current_z);
      theta=count*angleStep;
    }         
    current_z+=layerHeight;
  }
}

void loadPoints() {
  for (int i=0; i<pts.length-1; i++) {
    if (i==pts.length) {
      pla.writePoints(pts[i], pts[i-1]);

      //extrusion=(extrudePLA(new PVector(pts[i].x, pts[i].y ), new PVector(pts[i+1].x, pts[i+1].y ))*extrusion_multiplier);
    } else {
      pla.writePoints(pts[i], pts[i+1]);
      // extrusion=(extrudePLA(new PVector(pts[i].x, pts[i].y ), new PVector(pts[0].x, pts[0].y ))*extrusion_multiplier);
    }
  }
}

void drawPoints() {
  for (int i=0; i<pts.length-1; i++) {
    stroke(255);
    strokeWeight(1);
    stroke(255-i);
    if (i==0) {
      line(pts[i].x, pts[i].y, pts[i].z, pts[0].x, pts[0].y, pts[0].z);
    } else {
      line(pts[i].x, pts[i].y, pts[i].z, pts[i+1].x, pts[i+1].y, pts[i+1].z);
    }
    //if(i%numPtsPerLayer==0){
    //  pushMatrix();
    //  translate(pts[i].x, pts[i].y, pts[i].z);
    //  fill(255, 0, 0);
    //  ellipse(0,0, 25, 25);
    //  popMatrix();
    //}
  }
}

//void gCommand(String command) {
//  gcode.add(command);
//}

void keyPressed() {
  if (key=='0')currentCam=0;
  if (key=='1')currentCam=1;
  if (key=='2')currentCam=2;
  if (key=='s') {
    saveFrame("twinforms-"+second()+minute()+hour()+".png");
  }
  if (keyCode==UP) {
    ypos-=zoom; 
    println("ypos: " + ypos);
  }
  if (keyCode==DOWN) {
    ypos+=zoom; 
    println("ypos: " + ypos);
  }
  if (keyCode==LEFT) {
    xpos-=zoom; 
    println("xpos: " + xpos);
  }
  if (keyCode==RIGHT) {
    xpos+=zoom; 
    println("xpos: " + xpos);
  }
  if (key=='z') {
    zpos-=zoom; 
    println("zpos: " + zpos);
  }
  if (key=='x') {
    zpos+=zoom; 
    println("zpos: " + zpos);
  }
}
