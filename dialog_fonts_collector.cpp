// Copyright (c) 2007, Rodrigo Braz Monteiro
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
//   * Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//   * Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//   * Neither the name of the Aegisub Group nor the names of its contributors
//     may be used to endorse or promote products derived from this software
//     without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// -----------------------------------------------------------------------------
//
// AEGISUB
//
// Website: http://aegisub.cellosoft.com
// Contact: mailto:zeratul@cellosoft.com
//


////////////
// Includes
#include <wx/config.h>
#include <wx/filename.h>
#include <wx/wfstream.h>
#include <wx/zipstrm.h>
#include "ass_override.h"
#include "ass_file.h"
#include "ass_dialogue.h"
#include "ass_style.h"
#include "dialog_fonts_collector.h"
#include "utils.h"
#include "options.h"
#include "frame_main.h"
#include "subs_grid.h"
#include "main.h"
#include "font_file_lister.h"
#include "utils.h"


///////
// IDs
enum IDs {
	START_BUTTON = 1150,
	BROWSE_BUTTON,
	RADIO_BOX
};


///////////////
// Constructor
DialogFontsCollector::DialogFontsCollector(wxWindow *parent)
: wxDialog(parent,-1,_("Fonts Collector"),wxDefaultPosition, wxDefaultSize, wxDEFAULT_DIALOG_STYLE)
{
	// Parent
	main = (FrameMain*) parent;

	// Destination box
	wxString dest = Options.AsText(_T("Fonts Collector Destination"));
	if (dest == _T("?script")) {
		wxFileName filename(AssFile::top->filename);
		dest = filename.GetPath();
	}
	DestBox = new wxTextCtrl(this,-1,dest,wxDefaultPosition,wxSize(250,20),0);
	BrowseButton = new wxButton(this,BROWSE_BUTTON,_("&Browse..."));
	wxSizer *DestBottomSizer = new wxBoxSizer(wxHORIZONTAL);
	DestLabel = new wxStaticText(this,-1,_("Choose the folder where the fonts will be collected to.\nIt will be created if it doesn't exist."));
	DestBottomSizer->Add(DestBox,1,wxEXPAND | wxRIGHT,5);
	DestBottomSizer->Add(BrowseButton,0,0,0);
	wxSizer *DestSizer = new wxStaticBoxSizer(wxVERTICAL,this,_("Destination"));
	DestSizer->Add(DestLabel,0,wxEXPAND | wxBOTTOM,5);
	DestSizer->Add(DestBottomSizer,0,wxEXPAND,0);

	// Action radio box
	wxArrayString choices;
	choices.Add(_T("Check fonts for availability"));
	choices.Add(_T("Copy fonts to folder"));
	choices.Add(_T("Copy fonts to zipped archive"));
	choices.Add(_T("Attach fonts to current subtitles"));
	CollectAction = new wxRadioBox(this,RADIO_BOX,_T("Action"),wxDefaultPosition,wxDefaultSize,choices,1);
	CollectAction->SetSelection(Options.AsInt(_T("Fonts Collector Action")));

	// Log box
	LogBox = new wxStyledTextCtrl(this,-1,wxDefaultPosition,wxSize(300,210),0,_T(""));
	LogBox->SetWrapMode(wxSTC_WRAP_WORD);
	LogBox->SetMarginWidth(1,0);
	LogBox->SetReadOnly(true);
	LogBox->StyleSetForeground(1,wxColour(0,200,0));
	LogBox->StyleSetForeground(2,wxColour(200,0,0));
	LogBox->StyleSetForeground(3,wxColour(200,100,0));
	wxSizer *LogSizer = new wxStaticBoxSizer(wxVERTICAL,this,_("Log"));
	LogSizer->Add(LogBox,1,wxEXPAND,0);

	// Buttons sizer
	StartButton = new wxButton(this,START_BUTTON,_("&Start!"));
	StartButton->SetDefault();
	CloseButton = new wxButton(this,wxID_CANCEL,_T("Close"));
	wxSizer *ButtonSizer = new wxBoxSizer(wxHORIZONTAL);
	ButtonSizer->AddStretchSpacer(1);
#ifdef __WXMAC__ 
	ButtonSizer->Add(CloseButton,0,wxRIGHT,5);
	ButtonSizer->Add(StartButton);
#else
	ButtonSizer->Add(StartButton,0,wxRIGHT,5);
	ButtonSizer->Add(CloseButton);
#endif

	// Main sizer
	wxSizer *MainSizer = new wxBoxSizer(wxVERTICAL);
	MainSizer->Add(CollectAction,0,wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM,5);
	MainSizer->Add(DestSizer,0,wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM,5);
	MainSizer->Add(LogSizer,0,wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM,5);
	MainSizer->Add(ButtonSizer,0,wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM,5);

	// Set sizer
	SetSizer(MainSizer);
	MainSizer->SetSizeHints(this);
	CenterOnParent();

	// Run dummy event to update label
	Update();
}


