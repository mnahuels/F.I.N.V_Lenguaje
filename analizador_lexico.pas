Unit analizador_Lexico;
    {$codepage utf8}
Interface

Uses crt, Classes, SysUtils, archivo;

Const
    MaxSim =   200;

Type
    TipoSG = (Tid, Tprogram, Tgol, Tpase, Tgambetear, Tmarcar, Tvar, Tzurda, Tasistir, Tcontra, Tarco, Tconst, Tcadena, Tlio, Tdefinir, Tor, Tand, Tnot, Tcomp, TdosPuntos, TdosPuntosIgual,
          TparA, TparC, TpuntoComa, Tcoma, Tmas, Tmenos, Tpor, Tdiv, TllaveA, TllaveC, pesos, ErrorLexico, Vinicio, Vsentencias, Vsentencias2, Vlinea, Vvariables, Vvariables2, Vasignar, Vleer, Vescribir,
          Vl, Vl2, Vcondicional, Vciclo,Vl3,Vopgol,Vopgol2, Vop, Vop2, Vt, Vt2, Vf, Vcondicion, Vcondicion2, Vc, Vc2, Vp);

    TElemTS =   Record
        compLex:   TipoSG;
        Lexema:   string;
    End;
    TablaDeSimbolos =   Record
        elem:   array[1..MaxSim] Of TElemTS;
        cant:   0..maxsim;
    End;

Procedure InicializarTS(Var TS:TablaDeSimbolos);
Procedure CompletarTS(Var TS:TablaDeSimbolos);
Procedure LeerCar(Var Fuente:t_arch;Var control:Longint; Var car:char);
Function EsIdentificador(Var Fuente:t_arch;Var control:Longint;Var Lexema:String): Boolean;
Function EsConstanteReal(Var Fuente:t_arch;Var control:Longint;Var Lexema:String): Boolean;
Function EsCadena(Var Fuente:t_arch;Var control:Longint;Var Lexema:String):Boolean;
Procedure ObtenerSiguienteCompLex(Var Fuente:t_arch;Var Control:Longint; Var CompLex:TipoSG;Var Lexema:String;Var TS:TablaDeSimbolos);
Procedure MostrarAnalizadorLexico(var Fuente:t_arch);

Implementation

Procedure InstalarEnTS(lexema:String; Var TS:TablaDeSimbolos; Var CompLex:TipoSG);
Var
    encontrado:   boolean;
    i:   byte;
Begin
    encontrado := False;
    For i:=1 To TS.cant Do
        Begin
            If upCase(lexema) = upCase(TS.elem[i].lexema) Then
                Begin
                    CompLex := TS.elem[i].compLex;
                    encontrado := True;
                End;
        End;
    If Not encontrado Then
        Begin
            inc(TS.cant);
            TS.elem[TS.cant].lexema := lexema;
            TS.elem[TS.cant].CompLex := Tid;
            CompLex := Tid;
        End;
End;

Procedure LeerCar(Var Fuente:t_arch; Var control:Longint; Var car:char);
Begin
    If control < filesize(Fuente) Then
        Begin
            seek(FUENTE,control);
            read(fuente,car);
        End
    Else
        Begin
            car := finarch;
        End;
End;

 Procedure InicializarTS(Var TS:TablaDeSimbolos);
 Begin
     TS.cant := 0;
 End;
 Procedure CompletarTS(Var TS:TablaDeSimbolos);
 Begin
     Inc(TS.cant);
     TS.elem[TS.cant].lexema := 'program';
     TS.elem[TS.cant].compLex := Tprogram;
     Inc(TS.cant);
     TS.elem[TS.cant].lexema := 'pase';
     TS.elem[TS.cant].compLex := Tpase;
     Inc(TS.cant);
     TS.elem[TS.cant].lexema := 'gol';
     TS.elem[TS.cant].compLex := Tgol;
     Inc(TS.cant);
     TS.elem[TS.cant].lexema := 'var';
     TS.elem[TS.cant].compLex := Tvar;
     Inc(TS.cant);
     TS.elem[TS.cant].lexema := 'asistir';
     TS.elem[TS.cant].compLex := Tasistir;
     Inc(TS.cant);
     TS.elem[TS.cant].lexema := 'marcar';
     TS.elem[TS.cant].compLex := Tmarcar;
     Inc(TS.cant);
     TS.elem[TS.cant].lexema := 'contra';
     TS.elem[TS.cant].compLex := Tcontra;
     Inc(TS.cant);
     TS.elem[TS.cant].lexema := 'gambetear';
     TS.elem[TS.cant].compLex := Tgambetear;
     Inc(TS.cant);
     TS.elem[TS.cant].lexema := 'const';
     TS.elem[TS.cant].compLex := Tconst;
     Inc(TS.cant);
     TS.elem[TS.cant].lexema := 'arco';
     TS.elem[TS.cant].compLex := Tarco;
     Inc(TS.cant);
     TS.elem[TS.cant].lexema := 'zurda';
     TS.elem[TS.cant].compLex := Tzurda;
     Inc(TS.cant);
     TS.elem[TS.cant].lexema := 'or';
     TS.elem[TS.cant].compLex := Tor;
     Inc(TS.cant);
     TS.elem[TS.cant].lexema := 'and';
     TS.elem[TS.cant].compLex := Tand;
     Inc(TS.cant);
     TS.elem[TS.cant].lexema := 'not';
     TS.elem[TS.cant].compLex := Tnot;
     Inc(TS.cant);
     TS.elem[TS.cant].lexema := 'definir';
     TS.elem[TS.cant].compLex := Tdefinir;
     Inc(TS.cant);
     TS.elem[TS.cant].lexema := 'lio';
     TS.elem[TS.cant].compLex := Tlio;
     Inc(TS.cant);
 End;

