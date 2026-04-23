unit menu;
     {$CODEPAGE UTF8}

interface

uses
  crt,analizador_lexico, archivo, analizador_sintactico, evaluador;
procedure menu_opciones ;
VAR
fuente:t_arch;
Promedio_Varianza:t_arch;
Sumatoria:t_arch;
Fibonacci:t_arch;
Complex:TipoSG;
control:longint;
Lexema:string;
TS:TabladeSimbolos;
estado:t_estado;
Arbol:TApuntNodo;

implementation
PROCEDURE menu_opciones;
  var
            op:0..1;
            TAS: TipoTAS;
            archivo:t_arch;
          BEGIN
           repeat
               TEXTBACKGROUND(black);
               CLRSCR;
               GOTOXY(49,2);
               TEXTCOLOR(0);
              WRITELN('');
               GOTOXY(52,4);
               TEXTCOLOR(3);
               WRITELN('MENÚ PRINCIPAL');
               GOTOXY(30,7);
               TEXTCOLOR(15);
               WRITELN('0. Salir del programa');
               GOTOXY(30,9);
               WRITELN('1. Evaluador');
               GOTOXY(30,11);
               WRITELN('2. Mostrar analizador lexico');
               GOTOXY(30,13);
               WRITELN('3. Analizador Sintactico');
               readln(op);
               clrscr;
              case op of
              1:begin
                abrir_archivo (Fuente);
                evaluador_semantico(Fuente);
                close(Fuente);
                 end;
              2:begin
                 MostrarAnalizadorLexico(Fuente);
                end;
              3:begin
                abrir_archivo (Fuente);
                analizadorSintactico(Fuente,Arbol,estado);
                Close(Fuente);
                end;
              end;

           until op=0 ;
          END;
end.

