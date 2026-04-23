unit Evaluador;

interface

uses
  crt,analizador_Lexico,analizador_sintactico,math,sysutils,archivo;
const
  MaxVar=300;
  MaxReal= 300;
  MaxArreglo=100;

  Type
    TElemEstado=record
      LexemaId: string;
      Valreal: real;
      ValArray: array[1..MaxArreglo] of real;
      CantArray: byte;
    end;
    TEstado = record
      elementos: array[1..MaxVar] of TElemEstado;
      cant:word;
      end;

{Evaluadores}
procedure eval_inicio(var arbol:TApuntNodo;var estado:TEstado);
procedure eval_sentencias(var arbol:TApuntNodo;Var estado:TEstado);
procedure eval_sentencias2(var arbol:TApuntNodo;Var estado:TEstado);
procedure eval_linea(var arbol:TApuntNodo;Var estado:TEstado);
procedure eval_variables(var arbol:TApuntNodo;Var estado:TEstado);
procedure eval_variables2(var arbol:TApuntNodo;Var estado:TEstado);
procedure eval_asignar(var arbol:TApuntNodo;Var estado:TEstado);
procedure eval_leer(var arbol:TApuntNodo;Var estado:TEstado);
procedure eval_escribir(var arbol:TApuntNodo;Var estado:TEstado);
procedure eval_l (var arbol:TApuntNodo;Var estado:TEstado);
procedure eval_l2 (var arbol:TApuntNodo;Var estado:TEstado);
procedure eval_l3 (var arbol:TApuntNodo;Var estado:TEstado);
procedure eval_condicional(var arbol:TApuntNodo;var estado:TEstado);
procedure eval_opcional_gol(var arbol:TApuntNodo;Var estado:TEstado; var valor:boolean);
procedure eval_opcional_gol2(var arbol:TApuntNodo;Var estado:TEstado; var valor:boolean);
procedure eval_ciclo(var arbol:TApuntNodo;Var estado:TEstado);
procedure eval_op(var arbol:TApuntNodo;Var estado:TEstado;var resultado:real);
procedure eval_op2(var arbol:TApuntNodo;Var estado:TEstado;var operador:real;var resultado:real);
procedure eval_t(var arbol:TApuntNodo;Var estado:TEstado;var operador3:real;var resultado2:real);
procedure eval_t2(var arbol:TApuntNodo;Var estado:TEstado;var operador3:real;var resultado2:real);
procedure eval_f(var arbol:TApuntNodo;Var estado:TEstado;var operador:real;var resultado:real);
procedure eval_condicion(var arbol:TApuntNodo;Var estado:TEstado;var valor:boolean);
procedure eval_condicion2(var arbol:TApuntNodo;Var estado:TEstado;var aux:boolean;var valor:boolean);
procedure eval_c(var arbol:TApuntNodo;Var estado:TEstado;var valor:boolean);
procedure eval_c2(var arbol:TApuntNodo;Var estado:TEstado;var aux:boolean; var valor:boolean);
procedure eval_p (var arbol:TApuntNodo;Var estado:TEstado;var valor:boolean);


Function ValorDe (Var E:TEstado;lexemaid:string):real;
procedure inicializar_estado(var estado:TEstado);
Function Convertir_en_Real(lexema:string): real;
Procedure AgregarVar(var E:TEstado; var lexemaId:string);
Procedure agregarArray(var arbol:TApuntNodo;Var E:TEstado; Var lexemaid:string;tam:byte);
procedure AsignarValor(lexemaId:string;Var E:TEstado;valor:real);
Procedure evaluador_semantico(var fuente:t_arch);
implementation

procedure inicializar_estado(var estado:TEstado);
begin
Estado.cant:=0;
end;

Function Convertir_en_Real(lexema:string):real;
var valor:real;
  codigoError:word;
begin
valor:=0;
val(lexema,valor,codigoError);
Convertir_en_Real:=valor;
end;
Function ValorDe (Var E:TEstado;lexemaid:string):real;
var i:word;
  enc:boolean;