//////////////
// Destructor
DialogFontsCollector::~DialogFontsCollector() {
	FontFileLister::ClearData();
}


///////////////
// Event table
BEGIN_EVENT_TABLE(DialogFontsCollector, wxDialog)
	EVT_BUTTON(START_BUTTON,DialogFontsCollector::OnStart)
	EVT_BUTTON(BROWSE_BUTTON,DialogFontsCollector::OnBrowse)
	EVT_BUTTON(wxID_CLOSE,DialogFontsCollector::OnClose)
	EVT_RADIOBOX(RADIO_BOX,DialogFontsCollector::OnRadio)
END_EVENT_TABLE()


////////////////////
// Start processing
void DialogFontsCollector::OnStart(wxCommandEvent &event) {
	// Check if it's OK to do it
	wxString foldername = DestBox->GetValue();
	wxFileName folder(foldername);
	int action = CollectAction->GetSelection();

	// Make folder if it doesn't exist
	if (action == 1 && !folder.DirExists()) {
		folder.Mkdir(0777,wxPATH_MKDIR_FULL);
		if (!folder.DirExists()) {
			wxMessageBox(_("Invalid destination"),_("Error"),wxICON_EXCLAMATION | wxOK);
			return;
		}
	}

	// Start thread
	wxThread *worker = new FontsCollectorThread(AssFile::top,foldername,this);
	worker->Create();
	worker->Run();

	// Set options
	if (action == 1 || action == 2) {
		wxString dest = foldername;
		wxFileName filename(AssFile::top->filename);
		if (filename.GetPath() == dest) {
			dest = _T("?script");
		}
		Options.SetText(_T("Fonts Collector Destination"),dest);
	}
	Options.SetInt(_T("Fonts Collector Action"),action);
	Options.Save();

	// Set buttons
	StartButton->Enable(false);
	BrowseButton->Enable(false);
	DestBox->Enable(false);
	CloseButton->Enable(false);
	CollectAction->Enable(false);
	DestLabel->Enable(false);
	if (!worker->IsDetached()) worker->Wait();
}


////////////////
// Close dialog
void DialogFontsCollector::OnClose(wxCommandEvent &event) {
	EndModal(0);
}


///////////////////
// Browse location
void DialogFontsCollector::OnBrowse(wxCommandEvent &event) {
	// Chose file name
	if (CollectAction->GetSelection()==2) {
		wxFileName fname(DestBox->GetValue());
		wxString dest = wxFileSelector(_("Select archive file name"),DestBox->GetValue(),fname.GetFullName(),_T(".zip"),_T("Zip Archives (*.zip)|*.zip"),wxFD_SAVE|wxFD_OVERWRITE_PROMPT);
		if (!dest.empty()) {
			DestBox->SetValue(dest);
		}
	}

	// Choose folder
	else {
		wxString dest = wxDirSelector(_("Select folder to save fonts on"),DestBox->GetValue(),0);
		if (!dest.empty()) {
			DestBox->SetValue(dest);
		}
	}
}


/////////////////////
// Radio box changed
void DialogFontsCollector::OnRadio(wxCommandEvent &event) {
	Update(event.GetInt());
}


