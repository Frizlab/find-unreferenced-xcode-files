# find_unreferenced_xcode_files
A helper to find unreferenced files in an Xcode project.

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
