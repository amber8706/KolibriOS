(*
    Minimal Delphi System unit
*)

unit System;

interface

type
  PPAnsiChar = ^PAnsiChar;
  PInteger = ^Integer;

  THandle = LongWord;

  TGUID = record
    D1: LongWord;
    D2: Word;
    D3: Word;
    D4: array [0..7] of Byte;
  end;

  PackageUnitEntry = packed record
    Init, FInit : Pointer;
  end;

  { Compiler generated table to be processed sequentially to init & finit all package units }
  { Init: 0..Max-1; Final: Last Initialized..0                                              }
  UnitEntryTable = array [0..9999999] of PackageUnitEntry;
  PUnitEntryTable = ^UnitEntryTable;

  PackageInfoTable = packed record
    UnitCount : LongInt;      { number of entries in UnitInfo array; always > 0 }
    UnitInfo : PUnitEntryTable;
  end;

  PackageInfo = ^PackageInfoTable;

  PInitContext = ^TInitContext;
  TInitContext = record
    OuterContext:   PInitContext;
    ExcFrame:       Pointer;
    InitTable:      PackageInfo;
    InitCount:      Integer;
    Module:         Pointer;
    DLLSaveEBP:     Pointer;
    DLLSaveEBX:     Pointer;
    DLLSaveESI:     Pointer;
    DLLSaveEDI:     Pointer;
    ExitProcessTLS: procedure;
    DLLInitState:   Byte;
  end;

var
  IsConsole: Boolean;       { True if compiled as console app }

procedure _Halt0;
procedure _HandleFinally;
procedure _StartExe(InitTable: PackageInfo);

implementation

uses
  SysInit;

type
  TProc = procedure;

var
  InitContext: TInitContext;

procedure InitUnits;
var
  i: LongInt;
  P: Pointer;
begin
  if InitContext.InitTable <> nil then
  begin
    with InitContext.InitTable^ do
    begin
      i := 0;
      while i < UnitCount do
      begin
        P := UnitInfo^[i].Init;
        Inc(i);
        InitContext.InitCount := i;
        if P <> nil then
          TProc(P)();
      end;
    end;
  end;
end;

procedure FinalizeUnits;
var
  P: Pointer;
begin
  if InitContext.InitTable <> nil then
  begin
    with InitContext do
    begin
      while InitCount > 0 do
      begin
        Dec(InitCount);
        P := InitTable^.UnitInfo^[InitCount].FInit;
        if P <> nil then
          TProc(P)();
      end;
    end;
  end;
end;

procedure _StartExe(InitTable: PackageInfo);
begin
  InitContext.InitTable := InitTable;
  InitContext.InitCount := 0;
  InitUnits;
end;

procedure _Halt0;
begin
  FinalizeUnits;
  asm
          OR  EAX, -1
          INT $40
  end;
end;

procedure _HandleFinally;
asm
end;

end.
