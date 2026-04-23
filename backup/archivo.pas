unit archivo;

{$mode objfpc}{$H+}

interface
uses
  crt,Sysutils;
const
  finarch=#0;
  ruta='Fuente.txt';

type
  t_arch=file of char;

procedure abrir_archivo(var archivo:t_arch);
procedure leerCaracter(var archivo:t_arch; var pos:integer;var caracter:char);

implementation

procedure abrir_archivo(var archivo:t_arch);
     begin
       Assign(archivo,ruta);
       if not FileExists(ruta) then
       begin
           Rewrite(archivo);
           Close(archivo);
       end;
       writeln('hola mundo');
       reset(archivo);
     end;
procedure leerCaracter(var archivo:t_arch; var pos:integer;var caracter:char);
   begin
     if pos<filesize(archivo) then
       begin
         seek(archivo,pos);
         read(archivo,caracter);
       end
     else caracter:=finarch;
   end;
end.