///////////////////
// Update controls
void DialogFontsCollector::Update(int value) {
	// Enable buttons
	CloseButton->Enable(true);
	StartButton->Enable(true);
	CollectAction->Enable(true);

	// Get value if -1
	if (value == -1) {
		value = CollectAction->GetSelection();
	}

	// Check or attach
	if (value == 0 || value == 3) {
		DestBox->Enable(false);
		BrowseButton->Enable(false);
		DestLabel->Enable(false);
		DestLabel->SetLabel(_T("N/A\n"));
	}

	// Collect to folder
	else if (value == 1) {
		DestBox->Enable(true);
		BrowseButton->Enable(true);
		DestLabel->Enable(true);
		DestLabel->SetLabel(_("Choose the folder where the fonts will be collected to.\nIt will be created if it doesn't exist."));

		// Remove filename from browser box
		wxFileName fname1(DestBox->GetValue()+_T("/"));
		if (fname1.DirExists()) {
			DestBox->SetValue(fname1.GetPath());
		}
		else {
			wxFileName fname2(DestBox->GetValue());
			if (fname2.DirExists()) {
				DestBox->SetValue(fname2.GetPath());
			}
			else DestBox->SetValue(((AegisubApp*)wxTheApp)->folderName);
		}
	}

	// Collect to zip
	else if (value == 2) {
		DestBox->Enable(true);
		BrowseButton->Enable(true);
		DestLabel->Enable(true);
		DestLabel->SetLabel(_("Enter the name of the destination zip file to collect the fonts to.\nIf a folder is entered, a default name will be used."));
	}
}


///////////////////////
// Collect font files
void FontsCollectorThread::CollectFontData () {
	FontFileLister::GatherData();
}


////////////////////
// Collector thread
FontsCollectorThread::FontsCollectorThread(AssFile *_subs,wxString _destination,DialogFontsCollector *_collector)
: wxThread(wxTHREAD_DETACHED)
{
	subs = _subs;
	destination = _destination;
	collector = _collector;
	instance = this;
}


////////////////
// Thread entry
wxThread::ExitCode FontsCollectorThread::Entry() {
	// Collect
	Collect();

	// After done, restore status
	collector->Update();

	// Return
	if (IsDetached()) Delete();
	return 0;
}


///////////
// Collect
void FontsCollectorThread::Collect() {
	// Clear log box
	wxMutexGuiEnter();
	collector->LogBox->SetReadOnly(false);
	collector->LogBox->ClearAll();
	collector->LogBox->SetReadOnly(true);
	wxMutexGuiLeave();

	// Set destination folder
	int oper = collector->CollectAction->GetSelection();
	destFolder = collector->DestBox->GetValue();
	if (oper == 1 && !wxFileName::DirExists(destFolder)) {
		AppendText(_("Invalid destination directory."),1);
		return;
	}

	// Collect font data
	AppendText(_("Collecting font data from system... "));
	CollectFontData();
	AppendText(_("done.\n\nScanning file for fonts..."));

	// Scan file
	AssDialogue *curDiag;
	curLine = 0;
	for (std::list<AssEntry*>::iterator cur=subs->Line.begin();cur!=subs->Line.end();cur++) {
		// Collect from style
		curStyle = AssEntry::GetAsStyle(*cur);
		if (curStyle) {
			AddFont(curStyle->font,true);
		}

		// Collect from dialogue
		else {
			curDiag = AssEntry::GetAsDialogue(*cur);
			if (curDiag) {
				curLine++;
				curDiag->ParseASSTags();
				curDiag->ProcessParameters(GetFonts);
				curDiag->ClearBlocks();
			}
		}
	}

	// Copy fonts
	AppendText(_("Done.\n\n"));
	switch (oper) {
		case 0: AppendText(_("Checking fonts...\n")); break;
		case 1: AppendText(_("Copying fonts to folder...\n")); break;
		case 2: AppendText(_("Copying fonts to archive...\n")); break;
		case 3: AppendText(_("Attaching fonts to file...\n")); break;
	}
	bool ok = true;
	bool someOk = false;
	for (size_t i=0;i<fonts.Count();i++) {
		bool result = ProcessFont(fonts[i]);
		if (result) someOk = true;
		if (!result) ok = false;
	}

	// Final result
	if (ok) {
		if (oper == 0) AppendText(_("Done. All fonts found."),1);
		else {
			AppendText(_("Done. All fonts copied."),1);

			// Modify file if it was attaching
			if (oper == 3 && someOk) {
				wxMutexGuiEnter();
				subs->FlagAsModified(_("font attachment"));
				collector->main->SubsBox->CommitChanges();
				wxMutexGuiLeave();
			}
		}
	}
	else {
		if (oper == 0) AppendText(_("Done. Some fonts could not be found."),2);
		else  AppendText(_("Done. Some fonts could not be copied."),2);
	}
}


