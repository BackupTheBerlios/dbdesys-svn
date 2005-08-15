unit EERExportSQLScript;

//----------------------------------------------------------------------------------------------------------------------
//
// This file is part of Human Profile DBDeSys.
// Copyright (C) 2005 Filippo Toso, www.humanprofile.biz
// Copyright (C) 2002 Michael G. Zinner, www.fabFORCE.net
//
// DBDeSys is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// DBDeSys is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with DBDeSys; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//
//----------------------------------------------------------------------------------------------------------------------
//
// Unit EERExportSQLCreateScript.pas
// ---------------------------------
// Version 1.1, 08.04.2003, Mike
// Description
//   Contains the SQL Script Export form class
//
// Changes:
//   Version 1.1, 08.04.2003, Mike
//     added LoadSettings / SaveSettings proc.
//   Version 1.0, 13.03.2003, Mike
//     initial version
//
//----------------------------------------------------------------------------------------------------------------------

interface

uses
  SysUtils, Types, Classes, QGraphics, QControls, QForms, QDialogs,
  QStdCtrls, QButtons, EERModel, QClipbrd, QExtCtrls, QComCtrls,
  IniFiles, QCheckLst;

type
  TEERExportSQLScriptFrom = class(TForm)
    Settings: TGroupBox;
    PhysicalCBox: TCheckBox;
    StatusBar: TStatusBar;
    ExportSelTablesCBox: TCheckBox;
    SQLCreatesSettingGBox: TGroupBox;
    PKCBox: TCheckBox;
    FKCBox: TCheckBox;
    StdInsertsCBox: TCheckBox;
    IndicesCBox: TCheckBox;
    Panel1: TPanel;
    CopyBtn: TSpeedButton;
    ExportBtn: TSpeedButton;
    TblOptionsCBox: TCheckBox;
    CommentsCBox: TCheckBox;
    RegionsListBox: TCheckListBox;
    CloseBtn: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SetModel(theEERModel: TEERModel; mode: integer = 0);
    function GetSQLScript: string;
    procedure ExportBtnClick(Sender: TObject);
    procedure CopyBtnClick(Sender: TObject);
    procedure FKCBoxClick(Sender: TObject);

    procedure LoadSettingsFromIniFile;
    procedure SaveSettingsToIniFile;
    procedure RegionsListBoxClickCheck(Sender: TObject);
    procedure RegionsListBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CloseBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    EERModel: TEERModel;
    ScriptMode: integer;
    theRegions: TList;
  end;

var
  EERExportSQLScriptFrom: TEERExportSQLScriptFrom;

implementation

uses MainDM, EERDM, GUIDM;

{$R *.xfm}

procedure TEERExportSQLScriptFrom.FormCreate(Sender: TObject);
begin
  DMMain.InitForm(self);

  theRegions := TList.Create;

  LoadSettingsFromIniFile;
end;

procedure TEERExportSQLScriptFrom.FormDestroy(Sender: TObject);
begin
  SaveSettingsToIniFile;

  theRegions.Free;
end;

procedure TEERExportSQLScriptFrom.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  //
end;

procedure TEERExportSQLScriptFrom.SetModel(theEERModel: TEERModel; mode: integer);
var i: integer;
begin
  EERModel := theEERModel;
  ScriptMode := mode;

  // mode=0 ... creates
  // mode=1 ... drops
  // mode=2 ... optimize
  if (mode <> 0) then
  begin
    SQLCreatesSettingGBox.Visible := False;
    Height := Height - SQLCreatesSettingGBox.Height - 10;
  end;

  RegionsListBox.Items.Clear;
  RegionsListBox.Items.Add('All Tables');
  EERModel.GetEERObjectList([EERRegion], theRegions, False);
  for i := 0 to theRegions.Count - 1 do
    RegionsListBox.Items.Add(TEERRegion(theRegions[i]).ObjName);

  RegionsListBox.Checked[0] := True;
