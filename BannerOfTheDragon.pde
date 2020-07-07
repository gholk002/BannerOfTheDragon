
float radius = 4;
float left = 100;
float top = 50;
float restlen = 10; //rest length of spring
float ks = -500; //spring constant
float kd = -800; //dampening factor
float mass = 1;
Vec3 gravity = new Vec3(0,2,0);
int cols = 40;
int rows = 40;
PImage dragonbanner;
PImage sky;
PImage wood;
float zoff = 0;

Vec3 pos[][] = new Vec3[rows][cols];
Vec3 vel[][] = new Vec3[rows][cols];

void setup() {
  size(1000, 548, P3D);
  surface.setTitle("Banner of the Dragon");
  dragonbanner = loadImage("DragonBanner.jpg");
  sky = loadImage("sky.jpg");
  wood = loadImage("wood.jpg");
  initScene();
}

void initScene(){
  for(int i = 0; i<rows; i++){
    for(int j = 0; j<cols; j++){
      pos[i][j] = new Vec3(left + restlen*j, top + restlen*i, 0);
      vel[i][j] = new Vec3(0,0,0);
    }
  }
}

void update(float dt){
  
  Vec3 nvel[][] = new Vec3[rows][cols];
  for(int i = 0; i<rows; i++){
    for(int j = 0; j<cols; j++){
      nvel[i][j] = vel[i][j];
    }
  }
  
  for(int i = 0; i< rows-1; i++){ //vertical force
    for(int j = 0; j< cols; j++){
      Vec3 rope = pos[i+1][j].minus(pos[i][j]);
      Vec3 rest = rope.normalized().times(restlen); //restlen in direction
      Vec3 springF = rest.minus(rope).times(ks); //magnitude of force
      
      rope.normalize();
      float v1 = dot(rope,vel[i][j]); //old velocities
      float v2 = dot(rope,vel[i+1][j]);
      Vec3 dampF = rope; //direction of force
      dampF.times(kd*(v1 - v2)/mass); //magnitude of force
      nvel[i][j].add(springF.times(dt).plus(dampF.times(0.5*dt)));
      nvel[i+1][j].subtract(springF.times(dt).plus(dampF.times(0.5*dt)));
      
    }
  }
  for(int i = 0; i< rows; i++){ //horizontal force
    for(int j = 0; j< cols-1; j++){
      Vec3 rope = pos[i][j+1].minus(pos[i][j]);
      Vec3 rest = rope.normalized().times(restlen); //restlen in direction
      Vec3 springF = rest.minus(rope).times(ks); //magnitude of force
      
      rope.normalize();
      float v1 = dot(rope,vel[i][j]); //old velocities
      float v2 = dot(rope,vel[i][j+1]);
      Vec3 dampF = rope; //direction of force
      dampF.times(-kd*(v1 - v2)/mass); //magnitude of force
      nvel[i][j].add(springF.times(dt).plus(dampF.times(dt)));
      nvel[i][j+1].subtract(springF.times(dt).plus(dampF.times(dt)));
      
    }
  }
  
  float xoff = 0;
  for(int i = 0; i<rows; i++){
    float yoff = 0;
    for(int j = 0; j<cols; j++){
      nvel[i][j].plus(gravity.times(dt)); //gravity added
      float windx = map(noise(xoff, yoff, zoff), 0, 0.1, 0.1, 0.2);
      float windz = map(noise(xoff +5,yoff +5, zoff), 0, 1, -1, 1);
      Vec3 wind = new Vec3(windx,0,windz);
      vel[i][j] = nvel[i][j].plus(wind);
      yoff += 0.01;
      
    }
    xoff += 0.01;
  }
  zoff+=0.01;
  vel[0][0].mul(0); //locking top left
  vel[rows-1][0].mul(0); //locking bottom left
  //vel[0][cols-1].mul(0);
  
  
  for(int i = 0; i<rows; i++){
    for(int j = 0; j<cols; j++){
      if(j == 0)
        vel[i][j].mul(0);
      pos[i][j].add(vel[i][j].times(dt));
    }
  }
  
}

void draw(){
  background(sky);
  lights();
  update(1/frameRate);
  noFill();
  noStroke();
  textureMode(NORMAL);
  for(int i = 0; i < rows-1; i++){
    beginShape(TRIANGLE_STRIP);
    texture(dragonbanner);
    for (int j = 0; j< cols; j++){
      float x1 = pos[i][j].x;
      float y1 = pos[i][j].y;
      float z1 = pos[i][j].z;
      float u = map(j, 0, cols-1, 0, 1);
      float v1 = map(i, 0, rows-1, 0, 1);
      vertex(x1, y1, z1, u, v1);
      float x2 = pos[i+1][j].x;
      float y2 = pos[i+1][j].y;
      float z2 = pos[i+1][j].z;
      float v2 = map(i+1, 0, rows-1, 0, 1);
      vertex(x2, y2, z2, u, v2);
    }
    endShape();
  }
  noStroke();
  noFill();
  for(int i = int(top); i < height; i+=2){
    beginShape(TRIANGLE_STRIP);
    texture(wood);
    for (int j = int(left) - 20; j <left+2 ; j+=2){
      float x1 = j;
      float y1 = i;
      float u = map(j, int(left) - 20, left+2, 0, 1);
      float v1 = map(i, int(top), height, 0, 1);
      vertex(x1, y1, 0, u, v1);
      float x2 = j+2;
      float y2 = i+2;
      float v2 = map(i+1, int(top), height, 0, 1);
      vertex(x2, y2, 0, u, v2);
    }
    endShape();
  }
  
  stroke(200);
  strokeWeight(1);
  beginShape();
  for (int j = 0; j< cols-1; j++){
    float x1 = pos[0][j].x;
    float y1 = pos[0][j].y;
    float z1 = pos[0][j].z;
    vertex(x1, y1, z1);
    float x2 = pos[0][j+1].x;
    float y2 = pos[0][j+1].y;
    float z2 = pos[0][j+1].z;
    vertex(x2, y2, z2);
  }
  for (int i = 0; i< rows-1; i++){
    float x1 = pos[i][cols-1].x;
    float y1 = pos[i][cols-1].y;
    float z1 = pos[i][cols-1].z;
    vertex(x1, y1, z1);
    float x2 = pos[i+1][cols-1].x;
    float y2 = pos[i+1][cols-1].y;
    float z2 = pos[i+1][cols-1].z;
    vertex(x2, y2, z2);
  }
  for (int j = cols-1; j > 0; j--){
    float x1 = pos[rows-1][j].x;
    float y1 = pos[rows-1][j].y;
    float z1 = pos[rows-1][j].z;
    vertex(x1, y1, z1);
    float x2 = pos[rows-1][j-1].x;
    float y2 = pos[rows-1][j-1].y;
    float z2 = pos[rows-1][j-1].z;
    vertex(x2, y2, z2);
  }
  for (int i = rows-1; i > 0; i--){
    float x1 = pos[i][0].x;
    float y1 = pos[i][0].y;
    float z1 = pos[i][0].z;
    vertex(x1, y1, z1);
    float x2 = pos[i-1][0].x;
    float y2 = pos[i-1][0].y;
    float z2 = pos[i-1][0].z;
    vertex(x2, y2, z2);
  }
  endShape();
 

}
