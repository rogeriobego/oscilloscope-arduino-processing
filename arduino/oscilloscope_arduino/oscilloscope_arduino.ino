// 28/05/2017 => bug v1.5 => qdo aumenta 1 canal dá erro na serial (disabling serial)
// 22/05/2017 => versão 1.5 => dynamic buffer - 1ch=400pt/ch, 2chs=200pt/ch, 3chs=130pt/ch, 4chs=100pt/ch
// 21/01/2017 => versão 1.4 => melhorar o trigger: informar valor e sentido (subindo/descendo)
// 13/03/2016 => versão 1.3 =>  alterar o clock do ADC para ler maiores frequencias 
// 14/09/2015 => implementei TimerOne.h pin9(pwm) e pino10(2*periodo) output
// 03/08/2016 => versão 1.2 => ler resistor em A5
// 26/07/2015 => versão 1.1 => ler em microsegundos
//String versao="1.2"; // versão do programa - 
#define versao "v1.5"

/* trabalhando com TimerOne
  Timer1.initializa(us);  // inicializa o timer1 (chamar primeiro)
  Timer1.setPeriodo(us); // new period
  Timer1.start(); // 
  Timer1.stop();
  Timer1.restart();
  Timer1.resume();
  Timer1.pwm(pin,duty); pin 9 ou 10, dute(0-1023) (usar primeiro no pwm)
  Timer1.setPwmDuty(pin,duty); //reconfigura o pwm
  Timer1.disablePwm(pin); //stop using pwm on a pin. (volta para o digitalWrite())
  Timer1.attachInterrupt(function);// roda a função como uma interrupção então usar "volatile" no nome de variaveis 
  Timer1.detachInterrupt();//
  noInterrupts();
   blinkCopy=blinkCount; // desliga a interrupção para passar a variavel volatile
  interrupts();
  
*/


#include <TimerOne.h>

//--- constantepara configuração do prescaler ======
// vou usar o PS_16
const unsigned char PS_16 = (1 << ADPS2);
const unsigned char PS_32 = (1 << ADPS2) | (1 << ADPS0);
const unsigned char PS_64 = (1 << ADPS2) | (1 << ADPS1);
const unsigned char PS_128 = (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0);
// configurar no setup: ADC
//======================================

boolean  pwmOn=true; 
unsigned long pwmP=20000; //Periodo 20000us=20ms=0.02s => 50Hz
byte pwmPon=25; // % do pwmP em HIGH

/* -- 07/May/2017 --
int v0[100];
int v1[100];
int v2[100]; // guarda os valores das leituras
int v3[100]; // acrescentei mais um canal em 15/10/2015
*/
/* ------------------------------------------------
/* I changed the 4 buffers (v0[100],v1[],v2[],v3[]) above 
 *  by 1 buffer bellow (vb[408])
 *  The chq indicates how many channels will use and the buffer
 *  will be divided by then:
 *  4 ch (q=102) => 0-101, 102-203, 204-305, 306-407
 *  3 ch (q=136) => 0-135, 136-271, 272-407
 *  2 ch (q=204) => 0-203, 204-407
 *  1 ch (q=408) => 0-407
 *  chi[n] indicates the initial position of the buffer
 *  q indicates the size of channel buffer
   ------------------------------------------------
   */
int vb[400]; // (100*4=400) buffer stores the measure values of all channels
// (old) int chi[]={0,102,204,306}; // channel init position on buffer vb[]
int chi[]={0,100,200,300}; // channel init position on buffer vb[]
int chq=4; // how many channels are ON
int q=100; // quantidade de leituras
int qmax=100; // qtd maxima permitida para q
              // (new)  chq-qmax; 4-100; 3-130; 2-200; 1-400
              // (old)  chq-qmax; 4-102; 3-136; 2-204; 1-408
int vtrigger=0; // tensao de trigger
boolean Ch[]={true,true,true,true}; // ativa/desativa canais
unsigned int dt=4; // 100us a 1000us(1ms) a 3000ms(3s)
char unidade='m'; // unidade: m=milisegundo, u=microsegundo

// obs: para leitura dos 3 canais o tempo mínimo é 380us 
// obs: para leitura dos 4 canais o tempo mínimo é 500us
//      1 canal deve dar 120us

boolean varias=false; // v = varias
boolean uma=false;    // u = uma
boolean fluxo=false; // f = fluxo de dados (envia cada leitura sem guardar na memoria)
                      // velocidade limitada pela serial 115200
