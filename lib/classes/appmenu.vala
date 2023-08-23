namespace Aero
{
    [GtkTemplate (ui = "/com/github/albert-tomanek/aero/templates/appmenu.ui")]
    public class AppMenu : Gtk.Popover
    {
        [GtkChild] Gtk.Box main_box;
        [GtkChild] Gtk.Box recent_box;
        Gtk.ListView recent_list;
        GLib.ListStore recent = new GLib.ListStore(typeof(Object));
        [GtkChild] Gtk.Overlay recent_overlay;
        ActionList action_list;

        SubActionsMenu? current_overlay = null;

        static construct {
            set_css_name("appmenu");
        }

        public delegate void AddRecentFunc(string uri);
        public signal void need_recent(AddRecentFunc add);  // Handlers should use the provided function to add recent files.

        public AppMenu.from_model(GLib.MenuModel mm)
        {
            for (int i = 0; i < mm.get_n_items(); i++)
            {
                var? sec = mm.get_item_link(i, "section");

                if (sec != null)
                    add_section(sec);
                else
                    error("All items within an Aero.AppMenu must be inside a `section`.");
            }
        }

        construct {
            this.has_arrow = false;
            this.halign = Gtk.Align.START;

            this.action_list = new ActionList();
            this.action_list.set_size_request(150, -1);
            this.main_box.prepend(this.action_list);

            // When we're closed, hide the currently overlayed submenu
            this.notify["visible"].connect(() => {
                if (this.current_overlay != null)
                {
                    this.recent_overlay.remove_overlay(this.current_overlay);
                    this.current_overlay = null;
                }
            });

            // Create recent box
            this.recent_list = new Gtk.ListView(
                new Gtk.NoSelection(
                    this.recent
                ),
                new_signal_list_item_factory(
                    (_, li) => {
                        var button = new Gtk.Button() {
                            child = new Gtk.Label(null) {
                                ellipsize = Pango.EllipsizeMode.START,
                                max_width_chars = 10
                            }
                        };
                        button.add_css_class("flat");
                        li.child = button;
                    },
                    null,
                    (_, li) => {
                        var button = li.child as Gtk.Button;
                        var uri    = li.item.get_data<string>("uri");
                        
                        (button.child as Gtk.Label).label = uri;
                        ulong handler_id = button.clicked.connect(() => {
                            this.popdown();
                            (this.get_ancestor(typeof(Gtk.ApplicationWindow)) as Gtk.ApplicationWindow).lookup_action("open").activate(new Variant.string(uri));
                        });

                        //  li.set_data<ulong>("handler-id", handler_id);
                    },
                    (_, li) => {
                        //  li.disconnect(li.get_data<ulong>("handler-id"));
                    }
                )
            ) {
                hexpand = true,
                vexpand = true
            };
            this.recent_box.append(this.recent_list);

            // Refresh recent every time menu is opened.
            this.notify["visible"].connect(() => {
                if (this.visible == true)
                {
                    this.recent.remove_all();
                    this.need_recent(this.add_to_recent);
                }
            });
        }

        private void add_to_recent(string uri)
        {
            var o = new Object();
            o.set_data<string>("uri", uri);
    
            this.recent.append(o);
        }

        [GtkCallback]
        void close_menu()
        {
            this.popdown();
        }

        void add_section(GLib.MenuModel mm)
        {
            if (this.action_list.list.get_first_child() != null)    // If there's already items in the list
                this.action_list.list.append(new Separator() { hexpand = true });

            for (int i = 0; i < mm.get_n_items(); i++)
            {
                var? action_name = mm.get_item_attribute_value(i, "action", VariantType.STRING);
                action_name = action_name ?? mm.get_item_attribute_value(i, "ribbon-action", VariantType.STRING);
                var? subactions = mm.get_item_link(i, "submenu");

                if (action_name == null) {
                    critical("AeroRibbon item missing `action` or `ribbon-action` attribute.");
                    continue;
                }

                var ab = new Aero.ActionButton(action_name.get_string(), Gtk.Orientation.HORIZONTAL, Gtk.IconSize.LARGE);
                //  ab.add_css_class("border");
                ab.main_button.clicked.connect(this.popdown);
                var inner_arrow_button = (ab.arrow_button.get_first_child() as Gtk.ToggleButton);
                inner_arrow_button.sensitive = true;
                inner_arrow_button.toggled.connect(() => { inner_arrow_button.active = false; });   // It's actually quite a useless button
                this.action_list.add_item(ab);

                ab.show_description = false;
                ab.arrow_button.direction = Gtk.ArrowType.RIGHT;
                ab.arrow_button.realize.connect(() => { ab.arrow_button.sensitive = true; });
                ab.arrow_button.visible = (subactions != null);
                //  ab.arrow_button.notify["active"].connect(() => { GLib.Timeout.add_once(10, () => { ab.arrow_button.active = false; }); });

                // If the action has sub actions, create a menu with them that pops up on hover.

                SubActionsMenu menu = null;
                if (subactions != null)
                {
                    menu = new SubActionsMenu(action_name.get_string());
                    menu.add_actions(subactions);
                }

                var hover = new Gtk.EventControllerMotion();
                hover.enter.connect(() => {
                    if (this.current_overlay != null)
                    {
                        this.recent_overlay.remove_overlay(this.current_overlay);
                        this.current_overlay = null;
                    }
                    if (menu != null)
                    {
                        this.recent_overlay.add_overlay(menu);
                        this.current_overlay = menu;
                    }
                });
                ab.add_controller(hover);
            }
        }

        [GtkTemplate (ui = "/com/github/albert-tomanek/aero/templates/appmenuactionlist.ui")]
        internal class ActionList : Gtk.Box
        {
            [GtkChild] Gtk.Button top_scrollbutton;
            [GtkChild] Gtk.Button bottom_scrollbutton;
            [GtkChild] public Gtk.Box list;
            [GtkChild] Gtk.ScrolledWindow sw;
    
            static construct {
                set_css_name("action-list");
            }

            construct {
                setup_hover(top_scrollbutton, -120);
                setup_hover(bottom_scrollbutton, 120);

                this.sw.vadjustment.value_changed.connect(this.assess_button_visibility);
                this.realize.connect(() => {this.sw.vadjustment.value_changed();});
            }

            public void add_item(Gtk.Widget item)
            {
                list.append(item);
                this.assess_button_visibility();
            }

            void assess_button_visibility()
            {
                //  message("assessed %f %f", this.list.get_allocated_height(), this.sw.vadjustment.value + this.sw.vadjustment.get_page_size());
                if (this.sw.vadjustment.value > 1)
                    top_scrollbutton.show();
                else
                    top_scrollbutton.hide();
                
                if (this.list.get_allocated_height() > this.sw.vadjustment.value + this.sw.vadjustment.get_page_size())
                    bottom_scrollbutton.show();
                else
                    bottom_scrollbutton.hide();
            }

            uint _callback_handle;
            static int FPS = 60;

            void setup_hover(Gtk.Widget wij, double dy_dt)
            {
                var hover = new Gtk.EventControllerMotion();
                wij.add_controller(hover);

                hover.enter.connect(() => {
                    _callback_handle = GLib.Timeout.add(1000/FPS, () => {
                        this.sw.vadjustment.value += dy_dt / FPS;
                        return true;
                    });
                });
                hover.leave.connect(() => {
                    GLib.Source.remove(_callback_handle);
                });
            }
        }

        class SubActionsMenu : Gtk.Box
        {
            ActionList action_list;
            Gtk.Label heading;
    
            static construct {
                set_css_name("subaction-overlay");
            }

            public SubActionsMenu(string parent_action_name)
            {
                Object();

                this.realize.connect(() => {
                    var parent_action = Aero.ActionEntry.extract(Aero.ActionEntry.find(this, parent_action_name));
                    this.heading.set_text_with_mnemonic(parent_action.title);
                });
            }
    
            construct {
                hexpand = true;
                vexpand = true;
    
                orientation = Gtk.Orientation.VERTICAL;
                
                this.heading = new Gtk.Label(null) {
                    halign = Gtk.Align.START,
                };
                var hb = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0) {
                    hexpand = true,
                    halign = Gtk.Align.FILL,
                };
                hb.add_css_class("heading");
                hb.append(this.heading);
                this.append(hb);
    
                this.action_list = new ActionList();
                append(this.action_list);
            }
            
            public void add_actions(GLib.MenuModel mm)
            {
                for (int i = 0; i < mm.get_n_items(); i++)
                {
                    var action_name = mm.get_item_attribute_value(i, "action", VariantType.STRING);
    
                    if (action_name == null) {
                        critical("AeroRibbon item missing `action` attribute.");
                        continue;
                    }
    
                    var ab = new Aero.ActionButton(action_name.get_string(), Gtk.Orientation.HORIZONTAL, Gtk.IconSize.LARGE);
                    this.action_list.add_item(ab);

                    ab.arrow_button.visible = false;
                    ab.main_button.clicked.connect((this.get_ancestor(typeof(Gtk.Popover)) as Gtk.Popover).popdown);
                }    
            }
        }
    }
}
