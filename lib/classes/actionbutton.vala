namespace Aero
{
    public class ActionButton : Gtk.Box
    {
        unowned Action? action;

        public Gtk.Button main_button;
        public Gtk.MenuButton arrow_button;
        public Gtk.Label description;
        public Gtk.Image icon;
        public Gtk.Label label;

        public bool show_description { get; set; }

        //public Gtk.ArrowType arrow_direction {} // Just set `this.arrow_button.direction`

        static construct {
            set_css_name("actionbutton");
        }

        public ActionButton(string action_id, Gtk.Orientation ort, Gtk.IconSize size)
        {
            this.realize.connect(() => {
                this.action = (this.root as Gtk.ApplicationWindow).lookup_action(action_id);
                this.on_new_action();
                this.set_description_visible(this.show_description);
            });

            this.mnemonic_activate.connect(() => { this.do_action(); return false; });
            
            this.show_description = (ort == Gtk.Orientation.HORIZONTAL && size == Gtk.IconSize.LARGE);

            this.orientation = ort;

            this.hexpand = false;
            this.add_css_class("linked");
            this.add_css_class("flat");
            this.add_css_class((size == Gtk.IconSize.NORMAL) ? "normal" : "large");

            this.main_button = new Gtk.Button();
            this.main_button.add_css_class("flat");
            this.main_button.clicked.connect(this.do_action);
            this.append(this.main_button);
            this.main_button.child = new Gtk.Box(this.orientation, 0) {
                hexpand = true,
                vexpand = true,
                halign = (ort == Gtk.Orientation.VERTICAL) ? Gtk.Align.CENTER : Gtk.Align.FILL
            };

            this.icon = new Gtk.Image() {
                icon_size = size,
                halign = Gtk.Align.CENTER
            };
            (this.main_button.child as Gtk.Box).append(icon);
            
            var b = new Gtk.Box(Gtk.Orientation.VERTICAL, 0) {
                valign = Gtk.Align.CENTER
            };
            (this.main_button.child as Gtk.Box).append(b);

            this.label = new Gtk.Label.with_mnemonic(null) {
                halign = (ort == Gtk.Orientation.VERTICAL) ? Gtk.Align.CENTER : Gtk.Align.START,
                hexpand = true,
            };
            b.append(this.label);

            this.description = new Gtk.Label(null) {
                halign = (ort == Gtk.Orientation.VERTICAL) ? Gtk.Align.CENTER : Gtk.Align.START,
                hexpand = true,
            };
            b.append(this.description);

            this.arrow_button = new Gtk.MenuButton() {
                //  child = new Gtk.Image.from_resource("/com/github/albert-tomanek/aero/images/button_arrow_down.svg") {
                //      valign = Gtk.Align.CENTER
                //  }
            };
            this.arrow_button.add_css_class("flat");
            (this.arrow_button.get_first_child() as Gtk.ToggleButton).remove_css_class("image-button");
            this.append(this.arrow_button);
        }

        void on_new_action()
        {
            if (this.action.get_data<unowned string>("icon") != null)
                this.icon.icon_name = this.action.get_data<unowned string>("icon");
            else {
                warning("Display information is missing for the action `%s`. It wasn't created using Aero.ActionEntry.add().", this.action.name);
                this.icon.icon_name = "image-missing";
            }

            this.label.set_text_with_mnemonic(this.action.get_data<unowned string>("title") ?? "????");

            var? desc = this.action.get_data<unowned string>("description");
            if (desc != null)
                this.description.label = desc;
            else
                this.description.hide();
        }

        void set_description_visible(bool b)
        {
            if (b)
            {
                this.description.show();
                this.label.add_css_class("heading");
            }
            else
            {
                this.description.hide();
                this.label.remove_css_class("heading");
                this.tooltip_markup = this.description.label;
            }
        }

        void do_action()
        {
            (this.root as Gtk.ApplicationWindow).activate_action(this.action.name, null);
        }
    }

    [Compact]
    public struct OldAction    // Inspired by Gtk.Action
    {
        string id;
        string name;
        string? icon_resource;
        string? icon_name;
        string? tooltip;

        /* Registry of actions for the application */

        private static GenericArray<unowned OldAction?>? custom = null;

        public static unowned OldAction? find(string stock_id)
        {
            foreach (unowned OldAction? act in stock)
            {
                if (act.id == stock_id)
                    return act;
            }

            if (custom != null)
            {
                uint idx = 0;
                if (custom.find_custom<string>(stock_id, (act, id) => { return act.id == id; }))
                {
                    return custom[idx];
                }
            }

            warning("Could not find stock action with ID `%s`.", stock_id);
            return OldAction.fallback;
        }

        public void register(unowned OldAction act)
        {
            if (custom == null)
                custom = new GenericArray<unowned OldAction?>();
            
            custom.add(act);
        }
        
        private static const OldAction[] stock = {
            //  { "save", "Save", null, "media-floppy" },
            { "print", "_Print", "/com/github/albert-tomanek/aero/icons/orig/networkexplorer_115.png", null },
            { "new", "_New File", "/com/github/albert-tomanek/aero/icons/orig/imageres_102.png", null },
            { "save", "_Save", "/com/github/albert-tomanek/aero/icons/orig/shell32_16761.png", null },
            { "cut", "_Cut", "/com/github/albert-tomanek/aero/icons/orig/shell32_16762.png", null },
            { "paste", "Paste", "/com/github/albert-tomanek/aero/icons/orig/shell32_16763.png", null },
        };

        private static const OldAction fallback = { "", "????", null, "image-missing" };
    }
}

