# Tool Files Enhancement: Non-Image Data URI Support

## Overview

This enhancement extends the `Collapsible.svelte` component to handle non-image data URIs returned by tools, making them downloadable as files through the UI. It also adds **file type-specific icons with colors** to make file identification more intuitive.

## What Was Enhanced

### Before
- Only image data URIs (`data:image/*`) were automatically displayed in tool results
- Non-image files returned by tools were not visible or downloadable
- All files used the same generic document icon

### After
- **All data URIs** are now handled and displayed as downloadable files
- Images continue to display inline as before
- Non-image files appear as clickable FileItem components that trigger downloads
- **File type-specific icons with colors** for better visual identification:
  - 📄 **PDF files**: Red document icon
  - 📊 **Excel/CSV files**: Green chart icon  
  - 💻 **Code files**: Blue code icon
  - 🖼️ **Image files**: Purple photo icon
  - 📦 **Archive files**: Yellow archive icon
  - 📝 **Text files**: Gray document icon

## Implementation Details

### Enhanced Components

#### `src/lib/components/common/FileItem.svelte`

**New Features Added:**

1. **File Type Detection System**
   - `getFileTypeInfo(fileName: string, mimeType?: string)` function
   - Detects file types by both filename extension and MIME type
   - Returns appropriate icon component and color scheme

2. **File Type Icons & Colors**
   ```typescript
   const fileTypes = {
     // Documents
     pdf: { icon: Document, bgColor: 'bg-red-500', textColor: 'text-red-500' },
     doc: { icon: Document, bgColor: 'bg-blue-500', textColor: 'text-blue-500' },
     
     // Spreadsheets  
     xlsx: { icon: DocumentChartBar, bgColor: 'bg-green-500', textColor: 'text-green-500' },
     csv: { icon: DocumentChartBar, bgColor: 'bg-green-500', textColor: 'text-green-500' },
     
     // Code files
     py: { icon: Code, bgColor: 'bg-blue-500', textColor: 'text-blue-500' },
     js: { icon: Code, bgColor: 'bg-yellow-500', textColor: 'text-yellow-500' },
     
     // Images
     png: { icon: Photo, bgColor: 'bg-purple-500', textColor: 'text-purple-500' },
     
     // Archives
     zip: { icon: ArchiveBox, bgColor: 'bg-yellow-600', textColor: 'text-yellow-600' }
   };
   ```

3. **Dynamic Icon Rendering**
   ```svelte
   <div class="p-3 {fileTypeInfo.bgColor} text-white rounded-xl">
     <svelte:component this={fileTypeInfo.icon} className="size-5" />
   </div>
   ```

#### `src/lib/components/common/Collapsible.svelte`

**Enhanced Functions:**

1. **`dataUriToFileInfo(dataUri: string, index: number)`**
   - Now includes MIME type extraction for better file type detection
   - Passes MIME type information to FileItem component

2. **`downloadDataUri(dataUri: string, fileName: string)`**
   - Handles direct download of data URI content
   - Converts base64 to blob and triggers browser download
   - Properly cleans up blob URLs after download

3. **`isImageDataUri(dataUri: string): boolean`**
   - Utility function to check if a data URI represents an image
   - Used to determine whether to display as Image or FileItem

**Enhanced Template Logic:**
```svelte
{#each files ?? [] as file, idx}
    {#if isImageDataUri(file)}
        <!-- Display as image (existing behavior) -->
        <Image src={file} alt="Image" />
    {:else if file.startsWith('data:')}
        <!-- Display as downloadable file with type-specific icon -->
        {@const fileInfo = dataUriToFileInfo(file, idx)}
        {#if fileInfo}
            <FileItem
                name={fileInfo.name}
                type={fileInfo.type}
                size={fileInfo.size}
                url={fileInfo.url}
                item={fileInfo.item}
                on:click={() => downloadDataUri(file, fileInfo.name)}
            />
        {/if}
    {/if}
{/each}
```

## How It Works

