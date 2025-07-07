<script lang="ts">
	import { getContext, onMount } from 'svelte';
	import { formatFileSize, getLineCount } from '$lib/utils';
	import { WEBUI_API_BASE_URL } from '$lib/constants';

	const i18n = getContext('i18n');

	import Modal from './Modal.svelte';
	import XMark from '../icons/XMark.svelte';
	import Info from '../icons/Info.svelte';
	import Switch from './Switch.svelte';
	import Tooltip from './Tooltip.svelte';
	import CodeBlock from '../chat/Messages/CodeBlock.svelte';
	import * as XLSX from 'xlsx';

	export let item;
	export let show = false;
	export let edit = false;

	let enableFullContent = false;

	let isPdf = false;
	let isAudio = false;
	let isTextFile = false;
	let isCodeFile = false;
	let isExcelFile = false;
	let fileContent = '';
	let fileLanguage = '';
	let pdfUrl = '';
	let excelData = null;
	let excelSheets = [];
	let activeSheet = 0;

	// Determine file type and content
	$: {
		if (item) {
			const fileName = item.name?.toLowerCase() || '';
			const mimeType = item.mimeType || item?.meta?.content_type || '';
			
			// Check if it's a PDF
			isPdf = mimeType === 'application/pdf' || fileName.endsWith('.pdf');
			
			// Check if it's audio
			isAudio = mimeType.startsWith('audio/') || 
				['.mp3', '.wav', '.ogg', '.m4a', '.webm'].some(ext => fileName.endsWith(ext));
			
			// Check if it's a text file
			isTextFile = mimeType.startsWith('text/') || 
				['.txt', '.md', '.csv', '.json', '.xml', '.yaml', '.yml', '.toml', '.ini', '.cfg', '.conf'].some(ext => fileName.endsWith(ext));
			
			// Check if it's a code file
			isCodeFile = [
				'.py', '.js', '.ts', '.jsx', '.tsx', '.html', '.css', '.scss', '.sass', '.less',
				'.java', '.cpp', '.c', '.cs', '.php', '.rb', '.go', '.rs', '.swift', '.kt',
				'.sql', '.sh', '.bash', '.ps1', '.r', '.m', '.scala', '.clj', '.hs', '.elm',
				'.vue', '.svelte', '.astro', '.dart', '.lua', '.pl', '.perl', '.asm', '.s',
				'.h', '.hpp', '.cc', '.cxx', '.m', '.mm', '.f', '.f90', '.f95', '.f03'
			].some(ext => fileName.endsWith(ext));
			
			// Check if it's an Excel file
			isExcelFile = mimeType === 'application/vnd.ms-excel' || 
				mimeType === 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ||
				['.xls', '.xlsx'].some(ext => fileName.endsWith(ext));
			
			// Extract content from data URI if available
			if (item?.file?.data?.content && item.file.data.content.startsWith('data:')) {
				try {
					const [header, base64Data] = item.file.data.content.split(',');
					const mimeTypeFromUri = header.match(/data:(.+);base64/)?.[1] || '';
					
					// For text-based files, decode the content
					if (mimeTypeFromUri.startsWith('text/') || 
						mimeTypeFromUri === 'application/json' || 
						mimeTypeFromUri === 'application/xml') {
						const binaryString = atob(base64Data);
						fileContent = binaryString;
						
						// Determine language for syntax highlighting
						fileLanguage = getLanguageFromFileName(fileName) || getLanguageFromMimeType(mimeTypeFromUri);
					}
					
					// For PDFs, create blob URL
					if (mimeTypeFromUri === 'application/pdf') {
						const binaryString = atob(base64Data);
						const blob = new Blob([Uint8Array.from(binaryString, (c) => c.charCodeAt(0))], {
							type: 'application/pdf'
						});
						pdfUrl = URL.createObjectURL(blob);
					}
					
					// For Excel files, parse the workbook
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
				} catch (error) {
					console.error('Error processing data URI:', error);
				}
			} else if (item?.file?.data?.content) {
				// Handle plain text content
				fileContent = item.file.data.content;
				fileLanguage = getLanguageFromFileName(fileName);
			}
		}
	}

	// Function to determine language from filename
	function getLanguageFromFileName(fileName: string): string {
		const extension = fileName.split('.').pop()?.toLowerCase() || '';
		
		const languageMap = {
			// Code files
			'py': 'python',
			'js': 'javascript',
			'ts': 'typescript',
			'jsx': 'jsx',
			'tsx': 'tsx',
			'html': 'html',
			'css': 'css',
			'scss': 'scss',
			'sass': 'sass',
			'less': 'less',
			'java': 'java',
			'cpp': 'cpp',
			'c': 'c',
			'cs': 'csharp',
			'php': 'php',
			'rb': 'ruby',
			'go': 'go',
			'rs': 'rust',
			'swift': 'swift',
			'kt': 'kotlin',
			'sql': 'sql',
			'sh': 'bash',
			'bash': 'bash',
			'ps1': 'powershell',
			'r': 'r',
			'm': 'matlab',
			'scala': 'scala',
			'clj': 'clojure',
			'hs': 'haskell',
			'elm': 'elm',
			'vue': 'vue',
			'svelte': 'svelte',
			'astro': 'astro',
			'dart': 'dart',
			'lua': 'lua',
			'pl': 'perl',
			'perl': 'perl',
			'asm': 'assembly',
			's': 'assembly',
			'h': 'c',
			'hpp': 'cpp',
			'cc': 'cpp',
			'cxx': 'cpp',
			'mm': 'objective-c',
			'f': 'fortran',
			'f90': 'fortran',
			'f95': 'fortran',
			'f03': 'fortran',
			
			// Text files
			'txt': 'text',
			'md': 'markdown',
			'csv': 'csv',
			'json': 'json',
			'xml': 'xml',
			'yaml': 'yaml',
			'yml': 'yaml',
			'toml': 'toml',
			'ini': 'ini',
			'cfg': 'ini',
			'conf': 'ini'
		};
		
		return languageMap[extension] || 'text';
	}

	// Function to determine language from MIME type
	function getLanguageFromMimeType(mimeType: string): string {
		const mimeMap = {
			'text/plain': 'text',
			'text/markdown': 'markdown',
			'text/csv': 'csv',
			'application/json': 'json',
			'application/xml': 'xml',
			'text/xml': 'xml',
			'text/yaml': 'yaml',
			'text/javascript': 'javascript',
			'application/javascript': 'javascript',
			'text/typescript': 'typescript',
			'application/typescript': 'typescript',
			'text/html': 'html',
			'text/css': 'css',
			'text/x-python': 'python',
			'application/x-python': 'python'
		};
		
		return mimeMap[mimeType] || 'text';
	}

	onMount(() => {
		console.log(item);
		if (item?.context === 'full') {
			enableFullContent = true;
		}
	});
