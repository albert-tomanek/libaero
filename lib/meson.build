pkg = import('pkgconfig')

subdir('stylesheet')
subdir('classes')
subdir('templates')

lib_resources = gnome.compile_resources(
   'aero_res', 'resource.xml',
    source_dir: ['.', meson.current_build_dir()],	# Some resources might be relative to us in the build tree, and not the source tree
	dependencies: [css_dep, ui_files],
	export: true,
)

icon_resources = gnome.compile_resources(
   'aero_res_icons', 'icon_resource.xml',
    source_dir: '.',
	dependencies: css_dep,
	export: true,
)

add_project_arguments(['--gresourcesdir', meson.current_build_dir()], language: 'vala')

lib = shared_library('aero',
	[css_dep, lib_resources, icon_resources],
	version: '0.0.1',
	sources: lib_sources,
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

pkg.generate(lib)	# Register with pkg-config

# g_ir_compiler = find_program('g-ir-compiler')	# Create a .typelib from the .gir so that we can be used from Python. We need this because the script that generates the Cambalache catalog is written in Python.
# custom_target('aero typelib', command: [g_ir_compiler, '--output', '@OUTPUT@', '@INPUT@'],
#               input: meson.current_build_dir() / 'Aero-0.gir',
#               output: 'Aero-0.typelib',
#               depends: lib,
#               install: true,
#               install_dir: get_option('libdir') / 'girepository-1.0')

#install_data(['aero/libaero-0.xml'], install_dir: join_paths(get_option('prefix'), get_option('datadir'), 'cambalache', 'catalogs'))

if get_option('glade_catalog')
	subdir('catalog')
endif