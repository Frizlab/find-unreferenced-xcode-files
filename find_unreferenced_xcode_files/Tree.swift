/*
 * Tree.swift
 * find_unreferenced_xcode_files
 *
 * Created by François Lamboley on 30/05/2018.
 * Copyright © 2018 Frizlab. All rights reserved.
 */

import Foundation



class XcodeNode {
	
	class func from(reference: String, in pbxprojObjects: [String: Any]) -> XcodeNode? {
		guard let object = pbxprojObjects[reference] as? [String: Any] else {return nil}
		
		switch object["isa"] as? String {
		case "PBXGroup", "PBXVariantGroup": return Group(pbxprojObject: object, pbxprojObjects: pbxprojObjects)
		case "PBXFileReference":            return FileReference(pbxprojObject: object, pbxprojObjects: pbxprojObjects)
		default:                            return nil
		}
	}
	
	func getFilePaths(prefix: String) -> [String] {
		fatalError("abstract method")
	}
	
}

class Group : XcodeNode {
	
	private(set) var relativePath: String?
	private(set) var children = [XcodeNode]()
	
	init?(pbxprojObject object: [String: Any], pbxprojObjects: [String: Any]) {
		guard let isa = object["isa"] as? String, (isa == "PBXGroup" || isa == "PBXVariantGroup") else {return nil}
		
		guard let p = object["path"] as? String? else {return nil}
		guard let c = object["children"] as? [String] else {return nil}
		
		relativePath = p
		children = c.compactMap{ XcodeNode.from(reference: $0, in: pbxprojObjects) }
		
		super.init()
	}
	
	override func getFilePaths(prefix: String) -> [String] {
		return children.flatMap{ $0.getFilePaths(prefix: (prefix as NSString).appendingPathComponent(relativePath ?? "")) }
	}
	
}

class FileReference : XcodeNode {
	
	private(set) var relativePath: String
    private(set) var sourceTree: String?
	
	init?(pbxprojObject object: [String: Any], pbxprojObjects: [String: Any]) {
		guard object["isa"] as? String == "PBXFileReference" else {return nil}
		
		guard let p = object["path"] as? String else {return nil}
		relativePath = p

		super.init()
	}
	
	override func getFilePaths(prefix: String) -> [String] {
        if sourceTree == "SOURCE_ROOT" {
            return [relativePath]
        }else {
            return [(prefix as NSString).appendingPathComponent(relativePath)]
        }
	}
	
}
