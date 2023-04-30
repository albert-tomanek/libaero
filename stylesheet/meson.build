# https://github.com/GNOME/libadwaita/blob/main/src/stylesheet/meson.build

sassc = find_program('sassc', required: true)

sassc_opts = [ '-a', '-M', '-t', 'compact' ]

css_dep = custom_target('aero.css',
        input: 'style.scss',
        output: 'aero.css',
        command: [
          sassc, sassc_opts, '@INPUT@', '@OUTPUT@',
        ],
      )