Function EsIdentificador(Var Fuente:t_arch;Var control:Longint;Var Lexema:String):   Boolean;
Const
    q0 =   0;
    F =   [3];

Type
    Q =   0..3;
    Sigma =   (L,D,GB,o);
    TipoDelta =   array[Q,Sigma] Of Q;

Var
    E_actual:   Q;
    car:   char;
    delta:   TipoDelta;
    ContLocal:   Longint;
Function CarASimb(Car:Char):   Sigma;
Begin
    Case Car Of
    'a'..'z', 'A'..'Z':   CarASimb := L;
    '0'..'9'      :   CarASimb := D;
    '_'      :   CarASimb := GB;
    Else
        CarASimb := o;
    End;
End;
Begin
    Lexema := '';
    ContLocal := Control;
    Delta[0,L] := 1;
    Delta[0,D] := 2;
    Delta[0,GB] := 2;
    Delta[0,o] := 2;
    Delta[1,L] := 1;
    Delta[1,GB] := 1;
    Delta[1,D] := 1;
    Delta[1,o] := 3;
    E_actual := q0;
    While (E_actual<>3) And (E_actual<>2) Do
    Begin
        LeerCar(Fuente,ContLocal,car);
        E_actual := delta[E_actual,CarASimb(car)];
        INC(ContLocal);
        If E_actual = 1 Then
        lexema := lexema+car;
    End;
    If E_actual In F Then
    Begin
        EsIdentificador := true;
        Control := (ContLocal-1);
    End
    Else
    EsIdentificador := false;
End;

Function EsConstanteReal(Var Fuente:t_arch;Var control:Longint;Var Lexema:String): Boolean;
Const
    q0 =   0;
    F =   [4];

Type
    Q =   0..5;
    Sigma =   (D,o,P);
    TipoDelta =   array[Q,Sigma] Of Q;

Var
    E_actual:   Q;
    car:   char;
    delta:   TipoDelta;
    ContLocal:   Longint;
Function CarASimb(Car:Char):   Sigma;
Begin
    Case Car Of
    '0'..'9':   CarASimb := D;
    '.':   CarASimb := P;
    Else
        CarASimb := o;
    End;
End;
Begin
    Lexema := '';
    ContLocal := Control;
    Delta[0,D] := 1;
    Delta[0,o] := 5;
    Delta[0,P] := 5;
    Delta[1,D] := 1;
    Delta[1,o] := 4;
    Delta[1,P] := 2;
    Delta[2,D] := 3;
    Delta[2,o] := 5;
    Delta[2,P] := 5;
    Delta[3,D] := 3;
    Delta[3,o] := 4;
    Delta[3,P] := 5;
    E_actual := q0;
    While (E_actual<>5) And (E_actual<>4) Do
    Begin
        LeerCar(Fuente,ContLocal,car);
        E_actual := delta[E_actual,CarASimb(car)];
        INC(ContLocal);
        If (E_actual in [0,1,2,3]) Then
        lexema := lexema+car;
    End;
    If E_actual In F Then
    Begin
        EsConstanteReal := true;
        Control := (ContLocal-1);
    End
    Else
    EsConstanteReal := false;
End;

Function EsCadena(Var Fuente:t_arch;Var control:Longint;Var Lexema:String):Boolean;
Const
    q0 =   0;
    F =   [4];

Type
    Q =   0..4;
    Sigma =   (C,o,par,coma);
    TipoDelta =   array[Q,Sigma] Of Q;

Var
    E_actual:   Q;
    car:   char;
    delta:   TipoDelta;
    ContLocal:   Longint;
