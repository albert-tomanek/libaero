project('gkeep', ['vala', 'c'])
gnome = import('gnome')

subdir('stylesheet')

resources = gnome.compile_resources(
   'keep_res', 'resource.xml',
    source_dir: '.',
	dependencies: css_dep,
	export: true,
)

executable('win',
	[css_dep, resources],
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
