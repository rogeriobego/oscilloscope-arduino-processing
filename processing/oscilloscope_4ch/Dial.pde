class Dial {
/*  dial(escala,alterar,nInt,formatar,tex,unid,v,vMin,vMax,x,y,w,h);
      escala=escLinear/escLog    //tipo da escala: linear ou logaritmica
      alterar=altMove/altSolta   //tipo de alteração: ao mover ou solta o mouse
      nTipo=nInt/nDec            //n deve ser inteiro ou decimal
      formatar=fmt / !fmt        // formatar o número true/false
      
   constantes usadas na classe Dial 
     byte escLinear=0; // Dial com escala linear
     byte escLog=1;     // Dial com escala logarítimica (base 10)
     byte altMove=2; // mudar o valor ao arrastar o mouse "MouseDragged"
     byte altSolta=3; // mudar o valor ao soltar o botão do mouse "MouseReleased"
     byte nInt=4; // n é inteiro (arredondar)
     byte nDec=5; // n é decimal 
     boolean fmt=true; // fmt=true="formatar",  !fmt=false="não formatar" 
----------------- */
   
   int x,y,w,h;
   FmtNum v, vTemp;
   float vOld;
   //boolean nInt=false;
   float vMin, vMax;
   String unidade="";
   byte escala=escLinear;
   byte alterar=altSolta;  // alterar v quando MouseDrag ou MouseRelease
   int g; // usado para mudar simultaneamente os valores de varios controles qdo usar SHIFT
   //boolean linear=true;  // true=linear,  false=log10
   //boolean imediato=false; // true=alterar o valor do v quando mouseArrastou
                           // false=alterar o valor do v quando mouseSoltou
   String tex;
   boolean clicou=false;
   int cx, mouseOffSet;
   boolean mostrarTriangulos=false;
   boolean mostrarIncrementos=false;
   //boolean formatar=true;  // pede para a classe FmtNum não formatar no formato engenharia
   
  
   //constructor
   Dial(byte escala_, byte alterar_, boolean nInt_, boolean fmt_, String tex_,String unidade_, float v_, float vMin_, float vMax_, int x_, int y_, int w_, int h_){
       escala=escala_; alterar=alterar_; tex=tex_;
       unidade=unidade_;
       vMin=vMin_; vMax=vMax_;
       x=x_; y=y_; w=w_; h=h_;
       v=new FmtNum(v_,nInt_,fmt_);
       //formatar=fmt_;
       updateCx(); 
       vTemp=new FmtNum(v.v,nInt_,fmt_);
       g=0;
   } 
   Dial(byte escala_, byte alterar_, boolean nInt_, boolean fmt_, String tex_,String unidade_, float v_, float vMin_, float vMax_, int x_, int y_, int w_, int h_, int g_){
       escala=escala_; alterar=alterar_; tex=tex_;
       unidade=unidade_;
       vMin=vMin_; vMax=vMax_;
       x=x_; y=y_; w=w_; h=h_;
       v=new FmtNum(v_,nInt_,fmt_);
       //formatar=fmt_;
       updateCx(); 
       vTemp=new FmtNum(v.v,nInt_,fmt_);
      
       g=g_;
       grupo[g].qtd++;
       //println("Dial.tex=",tex," g=",g);
       //println("grupo[",g,"].qtd=",grupo[g].qtd);
   } 

   void salvar(){
     vOld=v.v;  
   }
   
   void restaurar(){
     setV(vOld);
   }
   
   void setV(float v_){
       v.setV(v_); 
       updateCx();
   }
   
   void updateCx(){
      //v=v_;
      
       cx=v2x(v.v); 
   }
   
   void display(){
      display(color(0)); 
   }
   
   void display(color cor){
      // faz retangulo
      //if (clicou) {stroke(100,0,0);} else {stroke(0);}
      stroke(cor);
      strokeWeight(1);   fill(200);  rect(x,y,w,h); 
      // faz o valor v
      noStroke();  fill(0,255,255); rect(x+1,y+1,cx-x-2,h-2);
      
      if (mostrarIncrementos){
          fill(0); stroke(0); textSize(10);
         text("-100",x,y+5); 
         text("-10",x+w/6,y+5);
         text("-1",x+2*w/6,y+5);
         text("+1",x+3*w/6,y+5);
         text("+10",x+4*w/6,y+5);
         text("+100",x+5*w/6,y+5);
      }
      if (mostrarTriangulos){
        // faz o triangulo do cursor
         fill(250,250,0); stroke(0);
        triangle(cx,y+3*h/4,cx-5,y+h,cx+5,y+h); //rect(cx-10,y,20,h);
        triangle(cx,y+h/4,cx-5,y,cx+5,y); //rect(cx-10,y,20,h);
      }

      // imprimir as linhas para delimitar as 6 areas de + -
      stroke(0);
      for (int k=0;k<5;k++){ 
        float vx=x+(k+1)*0.17*w;
        if (k==2){line(vx,y,vx,y+0.2*h);} 
          else {line(vx,y,vx,y+0.1*h);} 
       
      }

      
      //faz o texto
      fill(0); strokeWeight(2); textSize(12);  textAlign(CENTER,CENTER); 

      String t=tex+" ";
      if (clicou) {
        if (alterar==altSolta){
          t+=vTemp.printV();
        } else {
          t+=v.printV();
        }
      } else {
        t+=v.printV();
      }
      text(t+unidade,x+w/2,y+h/2-2);
  
  
   }
   
   /*
   String fmt(float v_){
     String t;
     int i=round((log(v_)/log(10))/3);
     char u[]={'p','n','u','m',' ','k','M','G','T'};
     t=nf(v_*pow(10,-3*i),0,1)+u[i+4];
     if (t.charAt(0)=='0'){ // se o valor do primeiro caracter e' zero, então subir escala (x1000)
        t=nf(1000*v_*pow(10,-3*i),0,1)+u[i+4-1]; 
     }
     return t; 
   }
   */
   
 /*  int fmtV(float v_){ //enviar apenas a parte inteira (1-999)
     int i=round((log(v_)/log(10))/3);
     int vi=int(v_*pow(10,-3*i));
     if (vi<=0) {
        vi=int(1000*v_*pow(10,-3*i)); 
     }
     println("vi=",vi);
     return vi;
     
   }
*/   
   
   int v2x(float v_){
      if (escala==escLinear) {
        return (int)map(v_,vMin,vMax,x,x+w);
      } else {
        return (int)map(log(v_)/log(10),log(vMin)/log(10), log(vMax)/log(10),x,x+w); 
      }
   }
   
   float x2v(int cx_){
     if (escala==escLinear){
       return map(cx_,x,x+w,vMin,vMax);
     } else{
       return pow(10,map(cx_,x,x+w,log(vMin)/log(10),log(vMax)/log(10)));
     }  
   }
   
   
   void grupoUpdate(){
     if (g>0){
        if (grupo[g].conta>0){
           grupo[g].conta--;
           setV(grupo[g].v);
           if (grupo[g].conta<=0) grupo[g].v=0;
        }
     }
       
   }
   
   
   boolean mouseClicado(){ // Soma/Subtrai 1,10 ou 100 do valor => true se alterou o valor
     boolean alterou=false;
     float v2=0;
     if (mouseX>x && mouseX<x+w && mouseY>y && mouseY<y+h){
       alterou=true;
       int p=(int)map(mouseX,x,x+w,1,7);
       //int p=round(map(mouseX,x,x+w,1,5));
       //println("p=",p);
       //println("fmtV=",fmtV(v));
       switch (p) {
          case 1: // subtrair 100
            v2=v.addN(-100);
            break;
          case 2: // subtrair 10 em 10
             //println("-10");
             v2=v.addN(-10);
           break;
          case 3: // subtrair de 1 em 1
            //println("-1");
            v2=v.addN(-1);
           break;
          case 4: // somar de 1 em 1
            //println("+1");
            v2=v.addN(+1);
           break;
          case 5: // somar de 10 em 10
            //println("+10");
            v2=v.addN(+10);
           break; 
          case 6: //somar
            v2=v.addN(+100);
            break;
       }
       if (v2<vMin) {
          v.setV(vMin); 
       } else if (v2>vMax){
          v.setV(vMax); 
       } else {
          v.setV(v2); 
       }
       updateCx();
       ifShiftAlterarGrupo();       
     } 
     return alterou;
   }

   void mouseMoveu(){
      if (mouseY>y && mouseY<y+h) {
        if (mouseX>cx-10 && mouseX<cx+10){
         // println("mouseMoveu Dial");
          mostrarTriangulos=true;
        } else {
          mostrarTriangulos=false;
        }
        if (mouseX>x && mouseX<x+w && keyPressed && keyCode==CONTROL){
          println("mostrarIncrementos=" + mostrarIncrementos);
           mostrarIncrementos=true; 
        } else {
           mostrarIncrementos=false;
        }
      }  else {
        mostrarTriangulos=false;
      }   
   }
   
   void mousePressionou(){
     if (mouseButton==LEFT){
      if (mouseY>y && mouseY<y+h) {
        if (mouseX>cx-10 && mouseX<cx+10){
          //println("mousePressionado"); 
          clicou=true; 
           vTemp.setV(v.v);
           mouseOffSet=mouseX-cx;
           //println("cx=",cx);
        }
      }
     }
   }
   
   boolean mouseArrastou(){ // retorna true se é para enviar o comando para Garagino
      //println("Dial.mouseArrastou");
      boolean enviar=false;
      if (clicou){
         cx=constrain(mouseX-mouseOffSet,x,x+w);
         if (alterar==altMove){ // é para alterar Imediatamente enquanto Mover o Mouse
            vTemp.setV(x2v(cx)); // converte o x para v
              v.setV(vTemp.v); 
              enviar=true;   // enviar o comando de alterar para o Garagino!
              ifShiftAlterarGrupo(); // se tiver SHIFT então alterar Grupo
         }else{
            vTemp.setV(x2v(cx));
         }
      }
     return enviar; 
   }
   
   boolean mouseSoltou(){ // retorna true se é para enviar o comando para o Garagino
     boolean enviar=false;
      if (clicou) {
        clicou=false;
        if (alterar==altSolta){
           if (mouseY>y-10 && mouseY<y+h+10) { // && mouseX>x-15 && mouseX<x+w+15){
               v.setV(vTemp.v); // é para alterar quando Soltar o Mouse
               enviar=true;  // enviar comando de alterar para o Garagino!
               ifShiftAlterarGrupo(); // se tiver SHIFT então alterar Grupo
            } else{
               cx=v2x(v.v);
           }
        }
    } 
    return enviar;
   }
   
   void ifShiftAlterarGrupo(){
     if (keyPressed && key==CODED && keyCode==SHIFT){
        grupo[g].v=v.v;
        grupo[g].conta=grupo[g].qtd; //quantidade de controles que irão sincronizar o valor
     }
   }
   
}