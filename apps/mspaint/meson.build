mspaint_res = gnome.compile_resources(
   'mspaint_res', 'resource.xml',
    source_dir: '.',
	export: true,
)

executable('mspaint',
	[mspaint_res],
	sources: [
		'main.vala',
	],
	dependencies: [
		dependency('glib-2.0'),
		dependency('gobject-2.0'),
		dependency('gtk4'),
	],
	link_with: lib
)
