/*
 * main.swift
 * find-unreferenced-xcode-files
 *
 * Created by François Lamboley on 30/05/2018.
 * Copyright © 2018 Frizlab. All rights reserved.
 */

import Foundation

import StreamReader
import SystemPackage



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
	let showUsage: Bool
	
}

do {
	var expectsNull = false
	let pbxprojPath: String
	switch CommandLine.arguments.count {
	case 2: pbxprojPath = CommandLine.arguments[1]
	case 3: pbxprojPath = CommandLine.arguments[2]; expectsNull = true; guard CommandLine.arguments[1] == "-0" else {throw CLIError(code: 1, message: "syntax error", showUsage: true)}
	default: throw CLIError(code: 1, message: "syntax error", showUsage: true)
	}
	
	let pbxprojData = try Data(contentsOf: URL(fileURLWithPath: pbxprojPath, isDirectory: false))
	let pbxproj = try PropertyListSerialization.propertyList(from: pbxprojData, options: [], format: nil) as? [String: Any]
	guard
		let pbxprojRoot = pbxproj?["rootObject"] as? String,
		let pbxprojObjects = pbxproj?["objects"] as? [String: Any],
		let mainGroupId = (pbxprojObjects[pbxprojRoot] as? [String: Any])?["mainGroup"] as? String,
		let mainGroup = pbxprojObjects[mainGroupId] as? [String: Any],
		let filepathsArray = Group(pbxprojObject: mainGroup, pbxprojObjects: pbxprojObjects)?.getFilePaths(prefix: ".")
	else {
		throw NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unexpected file format"])
	}
	
	let fileURLsSet = Set(filepathsArray.map{ path -> URL in
		return URL(fileURLWithPath: path).absoluteURL
	})
	
	/* Funnily enough, using a FileHandle stream reader will block when using a
	 * Terminal and sending the paths manually until ctrl-D has been sent, but w/
	 * a FileDescriptor stream reader we have no issue. Of course when sending
	 * through a pipe or other, both solutions work. */
	let fileDescriptor = FileDescriptor(rawValue: FileHandle.standardInput.fileDescriptor /* FileDescriptor.standardInput does not exist in 0.0.1 */)
	let streamReader = FileDescriptorReader(stream: fileDescriptor, bufferSize: 1024, bufferSizeIncrement: 512, readSizeLimit: nil)
	while try !streamReader.hasReachedEOF() {
		let e = try streamReader.readData(upTo: [expectsNull ? Data([0]) : Data("\n".utf8)], matchingMode: .anyMatchWins, failIfNotFound: true, includeDelimiter: false)
		_ = try streamReader.readData(size: e.delimiter.count) /* Read the delimiter */
		guard !e.data.isEmpty else {continue}
		guard let p = String(data: e.data, encoding: .utf8) else {continue}
		if !fileURLsSet.contains(URL(fileURLWithPath: p).absoluteURL) {print(p)}
	}
} catch let error as CLIError {
	if let msg = error.message {print("error: \(msg)", to: &stderrStream)}
	if error.showUsage {usage(progname: CommandLine.arguments[0], stream: &stderrStream)}
	exit(error.code)
} catch {
	print("unknown error: \(error.localizedDescription)", to: &stderrStream)
	exit(255)
}
