class Botao{
   int x,y,w,h;
   String tex;
   boolean mPressionou=false;
   boolean clicado=false;
   color cor_ativo=color(0,255,0);
   color cor_fio=color(0);
   
   
   //constructor
   Botao(String tex_,int x_,int y_, int w_, int h_){
      tex=tex_; x=x_; y=y_; w=w_; h=h_;
   } 
   Botao(String tex_,int x_,int y_, int w_, int h_,color cor_ativo_, color cor_fio_){
      tex=tex_; x=x_; y=y_; w=w_; h=h_;
      cor_ativo=cor_ativo_;
      cor_fio=cor_fio_;
   }
   void display(){
     if (mPressionou){
        fill(0,100,0);
     } else if (clicado){
         fill(cor_ativo); //fill(0,255,0); 
      } else{
        fill(200);
      }
      stroke(cor_fio); strokeWeight(1);
      rect(x,y,w,h); 
      textAlign(CENTER,CENTER);
      if (cor_ativo==color(0,0,255) && clicado){ // usar branco para texto na cor de fundo blue
        fill(255);
      } else{
        fill(0);
      } textSize(14); text(tex,x+w/2,y+h/2);
     // if (tex.equals("1")) println("mPressionou=",mPressionou);
   }
   
   void mousePressionou(){
     if (mouseButton==LEFT) {
       if (mouseX>x && mouseX<x+w && mouseY>y && mouseY<y+h){
          mPressionou=true;
       }
     }
   }
   void mouseSoltou(){
      if (mPressionou) mPressionou=false;
   }
   
   boolean mouseClicado(){ // retorna se foi clicado ou não
     boolean ret=false;
     if (mouseButton==LEFT){
       if (mouseX>x && mouseX<x+w && mouseY>y && mouseY<y+h){
          clicado=!clicado;
          //println("clicado=",clicado);
          ret=true;
          mPressionou=false;
       }
     }
     return ret;
   }
   
   
 /*  void mouseSoltou(){
       if (!fixar) {
          clicado=false; 
        }
   }
   */
}