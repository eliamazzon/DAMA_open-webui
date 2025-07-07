# File Preview Enhancement: PDF and Text File Previews

## Overview

This enhancement adds comprehensive file preview functionality to Open WebUI, allowing users to view PDFs and text-based files directly in the interface without downloading them. The preview system includes syntax highlighting for code files and proper handling of data URIs from tool results.

## What Was Enhanced

### Before
- Files could only be downloaded, not previewed
- No syntax highlighting for code files
- Limited file type support in the modal
- No preview for data URIs from tools

### After
- **PDF Preview**: Full PDF viewing with iframe integration
- **Text File Preview**: Plain text files with proper formatting
- **Code File Preview**: Syntax highlighting for 50+ programming languages
- **Data URI Support**: Preview files returned by tools as data URIs
- **Smart File Detection**: Automatic language detection for syntax highlighting

## Implementation Details

### Enhanced Components

#### `src/lib/components/common/FileItemModal.svelte`

**New Features Added:**

1. **Comprehensive File Type Detection**
   ```typescript
   // File type detection with multiple criteria
   const fileName = item.name?.toLowerCase() || '';
   const mimeType = item.mimeType || item?.meta?.content_type || '';
   
   // PDF detection
   isPdf = mimeType === 'application/pdf' || fileName.endsWith('.pdf');
   
   // Text file detection
   isTextFile = mimeType.startsWith('text/') || 
     ['.txt', '.md', '.csv', '.json', '.xml', '.yaml'].some(ext => fileName.endsWith(ext));
   
   // Code file detection
   isCodeFile = ['.py', '.js', '.ts', '.html', '.css', '.java', '.cpp'].some(ext => fileName.endsWith(ext));
   ```

2. **Data URI Processing**
   ```typescript
   // Extract and decode content from data URIs
   if (item?.file?.data?.content && item.file.data.content.startsWith('data:')) {
     const [header, base64Data] = item.file.data.content.split(',');
     const mimeTypeFromUri = header.match(/data:(.+);base64/)?.[1] || '';
     
     // Handle text-based files
     if (mimeTypeFromUri.startsWith('text/') || 
         mimeTypeFromUri === 'application/json' || 
         mimeTypeFromUri === 'application/xml') {
       const binaryString = atob(base64Data);
       fileContent = binaryString;
       fileLanguage = getLanguageFromFileName(fileName);
     }
     
     // Handle PDFs
     if (mimeTypeFromUri === 'application/pdf') {
       const blob = new Blob([Uint8Array.from(binaryString, (c) => c.charCodeAt(0))], {
         type: 'application/pdf'
       });
       pdfUrl = URL.createObjectURL(blob);
     }
   }
   ```

3. **Language Detection System**
   ```typescript
   // Comprehensive language mapping
   const languageMap = {
     // Code files
     'py': 'python', 'js': 'javascript', 'ts': 'typescript',
     'html': 'html', 'css': 'css', 'java': 'java', 'cpp': 'cpp',
     
     // Text files
     'txt': 'text', 'md': 'markdown', 'csv': 'csv',
     'json': 'json', 'xml': 'xml', 'yaml': 'yaml'
   };
   ```

4. **Enhanced Preview Rendering**
   ```svelte
   {#if isPdf}
     <!-- PDF preview with iframe -->
     <iframe src={pdfUrl} class="w-full h-[70vh]" />
   {:else if (isTextFile || isCodeFile) && fileContent}
     <!-- Code preview with syntax highlighting -->
     <CodeBlock
       lang={fileLanguage}
       code={fileContent}
       run={false}
       save={false}
       preview={false}
     />
   {:else}
     <!-- Fallback text display -->
     <div class="whitespace-pre-wrap">{item?.file?.data?.content}</div>
   {/if}
   ```

## Supported File Types

### 📄 PDF Files
- **Preview**: Full PDF viewing in iframe
- **Support**: Both server-hosted and data URI PDFs
- **Features**: Zoom, scroll, search (browser PDF controls)

### 📊 Excel Files
- **Formats**: `.xlsx`, `.xls`
- **Preview**: Multi-sheet table view with navigation
- **Features**: Sheet switching, responsive tables, row/column statistics

### 📝 Text Files
- **Formats**: `.txt`, `.md`, `.csv`, `.json`, `.xml`, `.yaml`, `.yml`, `.toml`, `.ini`, `.cfg`, `.conf`
- **Preview**: Plain text with proper formatting
- **Features**: Line numbers, syntax highlighting where applicable

### 💻 Code Files (50+ Languages)
- **Languages**: Python, JavaScript, TypeScript, HTML, CSS, Java, C++, C#, PHP, Ruby, Go, Rust, Swift, Kotlin, SQL, Bash, PowerShell, R, MATLAB, Scala, Clojure, Haskell, Elm, Vue, Svelte, Astro, Dart, Lua, Perl, Assembly, Fortran, and more
- **Preview**: Full syntax highlighting with CodeMirror
- **Features**: Language detection, code formatting, copy functionality

