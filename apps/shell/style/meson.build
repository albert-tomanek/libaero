sassc = find_program('sassc', required: true)

sassc_opts = [ '-a', '-M', '-t', 'compact' ]

css_dep = custom_target('shell.css',
      input: 'shell.scss',
      output: 'shell.css',
      command: [
            sassc, sassc_opts, '@INPUT@', '@OUTPUT@',
      ],
)