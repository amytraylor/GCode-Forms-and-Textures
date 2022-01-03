//assume mm dimensions
int machineXDim = 140;
int machineYDim = 280;
int machineZDim = 140;

PVector[] v;// = new PVector[900];//was 625
int layers, numPointsPerLayer;
float radius, angleStep;// = 10;
//float radius  =450;
float theta;
int p = 0;
int div;
float mP;
float extrusionRate = 1.0;

PrintWriter output;


void setup() {
  size(900, 900, P3D);
  smooth();
  output = createWriter("gcodeTest.gcode");
  mP=height/2;

  layers = 50;
  numPointsPerLayer= 60;
  v = new PVector[layers*numPointsPerLayer];
  radius = 50;//(v.length/layers/2
  float decrement = (layers/radius)/10;
  //theta = (layers*TWO_PI)/v.length;
  theta = 0;
  angleStep = TWO_PI/numPointsPerLayer;
  div = numPointsPerLayer/30;





  for (int t = 0; t<v.length; t++) {
    if (t%div==0) {
      float cSin = map(sin(t/(TWO_PI*layers)), -1, 1, 1.05, 1.55);//version2
      //float cSin2 = map(sin(t/(TWO_PI*layers)), -1, 1, 0.8, 1.5);//version2
      //float cSin = map(sin(t/TWO_PI), -1, 1, 0.9, 1.1);//version2
      //float cSin = map(sin(t), -1, 1, 0.8, 1.2);//version1
      v[t] = new PVector((radius*cSin)*cos(theta), t*0.1, (radius*cSin)*sin(theta));
    } else {
      v[t] = new PVector(radius*cos(theta), t*0.1, radius*sin(theta));
    }
    theta=t*angleStep;
    //radius-=decrement;//layers/rad
  }
  text("end radius: radius-=decrement;//layers/rad/10: " + radius, 15, 290);
  //p=v.length-1;
  //println(p);
}

void draw() {
  background(200);
  int inc =1;

  //if (p>(inc+1)) {
  //  p-=inc;
  //  float c = map(p, v.length, 0, 255, 0);
  //  pushMatrix();
  //  translate(width/2, mP, 0);
  //  stroke(c, c/10, 255-c);
  //  strokeWeight(5);
  //  point(v[p].x, v[p].y, v[p].z);
  //  strokeWeight(1);
  //  line(v[p].x, v[p].y, v[p].z, v[p+1].x, v[p+1].y, v[p+1].z);
  //  popMatrix();
  //}

  for (int p = v.length-1; p>1; p--) {
    //if(p>0){
    //  p--;
    //}
    float c = map(p, v.length, 0, 255, 0);
    pushMatrix();
    translate(width/2, mP, 0);
    stroke(c, c/10, 255-c);
    strokeWeight(5);
    point(v[p].x, v[p].y, v[p].z);
    strokeWeight(1);
    line(v[p].x, v[p].y, v[p].z, v[p-1].x, v[p-1].y, v[p-1].z);
    popMatrix();
    output.println("G1 X" + v[p].x +" Y-"+ v[p].y +" Z" + v[p].z +" E" + extrusionRate);
  }
  //print to file


  fill(255);
  rect(0, 0, width, 300);
  textSize(25);
  fill(0);
  text("float cSin = map(sin(t/(TWO_PI*(layers))), -1, 1, 1.05, 1.55);", 15, 50);
  text("layer divisor: " + div, 12, 90);
  text("theta: " + theta, 15, 130);
  text("starting radius: " + radius, 15, 170);
  text("numPointsPerLayer: " + numPointsPerLayer, 15, 210);
  text("layers: " + layers, 15, 250);
}

void mousePressed() {
  mP=mouseY;
}

void keyPressed() {
  if (key=='s') {
    saveFrame("trig-###"+frameCount+".png");
  }

  if (key=='o') {
    output.flush(); // Writes the remaining data to the file
    output.close(); // Finishes the file
    exit(); // Stops the program
  }
}
