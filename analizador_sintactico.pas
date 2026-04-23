Unit analizador_sintactico;

Interface

Uses
    crt, analizador_lexico,archivo;

Const
    MaxProd =   10;
   type t_estado = (enProceso, errorLexico, errorSintactico, Exito)  ;
 const rutaArbol = 'Fuente.txt';
Type
//Definicion TAS
    TProduccion =   Record
        elem:   array[1..MaxProd] Of TipoSG;
        cant:   0..MaxProd;
    End;
    TipoVariable =   Vinicio..Vp;
    TipoTermPesos =   Tid..pesos;
    TipoTAS =   array [TipoVariable, TipoTermPesos] Of ^Tproduccion;
    TApuntNodo =   ^TNodoArbol;
    TipoHIjos =   Record
        elem:   array[1..MaxProd] Of TApuntNodo;
        cant:   0..MaxProd;
    End;
    TNodoArbol =   Record
        Simbolo:   TipoSG;
        lexema:   string;
        Hijos:   TipoHIjos;
    End;

//Definicion Pila
t_elemPila = record
  Simbolo:TipoSG;
  NodoArbol:TApuntNodo; //arbol de derivacion
end;

t_pila = record
  elem:array[1..200]of t_elemPila;
  tope:0..200;
end;




procedure GuardarArbol(Ruta:string; var arbol:TApuntNodo);
Procedure analizadorSintactico(VAR Fuente:t_arch;Var arbol:TApuntNodo; Var estado:t_estado);
Procedure AnalizadorPredictivo(VAR Fuente:t_arch;Var arbol:TApuntNodo; Var estado : t_estado);
Procedure cargarTAS(Var TAS:TipoTAS);
Implementation

//Implementacion pila
procedure crearpila(var p:t_pila);
 begin
  p.tope:=0;
 end;

 procedure apilar (var p:t_pila; x:t_elemPila);
 begin
 p.tope:=p.tope+1;
 p.elem[p.tope]:=x;
 end;

 procedure desapilar (var p:t_pila;var x:t_elemPila);
 begin
  x:= p.elem[p.tope];
 p.tope:=p.tope-1;
  end;


procedure apilarTodos(var Celda:Tproduccion; var padre:TApuntNodo; var pila: t_pila);
 var i:0..MaxProd;
   elemento_pila: t_elemPila;
 begin
 for i:= Celda.cant downto 1 do
  begin
  elemento_pila.simbolo := Celda.elem[i];
  elemento_pila.NodoArbol := padre^.Hijos.elem[i];
  apilar(pila,elemento_pila);
  end;
 end;

//Implementacion Arbol
Procedure CrearNodo (SG:tipoSG; Var apuntador:TApuntNodo);
Begin
    new(apuntador);
    apuntador^.simbolo := SG;
    apuntador^.lexema := '';
    apuntador^.hijos.cant := 0;
End;

Procedure AgregarHijo(Var raiz:TApuntNodo; Var hijo:TApuntNodo);
Begin
    If raiz^.hijos.cant < MaxProd Then
        Begin
            inc(raiz^.hijos.cant);
            raiz^.hijos.elem[raiz^.hijos.cant] := hijo;
        End;
End;

Procedure GuardarNodo (var arch:text; var arbol:TApuntNodo; dezpl:string);
var
    i:byte;
begin
    writeln(arch,dezpl,arbol^.simbolo,' (',arbol^.lexema,')');
    for i:=1 to arbol^.hijos.cant do
         begin
             GuardarNodo(arch,arbol^.hijos.elem[i],dezpl+'  ');
         end;
end;

procedure GuardarArbol(Ruta:string; var arbol:TApuntNodo);
var
    Arch:text;
begin
    assign(Arch,ruta);
    Rewrite(Arch);
    GuardarNodo(arch,arbol,'');
    close(arch);
end;

//Implementacion TAS
Procedure inicializarTAS(Var TAS:TipoTAS);
Var i,j:   TipoSG;
Begin
    For i:=Vinicio To Vp Do
        For j:=Tid To pesos Do
            TAS[i, j] := Nil;
End;

procedure crearTAS(var TAS: TipoTAS);
begin
  inicializarTAS(TAS);
  cargarTAS(TAS);
end;

