class CanalXYZ{
  Botao XYZ;
  color nCor;
  Botao selXYZ[]=new Botao[3];
  //CheckBox inv;
  CheckBox curvaSuave;
  CheckBox verCanais;
  int x,y,w,h;
  Dial fm;
  float p0;   // posição tensão zero (0)
  boolean pegouP0=false; // indica que mouse pegou o p0
  float mouseOffSet; // para deslocamento dos objetos (ex: p0)
  
  float fa=5.0/(1023.0); // (dividi por 4 pois tive falta de memoria no garagino) 16/09/2015 
                       // fator garagino (entrada analogica = 10bits) fa=5/1023unidades
  
  //Constructor
  CanalXYZ(color nCor_,int x_, int y_, int w_, int h_){
     x=x_; y=y_; w=w_; h=h_;
     nCor=nCor_;
     XYZ=new Botao("XYZ",x,y,w/2,15,nCor,nCor);
     //inv=new CheckBox("INV",x+w/2+8,y+4,12);
     for (int k=0; k<3;k++){
        selXYZ[k]=new Botao(str(k),x+w/2+5+k*(18+2),y+1,18,15);
        selXYZ[k].cor_ativo=cor[parseInt(selXYZ[k].tex)];
        selXYZ[k].clicado=true;
      }

     XYZ.clicado=false;
     fm=new Dial(escLog,altMove,!nInt,fmt,"","v/div",2f,100e-3f,20f,x+10,selXYZ[0].y+selXYZ[0].h+5,w-20,20);
     p0=tela.y+12*Q;//posição da tensão zero
     curvaSuave=new CheckBox("curva suave",fm.x,fm.y+fm.h+5,15);
     verCanais=new CheckBox("ver canais",curvaSuave.x,curvaSuave.y+curvaSuave.h+2,15);
    
  }
  
  void display(){
     //== mostrar os controles ==
     strokeWeight(2); stroke(nCor); noFill();
     rect(x,y,w,h);
     XYZ.display();
     if (XYZ.clicado){
       //inv.display();
       for (int k=0;k<3;k++){
          selXYZ[k].display(); 
       }
       fm.display();
       curvaSuave.display();
       verCanais.display();
       //== mostrar a linha P0 de tensão zero
       strokeWeight(1); stroke(nCor,150);
       line(tela.x,p0,tela.x+tela.w,p0);
       fill(nCor); noStroke();
       triangle(tela.x,p0,tela.x-20,p0-20,tela.x-20,p0+20);
       displayDados();
     }
  }
  
