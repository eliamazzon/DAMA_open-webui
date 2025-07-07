# File Type Icons: Visual Examples

This document shows how different file types are displayed with their respective colored icons in Open WebUI.

## Icon Color Scheme

### 📄 Document Files
- **PDF** (`.pdf`): 🔴 **Red** document icon
- **Word** (`.doc`, `.docx`): 🔵 **Blue** document icon  
- **Text** (`.txt`, `.rtf`): ⚫ **Gray** document icon

### 📊 Spreadsheet Files
- **Excel** (`.xls`, `.xlsx`): 🟢 **Green** chart icon
- **CSV** (`.csv`): 🟢 **Green** chart icon

### 💻 Code Files
- **Python** (`.py`): 🔵 **Blue** code icon
- **JavaScript** (`.js`): 🟡 **Yellow** code icon
- **TypeScript** (`.ts`): 🔷 **Dark Blue** code icon
- **HTML** (`.html`): 🟠 **Orange** code icon
- **CSS** (`.css`): 🔵 **Blue** code icon
- **JSON** (`.json`): ⚫ **Gray** code icon

### 🖼️ Image Files
- **All formats** (`.png`, `.jpg`, `.gif`, etc.): 🟣 **Purple** photo icon

### 📦 Archive Files
- **ZIP** (`.zip`): 🟡 **Yellow** archive icon
- **RAR** (`.rar`): 🔴 **Red** archive icon
- **TAR/GZ** (`.tar`, `.gz`): 🔵 **Blue** archive icon

## Example Tool Output

When a tool returns multiple file types, users will see:

```
┌─────────────────────────────────────────────────────────────┐
│ Tool Result: Data Analysis Complete                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ 📊 tool-result-1.csv (2.3 KB) [Green Chart Icon]          │
│    Click to download CSV data                              │
│                                                             │
│ 📄 tool-result-2.pdf (45.7 KB) [Red Document Icon]        │
│    Click to download PDF report                            │
│                                                             │
│ 💻 tool-result-3.py (1.2 KB) [Blue Code Icon]             │
│    Click to download Python script                         │
│                                                             │
│ 🖼️ [Inline Image Display] [Purple Photo Icon]             │
│    Chart visualization                                     │
│                                                             │
│ 📦 tool-result-4.zip (156 KB) [Yellow Archive Icon]       │
│    Click to download compressed data                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Implementation Details

### Icon Selection Logic

The system uses a two-step detection process:

1. **MIME Type Detection** (Primary)
   ```typescript
   // Extract MIME type from data URI
   const mimeType = "data:application/pdf;base64,...".match(/data:(.+);base64/)?.[1];
   // Result: "application/pdf"
   ```

2. **Extension Detection** (Fallback)
   ```typescript
   // Extract extension from filename
   const extension = "report.pdf".split('.').pop()?.toLowerCase();
   // Result: "pdf"
   ```

### Color Mapping

```typescript
const fileTypeColors = {
  // Documents
  pdf: 'bg-red-500',      // Red for PDFs
  doc: 'bg-blue-500',     // Blue for Word docs
  
  // Spreadsheets  
  xlsx: 'bg-green-500',   // Green for Excel
  csv: 'bg-green-500',    // Green for CSV
  
  // Code
  py: 'bg-blue-500',      // Blue for Python
  js: 'bg-yellow-500',    // Yellow for JavaScript
  
  // Images
  png: 'bg-purple-500',   // Purple for images
  
  // Archives
  zip: 'bg-yellow-600',   // Yellow for ZIP
  rar: 'bg-red-500'       // Red for RAR
};
```

### Icon Component Mapping

```typescript
const fileTypeIcons = {
  // Documents & Text
  pdf: Document,
  doc: Document,
  txt: Document,
  
  // Spreadsheets
  xlsx: DocumentChartBar,
  csv: DocumentChartBar,
  
  // Code
  py: Code,
  js: Code,
  html: Code,
  
  // Images
  png: Photo,
  jpg: Photo,
  
  // Archives
  zip: ArchiveBox,
  rar: ArchiveBox
};
```

## User Experience Benefits

### 1. **Instant Recognition**
Users can immediately identify file types without reading filenames:
- 🔴 Red = PDF documents
- 🟢 Green = Spreadsheets  
- 🔵 Blue = Code files
- 🟣 Purple = Images
- 🟡 Yellow = Archives

### 2. **Consistent Visual Language**
- Same file types always use the same colors
- Icons are semantically meaningful (chart for spreadsheets, code for scripts)
- Colors are accessible and have good contrast

### 3. **Reduced Cognitive Load**
- No need to parse file extensions
- Visual scanning is faster than text reading
- Grouped file types share visual characteristics

## Accessibility Considerations

### Color Blindness Support
- Colors are chosen to be distinguishable for common forms of color blindness
- Icons provide additional visual cues beyond just color
- Text labels are always present for screen readers

### Screen Reader Support
- Icons have proper alt text and ARIA labels
- File type information is conveyed through text as well as visuals
- Download actions are clearly labeled

## Customization Potential

The icon system is designed to be easily extensible:

```typescript
// Adding new file types
const newFileTypes = {
  // Custom file types
  'myapp': {
    icon: CustomIcon,
    bgColor: 'bg-indigo-500',
    textColor: 'text-indigo-500'
  }
};

// Theme customization
const darkTheme = {
  pdf: 'bg-red-600',    // Darker red for dark mode
  doc: 'bg-blue-600'    // Darker blue for dark mode
};
```

## Performance Notes

- Icons are pre-loaded and cached
- Color classes use Tailwind CSS for optimal performance
- File type detection is O(1) lookup time
- No additional network requests for icons

This enhancement significantly improves the user experience by making file types instantly recognizable and providing a more intuitive interface for managing tool-generated files. 