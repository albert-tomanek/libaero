# gladeui_dep = dependency('gladeui-2.0', required: true)
# glade_catalogdir = gladeui_dep.get_pkgconfig_variable('catalogdir')
# install_data('libaero.xml', install_dir: glade_catalogdir)

# https://github.com/alice-mkh/libhandy/blob/master/glade/meson.build

# Glade loads the actual library to introspect infromation about widgets.
# Unfortunately, as Glade is Gtk3, it cannot load out gtk4 library. 
# So we create a summy library from the .vapi where the widgets inherit from Gtk+-3.0

converter = find_program(join_paths(meson.source_root(), 'utils/mkdummylib.py'), required: true)

dummy_code = custom_target('dummy.vala',
      depends: [lib],      # for the .vapi to exist
      input: join_paths(meson.build_root(), 'lib', 'aero.vapi'),
      output: 'dummy.vala',
      command: [
            converter, '@INPUT@', '@OUTPUT@',
      ],
)

dummy_lib = shared_library('aero-dummy',
	version: '0.0.1',
	sources: [dummy_code, lib_resources],
	dependencies: [
		dependency('glib-2.0'),
		dependency('gobject-2.0'),
		dependency('gtk+-3.0'),
	],
	install: true,
)
