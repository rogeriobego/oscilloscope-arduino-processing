class Painel{
   int x,y,w,h;
   String tex="";
   String tex2="";
   Boolean piscar=false;
   
   //constructor
   Painel(String tex_, int x_, int y_, int w_, int h_){
     tex=tex_;
     x=x_; y=y_; w=w_; h=h_;
   }
   
   void display(){
      strokeWeight(1); fill(200); stroke(0);
      rect(x,y,w,h);
      if (piscar){
        fill(map(millis()%1000,0,1000,0,255));
      }else {
        fill(0);
      } 
      
      textAlign(LEFT); text(tex+" "+tex2,x+5,y+textAscent());
      
   } 
}