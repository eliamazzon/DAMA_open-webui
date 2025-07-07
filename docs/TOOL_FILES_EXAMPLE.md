# Tool Files Enhancement: Example Implementation

This document provides practical examples of how to create tools that return files and how they will be displayed in Open WebUI.

## Example 1: Data Analysis Tool

Here's an example of a tool that performs data analysis and returns multiple file types:

```python
import pandas as pd
import matplotlib.pyplot as plt
import base64
import io
import json

def analyze_data_tool(data_input):
    """
    A tool that analyzes data and returns multiple file types:
    - CSV data file
    - PNG chart image
    - JSON report
    """
    
    # Simulate data processing
    df = pd.DataFrame({
        'category': ['A', 'B', 'C', 'D'],
        'value': [10, 20, 15, 25]
    })
    
    # Create CSV file
    csv_buffer = io.StringIO()
    df.to_csv(csv_buffer, index=False)
    csv_data = csv_buffer.getvalue()
    csv_base64 = base64.b64encode(csv_data.encode()).decode()
    csv_uri = f"data:text/csv;base64,{csv_base64}"
    
    # Create chart image
    plt.figure(figsize=(8, 6))
    df.plot(kind='bar', x='category', y='value')
    plt.title('Data Analysis Chart')
    plt.tight_layout()
    
    # Convert plot to base64
    img_buffer = io.BytesIO()
    plt.savefig(img_buffer, format='png', dpi=100)
    img_buffer.seek(0)
    img_base64 = base64.b64encode(img_buffer.getvalue()).decode()
    img_uri = f"data:image/png;base64,{img_base64}"
    plt.close()
    
    # Create JSON report
    report = {
        'summary': 'Data analysis completed successfully',
        'total_records': len(df),
        'average_value': df['value'].mean(),
        'max_value': df['value'].max(),
        'min_value': df['value'].min()
    }
    json_data = json.dumps(report, indent=2)
    json_base64 = base64.b64encode(json_data.encode()).decode()
    json_uri = f"data:application/json;base64,{json_base64}"
    
    return [
        "Data analysis completed! Here are the results:",
        csv_uri,    # Will appear as downloadable CSV file
        img_uri,    # Will display as inline image
        json_uri    # Will appear as downloadable JSON file
    ]
```

## Example 2: Document Generation Tool

```python
import base64
import io
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter

def generate_report_tool(title, content):
    """
    A tool that generates a PDF report and returns it as a data URI
    """
    
    # Create PDF in memory
    buffer = io.BytesIO()
    p = canvas.Canvas(buffer, pagesize=letter)
    
    # Add content to PDF
    p.setFont("Helvetica-Bold", 16)
    p.drawString(100, 750, title)
    
    p.setFont("Helvetica", 12)
    y_position = 700
    for line in content.split('\n'):
        if y_position < 50:  # New page if needed
            p.showPage()
            y_position = 750
        p.drawString(100, y_position, line)
        y_position -= 20
    
    p.save()
    
    # Convert to base64
    buffer.seek(0)
    pdf_base64 = base64.b64encode(buffer.getvalue()).decode()
    pdf_uri = f"data:application/pdf;base64,{pdf_base64}"
    
    return [
        f"Report '{title}' generated successfully!",
        pdf_uri  # Will appear as downloadable PDF file
    ]
```

## Example 3: Code Generation Tool

```python
import base64

def generate_code_tool(language, functionality):
    """
    A tool that generates code files in different languages
    """
    
    # Example code templates
    templates = {
        'python': f'''# Generated Python Code
def {functionality}():
    """
    Auto-generated function for: {functionality}
    """
    print("Hello from {functionality}!")
    return True

if __name__ == "__main__":
    {functionality}()
''',
        'javascript': f'''// Generated JavaScript Code
function {functionality}() {{
    // Auto-generated function for: {functionality}
    console.log("Hello from {functionality}!");
    return true;
}}

// Usage
{functionality}();
''',
        'html': f'''<!DOCTYPE html>
<html>
<head>
    <title>{functionality}</title>
</head>
<body>
    <h1>Generated HTML for: {functionality}</h1>
    <p>This is auto-generated content.</p>
</body>
</html>
'''
    }
    
    if language not in templates:
        return ["Error: Unsupported language"]
    
    code = templates[language]
    code_base64 = base64.b64encode(code.encode()).decode()
    
    # Determine MIME type based on language
    mime_types = {
        'python': 'text/x-python',
        'javascript': 'text/javascript',
        'html': 'text/html'
    }
    
    mime_type = mime_types.get(language, 'text/plain')
    code_uri = f"data:{mime_type};base64,{code_base64}"
    
    return [
        f"Generated {language} code for: {functionality}",
        code_uri  # Will appear as downloadable code file
    ]
```

## How These Examples Work in Open WebUI

### Example 1 Output:
When the data analysis tool runs, users will see:
1. **Text message**: "Data analysis completed! Here are the results:"
2. **CSV file item**: Clickable file item named "tool-result-1.csv" that downloads the data
3. **Chart image**: Inline display of the matplotlib chart
4. **JSON file item**: Clickable file item named "tool-result-2.json" that downloads the report

### Example 2 Output:
When the report generation tool runs, users will see:
1. **Text message**: "Report 'My Report' generated successfully!"
2. **PDF file item**: Clickable file item named "tool-result-1.pdf" that downloads the report

### Example 3 Output:
When the code generation tool runs, users will see:
1. **Text message**: "Generated python code for: data_processor"
2. **Code file item**: Clickable file item named "tool-result-1.py" that downloads the code

## File Naming Convention

The enhanced system automatically generates filenames based on MIME type:
- `data:text/csv` → `tool-result-1.csv`
- `data:application/pdf` → `tool-result-1.pdf`
- `data:image/png` → `tool-result-1.png`
- `data:text/x-python` → `tool-result-1.py`
- `data:application/json` → `tool-result-1.json`

## Best Practices

1. **Always include a text message** explaining what the tool did
2. **Use appropriate MIME types** for better file handling
3. **Keep file sizes reasonable** - large base64 strings can impact performance
4. **Provide meaningful content** in the files you generate
5. **Handle errors gracefully** and return error messages as text

## Testing Your Tools

To test these examples:

1. **Backend**: Add the tool functions to your Open WebUI backend
2. **Frontend**: The enhanced Collapsible component will automatically handle the files
3. **User Experience**: Users will see both inline images and downloadable file items
4. **Downloads**: Clicking file items will trigger browser downloads with proper filenames

This enhancement makes it much easier for tools to return rich, multi-format results that users can interact with directly in the chat interface. 