////////////////
// Process font
bool FontsCollectorThread::ProcessFont(wxString name) {
	// Action
	int action = collector->CollectAction->GetSelection();

	// Font name
	AppendText(wxString::Format(_T("\"%s\"... "),name.c_str()));

	// Get font list
	wxArrayString files = FontFileLister::GetFilesWithFace(name);
	bool result = files.Count() != 0;

	// No files found
	if (!result) {
		AppendText(_("Not found.\n"),2);
		return false;
	}

	// Just checking, found
	else if (action == 0) {
		AppendText(_("Found.\n"),1);
		return true;
	}

	// Copy font
	AppendText(_T("\n"));
	for (size_t i=0;i<files.Count();i++) {
		int tempResult = 0;
		switch (action) {
			case 1: tempResult = CopyFont(files[i]); break;
			case 2: tempResult = ArchiveFont(files[i]) ? 1 : 0; break;
			case 3: tempResult = AttachFont(files[i]) ? 1 : 0; break;
		}

		if (tempResult == 1) {
			AppendText(wxString::Format(_("* Copied %s.\n"),files[i].c_str()),1);
		}
		else if (tempResult == 2) {
			wxFileName fn(files[i]);
			AppendText(wxString::Format(_("* %s already exists on destination.\n"),fn.GetFullName().c_str()),3);
		}
		else {
			AppendText(wxString::Format(_("* Failed to copy %s.\n"),files[i].c_str()),2);
			result = false;
		}
	}

	// Done
	return result;
}


/////////////
// Copy font
int FontsCollectorThread::CopyFont(wxString filename) {
	wxFileName fn(filename);
	wxString dstName = destFolder + _T("//") + fn.GetFullName();
	if (wxFileName::FileExists(dstName)) return 2;
	return CopyFile(filename,dstName) ? 1 : 0;
}


////////////////
// Archive font
bool FontsCollectorThread::ArchiveFont(wxString filename) {
	return false;
}


///////////////
// Attach font
bool FontsCollectorThread::AttachFont(wxString filename) {
	try {
		subs->InsertAttachment(filename);
	}
	catch (...) {
		return false;
	}
	return true;
}


////////////////////////////////
// Get fonts from ass overrides
void FontsCollectorThread::GetFonts (wxString tagName,int par_n,AssOverrideParameter *param,void *usr) {
	if (tagName == _T("\\fn")) {
		instance->AddFont(param->AsText(),false);
	}
}


///////////////
// Adds a font
void FontsCollectorThread::AddFont(wxString fontname,bool isStyle) {
	if (fonts.Index(fontname) == wxNOT_FOUND) {
		fonts.Add(fontname);

		if (isStyle) AppendText(wxString(_T("\"")) + fontname + _("\" found on style \"") + curStyle->name + _T("\".\n"));
		if (!isStyle) AppendText(wxString(_T("\"")) + fontname + _("\" found on dialogue line ") + wxString::Format(_T("%i"),curLine) + _T(".\n"));
	}
}


///////////////
// Append text
void FontsCollectorThread::AppendText(wxString text,int colour) {
	wxStyledTextCtrl *LogBox = collector->LogBox;
	wxMutexGuiEnter();
	LogBox->SetReadOnly(false);
	int pos = LogBox->GetLength();
	LogBox->AppendText(text);
	if (colour) {
		LogBox->StartStyling(pos,31);
		LogBox->SetStyling(text.Length(),colour);
	}
	LogBox->GotoPos(pos);
	LogBox->SetReadOnly(true);
	wxSafeYield();
	wxMutexGuiLeave();
}


///////////////////
// Static instance
FontsCollectorThread *FontsCollectorThread::instance;
