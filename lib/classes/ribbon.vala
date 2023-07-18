public class Aero.Ribbon : Gtk.Box
{
    public Gtk.Notebook nb = new Gtk.Notebook();
    public GLib.MenuModel menu_model { get; set; }

    construct {
        this.add_css_class("ribbon");
        this.append(nb);

        this.hexpand = true;
        nb.hexpand = true;
        nb.vexpand = false;

        this.notify["menu-model"].connect(this.on_set_menu_model);
    }

    void on_set_menu_model()
    {
        var mm = this.menu_model;

        message("%d items", mm.get_n_items());

        for (int i = 0; i < mm.get_n_items(); i++)
        {
            /* If it's the app menu */
            Variant? is_appmenu = mm.get_item_attribute_value(i, "ribbon-type", VariantType.STRING);
            if (is_appmenu != null)
            {
                if (is_appmenu.get_string() == "app-menu")
                {
                    var button = new Gtk.MenuButton() {
                        menu_model = mm.get_item_link(i, "submenu"),
                        label = "Menu",
                    };

                    this.nb.set_action_widget(button, Gtk.PackType.START);

                    continue;
                }
            }

            add_tab(mm.get_item_link(i, "submenu"), mm.get_item_attribute_value(i, "label", VariantType.STRING).get_string());
        }
    }

    void add_tab(GLib.MenuModel mm, string name)
    {
        Gtk.Box box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);

        this.nb.append_page(box, new Gtk.Label.with_mnemonic(name));

        for (int i = 0; i < mm.get_n_items(); i++)
        {
            add_section(box, mm.get_item_link(i, "section") /* this will err if there are other items besides sections */, mm.get_item_attribute_value(i, "label", VariantType.STRING).get_string());
        }
    }

    void add_section(Gtk.Box box, GLib.MenuModel mm, string name)
    {
        Section sec = new Section() { title = name };
        box.append(sec);

        for (int i = 0; i < mm.get_n_items(); i++)
        {
            string action_name = mm.get_item_attribute_value(i, "action", VariantType.STRING).get_string();
            
            Gtk.IconSize sz = Gtk.IconSize.LARGE;
            var sz_v = mm.get_item_attribute_value(i, "item-size", VariantType.STRING);
            if (sz_v != null)
            {
                if (sz_v.get_string() == "large")
                    sz = Gtk.IconSize.LARGE;
                else if (sz_v.get_string() == "normal")
                    sz = Gtk.IconSize.NORMAL;
                else
                    warning("Invalid MenuItem `item-size` for Aero.Ribbon: \"%s\". Valid values are \"large\" and \"normal\".", sz_v.get_string());
            }
            
            message(@"New button $(i) $sz");
            var ab = new Aero.ActionButton(action_name, sz);
            sec.append(ab);
        }
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

        public void append(Gtk.Widget widget)
        {
            this.internal_box.append(widget);
        }
    }
}

string assert_else(string? s, string err)
{
    if (s != null)
        return s;
    else {
        critical(err);
        return null;
    }
}