### 1. Tool Response Processing
When a tool returns files in its response, the backend processes them as described in the existing documentation:

```python
# Backend automatically extracts data URIs from tool results
tool_result_files = []
if isinstance(tool_result, list):
    for item in tool_result:
        if isinstance(item, str) and item.startswith("data:"):
            tool_result_files.append(item)
            tool_result.remove(item)
```

### 2. Frontend Rendering with Icons
The enhanced components now:

1. **Detects file types**: Uses both MIME type and filename extension
2. **Selects appropriate icons**: Maps file types to specific icon components
3. **Applies color schemes**: Uses consistent colors for each file type category
4. **Renders with styling**: Displays colored icon backgrounds with white icons
5. **Handles downloads**: Uses `downloadDataUri()` to convert data URIs to downloadable blobs

### 3. File Type Detection Priority
1. **MIME type first**: Extracted from data URI header (most accurate)
2. **Extension fallback**: Uses filename extension if MIME type not recognized
3. **Default fallback**: Generic document icon with gray color

## File Type Icons & Colors

### Document Files
- **PDF** (`.pdf`): 📄 Red document icon
- **Word** (`.doc`, `.docx`): 📄 Blue document icon  
- **Text** (`.txt`, `.rtf`): 📄 Gray document icon

### Spreadsheet Files
- **Excel** (`.xls`, `.xlsx`): 📊 Green chart icon
- **CSV** (`.csv`): 📊 Green chart icon

### Code Files
- **Python** (`.py`): 💻 Blue code icon
- **JavaScript** (`.js`): 💻 Yellow code icon
- **TypeScript** (`.ts`): 💻 Dark blue code icon
- **HTML** (`.html`): 💻 Orange code icon
- **CSS** (`.css`): 💻 Blue code icon
- **JSON** (`.json`): 💻 Gray code icon

### Image Files
- **All formats** (`.png`, `.jpg`, `.gif`, etc.): 🖼️ Purple photo icon

### Archive Files
- **ZIP** (`.zip`): 📦 Yellow archive icon
- **RAR** (`.rar`): 📦 Red archive icon
- **TAR/GZ** (`.tar`, `.gz`): 📦 Blue archive icon

## Usage Examples

### Tool Returning Multiple File Types
```python
def my_tool():
    return [
        "Analysis complete",
        "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA...",  # Purple photo icon
        "data:application/pdf;base64,JVBERi0xLjQKJcOkw7zDtsO...",  # Red document icon
        "data:text/csv;base64,bmFtZSx2YWx1ZQphLDEKYiwyCg=="  # Green chart icon
    ]
```

**Result:**
- The image displays inline with purple photo icon
- The PDF appears as a downloadable file with red document icon
- The CSV appears as a downloadable file with green chart icon

## Benefits

1. **Complete File Support**: All file types returned by tools are now accessible
2. **Visual File Identification**: Color-coded icons make file types instantly recognizable
3. **Consistent UI**: Uses existing FileItem component for familiar user experience
4. **Automatic Filename Generation**: Creates meaningful filenames based on MIME type
5. **Proper Download Handling**: Converts data URIs to downloadable blobs
6. **Backward Compatibility**: Existing image functionality remains unchanged
7. **Enhanced UX**: Users can quickly identify file types at a glance

## Technical Notes

- **Memory Management**: Blob URLs are properly cleaned up after downloads
- **Error Handling**: Graceful fallback if data URI parsing fails
- **Performance**: Base64 decoding only happens when files are actually displayed
- **Accessibility**: Maintains existing accessibility features of FileItem components
- **Icon Consistency**: Uses existing icon components from the design system
- **Color Accessibility**: Colors are chosen for good contrast and accessibility

## Future Enhancements

Potential improvements could include:
- File preview for supported formats (PDF, text, etc.)
- Batch download functionality for multiple files
- Custom filename support from tool responses
- File type icons based on MIME type
- Progress indicators for large file downloads
- Hover tooltips showing file type information
- Custom icon themes or user preferences 