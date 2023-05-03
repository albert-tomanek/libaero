namespace Aero
{
    public class Orb : Gtk.Button
    {
        public Orb(string icon_res)
        {
            var overlay = new Gtk.Overlay();
            var refl_dummy = new DummyWidget() { visible = false };     // We steal the CSS style ctx from this one. Haven;t found a way to make a dummy css node.
            overlay.add_overlay(refl_dummy);
            overlay.add_overlay(new Reflection(refl_dummy.get_style_context()));
            overlay.add_overlay(new Gtk.Image.from_resource(icon_res) {
                //  halign = Gtk.Align.CENTER,
                //  valign = Gtk.Align.CENTER
            });

            Object(child: overlay);
        }

        construct {
            //  this.set_size_request(37, 37);
            this.set_size_request(25, 25);
        }

        static construct {
            set_css_name("orb");
        }

        class DummyWidget : Gtk.Widget
        {
            static construct {
                set_css_name("reflection");
            }    
        }

        class Reflection : Gtk.DrawingArea
        {
            public Reflection(Gtk.StyleContext ctx)
            {
                set_draw_func((da, cr, w, h) => {
                    cr.set_source_rgb(1, 0, 0);
                    push_path(cr, 0.9576, 0.5126, {
                        0.9656, 0.5140, 0.9729, 0.5080, 0.9729, 0.5,
                        0.9729, 0.5, 0.9729, 0.5, 0.9729, 0.5,
                        0.9729, 0.2387, 0.7612, 0.0270, 0.5, 0.0270,
                        0.2387, 0.0270, 0.0270, 0.2387, 0.0270, 0.5,
                        0.0270, 0.5, 0.0270, 0.5, 0.0270, 0.5,
                        0.0270, 0.5080, 0.0343, 0.5140, 0.0423, 0.5126,
                        0.1829, 0.4884, 0.3375, 0.4751, 0.5, 0.4751,
                        0.6624, 0.4751, 0.8170, 0.4884, 0.9576, 0.5126,
                        0.9576, 0.5126, 0.9576, 0.5126, 0.9576, 0.5126
                    }, w, h);
                    cr.clip();

                    ctx.render_background(cr, 0, 0, w, h);
                    ctx.render_frame(cr, 0, 0, w, h);
                });
            }

            static void push_path(Cairo.Context cr, double start_x, double start_y, double[] coords, double w, double h)
            {
                cr.move_to(start_x * w, start_y * h);

                for (int i = 0; i < coords.length; i += 6)
                    cr.curve_to(coords[i+0]*w, coords[i+1]*h, coords[i+2]*w, coords[i+3]*h, coords[i+4]*w, coords[i+5]*h);
                
                cr.close_path();
            }
        }
    }

    [GtkTemplate (ui = "/com/github/albert-tomanek/aero/templates/windowcontrols.ui")]
    public class HeaderBar : Gtk.Box
    {
        // Since this is a Gtk.Box, additional headerbar items to come before the main window content can be added using the usual Box.add()

        [GtkChild] Gtk.Button minimize;
        [GtkChild] Gtk.Button maximize;
        [GtkChild] Gtk.Button close;

        [GtkChild] public Gtk.Label title;
        [GtkChild] public Gtk.Image icon;
        [GtkChild] Gtk.Box   content_box;
        [GtkChild] Gtk.Box   info_box;

        public bool show_info { get; set; default = true; }

        construct {
            this.realize.connect(() => {
                var win = this.get_ancestor(typeof(Gtk.Window)) as Gtk.Window;
                
                /* Window controls callbacks */
                close.clicked.connect(() => { win.close(); });
                maximize.clicked.connect(() => { win.maximized = !win.maximized; });
                minimize.clicked.connect(() => { win.minimize(); });

                win.notify["maximized"].connect(() => {
                    maximize.icon_name = win.maximized ? "window-restore-symbolic" : "window-maximize-symbolic";
                });

                /* Window icon */
                icon.state_flags_changed.connect((old) => {
                    if (((old & Gtk.StateFlags.ACTIVE) != 0) && ((icon.get_state_flags() & Gtk.StateFlags.ACTIVE) == 0))
                        (win.get_native().get_surface() as Gdk.Toplevel).titlebar_gesture(Gdk.TitlebarGesture.RIGHT_CLICK);
                });
                
                /* Bind to window properties */
                win.bind_property("modal", minimize, "visible", BindingFlags.SYNC_CREATE | BindingFlags.INVERT_BOOLEAN);
                win.bind_property("resizable", maximize, "visible", BindingFlags.SYNC_CREATE);

                this.bind_property("show_info", info_box, "visible", BindingFlags.SYNC_CREATE);
            }); 
        }

        public HeaderBar.with_contents(Gtk.Widget contents)
        {
            this.content_box.append(contents);
        }

        static construct {
            // Import the aero stylesheet into Gtk when the Aero classes are loaded.

            var css_provider = new Gtk.CssProvider();
            css_provider.load_from_resource("/com/github/albert-tomanek/aero/aero.css");
            Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);    
        }
    }
    
    [GtkTemplate (ui = "/com/github/albert-tomanek/aero/templates/wizard.ui")]
    public class Wizard : Gtk.Window
    {
        [GtkChild] Gtk.Box header;

        [GtkChild] private Gtk.Label title_label;
        [GtkChild] private Gtk.Image icon;
        Gtk.Button back;
        [GtkChild] Gtk.Button next;
        [GtkChild] Gtk.Button cancel;
        [GtkChild] public Gtk.Stack stack;

        [GtkChild] public Gtk.Box footer;

        public bool can_next { get; set; default = true; }

        public uint page { get; set; default = 0; }
        public bool last_page { get { return (page == this.stack.pages.get_n_items() - 1); } }

        public Wizard(Gtk.Window? parent)
        {
            Object(transient_for: parent);
        }
        
        construct {
            this.resizable = false;

            ((Gtk.Widget) this).realize.connect(() => {    // Gtk.Dialog installs its own headerbar in its constructor so we have to run after that.
                var titlebar = new Aero.HeaderBar.with_contents(header);
                this.bind_property("title", this.title_label, "label", BindingFlags.SYNC_CREATE);
                titlebar.icon.bind_property("paintable", this.icon, "paintable", BindingFlags.SYNC_CREATE);
                titlebar.show_info = false;

                this.titlebar = titlebar;

                this.page = 0;
            });

            back = new Orb("/com/github/albert-tomanek/aero/images/orb_arrow_left.svg");
            back.sensitive = false;
            header.prepend(back);

            /* Bind UI */
            this.notify["page"].connect(() => {
                this.stack.visible_child = (this.stack.pages.get_item(this.page) as Gtk.StackPage).child;

                this.back.sensitive = (page != 0);
                this.next.visible   = !last_page;
                this.cancel.label   = last_page ? "_Finish" : "_Cancel";
            });
            
            this.bind_property("can_next", this.next, "sensitive");
            this.next.clicked.connect(() => { this.next_page(); });
            this.back.clicked.connect(() => { this.prev_page(); });
            this.cancel.clicked.connect(() => { this.close(); });

            /* Install swipe gesture */
            //  var ges = new Gtk.GestureSwipe();
            //  ges.swipe.connect((dx, dy) => {
            //      message("swipe %f %f", dx, dy);
            //      if (dx > 0 && can_next)
            //          this.next_page();
            //      if (dx < 0 && page != 0)
            //          this.prev_page();
            //  });
            //  this.stack.add_controller(ges);
        }

        public void next_page()
        {
            this.page += 1;
        }

        public void prev_page()
        {
            this.page -= 1;
        }

        [GtkTemplate (ui = "/com/github/albert-tomanek/aero/templates/wizardoptionbutton.ui")]
        public class OptionButton : Gtk.Button
        {
            public string title { get; set; }
            public string description { get; set; }

            [GtkChild] Gtk.Label label_title;
            [GtkChild] Gtk.Label label_desc;

            public OptionButton(string title, string desc)
            {
                this.title = title;
                this.description = desc;
            }

            construct {
                this.bind_property("title", label_title, "label", BindingFlags.SYNC_CREATE);
                this.bind_property("description", label_desc, "label", BindingFlags.SYNC_CREATE);
            }

            static construct {
                set_css_name("optionbutton");
            }    
        }
    }
}