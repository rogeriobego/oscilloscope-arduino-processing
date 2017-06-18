class Com{
   Serial port;
   String ports[]=append(Serial.list(),"select serial");
   String portName;
   int indPort=ports.length-1;
   //String speed="115200";
   //String speed="250000";
   String speeds[]={"9600","115200","250000","select speed"};
   //int portSpeed;
   int indSpeed=speeds.length-1;
   int p=-1;
   int x,y,w,h,dh;
   TextBox title, onOff,selectSerial,selectSpeed,refresh; 
   boolean conectado=false;
   boolean erro=false;
   color cor=color(0);
   String tex;
   boolean estaSobre=false; // indica se o cursor do mouse está sobre a area do controle
   
   //constructor
   Com(Serial portt,int xt, int yt, int wt, int ht){
      x=xt; y=yt; w=wt; h=ht;
      dh=h/3;
      title= new TextBox("Configurar Serial",CENTER,x,y,int(0.7*w),dh);
      refresh=new TextBox("refresh",CENTER,int(x+0.7*w),y,int(0.3*w),dh);
      //refresh=new TextBox("refresh",CENTER,int(x+0.6*w),y+2*h/3,int(0.4*w),dh);
      selectSerial=new TextBox("select serial",CENTER,x,y+h/3,w,dh);
      selectSpeed=new TextBox("select speed",CENTER,x,y+2*h/3,int(0.7*w),dh);
      onOff=new TextBox("off",CENTER,int(x+0.7*w),y+2*h/3,int(0.3*w),dh);
      //onOff=new TextBox("off",CENTER,int(x+0.7*w),y,int(0.3*w),dh);
   } 
   void display(){
     strokeWeight(1); stroke(0);fill(200);
     onOff.tex="off";
     if (conectado) {
         cor=color(0,255,0);
         onOff.tex="on";
        // fill(cor);
     } else if (erro) {
        cor=color(255,0,255);
     } else {
        cor=color(200);
      //  fill(200);
     }
     //fill(cor); 
     title.display(cor);
     onOff.display(cor);
     selectSerial.display(cor);
     selectSpeed.display(cor);
     refresh.display(cor);
     
     /*
     rect(x,y,0.7*w,dh); // Config Serial text Box - line 1
     rect(x+0.7*w,y,0.3*w,dh); // on-off box - line 1
     rect(x,y+dh,w,dh); // select serial port box - line 2
     rect(x,y+2*dh,0.6*w,dh); // select speed box - line 3
     rect(x,y+2*dh,0.4*w,dh); // refresh serial list box  - line 3
       
     fill(0);textAlign(CENTER,CENTER); text("Configurar Serial",x+0.7*w/2,y+dh/2);
     //text("*",x+u/2,y+h/2); text(ports[indPort],x+3*u,y+h/2); text(speeds[indSpeed],x+7*u,y+h/2); 
     if (conectado) tex="on"; else tex="off";
     text(tex,x+0.85*w,y+dh/2);//9*u,y+h/2);
     textAlign(LEFT,CENTER);
     text(ports[indPort],x+10,y+dh+dh/2); 
     textAlign(CENTER,CENTER);
     text(speeds[indSpeed],x+0.3*w,y+2*dh+dh/2);
     text("reflesh",x+0.8*w,y+2*dh+dh/2);
   */
 }
   //int mouseLeftClick(){
     
   void mouseMoveu(){
      if (mouseX>x && mouseX<x+w && mouseY>y & mouseY<y+h){
         if (estaSobre==false){
             cursor(HAND);
             estaSobre=true;
         }
      } else {
        if (estaSobre){
          cursor(ARROW);
          estaSobre=false;
        }
      }
   }
     
   int mouseClicado(){
     int r=0;
     
     //if (mouseY>y && mouseY<y+h){
       if (refresh.mouseClicado()) { // recarregar a lista das COMs
         if (!conectado) {  // not connected
            ports=append(Serial.list(),"select serial");
            if (ports.length>1){
              indPort=ports.length-2;
            }else{
              indPort=ports.length-1;
            }
            selectSerial.tex=ports[indPort];
            indSpeed=1;
            selectSpeed.tex=speeds[indSpeed];
         }
       } else if (selectSerial.mouseClicado()) { // mudar porta serial
         //println("Com=mouseClicado");
         if (!conectado){
           indPort++;
           if (indPort>=ports.length) indPort=0;
         }
         selectSerial.tex=ports[indPort];
       } else if (selectSpeed.mouseClicado()) { // mudar speed (baudrate)
         if (!conectado){
           indSpeed++;
           if (indSpeed>=speeds.length) indSpeed=0;
         } 
         selectSpeed.tex=speeds[indSpeed];
       } else if (onOff.mouseClicado()){ // mudar X (desconectado) para ok (conectado)
          if (conectado){ // desconectar
              r=-1; // -1 => desconectar
              //port.stop();
              //conectado=false;
          } else {        // conectar
              //if (indPort<ports.length-1 && indSpeed<speeds.length-1){
              if (indPort<ports.length-1 && indSpeed<3){
                  //println("speeds[",indSpeed,"]=",speeds[indSpeed]);
                      //port=new Serial(this,"COM3",9600);
                    //port=new Serial(this,ports[indPort],int(speeds[indSpeed]));
                    r=1;  // retorna 1 para conectar
              }
          }
       }  
     //}
     return r;
   }
}