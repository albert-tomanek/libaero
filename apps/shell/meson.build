
subdir('templates')
subdir('style')

res = gnome.compile_resources(
    'res', 'resource.xml',
	dependencies: [ui_files, css_dep],
    source_dir: meson.current_build_dir(),
	export: true,
)

executable('shell',
	[res],
	vala_args: ['--gresourcesdir', meson.current_build_dir()],
	sources: [
		'main.vala',
	],
	dependencies: [
		dependency('glib-2.0'),
		dependency('gobject-2.0'),
		dependency('gtk4'),
		dependency('accountsservice'),
		# dependency('libmutter-11'),
	],
	link_with: lib,
	install: true
)
