<script lang="ts">
	import { decode } from 'html-entities';
	import { v4 as uuidv4 } from 'uuid';

	import { getContext } from 'svelte';
	const i18n = getContext('i18n');

	import dayjs from '$lib/dayjs';
	import duration from 'dayjs/plugin/duration';
	import relativeTime from 'dayjs/plugin/relativeTime';

	dayjs.extend(duration);
	dayjs.extend(relativeTime);

	async function loadLocale(locales) {
		if (!locales || !Array.isArray(locales)) {
			return;
		}
		for (const locale of locales) {
			try {
				dayjs.locale(locale);
				break; // Stop after successfully loading the first available locale
			} catch (error) {
				console.error(`Could not load locale '${locale}':`, error);
			}
		}
	}

	// Assuming $i18n.languages is an array of language codes
	$: loadLocale($i18n.languages);

	import { slide } from 'svelte/transition';
	import { quintOut } from 'svelte/easing';

	import ChevronUp from '../icons/ChevronUp.svelte';
	import ChevronDown from '../icons/ChevronDown.svelte';
	import Spinner from './Spinner.svelte';
	import CodeBlock from '../chat/Messages/CodeBlock.svelte';
	import Markdown from '../chat/Messages/Markdown.svelte';
	import Image from './Image.svelte';
	import FileItem from './FileItem.svelte';

	export let open = false;

	export let className = '';
	export let buttonClassName =
		'w-fit text-gray-500 hover:text-gray-700 dark:hover:text-gray-300 transition';

	export let id = '';
	export let title = null;
	export let attributes = null;

	export let chevron = false;
	export let grow = false;

	export let disabled = false;
	export let hide = false;

	export let onChange: Function = () => {};

	$: onChange(open);

	const collapsibleId = uuidv4();

	function parseJSONString(str) {
		try {
			return parseJSONString(JSON.parse(str));
		} catch (e) {
			return str;
		}
	}

	function formatJSONString(str) {
		try {
			const parsed = parseJSONString(str);
			// If parsed is an object/array, then it's valid JSON
			if (typeof parsed === 'object') {
				return JSON.stringify(parsed, null, 2);
			} else {
				// It's a primitive value like a number, boolean, etc.
				return `${JSON.stringify(String(parsed))}`;
			}
		} catch (e) {
			// Not valid JSON, return as-is
			return str;
		}
	}

	// Utility function to convert data URI to file info
	function dataUriToFileInfo(dataUri: string, index: number) {
		try {
			const [header, base64Data] = dataUri.split(',');
			const mimeType = header.match(/data:(.+);base64/)?.[1] || 'application/octet-stream';
			
			// Decode base64 to get file size
			const binaryString = atob(base64Data);
			const size = binaryString.length;
			
			// Generate filename based on MIME type
			const extension = mimeType.split('/')[1] || 'bin';
			const fileName = `tool-result-${index + 1}.${extension}`;
			
			// Create a blob URL for download
			const blob = new Blob([Uint8Array.from(binaryString, (c) => c.charCodeAt(0))], {
				type: mimeType
			});
			const blobUrl = URL.createObjectURL(blob);
			
			return {
				name: fileName,
				type: 'file',
				size: size,
				url: blobUrl,
				mimeType: mimeType,
				item: {
					file: {
						data: {
							content: dataUri
						}
					},
					name: fileName,
					size: size,
					url: blobUrl,
					blob: blob,
					mimeType: mimeType
				}
			};
		} catch (error) {
			console.error('Error converting data URI to file info:', error);
			return null;
		}
	}

	// Function to handle data URI download
	function downloadDataUri(dataUri: string, fileName: string) {
		try {
			const [header, base64Data] = dataUri.split(',');
			const mimeType = header.match(/data:(.+);base64/)?.[1] || 'application/octet-stream';
			
			// Create blob from base64 data
			const binaryString = atob(base64Data);
			const blob = new Blob([Uint8Array.from(binaryString, (c) => c.charCodeAt(0))], {
				type: mimeType
			});
			
			// Create download link
			const url = URL.createObjectURL(blob);
			const a = document.createElement('a');
			a.href = url;
			a.download = fileName;
			document.body.appendChild(a);
			a.click();
			document.body.removeChild(a);
			URL.revokeObjectURL(url);
		} catch (error) {
			console.error('Error downloading data URI:', error);
		}
	}

	// Function to check if a data URI is an image
	function isImageDataUri(dataUri: string): boolean {
		return dataUri.startsWith('data:image/');
	}
</script>