begin
enc:=false;
    for i:=1 to E.cant do
    begin
     if upcase(E.elementos[i].LexemaId)= upcase(lexemaid) then
      begin
           ValorDe:=E.elementos[i].ValReal;
           enc:=true;
      end;
    end;
       if not(enc) then
    begin
         textcolor(red);
         writeln('No esta definida la variable: ', lexemaId);
         textcolor(white);
         halt(1);
    end;
end;

Procedure AgregarVar(var E:TEstado; var lexemaId:string);
begin
E.cant:= E.cant + 1 ;
E.elementos[E.cant].lexemaId := lexemaId;
E.elementos[E.cant].Valreal:= 0;
E.elementos[E.cant].CantArray:=0;
end;

Procedure agregarArray(var arbol:TApuntNodo;Var E:TEstado; Var lexemaid:string;tam:byte);
var i:byte;
begin
E.cant := E.cant+1;
E.elementos[E.cant].lexemaId := lexemaId;
  For i:=1 to tam do
   begin
    E.elementos[E.cant].ValArray[i] := 0;
   end;
   E.elementos[E.cant].CantArray:= tam;
end;

procedure AsignarValor(lexemaId:string;Var E:TEstado;valor:real);
var i :word;
  enc:boolean;
  begin
    enc:=false;
   for i:=1 to E.cant do
    begin
     if upcase(E.elementos[i].LexemaId)= upcase(lexemaid) then
      begin
           E.elementos[i].ValReal := valor;
           enc:=true;
    end;
  end;
   if not(enc) then
    begin
         textcolor(red);
         writeln('No esta definida la variable: ', lexemaId);
         textcolor(white);
    end;
 end;

//<INICIO> ::= "program" "id" "pase" <SENTENCIAS> "gol"
procedure eval_inicio(var arbol:TApuntNodo;Var estado:TEstado);
begin
eval_sentencias(arbol^.hijos.elem[4],estado);
end;

//<SENTENCIAS> ::= <LINEA> ";" <SENTENCIAS2>
procedure eval_sentencias(var arbol:TApuntNodo;Var estado:TEstado);
begin
  eval_linea(arbol^.hijos.elem[1],estado);
  eval_sentencias2(arbol^.hijos.elem[3],estado);
end;

//<SENTENCIAS2> ::= <LINEA> ";" <SENTENCIAS2> | ε
procedure eval_sentencias2(var arbol:TApuntNodo;Var estado:TEstado);
Begin
 if arbol^.hijos.cant<>0 then
  begin
     eval_linea(arbol^.hijos.elem[1],estado);
     eval_sentencias2(arbol^.hijos.elem[3],estado);
  end;
end;

// <LINEA> ::= "var" <VARIABLES> | <ASIGNAR> | <LEER> | <ESCRIBIR> | <CONDICIONAL> | <CICLO>
procedure eval_linea(var arbol:TApuntNodo;Var estado:TEstado);
begin
      case  arbol^.hijos.elem[1]^.simbolo  of
	Tvar: eval_variables(arbol^.hijos.elem[2],estado);
	Vasignar: eval_asignar(arbol^.hijos.elem[1],estado);
	Vleer: eval_leer(arbol^.hijos.elem[1],estado);
	Vescribir: eval_escribir(arbol^.hijos.elem[1],estado);
	Vcondicional: eval_condicional(arbol^.hijos.elem[1],estado);
	Vciclo: eval_ciclo(arbol^.hijos.elem[1],estado);
      end;
end;

// <VARIABLES> ::= "id" <VARIABLES2>
procedure eval_variables(var arbol:TApuntNodo;Var estado:TEstado);
begin
        AgregarVar(estado,arbol^.hijos.elem[1]^.lexema);
	eval_variables2(arbol^.hijos.elem[2],estado);
end;

// <VARIABLES2> ::= "," <VARIABLES> | ε
procedure eval_variables2(var arbol:TApuntNodo;Var estado:TEstado);
begin
	if arbol^.hijos.cant <> 0 then
	begin
	     eval_variables(arbol^.hijos.elem[2],estado);
	end;
end;

