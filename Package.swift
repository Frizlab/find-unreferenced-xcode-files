// swift-tools-version:5.2
import PackageDescription


let package = Package(
	name: "find-unreferenced-xcode-files",
	products: [
		.executable(name: "find-unreferenced-xcode-files", targets: ["find-unreferenced-xcode-files"])
	],
	dependencies: [
		.package(url: "https://github.com/Frizlab/stream-reader.git", from: "3.0.0-rc.3")
	],
	targets: [
		.target(name: "find-unreferenced-xcode-files", dependencies: [
			.product(name: "StreamReader", package: "stream-reader")
		])
	]
)