</script>

<Modal bind:show size="lg">
	<div class="font-primary px-6 py-5 w-full flex flex-col justify-center dark:text-gray-400">
		<div class=" pb-2">
			<div class="flex items-start justify-between">
				<div>
					<div class=" font-medium text-lg dark:text-gray-100">
						<a
							href="#"
							class="hover:underline line-clamp-1"
							on:click|preventDefault={() => {
								if (!isPDF && item.url) {
									window.open(
										item.type === 'file' ? `${item.url}/content` : `${item.url}`,
										'_blank'
									);
								}
							}}
						>
							{item?.name ?? 'File'}
						</a>
					</div>
				</div>

				<div>
					<button
						on:click={() => {
							show = false;
						}}
					>
						<XMark />
					</button>
				</div>
			</div>

			<div>
				<div class="flex flex-col items-center md:flex-row gap-1 justify-between w-full">
					<div class=" flex flex-wrap text-sm gap-1 text-gray-500">
						{#if item.size}
							<div class="capitalize shrink-0">{formatFileSize(item.size)}</div>
							•
						{/if}

						{#if fileContent}
							<div class="capitalize shrink-0">
								{getLineCount(fileContent)} lines
							</div>
							•
							<div class="capitalize shrink-0">
								{fileLanguage} file
							</div>
						{/if}

						{#if item?.file?.data?.content && !fileContent}
							<div class="capitalize shrink-0">
								{getLineCount(item?.file?.data?.content ?? '')} extracted lines
							</div>

							<div class="flex items-center gap-1 shrink-0">
								<Info />

								Formatting may be inconsistent from source.
							</div>
						{/if}
					</div>

					{#if edit}
						<div>
							<Tooltip
								content={enableFullContent
									? $i18n.t(
											'Inject the entire content as context for comprehensive processing, this is recommended for complex queries.'
										)
									: $i18n.t(
											'Default to segmented retrieval for focused and relevant content extraction, this is recommended for most cases.'
										)}
							>
								<div class="flex items-center gap-1.5 text-xs">
									{#if enableFullContent}
										Using Entire Document
									{:else}
										Using Focused Retrieval
									{/if}
									<Switch
										bind:state={enableFullContent}
										on:change={(e) => {
											item.context = e.detail ? 'full' : undefined;
										}}
									/>
								</div>
							</Tooltip>
						</div>
					{/if}
				</div>
			</div>
		</div>

		<div class="max-h-[75vh] overflow-auto">
			{#if isPdf}
				{#if pdfUrl}
					<!-- PDF preview from data URI -->
					<iframe
						title={item?.name}
						src={pdfUrl}
						class="w-full h-[70vh] border-0 rounded-lg mt-4"
					/>
				{:else if item.id}
					<!-- PDF preview from server -->
					<iframe
						title={item?.name}
						src={`${WEBUI_API_BASE_URL}/files/${item.id}/content`}
						class="w-full h-[70vh] border-0 rounded-lg mt-4"
					/>
				{:else}
					<div class="text-center py-8 text-gray-500">
						PDF preview not available
					</div>
				{/if}
			{:else if isAudio}
				<audio
					src={`${WEBUI_API_BASE_URL}/files/${item.id}/content`}
					class="w-full border-0 rounded-lg mb-2"
					controls
					playsinline
				/>
			{:else if isExcelFile && excelSheets.length > 0}
				<!-- Excel preview with multiple sheets -->
				<div class="mt-4">
					<div class="mb-4">
						<label for="sheet-selector" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
							Sheet:
						</label>
						<select
							id="sheet-selector"
							bind:value={activeSheet}
							class="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 dark:bg-gray-700 dark:border-gray-600 dark:text-white"
						>
							{#each excelSheets as sheet, index}
								<option value={index}>{sheet.name}</option>
							{/each}
						</select>
					</div>
					
					<div class="overflow-x-auto">
						<table class="min-w-full border border-gray-300 dark:border-gray-600">
							<thead>
								{#if excelSheets[activeSheet]?.data?.[0]}
									<tr>
										{#each excelSheets[activeSheet].data[0] as cell}
											<th class="border border-gray-300 dark:border-gray-600 px-4 py-2 bg-gray-100 dark:bg-gray-800 text-left text-sm font-medium text-gray-900 dark:text-gray-100">
												{cell || ''}
											</th>
										{/each}
									</tr>
								{/if}
							</thead>
							<tbody>
								{#each excelSheets[activeSheet]?.data?.slice(1) || [] as row, rowIndex}
									<tr class={rowIndex % 2 === 0 ? 'bg-white dark:bg-gray-900' : 'bg-gray-50 dark:bg-gray-800'}>
										{#each row as cell}
											<td class="border border-gray-300 dark:border-gray-600 px-4 py-2 text-sm text-gray-900 dark:text-gray-100">
												{cell || ''}
											</td>
										{/each}
									</tr>
								{/each}
							</tbody>
						</table>
					</div>
					
					<div class="mt-4 text-sm text-gray-500 dark:text-gray-400">
						{excelSheets[activeSheet]?.data?.length || 0} rows, {excelSheets[activeSheet]?.data?.[0]?.length || 0} columns
					</div>
				</div>
			{:else if (isTextFile || isCodeFile) && fileContent}
				<!-- Enhanced text/code preview with syntax highlighting -->
				<div class="mt-4">
					<CodeBlock
						id={`file-preview-${item?.name}`}
						lang={fileLanguage}
						code={fileContent}
						className=""
						run={false}
						save={false}
						preview={false}
						collapsed={false}
					/>
				</div>
			{:else}
				<!-- Fallback to plain text display -->
				<div class="max-h-96 overflow-scroll scrollbar-hidden text-xs whitespace-pre-wrap">
					{item?.file?.data?.content ?? 'No content'}
				</div>
			{/if}
		</div>
	</div>
</Modal>
