project('gkeep', ['vala', 'c'])
gnome = import('gnome')

subdir('stylesheet')

resources = gnome.compile_resources(
   'keep_res', 'resource.xml',
    source_dir: '.',
	dependencies: css_dep,
	export: true,
)

lib = shared_library('aero',
	[css_dep, resources],
	version: '0.0.1',
	sources: [
		'aero.vala'
	],
	dependencies: [
		dependency('glib-2.0'),
		dependency('gobject-2.0'),
		dependency('gtk4'),
	],
	install: false,
)

executable('win',
	[resources],
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