unsigned long dtReal, tIni, tFim; // contador de final de tempo para o fluxo
char canalTrigger='x'; // de '0','1','2','3' (canal do trigger), 'x'=não tem trigger


//--------------- Ler Resistor/Capacitor ---------
boolean lerRC=false;
#define pinV 5
#define pinA 7 // pino A 10 multiplex 
#define pinB 8 // pino B 9 multiplex
byte entrada=0;
int vi, vf, v;
//float rx=0, cx=0;
//float r[]={0.0,200.0,20000.0,1000000.0};
//float re[]={0.0,145.2,20692.9,1017847.5};
//float vcc[]={0,871.5,1026.3,1027.1};
unsigned long dtRC=0;
char unidadeRC=' ';
boolean debug=true;

void setup() {

 //---------- configura o preescaler do ADC ======
 ADCSRA &= ~PS_128;  //limpa configuração da biblioteca do arduino
 
 // valores possiveis de prescaler só deixar a linha com prescaler desejado
 // PS_16, PS_32, PS_64 or PS_128
 //ADCSRA |= PS_128; // 64 prescaler
 //   ADCSRA |= PS_64; // 64 prescaler
 //  ADCSRA |= PS_32; // 32 prescaler
  ADCSRA |= PS_16; // 16 prescaler
//=================================================
  
  //definir Timer1 pwm(pino9) e pino10 para monitorar freq
  pinMode(10,OUTPUT);
  //vou inicializar com 10Hz (100ms=100000us)
  Timer1.initialize(pwmP); //100000us=100ms=>10Hz
  Timer1.pwm(9,map(pwmPon,0,100,0,1023)); //pwm no pino9 com 25% duty cycle
  Timer1.attachInterrupt(callback); //attaches callback() como timer overflow interrupt
  //Timer1.stop();

  //inicializar A0, A1, A2, A3 com pull_up
  // não ficou bom pois qdo não tem nada conectado na porta, ela fica
  // com 5v. O melhor é colocar um pull_down com resistor
  //  A0___|R=20k|___GND
  //     |__ Vinput
  /*
   * pinMode(A0,INPUT_PULLUP);
   * pinMode(A1,INPUT_PULLUP);
   * pinMode(A2,INPUT_PULLUP);
   * pinMode(A3,INPUT_PULLUP);
  */
  
  //Serial.begin(9600);
  Serial.begin(115200);
  //Serial.begin(250000);
  Serial.println();
  Serial.print(">init="); Serial.println(versao);
  //printHelp();
  //printConfig();  

  //ler Resistor e Capacitor
  //pinMode(pinCarga,OUTPUT);
  //digitalWrite(pinCarga,LOW);
  pinMode(pinA,OUTPUT);
  pinMode(pinB,OUTPUT);
  selecionar(0);
}

void callback(){
  digitalWrite(10,digitalRead(10)^1); // ^1 = xor (0->1, 1->0)
}

void loop() {
   lerSerial();
   if (varias) {
      lerEnviar();
   } else if (uma) {
      if (canalTrigger=='x'){
        lerEnviar();
        uma=false;
      } else {
        if (trigger()){
          lerEnviar();
          uma=false;
        }
      }
   } else if (fluxo) {
      lerFluxo(); 
   }
   if (lerRC){
     if (millis()>=dtRC){
       lerResistorCapacitor();
       dtRC=millis()+3000;
     }
   }
}

