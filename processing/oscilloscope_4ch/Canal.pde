class Canal{
 byte n;
 Botao chN;
 color nCor;
 int x,y,w,h;
 Dial fm;  // fator de escala para a voltagem (vertical)
 Dial ft; // fator de escala para o tempo (horizontal)
 //CheckBox inv; // inverter o sinal
 CheckBox trigger; // trigger
 CheckBox curva; // suavizar as curvas com curveVertex() / vertex()
 CheckBox medir; // medir tempo e tensão
 // armazenamento dos dados recebidos do Garagino
 int qMax=408;
 int v[]=new int[qMax];
 int buffer[]=new int[qMax];
 boolean atualizou=false;
 //int picos[]=new int[qMax];
 //int qPicos;
 //int vales[]=new int[qMax];
 //int qVales;
 int dif[]=new int[qMax]; // valores diferenciais v[t+1]-v[t]
 int picos[]=new int[qMax];
 int qPicos;
 float p0;   // posição tensão zero (0)
 boolean pegouP0=false; // indica que mouse pegou o p0
 float p0Trigger; // posição do trigger
 boolean pegouTrigger=false; // indica que mouse pegou o trigger
 float dP0Trigger; // diferença entre p0 e p0trigger
 float p0Out; // posição pixel do triangulo qInit
 boolean pegouOut=false; // indica que pedou o triangulo do Out
 float mouseOffSet; // para deslocamento dos objetos (ex: p0, p0Trigger, p0Out)
 //float fCalc, tCalc; // frequencia e periodo calculados a partir dos picos 
 FmtNum fCalc=new FmtNum(0,!nInt,fmt);
 FmtNum tCalc=new FmtNum(0,!nInt,fmt); // frequencia e periodo calculados a partir dos picos 
 float fa=5.0/(1023.0); // (dividi por 4 pois tive falta de memoria no garagino) 16/09/2015 
                       // fator garagino (entrada analogica = 10bits) fa=5/1023unidades
 //retangulo de medição da Tela
 boolean telaClicou=false;
 float xi,yi,dx,dy; // retangulo de medir tempo e tensão na tela
 
 // 11/May/2017 triangle to move points out of visible window (qOut) for k=qInit; k<q; k++
 //  qOut=qTotal-qVisible => qVisible=10*df/dt, qTotal (q.v.v)
 int qOut=0;
 int qInit=0; // qInit=int((px-leftWindow) * qOut/(10Q)) , Q=size of square in pixel
 
 //constructor
 Canal(byte n_,color nCor_, int x_, int y_, int w_, int h_){
     n=n_; nCor=nCor_;
     x=x_; y=y_; w=w_; h=h_;
     //chN=new Botao("Ch-"+str(n),x,y,w/2,20,nCor,nCor);
     chN=new Botao("Ch-"+str(n),x,y,w/2,15,nCor,nCor);
     //inv=new CheckBox("INV",x+w/2+8,y+4,12);
     trigger=new CheckBox("Trigger",x+w/2+3,y+3,14);
     chN.clicado=true;
     fm=new Dial(escLog,altMove,!nInt,fmt,"","v/div",2f,10e-3f,20f,x+10,y+21,w-20,20,1);
     ft=new Dial(escLog,altMove,!nInt,fmt,"","s/div",10e-3f,20e-6f,20f,x+10,fm.y+fm.h+3,w-20,20,2);
     p0=tela.y+3*Q*(n+1);//posição da tensão zero
     p0Trigger=p0;
     medir=new CheckBox("medir",ft.x,ft.y+ft.h+5,15);
     curva=new CheckBox("curva",ft.x+ft.w/2,ft.y+ft.h+5,15);
 }
  
  void display(){
    //vTrigger=vTrigger1;
    //println("n=",n);
     // verificar se tem dados atualizados no buffer
     
     if (atualizou){
       arrayCopy(buffer,v);
       atualizou=false;
     }
     
     // grupoUpdate
     fm.grupoUpdate();
     ft.grupoUpdate();
     
     //== mostrar os controles ==
     strokeWeight(2); stroke(nCor); noFill();
     rect(x,y,w,h);
     chN.display();
     if (chN.clicado && (!chXYZ.XYZ.clicado || chXYZ.verCanais.clicado)){
       //inv.display();
       trigger.display();
       fm.display();
       ft.display();
       medir.display();
       curva.display();
       
      
      //if (XYZ.clicado){
        
      //  displayXYZ();       //mostrar XY 
      //} else{
        
       //== mostrar a linha P0 de tensão zero
       strokeWeight(1); stroke(nCor,150);
       line(tela.x-10*n,p0,tela.x+tela.w,p0);
       fill(nCor); noStroke();
       triangle(tela.x-10*n,p0,tela.x-10-10*n,p0-10,tela.x-10-10*n,p0+10);
      
      //== mostrar a linha do trigger se o trigger estiver acionado
      if (trigger.clicado){
        if (!pegouTrigger) {
          p0Trigger=fy(vTrigger); //-fy(vTrigger);
        }
        //println(vTrigger," ",fy(vTrigger));
        strokeWeight(2); stroke(nCor,100);
        line(tela.x-10*n,p0Trigger,tela.x+tela.w,p0Trigger);
        fill(nCor); noStroke();
        triangle(tela.x+tela.w,p0Trigger,tela.x+tela.w+10,p0Trigger,tela.x+tela.w+10,p0Trigger-20);
      }

      //== mostrar o triangulo do OUT (pontos que estão fora da janela)
      qOut=int(q.v.v-10.0*ft.v.v/dt.v.v);
      //println("qOut=",qOut," qInit=",qInit," q.v.v=",q.v.v," ft.v.v=",ft.v.v," dt.v.v=",dt.v.v);
      if (qOut>0){
        //float fq=10*Q/qOut;
        fill(nCor); noStroke();
        //float p0Out=tela.x+tela.w-qInit*fq;
        triangle(p0Out,p0,p0Out-10,p0+10,p0Out+10,p0+10);
      } else {
        qInit=0;
        p0Out=tela.x+tela.w;
      }
      
      
      //if (calcFreq.clicado) analisarCurva(); else {qPicos=0; qVales=0;}
        //tirei o analisarCurva() em 19/09/15 para por o curvaDiferencial
        displayXt();      // mostrar Xt
        
      //}
      displayRect();
     }
     
     
  }
  
  
  //=== mouse pega p0 e move ===
  void p0Pressionou(){
    int pini;
    int pfim;
    if (chN.clicado){
      pini=tela.x-10-10*n;
      pfim=tela.x-10*n;
      if (mouseX>pini && mouseX<pfim && mouseY>(p0-10) && mouseY<(p0+10)){ 
        // clicou no triangulo da origem (esquerdo)
        mouseOffSet=mouseY-p0;
        dP0Trigger=p0Trigger-p0;
        pegouP0=true;
       }
     }   
   }

  
  void p0Arrastou(){
   if (pegouP0){
      p0=constrain(mouseY,tela.y,tela.y+tela.h)-mouseOffSet; 
      p0Trigger=p0+dP0Trigger;
      if (keyPressed && key==CODED && keyCode==SHIFT){
        int k2=2;
        if (p0<=tela.y+tela.h/2){
            for (int k=0;k<4;k++){
               if (k != n){
                 canal[k].p0=constrain(tela.y+(p0-tela.y)*k2,tela.y,tela.y+tela.h);
                 k2++;
               }
            }
        } else {
            for (int k=0;k<4;k++){
              if (k!=n){
                canal[k].p0=constrain(tela.y+tela.h-(tela.y+tela.h-p0)*k2,tela.y,tela.y+tela.h);
                k2++;
              }
            }
        }
      }
   }
  }

 //=== mouse pega triangulo p0Trigger ===
 void  p0TriggerPressionou(){
    int pini;
    int pfim;
    if (chN.clicado){
        // clicou no triangulo do trigger (direita)
        pini=tela.x+tela.w;
        pfim=tela.x+tela.w+10;
        if (mouseX>pini && mouseX<pfim && mouseY>(p0Trigger-20) && mouseY<(p0Trigger)){ 
           mouseOffSet=mouseY-p0Trigger;
           pegouTrigger=true;
        }
    }
 }

 void  p0TriggerArrastou(){
  if (pegouTrigger){
      p0Trigger=constrain(mouseY,fy(1024),p0)-mouseOffSet; 
      println("pegouTrigger=true  p0Trigger="+str(p0Trigger));
   }
 }

 //=== mouse pega triangulo p0Out ===
 void p0OutPressionou(){
   if (chN.clicado){
      // clicou no triangulo do deslocamento da janela (pontos escondidos)
      if (mouseX>p0Out-10 && mouseX<p0Out+10 && mouseY>p0 && mouseY<(p0+10)){
        println("n=",n);
        mouseOffSet=mouseX-p0Out;
        pegouOut=true;
      }
   }
 }

 void p0OutArrastou(){
  if (pegouOut){
      p0Out=constrain(mouseX,tela.x,tela.x+tela.w);
      float fq=10*Q/qOut;
      //float p0Out=tela.x+tela.w-qInit*fq;
      qInit=int((tela.x+tela.w-p0Out)/fq);
      //println("pegouOut=true p0Out="+str(p0Out)," qInit=",qInit);
      if (keyPressed && key==CODED && keyCode==SHIFT){
            for (int k=0;k<4;k++){
               if (k != n){
                 //canal[k].ft.v.v=canal[n].ft.v.v;
                 canal[k].ft.setV(ft.v.v);
                 canal[k].qInit=qInit;
                 // recalcular o p0Out
                 canal[k].p0Out=p0Out;
               }
            }
      }      
   }
 }

  
  void displayXt(){ // modo em função do tempo
    float px, py;
    int pt0,pt1;
    stroke(nCor);strokeWeight(2); noFill();
    beginShape();
      for (int k=qInit; k<q.v.v; k++){
        px=fx(k-qInit);
        if (px>tela.x+tela.w || px<tela.x) {
           break; 
        }
        py=fy(v[k]);
        if (curva.clicado) {
          curveVertex(px,py);
        } else {
          vertex(px,py);
        }
        if (verPontos.clicado){
          stroke(255); strokeWeight(4); point(px,py); strokeWeight(2); stroke(nCor);
        }
      }
    endShape();
     if (calcFreq.clicado){  
       curvaDiferencial();
     }
    strokeWeight(2); stroke(nCor);
  }
  
  float fx(int x){
    return tela.x+Q*dt.v.v/ft.v.v*x;
  }

  float fy(int y){
    return p0-y*fa/fm.v.v*Q;
  }
  
  
  //14/03/2016 - comecei a procurar a frequencia pelos picos minimos, criei vMin e pMin
  //                falta analisar os picos minimos e tirar os picos máximos
  void curvaDiferencial(){
    float px;
    int vMax1=0,vMax2=0,pMax1=-1,pMax2=-1; // -1 no pMax para indicar que não foi encontrado
    int vMin1=0, vMin2=0, pMin1=-1, pMin2=-1;
    int pM1,pM2;
    int vMax=0, pMax=-1;
    int vMin=0, pMin=-1;
    //float vRuido=map(ruido.v.v,0,5,0,1023);
    qPicos=0;
    // procurar o valor dif máximo vMax => pMax (ponto k)
    for (int k=1; k<q.v.v; k++){
       dif[k-1]=v[k]-v[k-1];
       if (dif[k-1]>vMax) {
         vMax=dif[k-1];
         pMax=k-1;
        }
        if (dif[k-1]<vMin){
           vMin=dif[k-1];
           pMin=k-1;
        }
    }
    
 //==eliminei essa rotina que procura picos máximos para procurar os picos minimos - 14/03/2016===
 // procurar todos os pontos que estão entre vMax e 2/3*vMax-vRuido
 /*   vMax=(int)(2.0/3.0*(float)vMax);
    qPicos=0;
    if (vMax>0){
      for (int k=0; k<q.v.v-1; k++){ 
         if (dif[k]>=vMax){
           qPicos++;
           picos[qPicos-1]=k;
         }
      }
      if (qPicos>=2){
         if (picos[1]-picos[0]>1){
         pMax1=picos[0]; vMax1=dif[pMax1];
         pMax2=picos[1]; vMax2=dif[pMax2];
         }
      }
    }

   // procurar todos os pontos que estão entre vMax e 2/3*vMax-vRuido
    vMax=(int)(2.0/3.0*(float)vMax);
    qPicos=0;
    if (vMax<0){
      for (int k=0; k<q.v.v-1; k++){ 
         if (dif[k]>=vMax){
           qPicos++;
           picos[qPicos-1]=k;
         }
      }
      if (qPicos>=2){
         if (picos[1]-picos[0]>1){
         pMax1=picos[0]; vMax1=dif[pMax1];
         pMax2=picos[1]; vMax2=dif[pMax2];
         }
      }
    }

    if (pMax1>=0 && pMax2>=0){ //deve ser onda quadrada
       //println(n," Quadrada");
    }else{    // deve ser senoide (suave)
        //println(n," Senoide");
        //pMax1=-1; pMax2=-1;
        for (int k=0; k<q.v.v-2; k++){ // pegar 2 pontos de mudança do Zero
          //println("vMax1=",vMax1," vMax2=",vMax2);
          if (dif[k]>0 && dif[k+1]<=0){ // achou + para - (pico)
            //println("entrei ",dif[k],dif[k+1]);
            if (pMax1<0){
               vMax1=dif[k+1];
               pMax1=k+1;
               //println("pMax1=",pMax1," vMax1=",vMax1);
            } else if (pMax2<0){
              vMax2=dif[k+1];
              pMax2=k+1;
              // println("pMax2=",pMax2," vMax2=",vMax2);
              break;
            }
          }
        }
    }

*/    

   // procurar todos os pontos que estão entre vMin e 2/3*vMin-vRuido
    vMin=(int)(2.0/3.0*(float)vMin);
    qPicos=0;
    if (vMin<0){
      for (int k=qInit; k<q.v.v-1; k++){ 
         if (dif[k]<=vMin){
           qPicos++;
           picos[qPicos-1]=k;
         }
      }
      if (qPicos>=2){
         if (picos[1]-picos[0]>1){
         pMin1=picos[0]; vMin1=dif[pMin1];
         pMin2=picos[1]; vMin2=dif[pMin2];
         }
      }
    }
    
    
    
    if (pMin1>=0 && pMin2>=0){ //deve ser onda quadrada
       //println(n," Quadrada");
    }else{    // deve ser senoide (suave)
        //println(n," Senoide");
        //pMax1=-1; pMax2=-1;
        for (int k=qInit; k<q.v.v-2; k++){ // pegar 2 pontos de mudança do Zero
          //println("vMax1=",vMax1," vMax2=",vMax2);
          if (dif[k]>0 && dif[k+1]<=0){ // achou + para - (pico)
            //println("entrei ",dif[k],dif[k+1]);
            if (pMin1<0){
               vMin1=dif[k+1];
               pMin1=k+1;
               //println("pMax1=",pMax1," vMax1=",vMax1);
            } else if (pMin2<0){
              vMin2=dif[k+1];
              pMin2=k+1;
              // println("pMax2=",pMax2," vMax2=",vMax2);
              break;
            }
          }
        }
    }
    
    
    
    // desenhar os fios diferenciais dif[]
    if (grafDif.clicado){
      strokeWeight(1); stroke(255);
      for (int k=qInit; k<q.v.v-1;k++){
          px=fx(k-qInit);
          if (px>tela.x+tela.w || px<tela.x) { break;}
          line(px,p0,px,fy(dif[k])); 
      }
      stroke(200,0,200);
      for (int k=qInit;k<qPicos;k++){
         px=fx(picos[k-qInit]);
         if (px>tela.x+tela.w || px<tela.x){ break;}
         line(px,p0,px,fy(dif[picos[k]]));
      }
    }
    
    
  //== 14/03/2016 - tirei para recalcular a frequencia com div negativo ====  
   //calcular a frequencia e período
 /*  tCalc.setV(0);
   fCalc.setV(0);
   if (pMax1>=0 && pMax2>=0){
      //desenhar os pMax1 e pMax2
      strokeWeight(5); stroke(255,0,255);
      point(fx(pMax1),p0);
      point(fx(pMax2),p0);
      strokeWeight(1);
     
     tCalc.setV(abs(pMax2-pMax1)*dt.v.v);
    fCalc.setV(1/tCalc.v);
    
    //mostrar a frequencia e o periodo
    textAlign(LEFT); fill(0);
    text(fCalc.printV()+"Hz ("+tCalc.printV()+"s)",medir.x,medir.y+29); 
   }
  */ 
 
   //calcular a frequencia e período - dif negativo 14/03/2016 
   tCalc.setV(0);
   fCalc.setV(0);
   if (pMin1>=0 && pMin2>=0){
      //desenhar os pMin1 e pMin2
      strokeWeight(5); stroke(255,0,255);
      point(fx(pMin1-qInit),p0);
      point(fx(pMin2-qInit),p0);
      strokeWeight(1);
     
     tCalc.setV(abs(pMin2-pMin1)*dt.v.v);
    fCalc.setV(1/tCalc.v);
    
    //mostrar a frequencia e o periodo
    textAlign(LEFT); fill(0);
    text(fCalc.printV()+"Hz ("+tCalc.printV()+"s)",medir.x,medir.y+29); 
   }
   
 
   
  }
  
  
  


  /*============================================================
     controle do retangulo de medição na tela (faz medições tempoxtensão)
  =============================================================== */
    // mostrar o retangulo de seleção e os valores tempo x volts
    void displayRect(){ 
      if (telaClicou){
         fill(nCor,50); stroke(nCor,255); strokeWeight(1);
         tracejado(xi,yi,xi+dx,yi+dy,3);
         fill(255);
         float vTemp=abs(dx)/(Q)*ft.v.v*1000.0;
         //println("Q=",Q);
         String vh=nf(vTemp,0,1)+" ms";
         String fh=nf(1000/vTemp,0,1)+ " Hz";
         String vv=nf(abs(dy)/(Q)*fm.v.v,0,2)+" V";
         textAlign(RIGHT); text(vh+" "+fh,xi+dx-10,yi+dy/2);
         textAlign(LEFT); text(vv,xi+dx,yi+dy/2);
       }       
     }
     
     void tracejado(float xi, float yi, float xf, float yf, float step){
        float temp;
        boolean faz=true;
        if (xi>xf) {
           temp=xf; xf=xi; xi=temp; 
        } 
        if (yi>yf) {
           temp=yf; yf=yi; yi=temp;
        }
        for (float x=xi; x<xf; x+=step){
           if (faz){
              line(x,yi,x+step,yi);
              line(x,yf,x+step,yf);
           } 
           faz=!faz;
        }
        for (float y=yi; y<yf; y+=step){
           if (faz){
              line(xi,y,xi,y+step);
              line(xf,y,xf,y+step);
           } 
           faz=!faz;
        }
     }

      // -- rotinas para fazer a medição na "tela"
     void telaMousePressionou(){
      // println("telaMousePressionou");
      // println("cor=",get(mouseX,mouseY));
       if (medir.clicado){ // acertar procurar qual cor de canal mais próximo ao mouse
         if (mouseX>tela.x && mouseX<tela.x+tela.w && mouseY>tela.y && mouseY<tela.y+tela.h){
            telaClicou=true;
            //println("telaClicou=",telaClicou);
            xi=mouseX;
            yi=mouseY;    
            dx=0; dy=0;   
         }
       }
     }
     void telaMouseArrastou(){
       //println("telaMouseArrastou");
       if (medir.clicado){
         if (telaClicou){
           
           if (mouseX>tela.x && mouseX<tela.x+tela.w && mouseY>tela.y && mouseY<tela.y+tela.h){
            dx=mouseX-xi;
            dy=mouseY-yi;
             //println("arrastando dx=",dx," dy=",dy);
           }
         }
       }
     }
     void telaMouseSoltou(){
       //println("telaMouseSoltou telaClicou=",telaClicou);
       if (medir.clicado){
          if (telaClicou) {
            // println("dx=",dx," dy=",dy);
            if (abs(dx)<10 && abs(dy)<10){
               telaClicou=false;
          //     println("telaClicou= ",telaClicou);
            }
          } 
       }
     }

  
  //=== controle dos eventos do mouse ===  
  boolean mouseClicado(){
     boolean ret=false;
     ret=chN.mouseClicado(); 
     //inv.mouseClicado();
     if (trigger.mouseClicado()){
        if (trigger.clicado){
           for (int k=0;k<4;k++){
              canal[k].trigger.clicado=false;
           }
           trigger.clicado=true;
           if (com.conectado){
              port.write("t"+str(n)); 
           }
        } else {
          if (com.conectado){
             port.write("tx"); 
          }
        }
     }
     fm.mouseClicado();
     ft.mouseClicado();
     if (medir.mouseClicado()){
        if (medir.clicado){
           for (int k=0;k<4;k++){
              canal[k].medir.clicado=false; 
           }
           medir.clicado=true;
        }
     };
     curva.mouseClicado();
     return ret;
  }
  
  void mousePressionou(){
    fm.mousePressionou();
    ft.mousePressionou();
    p0Pressionou(); //se pegar o triangulo de p0
    p0TriggerPressionou(); // se pegar o triangulo de p0Trigger
    p0OutPressionou(); // se pegar o triangulo de p0Out
    telaMousePressionou();
  }
  
  void mouseArrastou(){
    fm.mouseArrastou();
    ft.mouseArrastou();
    p0Arrastou(); // se arrastou o p0
    p0TriggerArrastou(); // se arrastou o p0Trigger
    p0OutArrastou(); // se arrastou o p0Out
    telaMouseArrastou();
  }
  
  void mouseSoltou(){
    fm.mouseSoltou();
    ft.mouseSoltou();
    if (pegouP0) {
       pegouP0=false; 
    }
    if (pegouTrigger){
      vTrigger=constrain(int((p0-p0Trigger)/(fa/fm.v.v*Q)),0,1024);
      println("tv"+str(vTrigger)+".");
      if (com.conectado) {
        port.write("tv"+str(vTrigger)+".");
        
      }
      pegouTrigger=false;
    }
    if (pegouOut){
      pegouOut=false;
    }
    telaMouseSoltou();
  }
  
  void mouseMoveu(){
     fm.mouseMoveu();
     ft.mouseMoveu(); 
  }
}