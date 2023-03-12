project('gkeep', ['vala', 'c'])
gnome = import('gnome')

resources = gnome.compile_resources(
   'keep_res', 'resource.xml',
    source_dir: '.',
	export: true,
)

executable('win',
	resources,
	sources: [
		'main.vala',
		'aero.vala',
	],
	dependencies: [
		dependency('glib-2.0'),
		dependency('gobject-2.0'),
		dependency('gtk4'),
	],
)
