namespace Aero
{
    public class ActionButton : Gtk.Box
    {
        public string action_id { private get; construct; }
        public Gtk.IconSize size { get; set; }
        public string s_size { construct { this.size = (value == "large") ? Gtk.IconSize.LARGE : Gtk.IconSize.NORMAL; } }
        public Gtk.Popover? popover { get; set; default = new Gtk.Popover(); }
        unowned Action? action;

        Gtk.Button icon_button;
        Gtk.Button arrow;

        static construct {
            set_css_name("actionbutton");
        }

        public ActionButton(string action_id, Gtk.IconSize size)
        {
            Object(action_id: action_id, size: size);
        }
        
        construct {
            this.action = Action.find(this.action_id);

            this.orientation = (size == Gtk.IconSize.LARGE) ? Gtk.Orientation.VERTICAL : Gtk.Orientation.HORIZONTAL;
            this.hexpand = false;
            this.add_css_class("linked");
            this.add_css_class("flat");

            this.icon_button = new Gtk.Button();
            this.icon_button.add_css_class("flat");
            this.append(this.icon_button);
            this.icon_button.child = new Gtk.Box(this.orientation, 0) {
                hexpand = true,
                vexpand = true,
                halign = (size == Gtk.IconSize.LARGE) ? Gtk.Align.CENTER : Gtk.Align.FILL
            };

            var icon = new Gtk.Image() {
                icon_size = this.size,
                halign = Gtk.Align.CENTER
            };
            if (this.action.icon_name != null)
                icon.icon_name = this.action.icon_name;
            else if (this.action.icon_resource != null)
                icon.resource = this.action.icon_resource;
            else
                warning("No icon specified for stock action with ID `%s`.", this.action.id);
            (this.icon_button.child as Gtk.Box).append(icon);
            (this.icon_button.child as Gtk.Box).append(
                new Gtk.Label.with_mnemonic(this.action.name) {
                    halign = (size == Gtk.IconSize.LARGE) ? Gtk.Align.CENTER : Gtk.Align.START,
                    hexpand = true
                }
            );

            this.arrow = new Gtk.Button() {
                child = new Gtk.Image.from_resource("/com/github/albert-tomanek/aero/images/button_arrow_down.svg") {
                    valign = Gtk.Align.CENTER
                }
            };
            this.arrow.add_css_class("flat");
            this.append(this.arrow);
            this.notify["popover"].connect(() => { this.arrow.visible = (this.popover != null); });
            this.arrow.clicked.connect(() => {
                if (this.popover != null)
                    this.popover.popdown();
            });
        }
    }

    [Compact]
    public struct Action    // Inspired by Gtk.Action
    {
        string id;
        string name;
        string? icon_resource;
        string? icon_name;
        string? tooltip;

        /* Registry of actions for the application */

        private static GenericArray<unowned Action?>? custom = null;

        public static unowned Action? find(string stock_id)
        {
            foreach (unowned Action? act in stock)
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
            return Action.fallback;
        }

        public void register(unowned Action act)
        {
            if (custom == null)
                custom = new GenericArray<unowned Action?>();
            
            custom.add(act);
        }
        
        private static const Action[] stock = {
            //  { "save", "Save", null, "media-floppy" },
            { "print", "_Print", "/com/github/albert-tomanek/aero/icons/orig/networkexplorer_115.png", null },
            { "new", "_New File", "/com/github/albert-tomanek/aero/icons/orig/imageres_102.png", null },
            { "save", "_Save", "/com/github/albert-tomanek/aero/icons/orig/shell32_16761.png", null },
            { "cut", "_Cut", "/com/github/albert-tomanek/aero/icons/orig/shell32_16762.png", null },
            { "paste", "Paste", "/com/github/albert-tomanek/aero/icons/orig/shell32_16763.png", null },
        };

        private static const Action fallback = { "", "????", null, "image-missing" };
    }
}