end;


function TEERExportSQLScriptFrom.GetSQLScript: string;
var s: string;
  i: integer;
  Tables: TList;
  theEERTbl: TEERTable;
begin
  Tables := TList.Create;
  try
    GetSQLScript := '';
    if (ScriptMode = 0) then
      StatusBar.SimpleText := DMMain.GetTranslatedMessage('Creating SQL Creates.', 199)
    else if (ScriptMode = 1) then
      StatusBar.SimpleText := DMMain.GetTranslatedMessage('Creating SQL Drops.', 200)
    else if (ScriptMode = 2) then
      StatusBar.SimpleText := DMMain.GetTranslatedMessage('Creating SQL Optimize Script.', 242)
    else if (ScriptMode = 3) then
      StatusBar.SimpleText := DMMain.GetTranslatedMessage('Creating SQL Repair Script.', 271);

    //get tables
    if (RegionsListBox.Checked[0]) then
      EERModel.GetEERObjectList([EERTable], Tables, ExportSelTablesCBox.Checked)
    else
    begin
      //get tables on regions
      for i := 1 to RegionsListBox.Items.Count - 1 do
        if (RegionsListBox.Checked[i]) then
          TEERRegion(theRegions[i - 1]).GetEERObjsInRegion([EERTable], Tables, ExportSelTablesCBox.Checked);
    end;

    //Remove Linked Tables if CreateSQLforLinkedObjects is deactivated
    if (not (EERModel.CreateSQLforLinkedObjects)) then
    begin
      i := 0;
      while (i < Tables.Count) do
        if (TEERTable(Tables[i]).IsLinkedObject) then
          Tables.Delete(i)
        else
          inc(i);
    end;

    //Sort tables alphabetically
    EERModel.SortEERObjectListByObjName(Tables);

    //Sort in FK order
    if (PhysicalCBox.Checked) then
      EERModel.SortEERTableListByForeignKeyReferences(Tables);

    //When dropping the tables, reverse tablelist order
    if (ScriptMode = 1) then
      DMMain.ReverseList(Tables);


    //do for all tables
    s := '';
    for i := 0 to Tables.Count - 1 do
    begin
      theEERTbl := Tables[i];

      if (ScriptMode = 0) then
        s := s + theEERTbl.GetSQLCreateCode(PKCBox.Checked,
          IndicesCBox.Checked, FKCBox.Checked,
          TblOptionsCBox.Checked, StdInsertsCBox.Checked,
          CommentsCBox.Checked) + #13#10#13#10
      else if (ScriptMode = 1) then
        s := s + theEERTbl.GetSQLDropCode + #13#10#13#10
      else if (ScriptMode = 2) then
        s := s + 'OPTIMIZE TABLE ' + theEERTbl.GetSQLTableName + ';' + #13#10#13#10
      else if (ScriptMode = 3) then
        s := s + 'REPAIR TABLE ' + theEERTbl.GetSQLTableName + ';' + #13#10#13#10;

    end;

    if (DMEER.OutputLinuxStyleLineBreaks) then
      s := DMMain.ReplaceString(s, #13#10, #10);


    GetSQLScript := s;
  finally
    Tables.Free;
  end;
end;


procedure TEERExportSQLScriptFrom.ExportBtnClick(Sender: TObject);
var theFile: Textfile;
  theSaveDialog: TSaveDialog;
begin
  theSaveDialog := TSaveDialog.Create(nil);
  try
{$IFDEF MSWINDOWS}
    //On Windows use native Win32 Open Dlg
    theSaveDialog.UseNativeDialog := True;
    theSaveDialog.OnShow := DMMain.OnOpenSaveDlgShow;
{$ENDIF}

    if (ScriptMode = 0) then
      theSaveDialog.Title := DMMain.GetTranslatedMessage('Export SQL Creates ...', 201)
    else if (ScriptMode = 1) then
      theSaveDialog.Title := DMMain.GetTranslatedMessage('Export SQL Drops ...', 202)
    else if (ScriptMode = 2) then
      theSaveDialog.Title := DMMain.GetTranslatedMessage('Export SQL Optimize Script ...', 272)
    else if (ScriptMode = 3) then
      theSaveDialog.Title := DMMain.GetTranslatedMessage('Export SQL Repair Script ...', 273);

    theSaveDialog.Width := 600;
    theSaveDialog.Height := 450;
    theSaveDialog.DefaultExt := 'sql';

    if (DirectoryExists(DMGUI.RecentExportSQLCreatesDir)) then
      theSaveDialog.InitialDir := DMGUI.RecentExportSQLCreatesDir
    else
      theSaveDialog.InitialDir := '';

    {theSaveDialog.Position:=Point((Screen.Width-theSaveDialog.Width) div 2,
      (Screen.Height-theSaveDialog.Height) div 2);}

    theSaveDialog.Filter := DMMain.GetTranslatedMessage('SQL files', 203) + ' (*.sql)';

    if (theSaveDialog.Execute) then
    begin
      if (FileExists(theSaveDialog.Filename)) then
        if (MessageDlg(DMMain.GetTranslatedMessage('The file [%s] ' +
          'already exists. '#13#10 +
          'Do you want to overwrite this file?', 197,
          ExtractFileName(theSaveDialog.Filename)), mtInformation,
          [mbYes, mbNo], 0) = mrNo) then
          Exit;

      AssignFile(theFile, theSaveDialog.Filename);
      ReWrite(theFile);
      try
        WriteLn(theFile, GetSQLScript);
      finally
        CloseFile(theFile);
      end;

      if (ScriptMode = 0) then
        StatusBar.SimpleText := DMMain.GetTranslatedMessage('SQL Creates saved to file %s.', 204, ExtractFileName(theSaveDialog.Filename))
      else if (ScriptMode = 1) then
        StatusBar.SimpleText := DMMain.GetTranslatedMessage('SQL Drops saved to file %s.', 205, ExtractFileName(theSaveDialog.Filename))
      else if (ScriptMode = 2) then
        StatusBar.SimpleText := DMMain.GetTranslatedMessage('SQL Optimize Script saved to file %s.', 274, ExtractFileName(theSaveDialog.Filename))
      else if (ScriptMode = 3) then
        StatusBar.SimpleText := DMMain.GetTranslatedMessage('SQL Repair Script saved to file %s.', 275, ExtractFileName(theSaveDialog.Filename));

      DMGUI.RecentExportSQLCreatesDir := ExtractFilePath(theSaveDialog.FileName);
    end;
  finally
    theSaveDialog.Free;
  end;
end;

procedure TEERExportSQLScriptFrom.CopyBtnClick(Sender: TObject);
begin
  Clipboard.AsText := GetSQLScript;
  if (ScriptMode = 0) then
    StatusBar.SimpleText := DMMain.GetTranslatedMessage('SQL Creates copied to Clipboard.', 206)
  else if (ScriptMode = 1) then
    StatusBar.SimpleText := DMMain.GetTranslatedMessage('SQL Drops copied to Clipboard.', 207)
  else if (ScriptMode = 2) then
    StatusBar.SimpleText := DMMain.GetTranslatedMessage('SQL Optimize Script copied to Clipboard.', 276)
  else if (ScriptMode = 3) then
    StatusBar.SimpleText := DMMain.GetTranslatedMessage('SQL Repair Script copied to Clipboard.', 277);

end;

procedure TEERExportSQLScriptFrom.FKCBoxClick(Sender: TObject);
begin
  PhysicalCBox.Checked := FKCBox.Checked;
end;

procedure TEERExportSQLScriptFrom.LoadSettingsFromIniFile;
var theIni: TMemIniFile;
begin
  //Read from IniFile
  theIni := TMemIniFile.Create(DMMain.SettingsPath + DMMain.ProgName + '_Settings.ini');
  try
    ExportSelTablesCBox.Checked := (StrToInt(theIni.ReadString('ExportSQLSettings', 'ExportSelTables',
      '0')) = 1);
    PhysicalCBox.Checked := (StrToInt(theIni.ReadString('ExportSQLSettings', 'OrderTablesByForeignKeys',
      '0')) = 1);

    PKCBox.Checked := (StrToInt(theIni.ReadString('ExportSQLSettings', 'DefinePKs',
      '1')) = 1);
    TblOptionsCBox.Checked := (StrToInt(theIni.ReadString('ExportSQLSettings', 'OutputTableOptions',
      '1')) = 1);
    IndicesCBox.Checked := (StrToInt(theIni.ReadString('ExportSQLSettings', 'CreateIndices',
      '1')) = 1);
    StdInsertsCBox.Checked := (StrToInt(theIni.ReadString('ExportSQLSettings', 'OutputStdInserts',
      '1')) = 1);

    FKCBox.Checked := (StrToInt(theIni.ReadString('ExportSQLSettings', 'DefineFKReference',
      '0')) = 1);

    CommentsCBox.Checked := (StrToInt(theIni.ReadString('ExportSQLSettings', 'OutputComments',
      '0')) = 1);
  finally
    theIni.Free;
  end;
end;

procedure TEERExportSQLScriptFrom.SaveSettingsToIniFile;
var theIni: TMemIniFile;
begin
  //Write to IniFile
  theIni := TMemIniFile.Create(DMMain.SettingsPath + DMMain.ProgName + '_Settings.ini');
  try
    theIni.WriteString('ExportSQLSettings', 'ExportSelTables',
      IntToStr(Ord(ExportSelTablesCBox.Checked)));
    theIni.WriteString('ExportSQLSettings', 'OrderTablesByForeignKeys',
      IntToStr(Ord(PhysicalCBox.Checked)));

    theIni.WriteString('ExportSQLSettings', 'DefinePKs',
      IntToStr(Ord(PKCBox.Checked)));
    theIni.WriteString('ExportSQLSettings', 'OutputTableOptions',
      IntToStr(Ord(TblOptionsCBox.Checked)));
    theIni.WriteString('ExportSQLSettings', 'CreateIndices',
      IntToStr(Ord(IndicesCBox.Checked)));
    theIni.WriteString('ExportSQLSettings', 'OutputStdInserts',
      IntToStr(Ord(StdInsertsCBox.Checked)));

    theIni.WriteString('ExportSQLSettings', 'DefineFKReference',
      IntToStr(Ord(FKCBox.Checked)));

    theIni.WriteString('ExportSQLSettings', 'OutputComments',
      IntToStr(Ord(CommentsCBox.Checked)));

    theIni.UpdateFile;
  finally
    theIni.Free;
  end;
end;


procedure TEERExportSQLScriptFrom.RegionsListBoxClickCheck(
  Sender: TObject);
var i: integer;
  RegionChecked: Boolean;
begin
  RegionChecked := False;

  for i := 1 to RegionsListBox.Items.Count - 1 do
    if (RegionsListBox.Checked[i]) then
    begin
      RegionChecked := True;
      break;
    end;

  RegionsListBox.Checked[0] := not (RegionChecked);
end;

procedure TEERExportSQLScriptFrom.RegionsListBoxMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var i: integer;
begin
  if (RegionsListBox.ItemAtPos(Point(X, Y), True) = 0) and
    (X < 14) then
  begin
    for i := 1 to RegionsListBox.Items.Count - 1 do
      RegionsListBox.Checked[i] := False;

    RegionsListBox.Checked[0] := True;
  end;
end;

procedure TEERExportSQLScriptFrom.CloseBtnClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

end.