<div {id} class={className}>
	{#if title !== null}
		<!-- svelte-ignore a11y-no-static-element-interactions -->
		<!-- svelte-ignore a11y-click-events-have-key-events -->
		<div
			class="{buttonClassName} cursor-pointer"
			on:pointerup={() => {
				if (!disabled) {
					open = !open;
				}
			}}
		>
			<div
				class=" w-full font-medium flex items-center justify-between gap-2 {attributes?.done &&
				attributes?.done !== 'true'
					? 'shimmer'
					: ''}
			"
			>
				{#if attributes?.done && attributes?.done !== 'true'}
					<div>
						<Spinner className="size-4" />
					</div>
				{/if}

				<div class="">
					{#if attributes?.type === 'reasoning'}
						{#if attributes?.done === 'true' && attributes?.duration}
							{#if attributes.duration < 60}
								{$i18n.t('Thought for {{DURATION}} seconds', {
									DURATION: attributes.duration
								})}
							{:else}
								{$i18n.t('Thought for {{DURATION}}', {
									DURATION: dayjs.duration(attributes.duration, 'seconds').humanize()
								})}
							{/if}
						{:else}
							{$i18n.t('Thinking...')}
						{/if}
					{:else if attributes?.type === 'code_interpreter'}
						{#if attributes?.done === 'true'}
							{$i18n.t('Analyzed')}
						{:else}
							{$i18n.t('Analyzing...')}
						{/if}
					{:else if attributes?.type === 'tool_calls'}
						{#if attributes?.done === 'true'}
							<Markdown
								id={`${collapsibleId}-tool-calls-${attributes?.id}`}
								content={$i18n.t('View Result from **{{NAME}}**', {
									NAME: attributes.name
								})}
							/>
						{:else}
							<Markdown
								id={`${collapsibleId}-tool-calls-${attributes?.id}-executing`}
								content={$i18n.t('Executing **{{NAME}}**...', {
									NAME: attributes.name
								})}
							/>
						{/if}
					{:else}
						{title}
					{/if}
				</div>

				<div class="flex self-center translate-y-[1px]">
					{#if open}
						<ChevronUp strokeWidth="3.5" className="size-3.5" />
					{:else}
						<ChevronDown strokeWidth="3.5" className="size-3.5" />
					{/if}
				</div>
			</div>
		</div>
	{:else}
		<!-- svelte-ignore a11y-no-static-element-interactions -->
		<!-- svelte-ignore a11y-click-events-have-key-events -->
		<div
			class="{buttonClassName} cursor-pointer"
			on:pointerup={() => {
				if (!disabled) {
					open = !open;
				}
			}}
		>
			<div>
				<div class="flex items-start justify-between">
					<slot />

					{#if chevron}
						<div class="flex self-start translate-y-1">
							{#if open}
								<ChevronUp strokeWidth="3.5" className="size-3.5" />
							{:else}
								<ChevronDown strokeWidth="3.5" className="size-3.5" />
							{/if}
						</div>
					{/if}
				</div>

				{#if grow}
					{#if open && !hide}
						<div
							transition:slide={{ duration: 300, easing: quintOut, axis: 'y' }}
							on:pointerup={(e) => {
								e.stopPropagation();
							}}
						>
							<slot name="content" />
						</div>
					{/if}
				{/if}
			</div>
		</div>
	{/if}

	{#if attributes?.type === 'tool_calls'}
		{@const args = decode(attributes?.arguments)}
		{@const result = decode(attributes?.result ?? '')}
		{@const files = parseJSONString(decode(attributes?.files ?? ''))}

		{#if !grow}
			{#if open && !hide}
				<div transition:slide={{ duration: 300, easing: quintOut, axis: 'y' }}>
					{#if attributes?.type === 'tool_calls'}
						{#if attributes?.done === 'true'}
							<Markdown
								id={`${collapsibleId}-tool-calls-${attributes?.id}-result`}
								content={`> \`\`\`json
> ${formatJSONString(args)}
> ${formatJSONString(result)}
> \`\`\``}
							/>
						{:else}
							<Markdown
								id={`${collapsibleId}-tool-calls-${attributes?.id}-result`}
								content={`> \`\`\`json
> ${formatJSONString(args)}
> \`\`\``}
							/>
						{/if}
					{:else}
						<slot name="content" />
					{/if}
				</div>
			{/if}

			{#if attributes?.done === 'true'}
				{#if typeof files === 'object'}
					{#each files ?? [] as file, idx}
						{#if isImageDataUri(file)}
							<Image
								id={`${collapsibleId}-tool-calls-${attributes?.id}-result-${idx}`}
								src={file}
								alt="Image"
							/>
						{:else if file.startsWith('data:')}
							{@const fileInfo = dataUriToFileInfo(file, idx)}
							{#if fileInfo}
								<div class="mt-2">
									<FileItem
										id={`${collapsibleId}-tool-calls-${attributes?.id}-file-${idx}`}
										name={fileInfo.name}
										type={fileInfo.type}
										size={fileInfo.size}
										url={fileInfo.url}
										item={fileInfo.item}
										className="w-full max-w-md"
										on:click={() => {
											// Handle data URI download directly
											downloadDataUri(file, fileInfo.name);
										}}
									/>
								</div>
							{/if}
						{/if}
					{/each}
				{/if}
			{/if}
		{/if}
	{:else if !grow}
		{#if open && !hide}
			<div transition:slide={{ duration: 300, easing: quintOut, axis: 'y' }}>
				<slot name="content" />
			</div>
		{/if}
	{/if}
</div>
