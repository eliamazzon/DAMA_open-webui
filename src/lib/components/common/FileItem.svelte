<script lang="ts">
	import { createEventDispatcher, getContext } from 'svelte';
	import { formatFileSize } from '$lib/utils';

	import FileItemModal from './FileItemModal.svelte';
	import GarbageBin from '../icons/GarbageBin.svelte';
	import Spinner from './Spinner.svelte';
	import Tooltip from './Tooltip.svelte';
	import Document from '../icons/Document.svelte';
	import DocumentChartBar from '../icons/DocumentChartBar.svelte';
	import Code from '../icons/Code.svelte';
	import Photo from '../icons/Photo.svelte';
	import ArchiveBox from '../icons/ArchiveBox.svelte';

	const i18n = getContext('i18n');
	const dispatch = createEventDispatcher();

	export let className = 'w-60';
	export let colorClassName = 'bg-white dark:bg-gray-850 border border-gray-50 dark:border-white/5';
	export let url: string | null = null;

	export let dismissible = false;
	export let loading = false;

	export let item: any = null;
	export let edit = false;
	export let small = false;

	export let name: string;
	export let type: string;
	export let size: number;

	import { deleteFileById } from '$lib/apis/files';

	let showModal = false;

	const decodeString = (str: string) => {
		try {
			return decodeURIComponent(str);
		} catch (e) {
			return str;
		}
	};

	// Function to get file type info (icon and color) based on filename and MIME type
	function getFileTypeInfo(fileName: string, mimeType?: string) {
		const extension = fileName.split('.').pop()?.toLowerCase() || '';
		
		// File type definitions with icons and colors
		const fileTypes = {
			// Documents
			pdf: {
				icon: Document,
				bgColor: 'bg-red-500',
				textColor: 'text-red-500'
			},
			doc: {
				icon: Document,
				bgColor: 'bg-blue-500',
				textColor: 'text-blue-500'
			},
			docx: {
				icon: Document,
				bgColor: 'bg-blue-500',
				textColor: 'text-blue-500'
			},
			txt: {
				icon: Document,
				bgColor: 'bg-gray-500',
				textColor: 'text-gray-500'
			},
			rtf: {
				icon: Document,
				bgColor: 'bg-gray-500',
				textColor: 'text-gray-500'
			},
			
			// Spreadsheets
			xls: {
				icon: DocumentChartBar,
				bgColor: 'bg-green-500',
				textColor: 'text-green-500'
			},
			xlsx: {
				icon: DocumentChartBar,
				bgColor: 'bg-green-500',
				textColor: 'text-green-500'
			},
			csv: {
				icon: DocumentChartBar,
				bgColor: 'bg-green-500',
				textColor: 'text-green-500'
			},
			
			// Presentations
			ppt: {
				icon: Document,
				bgColor: 'bg-orange-500',
				textColor: 'text-orange-500'
			},
			pptx: {
				icon: Document,
				bgColor: 'bg-orange-500',
				textColor: 'text-orange-500'
			},
			
			// Code files
			js: {
				icon: Code,
				bgColor: 'bg-yellow-500',
				textColor: 'text-yellow-500'
			},
			ts: {
				icon: Code,
				bgColor: 'bg-blue-600',
				textColor: 'text-blue-600'
			},
			py: {
				icon: Code,
				bgColor: 'bg-blue-500',
				textColor: 'text-blue-500'
			},
			java: {
				icon: Code,
				bgColor: 'bg-red-600',
				textColor: 'text-red-600'
			},
			cpp: {
				icon: Code,
				bgColor: 'bg-blue-700',
				textColor: 'text-blue-700'
			},
			c: {
				icon: Code,
				bgColor: 'bg-blue-700',
				textColor: 'text-blue-700'
			},
			html: {
				icon: Code,
				bgColor: 'bg-orange-500',
				textColor: 'text-orange-500'
			},
			css: {
				icon: Code,
				bgColor: 'bg-blue-500',
				textColor: 'text-blue-500'
			},
			json: {
				icon: Code,
				bgColor: 'bg-gray-600',
				textColor: 'text-gray-600'
			},
			xml: {
				icon: Code,
				bgColor: 'bg-orange-600',
				textColor: 'text-orange-600'
			},
			
			// Images
			jpg: {
				icon: Photo,
				bgColor: 'bg-purple-500',
				textColor: 'text-purple-500'
			},
			jpeg: {
				icon: Photo,
				bgColor: 'bg-purple-500',
				textColor: 'text-purple-500'
			},
			png: {
				icon: Photo,
				bgColor: 'bg-purple-500',
				textColor: 'text-purple-500'
			},
			gif: {
				icon: Photo,
				bgColor: 'bg-purple-500',
				textColor: 'text-purple-500'
			},
			svg: {
				icon: Photo,
				bgColor: 'bg-purple-500',
				textColor: 'text-purple-500'
			},
			webp: {
				icon: Photo,
				bgColor: 'bg-purple-500',
				textColor: 'text-purple-500'
			},
			
			// Archives
			zip: {
				icon: ArchiveBox,
				bgColor: 'bg-yellow-600',
				textColor: 'text-yellow-600'
			},
			rar: {
				icon: ArchiveBox,
				bgColor: 'bg-red-500',
				textColor: 'text-red-500'
			},
			tar: {
				icon: ArchiveBox,
				bgColor: 'bg-blue-600',
				textColor: 'text-blue-600'
			},
			gz: {
				icon: ArchiveBox,
				bgColor: 'bg-blue-600',
				textColor: 'text-blue-600'
			},
			'7z': {
				icon: ArchiveBox,
				bgColor: 'bg-green-600',
				textColor: 'text-green-600'
			}
		};

		// Check MIME type first, then fall back to extension
		if (mimeType) {
			const mimeToExtension = {
				'application/pdf': 'pdf',
				'application/msword': 'doc',
				'application/vnd.openxmlformats-officedocument.wordprocessingml.document': 'docx',
				'text/plain': 'txt',
				'application/rtf': 'rtf',
				'application/vnd.ms-excel': 'xls',
				'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': 'xlsx',
				'text/csv': 'csv',
				'application/vnd.ms-powerpoint': 'ppt',
				'application/vnd.openxmlformats-officedocument.presentationml.presentation': 'pptx',
				'text/javascript': 'js',
				'application/typescript': 'ts',
				'text/x-python': 'py',
				'text/x-java-source': 'java',
				'text/x-c++src': 'cpp',
				'text/x-csrc': 'c',
				'text/html': 'html',
				'text/css': 'css',
				'application/json': 'json',
				'application/xml': 'xml',
				'image/jpeg': 'jpg',
				'image/png': 'png',
				'image/gif': 'gif',
				'image/svg+xml': 'svg',
				'image/webp': 'webp',
				'application/zip': 'zip',
				'application/x-rar-compressed': 'rar',
				'application/x-tar': 'tar',
				'application/gzip': 'gz',
				'application/x-7z-compressed': '7z'
			};
			
			const mimeExtension = mimeToExtension[mimeType];
			if (mimeExtension && fileTypes[mimeExtension]) {
				return fileTypes[mimeExtension];
			}
		}

		// Fall back to extension-based detection
		return fileTypes[extension] || {
			icon: Document,
			bgColor: 'bg-gray-500',
			textColor: 'text-gray-500'
		};
	}

	// Get file type info for current file
	$: fileTypeInfo = getFileTypeInfo(name, item?.file?.data?.content ? 
		item.file.data.content.match(/data:(.+);base64/)?.[1] : null);
