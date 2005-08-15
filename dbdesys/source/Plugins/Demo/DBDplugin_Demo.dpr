program DBDplugin_Demo;

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
// Unit DBDplugin_Demo.dpr
// -----------------------
// Version 1.0, 10.01.2003, Mike
// Description
//   Projectfile for the Demo Plugin
//
// Changes:
//   Version 1.1, 01.08.2003, Mike
//     added support for LibXmlParser
//   Version 1.0, 10.01.2003, Mike
//     initial version, Mike
//
//----------------------------------------------------------------------------------------------------------------------

{$IFDEF MSWINDOWS}
{$I ..\..\dbdesys.inc}
{$ELSE}
{$I ../../dbdesys.inc}
{$ENDIF}

uses
  QForms,
  Main in 'Main.pas' {MainForm},
{$IFDEF MSWINDOWS}
  EERModel in '..\..\EERModel.pas',
  EERDM in '..\..\EERDM.pas' {DMEER: TDataModule},
  MainDM in '..\..\MainDM.pas' {DMMain: TDataModule},
  EditorString in '..\..\EditorString.pas' {EditorStringForm},
{$IFDEF USE_IXMLDBMODELType}
  EERModel_XML in '..\..\EERModel_XML.pas',
{$ENDIF}
  LibXmlParser in '..\..\LibXmlParser.pas';
{$ELSE}
  EERModel in '../../EERModel.pas',
  EERDM in '../../EERDM.pas' {DMEER: TDataModule},
  MainDM in '../../MainDM.pas' {DMMain: TDataModule},
  EditorString in '../../EditorString.pas' {EditorStringForm},
{$IFDEF USE_IXMLDBMODELType}
  EERModel_XML in '../../EERModel_XML.pas',
{$IFDEF LINUX}
  xmldom, oxmldom,
{$ENDIF}
{$ENDIF}
  LibXmlParser in '../../LibXmlParser.pas';
{$ENDIF}

{$R *.res}

begin
{$IFDEF LINUX}
{$IFDEF USE_IXMLDBMODELType}
  DefaultDOMVendor:='Open XML';
{$ENDIF}
{$ENDIF}

  Application.Initialize;
  Application.Title := 'Demo Plugin';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