void lerSerial(){
  int k;
  float kf;
  char c, c2;
  if (Serial.available()>0){
    c=Serial.read();
    switch (c){
       case 'h': // enviar help pela serial
          printHelp();
          break;
       case 'd': //alterar o valor de dt (us/ms)
          k=Serial.parseInt(); // como e inteiro então vai de 0 a 32767 (parseint limita 16bits)
          if (k>=1 && k<=30000) {//28/08/15 deve ser dtmin=400us(3canais) dtmax=30000 
             dt=k;
          } 
          c=Serial.read();
          if (c=='u' || c=='m'){
            unidade=c;
          } else { // sem unidade é segundo, então converter para mili (x1000)m
            unidade='m';
            dt*=1000;
          }
//          Serial.print("=> dt="); Serial.print(dt); Serial.print(unidade); Serial.println("s");
          break; 
       case 'q': // alterar valor do q.(ponto no final) (quantidade de leituras)
          k=Serial.parseInt(); // inteiro de 0 a 32767
          c=Serial.read(); // para ir mais rápido colocar um . no final ex: q150.
          if (k>=1 && k<=qmax) {
             q=k; 
          }
          //calcBuffer(); //não precisa pois será usado o qmax
          Serial.print("=> q="); Serial.println(q);
          break;
       case 'c': //cnm : n=0-3, m=(o)ativa/(x)desativa canal n exemplo:  c0x,  c2o
          delay(100);
          c=Serial.read();
          delay(100);
          c2=Serial.read();
          if (c>='0' && c<='3'){
             if (c2=='o'){
                Ch[c-'0']=true;
             }else if (c2=='x'){
                Ch[c-'0']=false;
             }
             // recalcular o buffer para cada canal e colocar o indice
             // inicial para cada canal
             //Serial.println("entrar calcBuffer");
             calcBuffer();
             //Serial.println("saiu calcBuffer");
/*            Serial.print("=> Canais: ");
              for (k=0; k<3;k++){
                Serial.print("Ch"); Serial.print(k); Serial.print("="); Serial.print(Ch[k]);
              }
              Serial.println();
*/              
            }  
          break;
       case 't': // trigger: t(canal)
                 // trigger:  t0, t1, t2, t3
                 //           tx   desligado
                 //           tv512.  valor da tensão 0-1024 (5v)
        delay(100);
        c=Serial.read();
        if ((c>='0' && c<='3') || c=='x'){
           canalTrigger=c;      
        } else if (c=='v'){
          k=Serial.parseInt();
          c=Serial.read();
          if (k>=0 && k<=1024) {
            vtrigger=k;
          }
        }
        
//        Serial.print("=> canalTrigger="); Serial.println(canalTrigger);
        break;
       case '?':
          printConfig(); 
          break;
        case '1': // enviar Uma Amostra (q leituras)
          if (!uma) uma=true;
          if (uma){
             varias=false;
             fluxo=false; 
          }
//          Serial.print("=> uma="); Serial.println(uma);
          break;
        case 'v': // o(on)/x(off) - enviar Varias Amostras (q leituras cada)
           delay(100);
           c=Serial.read();
           if (c=='o') {
              varias=true;
           } else {
              varias=false;
           }
          if (varias){
             uma=false;
             fluxo=false; 
          }
//          Serial.print("=> varias="); Serial.println(varias);
          break;
        case 'f': // o(on)/x(off) - enviar Fluxo (ler e enviar - nao armazenar)
           delay(100);
           c=Serial.read();
           if (c=='o') {
              fluxo=true;
           } else {
              fluxo=false;
           }
          if (fluxo){
             varias=false;
             uma=false; 
             if (unidade=='u'){ // microsegundo
               tIni=micros(); tFim=tIni+dt;
             } else{ // milisegundo
               tIni=millis(); tFim=tIni+dt;
             }
          }
//          Serial.print("=> fluxo="); Serial.println(fluxo);
          break;
         case 'r': // (on/off) - enviar valor lido do Resistor em A5
           delay(100);
           c=Serial.read();
           if (c=='o') {
              lerRC=true;
           } else {
              lerRC=false;
           }
//           Serial.print("=> lerRC="); Serial.println(lerRC);
           dtRC=0;
           break;
         case 's': // Sinal: Ligar/desligar Gerador de Sinal
          delay(100);
          c=Serial.read();
          if (c=='o'){
            Timer1.restart(); // zera o contador
            Timer1.start(); //inicio
//            Serial.println("Timer1 restart/start");
          }else{
            Timer1.stop();
//            Serial.println("Timer1.stop()");
          }
          break;
         case 'p': // Sinal: alterar Período ex: p100m p343u
          kf=Serial.parseFloat();
          if (kf>0){
            c=Serial.read(); // ler unidade e converter para micro
//            Serial.print(">>kf="); Serial.print(kf); Serial.print(" c="); Serial.println(c);
            switch (c){
              case 'u': //já está em micro (u)
                pwmP=long(kf);
                break;
              case 'm': // está em mili (m) então converter para micro (u)
                pwmP=long(kf*1000.0);
//                Serial.print("kf="); Serial.print(kf); Serial.print("m"); Serial.print(" pwmP=kf*1000="); Serial.println(pwmP);
                break;
              case ' ': // está em segundo ( ) então converter para micro (u)
                pwmP=long(kf*1000000.0);
                break;
               default: // se veio caracter desconhecido faço o pwmP=1s
                pwmP=1000000l; // coloquei L no final do 100000 para dizer que é long
//                Serial.print("=> erro unidade pwmP, usando padrao(us)="); Serial.println(1000000);
                break;
            }
            Timer1.setPeriod(pwmP);
            Timer1.setPwmDuty(9,map(pwmPon,0,100,0,1023)); 
//            Serial.print("=> setPeriod="); Serial.println(pwmP);
          }
          break;
         case 'o': // Sinal: alterar tempo em ON ex: o25% o50%
          k=int(Serial.parseFloat());
          c=Serial.read(); // só ler a % e desprezar (faz o parseInt ficar mais rapido
          if (k>=0 && k<=100){
            pwmPon=k;
            Timer1.setPwmDuty(9,map(pwmPon,0,100,0,1023)); 
//            Serial.print("=> pwm on="); Serial.print(k); Serial.println("%");          
          }
          break;
         default:
           Serial.print("erro c="); Serial.println(c,HEX);
    }
  }
}

