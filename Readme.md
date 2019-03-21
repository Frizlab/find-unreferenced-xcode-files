# find_unreferenced_xcode_files
A helper to find unreferenced files in an Xcode project.

## Installation
You can install the project via Homebrew with:
```bash
brew install frizlab/perso/find_unreferenced_xcode_files
```

## Example of Use
```bash
project_name=MyAwesomeProject

find . \
   \( -name "*.swift" -o -name "*.h" -o -name "*.m" -o -name "*.c" \) \
   -a ! -path "*/.git/*" \
   -a ! -path "*/Carthage/*" \
   -print0 | \
   find_unreferenced_xcode_files -0 "./$project_name.xcodeproj/project.pbxproj"
```
