/*
 Copyright (C) 2010-2016 Kristian Duske
 
 This file is part of TrenchBroom.
 
 TrenchBroom is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 TrenchBroom is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with TrenchBroom. If not, see <http://www.gnu.org/licenses/>.
 */

#include "ImageListBox.h"

#include "View/ViewConstants.h"

#include <wx/panel.h>
#include <wx/sizer.h>
#include <wx/stattext.h>
#include <wx/statbmp.h>

#include <cassert>

namespace TrenchBroom {
    namespace View {
        ImageListBox::ImageListBox(wxWindow* parent, const wxString& emptyText) :
        ControlListBox(parent, true, emptyText) {}

        ControlListBox::Item* ImageListBox::createItem(wxWindow* parent, const wxSize& margins, const size_t index) {
            Item* container = new Item(parent);
            wxStaticText* titleText = new wxStaticText(container, wxID_ANY, title(index), wxDefaultPosition, wxDefaultSize,  wxST_ELLIPSIZE_END);
            wxStaticText* subtitleText = new wxStaticText(container, wxID_ANY, subtitle(index), wxDefaultPosition, wxDefaultSize,  wxST_ELLIPSIZE_MIDDLE);
            
            titleText->SetFont(titleText->GetFont().Bold());
#ifndef _WIN32
            subtitleText->SetWindowVariant(wxWINDOW_VARIANT_SMALL);
#endif
            
            wxSizer* vSizer = new wxBoxSizer(wxVERTICAL);
            vSizer->Add(titleText, 0);
            vSizer->Add(subtitleText, 0);
            
            wxSizer* hSizer = new wxBoxSizer(wxHORIZONTAL);
            hSizer->AddSpacer(margins.x);

            wxBitmap bitmap;
            if (image(index, bitmap)) {
                wxStaticBitmap* imagePanel = new wxStaticBitmap(container, wxID_ANY, bitmap);
                hSizer->Add(imagePanel, 0, wxALIGN_BOTTOM | wxTOP | wxBOTTOM, margins.y);
            }
            hSizer->Add(vSizer, 0, wxTOP | wxBOTTOM, margins.y);
            hSizer->AddSpacer(margins.x);
            
            container->SetSizer(hSizer);
            return container;
        }

        bool ImageListBox::image(const size_t n, wxBitmap& result) const {
            result = wxNullBitmap;
            return false;
        }
    }
}
