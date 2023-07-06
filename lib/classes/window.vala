[GtkTemplate (ui = "/com/github/albert-tomanek/aero/templates/windowcontrols.ui")]
public class Aero.HeaderBar : Gtk.Box
{
    // Since this is a Gtk.Box, additional headerbar items to come before the main window content can be added using the usual Box.add()

    [GtkChild] Gtk.Button minimize;
    [GtkChild] Gtk.Button maximize;
    [GtkChild] Gtk.Button close;

    [GtkChild] Gtk.Label title; // private; this syncs with the official window title automatically.
    [GtkChild] public Gtk.Image icon;
    [GtkChild] Gtk.Box   content_box;
    [GtkChild] Gtk.Box   info_box;

    public bool show_info { get; set; default = true; }

    construct {
        this.realize.connect(() => {    // Once it's actually attached to a window...
            var win = this.get_ancestor(typeof(Gtk.Window)) as Gtk.Window;
            
            /* Window controls callbacks */
            close.clicked.connect(() => { win.close(); });
            maximize.clicked.connect(() => { win.maximized = !win.maximized; });
            minimize.clicked.connect(() => { win.minimize(); });

            win.notify["maximized"].connect(() => {
                maximize.icon_name = win.maximized ? "window-restore-symbolic" : "window-maximize-symbolic";
            });

            /* Window icon */
            icon.state_flags_changed.connect((old) => {
                if (((old & Gtk.StateFlags.ACTIVE) != 0) && ((icon.get_state_flags() & Gtk.StateFlags.ACTIVE) == 0))
                    (win.get_native().get_surface() as Gdk.Toplevel).titlebar_gesture(Gdk.TitlebarGesture.RIGHT_CLICK);
            });
            
            /* Bind to window properties */
            win.bind_property("modal", minimize, "visible", BindingFlags.SYNC_CREATE | BindingFlags.INVERT_BOOLEAN);
            win.bind_property("resizable", maximize, "visible", BindingFlags.SYNC_CREATE);
            win.bind_property("title", this.title, "label", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

            this.bind_property("show_info", info_box, "visible", BindingFlags.SYNC_CREATE);
        }); 
    }

    public HeaderBar.with_contents(Gtk.Widget contents)
    {
        this.content_box.append(contents);
    }

    static construct {
        // Import the aero stylesheet into Gtk when the Aero classes are loaded.

        var css_provider = new Gtk.CssProvider();
        css_provider.load_from_resource("/com/github/albert-tomanek/aero/aero.css");
        Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);    
    }
}
