class Com{
   Serial port;
   String ports[]=append(Serial.list(),"Serial");
   String portName;
   int indPort=ports.length-1;
   //String speed="115200";
   //String speed="250000";
   String speeds[]={"9600","115200","250000","speed"};
   //int portSpeed;
   int indSpeed=speeds.length-1;
   int p=-1;
   int x,y,w,h,u; // u=w/7  com1(4u), speed(4u), ok/x(2u)
   boolean conectado=false;
   boolean erro=false;
   color cor=color(0);
   String tex;
   boolean estaSobre=false; // indica se o cursor do mouse está sobre a area do controle
   
   //constructor
   Com(Serial portt,int xt, int yt, int wt, int ht){
      x=xt; y=yt; w=wt; h=ht;
      u=w/11;
   } 
   void display(){
     strokeWeight(1); stroke(0);fill(200);
     if (conectado) {
         cor=color(0,255,0);
        // fill(cor);
     } else if (erro) {
        cor=color(255,0,255);
     } else {
        cor=color(200);
      //  fill(200);
     }
     fill(cor); rect(x,y-20,11*u,20);
     rect(x,y,u,h); rect(x+u,y,4*u,h); rect(x+5*u,y,4*u,h); rect(x+9*u,y,2*u,h);  
     fill(0);textAlign(CENTER,CENTER); text("Configurar a Serial",x+w/2,y-12);
     //text("*",x+u/2,y+h/2); text(ports[indPort],x+3*u,y+h/2); text(speeds[indSpeed],x+7*u,y+h/2); 
     text("*",x+u/2,y+h/2); text(ports[indPort],x+3*u,y+h/2); text(speeds[indSpeed],x+7*u,y+h/2); 
     if (conectado) tex="on"; else tex="off";
     text(tex,x+10*u,y+h/2);//9*u,y+h/2);
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
     if (mouseY>y && mouseY<y+h){
       if (mouseX>x && mouseX<x+u) { // recarregar a lista das COMs
         if (!conectado) {
            ports=append(Serial.list(),"Serial");
            indPort=ports.length-1;
         }
       } else if (mouseX>x+u && mouseX<x+5*u) { // mudar porta serial
         if (!conectado){
           indPort++;
           if (indPort>=ports.length) indPort=0;
         }
       } else if (mouseX>x+5*u && mouseX<x+9*u) { // mudar speed (baudrate)
         if (!conectado){
           indSpeed++;
           if (indSpeed>=speeds.length) indSpeed=0;
         } 
       } else if (mouseX>x+9*u && mouseX<x+w){ // mudar X (desconectado) para ok (conectado)
          if (conectado){ // desconectar
              r=-1; // -1 => desconectar
              //port.stop();
              //conectado=false;
          } else {        // conectar
              //if (indPort<ports.length-1 && indSpeed<speeds.length-1){
              if (indPort<ports.length-1){
                      //port=new Serial(this,"COM3",9600);
                    //port=new Serial(this,ports[indPort],int(speeds[indSpeed]));
                    r=1;  // retorna 1 para conectar
              }
          }
       }  
     }
     return r;
   }
}