Function CarASimb(Car:Char):   Sigma;
Begin
    Case Car Of
    '"' : CarAsimb := C;
    ')' : CarAsimb := par;
    ',' : CarAsimb := coma;
    Else
        CarASimb := o;
    End;
End;
Begin
    Lexema := '';
    ContLocal := Control;
    Delta[0,C] := 1;
    Delta[0,o] := 2;
    Delta[1,o] := 1;
    Delta[1,C] := 3;
    Delta[3,C] := 2;
    Delta[3,o] := 2;
    Delta[3,par] := 4;
    Delta[3,coma] := 4;
    E_actual := q0;
    While (E_actual<>4) And (E_actual<>2) Do
    Begin
        LeerCar(Fuente,ContLocal,car);
        E_actual := delta[E_actual,CarASimb(car)];
        INC(ContLocal);
        If (E_actual in [0,1,3])and (car<>'"') Then
        lexema := lexema+car;
    End;
    EsCadena := false;
    If E_actual In F Then
    Begin
        EsCadena := true;
        Control := (ContLocal-1);
    End
End;

Function EsSimboloEspecial(Var Fuente:t_arch;Var control:Longint;Var Lexema:String;Var CompLex:TipoSG):   Boolean;
Var
    car:   char;
Begin
    LeerCar(Fuente,control,car);
    lexema := car;
    INC(control);
    EsSimboloEspecial := true;
    Case car Of
         ':': begin
                   LeerCar(Fuente,control,car);
                    If car = '=' Then
                           Begin
                               Complex:=TdosPuntosIgual;
                               lexema := ':=';
                               Inc(control);
                           End
                             else Complex:=ErrorLexico;
             end;
        ';':   CompLex := TpuntoComa;
        ',':   CompLex := Tcoma;
        '(':   CompLex := TparA;
        ')':   CompLex := TparC;

        '=': Begin
                   CompLex := Tcomp;
                   lexema := '=';
               End;
        '+':   CompLex := Tmas;
        '-':   CompLex := Tmenos;
        '*':   CompLex := Tpor;
        '/':   CompLex := Tdiv;
        '<':    Begin
                   CompLex :=  Tcomp;
                   LeerCar(Fuente,control,car);
                   If car = '=' Then
                       Begin
                           lexema := '<=';
                           Inc(control);
                       End
                   Else
                       If car = '>' Then
                           Begin
                               lexema := '<>';
                               Inc(control);
                           End
                           else lexema := '<';
               End;
        '>': Begin
                   CompLex :=  Tcomp;
                   LeerCar(Fuente,control,car);
                   If car = '=' Then
                       Begin
                           lexema := '>=';
                           Inc(control);
                       End
                       else lexema := '>';
               End;
        Else
            DEC(control);
        EsSimboloEspecial := false
    End;

End;

Procedure ObtenerSiguienteCompLex(Var Fuente:t_arch;Var Control:Longint; Var CompLex:TipoSG;Var Lexema:String;Var TS:TablaDeSimbolos);
Var
    car:   char;
Begin
    LeerCar(Fuente,control,car);
    While car In [#1 .. #32 ] Do
        Begin
            INC(control);
            LeerCar(Fuente,control,car);
        End;
    If car=finarch Then
        complex := pesos
    Else
        Begin
            If EsIdentificador(Fuente,Control,Lexema) Then
                InstalarEnTS(Lexema,TS,CompLex)
            Else If EsConstanteReal(Fuente,Control,Lexema) Then
                     CompLex := Tconst
            Else If EsCadena(Fuente,Control,Lexema) Then
                     CompLex := Tcadena
            Else if not EsSimboloEspecial(Fuente, control,  Lexema, CompLex) then
                CompLex := ErrorLexico ;
        End;
End;
Procedure MostrarAnalizadorLexico(var Fuente:t_arch);
   var
      Control:Longint;
      CompLex: TipoSG ;
      Lexema:String;
      TS:TablaDeSimbolos;
      Contador:byte;

   begin
    abrir_archivo(fuente);
    Control:=0;
    CompletarTS(TS);
    ObtenerSiguienteCompLex(Fuente,Control,CompLex,Lexema,TS);
    While (CompLex <> pesos) xor (CompLex = ErrorLexico) do
   begin
       textcolor(white);
     write(Lexema);
     textcolor(green);
     writeln(' su compononente lexico es ',CompLex);
     ObtenerSiguienteCompLex(Fuente,Control,CompLex,Lexema,TS);
     readln;
     end;
    if Complex = pesos then
    begin
        textcolor(white);
       writeln(CompLex) ;
    end
    else
    begin
    textcolor(red);
      writeln('Error Lexico') ;
      end;
     readln;
     close(fuente);
   end;
End.

