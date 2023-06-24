res = gnome.compile_resources(
   'res', 'resource.xml',
    source_dir: '.',
	export: true,
)

executable('demo1',
	[res],
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
