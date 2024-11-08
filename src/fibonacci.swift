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

// import CxxStdlib
// import Fibonacci
// import Foundation
import LibUv
// import Raylib

let loop = uv_default_loop()

var open_req: uv_fs_t = uv_fs_t()
var read_req: uv_fs_t = uv_fs_t()
var close_req: uv_fs_t = uv_fs_t()

var data_buf = UnsafeMutablePointer<Int8>.allocate(capacity: 64)
var buffer: uv_buf_t = uv_buf_t()

func on_read(req: UnsafeMutablePointer<uv_fs_t>?) {
    uv_fs_req_cleanup(req)
    if let req = req {
        if req.pointee.result < 0 {
            print("Error reading file", String(cString: uv_strerror(Int32(req.pointee.result))))
        } else if req.pointee.result == 0 {
            print("EOF")
            print("File read")
            uv_fs_close(loop, &close_req, Int32(req.pointee.result), nil)
        } else {
            // terminate the buffer
            print("Result: \(req.pointee.result)")
            buffer.base.advanced(by: req.pointee.result).pointee = 0
            print(String(cString: buffer.base), terminator: "")
            uv_fs_read(loop, &read_req, Int32(open_req.result), &buffer, 1, -1, on_read)
        }
    }
}

// func open_cb(req: UnsafeMutablePointer<uv_fs_t>?) {
//     // if req == nil {
//     //     print("Error opening file")
//     //     return
//     // }

// }

uv_fs_open(loop, &open_req, "src/fibonacci.swift", O_RDONLY, 0, { req in 
    if let req = req {
        if req.pointee.result < 0 {
            print("Error opening file", req.pointee.result)
        } else {
            print("Result: \(req.pointee.result)")
            buffer = uv_buf_init(data_buf, 64)

            uv_fs_read(loop, &read_req, Int32(req.pointee.result), &buffer, 1, -1, on_read)
        }
    }

    uv_fs_req_cleanup(req)
})

uv_run(loop, UV_RUN_DEFAULT)
uv_loop_close(loop)

// let file = uv_fs_open()

// uv_loop

// InitWindow(800, 600, "Hello World")
// while !WindowShouldClose() {
//     BeginDrawing()
//     ClearBackground(Color(r: 0, g: 0, b: 0, a: 255))
//     DrawText("Congrats! You created your first window!", 190, 200, 20, Color(r: 255, g: 255, b: 255, a: 255))

//     EndDrawing()
// }