Procedure cargarTAS(Var TAS:TipoTAS);
Begin
    //Inicio->program id pase Sentencias gol
    new (TAS[Vinicio, Tprogram]);
    TAS[Vinicio, Tprogram]^.elem[1] := Tprogram;
    TAS[Vinicio, Tprogram]^.elem[2] := Tid;
    TAS[Vinicio, Tprogram]^.elem[3] := Tpase;
    TAS[Vinicio, Tprogram]^.elem[4] := Vsentencias;
    TAS[Vinicio, Tprogram]^.elem[5] := Tgol;
    TAS[Vinicio, Tprogram]^.cant := 5;

    //Sentencias -> Linea ; Sentencias2
    new (TAS[Vsentencias, Tid]);
    TAS[Vsentencias, Tid]^.elem[1] := Vlinea;
    TAS[Vsentencias, Tid]^.elem[2] := TpuntoComa;
    TAS[Vsentencias, Tid]^.elem[3] := Vsentencias2;
    TAS[Vsentencias, Tid]^.cant := 3;

    //Sentencias -> Linea ; Sentencias2
    new (TAS[Vsentencias, Tvar]);
    TAS[Vsentencias, Tvar]^.elem[1] := Vlinea;
    TAS[Vsentencias, Tvar]^.elem[2] := TpuntoComa;
    TAS[Vsentencias, Tvar]^.elem[3] := Vsentencias2;
    TAS[Vsentencias, Tvar]^.cant := 3;

    //Sentencias -> Linea ; Sentencias2
    new (TAS[Vsentencias, Tlio]);
    TAS[Vsentencias, Tlio]^.elem[1] := Vlinea;
    TAS[Vsentencias, Tlio]^.elem[2] := TpuntoComa;
    TAS[Vsentencias, Tlio]^.elem[3] := Vsentencias2;
    TAS[Vsentencias, Tlio]^.cant := 3;

    //Sentencias -> Linea ; Sentencias2
    new (TAS[Vsentencias, Tdefinir]);
    TAS[Vsentencias, Tdefinir]^.elem[1] := Vlinea;
    TAS[Vsentencias, Tdefinir]^.elem[2] := TpuntoComa;
    TAS[Vsentencias, Tdefinir]^.elem[3] := Vsentencias2;
    TAS[Vsentencias, Tdefinir]^.cant := 3;

    //Sentencias -> Linea ; Sentencias2
    new (TAS[Vsentencias, Tasistir]);
    TAS[Vsentencias, Tasistir]^.elem[1] := Vlinea;
    TAS[Vsentencias, Tasistir]^.elem[2] := TpuntoComa;
    TAS[Vsentencias, Tasistir]^.elem[3] := Vsentencias2;
    TAS[Vsentencias, Tasistir]^.cant := 3;

    //Sentencias -> Linea ; Sentencias2
    new (TAS[Vsentencias, Tgambetear]);
    TAS[Vsentencias, Tgambetear]^.elem[1] := Vlinea;
    TAS[Vsentencias, Tgambetear]^.elem[2] := TpuntoComa;
    TAS[Vsentencias, Tgambetear]^.elem[3] := Vsentencias2;
    TAS[Vsentencias, Tgambetear]^.cant := 3;

    //Sentencias2 -> Linea ; Sentencias2
    new (TAS[Vsentencias2, Tid]);
    TAS[Vsentencias2, Tid]^.elem[1] := Vlinea;
    TAS[Vsentencias2, Tid]^.elem[2] := TpuntoComa;
    TAS[Vsentencias2, Tid]^.elem[3] := Vsentencias2;
    TAS[Vsentencias2, Tid]^.cant := 3;

    //Sentencias2 -> epsilon
    new (TAS[Vsentencias2, Tgol]);
    TAS[Vsentencias2, Tgol]^.cant := 0;
    //Sentencias2 -> epsilon
    new (TAS[Vsentencias2, TpuntoComa]);
    TAS[Vsentencias2, TpuntoComa]^.cant := 0;

    //Sentencias2 -> Linea ; Sentencias2
    new (TAS[Vsentencias2, Tvar]);
    TAS[Vsentencias2, Tvar]^.elem[1] := Vlinea;
    TAS[Vsentencias2, Tvar]^.elem[2] := TpuntoComa;
    TAS[Vsentencias2, Tvar]^.elem[3] := Vsentencias2;
    TAS[Vsentencias2, Tvar]^.cant := 3;

    //Sentencias2 -> Linea ; Sentencias2
    new (TAS[Vsentencias2, Tlio]);
    TAS[Vsentencias2, Tlio]^.elem[1] := Vlinea;
    TAS[Vsentencias2, Tlio]^.elem[2] := TpuntoComa;
    TAS[Vsentencias2, Tlio]^.elem[3] := Vsentencias2;
    TAS[Vsentencias2, Tlio]^.cant := 3;

    //Sentencias2 -> Linea ; Sentencias2
    new (TAS[Vsentencias2, Tdefinir]);
    TAS[Vsentencias2, Tdefinir]^.elem[1] := Vlinea;
    TAS[Vsentencias2, Tdefinir]^.elem[2] := TpuntoComa;
    TAS[Vsentencias2, Tdefinir]^.elem[3] := Vsentencias2;
    TAS[Vsentencias2, Tdefinir]^.cant := 3;

    //Sentencias2 -> Linea ; Sentencias2
    new (TAS[Vsentencias2, Tasistir]);
    TAS[Vsentencias2, Tasistir]^.elem[1] := Vlinea;
    TAS[Vsentencias2, Tasistir]^.elem[2] := TpuntoComa;
    TAS[Vsentencias2, Tasistir]^.elem[3] := Vsentencias2;
    TAS[Vsentencias2, Tasistir]^.cant := 3;

    //Sentencias2 -> Linea ; Sentencias2
    new (TAS[Vsentencias2, Tgambetear]);
    TAS[Vsentencias2, Tgambetear]^.elem[1] := Vlinea;
    TAS[Vsentencias2, Tgambetear]^.elem[2] := TpuntoComa;
    TAS[Vsentencias2, Tgambetear]^.elem[3] := Vsentencias2;
    TAS[Vsentencias2, Tgambetear]^.cant := 3;

    //Linea -> Asignar
    new (TAS[Vlinea, Tid]);
    TAS[Vlinea, Tid]^.elem[1] := Vasignar;
    TAS[Vlinea, Tid]^.cant := 1;

    //Linea -> var Variables
    new (TAS[Vlinea, Tvar]);
    TAS[Vlinea, Tvar]^.elem[1] := Tvar;
    TAS[Vlinea, Tvar]^.elem[2] := Vvariables;
    TAS[Vlinea, Tvar]^.cant := 2;

    //Linea -> Leer
    new (TAS[Vlinea, Tlio]);
    TAS[Vlinea, Tlio]^.elem[1] := Vleer;
    TAS[Vlinea, Tlio]^.cant := 1;

    //Linea -> Escribir
    new (TAS[Vlinea, Tdefinir]);
    TAS[Vlinea, Tdefinir]^.elem[1] := Vescribir;
    TAS[Vlinea, Tdefinir]^.cant := 1;

    //Linea -> Condicional
    new (TAS[Vlinea, Tasistir]);
    TAS[Vlinea, Tasistir]^.elem[1] := Vcondicional;
    TAS[Vlinea, Tasistir]^.cant := 1;

    //Linea -> Ciclo
    new (TAS[Vlinea, Tgambetear]);
    TAS[Vlinea, Tgambetear]^.elem[1] := Vciclo;
    TAS[Vlinea, Tgambetear]^.cant := 1;

    //Variables -> id Variables2
    new (TAS[Vvariables, Tid]);
    TAS[Vvariables, Tid]^.elem[1] := Tid;
    TAS[Vvariables, Tid]^.elem[2] := Vvariables2;
    TAS[Vvariables, Tid]^.cant := 2;

    //Variables2 -> epsilon
    new (TAS[Vvariables2, TpuntoComa]);
    TAS[Vvariables2, TpuntoComa]^.cant := 0;

    //Variables2 -> , Variables
    new (TAS[Vvariables2, Tcoma]);
    TAS[Vvariables2, Tcoma]^.elem[1] := Tcoma;
    TAS[Vvariables2, Tcoma]^.elem[2] := Vvariables;
    TAS[Vvariables2, Tcoma]^.cant := 2;

  //ASIGNAR
    //Asignar ->  ‘’id’’ <:=> <op>
    new(TAS[Vasignar ,Tid ]) ;
    TAS[Vasignar ,Tid]^.elem[1]:= Tid;
    TAS[Vasignar ,Tid]^.elem[2]:= TdosPuntosIgual;
    TAS[Vasignar ,Tid]^.elem[3]:= Vop;
    TAS[Vasignar ,Tid]^.cant:= 3 ;

  //LEER
    //leer-> lio ( cadena , id )    <lio>
    new(TAS[Vleer,Tlio ]);
    TAS[Vleer ,Tlio]^.elem[1]:= Tlio;
    TAS[Vleer ,Tlio]^.elem[2]:= TparA;
    TAS[Vleer ,Tlio]^.elem[3]:= Tcadena;
    TAS[Vleer ,Tlio]^.elem[4]:= Tcoma;
    TAS[Vleer ,Tlio]^.elem[5]:= Tid;
    TAS[Vleer ,Tlio]^.elem[6]:= TparC;
    TAS[Vleer ,Tlio]^.cant:= 6 ;

  //ESCRIBIR
    //escribir --> definir ( L ) <definir>
    new(TAS[Vescribir,Tdefinir ]);
    TAS[Vescribir ,Tdefinir]^.elem[1]:= Tdefinir;
    TAS[Vescribir ,Tdefinir]^.elem[2]:= TparA;
    TAS[Vescribir ,Tdefinir]^.elem[3]:= Vl;
    TAS[Vescribir ,Tdefinir]^.elem[4]:= TparC;
    TAS[Vescribir ,Tdefinir]^.cant:= 4 ;

  //L
    //L --> OP L2  <id>
    new(TAS[Vl,Tid ]);
    TAS[Vl ,Tid]^.elem[1]:= Vop;
    TAS[Vl ,Tid]^.elem[2]:= Vl2;
    TAS[Vl ,Tid]^.cant:= 2 ;

    //L --> OP L2  <(>
    new(TAS[Vl,TparA ]);
    TAS[Vl ,TparA]^.elem[1]:= Vop;
    TAS[Vl ,TparA]^.elem[2]:= Vl2;
    TAS[Vl ,TparA]^.cant:= 2 ;

    //L --> cadena L2  <cadena>
    new(TAS[Vl,Tcadena ]);
    TAS[Vl ,Tcadena]^.elem[1]:= Tcadena;
    TAS[Vl ,Tcadena]^.elem[2]:= Vl2;
    TAS[Vl ,Tcadena]^.cant:= 2 ;

    //L --> OP L2   <->
    new(TAS[Vl,Tmenos ]);
    TAS[Vl ,Tmenos]^.elem[1]:= Vop;
    TAS[Vl ,Tmenos]^.elem[2]:= Vl2;
    TAS[Vl ,Tmenos]^.cant:= 2 ;

    //L --> OP L2   <const>
    new(TAS[Vl,Tconst ]);
    TAS[Vl ,Tconst]^.elem[1]:= Vop;
    TAS[Vl ,Tconst]^.elem[2]:= Vl2;
    TAS[Vl ,Tconst]^.cant:= 2 ;

    //L --> OP L2   <arco>
    new(TAS[Vl,Tarco ]);
    TAS[Vl ,Tarco]^.elem[1]:= Vop;
    TAS[Vl ,Tarco]^.elem[2]:= Vl2;
    TAS[Vl ,Tarco]^.cant:= 2 ;

    //L --> OP L2   <zurda>
    new(TAS[Vl,Tzurda ]);
    TAS[Vl ,Tzurda]^.elem[1]:= Vop;
    TAS[Vl ,Tzurda]^.elem[2]:= Vl2;
    TAS[Vl ,Tzurda]^.cant:= 2 ;

  // L2
    // L2 --> , CADENA L2  <,>
    new(TAS[Vl2,Tcoma ]);
    TAS[Vl2 ,Tcoma]^.elem[1]:= Tcoma;
    TAS[Vl2 ,Tcoma]^.elem[2]:= Vl3;
    TAS[Vl2 ,Tcoma]^.elem[3]:= Vl2;
    TAS[Vl2 ,Tcoma]^.cant:= 3 ;

    // L2 --> epsilon <)>
    new(TAS[Vl2,TparC ]);
    TAS[Vl2,TparC]^.cant:= 0;

