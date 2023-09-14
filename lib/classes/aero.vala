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

        Aero.is_initialized = true;
    }

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

    public delegate void SignalListItemFactoryCallback(Gtk.SignalListItemFactory @this, Gtk.ListItem li);

    public Gtk.SignalListItemFactory new_signal_list_item_factory(
        SignalListItemFactoryCallback? setup,
        SignalListItemFactoryCallback? teardown,
        SignalListItemFactoryCallback? bind,
        SignalListItemFactoryCallback? unbind
    )
    {
        var f = new Gtk.SignalListItemFactory();

        if (setup    != null) f.setup.connect(setup);
        if (teardown != null) f.teardown.connect(teardown);
        if (bind     != null) f.bind.connect(bind);
        if (unbind   != null) f.unbind.connect(unbind);

        return f;
    }
}