project('gkeep', ['vala', 'c'])

gnome = import('gnome')

add_global_arguments('-Ilib/', language : 'c')  # For some reason it didn't see the latest version of the generated aero.h header.

subdir('lib')
subdir('apps')