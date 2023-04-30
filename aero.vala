namespace Aero
{
    class Window : Gtk.Window
    {
        construct {
            this.get_style_context().add_class("aero");

            this.titlebar = new Aero.HeaderBar();

            // We style the window child
            this.notify["child"].connect(() => {
                this.child.get_style_context().add_class("aero-window-contents");
            });
        }
    }

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
        [GtkChild] Gtk.Image icon;
        [GtkChild] Gtk.Box   content_box;

        construct {
            this.realize.connect(() => {
                var win = this.get_ancestor(typeof(Gtk.Window)) as Gtk.Window;
                
                close.clicked.connect(() => { win.close(); });
                maximize.clicked.connect(() => {
                    win.maximized = !win.maximized;
                });
                minimize.clicked.connect(() => { win.minimize(); });

                win.notify["maximized"].connect(() => {
                    maximize.icon_name = win.maximized ? "window-restore-symbolic" : "window-maximize-symbolic";
                });
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
}