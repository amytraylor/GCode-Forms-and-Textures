//Amy Traylor
//December 29, 2021
//Code maps a bitmap image to a 3D surface


GCodeMaker pla, clay;
PVector[] ptsPLA, ptsClay;//to contain points
//PVector[] ptsLoad;// to add translation for  printer bed = new PVector[pts.length];
float [] cR, cT, cD;//to contain color/brightness data of each point, radius, texture, detail
float [] cLH;// layer height data
//variables to draw 3d form
float theta, radius, angleStep, numPtsPerLayer, layers;
float amp, freq, phase;

PImage img, imgTexture, imgDetail, imgLayerHeight;
String imgRad, imgText, imgDet;

float nozzleSizePLA = 0.4;
float nozzleSizeClay = 3.0;
float layerHeightPLA = 0.2;
float layerHeightPercent = 0.33;
float layerHeightClay = nozzleSizeClay*layerHeightPercent;
float extrudeRateClay = 3.0;
float claySpeed = 1000;
float startingZ =21; //in case you are printing on a matrix

int count=0;
float xpos, ypos, zpos;
float zoom=5;

PGraphics form1, form2;
String[] params;


void setup() {
  size(1600, 900, P3D);
  form1=createGraphics(width, height, P3D);
  form2=createGraphics(width, height, P3D);

  // GCodeMakerPLA(float _nozzleSize, float _pathWidth, float _layerHeight, float _extrudeRate, float _extrusionMultiplier
  pla = new GCodeMaker(nozzleSizePLA, nozzleSizePLA, layerHeightPLA, 1, 1);
  //GCodeMaker(float _nozzleSize, float _layerHeightClay, float _extrudeRate, float _speed) {
  clay = new GCodeMaker(nozzleSizeClay, layerHeightClay, extrudeRateClay, claySpeed);
  imgRad = "linear_blur_green-31_41.png";//"linear_blur_green-31_41.png"//"linear_blur_green-32_47.png"
  imgText = "saskia4.png";//radial_blur_red-19_45.png
  imgDet = "radial_blur_red-15_12.png"; //linear_blur_blue-50_22.png";//"linear_blur_blue-37_55.png"
  img = loadImage(imgRad);
  imgTexture= loadImage(imgText);
  imgDetail= loadImage(imgDet);//linear_blur_blue-37_55.png
  //imgLayerHeight = loadImage("layerheight_gradient_green3.png");
  //img.get(0,0,int(img.width), int(img.height*0.75));
  img.resize(180, 45);
  imgTexture.resize(img.width, img.height);
  imgDetail.resize(img.width, img.height);
  //imgLayerHeight.resize(360, 360);
  cR = new float[img.width*img.height];
  cT = new float[imgTexture.width*imgTexture.height];
  cD = new float[imgDetail.width*imgDetail.height];
  //cLH = new float[imgLayerHeight.width*imgLayerHeight.height];
  ptsPLA = new PVector[img.height*img.width];
  ptsClay = new PVector[img.height*img.width];

  radius = 70;
  theta= 0;
  layers = img.height;
  numPtsPerLayer =img.width;
  angleStep=TWO_PI/numPtsPerLayer;
  //angleStep=7.5*(TWO_PI/360);

  pla.printTitle("TextureGCode_"+day()+hour()+minute()+second(), "Amy Traylor");
  pla.printParameters(imgRad, imgText, imgDet, radius, layerHeightPLA, img.height, img.width, "");
  pla.start(500, 0, 0, 0, 250, 250, 200);

  clay.printTitle("TextureGCode_"+day()+hour()+minute()+second(), "Amy Traylor");
  clay.printParameters(imgRad, imgText, imgDet, radius, layerHeightClay, img.height, img.width, "");
  clay.start(1000, 0, 0, startingZ, 250, 250, 200);


  params = new String[10];
  params[0] = "radius: " + radius;
  params[1] ="layers: " + layers;
  params[2] ="layerHeightClay: " + layerHeightClay +" layerHeightPLA: " + layerHeightPLA;
  params[3] ="numPtsPerLayer: " + numPtsPerLayer;
  params[4] ="image silhouette: " + imgRad;
  params[5] ="silhouette range: " ;
  //params[6] ="image texture: " + imgText;
  //params[7] ="texture range: ";
  //params[8] ="image detail: " + imgDet;
  //params[9] ="detail range: ";
  //combineImages();


  createBaseRadiusPoints(layerHeightPLA, ptsPLA);
    createBaseRadiusPoints(layerHeightClay, ptsClay);

  loadPoints();
  pla.end();
  pla.export();

  clay.end();
  clay.export();
}


