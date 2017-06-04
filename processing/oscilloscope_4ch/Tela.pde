class Tela{
   int x,y,w,h;
   
   //constructor
   Tela(float xi, float yi, float wi, float hi){
      x=int(xi); y=int(yi); w=int(wi); h=int(hi);
   } 
   void display(){
      fill(0); stroke(0,0,255); strokeWeight(1);// noStroke();
      rect(x,y,w,h); 
      stroke(100);
      for (float lin=y; lin<y+h; lin+=h/12){
         line(x,lin,x+w,lin);
      }
      for (float col=x; col<x+w; col+=w/10){
          line(col,y,col,y+h);
       } 
   }
}