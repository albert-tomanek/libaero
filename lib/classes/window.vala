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

    [GtkChild] Gtk.Box   action_box;
    [GtkChild] Gtk.Box   action_box_parent;

    public bool show_info { get; set; default = true; }

    construct {
        this.realize.connect(() => {    // Once it's actually attached to a window...
            var win = this.get_ancestor(typeof(Gtk.Window)) as Gtk.Window;
            
            /* Window controls callbacks */
            close.clicked.connect(() => { win.close(); });
            maximize.clicked.connect(() => { win.maximized = !win.maximized; });
            minimize.clicked.connect(() => { win.minimize(); });

            win.notify["maximized"].connect(() => {
                (maximize.child as Gtk.Image).resource = (win.maximized ? "/com/github/albert-tomanek/aero/images/window-unmaximize.svg" : "/com/github/albert-tomanek/aero/images/window-maximize.svg");
            });
            (maximize.child as Gtk.Image).resource = ("/com/github/albert-tomanek/aero/images/window-maximize.svg");
            (minimize.child as Gtk.Image).resource = ("/com/github/albert-tomanek/aero/images/window-minimize.svg");
            (close.child as Gtk.Image).resource = ("/com/github/albert-tomanek/aero/images/window-close.svg");

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

        this.action_box_parent.prepend(new Separator());
        this.action_box_parent.append(new Separator());
    }

    public HeaderBar.with_contents(Gtk.Widget contents)
    {
        this.content_box.append(contents);
    }

    static construct {
        if (!Aero.is_initialized)
            Aero.init();
    }

    public Gtk.Button add_action(string action_name)
    {
        this.action_box_parent.visible = true;

        Aero.ActionEntry action = Aero.ActionEntry.extract(Aero.ActionEntry.find(this, action_name));

        var but = new Gtk.Button() {
            icon_name = action.icon,
            tooltip_markup = action.title,
        };
        but.add_css_class("flat");
        but.clicked.connect(() => {
            (this.get_ancestor(typeof(Gtk.ApplicationWindow)) as Gtk.ApplicationWindow).activate_action(action.name, null);
        });

        this.action_box.append(but);
        return but;
    }
}