void calcBuffer(){
  //Serial.println("entrou calcBuffer");
  chq=0;
  // conta a quantidade de canais ativos
  for (int k=0;k<4;k++){
    if (Ch[k]) {chq+=1;}
  }
  // calc size of each channel
  switch (chq){
    case 0:
      qmax=0;
      break;
    case 1:
      qmax=400;
      break;
    case 2:
      qmax=200;
      break;
    case 3:
      qmax=130;
      break;
    case 4:
      qmax=100;
      break;
  }
  /*
  if (chq<=0) {
    qmax=0;
  } else {
    qmax=408/chq; // chq-qmax; 4-102; 3-136; 2-204; 1-408
  }
*/
  if (q>qmax) {
    q=qmax;
  }
  //Serial.print("q=408/chq=");Serial.print("408/");Serial.print(chq);Serial.print("=");Serial.println(q);
  // qtdCanais-qmax (chq-qmax) (4-100) (3-130) (2-200) (1-400)
  int chInit=0;
  for (int k=0; k<4; k++){
    if (Ch[k]) {
      chi[k]=chInit;
      chInit+=qmax;
    }
  }
  
 // Serial.print("chq="); Serial.print(chq); Serial.print(" q="); Serial.print(q); Serial.print(" qmax="); Serial.println(qmax);
//  for (int k=0; k<4; k++){
 //    Serial.print("k=");Serial.print(k); Serial.print(" chi[k]="); Serial.println(chi[k]);
 // }
  
}

void printHelp(){
   Serial.println("-----------------------");
   Serial.print("! BegOscopio "); Serial.print(versao); Serial.println(" - rogerio.bego@hotmail.com !");
   Serial.println("-----------------------");
/*
   Serial.println("----------- help ---------------------");
   Serial.println(" h    : help");
   Serial.println(" ?    : exibir as configuracoes atuais");
   Serial.println(" -------- controle da amostragem ------");
   Serial.println(" d___ : d[1-3000][un] - ex: d100m, d200u - dt = intervalo de tempo (us/ms) entre as leituras");
   Serial.println(" q___ : q[1-100]. - qtd de leituras");
   Serial.println(" cn_  : (o)ativa,(x)desativa canal: ex:  c2o (ativar Ch2), c0x (desativar Ch0)");
   Serial.println(" t_   : 0,1,2,3(canal),x(off)  ");
   Serial.println(" tv__ : tv512.  valor da tensao 0-1024 (0-5v)");
   Serial.println(" -------- envio das amostras ---------");
   Serial.println(" 1    : enviar uma amostra");
   Serial.println(" v_   : o(on),x(off) enviar varias amostras");
   Serial.println(" f_   : o(on),x(off) enviar fluxo de dados");
   Serial.println("    obs:  1, v, f sao mutuamente excludentes");
   Serial.println(" -------- leitura de Resistor ou Capacitor ----");
   Serial.println(" r_   : o(on),x(off) ler Resistor ou Capacitor");
   Serial.println(" -------- Gerador de Sinal pwm ---------");
   Serial.println(" s_   : o(on),x(off) ativa Ger.Sinal (pwm na porta 9) (porta 10 indica 2*T)");
   Serial.println(" p_   : p[valor][unidade] periodo do sinal de 100u a 8s");
   Serial.println(" o_   : o[0-100][%] Ton em porcentagem");
   Serial.println("----------------------------------------");
   */
}



