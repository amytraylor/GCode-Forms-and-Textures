//Amy Traylor
//December 29, 2021
//Code maps a bitmap image to a 3D surface

//cameras to view different angles
import damkjer.ocd.*;
Camera camera0, camera1, camera2;
int currentCam = 0;
int camX, camY, camZ, aimX, aimY, aimZ;

GCodeMaker pla, clay;
PVector[] pts;//to contain points
float [] cR, cT, cD;//to contain color/brightness data of each point, radius, texture, detail
float [] cLH;// layer height data
//variables to draw 3d form
float theta, radius, angleStep, numPtsPerLayer;

PImage img, imgTexture, imgDetail, imgLayerHeight;


float layerHeight = 0.1;
float layerHeightClay = 3.0;
int count=0;
//protusion max amount for each pixel
float protrude;
float xpos, ypos, zpos;
float zoom=5;

void setup() {
  size(900, 900, P3D);
  smooth(8);
  //  GCodeMaker(int _mode, float _nozzleSize, float _pathWidth, float _layerHeight, float _extrudeRate, float _filamentDiameter)
  pla = new GCodeMaker(0, 0.4, 0.4, layerHeight, 1, 1.75);
  //GCodeMaker(int _mode, float _nozzleSize, float _pathWidth, float _layerHeightPercent, float _extrudeRate, float _speed, float _extrusionMultiplier, float _filamentDiameter) {
  clay = new GCodeMaker(1, 3, 3, 0.66, 3, 3);
  String imgRad = "linear_gradient_blur_20_2.png";
  img = loadImage(imgRad);
  imgTexture= loadImage("radial_gradient_grid4_drop24_23.png");
  imgDetail= loadImage("triangle_gradient-32_28.png");
  //imgLayerHeight = loadImage("layerheight_gradient_green3.png");
  //img.get(0,0,int(img.width), int(img.height*0.75));
  img.resize(255, 810);
  imgTexture.resize(img.width, img.height);
  imgDetail.resize(img.width, img.height);
  //imgLayerHeight.resize(360, 360);
  cR = new float[img.width*img.height];
  cT = new float[imgTexture.width*imgTexture.height];
  cD = new float[imgDetail.width*imgDetail.height];
  //cLH = new float[imgLayerHeight.width*imgLayerHeight.height];
  pts = new PVector[img.height*img.width];

  radius = 50;
  //radius = (img.width/PI)/2;
  // protrude = radius/50;
  //println(radius);
  theta= 0;
  numPtsPerLayer =img.width;
  angleStep=TWO_PI/numPtsPerLayer;

  pla.printTitle("TextureGCode_"+day()+hour()+minute()+second(), "Amy Traylor");
  //void printParameters(float radius, float radInc, float layerHeight, int layers, int numPtsPerLayer, float wX2, float wY2, flo
  pla.printParameters(imgRad, radius, 0, layerHeight, img.height, img.width);
  pla.start(500, 0, 0, 0, 250, 250, 200);

  clay.printTitle("TextureGCode_"+day()+hour()+minute()+second(), "Amy Traylor");
  //void printParameters(float radius, float radInc, float layerHeight, int layers, int numPtsPerLayer, float wX2, float wY2, flo
  clay.printParameters(imgRad, radius, 0, layerHeight, img.height, img.width);
  clay.start(500, 0, 0, 0, 250, 250, 200);

  //camera setup
  camera0 = new Camera(this, 0, 0, 0, width/2, height/2, 0, 0, 1, 0);
  camera1 = new Camera(this, 0, height*0.25, 500);
  camera2 = new Camera(this, width, height/2, -100);
  camera0.aim(width/2, height/2, 0);
  camera1.aim(width/2, height*0.25, 0);
  camera2.aim(width/2, height*0.25, 0);

  createBaseRadiusPointsPLA();

  loadPoints();
  pla.end();
  pla.export();

  clay.end();
  clay.export();
}


