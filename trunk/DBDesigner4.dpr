program DBDesigner4;

//----------------------------------------------------------------------------------------------------------------------
//
// This file is part of fabFORCE DBDesigner4.
// Copyright (C) 2002 Michael G. Zinner, www.fabFORCE.net
//
// DBDesigner4 is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// DBDesigner4 is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with DBDesigner4; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//
//----------------------------------------------------------------------------------------------------------------------
//
// Unit DBDesigner4.dpr
// --------------------
// Version 1.0, 13.03.2003, Mike
// Description
//   DBDesigner4 Project file, includes all modules, displays
//   the splash screen, creates the MainForm and runs the application
//   The Version Number is set in this file
//
// Changes:
//   Version 1.0, 13.03.2003, Mike
//     initial version
//
//----------------------------------------------------------------------------------------------------------------------

{$I DBDesigner4.inc}

uses
  ExceptionLog,
  QForms,

//-------------------------------------------------------------
// Include all units

  Main in 'Main.pas' {MainForm},
  MainDM in 'MainDM.pas' {DMMain: TDataModule},
  Splash in 'Splash.pas' {SplashForm},
  EER in 'EER.pas' {EERForm},
  PaletteTools in 'PaletteTools.pas' {PaletteToolsForm},
  EERModel in 'EERModel.pas',
  ZoomSel in 'ZoomSel.pas' {ZoomSelForm},
  PaletteModel in 'PaletteModel.pas' {PaletteModelFrom},
  PaletteDatatypes in 'PaletteDatatypes.pas' {PaletteDataTypesForm},
  EditorTable in 'EditorTable.pas' {EditorTableForm},
  EditorDatatype in 'EditorDatatype.pas' {EditorDatatypeForm},
  EditorString in 'EditorString.pas' {EditorStringForm},
  EditorRegion in 'EditorRegion.pas' {EditorRegionForm},
  EditorNote in 'EditorNote.pas' {EditorNoteForm},
  OptionsModel in 'OptionsModel.pas' {OptionsModelForm},
  EditorRelation in 'EditorRelation.pas' {EditorRelationForm},
  Options in 'Options.pas' {OptionsForm},
  EERPageSetup in 'EERPageSetup.pas' {EERPageSetupForm},
  PaletteNav in 'PaletteNav.pas' {PaletteNavForm},
  EditorImage in 'EditorImage.pas' {EditorImageForm},
  EERExportSQLScript in 'EERExportSQLScript.pas' {EERExportSQLScriptFrom},
  DBConnSelect in 'DBConnSelect.pas' {DBConnSelectForm},
  PaletteDataTypesReplace in 'PaletteDataTypesReplace.pas' {PaletteDataTypesReplaceForm},
  EERReverseEngineering in 'EERReverseEngineering.pas' {EERReverseEngineeringForm},
  EERSynchronisation in 'EERSynchronisation.pas' {EERSynchronisationForm},
  DBConnEditor in 'DBConnEditor.pas' {DBConnEditorForm},
  DBConnLogin in 'DBConnLogin.pas' {DBConnLoginForm},
  EERStoreInDatabase in 'EERStoreInDatabase.pas' {EERStoreInDatabaseForm},
  EERDM in 'EERDM.pas' {DMEER: TDataModule},
  EditorTableField in 'EditorTableField.pas',
  EditorTableFieldDatatypeInplace in 'EditorTableFieldDatatypeInplace.pas',
  GUIDM in 'GUIDM.pas' {DMGUI: TDataModule},
  DBDM in 'DBDM.pas' {DMDB: TDataModule},
  DBEERDM in 'DBEERDM.pas' {DMDBEER: TDataModule},
  EditorTableFieldParam in 'EditorTableFieldParam.pas' {EditorTableFieldParamForm},
  Tips in 'Tips.pas' {TipsForm},
  EditorQuery in 'EditorQuery.pas' {EditorQueryForm},
  EditorQueryDragTarget in 'EditorQueryDragTarget.pas' {EditorQueryDragTargetForm},
  EERExportImportDM in 'EERExportImportDM.pas',

//-------------------------------------------------------------
// Include SynEdit if USE_SYNEDIT is defined