void printConfig(){
   Serial.println("------ configuracoes -------");
   Serial.print(">? q="); Serial.println(q);
   Serial.print(">? qmax="); Serial.println(qmax);
   Serial.print(">? dt="); Serial.print(dt); Serial.print(unidade); Serial.println("s");
   float t=(float)q * (float)dt;
   Serial.print(" -> T=(q*dt)= "); Serial.print(t); Serial.print(unidade); Serial.println("s ");
   Serial.print(">? Canais: "); 
   for (int k=0; k<4; k++){
      Serial.print("  Ch"); Serial.print(k); Serial.print("="); 
      if (Ch[k]) {
        Serial.print("o");     
      } else {
        Serial.print("x");
      }
   }
   Serial.println();
   Serial.print(">? canalTrigger="); Serial.println(canalTrigger);
   Serial.print(">? uma="); Serial.println(uma);
   Serial.print(">? varias="); Serial.println(varias);
   Serial.print(">? fluxo="); Serial.println(fluxo);
   Serial.print(">? lerRC="); Serial.println(lerRC);
   Serial.print(">? pwmOn="); Serial.println(pwmOn);
   Serial.print(">? pwmP="); Serial.print(pwmP); Serial.println("us");
   Serial.print(">? pwmPon="); Serial.print(pwmPon); Serial.println("%");
}


unsigned long microsOuMillis(){
   if (unidade=='u'){
      return micros();
   } else {
      return millis();
   }
}

