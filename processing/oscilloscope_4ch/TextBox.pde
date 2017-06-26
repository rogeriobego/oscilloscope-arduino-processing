class TextBox{
   int x,y,w,h;
   int hAlign;
   String tex;
   //constructor
   TextBox(String texi,int hAligni, int xi, int yi, int wi, int hi){
     tex=texi; hAlign=hAligni;
     x=xi; y=yi; w=wi; h=hi;
   }
   void display(color bgColor){
      fill(bgColor);
      rect(x,y,w,h);
      fill(0);
      if (hAlign==LEFT){
        textAlign(LEFT,CENTER);
        text(tex,x+5,y+h/2);
      } else{
        textAlign(CENTER,CENTER);
        text(tex,x+w/2,y+h/2);
      }
   }
   
   boolean mouseClicado(){
       boolean r=false;
       if (mouseX>x && mouseX<x+w && mouseY>y && mouseY<y+h){
         r=true;
        // println(tex," mouseClicado=",r);
       }
       return r;
   }
}