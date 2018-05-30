/*
 * main.swift
 * find_unreferenced_xcode_files
 *
 * Created by François Lamboley on 30/05/2018.
 * Copyright © 2018 Frizlab. All rights reserved.
 */

import Foundation



func usage<TargetStream: TextOutputStream>(progname: String, stream: inout TargetStream) {
	print("""
		usage: \(progname) [-0] pbxproj_path
		
		Reads filenames from stdin and checks that each filename is defined in the given
		pbxproj file. If -0 is specified, expects the filenames to be separated by a NULL-char.
		""",
		to: &stream
	)
}

struct CLIError : Error {
	
	let code: Int32
	let message: String?
	
}

var expectsNull = false
let pbxprojPath: String
do {
	switch CommandLine.arguments.count {
	case 2: pbxprojPath = CommandLine.arguments[1]
	case 3: pbxprojPath = CommandLine.arguments[2]; expectsNull = true; guard CommandLine.arguments[1] == "-0" else {throw CLIError(code: 1, message: "syntax error")}
	default: throw CLIError(code: 1, message: "syntax error")
	}
} catch  {
	usage(progname: CommandLine.arguments[0], stream: &stderrStream)
	exit((error as? CLIError)?.code ?? 255)
}

print(pbxprojPath)
