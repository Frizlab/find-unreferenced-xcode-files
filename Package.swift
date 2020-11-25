// swift-tools-version:5.2
import PackageDescription


let package = Package(
	name: "find-unreferenced-xcode-files",
	products: [
		.executable(name: "find-unreferenced-xcode-files", targets: ["find-unreferenced-xcode-files"])
	],
	dependencies: [
		.package(url: "https://github.com/Frizlab/SimpleStream.git", from: "2.1.0")
	],
	targets: [
		.target(name: "find-unreferenced-xcode-files", dependencies: [
			.product(name: "SimpleStream", package: "SimpleStream")
		])
	]
)