//-- procurar tensão maior que zero no canalTrigger ----
//-- se UMA=true então fica aguardando indefinitivamente
//-- se UMA=false então fica aguardando até o tempo tFIM (q*dt)
boolean trigger(){ // a variavel canalTrigger indica qual canal fará o trigger: 0,1,2 ou 3
  unsigned long tFim; // contador do tempo Final
  int v1=0,v2=0; 
  //int c1=0, c2=0;
  boolean achou=false;
    tFim=microsOuMillis()+q*dt;
    // dispara na subida do valor vtrigger+10
    //fica lendo a tensão enquanto for maior que vtrigger 
    //   E tempo menor que tFim
    do{
      v1=analogRead(canalTrigger-'0');
      //c1++;
    }while (v1>vtrigger && microsOuMillis()<tFim);
  //  while (v1=analogRead(canalTrigger-'0')>0 && microsOuMillis()<tFim){c1++;}
    if (v1<=vtrigger){
      tFim=microsOuMillis()+q*dt;
      //fica lendo a tensão enquanto for menor ou igual a 10+vtrigger
      // E tempo menor que tFim
      do{
        v2=analogRead(canalTrigger-'0');
        //c2++;
      }while(v2<=10+vtrigger && microsOuMillis()<tFim);
      //while (v2=analogRead(canalTrigger-'0')<=0 && microsOuMillis()<tFim){c2++;}
      if (v2>10+vtrigger){ 
        achou=true;
      }
      //Serial.print("v1="); Serial.print(v1); Serial.print(" v2=");Serial.println(v2);
      //Serial.print("c1=");Serial.print(c1);Serial.print(" c2=");Serial.println(c2);
    }
    return achou;
}

    
void lerEnviar(){

/*  
  // enviar quais canais serao enviados. ex: >ch=1<\t>3<\t>
  Serial.print(">chq="); Serial.print(chq); Serial.print("\t");
  for (int k=0; k<4; k++){
    if (Ch[k]){Serial.print(k); Serial.print("\t");}    
  }
  Serial.println("");

  //enviar os valores dos canais
  for (int k=0; k<q; k++){
    Serial.print(">v="); Serial.print(k); Serial.print("\t");
    if (Ch[0]) {Serial.print(chi[0]+k); Serial.print("\t");}
    if (Ch[1]) {Serial.print(chi[1]+k); Serial.print("\t");}
    if (Ch[2]) {Serial.print(chi[2]+k); Serial.print("\t");}
    if (Ch[3]) {Serial.print(chi[3]+k); Serial.print("\t");}
    Serial.println("");
  }

  
  return;

  */

  
  unsigned long tFim; // contador do tempo Final
  unsigned long tTotalReal; // tempo Total da leitura dos valores.
    if (canalTrigger>='0' && canalTrigger<='3'){
      //Serial.print("canalTrigger=");Serial.println(canalTrigger);
      Serial.print("trigger="); Serial.println(trigger());
     }
    tTotalReal=microsOuMillis();

    for (int k=0; k<q; k++){
      tFim=microsOuMillis()+dt; 
/*
      if (Ch[0]) {v0[k]=analogRead(A0);}
      if (Ch[1]) {v1[k]=analogRead(A1);}
      if (Ch[2]) {v2[k]=analogRead(A2);}
      if (Ch[3]) {v3[k]=analogRead(A3);}
*/

      if (Ch[0]) {vb[chi[0]+k]=analogRead(A0);}
      if (Ch[1]) {vb[chi[1]+k]=analogRead(A1);}
      if (Ch[2]) {vb[chi[2]+k]=analogRead(A2);}
      if (Ch[3]) {vb[chi[3]+k]=analogRead(A3);}
      while (microsOuMillis()<tFim){}
    }

    
    tTotalReal=microsOuMillis()-tTotalReal; // total de tempo para ler todas as amostras
    dtReal=tTotalReal/q; // calcular o tempo médio de cada leitura
  Serial.println();
  Serial.print(">q="); Serial.println(q);
  Serial.print(">dt="); Serial.print(dt); Serial.print(unidade); Serial.println("s");
  Serial.print(">dtReal="); Serial.print(dtReal); //  Serial.print(unidade); Serial.println("s");
    if (unidade=='m'){
      Serial.println("e-3");
    }else if (unidade=='u'){
      Serial.println("e-6");
    }
    
  // enviar quais canais serao enviados. ex: >ch=1<\t>3<\t>
  Serial.print(">chq="); Serial.print(chq); Serial.print("\t");
  for (int k=0; k<4; k++){
    if (Ch[k]){Serial.print(k); Serial.print("\t");}    
  }
  Serial.println("");
  
  //enviar os valores dos canais
  for (int k=0; k<q; k++){
    Serial.print(">v="); Serial.print(k); Serial.print("\t");
    if (Ch[0]) {Serial.print(vb[chi[0]+k]); Serial.print("\t");}
    if (Ch[1]) {Serial.print(vb[chi[1]+k]); Serial.print("\t");}
    if (Ch[2]) {Serial.print(vb[chi[2]+k]); Serial.print("\t");}
    if (Ch[3]) {Serial.print(vb[chi[3]+k]); Serial.print("\t");}
    Serial.println("");

  /* 
    if (Ch[0]) {Serial.print(chi[0]+k); Serial.print("\t");}
    if (Ch[1]) {Serial.print(chi[1]+k); Serial.print("\t");}
    if (Ch[2]) {Serial.print(chi[2]+k); Serial.print("\t");}
    if (Ch[3]) {Serial.print(chi[3]+k); Serial.print("\t");}
    Serial.println("");
  */
  }
 /* -- eliminado em 07/May/2017 - criei buffer dinamico  vb[408] --   
  for (int k=0; k<q; k++){
    Serial.print(">v=");
    Serial.print(k); Serial.print("\t");
    Serial.print(v0[k]); Serial.print("\t");
    Serial.print(v1[k]); Serial.print("\t");
    Serial.print(v2[k]); Serial.print("\t");
    Serial.println(v3[k]);
  } 
  */ 
  Serial.print(">tTotalReal="); Serial.print(tTotalReal); //Serial.print(unidade); Serial.println("s");
    if (unidade=='m'){
      Serial.println("e-3");
    }else if (unidade=='u'){
      Serial.println("e-6");
    }
}