//ASIGNAR::=  "id" ":=" <OP>
procedure eval_asignar(var arbol:TApuntNodo;Var estado:TEstado);
var resultado:real;
Begin
 eval_op(arbol^.hijos.elem[3],estado,resultado);
 AsignarValor(arbol^.hijos.elem[1]^.lexema,estado,resultado);
 resultado:=ValorDe(estado,arbol^.hijos.elem[1]^.lexema);
end;

//LEER::= "lio" "(" "cadena" "," "id" ")"
procedure eval_leer(var arbol:TApuntNodo;Var estado:TEstado);
var valor_escribir:real;
  indice:byte;
begin
 indice:=0;
 valor_escribir:=0;
 writeln(arbol^.hijos.elem[3]^.lexema);
 readln(valor_escribir);
 AsignarValor(arbol^.hijos.elem[5]^.lexema,estado,valor_escribir);
 end;

//ESCRIBIR::= "definir" "(" <L> ")"
procedure eval_escribir(var arbol:TApuntNodo;Var estado:TEstado);
begin
eval_l(arbol^.hijos.elem[3],estado);
end;

//L::= "cadena" <L2>  |  <OP> <L2>
procedure eval_l (var arbol:TApuntNodo;Var estado:TEstado);
var resultado: real;
begin
resultado:=0;
 case arbol^.hijos.elem[1]^.simbolo of
   Tcadena:begin
             writeln(arbol^.hijos.elem[1]^.lexema);
             eval_l2(arbol^.hijos.elem[2],estado);
           end;
     Vop:begin
            eval_op(arbol^.hijos.elem[1],estado,resultado);
            writeln(resultado:9:4);
            eval_l2(arbol^.hijos.elem[2],estado);
         end;
 end;
end;

// L2::= "," <L3> <L2>  |    epsilon
procedure eval_l2 (var arbol:TApuntNodo;Var estado:TEstado);
begin
 if arbol^.hijos.cant <> 0 then
  begin
   eval_l3(arbol^.hijos.elem[2],estado);
   eval_l2(arbol^.hijos.elem[3],estado);
  end;
end;

//L3::= "cadena"  |  <OP>
procedure eval_l3(var arbol:TApuntNodo;Var estado:TEstado);
var resultado:real;
begin
resultado:=0;
      case  arbol^.hijos.elem[1]^.simbolo  of
           Tcadena:begin
                     write(arbol^.hijos.elem[1]^.lexema);
                    end;
           Vop:begin
                    eval_op(arbol^.hijos.elem[1],estado,resultado);
                    writeln(resultado:9:4);
               end;
      end;
end;

// <condicional> → asistir CONDICION marcar SENTENCIAS opcional_gol
procedure eval_condicional(var arbol:TApuntNodo;Var estado:TEstado);
var valor:boolean;
begin
eval_condicion(arbol^.hijos.elem[2],estado,valor);
 if valor=true then
  begin
   eval_sentencias(arbol^.hijos.elem[4],estado);
  end;
eval_opcional_gol(arbol^.hijos.elem[4],estado, valor);

end;


// opcional_gol-> gol opcional_gol2  |   epsilon
procedure eval_opcional_gol(var arbol:TApuntNodo;Var estado:TEstado; var valor:boolean);
begin
 if arbol^.hijos.cant <> 0 then
Begin
     eval_opcional_gol2(arbol^.hijos.elem[2],estado, valor);
  end;
end;

// opcional_gol2-> contra SENTENCIAS gol2  |   epsilon

procedure eval_opcional_gol2(var arbol:TApuntNodo;Var estado:TEstado; var valor:boolean);
begin
 if arbol^.hijos.cant <> 0 then
Begin
  if valor=false then
   begin
    eval_sentencias(arbol^.hijos.elem[4],estado);
   end;
 eval_opcional_gol2(arbol^.hijos.elem[4],estado, valor);
end;
end;

// ciclo -> gambetear CONDICION marcar SENTENCIAS gol

