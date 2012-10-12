//  soundOrbiter writted by Patricio Gonzalez Vivo
//  Developing a Better Together
//  http://www.patriciogonzalezvivo.com
//

class soundStar{
  AudioInput starInput;
  
  soundOrbit orbit;
  soundOrbit orbits[] = new soundOrbit[0];
  
  float minRadio = 30;
  float maxRadio;
  
  float t = 0;
  float speed = 0.03;

  int selected;
  
  int x = 0;
  int y = 0;

  boolean recording = false;
  boolean stop = false;
  boolean repeat = true;
  
  String starName = "audio";
  int recordNumber = 0;

  
  soundStar(AudioInput starInput_, String starName_){
    starName = starName_;    
    starInput = starInput_;
  }
  
  soundStar(AudioInput starInput_, String starName_,int x_, int y_){
    starName = starName_;    
    starInput = starInput_;
    
    x = x_;
    y = y_;
  }
  
  void startRecording(){
    orbit = new soundOrbit(starInput,t, (String)(starName + "-" +recordNumber) );
    recording = true;
    recordNumber++;
  }

  void endRecording(){
    orbit.endRecording();
    recording = false;
  
    orbits = (soundOrbit[]) append(orbits,orbit);
  
    selected = orbits.length - 1;
  }
  
  
  void deleteOrbit(){
    soundOrbit[] temp = new soundOrbit[0];
    
    for(int i = 0; i < orbits.length; i++){
      if (i != selected ) temp = (soundOrbit[]) append(temp, orbits[i]);
    }
    
    orbits = temp;
  }
  
  
  void deleteOrbit(int n_){
    soundOrbit[] temp = new soundOrbit[0];
    
    for(int i = 0; i < orbits.length; i++){
      if (i != n_ ) temp = (soundOrbit[]) append(temp, orbits[i]);
    }
    
    orbits = temp;
  }
  
  
  void moveFowardOrbit(){
    orbits[selected].startT += speed;
  }
  
  
  void moveFowardOrbit(int n_){
    orbits[n_].startT += speed;
  }
  
  
  void moveBackwardOrbit(){
    orbits[selected].startT -= speed;
  }
  
  
  void moveBackwardOrbit(int n_){
    orbits[n_].startT -= speed;
  }
  
  
  void nextFrame(){
    if (!stop) t += speed;
    
    if ( t >= TWO_PI ){
      t = 0;
      if (!repeat) stop = true;
    }
    
    for(int i = 0; i < orbits.length; i++){
      orbits[i].update(t);
    } 
  }
  
  void display(){
    pushMatrix();
    translate(x,y);
      if (!stop) displayScanner();
      displayOrbits();
      displayStar();
    popMatrix();
  }

  
  void display(float x_, float y_){
    pushMatrix();
      translate(x_,y_);
      if (!stop) displayScanner();
      displayOrbits();
      displayStar();
    popMatrix();
  }
  
  void displayScanner(){
    float extremeX = maxRadio * cos(t);
    float extremeY = maxRadio * sin(t);
    
    stroke(255,255);
    strokeWeight(1);
    line(0, 0, extremeX, extremeY);
    
    stroke(255,100);
    strokeWeight(3);
    line(0, 0, extremeX, extremeY);
  }

  
  void displayOrbits(){
    float radio = minRadio; 
    
    for(int i = 0; i < orbits.length; i++){          
      if (selected == i) orbits[i].displaySelected(speed, radio);
      else orbits[i].display(speed,radio);
      orbits[i].checkOver(t,radio);
      
      radio += orbits[i].maxLevel; 
    }
    
    maxRadio = radio;
  }
  
  void displayStar(){
    float level = starInput.mix.level()*1000;
    if (recording) orbit.addLevel(level);
    
    noStroke();
    fill(255,50);
    ellipse(0,0,level,level);
    ellipse(0,0,level-level/4,level-level/4);
    ellipse(0,0,level/2,level/2);
    ellipse(0,0,level/4,level/4);
  }
}


/* ===================================================================================== Orbits of sounds Records */

class soundOrbit{
  
  AudioRecorder rec;
  AudioPlayer player;
  
  float[] levels = {1};
  float maxLevel = 5;
  
  float time = 0;
  
  float startT;
  
  float startX,startY;  
  float lastX,lastY;
  float endX,endY;
  
  int zone = 0;
  
  boolean over = false;
  
  soundOrbit(AudioInput soundInput_,float startT_, String string_ ){
    startT = startT_;
    
    rec = minim.createRecorder(soundInput_, string_ + ".wav", true);
    startRecording();
  }
  
  
  void startRecording(){
    rec.beginRecord();
  }
  
  
  void addLevel(float level_){
    level_ = map(level_,0,400,1,100);
    levels = append(levels,level_);
  }
  
  
  void endRecording(){
    rec.endRecord();
    
    for(int i = 5; i < levels.length; i++){
      if (levels[i] > maxLevel){
        maxLevel = levels[i];
      }
    }
  }
  
  
  void checkOver(float t_, float radio_){
    float nowX = radio_ * cos(t_);
    float nowY = radio_ * sin(t_);
    
    zone = (int) dist(lastX,lastY,nowX,nowY);
    
    lastX = nowX;
    lastY = nowY;
    
    if ( (int) dist(startX,startY,nowX,nowY) <= zone){
     if (!over){
         play();
     }  
     over = true;
    }
    
    if ( (int) dist(endX,endY,nowX,nowY) <= zone){
      over = false;
    }
  }
  
  
  void play(){
    if ( player != null ){
        player.close();
    }
    player = rec.save();
    player.play();
  }
  
  
  void drawPlanet( int alfa_, float radio_, float moment_,float level_){
    float locX = radio_ * cos(moment_);
    float locY = radio_ * sin(moment_);
    
    float nowX = radio_ * cos(time);
    float nowY = radio_ * sin(time);
    
    if ((int)dist(nowX,nowY,locX,locY) <= zone ) fill(color(255,alfa_)); 
    else fill(color(255,alfa_-50));
    
    noStroke();
    
    ellipse(locX, locY, level_, level_);
  }  
  
  
  
  void drawPlanets(int alfa_, float speed_, float radio_){
    startX = radio_ * cos(startT);
    startY = radio_ * sin(startT);
    
    float drawT = startT;
    
    for (int i = 0; i < levels.length ; i++ ){      
      drawPlanet(alfa_/2, radio_, drawT, levels[i]);
      drawPlanet(alfa_, radio_, drawT, levels[i] - levels[i]/3);   
      
      if (i == levels.length-1){
        endX = radio_ * cos(time);
        endY = radio_ * sin(time);
      }
      
      drawT += speed_;
    }
  }
  
  void drawOrbit(int alfa_, int stroke_, float radio_){
    noFill();
    stroke(color(255,alfa_));
    strokeWeight(stroke_);
    ellipse(0,0,radio_*2,radio_*2);
  }
  
  void display(float speed_, float radio_){
    drawPlanets(70,speed_, radio_);
    drawOrbit(100,1, radio_);
  }
  
  void displaySelected(float speed_, float radio_){
    drawPlanets(100,speed_, radio_);
    drawOrbit(50,3, radio_);
    drawOrbit(170,1, radio_);
  }
  
  void update(float time_){
    time = time_;
  }
}
