converter = find_program(join_paths(meson.source_root(), 'utils/glade2gtk4.py'), required: true)

glade_files = ['appmenu', 'appmenuactionlist']
ui_files = []

foreach file : glade_files
	ui_files += custom_target('@0@.ui'.format(file),
		input: '@0@.glade'.format(file),
		output: '@0@.ui'.format(file),
		command: [
		converter, '@INPUT@', '@OUTPUT@',
		],
	)
endforeach