procedure eval_ciclo(var arbol:TApuntNodo;Var estado:TEstado);
var resultado1,resultado2:real;
i,res1,res2:longint;
valor:boolean;
begin
 eval_condicion(arbol^.hijos.elem[2],estado,valor);
     while valor do
       begin
          eval_sentencias(arbol^.hijos.elem[4],estado);
          eval_condicion(arbol^.hijos.elem[2],estado,valor);
       end;
end;
//OP::= <T> <OP2>
procedure eval_op(var arbol:TApuntNodo; Var estado:TEstado; var resultado:real);
var operador:real;
begin
  eval_t(arbol^.hijos.elem[1], estado, operador, resultado);
  resultado := operador;
  eval_op2(arbol^.hijos.elem[2], estado, operador, resultado);
end;

//OP2::= "+" <T>  <OP2>  |   "-" <T> <OP2>   |   epsilon
procedure eval_op2(var arbol:TApuntNodo; Var estado:TEstado; var operador:real; var resultado:real);
var operador2:real;
begin
  if arbol^.hijos.cant <> 0 then
  begin
    case arbol^.hijos.elem[1]^.simbolo of
      Tmas:
        begin
          eval_t(arbol^.hijos.elem[2], estado, operador2, resultado);
          operador := operador + operador2;
          resultado := operador;
          eval_op2(arbol^.hijos.elem[3], estado, operador, resultado);
        end;
      Tmenos:
        begin
          eval_t(arbol^.hijos.elem[2], estado, operador2, resultado);
          operador := operador - operador2;
          resultado := operador;
          eval_op2(arbol^.hijos.elem[3], estado, operador, resultado);
        end;
    end;
  end;
end;

//T::=  <F> <T2>
procedure eval_t(var arbol:TApuntNodo; Var estado:TEstado; var operador3:real; var resultado2:real);
begin
  eval_f(arbol^.hijos.elem[1], estado, operador3, resultado2);
  resultado2 := operador3;
  eval_t2(arbol^.hijos.elem[2], estado, operador3, resultado2);
end;

//T2::=  "*" <F> <T2>  |    "/" <F> <T2>    | epsilon
procedure eval_t2(var arbol:TApuntNodo; Var estado:TEstado; var operador3:real; var resultado2:real);
var operador4:real;
begin
  if arbol^.hijos.cant <> 0 then
  begin
    case arbol^.hijos.elem[1]^.simbolo of
      Tpor:
        begin
          eval_f(arbol^.hijos.elem[2], estado, operador4, resultado2);
          operador3 := operador3 * operador4;
          resultado2 := operador3;
          eval_t2(arbol^.hijos.elem[3], estado, operador3, resultado2);
        end;
      Tdiv:
        begin
          eval_f(arbol^.hijos.elem[2], estado, operador4, resultado2);
          if operador4 <> 0 then
          begin

            operador3 := operador3 / operador4;
            resultado2 := operador3;
            eval_t2(arbol^.hijos.elem[3], estado, operador3, resultado2);
          end
          else
          begin
            textcolor(red);
            writeln('Imposible dividir por cero');
          end;
        end;
    end;
  end;
end;

//F::= "const" |  "id"  | "(" <OP> ")" |  "arco" "(" <OP> "," <OP> ")" |  "zurda" "(" <OP> "," <OP> ")"  |  "-" <F>
procedure eval_f(var arbol:TApuntNodo; Var estado:TEstado; var operador:real; var resultado:real);
var base, exponente, indice, operador2, valor:real;
    codigoError:word;
begin
  case arbol^.hijos.elem[1]^.simbolo of
    Tconst:
      begin
        val(arbol^.hijos.elem[1]^.lexema, resultado, codigoError);
        operador := resultado;
      end;
    Tid:
      begin
        resultado := ValorDe(estado, arbol^.hijos.elem[1]^.lexema);
        operador := resultado;
      end;
    TparA:
      begin
        eval_op(arbol^.hijos.elem[2], estado, resultado);
        operador := resultado;
      end;
    Tarco:
      begin
        eval_op(arbol^.hijos.elem[3], estado, operador);
        eval_op(arbol^.hijos.elem[5], estado, operador2);
        base := operador;
        exponente := operador2;
        resultado := power(base, exponente);
        operador := resultado;
      end;
    Tzurda:
      begin
        eval_op(arbol^.hijos.elem[3], estado, operador);
        eval_op(arbol^.hijos.elem[5], estado, operador2);
        base := operador;
        indice := operador2;
        resultado := power(base, 1 / indice);
        operador := resultado;
      end;
    Tmenos:
      begin
        eval_f(arbol^.hijos.elem[2], estado, operador, resultado);
        resultado := resultado * (-1);
        operador := resultado;
      end;
  end;
