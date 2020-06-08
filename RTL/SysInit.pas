(*
    Minimal Delphi SysInit unit
*)

unit SysInit;

interface

procedure _InitExe(InitTable: Pointer);
procedure _Halt0;
procedure _InitLib(Context: PInitContext);

var
  ModuleIsLib: Boolean;
  TLSIndex: Integer = -1;
  TLSLast: Byte;

const
  PtrToNil: Pointer = nil;

implementation

procedure _InitLib(context: pinitcontext);
asm
end;

procedure _InitExe(InitTable: Pointer);
begin
  _StartExe(InitTable);
end;

procedure _Halt0;
asm
end;

end.
