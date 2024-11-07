//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift project authors.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import Fibonacci
import Raylib
import CxxStdlib

if fibonacci_cpp(5) == "Henk!" {
    print("Is henk!")
} else {
    print("Is niet henk!")
}

InitWindow(800, 600, "Hello World")
while !WindowShouldClose() {
    BeginDrawing()
    ClearBackground(Color(r: 0, g: 0, b: 0, a: 255))
    DrawText("Congrats! You created your first window!", 190, 200, 20, Color(r: 255, g: 255, b: 255, a: 255))
    EndDrawing()
}
