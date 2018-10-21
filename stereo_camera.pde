import processing.video.*;

Capture cameraL;
Capture cameraR;

PImage img;
PGraphics Limg;
PGraphics Rimg;
PGraphics uniImg;

int lensWidth;
int lensHeight;

int lensCenterX;
int lensCenterY;

int cameraWidth = 640;
int cameraHeight = 480;
int num = 12;
float[] posX;
float[] posY;
float[] posU;
float[] posV;
int[] vertexes;

void setup() {
  size(853, 480, P3D);
  String[] cameras = Capture.list();
  
  int r = -1;
  int l = -1;
  for(int i = 0; i < cameras.length; ++i){
    String[] attr = cameras[i].split(",");
    if(attr[1].split("=")[1].equals(cameraWidth + "x" + cameraHeight) && attr[2].split("=")[1].equals("30")){
      if(r == -1)
        r = i;
      else if(l == -1)
        l = i;
      else
        break;
    }
  }
  
  cameraL = new Capture(this, cameras[l]);
  cameraR = new Capture(this, cameras[r]);
  cameraL.start();
  cameraR.start();
  
  println("camera was initialized");
  
  lensWidth = width / 2;
  lensHeight = height;
  lensCenterX = lensWidth / 2;
  lensCenterY = lensHeight / 2;
  
  Limg = createGraphics(cameraWidth,cameraHeight);
  Rimg = createGraphics(cameraWidth,cameraHeight);
  uniImg = createGraphics(cameraWidth,cameraHeight);
  
  posX = new float[(num + 1) * (num + 1)];
  posY = new float[(num + 1) * (num + 1)];
  posU = new float[(num + 1) * (num + 1)];
  posV = new float[(num + 1) * (num + 1)];
  vertexes = new int[num * num * 4];
  
  for(int i = 0; i < posX.length; ++i){
    posX[i] = ((float)(i % (num + 1)) / (float)num);
    posU[i] = posX[i];
  }
  for(int i = 0; i < posY.length; ++i){
    posY[i] = ((float)(int)(i / (num + 1)) / (float)num);
    posV[i] = posY[i];
  }
  
  for(int i = 0, j = 0; i < num * num * 4; i+=4, ++j){
    vertexes[i] = j + (int)(j / num);
    vertexes[i + 1] = j + (int)(j / num) + 1;
    vertexes[i + 2] = j + (int)(j / num) + 2 + num;
    vertexes[i + 3] = j + (int)(j / num) + 1 + num;
  }
  
  float k1 = -0.20;
  float k2 = 0.005;
  float p1 = 0;
  float p2 = 0;
  for(int i = 0; i < posX.length; ++i){
    posX[i] = (posX[i] - 0.5) * 2;
    posY[i] = (posY[i] - 0.5) * 2;
    posU[i] *= cameraWidth;
    posV[i] *= cameraHeight;
    
    float xx = pow(posX[i], 2);
    float yy = pow(posY[i], 2);
    
    float b = k2 * pow(xx + yy,2) + k1 * (xx + yy) + 1;
    float distX = p2 * (3 * xx + yy) + posX[i] * b + 2 * p1 * posX[i] * posY[i];
    float distY = p1 * (3 * yy + xx) + posY[i] * b + 2 * p2 * posX[i] * posY[i];
    
    posX[i] = lensCenterX + distX * lensWidth / 2;
    posY[i] = lensCenterY + distY * lensHeight / 2;
  }
  
  println("mesh was generated");
}

void draw(){
  uniImg.beginDraw();
  
  uniImg.clear();
  uniImg.stroke(255);
  uniImg.strokeWeight(2);
  uniImg.line(uniImg.width/2-10,uniImg.height/2,uniImg.width/2+10,uniImg.height/2);
  uniImg.line(uniImg.width/2,uniImg.height/2-10,uniImg.width/2,uniImg.height/2+10);
  
  uniImg.endDraw();
  
  
  
  Limg.beginDraw();
  Limg.clear();
  Limg.image(cameraL.copy(),0,0);
  Limg.image(uniImg.copy(),0,0);
  Limg.endDraw();
  
  Rimg.beginDraw();
  Rimg.clear();
  Rimg.pushMatrix();
  Rimg.translate(Rimg.width, Rimg.height);
  Rimg.rotate(PI);
  Rimg.image(cameraR.copy(),0,0);
  Rimg.popMatrix();
  Rimg.image(uniImg.copy(),0,0);
  Rimg.endDraw();
  
  noStroke();
  pushMatrix();
  translate(30,0);
  beginShape(QUADS);
  for(int i = 0; i < vertexes.length; ++i){
    if(i % 4 == 0){
      texture(Limg);
    }
    int j = vertexes[i];
    vertex(posX[j],posY[j],posU[j],posV[j]);
  }
  endShape();
  popMatrix();
  
  pushMatrix();
  translate(370,0);
  beginShape(QUADS);
  for(int i = 0; i < vertexes.length; ++i){
    if(i % 4 == 0){
      texture(Rimg);
    }
    int j = vertexes[i];
    vertex(posX[j],posY[j],posU[j],posV[j]);
  }
  endShape();
  popMatrix();
}

void captureEvent(Capture camera){
  camera.read();
}

void keyPressed() {

  // Pのキーが入力された時に保存
  if(key == 'p' || key == 'P') {

    // デスクトップのパスを取得
    String path  = System.getProperty("user.home") + "/Desktop/processing.png";

    // 保存
    save(path);

    // ログ用途
    println("screen saved." + path); 
  }
}