void draw() {
  background(255, 255, 100);

  drawPoints(ptsClay, form1);
  drawPoints(ptsPLA, form2);

  image(form1, 0, 0, width/2, height);
  image(form2, width/2, 0, width/2, height);

  float tS = 25;
  textSize(18);
  fill(0);
  text("CLAY", 50, 25);
  text("PLA", width*0.66, 25);
  for (int i=0; i<6; i++) {//params.length
    text(params[i], 25, 50+tS*i);
  }
  text("amp mapped y from 0 to 5, 5 to 0: "+amp, 25, tS*8);
  text("freq: " + freq, 25, tS*9);
  text("cR[inc]+amp*sin(freq*theta)", 25, tS*10);
  //text("rT = cR[inc]+amp*sin(freq*theta+phase) ", 25, tS*8);
  //text("phase = (5*TWO_PI)*y/img.height", 25, tS*9);
}

PVector[] createBaseRadiusPoints(float _layerHeight, PVector[] _pts) {
  PVector[] pts = new PVector[_pts.length];
  pts = _pts;
  int moveOverOnBed = 200; //pla is 100, clay is 200
  for (int x=0; x<img.width; x++) {
    for (int y=0; y<img.height; y++) {
      int inc = x+y*img.width;
      //if (y>10) {
      //  if (x<img.width/2) {
      //    layerHeight = map(sin(x), -1, 1, 0.2, 0.21);
      //  } else {
      //    layerHeight = map(sin(x), -1, 1, 0.21, 0.2);
      //  }
      //} else {
      //  layerHeight=0.2;
      //}

      float currentRad = smoothStep(img, inc, 0, 255, radius*0.5, radius*1.0);
      float currentTexture = smoothStep(imgTexture, inc, 0, 255, 0, 5);
      float currentDetail = smoothStep(imgDetail, inc, 0, 255, -radius/10, radius/10);
      params[5] ="silhouette range: " + (radius*0.33) +"," + radius*1.0;
      params[7] ="texture range: " + (-radius/100) +"," + (radius/100);
      params[9] ="detail range: " + (-radius/10) +"," + (radius/10);
      //float currentLayerHeight = smoothStep(imgLayerHeight, inc, 0.15, 0.3);
      cR[inc] = currentRad;
      cT[inc] = currentTexture;
      cD[inc]=  currentDetail;

      phase = (5*TWO_PI)*y/img.height;//first multiplier shows how far it moves over from its neighbor pt
      // amp = 3;
      amp = map(y, 0, img.height, 0, 3);
      //if (y<img.height/2) {
      //  amp = map(y, 0, img.height/2, 0, 5);
      //} else {
      //  amp = map(y, img.height/2, img.height, 5, 0);
      //}
      freq = 12; //frequency of ripple//was 25
      float rT = cR[inc]+amp*sin(freq*theta);
      // float rT = cR[inc]+(y*0.05)+amp*sin(freq*theta+phase);
      // float rT = cR[inc];
      float xT = rT*sin(theta);
      float yT = rT*cos(theta);

      pts[inc] = new PVector(moveOverOnBed+xT, moveOverOnBed+yT, 21+y*_layerHeight);
    }

    theta+=angleStep;
  }
  return pts;
}



void loadPoints() {

  for (int i=0; i<ptsPLA.length-1; i++) {
    if (i==ptsPLA.length) {
      pla.writePoints(ptsPLA[i], ptsPLA[i-1]);
    } else {

      pla.writePoints(ptsPLA[i], ptsPLA[i+1]);
    }
  }

  for (int i=0; i<ptsClay.length-1; i++) {
    if (i==ptsClay.length) {
      clay.writePoints(ptsClay[i], ptsClay[i-1]);
    } else {
      clay.writePoints(ptsClay[i], ptsClay[i+1]);
    }
  }
}

PGraphics drawPoints(PVector[] _pts, PGraphics _form) {
  PGraphics form = createGraphics(width, height, P3D);
  form =_form;
  PVector[] pts = new PVector[_pts.length];
  pts = _pts;

  form.beginDraw();
  form.background(255, 255, 100);
  form.pushMatrix();
  form.translate(width/2+xpos, height/2+50+ypos, 600+zpos);
  float rot = map(mouseY, 0, height, 0.5, 2.0);

  form.rotateX(rot);//1.57);
  form.rotateY(0);
  form.rotateZ(radians(mouseX));

  for (int count=0; count<pts.length; count++ ) {
    //println(pts[count].z);
    form.stroke(map(pts[count].x, -radius, radius, 0, 255), map(pts[count].y, -radius/2, radius/2, 0, 255), map(pts[count].z, 0, radius, 0, 255));
    form.strokeWeight(1);
    if (count==0) {
      form.line(pts[count].x, pts[count].y, pts[count].z, pts[count+1].x, pts[count+1].y, pts[count+1].z);
    } else {
      form.line(pts[count].x, pts[count].y, pts[count].z, pts[count-1].x, pts[count-1].y, pts[count-1].z);
    }
    //if (count%numPtsPerLayer==0) {
    //  pushMatrix();
    //  translate(pts[count].x, pts[count].y, pts[count].z);
    //  fill(0, 255, 0);
    //  ellipse(0, 0, 10, 10);
    //  popMatrix();
    //}
  }

  form.popMatrix();
  form.endDraw();
  return form;
}

void keyPressed() {

  if (key=='s') {
    saveFrame("textureGcode-"+day()+"_"+hour()+minute()+second()+".png");
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
