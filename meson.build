project('gkeep', ['vala', 'c'])
gnome = import('gnome')

subdir('stylesheet')
subdir('catalog')

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
	install: true,

	# https://mesonbuild.com/Vala.html
	vala_gir: 'Aero-0.gir',
	install_dir: [true, true, true, true],
)

#install_data(['aero/libaero-0.xml'], install_dir: join_paths(get_option('prefix'), get_option('datadir'), 'cambalache', 'catalogs'))

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

executable('mspaint',
	[resources],
	sources: [
		'mspaint/main.vala',
	],
	dependencies: [
		dependency('glib-2.0'),
		dependency('gobject-2.0'),
		dependency('gtk4'),
	],
	link_with: lib
)
