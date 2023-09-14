namespace Aero
{
    // A highly versatile button class that represents a GLib.Action using an icon and a label. May display a description/popover depending on configured size. If you look around Windows 7, you will find a lot of these. Designed to be customized after construction: all child widgets are public.

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

        public ActionButton(string action_id, Gtk.Orientation ort, Gtk.IconSize size, bool flat = true)
        {
            this.realize.connect(() => {
                this.action = (this.get_ancestor(typeof(Gtk.ApplicationWindow)) as Gtk.ApplicationWindow).lookup_action(action_id);
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
            if (flat)
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
                justify = (ort == Gtk.Orientation.VERTICAL && size == Gtk.IconSize.LARGE) ? Gtk.Justification.CENTER : Gtk.Justification.LEFT,
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
            this.append(this.arrow_button);
            if (flat)
                this.arrow_button.add_css_class("flat");
            (this.arrow_button.get_first_child() as Gtk.ToggleButton).remove_css_class("image-button");
            this.arrow_button.notify["popover"].connect(() => {
                this.arrow_button.popover.has_arrow = false;
                this.arrow_button.popover.valign = Gtk.Align.START;
            });
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
            this.action.activate(null);
            //  this.activate_action(name, null);
        }
    }
}