end;



//CONDICION → C CONDICION2
procedure eval_condicion(var arbol:TApuntNodo;Var estado:TEstado;var valor:boolean);
var aux:boolean;
begin
 eval_c(arbol^.hijos.elem[1],estado, aux);
 eval_condicion2(arbol^.hijos.elem[2],estado,aux, valor);
end;

//CONDICION2 → or C CONDICION2 | epsilon
procedure eval_condicion2(var arbol:TApuntNodo;Var estado:TEstado;var aux:boolean;var valor:boolean);
var valor2:boolean;
begin
 if  arbol^.Hijos.cant <>0 then
   begin
    eval_c(arbol^.hijos.elem[2],estado,valor2);
    aux:= aux or valor2;
    eval_condicion2(arbol^.hijos.elem[3],estado,aux,valor);
   end
 else
  begin
    valor:=aux;
  end;
end;

//C →  P C2
procedure eval_c(var arbol:TApuntNodo;Var estado:TEstado;var valor:boolean);
var aux:boolean;
begin
eval_p(arbol^.hijos.elem[1],estado, valor);
eval_c2(arbol^.hijos.elem[2],estado, aux, valor);
end;

//C2> →  P C2 | and P C2 | epsilon
procedure eval_c2(var arbol:TApuntNodo;Var estado:TEstado;var aux:boolean; var valor:boolean);
var valor2:boolean;
begin
 if arbol^.hijos.cant <> 0 then
begin
  case arbol^.hijos.elem[1]^.simbolo of
   Vp:
               begin
               eval_p(arbol^.hijos.elem[1],estado, valor);
               eval_c2(arbol^.hijos.elem[2],estado,aux, valor);
               end;

   Tand:
              begin
              eval_p(arbol^.hijos.elem[2],estado,valor2);
              aux:= aux and valor2;
              eval_c2(arbol^.hijos.elem[3],estado,aux,valor);
              end;
 end;
end;
end;

///P → OP comp OP| not P | {CONDICION}
 procedure eval_p (var arbol:TApuntNodo;Var estado:TEstado;var valor:boolean);
 var resultado1,resultado2:real;
 begin
    case arbol^.hijos.elem[1]^.simbolo of
    Vop:begin
            eval_op(arbol^.hijos.elem[1],estado,resultado1);
            eval_op(arbol^.hijos.elem[3],estado,resultado2);
           case arbol^.hijos.elem[2]^.lexema  of
            '>': valor:=(resultado1 >  resultado2) ;
            '<': valor:=resultado1 <  resultado2  ;
            '=': valor:=resultado1 =  resultado2  ;
           '>=': valor:=resultado1 >= resultado2  ;
           '<=': valor:=resultado1 <= resultado2  ;
           '<>': valor:= resultado1 <> resultado2  ;
            end;
        end;
    Tnot:begin
           eval_p(arbol^.hijos.elem[2],estado,valor);
           valor:= not valor;
          end;
    TllaveA:  begin
               eval_condicion(arbol^.hijos.elem[2],estado,valor);
               end;
  end;
 end;
{LLamada al Evaluador semantico}
Procedure evaluador_semantico(var fuente:t_arch);
const rutaarbol= 'Arbol.txt';
var
Arbol:TApuntNodo;
estado:t_estado;
e_stado:TEstado;
  begin
        AnalizadorPredictivo(fuente,Arbol,estado);
        if estado = Exito then
         begin
         guardarArbol(rutaarbol,arbol);
         inicializar_estado(e_stado);
         eval_inicio(arbol,e_stado);
         end;
        readln;
  end;

end.