// L3
    // L3 --> OP  <id>
    new(TAS[Vl3,Tid ]);
    TAS[Vl3 ,Tid]^.elem[1]:= Vop;
    TAS[Vl3 ,Tid]^.cant:= 1 ;

    // L3 --> OP  <(>
    new(TAS[Vl3,TparA ]);
    TAS[Vl3 ,TparA]^.elem[1]:= Vop;
    TAS[Vl3 ,TparA]^.cant:= 1 ;

// L3 --> cadena  <cadena>
    new(TAS[Vl3,Tcadena ]);
    TAS[Vl3 ,Tcadena]^.elem[1]:= Tcadena;
    TAS[Vl3 ,Tcadena]^.cant:= 1 ;

    // L3 --> OP  <->
    new(TAS[Vl3,Tmenos ]);
    TAS[Vl3 ,Tmenos]^.elem[1]:= Vop;
    TAS[Vl3 ,Tmenos]^.cant:= 1 ;

    // L3 --> OP  <const>
    new(TAS[Vl3,Tconst ]);
    TAS[Vl3 ,Tconst]^.elem[1]:= Vop;
    TAS[Vl3 ,Tconst]^.cant:= 1 ;

    // L3 --> OP  <arco>
    new(TAS[Vl3,Tarco ]);
    TAS[Vl3 ,Tarco]^.elem[1]:= Vop;
    TAS[Vl3 ,Tarco]^.cant:= 1 ;

    // L3 --> OP  <zurda>
    new(TAS[Vl3,Tzurda ]);
    TAS[Vl3 ,Tzurda]^.elem[1]:= Vop;
    TAS[Vl3 ,Tzurda]^.cant:= 1 ;


   //CONDICIONAL -> asistir CONDICIÓN marcar SENTENCIAS gol
   new (TAS[vcondicional, Tasistir]);
      TAS[Vcondicional, Tasistir]^.elem[1] := Tasistir;
      TAS[Vcondicional, Tasistir]^.elem[2] := Vcondicion;
      TAS[Vcondicional, Tasistir]^.elem[3] := Tmarcar;
      TAS[Vcondicional, Tasistir]^.elem[4] := Vsentencias;
      TAS[Vcondicional, Tasistir]^.elem[5] := Vopgol;
      TAS[Vcondicional, Tasistir]^.cant := 5;

