namespace Aero
{
    public class ActionButton : Gtk.Box
    {
        string action_id;
        Gtk.IconSize size;
        int i;
        public string s_size { construct; } // only here for Glade
        public Gtk.Popover? popover { get; construct; default = null; }
        unowned Action? action;

        Gtk.Image icon;
        Gtk.Label label;

        static construct {
            set_css_name("actionbutton");
        }

        public ActionButton(string action_id, Gtk.IconSize size)
        {
            this.action_id = action_id;
            this.size = size;

            this.realize.connect(() => {
                this.action = (this.root as Gtk.ApplicationWindow).lookup_action(this.action_id);
                this.on_new_action();
            });

            this.orientation = (size == Gtk.IconSize.LARGE) ? Gtk.Orientation.VERTICAL : Gtk.Orientation.HORIZONTAL;
            message(@"orientation computed $(size) -> $orientation");

            this.hexpand = false;
            this.add_css_class("linked");
            this.add_css_class("flat");

            var top_button = new Gtk.Button();
            top_button.add_css_class("flat");
            top_button.clicked.connect(() => {
                (this.root as Gtk.ApplicationWindow).activate_action(this.action_id, null);
            });
            this.append(top_button);
            top_button.child = new Gtk.Box(this.orientation, 0) {
                hexpand = true,
                vexpand = true,
                halign = (size == Gtk.IconSize.LARGE) ? Gtk.Align.CENTER : Gtk.Align.FILL
            };

            this.icon = new Gtk.Image() {
                icon_size = this.size,
                halign = Gtk.Align.CENTER
            };

            this.label = new Gtk.Label.with_mnemonic(null) {
                halign = (size == Gtk.IconSize.LARGE) ? Gtk.Align.CENTER : Gtk.Align.START,
                hexpand = true
            };

            (top_button.child as Gtk.Box).append(icon);
            (top_button.child as Gtk.Box).append(this.label);

            var arrow_button = new Gtk.Button() {
                child = new Gtk.Image.from_resource("/com/github/albert-tomanek/aero/images/button_arrow_down.svg") {
                    valign = Gtk.Align.CENTER
                }
            };

            if (this.popover != null)
            {
                arrow_button.add_css_class("flat");
                this.append(arrow_button);
                arrow_button.clicked.connect(() => {
                    if (this.popover != null)
                        this.popover.popdown();
                });
            }
        }

        void on_new_action()
        {
            if (this.action.get_data<unowned string>("icon") != null)
                this.icon.icon_name = this.action.get_data<unowned string>("icon");
            else {
                warning("Display information is missing for the action `%s`. It wasn't created using Aero.ActionEntry.add().", this.action.name);
                this.icon.icon_name = "image-missing";
            }

            this.label.label = this.action.get_data<unowned string>("title") ?? "????";
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

