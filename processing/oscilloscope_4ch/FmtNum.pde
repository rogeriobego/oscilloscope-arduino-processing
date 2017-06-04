class FmtNum{
   float v; // valor em float
   float n;  // parte numerica do valor formatado
   boolean nInt=false; // true=n arredondar n para inteiro
   boolean formatar=true; // formatar o texto no formato Engenharia (nu=numero-escala)
   char u; // parte unidade do valor formatado
   int i; // indice da unidade
   char unid[]={'f','p','n','u','m',' ','k','M','G','T','P'}; //pico(-12),nano(-9),micro(-6),mili(-3), (-0),kilo(3),mega(6),giga(9),tera(12)
     // femto, pico, nano, micro, mili, ., kilo, mega, giga, tera, peta

   //constructor
   FmtNum(float v_,boolean nInt_,boolean fmt_){
     v=v_;
     nInt=nInt_;
     v2nu(v);
     formatar=fmt_;
   }
   FmtNum(float v_,boolean nInt_){
     v=v_;
     nInt=nInt_;
     v2nu(v);
     formatar=true;
   } 
   
   String printV(){
     if (nInt){            // inteiro
       if (formatar){      //   inteiro formatado (nu)
         return nf(n,0,0)+u;
       } else {            //  inteiro não formatado (nu)
         return str(int(v));
       }
     } else{                // decimal (não inteiro)
       if (formatar){        //  decimal formatado (nu)
         return str(n)+u;
       } else {              // decimal não formatado (nu)
          return str(v); 
       }
     }  
   }
   
   void setV(float v_){
     v=v_;
     v2nu(v);  
   }
   
   float getV(){
     if (nInt){            // inteiro
         return int(n)*pow(10,(i-5)*3);
     } else{                // decimal (não inteiro)
         return v; 
     }  
   }

   void setNInt(){
       n=round(n);
       nu2v();
   }
   
   // somar/subtrair valores em n
   float addN(float k){ // adicionar/subtrair n (se u=' ' descer casa decimal)
                     // pequeno 1, grande 10 (se u=' ' pequeno=0.1, grande 1)
      float n2=int(n);
      int i2=i;      
      if (n2+k>0){
        n2+=k;
      } else {
        if (i2>0){
           i2--;
           n2=1000+k; 
        }
      }      
      return n2*pow(10,(i2-5)*3);
   } 
   
   void v2nu(float v_){
    i=constrain(int((log(v_)/log(10)+15)/3),0,unid.length-1); // calcular o indice do expoente do numero (v_) na base 10
    if (nInt){
      n=round(v_/pow(10,(i-5)*3));
    } else {
      n=round((v_/pow(10,(i-5)*3))*10.0)/10.0;
    }
    u=unid[i];
   }
   
   void nu2v(){
      v=n*pow(10,(i-5)*3);
      v2nu(v); 
   }
}