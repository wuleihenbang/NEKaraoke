// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

/// A model that holds a vector character
final class Glyph: Codable, DictionaryInitializable {
  // MARK: Lifecycle

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Glyph.CodingKeys.self)
    character = try container.decode(String.self, forKey: .character)
    fontSize = try container.decode(Double.self, forKey: .fontSize)
    fontFamily = try container.decode(String.self, forKey: .fontFamily)
    fontStyle = try container.decode(String.self, forKey: .fontStyle)
    width = try container.decode(Double.self, forKey: .width)
    if
      container.contains(.shapeWrapper),
      let shapeContainer = try? container.nestedContainer(keyedBy: ShapeKey.self, forKey: .shapeWrapper),
      shapeContainer.contains(.shapes) {
      shapes = try shapeContainer.decode([ShapeItem].self, ofFamily: ShapeType.self, forKey: .shapes)
    } else {
      shapes = []
    }
  }

  init(dictionary: [String: Any]) throws {
    character = try dictionary.value(for: CodingKeys.character)
    fontSize = try dictionary.value(for: CodingKeys.fontSize)
    fontFamily = try dictionary.value(for: CodingKeys.fontFamily)
    fontStyle = try dictionary.value(for: CodingKeys.fontStyle)
    width = try dictionary.value(for: CodingKeys.width)
    if
      let shapes = dictionary[CodingKeys.shapeWrapper.rawValue] as? [String: Any],
      let shapeDictionaries = shapes[ShapeKey.shapes.rawValue] as? [[String: Any]] {
      self.shapes = try [ShapeItem].fromDictionaries(shapeDictionaries)
    } else {
      shapes = [ShapeItem]()
    }
  }

  // MARK: Internal

  /// The character
  let character: String

  /// The font size of the character
  let fontSize: Double

  /// The font family of the character
  let fontFamily: String

  /// The Style of the character
  let fontStyle: String

  /// The Width of the character
  let width: Double

  /// The Shape Data of the Character
  let shapes: [ShapeItem]

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(character, forKey: .character)
    try container.encode(fontSize, forKey: .fontSize)
    try container.encode(fontFamily, forKey: .fontFamily)
    try container.encode(fontStyle, forKey: .fontStyle)
    try container.encode(width, forKey: .width)

    var shapeContainer = container.nestedContainer(keyedBy: ShapeKey.self, forKey: .shapeWrapper)
    try shapeContainer.encode(shapes, forKey: .shapes)
  }

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case character = "ch"
    case fontSize = "size"
    case fontFamily = "fFamily"
    case fontStyle = "style"
    case width = "w"
    case shapeWrapper = "data"
  }

  private enum ShapeKey: String, CodingKey {
    case shapes
  }
}