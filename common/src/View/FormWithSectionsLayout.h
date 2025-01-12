/*
 Copyright (C) 2010-2017 Kristian Duske

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

#pragma once

#include <QFormLayout>

namespace TrenchBroom {
namespace View {
class FormWithSectionsLayout : public QFormLayout {
public:
  using QFormLayout::QFormLayout;

  void addSection(const QString& title, const QString& info = "");

  // Since these functions are not virtual, we can only hide the inherited ones.
  void addRow(QWidget* label, QWidget* field);
  void addRow(QWidget* label, QLayout* field);
  void addRow(const QString& labelText, QWidget* field);
  void addRow(const QString& labelText, QLayout* field);
  void addRow(QWidget* field);
  void addRow(QLayout* field);

  void insertRow(int row, QWidget* label, QWidget* field);
  void insertRow(int row, QWidget* label, QLayout* field);
  void insertRow(int row, const QString& labelText, QWidget* field);
  void insertRow(int row, const QString& labelText, QLayout* field);
  void insertRow(int row, QWidget* field);
  void insertRow(int row, QLayout* field);
};
} // namespace View
} // namespace TrenchBroom