    //=== mostrar dados na Tela ===
  void displayDados(){ 
    float px=0,py=0;
    color pz=color(255,255,255); 
    float temp=0;
    int cX=parseInt(selXYZ[0].tex);
    int cY=parseInt(selXYZ[1].tex);
    int cZ=parseInt(selXYZ[2].tex);
      // criar linha de controle do Y
      //strokeWeight(1); stroke(nCor,150);
      //line(tela.x-10,XYZy,tela.x+tela.w,XYZy);
      //fill(nCor); noStroke();
      //triangle(tela.x,XYZy,tela.x-20,XYZy-20,tela.x-20,XYZy+20);
      
      //cZ será representado por cor red=0 -> blue=172
      // criar escala de cores para cZ 
      //rect(tela.x,tela.y,tela.w/3,30);
      //strokeWeight(1); stroke(nCor); noFill();
      strokeWeight(1); noStroke();
      if (verPontos.clicado){
        px=tela.x;
        py=tela.w/3.0/172.0;
        colorMode(HSB); //stroke(255); strokeWeight(2);
        for (int k=0; k<172; k++){
            fill(color(k,255,255));
            rect(px+k*py,tela.y,py,30);
        }
        colorMode(RGB); fill(255);textSize(20);
        textAlign(LEFT); text("0v",tela.x,tela.y+15); 
        textAlign(RIGHT); text("5v",tela.x+tela.w/3,tela.y+15);
        textAlign(CENTER); text("ch"+str(cZ),tela.x+tela.w/3/2,tela.y+15);
      }
      
      // criar eixos
      float px0=tela.x+10*Q-(p0-tela.y-2*Q); // posição x central da tela
      strokeWeight(3);
      //if (inv.clicado){
      //  //stroke(cor[cY]); line(p0,p0,p0,p0-255*fa/fm.v.v*Q); // vertical
      //  //stroke(cor[cX]); line(p0,p0,p0-255*fa/fm.v.v*Q,p0);  // horizontal
      //  stroke(cor[cX]); line(px0,XYZy,px0,XYZy-255*fa/fm.v.v*Q); // vertical
      //  stroke(cor[cY]); line(px0,XYZy,px0+255*fa/fm.v.v*Q,XYZy); // horizontal
      //} else {
        //stroke(cor[cX]); line(p0,p0,p0,p0-255*fa/fm.v.v*Q); // vertical
        //stroke(cor[cY]); line(p0,p0,p0+255*fa/fm.v.v*Q,p0); // horizontal
        stroke(cor[cY]); line(px0,p0,px0,p0-1023*fa/fm.v.v*Q); // vertical
        stroke(cor[cX]); line(px0,p0,px0+1023*fa/fm.v.v*Q,p0); // horizontal
      //}
      strokeWeight(1); noFill();
      stroke(nCor); colorMode(HSB);
      beginShape();
        for (int k=0;k<q.v.v;k++){
           //if (!inv.clicado){
              //px=px0 + canal[cx].v[k]*fa/fm.v.v*Q;
              px=px0+canal[cX].v[k]*fa/fm.v.v*Q;
              py=p0 - canal[cY].v[k]*fa/fm.v.v*Q; 
           //} else {
           //   px=px0+canal[cY].v[k]*fa/fm.v.v*Q;
           //   py=XYZy-v[k]*fa/fm.v.v*Q;
           //}
           //colorMode(HSB);
           pz=color(map(canal[cZ].v[k],0,1024,0,172),255,255); //ch2
           //colorMode(RGB);
           //pz=lerpColor(color(255,0,0),color(0,0,255),map(canal[2].v[k],0,255,0,1)); // 0-255 cor
           //stroke(pz);
           
           //if (inv.clicado) {temp=px; px=py; py=temp;}
           if (curvaSuave.clicado) {
            curveVertex(px,py);
           } else {
            vertex(px,py);
           }
           if (verPontos.clicado){
              stroke(pz); strokeWeight(5); point(px,py); strokeWeight(1); //stroke(cor);
           }
        }
        strokeWeight(10); stroke(pz); point(px,py); strokeWeight(1); colorMode(RGB); stroke(nCor);
//        strokeWeight(10); stroke(255,0,255); point(px,py); strokeWeight(1); stroke(cor);
      endShape();
    
  }

  
  
    //=== mouse pega p0 e move ===
  void p0MousePressionou(){
    if (XYZ.clicado){
      int pini=tela.x-20;
      int pfim=tela.x;
      if (mouseX>pini && mouseX<pfim && mouseY>(p0-20) && mouseY<(p0+20)){
        mouseOffSet=mouseY-p0;
        pegouP0=true;
      }
    }
  }
  
  void p0MouseArrastou(){
   if (pegouP0){
      //p0=constrain(mouseY,tela.y,tela.y+tela.h)-mouseOffSet;
      p0=constrain(mouseY,tela.y+2*Q,tela.y+12*Q)-mouseOffSet;
   }
  }


  void mouseClicado(){
    XYZ.mouseClicado();
    // canais selecionados do XYZ
    for (int k=0;k<3;k++){
       if(selXYZ[k].mouseClicado()){
          int j=10-4-(parseInt(selXYZ[0].tex)+parseInt(selXYZ[1].tex)+parseInt(selXYZ[2].tex));
          selXYZ[k].tex=str(j);
          selXYZ[k].cor_ativo=cor[j];
          selXYZ[k].clicado=true;
       } 
     }
     fm.mouseClicado();
     curvaSuave.mouseClicado();
     verCanais.mouseClicado();
  }
  
  void mousePressionou(){
    fm.mousePressionou();
    p0MousePressionou(); //se pegar o triangulo de p0
  }
  
  void mouseArrastou(){
    fm.mouseArrastou();
    p0MouseArrastou(); // se arrastou o p0
  }
  
  void mouseSoltou(){
    fm.mouseSoltou();
    if (pegouP0) {
       pegouP0=false; 
    }
  }
  
  void mouseMoveu(){
     fm.mouseMoveu();
  }

  
}