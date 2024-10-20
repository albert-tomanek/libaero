// https://developer-old.gnome.org/gtk4/stable/ch41s02.html

namespace Aero
{
    private bool is_initialized = false;

    public void init()
    {
        // Import the aero stylesheet into Gtk when the Aero classes are loaded.

        var css_provider = new Gtk.CssProvider();
        css_provider.load_from_resource("/com/github/albert-tomanek/aero/aero.css");
        Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default(), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);    
        Gtk.IconTheme.get_for_display(Gdk.Display.get_default()).add_resource_path("/com/github/albert-tomanek/aero/icons/orig/");

        // FIXME: This is overridden if in the stylesheet for some reason.
        css_provider = new Gtk.CssProvider();
        css_provider.load_from_data((uint8[]) "arrow {
            background-repeat: no-repeat;
            background-position: center;
        }");
        Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default(), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);    

        Aero.is_initialized = true;
    }

    public void convert_to_aero(Gtk.Window window)
    {
    }

    public void make_aero(Gtk.Window window)
    {
        var aero_titlebar = new Aero.HeaderBar();

        // If the titlebar ever gets changed by the app
        Gtk.Box? fake_tbar_box = null;      // FIXME: Should references to a classes deep children from the classes callbacks be weak?
        Gtk.Widget? last_fake_tbar = null;
        window.notify["titlebar"].connect(() => {
            // Ignore notifications about the addition of our own titlebar (which happens later in this callback).
            if (window.titlebar == aero_titlebar)
                return;

            // Replace contents with a box with the contents
            if (fake_tbar_box == null)
            {
                var old_child = window.child;
                if (old_child.has_css_class("window-content"))
                    old_child.remove_css_class("window-content");

                fake_tbar_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
                window.child = fake_tbar_box;
                fake_tbar_box.add_css_class(("window-content"));
                fake_tbar_box.append(old_child);
            }

            // Transplant the new titlebar into the box
            if (last_fake_tbar != null)
                fake_tbar_box.remove(last_fake_tbar);
            
            var new_titlebar = window.titlebar;
            if ((new_titlebar as Gtk.HeaderBar) != null)
            {
                window.titlebar = aero_titlebar;
                fake_tbar_box.prepend(new_titlebar);
                (new_titlebar as Gtk.HeaderBar).decoration_layout = "";
                last_fake_tbar = new_titlebar;
            }
            else
                last_fake_tbar = null;
        });
        window.notify_property("titlebar");

        window.add_css_class("aero");
        window.mnemonics_visible = true;
    }

    //  public void make_gtk_aero(Gtk.Window window)    // To be called after UI construction
    //  {
    //      window.child.add_css_class("window-content");
    //  }

    internal void push_path(Cairo.Context cr, double start_x, double start_y, double[] coords, double w, double h)
    {
        cr.move_to(start_x * w, start_y * h);

        for (int i = 0; i < coords.length; i += 6)
            cr.curve_to(coords[i+0]*w, coords[i+1]*h, coords[i+2]*w, coords[i+3]*h, coords[i+4]*w, coords[i+5]*h);
        
        cr.close_path();
    }

    internal class Separator : Gtk.Widget
    {
        static construct {
            set_css_name("separator");
        }
    }

    public class Arrow : Gtk.Box
    {
        public Gtk.ArrowType direction { get; set; default = Gtk.ArrowType.NONE; }

        static construct {
            set_css_name("arrow");
        }

        construct {
            //  this.append(new Gtk.Image());
            halign = Gtk.Align.CENTER;
            valign = Gtk.Align.CENTER;

            this.notify["direction"].connect(() => {
                foreach(var cls_name in get_css_classes())
                    if (cls_name == "up" || cls_name == "down" || cls_name == "left" || cls_name == "right")
                        remove_css_class(cls_name);

                switch (this.direction)
                {
                    case Gtk.ArrowType.UP:    add_css_class("up");    break;
                    case Gtk.ArrowType.DOWN:  add_css_class("down");  break;
                    case Gtk.ArrowType.LEFT:  add_css_class("left");  break;
                    case Gtk.ArrowType.RIGHT: add_css_class("right"); break;
                    default: break;
                }
            });
        }
    }

    public class FileChooserBox : Gtk.Box
    {
        public Gtk.Entry entry;
        public Gtk.Button button;
        public Gtk.FileChooserDialog dialog;

        public FileChooserBox(string? dia_title, Gtk.FileChooserAction dia_action, ...)
        {
            this.orientation = Gtk.Orientation.HORIZONTAL;
            this.spacing = 10;
            this.hexpand = true;

            this.entry = new Gtk.Entry() {
                hexpand = true
            };
            this.append(entry);
            this.button = new Gtk.Button.with_label("Browse...");
            this.append(button);

            this.dialog = new Gtk.FileChooserDialog(dia_title, null, dia_action);
            for (var l = va_list();;) {     // Unfortunately Vala dowsn't allow us to hand the varargs to another function like Python does (*args), so we have to reimplement what the function would do.
                string? text = l.arg<string>();
                if (text == null)
                    break;
                int rc = l.arg<int>();

                dialog.add_button(text, rc);
            }

            // Musn't be child of an .aero window in order to retain its original theme, assuming that Adwaita is still the overriding theme.
            this.realize.connect(() => {
                var p = (Gtk.Window?) this.get_ancestor(typeof(Gtk.Window));
                if (p != null)
                    this.dialog.set_transient_for(p);
            });
            this.dialog.response.connect((rc) => {
                switch (rc) {
                    case Gtk.ResponseType.YES:
                    case Gtk.ResponseType.OK:
                    case Gtk.ResponseType.APPLY:
                    case Gtk.ResponseType.ACCEPT:
                        this.entry.text = this.dialog.get_file()?.get_path() ?? "";
                        break;
                }

                (this.dialog as Gtk.Window).hide();
            });
            this.button.clicked.connect(this.dialog.show);
        }
    }

    /* Misc */

    public delegate void SignalListItemFactoryCallback(Gtk.SignalListItemFactory @this, Gtk.ListItem li);

    public Gtk.SignalListItemFactory new_signal_list_item_factory(
        SignalListItemFactoryCallback? setup,
        SignalListItemFactoryCallback? teardown,
        SignalListItemFactoryCallback? bind,
        SignalListItemFactoryCallback? unbind
    )
    {
        var f = new Gtk.SignalListItemFactory();

        if (setup    != null) f.setup.connect((t, li) => setup(f, (Gtk.ListItem) li));      // FIXME: We get passed Objects, not ListItems so this cast might be ignoring some aspect of reaity
        if (teardown != null) f.teardown.connect((t, li) => teardown(f, (Gtk.ListItem) li));
        if (bind     != null) f.bind.connect((t, li) => bind(f, (Gtk.ListItem) li));
        if (unbind   != null) f.unbind.connect((t, li) => unbind(f, (Gtk.ListItem) li));

        return f;
    }

    
    // Seems Windows uses JEDEC file sizes: https://superuser.com/a/938259, https://en.wikipedia.org/wiki/JEDEC_memory_standards#Unit_prefixes_for_semiconductor_storage_capacity

    public string humanize_size(size_t sz, bool kb_only = false)
    {
        if (sz < 1024)				// What would really feel natural would be 3 sig figs, ie: 2.37 MB, 321 B, 52.4 GB
            return "1 KB";
        else if (sz < 1048576)
            return @"$(sz / 1024) KB";
        else if (sz < 1073741824)
            return @"$(sz / 1048576) MB";
        else if (sz < 1099511627776)
            return @"$(sz / 1073741824) GB";
        else
            return @"$(sz / 1099511627776) TB";
    }

}