//Amy Traylor
//December 29, 2021
//Code maps a bitmap image to a 3D surface

//cameras to view different angles
import damkjer.ocd.*;
Camera camera0, camera1, camera2;
int currentCam = 0;
int camX, camY, camZ, aimX, aimY, aimZ;

GCodeMaker pla;
PVector[] pts;//to contain points
color [] c;//to contain color/brightness data of each point
//variables to draw 3d form
float theta, radius, angleStep, numPtsPerLayer;

PImage img;


float layerHeight = 0.30;
int count=0;
//protusion max amount for each pixel
float protrude;

void setup() {
  size(900, 900, P3D);
  smooth(8);
  //  GCodeMaker(int _mode, float _nozzleSize, float _pathWidth, float _layerHeight, float _extrudeRate, float _filamentDiameter)
  pla = new GCodeMaker(0, 0.4, 0.4, layerHeight, 1, 1.75);
  img = loadImage("dots_gradient.png");
  img.resize(800, 200);
  c = new color[img.width*img.height];
  pts = new PVector[img.height*img.width];

  radius = (img.width/PI)/2;
  protrude = radius/20;
  println(protrude);
  theta= 0;
  numPtsPerLayer =img.width;
  angleStep=TWO_PI/numPtsPerLayer;

  pla.printTitle("TextureGCode_"+day()+hour()+minute()+second(), "Amy Traylor");
  pla.printParameters(radius, 0, layerHeight, img.height, img.width);
  pla.start(500, 0, 0, 0, 250, 250, 200);

  //camera setup
  camera0 = new Camera(this, 0, 0, 0, width/2, height/2, 0, 0, 1, 0);
  camera1 = new Camera(this, 0, height*0.25, 500);
  camera2 = new Camera(this, width, height/2, -100);
  camera0.aim(width/2, height/2, 0);
  camera1.aim(width/2, height*0.25, 0);
  camera2.aim(width/2, height*0.25, 0);

  createPoints();
  loadPoints();
  pla.end();
  pla.export();
}


void draw() {
  background(255, 255, 0);
  switch(currentCam) {
  case 0:
    camera0.feed();
    break;
  case 1:
    camera1.feed();
    break;
  case 2:
    camera2.feed();
    break;
  }
  
  drawPoints();
}

void createPoints() {
  for (int x=0; x<img.width; x++) {
    for (int y=0; y<img.height; y++) {
      int inc = x+y*img.width;
      float current = smoothStep(inc, protrude);      
      c[inc] = int(current);
      pts[inc] = new PVector(100+(radius+c[inc])*sin(theta), 100+(radius+c[inc])*cos(theta), y*layerHeight);
    }
    theta+=angleStep;
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

  pushMatrix();
  translate(width/2, height/4, 0);
  //if(count<v.length){
  //  count+=1; //println(count);
  for (int count=0; count<pts.length; count++ ) {
    stroke(map(c[count], 0, protrude, 235, 200), map(c[count], 0, protrude, 0, 155), map(c[count], 0, protrude, 100, 200));
    strokeWeight(1);
    if (count==0) {
      line(pts[count].x, pts[count].y, pts[count].z, pts[count+1].x, pts[count+1].y, pts[count+1].z);
    } else {
      line(pts[count].x, pts[count].y, pts[count].z, pts[count-1].x, pts[count-1].y, pts[count-1].z);
    }
    if (count%numPtsPerLayer==0) {
      pushMatrix();
      translate(pts[count].x, pts[count].y, pts[count].z);
      fill(0, 255, 0);
      ellipse(0, 0, 10, 10);
      popMatrix();
    }
  }

  popMatrix();
}

void mouseMoved() {
  camera0.circle(radians(mouseX - pmouseX));
  camera1.circle(radians(mouseX - pmouseX));
  camera2.circle(radians(mouseX - pmouseX));
}

void keyPressed() {
  if (key=='0')currentCam=0;
  if (key=='1')currentCam=1;
  if (key=='2')currentCam=2;  

  if (key=='s') {
    saveFrame("textureGcode-"+second()+minute()+hour()+".png");
  }
}