//Opgol -> gol Opgol2
   new (TAS[Vopgol, Tgol]);
      TAS[Vopgol, Tgol]^.elem[1] := Tgol;
      TAS[Vopgol, Tgol]^.elem[2] := Vopgol2;
      TAS[Vopgol, Tgol]^.cant := 2;

 //Opgol -> epsilon
         new (TAS[Vopgol, TpuntoComa]);
            TAS[Vopgol, TpuntoComa]^.cant := 0;

//Opgol2 -> epsilon
        new (TAS[Vopgol2, TpuntoComa]);
           TAS[Vopgol2, TpuntoComa]^.cant := 0;

//Opgol2 -> epsilon
         new (TAS[Vopgol2, Tcontra]);
      TAS[Vopgol2, Tcontra]^.elem[1] := Tcontra;
      TAS[Vopgol2, Tcontra]^.elem[2] := Vsentencias;
      TAS[Vopgol2, Tcontra]^.elem[3] := Tgol;
            TAS[Vopgol2, Tcontra]^.cant := 3;

   //CICLO -> CICLO -> gambetear CONDICIÓN marcar SENTENCIAS gol
   new (TAS[Vciclo, Tgambetear]);
      TAS[Vciclo, Tgambetear]^.elem[1] := Tgambetear;
      TAS[Vciclo, Tgambetear]^.elem[2] := VCondicion;
      TAS[Vciclo, Tgambetear]^.elem[3] := Tmarcar;
      TAS[Vciclo, Tgambetear]^.elem[4] := VSentencias;
      TAS[Vciclo, Tgambetear]^.elem[5] := Tgol;

      TAS[Vciclo, Tgambetear]^.cant := 5;

   //OP -> OP -> T OP2
   new (TAS[Vop, Tid]);
      TAS[Vop, Tid]^.elem[1] := Vt;
      TAS[Vop, Tid]^.elem[2] := Vop2;

      TAS[Vop, Tid]^.cant := 2;


   //OP -> OP -> T OP2
   new (TAS[Vop, TparA]); //parentesis que abre
      TAS[Vop, TparA]^.elem[1] := Vt;
      TAS[Vop, TparA]^.elem[2] := Vop2;

      TAS[Vop, TparA]^.cant := 2;

   //OP -> OP -> T OP2
   new (TAS[Vop, Tmenos]);
      TAS[Vop, Tmenos]^.elem[1] := Vt;
      TAS[Vop, Tmenos]^.elem[2] := Vop2;

      TAS[Vop, Tmenos]^.cant := 2;

   //OP -> OP -> T OP2
   new (TAS[Vop, Tconst]);
      TAS[Vop, Tconst]^.elem[1] := Vt;
      TAS[Vop, Tconst]^.elem[2] := Vop2;

      TAS[Vop, Tconst]^.cant := 2;

   //OP -> OP -> T OP2
   new (TAS[Vop, Tarco]);
   TAS[Vop, Tarco]^.elem[1] := Vt;
   TAS[Vop, Tarco]^.elem[2] := Vop2;

   TAS[Vop, Tarco]^.cant := 2;


   //OP -> OP -> T OP2
   new (TAS[Vop, Tzurda]);
   TAS[Vop, Tzurda]^.elem[1] := Vt;
   TAS[Vop, Tzurda]^.elem[2] := Vop2;

   TAS[Vop, Tzurda]^.cant := 2;

   //OP2 -> OP2 -> epsilon
   new (TAS[Vop2, TpuntoComa]);

   TAS[Vop2, TpuntoComa]^.cant := 0;

   //OP2 -> OP2 -> epsilon
   new (TAS[Vop2, Tcoma]);

   TAS[Vop2, Tcoma]^.cant := 0;


   //OP2 -> OP2 -> epsilon
   new (TAS[Vop2, TparC]);

   TAS[Vop2, TparC]^.cant := 0;


   //OP2 -> OP2 -> epsilon
   new (TAS[Vop2, Tmarcar]);

   TAS[Vop2, Tmarcar]^.cant := 0;

   //OP -> OP -> + T OP2
   new (TAS[Vop2, Tmas]);
      TAS[Vop2, Tmas]^.elem[1] := Tmas;
      TAS[Vop2, Tmas]^.elem[2] := Vt;
      TAS[Vop2, Tmas]^.elem[3] := Vop2;

      TAS[Vop2, Tmas]^.cant := 3;


   //OP -> OP -> - T OP2
   new (TAS[Vop2, Tmenos]);
      TAS[Vop2, Tmenos]^.elem[1] := Tmenos;
      TAS[Vop2, Tmenos]^.elem[2] := Vt;
      TAS[Vop2, Tmenos]^.elem[3] := Vop2;

      TAS[Vop2, Tmenos]^.cant := 3;

   //OP2 -> OP2 -> epsilon
   new (TAS[Vop2, Tor]);

      TAS[Vop2, Tor]^.cant := 0;

   //OP2 -> OP2 -> epsilon
   new (TAS[Vop2, Tand]);

      TAS[Vop2, Tand]^.cant := 0;


   //OP2 -> OP2 -> epsilon
   new (TAS[Vop2, TllaveC]);

      TAS[Vop2, TllaveC]^.cant := 0;


   //OP2 -> OP2 -> epsilon
   new (TAS[Vop2, Tcomp]);

      TAS[Vop2, Tcomp]^.cant := 0;

   //T -> T -> F T2
   new (TAS[Vt, Tid]);
      TAS[Vt, Tid]^.elem[1] := Vf;
      TAS[Vt, Tid]^.elem[2] := Vt2;

      TAS[Vt, Tid]^.cant := 2;


   //T -> T -> F T2
   new (TAS[Vt, TparA]);
      TAS[Vt, TparA]^.elem[1] := Vf;
      TAS[Vt, TparA]^.elem[2] := Vt2;

      TAS[Vt, TparA]^.cant := 2;

   //T -> T -> F T2
   new (TAS[Vt, Tmenos]);
      TAS[Vt, Tmenos]^.elem[1] := Vf;
      TAS[Vt, Tmenos]^.elem[2] := Vt2;

      TAS[Vt, Tmenos]^.cant := 2;


   //T -> T -> F T2
   new (TAS[Vt, Tconst]);
      TAS[Vt, Tconst]^.elem[1] := Vf;
      TAS[Vt, Tconst]^.elem[2] := Vt2;

      TAS[Vt, Tconst]^.cant := 2;


   //T -> T -> F T2
   new (TAS[Vt, Tarco]);
      TAS[Vt, Tarco]^.elem[1] := Vf;
      TAS[Vt, Tarco]^.elem[2] := Vt2;

      TAS[Vt, Tarco]^.cant := 2;


   //T -> T -> F T2
   new (TAS[Vt, Tzurda]);
      TAS[Vt, Tzurda]^.elem[1] := Vf;
      TAS[Vt, Tzurda]^.elem[2] := Vt2;

      TAS[Vt, Tzurda]^.cant := 2;

  // T2
    // T2 --> epsilon <;>
    new(TAS[Vt2,TpuntoComa ]);
    TAS[Vt2,TpuntoComa]^.cant:= 0;


    // T2 --> epsilon <,>
    new(TAS[Vt2,Tcoma ]);
    TAS[Vt2,Tcoma]^.cant:= 0;

    // T2 --> epsilon <)>
    new(TAS[Vt2,TparC ]);
    TAS[Vt2,TparC]^.cant:= 0;

    // T2 --> epsilon <marcar>
    new(TAS[Vt2,Tmarcar ]);
    TAS[Vt2,Tmarcar]^.cant:= 0;

    // T2 --> epsilon <mas>
    new(TAS[Vt2,Tmas ]);
    TAS[Vt2,Tmas]^.cant:= 0;

    // T2 --> epsilon <menos>
    new(TAS[Vt2,Tmenos ]);
    TAS[Vt2,Tmenos]^.cant:= 0;

    // T2 --> * F T2 <*>
    new(TAS[Vt2,Tpor ]);
    TAS[Vt2 ,Tpor]^.elem[1]:= Tpor;
    TAS[Vt2 ,Tpor]^.elem[2]:= Vf;
    TAS[Vt2 ,Tpor]^.elem[3]:= Vt2;
    TAS[Vt2,Tpor]^.cant:= 3;

    // T2 --> / F T2 </>
    new(TAS[Vt2,Tdiv ]);
    TAS[Vt2 ,Tdiv]^.elem[1]:= Tdiv;
    TAS[Vt2 ,Tdiv]^.elem[2]:= Vf;
    TAS[Vt2 ,Tdiv]^.elem[3]:= Vt2;
    TAS[Vt2,Tdiv]^.cant:= 3;

    // T2 --> epsilon <or>
    new(TAS[Vt2,Tor ]);
    TAS[Vt2,Tor]^.cant:= 0;

    // T2 --> epsilon <and>
    new(TAS[Vt2,Tand ]);
    TAS[Vt2,Tand]^.cant:= 0;

    // T2 --> epsilon <llaveC>
    new(TAS[Vt2,TllaveC ]);
    TAS[Vt2,TllaveC]^.cant:= 0;

    // T2 --> epsilon <comp>
    new(TAS[Vt2,Tcomp ]);
    TAS[Vt2,Tcomp]^.cant:= 0;

    //P  P id
    new (TAS[Vp, Tid]);
    TAS[Vp, Tid]^.elem[1] := Vop;
    TAS[Vp, Tid]^.elem[2] := Tcomp;
    TAS[Vp, Tid]^.elem[3] := Vop;
    TAS[Vp, Tid]^.cant := 3;

    //P  P (
    new (TAS[Vp, TparA]);
    TAS[Vp, TparA]^.elem[1] := Vop;
    TAS[Vp, TparA]^.elem[2] := Tcomp;
    TAS[Vp, TparA]^.elem[3] := Vop;
    TAS[Vp, TparA]^.cant := 3;

    //P  P -
    new (TAS[Vp,Tmenos]);
    TAS[Vp,Tmenos ]^.elem[1] := Vop;
    TAS[Vp,Tmenos ]^.elem[2] := Tcomp;
    TAS[Vp,Tmenos]^.elem[3] := Vop;
    TAS[Vp,Tmenos]^.cant := 3;

    //P  P const
    new (TAS[Vp,Tconst]);
    TAS[Vp,Tconst ]^.elem[1] := Vop;
    TAS[Vp,Tconst]^.elem[2] := Tcomp;
    TAS[Vp,Tconst]^.elem[3] := Vop;
    TAS[Vp,Tconst]^.cant := 3;

    //P  P arco
    new (TAS[Vp,Tarco]);
    TAS[Vp,Tarco]^.elem[1] := Vop;
    TAS[Vp,Tarco]^.elem[2] := Tcomp;
    TAS[Vp,Tarco]^.elem[3] := Vop;
    TAS[Vp,Tarco]^.cant := 3;

    //P  P zurda
    new (TAS[Vp,Tzurda]);
    TAS[Vp,Tzurda]^.elem[1] := Vop;
    TAS[Vp,Tzurda]^.elem[2] := Tcomp;
    TAS[Vp,Tzurda]^.elem[3] := Vop;
    TAS[Vp,Tzurda]^.cant := 3;

    //P  P Not
    new (TAS[Vp,Tnot]);
    TAS[Vp,Tnot]^.elem[1] := Tnot;
    TAS[Vp,Tnot]^.elem[2] := Vp;
    TAS[Vp,Tnot]^.cant := 2;

    //P  P {
    new (TAS[Vp,TllaveA]);
    TAS[Vp,TllaveA]^.elem[1] := TllaveA;
    TAS[Vp,TllaveA]^.elem[2] := Vcondicion;
    TAS[Vp,TllaveA]^.elem[3] := TllaveC;
    TAS[Vp,TllaveA]^.cant := 3;

    //C2   C2 marcar
    new (TAS[Vc2,Tmarcar]);
    TAS[Vc2,Tmarcar]^.cant := 0;

    //C2   C2 or
    new (TAS[Vc2,Tor]);
    TAS[Vc2,Tor]^.cant := 0;

    //C2   C2 and
    new (TAS[Vc2,Tand]);
    TAS[Vc2,Tand]^.elem[1] := Tand;
    TAS[Vc2,Tand]^.elem[2] := Vp;
    TAS[Vc2,Tand]^.elem[3] := Vc2;
    TAS[Vc2,Tand]^.cant := 3;

    //C2   C2 }
    new (TAS[Vc2,TllaveC]);
    TAS[Vc2,TllaveC]^.cant := 0;

    //C    C id
    new (TAS[Vc,Tid]);
    TAS[Vc,Tid]^.elem[1] := Vp;
    TAS[Vc,Tid]^.elem[2] := Vc2;
    TAS[Vc,Tid]^.cant := 2;

    //C    C (
    new (TAS[Vc,TparA]);
    TAS[Vc,TparA]^.elem[1] := Vp;
    TAS[Vc,TparA]^.elem[2] := Vc2;
    TAS[Vc,TparA]^.cant := 2;

    //C    C -
    new (TAS[Vc,Tmenos]);
    TAS[Vc,Tmenos]^.elem[1] := Vp;
    TAS[Vc,Tmenos]^.elem[2] := Vc2;
    TAS[Vc,Tmenos]^.cant := 2;

    //C    C const
    new (TAS[Vc,Tconst]);
    TAS[Vc,Tconst]^.elem[1] := Vp;
    TAS[Vc,Tconst]^.elem[2] := Vc2;
    TAS[Vc,Tconst]^.cant := 2;

    //C    C arco
    new (TAS[Vc,Tarco]);
    TAS[Vc,Tarco]^.elem[1] := Vp;
    TAS[Vc,Tarco]^.elem[2] := Vc2;
    TAS[Vc,Tarco]^.cant := 2;

    //C    C zurda
    new (TAS[Vc,Tzurda]);
    TAS[Vc,Tzurda]^.elem[1] := Vp;
    TAS[Vc,Tzurda]^.elem[2] := Vc2;
    TAS[Vc,Tzurda]^.cant := 2;

    //C    C not
    new (TAS[Vc,Tnot]);
    TAS[Vc,Tnot]^.elem[1] := Vp;
    TAS[Vc,Tnot]^.elem[2] := Vc2;
    TAS[Vc,Tnot]^.cant := 2;

    //C    C {
    new (TAS[Vc,TllaveA]);
    TAS[Vc,TllaveA]^.elem[1] := Vp;
    TAS[Vc,TllaveA]^.elem[2] := Vc2;
    TAS[Vc,TllaveA]^.cant := 2;

    //CONDICION2   Condicion2 marcar
    new (TAS[Vcondicion2,Tmarcar]);
    TAS[Vcondicion2,Tmarcar]^.cant := 0;

    //CONDICION2   Condicion2 or
    new (TAS[Vcondicion2,Tor]);
    TAS[Vcondicion2,Tor]^.elem[1] := Tor;
    TAS[Vcondicion2,Tor]^.elem[2] := Vc;
    TAS[Vcondicion2,Tor]^.elem[3] := Vcondicion2;
    TAS[Vcondicion2,Tor]^.cant := 3;

    //CONDICION2   Condicion2 }
    new (TAS[Vcondicion2,TllaveC]);
    TAS[Vcondicion2,TllaveC]^.cant := 0;

    //CONDICION   Condicion id
    new (TAS[Vcondicion,Tid]);
    TAS[Vcondicion,Tid]^.elem[1] := Vc;
    TAS[Vcondicion,Tid]^.elem[2] := Vcondicion2;
    TAS[Vcondicion,Tid]^.cant := 2;

    //CONDICION   Condicion (
    new (TAS[Vcondicion,TparA]);
    TAS[Vcondicion,TparA]^.elem[1] := Vc;
    TAS[Vcondicion,TparA]^.elem[2] := Vcondicion2;
    TAS[Vcondicion,TparA]^.cant := 2;

    //CONDICION   Condicion -
    new (TAS[Vcondicion,Tmenos]);
    TAS[Vcondicion,Tmenos]^.elem[1] := Vc;
    TAS[Vcondicion,Tmenos]^.elem[2] := Vcondicion2;
    TAS[Vcondicion,Tmenos]^.cant := 2;

    //CONDICION   Condicion const
    new (TAS[Vcondicion,Tconst]);
    TAS[Vcondicion,Tconst]^.elem[1] := Vc;
    TAS[Vcondicion,Tconst]^.elem[2] := Vcondicion2;
    TAS[Vcondicion,Tconst]^.cant := 2;

    //CONDICION   Condicion arco
    new (TAS[Vcondicion,Tarco]);
    TAS[Vcondicion,Tarco]^.elem[1] := Vc;
    TAS[Vcondicion,Tarco]^.elem[2] := Vcondicion2;
    TAS[Vcondicion,Tarco]^.cant := 2;

    //CONDICION   Condicion zurda
    new (TAS[Vcondicion,Tzurda]);
    TAS[Vcondicion,Tzurda]^.elem[1] := Vc;
    TAS[Vcondicion,Tzurda]^.elem[2] := Vcondicion2;
    TAS[Vcondicion,Tzurda]^.cant := 2;

    //CONDICION   Condicion not
    new (TAS[Vcondicion,Tnot]);
    TAS[Vcondicion,Tnot]^.elem[1] := Vc;
    TAS[Vcondicion,Tnot]^.elem[2] := Vcondicion2;
    TAS[Vcondicion,Tnot]^.cant := 2;

    //CONDICION   Condicion {
    new (TAS[Vcondicion,TllaveA]);
    TAS[Vcondicion,TllaveA]^.elem[1] := Vc;
    TAS[Vcondicion,TllaveA]^.elem[2] := Vcondicion2;
    TAS[Vcondicion,TllaveA]^.cant := 2;

    //F   F  id
    new (TAS[Vf,Tid]);
    TAS[Vf,Tid]^.elem[1] := Tid;
    TAS[Vf,Tid]^.cant := 1;

    //F   F  (
    new (TAS[Vf,TparA]);
    TAS[Vf,TparA]^.elem[1] := TparA;
    TAS[Vf,TparA]^.elem[2] := Vop;
    TAS[Vf,TparA]^.elem[3] := TparC;
    TAS[Vf,TparA]^.cant := 3;

    //F   F  -
    new (TAS[Vf,Tmenos]);
    TAS[Vf,Tmenos]^.elem[1] := Tmenos;
    TAS[Vf,Tmenos]^.elem[2] := Vf;
    TAS[Vf,Tmenos]^.cant := 2;

    //F   F  const
    new (TAS[Vf,Tconst]);
    TAS[Vf,Tconst]^.elem[1] := Tconst;
    TAS[Vf,Tconst]^.cant := 1;

    //F   F  arco
    new (TAS[Vf,Tarco]);
    TAS[Vf,Tarco]^.elem[1] := Tarco;
    TAS[Vf,Tarco]^.elem[2] := TparA;
    TAS[Vf,Tarco]^.elem[3] := Vop;
    TAS[Vf,Tarco]^.elem[4] := Tcoma;
    TAS[Vf,Tarco]^.elem[5] := Vop;
    TAS[Vf,Tarco]^.elem[6] := TparC;
    TAS[Vf,Tarco]^.cant := 6;

    //F   F  zurda
    new (TAS[Vf,Tzurda]);
    TAS[Vf,Tzurda]^.elem[1] := Tzurda;
    TAS[Vf,Tzurda]^.elem[2] := TparA;
    TAS[Vf,Tzurda]^.elem[3] := Vop;
    TAS[Vf,Tzurda]^.elem[4] := Tcoma;
    TAS[Vf,Tzurda]^.elem[5] := Vop;
    TAS[Vf,Tzurda]^.elem[6] := TparC;
    TAS[Vf,Tzurda]^.cant := 6;