</script>

{#if item}
	<FileItemModal bind:show={showModal} bind:item {edit} />
{/if}

<button
	class="relative group p-1.5 {className} flex items-center gap-1 {colorClassName} {small
		? 'rounded-xl'
		: 'rounded-2xl'} text-left"
	type="button"
	on:click={async () => {
		if (item?.file?.data?.content) {
			showModal = !showModal;
		} else {
			if (url) {
				if (type === 'file') {
					window.open(`${url}/content`, '_blank').focus();
				} else {
					window.open(`${url}`, '_blank').focus();
				}
			}
		}

		dispatch('click');
	}}
>
	{#if !small}
		<div class="p-3 {fileTypeInfo.bgColor} text-white rounded-xl">
			{#if !loading}
				<svelte:component this={fileTypeInfo.icon} className="size-5" />
			{:else}
				<Spinner />
			{/if}
		</div>
	{/if}

	{#if !small}
		<div class="flex flex-col justify-center -space-y-0.5 px-2.5 w-full">
			<div class=" dark:text-gray-100 text-sm font-medium line-clamp-1 mb-1">
				{decodeString(name)}
			</div>

			<div class=" flex justify-between text-gray-500 text-xs line-clamp-1">
				{#if type === 'file'}
					{$i18n.t('File')}
				{:else if type === 'doc'}
					{$i18n.t('Document')}
				{:else if type === 'collection'}
					{$i18n.t('Collection')}
				{:else}
					<span class=" capitalize line-clamp-1">{type}</span>
				{/if}
				{#if size}
					<span class="capitalize">{formatFileSize(size)}</span>
				{/if}
			</div>
		</div>
	{:else}
		<Tooltip content={decodeString(name)} className="flex flex-col w-full" placement="top-start">
			<div class="flex flex-col justify-center -space-y-0.5 px-2.5 w-full">
				<div class=" dark:text-gray-100 text-sm flex justify-between items-center">
					{#if loading}
						<div class=" shrink-0 mr-2">
							<Spinner className="size-4" />
						</div>
					{/if}
					<div class="font-medium line-clamp-1 flex-1">{decodeString(name)}</div>
					<div class="text-gray-500 text-xs capitalize shrink-0">{formatFileSize(size)}</div>
				</div>
			</div>
		</Tooltip>
	{/if}

	{#if dismissible}
		<div class=" absolute -top-1 -right-1">
			<button
				class=" bg-white text-black border border-gray-50 rounded-full group-hover:visible invisible transition"
				type="button"
				on:click|stopPropagation={() => {
					dispatch('dismiss');
				}}
			>
				<svg
					xmlns="http://www.w3.org/2000/svg"
					viewBox="0 0 20 20"
					fill="currentColor"
					class="w-4 h-4"
				>
					<path
						d="M6.28 5.22a.75.75 0 00-1.06 1.06L8.94 10l-3.72 3.72a.75.75 0 101.06 1.06L10 11.06l3.72 3.72a.75.75 0 101.06-1.06L11.06 10l3.72-3.72a.75.75 0 00-1.06-1.06L10 8.94 6.28 5.22z"
					/>
				</svg>
			</button>

			<!-- <button
				class=" p-1 dark:text-gray-300 dark:hover:text-white hover:bg-black/5 dark:hover:bg-white/5 rounded-full group-hover:visible invisible transition"
				type="button"
				on:click={() => {
				}}
			>
				<GarbageBin />
			</button> -->
		</div>
	{/if}
</button>