void draw() {
  background(255, 255, 100);
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

void createBaseRadiusPointsPLA() {
  int moveOverOnBed = 0; //pla is 100, clay is 200
  for (int x=0; x<img.width; x++) {
    for (int y=0; y<img.height; y++) {
      int inc = x+y*img.width;
      float currentRad = smoothStep(img, inc, 0, 255, radius*0.25, radius*1.0);
      float currentTexture = smoothStep(imgTexture, inc, 0, 255, -radius/2, radius/2);
      float currentDetail = smoothStep(imgDetail, inc, 0, 255, -5, 5);
      //float currentLayerHeight = smoothStep(imgLayerHeight, inc, 0.15, 0.3);
      cR[inc] = currentRad;
      cT[inc] = currentTexture;
      cD[inc]=  currentDetail;
      //cLH[inc] = currentLayerHeight;
      //pts[inc] = new PVector(moveOverOnBed+((cR[inc]+cT[inc]))*sin(theta),moveOverOnBed+((cR[inc]+cT[inc]))*cos(theta), y*layerHeight);
     // pts[inc] = new PVector(moveOverOnBed+cR[inc]*sin(theta),moveOverOnBed+cR[inc]*cos(theta), y*layerHeight);
     // pts[inc] = new PVector(moveOverOnBed+(cR[inc]*sin(theta))+cT[inc], moveOverOnBed+(cR[inc]*cos(theta))+cT[inc], y*layerHeight);
     // pts[inc] = new PVector(moveOverOnBed+((cR[inc]+cT[inc])*sin(theta)), moveOverOnBed+((cR[inc]+cT[inc])*cos(theta)), y*layerHeight);
      pts[inc] = new PVector(moveOverOnBed+((cR[inc]+cT[inc]+cD[inc])*sin(theta)), moveOverOnBed+((cR[inc]+cT[inc]+cD[inc])*cos(theta)), y*layerHeight);
      //pts[inc] = new PVector(moveOverOnBed+(radius+cR[inc])*sin(theta)+cT[inc]+cD[inc], moveOverOnBed+(radius+cR[inc])*cos(theta)+cT[inc]+cD[inc], y*layerHeight);
    }
    theta+=angleStep;
  }
}

//void createBaseRadiusPointsClay() {
//  int moveOverOnBed = 200; //pla is 100, clay is 200
//  for (int x=0; x<img.width; x++) {
//    for (int y=0; y<img.height; y++) {
//      int inc = x+y*img.width;
//      float currentRad = smoothStep(img, inc, 0, 255, radius, radius*2);
//      float currentTexture = smoothStep(imgTexture, inc, 100, 130, 0, radius/10);
//      float currentDetail = smoothStep(imgDetail, inc, 0, 255, 0, radius/20);
//     // float currentLayerHeight = smoothStep(imgLayerHeight, inc, 3*0.5, 4);
//      cR[inc] = int(currentRad);
//      cT[inc] = int(currentTexture);
//      cD[inc] = int(currentDetail);
//     // cLH[inc] = currentLayerHeight;
//      pts[inc] = new PVector(moveOverOnBed+(radius+cR[inc])*sin(theta)+cT[inc]+cD[inc], moveOverOnBed+(radius+cR[inc])*cos(theta)+cT[inc]+cD[inc], y*layerHeightClay);
//    }
//    theta+=angleStep;
//  }
//}


void loadPoints() {
  for (int i=0; i<pts.length-1; i++) {
    if (i==pts.length) {
      pla.writePoints(pts[i], pts[i-1]);
      clay.writePoints(pts[i], pts[i-1]);

      //extrusion=(extrudePLA(new PVector(pts[i].x, pts[i].y ), new PVector(pts[i+1].x, pts[i+1].y ))*extrusion_multiplier);
    } else {
      pla.writePoints(pts[i], pts[i+1]);
      clay.writePoints(pts[i], pts[i+1]);
      // extrusion=(extrudePLA(new PVector(pts[i].x, pts[i].y ), new PVector(pts[0].x, pts[0].y ))*extrusion_multiplier);
    }
  }
}

void drawPoints() {

  pushMatrix();
  translate((300-250)+xpos, (300-150)+ypos, zpos);
  //translate(300+xpos, 300+ypos, zpos);
  rotateX(1.55);
  rotateY(0.4);
  rotateZ(radians(mouseX));
  //if(count<v.length){
 //println(radians(mouseX));
  for (int count=0; count<pts.length; count++ ) {
    stroke(pts[count].x, pts[count].y, pts[count].z);
    strokeWeight(1);
    if (count==0) {
      line(pts[count].x, pts[count].y, pts[count].z, pts[count+1].x, pts[count+1].y, pts[count+1].z);
    } else {
      line(pts[count].x, pts[count].y, pts[count].z, pts[count-1].x, pts[count-1].y, pts[count-1].z);
    }
    //if (count%numPtsPerLayer==0) {
    //  pushMatrix();
    //  translate(pts[count].x, pts[count].y, pts[count].z);
    //  fill(0, 255, 0);
    //  ellipse(0, 0, 10, 10);
    //  popMatrix();
    //}
  }

  popMatrix();
}

void mouseMoved() {
  //camera0.circle(radians(mouseX - pmouseX));
  //camera1.circle(radians(mouseX - pmouseX));
  //camera2.circle(radians(mouseX - pmouseX));
}

void keyPressed() {
  if (key=='0')currentCam=0;
  if (key=='1')currentCam=1;
  if (key=='2')currentCam=2;

  if (key=='s') {
    saveFrame("textureGcode-"+second()+minute()+hour()+".png");
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