### 🎵 Audio Files
- **Formats**: `.mp3`, `.wav`, `.ogg`, `.m4a`, `.webm`
- **Preview**: Audio player with controls
- **Features**: Play, pause, seek, volume control

## How It Works

### 1. File Type Detection
The system uses a multi-layered approach to determine file types:

1. **MIME Type Priority**: Checks `item.mimeType` first (most accurate)
2. **File Extension**: Falls back to filename extension analysis
3. **Content Analysis**: Examines actual file content when available

### 2. Content Extraction
For data URIs from tool results:

```typescript
// Example data URI processing
const dataUri = "data:application/json;base64,eyJuYW1lIjoidGVzdCJ9";
const [header, base64Data] = dataUri.split(',');
const mimeType = header.match(/data:(.+);base64/)?.[1]; // "application/json"
const content = atob(base64Data); // '{"name":"test"}'
```

### 3. Preview Rendering
Different preview types are rendered based on file type:

- **PDFs**: `<iframe>` with blob URL or server URL
- **Excel**: `<table>` with sheet navigation and formatting
- **Code/Text**: `<CodeBlock>` with syntax highlighting
- **Audio**: `<audio>` element with controls
- **Fallback**: Plain text display

## User Experience

### File Preview Workflow
1. **Click File Item**: User clicks on a file in the chat
2. **Modal Opens**: FileItemModal displays with preview
3. **Content Loads**: File content is extracted and processed
4. **Preview Renders**: Appropriate preview component is shown
5. **User Interaction**: User can view, copy, or download the file

### Preview Features
- **Syntax Highlighting**: Code files display with proper syntax colors
- **Line Numbers**: Code blocks show line numbers for easy reference
- **Copy Functionality**: One-click copy of file content
- **Responsive Design**: Previews adapt to different screen sizes
- **Dark Mode Support**: Syntax highlighting adapts to theme

## Example Usage

### Tool Returning Multiple File Types
```python
def analysis_tool():
    return [
        "Analysis complete! Here are the results:",
        "data:application/pdf;base64,JVBERi0xLjQKJcOkw7zDtsO...",  # PDF preview
        "data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,UEsDBBQAAAAIAA...",  # Excel with table preview
        "data:application/json;base64,eyJuYW1lIjoidGVzdCJ9",      # JSON with syntax highlighting
        "data:text/csv;base64,bmFtZSx2YWx1ZQphLDEKYiwyCg==",      # CSV with formatting
        "data:text/x-python;base64,cHJpbnQoIkhlbGxvIikK"          # Python with syntax highlighting
    ]
```

**Result:**
- PDF displays in iframe with full browser PDF controls
- Excel shows with multi-sheet navigation and formatted tables
- JSON shows with syntax highlighting and proper formatting
- CSV displays in a readable table format
- Python code shows with syntax highlighting and line numbers

## Technical Implementation

### Memory Management
- **Blob URLs**: Created for PDFs and cleaned up properly
- **Base64 Decoding**: Only performed when preview is actually opened
- **Content Caching**: File content is cached during modal session

### Performance Optimizations
- **Lazy Loading**: Content is only processed when modal opens
- **Efficient Detection**: File type detection uses O(1) lookups
- **Minimal Re-renders**: Reactive statements only trigger on relevant changes

### Error Handling
- **Graceful Fallbacks**: If preview fails, shows error message
- **Content Validation**: Checks for valid data URIs before processing
- **Language Fallback**: Unknown file types default to plain text

## Benefits

1. **Enhanced User Experience**: No need to download files to view content
2. **Faster Workflow**: Instant preview of tool results
3. **Better Code Review**: Syntax highlighting makes code easier to read
4. **Reduced Downloads**: Users can view files without saving them
5. **Consistent Interface**: All file types handled uniformly
6. **Accessibility**: Proper ARIA labels and keyboard navigation

## Future Enhancements

Potential improvements could include:
- **Image Preview**: Thumbnail generation for image files
- **Document Preview**: Rich text preview for Word documents
- **Video Preview**: Video player for video files
- **3D Model Preview**: WebGL viewer for 3D model files
- **Custom Preview Plugins**: Extensible preview system for custom file types

## Integration with Existing Features

The preview system integrates seamlessly with:
- **File Type Icons**: Colored icons help identify file types before preview
- **Download Functionality**: Users can still download files after previewing
- **Tool Results**: Works with all data URIs returned by tools
- **Chat Interface**: Previews appear in the same modal system as other file interactions

This enhancement significantly improves the user experience by providing immediate access to file content without the need for downloads, while maintaining all existing functionality. 