void lerFluxo(){
  int v0, v1, v2, v3; // guarda os valores das leituras
  //byte v0, v1, v2, v3; // guarda os valores das leituras
  boolean leu=false;
    if (microsOuMillis()>=tFim){
      dtReal=microsOuMillis()-tIni;
      tIni=microsOuMillis(); tFim=tIni+dt;
      if (Ch[0]) {v0=analogRead(A0);}
      if (Ch[1]) {v1=analogRead(A1);}
      if (Ch[2]) {v2=analogRead(A2);}
      if (Ch[3]) {v3=analogRead(A3);}
      //if (Ch[0]) {v0=analogRead(A0)/4;}
      //if (Ch[1]) {v1=analogRead(A1)/4;}
      //if (Ch[2]) {v2=analogRead(A2)/4;}
      //if (Ch[3]) {v3=analogRead(A3)/4;}
      leu=true;
    }
  if (leu){
    Serial.print(">f=");
    Serial.print("0"); Serial.print("\t");
    Serial.print(dtReal); 
      if (unidade=='m'){
        Serial.print("e-3");
      }else if (unidade=='u'){
        Serial.print("e-6");
      }
      Serial.print("\t");
    if (Ch[0]) {Serial.print(v0);} else {Serial.print("0");} Serial.print("\t");
    if (Ch[1]) {Serial.print(v1);} else {Serial.print("0");} Serial.print("\t");
    if (Ch[2]) {Serial.print(v2);} else {Serial.print("0");} Serial.print("\t");
    if (Ch[3]) {Serial.println(v3);} else {Serial.println("0");}
  }
}

//=========== Rotinas para leitura de Resistor e Capacitor ===========

void lerResistorCapacitor(){
  descarregar();
  lerEntrada(1);
  if (vf-vi>=100) {// e' capacitor
    calcCapacitor();
  } else {
    if (v<900) { // calcular valor do resistor
      calcRx();
    } else { // subir selecionar 2
      // descarregar se for capacitor
      descarregar();
      lerEntrada(2);
      if (vf-vi>=100) { // capacitor - escala 2
        calcCapacitor();
      } else { // resistor
        if (v<900){ // calcular valor do resistor
          calcRx();
        } else { // subir selecionar 3 (nao consegue detectar capacitor corretamente)
          lerEntrada(3);
          if (v<900){
            calcRx();
          } else {
            Serial.println(">rc=3\tColoque RC");
          }
        }
      }
    }
  }
}

void calcCapacitor(){
  float re[]={0.0,145.2,20692.9,1017847.5};
  float cx=0;
  descarregar();
  selecionar(1);
  dtRC=millis(); 
  while (analogRead(pinV)<647){} // 647 = 63.2% Vcc => (nessa voltagem  t=rc)
  dtRC=millis()-dtRC; 
  if (dtRC>=100) { // dentro da faixa Cx>1mF
    cx=(float)dtRC/re[entrada];
    unidadeRC='m';  //resultado em mF
  } else { // fora da faixa, subir para escala 2
    descarregar();
    selecionar(2);
    dtRC=millis();
    while (analogRead(pinV)<647){}
    dtRC=millis()-dtRC;
    if (dtRC>=10) { // dentro da faixa 
      cx=(float)dtRC*1000.0/re[entrada];
      unidadeRC='u'; // resultado em uF
    } else { // fora da faixa, então subir escala
      descarregar();
      selecionar(3);
      dtRC=millis();
      while (analogRead(pinV)<647){}
      dtRC=millis()-dtRC;
      cx=(float)dtRC*1000000.0/re[entrada]; 
      unidadeRC='n'; // resultado em nF
    }
  }
  Serial.print(">c="); Serial.print(entrada); Serial.print("\t"); Serial.print(cx); Serial.print(" "); Serial.print(unidadeRC); Serial.println("F");
}

void lerEntrada(byte e){
  selecionar(e);
  dtRC=micros();
  vi=analogRead(pinV);
  v=0;
  for (int k=0; k<10; k++){
     v+=analogRead(pinV);
  }
  v/=10;
  vf=analogRead(pinV);
  dtRC=micros()-dtRC;
}

void descarregar(){
  selecionar(0);
  while (analogRead(pinV)>0){}
}

void calcRx(){
  float re[]={0.0,145.2,20692.9,1017847.5};
  float vcc[]={0,871.5,1026.3,1027.1};
  float rx=0;
  rx=re[entrada]*(float)v/(vcc[entrada]-(float)v);
  Serial.print(">r="); Serial.print(entrada); Serial.print("\t");
  switch (entrada) {
     case 1:
      if (rx>=1000){
        rx/=1000;
        Serial.print(rx); Serial.println(" Kohm");
      } else {
        Serial.print(rx); Serial.println(" ohm");
      }
      break;
     case 2:
      Serial.print(rx/1000); Serial.println(" Kohm");
      break;
     case 3:
      Serial.print(rx/1000000); Serial.println(" Mohm");
      break; 
  }
}

void selecionar(byte e){
  entrada=e;
  digitalWrite(pinA,bitRead(entrada,0));
  digitalWrite(pinB,bitRead(entrada,1));
}