{$IFDEF USE_SYNEDIT}
{$IFDEF MSWINDOWS}
  QSynHighlighterHashEntries in 'SynEdit\QSynHighlighterHashEntries.pas',
  QSynHighlighterSQL in 'SynEdit\QSynHighlighterSQL.pas',
  QSynEditKbdHandler in 'SynEdit\QSynEditKbdHandler.pas',
  QSynEditHighlighter in 'SynEdit\QSynEditHighlighter.pas',
  QSynEditStrConst in 'SynEdit\QSynEditStrConst.pas',
  QSynEditKeyCmds in 'SynEdit\QSynEditKeyCmds.pas',
  QSynEditTextBuffer in 'SynEdit\QSynEditTextBuffer.pas',
  QSynEditMiscClasses in 'SynEdit\QSynEditMiscClasses.pas',
  QSynEditMiscProcs in 'SynEdit\QSynEditMiscProcs.pas',
  QSynEditKeyConst in 'SynEdit\QSynEditKeyConst.pas',
  QSynEditTypes in 'SynEdit\QSynEditTypes.pas',
  kTextDrawer in 'SynEdit\kTextDrawer.pas',
  QSynEdit in 'SynEdit\QSynEdit.pas',
{$ELSE}
  QSynHighlighterHashEntries in 'SynEdit/QSynHighlighterHashEntries.pas',
  QSynHighlighterSQL in 'SynEdit/QSynHighlighterSQL.pas',
  QSynEditKbdHandler in 'SynEdit/QSynEditKbdHandler.pas',
  QSynEditHighlighter in 'SynEdit/QSynEditHighlighter.pas',
  QSynEditStrConst in 'SynEdit/QSynEditStrConst.pas',
  QSynEditKeyCmds in 'SynEdit/QSynEditKeyCmds.pas',
  QSynEditTextBuffer in 'SynEdit/QSynEditTextBuffer.pas',
  QSynEditMiscClasses in 'SynEdit/QSynEditMiscClasses.pas',
  QSynEditMiscProcs in 'SynEdit/QSynEditMiscProcs.pas',
  QSynEditKeyConst in 'SynEdit/QSynEditKeyConst.pas',
  QSynEditTypes in 'SynEdit/QSynEditTypes.pas',
  kTextDrawer in 'SynEdit/kTextDrawer.pas',
  QSynEdit in 'SynEdit/QSynEdit.pas',
{$ENDIF}
{$ENDIF}

//-------------------------------------------------------------
// Include EmbeddedPDF

{$IFDEF MSWINDOWS}
  EmbeddedPdfDoc in 'EmbeddedPDF\EmbeddedPdfDoc.pas',
  EmbeddedPdfFonts in 'EmbeddedPDF\EmbeddedPdfFonts.pas',
  EmbeddedPdfTypes in 'EmbeddedPDF\EmbeddedPdfTypes.pas',
  EmbeddedPdfImages in 'EmbeddedPDF\EmbeddedPdfImages.pas',
  EmbeddedPdfDB in 'EmbeddedPDF\EmbeddedPdfDB.pas',
{$ELSE}
  EmbeddedPdfDoc in 'EmbeddedPDF/EmbeddedPdfDoc.pas',
  EmbeddedPdfFonts in 'EmbeddedPDF/EmbeddedPdfFonts.pas',
  EmbeddedPdfTypes in 'EmbeddedPDF/EmbeddedPdfTypes.pas',
  EmbeddedPdfImages in 'EmbeddedPDF/EmbeddedPdfImages.pas',
  EmbeddedPdfDB in 'EmbeddedPDF/EmbeddedPdfDB.pas',
{$ENDIF}

//-------------------------------------------------------------
// Include xmldom if USE_IXMLDBMODELType is defined

{$IFDEF USE_IXMLDBMODELType}
  EERModel_XML_ERwin41_Import in 'EERModel_XML_ERwin41_Import.pas',
  EERModel_XML in 'EERModel_XML.pas',
{$IFDEF LINUX}
  xmldom, oxmldom,
{$ENDIF}
{$ENDIF}

//-------------------------------------------------------------
// Include the new LibXmlParser

  LibXmlParser in 'LibXmlParser.pas',

{$IFDEF MSWINDOWS}
  MIDASLIB,
{$IFDEF USE_QTheming}
  //UxTheme in 'QTheming\Delphi6\UxTheme.pas',
  TmSchema in 'QTheming\Delphi6\TmSchema.pas',
  QThemeSrv in 'QTheming\QThemeSrv.pas',
  QThemed in 'QTheming\QThemed.pas',
{$ENDIF}
{$ENDIF}

  EERPlaceModel in 'EERPlaceModel.pas',
  RegExpr in 'RegExpr.pas',
  GlobalSysFunctions in 'GlobalSysFunctions.pas';

{$R *.res}

begin
{$IFDEF LINUX}
{$IFDEF USE_IXMLDBMODELType}
  DefaultDOMVendor := 'Open XML';
{$ENDIF}
{$ENDIF}

  Application.Initialize;
  Application.Title := 'DBDesigner 4';

  //Initialize Application Font
  LoadApplicationFont;

  //Show Splash Form
  SplashForm := TSplashForm.Create(Application);
  SplashForm.VersionLbl.Caption := '4.0.5.6 Beta';
{$IFDEF MSWINDOWS}
  SplashForm.FormStyle := fsNormal;
{$ENDIF}
  SplashForm.Show;
  SplashForm.Update;

  Application.ShowMainForm := False;
  Application.CreateForm(TMainForm, MainForm);
{$IFDEF MSWINDOWS}
  //Bring Splash Screen back to top again...
  SplashForm.BringToFront;
  SplashForm.FormStyle := fsStayOnTop;
{$ENDIF}
  Application.Run;
end.

