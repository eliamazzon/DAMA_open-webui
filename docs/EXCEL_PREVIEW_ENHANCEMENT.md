# Excel File Preview Enhancement

## Overview

This enhancement adds Excel file preview functionality to Open WebUI, allowing users to view Excel spreadsheets (.xlsx, .xls) directly in the interface without downloading them. The preview system includes multi-sheet support, table formatting, and proper handling of data URIs from tool results.

## What Was Added

### Excel File Preview Features

1. **Multi-Sheet Support**: View and switch between different sheets in Excel workbooks
2. **Table Formatting**: Clean, responsive table display with proper headers and data
3. **Data URI Support**: Preview Excel files returned by tools as data URIs
4. **File Type Detection**: Automatic detection of Excel files by MIME type and extension
5. **Statistics Display**: Show row and column counts for each sheet

## Implementation Details

### Enhanced Components

#### `src/lib/components/common/FileItemModal.svelte`

**New Features Added:**

1. **Excel File Detection**
   ```typescript
   // Excel file detection with MIME types and extensions
   isExcelFile = mimeType === 'application/vnd.ms-excel' || 
     mimeType === 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ||
     ['.xls', '.xlsx'].some(ext => fileName.endsWith(ext));
   ```

2. **Excel Data Processing**
   ```typescript
   // Parse Excel files from data URIs
   if (mimeTypeFromUri === 'application/vnd.ms-excel' || 
       mimeTypeFromUri === 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') {
     try {
       const binaryString = atob(base64Data);
       const arrayBuffer = Uint8Array.from(binaryString, (c) => c.charCodeAt(0)).buffer;
       const workbook = XLSX.read(arrayBuffer, { type: 'array' });
       
       excelData = workbook;
       excelSheets = workbook.SheetNames.map((name, index) => ({
         name,
         index,
         data: XLSX.utils.sheet_to_json(workbook.Sheets[name], { header: 1 })
       }));
     } catch (error) {
       console.error('Error parsing Excel file:', error);
     }
   }
   ```

3. **Excel Preview Rendering**
   ```svelte
   {#if isExcelFile && excelSheets.length > 0}
     <!-- Excel preview with multiple sheets -->
     <div class="mt-4">
       <!-- Sheet selector dropdown -->
       <select bind:value={activeSheet}>
         {#each excelSheets as sheet, index}
           <option value={index}>{sheet.name}</option>
         {/each}
       </select>
       
       <!-- Data table -->
       <table class="min-w-full border">
         <thead>
           <tr>
             {#each excelSheets[activeSheet].data[0] as cell}
               <th>{cell || ''}</th>
             {/each}
           </tr>
         </thead>
         <tbody>
           {#each excelSheets[activeSheet].data.slice(1) as row}
             <tr>
               {#each row as cell}
                 <td>{cell || ''}</td>
               {/each}
             </tr>
           {/each}
         </tbody>
       </table>
       
       <!-- Statistics -->
       <div class="text-sm text-gray-500">
         {excelSheets[activeSheet].data.length} rows, {excelSheets[activeSheet].data[0].length} columns
       </div>
     </div>
   {/if}
   ```

## Supported Excel Formats

### File Types
- **`.xlsx`**: Modern Excel format (Excel 2007+)
- **`.xls`**: Legacy Excel format (Excel 97-2003)

### MIME Types
- `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet` (for .xlsx)
- `application/vnd.ms-excel` (for .xls)

## User Experience

### Excel Preview Workflow
1. **Click Excel File**: User clicks on an Excel file in the chat
2. **Modal Opens**: FileItemModal displays with Excel preview
3. **Sheet Selection**: User can choose which sheet to view from dropdown
4. **Table Display**: Excel data is shown in a formatted table
5. **Statistics**: Row and column counts are displayed
6. **Navigation**: User can switch between sheets easily

### Preview Features
- **Multi-Sheet Navigation**: Dropdown to switch between sheets
- **Responsive Table**: Horizontal scrolling for wide tables
- **Header Row**: First row is displayed as table headers
- **Alternating Rows**: Zebra striping for better readability
- **Dark Mode Support**: Table styling adapts to theme
- **Statistics**: Shows data dimensions for each sheet

## Example Usage

### Tool Returning Excel File
```python
def generate_report():
    import pandas as pd
    from openpyxl import Workbook
    import base64
    import io
    
    # Create sample data
    data = {
        'Name': ['John', 'Jane', 'Bob'],
        'Age': [25, 30, 35],
        'Department': ['IT', 'HR', 'Sales']
    }
    df = pd.DataFrame(data)
    
    # Create Excel file
    output = io.BytesIO()
    with pd.ExcelWriter(output, engine='openpyxl') as writer:
        df.to_excel(writer, sheet_name='Employees', index=False)
        df.to_excel(writer, sheet_name='Summary', index=False)
    
    # Convert to data URI
    excel_data = base64.b64encode(output.getvalue()).decode()
    data_uri = f"data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,{excel_data}"
    
    return [
        "Report generated successfully!",
        data_uri
    ]
```

**Result:**
- Excel file opens in preview modal
- Two sheets available: "Employees" and "Summary"
- User can switch between sheets using dropdown
- Data displayed in formatted table with headers
- Statistics show "3 rows, 3 columns" for each sheet

## Visual Example

When a user clicks on an Excel file:

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

## Technical Implementation

### Dependencies
- **xlsx**: JavaScript library for parsing Excel files
- **Base64 Decoding**: Converts data URIs to binary data
- **ArrayBuffer**: Handles binary Excel file data

### Memory Management
- **Efficient Parsing**: Only parses Excel data when preview is opened
- **Sheet Caching**: Parsed sheet data is cached during modal session
- **Cleanup**: Proper memory cleanup when modal closes

### Performance Optimizations
- **Lazy Loading**: Excel parsing only occurs when needed
- **Sheet-by-Sheet**: Only active sheet data is rendered
- **Virtual Scrolling**: Large tables can be optimized with virtual scrolling

## Benefits

1. **Instant Preview**: No need to download Excel files to view content
2. **Multi-Sheet Support**: View all sheets in a workbook
3. **Clean Formatting**: Professional table display
4. **Data URI Support**: Works with tool-generated Excel files
5. **Responsive Design**: Adapts to different screen sizes
6. **Accessibility**: Proper table structure and ARIA labels

## Integration with Existing Features

The Excel preview integrates seamlessly with:
- **File Type Icons**: Green chart icon identifies Excel files
- **Download Functionality**: Users can still download files after previewing
- **Tool Results**: Works with all Excel data URIs returned by tools
- **Chat Interface**: Previews appear in the same modal system

## Future Enhancements

Potential improvements could include:
- **Cell Formatting**: Support for bold, italic, colors, etc.
- **Formula Display**: Show calculated values
- **Chart Preview**: Display embedded charts and graphs
- **Filtering/Sorting**: Interactive table features
- **Export Options**: Export to CSV or other formats
- **Large File Handling**: Virtual scrolling for very large spreadsheets

This enhancement significantly improves the user experience for working with Excel files, making it easy to view spreadsheet data without requiring external applications or downloads. 