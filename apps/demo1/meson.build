
converter = find_program(join_paths(meson.source_root(), 'utils/glade2gtk4.py'), required: true)

glade_files = ['demo1']
ui_files = []

foreach file : glade_files
	ui_files += custom_target('@0@.glade'.format(file),
		input: '@0@.glade'.format(file),
		output: '@0@.ui'.format(file),
		command: [
		converter, '@INPUT@', '@OUTPUT@',
		],
	)
endforeach

res = gnome.compile_resources(
    'res', 'resource.xml',
	dependencies: [ui_files],
    source_dir: '.',
	export: true,
)

executable('demo1',
	[res],
	vala_args: ['--gresourcesdir', meson.current_build_dir()],
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
