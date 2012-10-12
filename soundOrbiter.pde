//  soundOrbiter writted by Patricio Gonzalez Vivo
//  Developing a Better Together
//  http://www.patriciogonzalezvivo.com
//

import ddf.minim.*;
Minim minim;
AudioInput in;

soundStar[] stars = new soundStar[1];

int sel = 0;

void setup(){
  size(800,600);
  smooth();
  frame.setTitle("soundOrbiter by Patricio Gonzalez Vivo");
  
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 2048);
  stars[0] = new soundStar(in,"audio");
}


void draw(){
  background(0,0,0);

  //stars[0].display(mouseX,mouseY);
  stars[0].display(width/2,height/2);
  
  stars[sel].nextFrame();
}

void keyPressed(){
  if ( key == '+' ) stars[sel].speed += 0.005;
  if ( key == '-' ) stars[sel].speed -= 0.005;
  
  if ( key == 'p' ) stars[sel].stop = !stars[sel].stop;
  if ( key == 'r' ) stars[sel].repeat = !stars[sel].repeat; 
  
  if ( keyCode == UP ) stars[sel].selected--;
  if ( keyCode == DOWN ) stars[sel].selected++;
  
  if ( keyCode == LEFT ) stars[sel].moveFowardOrbit();
  if ( keyCode == RIGHT ) stars[sel].moveBackwardOrbit();
  
  if ( key == 's' ) stars[sel].deleteOrbit();
  if ( keyCode == TAB) sel = (sel + 1)%stars.length;
  
  stars[sel].selected = constrain(stars[sel].selected,0,stars[sel].orbits.length-1);
  stars[sel].speed = constrain(stars[sel].speed,-0.4,0.4);
}

void mousePressed(){
  stars[sel].startRecording();
}

void mouseReleased(){
  stars[sel].endRecording();
}

void stop(){
  in.close();
  stars[0].starInput.close();
  minim.stop();
  super.stop();
}
