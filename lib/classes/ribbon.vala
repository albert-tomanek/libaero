public class Aero.Ribbon : Gtk.Box
{
    public Gtk.Notebook rib = new Gtk.Notebook();

    construct {
        this.add_css_class("ribbon");
        this.append(rib);

        this.hexpand = true;
        rib.hexpand = true;
        rib.vexpand = false;
    }

    public class Section : Gtk.Box, Gtk.Buildable  // Inheriting publically from Box so that we can wxpose the functionality of a child box is a hack.
    {
        public string title { get; set; }
        Gtk.Box internal_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);

        static construct {
            set_css_name("section");
        }

        class Separator : Gtk.Widget
        {
            static construct {
                set_css_name("separator");
            }
        }

        construct {
            this.orientation = Gtk.Orientation.HORIZONTAL;
            this.notify["orientation"].connect(() => { this.orientation = Gtk.Orientation.HORIZONTAL; });   // Users shouldn't really be able to set this.
            this.append(new Separator() { vexpand = true });

            var title_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            this.prepend(title_box);

            this.internal_box.vexpand = true;
            this.realize.connect(() => { this.parent.vexpand = false; });
            title_box.prepend(this.internal_box);

            var label = new Gtk.Label(null);
            this.bind_property("title", label, "label", BindingFlags.SYNC_CREATE);
            title_box.append(label);
        }

        /* Forward stuff to the inner box that we're pretending to be. */

        public override void add_child(Gtk.Builder builder, Object child, string? type)
        {
            this.internal_box.add_child(builder, child, type);
        }
    }
}