End;

Procedure AnalizadorPredictivo(VAR Fuente:t_arch;Var arbol:TApuntNodo; Var estado : t_estado);
Var
    Control:   Longint;
    TS:   TablaDeSimbolos;
    TAS:   TipoTAS;
    Pila:   t_pila;
    ElemPila:   t_elemPila;
    CompLex:   TipoSG;
    Lexema:   String;
    i :   0..MaxProd;
    Auxiliar:   TipoSG;
    Auxiliar2: TApuntNodo;
    car:char;
Begin
    InicializarTS(TS);
    CompletarTS(TS);    //Carga TS
    crearTAS(TAS);      //Carga TAS
    crearpila(Pila);    //Inicializar Pila
    CrearNodo(Vinicio, arbol);
    ElemPila.Simbolo := pesos;
    ElemPila.NodoArbol := Nil;
    Apilar(pila,ElemPila);  //Apilar pesos
    ElemPila.Simbolo := Vinicio;
    ElemPila.NodoArbol := arbol;
    Apilar(pila,ElemPila);  //Apilar Vinicio
    Control := 0;
    ObtenerSiguienteCompLex(Fuente,control,CompLex,Lexema,TS);  //Llamar al sig. componente lexico
    Estado := enProceso;
    While (Estado=enProceso) Do
        Begin
            desapilar(Pila, ElemPila);
            If ElemPila.simbolo In [Tid..TllaveC] Then  //Si el componente es terminal
                Begin
                    If ElemPila.simbolo = CompLex Then
                        Begin
                            ElemPila.NodoArbol^.lexema := lexema;
                            ObtenerSiguienteCompLex(Fuente,control,CompLex,Lexema,TS);
                        End
                    Else
                        Begin
                            Estado := errorSintactico;
                            writeln('ERROR1 Sintactico: Se esperaba ',CompLex, ' y se encontro ',ElemPila.simbolo);
                            writeln(control);
                        End;
                End;
            If ElemPila.simbolo In [Vinicio..Vp]  Then   //Si el componente es variable
                Begin
                    If TAS[ElemPila.simbolo, CompLex] = Nil Then
                        Begin
                            Estado := errorSintactico;
                            writeln('ERROR2 Sintactico: Se esperaba ',ElemPila.simbolo , ' y se encontro ', CompLex);
                            writeln(control);
                        End
                    Else
                        Begin
                            For I:=1 To TAS[ElemPila.simbolo, CompLex]^.cant Do
                                Begin
                                    Auxiliar := TAS[ElemPila.simbolo, CompLex]^.elem[i];
                                    CrearNodo(Auxiliar,Auxiliar2);
                                    AgregarHijo(ElemPila.NodoArbol,Auxiliar2);
                                End;
                            apilarTodos(TAS[ElemPila.simbolo, CompLex]^, ElemPila.NodoArbol,Pila);
                        End;
                End
            Else
                Begin

                    If (CompLex = pesos) And (ElemPila.simbolo=pesos) Then  //Se reconocio la cadena
                        Begin
                            estado := Exito;
                        End;
                End;

        End;
End;
Procedure analizadorSintactico(VAR Fuente:t_arch;Var arbol:TApuntNodo; Var estado :  t_estado);
const rutaArbol= 'Arbol.txt';
  begin
        AnalizadorPredictivo(Fuente,arbol ,estado);
        if estado = Exito then
         begin
         guardarArbol(rutaArbol,arbol);
         writeln('El lenguaje fue reconocido con exito');
         end;
       readkey;
  end;
End.

