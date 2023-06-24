# https://gitlab.gnome.org/jpu/cambalache/-/blob/main/catalogs/Makefile
#
#CAMBALACHE_DB=flatpak run \
#	--env=LD_LIBRARY_PATH=../tools \
#	--env=GI_TYPELIB_PATH=../tools \
#	--share=ipc \
#	--socket=fallback-x11 \
#	--socket=wayland \
#	--device=all \
#	--filesystem=host \
#	--command=python3 \
#	org.gnome.Sdk//44 \
#	../tools/cambalache-db.py
#gnome/libadwaita-1.xml: gtk/gtk-4.0.xml
#	${CAMBALACHE_DB} \
#		--target-gtk4 \
#		--dependencies gtk-4.0 \
#		--gir /usr/share/gir-1.0/Adw-1.gir \
#		--external-catalogs ${GTK4_DEPS} gtk/gtk-4.0.xml \
#		--extra-data gnome/Adwaita.xml \
#		--skip-types AdwAnimation AdwSwipeTracker AdwPropertyAnimationTarget \
#		--output $@

# env GI_TYPELIB_PATH=. LD_LIBRARY_PATH=. python3 cambalache-db.py --target-gtk4 --dependencies gtk-4.0 --gir /usr/share/gir-1.0/Aero-0.gir --extra-data ../../../catalog/Aero.xml --output ../../../catalog/libaero-0.xml

cambalache_db = find_program('python3', required: true)

cambalache_db_opts = [ '../subprojects/cambalache/tools/cambalache-db.py', '-a', '-M', '-t', 'compact' ]

catalog = custom_target('libaero-0.xml', #[lib],
        input: 'Aero.xml',
        output: 'libaero-0.xml',
        command: [
          cambalache_db, cambalache_db_opts, '--extra-data', '@INPUT@', '--output', '@OUTPUT@',
        ],
      )