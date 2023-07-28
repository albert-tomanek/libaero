public class Aero.Ribbon : Gtk.Box
{
    public Gtk.Notebook nb = new Gtk.Notebook();
    public Aero.AppMenu? app_menu { get; private set; default = null; }
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

        for (int i = 0; i < mm.get_n_items(); i++)
        {
            /* If it's the app menu */
            Variant? is_appmenu = mm.get_item_attribute_value(i, "ribbon-type", VariantType.STRING);
            if (is_appmenu != null)
            {
                if (is_appmenu.get_string() == "app-menu")
                {
                    this.app_menu = new Aero.AppMenu.from_model(mm.get_item_link(i, "submenu"));

                    var button = new Gtk.MenuButton() {
                        child = new Gtk.Image.from_resource("/com/github/albert-tomanek/aero/images/appmenu_icon.svg"),
                        popover = this.app_menu,
                    };
                    button.add_css_class("appmenu-button");
                    Gtk.Allocation alloc;
                    button.get_allocation(out alloc);
                    button.popover.set_pointing_to(alloc);

                    this.nb.set_action_widget(button, Gtk.PackType.START);

                    continue;
                }
            }

            // Else if it's a tab bar button
            var? is_action_name = mm.get_item_attribute_value(i, "action", VariantType.STRING);
            if (is_action_name != null)
            {
                var action_name = is_action_name.get_string();
                var action = Aero.ActionEntry.extract(Aero.ActionEntry.find(this, action_name));

                var button = new Gtk.Button.from_icon_name(action.icon);
                this.nb.set_action_widget(button, Gtk.PackType.END);

                button.add_css_class("flat");
                button.add_css_class("normal-icons");
                button.clicked.connect(() => { (this.root as Gtk.ApplicationWindow).activate_action(action.name, null); });
                button.tooltip_markup = action.description ?? action.title;

                continue;
            }

            // Otherwise it's just a normal tab to add.
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

        Gtk.Box? vbox = null;
        uint vbox_children = 0;

        for (int i = 0; i < mm.get_n_items(); i++)
        {
            Gtk.Widget wij;
                
            GLib.Action action;
            Gtk.IconSize sz;
            
            /* Parse the item properties from the menu file */
            var action_name = (
                mm.get_item_attribute_value(i, "action", VariantType.STRING) ??
                mm.get_item_attribute_value(i, "ribbon-action", VariantType.STRING)   // for when the AcitonButton is actually a <submenu> because it has children
            ).get_string();
            
            action = (this.root as Gtk.ApplicationWindow).lookup_action(action_name);
            if (action == null)
                error(@"Action `win.$(action_name)` not found.");
            
            sz = Gtk.IconSize.LARGE;
            var sz_v = mm.get_item_attribute_value(i, "ribbon-size", VariantType.STRING);
            if (sz_v != null)
            {
                if (sz_v.get_string() == "large")
                    sz = Gtk.IconSize.LARGE;
                else if (sz_v.get_string() == "normal")
                    sz = Gtk.IconSize.NORMAL;
                else
                    warning("Invalid MenuItem `item-size` for Aero.Ribbon: \"%s\". Valid values are \"large\" and \"normal\".", sz_v.get_string());
            }

            /* Create the correct widget for the action type */
            if (action.get_parameter_type().dup_string() == "b")
            {
                wij = new Gtk.CheckButton() {
                    label = Aero.ActionEntry.extract(action).title,
                    action_name = action.name,
                };
            }
            else
            { 
                var ab = new Aero.ActionButton(action_name, (sz == Gtk.IconSize.LARGE) ? Gtk.Orientation.VERTICAL : Gtk.Orientation.HORIZONTAL, sz);
                wij = ab;

                // Attach a menu if it has children
                var submodel = mm.get_item_link(i, "submenu");
                if (submodel != null)
                    ab.arrow_button.menu_model = submodel;
                else
                    ab.arrow_button.visible = false;
            }
            
            /* Attach the button. Group small buttons into vertical boxes. */
            if (sz == Gtk.IconSize.LARGE)
            {
                sec.add_item(wij);
                vbox = null;
            }
            else {
                if (vbox == null || vbox_children == 3) {
                    vbox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0) {
                        valign = Gtk.Align.START,
                    };
                    vbox_children = 0;
                    sec.add_item(vbox);
                }

                vbox.append(wij);
                vbox_children += 1;
            }
        }
    }

    public class Section : Gtk.Box, Gtk.Buildable  // Inheriting publically from Box so that we can wxpose the functionality of a child box is a hack.
    {
        public string title { get; set; }
        Gtk.Box internal_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        Separator sep;

        static construct {
            set_css_name("section");
        }

        construct {
            this.orientation = Gtk.Orientation.HORIZONTAL;
            this.notify["orientation"].connect(() => { this.orientation = Gtk.Orientation.HORIZONTAL; });   // Users shouldn't really be able to set this.
            this.sep = new Separator() { vexpand = true };
            this.append(this.sep);

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

        public void add_item(Gtk.Widget widget)
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