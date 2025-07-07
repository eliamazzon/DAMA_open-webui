# File Preview Example

This document demonstrates how the new file preview functionality works with different file types in Open WebUI.

## Example Tool Response

When a tool returns multiple files as data URIs, each file will be displayed with appropriate preview functionality:

### 1. PDF Document
```json
{
  "type": "file",
  "name": "report.pdf",
  "mimeType": "application/pdf",
  "content": "data:application/pdf;base64,JVBERi0xLjQKJcOkw7zDtsO..."
}
```

**Preview Result:**
- Opens in iframe with full PDF viewer
- Browser PDF controls (zoom, scroll, search)
- No download required to view content

### 2. Excel Spreadsheet
```json
{
  "type": "file", 
  "name": "report.xlsx",
  "mimeType": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
  "content": "data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,UEsDBBQAAAAIAA..."
}
```

**Preview Result:**
- Multi-sheet navigation with dropdown
- Formatted table with headers
- Row and column statistics
- Responsive design with horizontal scrolling

### 3. JSON Configuration
```json
{
  "type": "file", 
  "name": "config.json",
  "mimeType": "application/json",
  "content": "data:application/json;base64,eyJzZXJ2ZXIiOiJsb2NhbGhvc3QiLCJwb3J0Ijo4MDgwLCJkZWJ1ZyI6dHJ1ZX0="
}
```

**Preview Result:**
- Syntax highlighting for JSON
- Proper formatting and indentation
- Copy functionality available
- Language detected as "json"

### 4. Python Script
```json
{
  "type": "file",
  "name": "analysis.py", 
  "mimeType": "text/x-python",
  "content": "data:text/x-python;base64,cHJpbnQoIkhlbGxvLCBXb3JsZCEiKQoKaW1wb3J0IGpzb24KaW1wb3J0IHBhbmRhcyBhcyBwZAoKZGVmIGFuYWx5emVfZGF0YShkYXRhKToKICAgIHJldHVybiBwZC5yZWFkX2pzb24oZGF0YSkK"
}
```

**Preview Result:**
- Syntax highlighting for Python
- Line numbers displayed
- Code formatting preserved
- Language detected as "python"

### 5. CSV Data
```json
{
  "type": "file",
  "name": "data.csv",
  "mimeType": "text/csv", 
  "content": "data:text/csv;base64,TmFtZSxBZ2UsQ2l0eQpKb2huLDI1LE5ldyBZb3JrCkphbmUsMzAsQ2hpY2FnbwpCb2IsMzUsQm9zdG9uCg=="
}
```

**Preview Result:**
- CSV formatting with proper column alignment
- Readable table structure
- Language detected as "csv"

### 6. Markdown Documentation
```json
{
  "type": "file",
  "name": "README.md",
  "mimeType": "text/markdown",
  "content": "data:text/markdown;base64,IyBNeSBQcm9qZWN0CgpUaGlzIGlzIGEgZGVzY3JpcHRpb24gb2YgbXkgcHJvamVjdC4KCiMjIEluc3RhbGxhdGlvbgoKQ2xvbmUgdGhlIHJlcG9zaXRvcnkgYW5kIGluc3RhbGw6CgpgYGBiYXNoCnBpcCBpbnN0YWxsIC1yIHJlcXVpcmVtZW50cy50eHQKYGBgCg=="
}
```

**Preview Result:**
- Markdown syntax highlighting
- Proper formatting for headers, code blocks
- Language detected as "markdown"

## Visual Example

When a user clicks on any of these files in the chat interface:

