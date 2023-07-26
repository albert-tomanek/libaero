Wanna have a shot at writing your own Aero app?
Here's what you need to do:

 * Install the TTF font in this directory.
 * `meson build`, `ninja -C build/`, `sudo ninja install -C build/`
 * If something breaks the build, you might be able to get away with commenting it out.

To build a basic Aero app:

 * You *need* to add an `Aero.HeaderBar` to your window otherwise the stylesheet will not be registered. This is a botch.
 * Add the `.aero` CSS class to your `Gtk.Window`
 * The toplevel container widget inside your window needs the `.content` class. This creates the outline etc.
 * Link with `libaero`. The library should also be visible to `pkg-config` to enable usage like `valac --pkg aero`.

There are many different style classes available for widgets. Look at `lib/stylesheet/*.scss`.

### Building UIs with Glade
Glade is not supported in Gtk4. Unfortunately, Cambalache, its replacement, is still in heavy development meaning that it is not effective for rapid UI development just yet. Beside other things, it doesn't support custom catalogs which we desparately need if we have our own widget library.
The solution I have found for this is creating Gtk3 UIs using Glade and converting them into the Gtk4 file format using the `gtk4-builder-tool` utility that is shipped with gtk4. Since the command only flags incompatibilities and does not remove them, you need to use the wrapper script `utils/glade2gtk4.py`. After that, most Gtk3 .ui files (apart from obsoleted widgets and properties) work in Gtk4.
  
To allow rapid app development, the whole UI needs to be able to be created graphically.
Glade has the ability to load information about widgets straight out of `.so` library files, allowing you to include (although not visualize) them in UIs. Unfortunately this is not possible with our library as `libaero.so` uses Gtk4 which would cause Glade to crash as it expects widget libraries to use Gtk3. I worked around this by writing a script that copies the Aero class definitions (but not the implementations) makes a dummy library (`libaero-dummy.so`) that compiles with Gtk3 and can be used with Glade. For more details see `lib/catalog/meson.build`.

### Building Menus
Neither Glade nor Cambalache have a UI to edit `GMenuModel`s, which is unfortunate because we use these to construct drop down menus and also the entire ribbon.
Luckily I managed to get ChatGPT to write a small GUI program that edits these files for us. It can be found in `utils/menu_editor.py` and can edit files such as `apps/mspaint/menu.ui` that can then be loaded as usual using a `Gtk.Builder`.