```
┌─────────────────────────────────────────────────────────────┐
│ 📄 report.pdf                                    [×]        │
│ Size: 245 KB • PDF file                                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ PDF Viewer (iframe)                                    │ │
│  │ [Zoom] [Search] [Download] [Print]                     │ │
│  │                                                         │ │
│  │ ┌─────────────────────────────────────────────────────┐ │ │
│  │ │                                                     │ │
│  │ │  Page 1 of 5                                        │ │
│  │ │  ┌─────────────────────────────────────────────────┐ │ │ │
│  │ │  │                                                 │ │ │
│  │ │  │  Report Content                                 │ │ │
│  │ │  │  • Introduction                                 │ │ │
│  │ │  │  • Methodology                                  │ │ │
│  │ │  │  • Results                                      │ │ │
│  │ │  │  • Conclusion                                   │ │ │
│  │ │  │                                                 │ │ │
│  │ │  └─────────────────────────────────────────────────┘ │ │
│  │ │                                                     │ │
│  │ └─────────────────────────────────────────────────────┘ │ │
│  │                                                         │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

For Excel files:

```
┌─────────────────────────────────────────────────────────────┐
│ 📊 report.xlsx                                   [×]        │
│ Size: 15.2 KB • Excel file • 2 sheets                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Sheet: [Employees ▼]                                       │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ Name  │ Age │ Department │                              │ │
│  ├───────┼─────┼────────────┤                              │ │
│  │ John  │ 25  │ IT         │                              │ │
│  │ Jane  │ 30  │ HR         │                              │ │
│  │ Bob   │ 35  │ Sales      │                              │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  3 rows, 3 columns                                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

For code files:

```
┌─────────────────────────────────────────────────────────────┐
│ 💻 analysis.py                                   [×]        │
│ Size: 1.2 KB • 15 lines • python file                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ python                                                 │ │
│  │ [Copy] [Save]                                          │ │
│  ├─────────────────────────────────────────────────────────┤ │
│  │ 1  │ print("Hello, World!")                            │ │
│  │ 2  │                                                   │ │
│  │ 3  │ import json                                       │ │
│  │ 4  │ import pandas as pd                               │ │
│  │ 5  │                                                   │ │
│  │ 6  │ def analyze_data(data):                           │ │
│  │ 7  │     return pd.read_json(data)                     │ │
│  │ 8  │                                                   │ │
│  │ 9  │ # Example usage                                   │ │
│  │ 10 │ data = '{"name": "test"}'                         │ │
│  │ 11 │ result = analyze_data(data)                       │ │
│  │ 12 │ print(result)                                     │ │
│  │ 13 │                                                   │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Supported File Extensions

### Code Files (with syntax highlighting)
- `.py` - Python
- `.js` - JavaScript  
- `.ts` - TypeScript
- `.jsx` - React JSX
- `.tsx` - React TSX
- `.html` - HTML
- `.css` - CSS
- `.scss` - SCSS
- `.sass` - Sass
- `.less` - Less
- `.java` - Java
- `.cpp` - C++
- `.c` - C
- `.cs` - C#
- `.php` - PHP
- `.rb` - Ruby
- `.go` - Go
- `.rs` - Rust
- `.swift` - Swift
- `.kt` - Kotlin
- `.sql` - SQL
- `.sh` - Bash
- `.bash` - Bash
- `.ps1` - PowerShell
- `.r` - R
- `.m` - MATLAB
- `.scala` - Scala
- `.clj` - Clojure
- `.hs` - Haskell
- `.elm` - Elm
- `.vue` - Vue
- `.svelte` - Svelte
- `.astro` - Astro
- `.dart` - Dart
- `.lua` - Lua
- `.pl` - Perl
- `.perl` - Perl
- `.asm` - Assembly
- `.s` - Assembly
- `.h` - C Header
- `.hpp` - C++ Header
- `.cc` - C++
- `.cxx` - C++
- `.mm` - Objective-C++
- `.f` - Fortran
- `.f90` - Fortran
- `.f95` - Fortran
- `.f03` - Fortran

### Text Files
- `.txt` - Plain Text
- `.md` - Markdown
- `.csv` - CSV
- `.json` - JSON
- `.xml` - XML
- `.yaml` - YAML
- `.yml` - YAML
- `.toml` - TOML
- `.ini` - INI
- `.cfg` - Config
- `.conf` - Config

### Binary Files (download only)
- `.pdf` - PDF (preview in iframe)
- `.mp3` - Audio (preview with player)
- `.wav` - Audio (preview with player)
- `.ogg` - Audio (preview with player)
- `.m4a` - Audio (preview with player)
- `.webm` - Audio (preview with player)

## Benefits

1. **Instant Preview**: No need to download files to see content
2. **Syntax Highlighting**: Code files are easier to read and understand
3. **Proper Formatting**: Text files display with correct formatting
4. **File Type Detection**: Automatic language detection for syntax highlighting
5. **Data URI Support**: Works seamlessly with tool-generated files
6. **Consistent Interface**: All file types handled uniformly

This enhancement makes Open WebUI much more user-friendly for working with files returned by tools and AI assistants. 