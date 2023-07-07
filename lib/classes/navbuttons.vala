public class Aero.NavButtons : Gtk.Box
{
    public Orb left;
    public Orb right;

    construct {
        var overlay = new Gtk.Overlay();
        this.pack_start(overlay);

        // Recess
        var style_dummy = new DummyWidget() { visible = false };     // We steal the CSS style ctx from this one. Haven;t found a way to make a dummy css node.
        overlay.add_overlay(style_dummy);
        overlay.add_overlay(new Recess(style_dummy.get_style_context()));

        // Buttons
        var button_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        overlay.add_overlay(button_box);

        this.left = new Orb("/com/github/albert-tomanek/aero/images/orb_arrow_left.svg");
        button_box.pack_start(this.left);
        this.right = new Orb("/com/github/albert-tomanek/aero/images/orb_arrow_right.svg");
        button_box.pack_start(this.right);

        // FIXME  overlay.set_measure_overlay(button_box, true);
    }

    static construct {
        set_css_name("navbuttons");
    }

    class DummyWidget : Gtk.Widget
    {
        static construct {
            set_css_name("recess");
        }    
    }

    class Recess : Gtk.DrawingArea
    {
        public Recess(Gtk.StyleContext ctx)
        {
            this.draw.connect((cr) => {
                var w = this.get_allocated_width();
                var h = this.get_allocated_height();

                cr.set_source_rgb(1, 0, 0);
                push_path(cr, 0.7125, 0.9803, {
                    0.6189, 0.9199, 0.3793, 0.9249, 0.2838, 0.9826,
                    0.265, 0.9939, 0.2452, 1.0, 0.2248, 1.0,
                    0.1006, 1.0, 8.661e-06, 0.7762, 4.224e-10, 0.5,
                    0, 0.2239, 0.1006, 0, 0.2248, 0,
                    0.2452, 0, 0.2651, 0.005411, 0.2838, 0.01744,
                    0.4565, 0.1283, 0.5362, 0.133, 0.7125, 0.0197,
                    0.7325, 0.006914, 0.7535, 0, 0.7752, 0,
                    0.8994, 0, 1.0, 0.2239, 1.0, 0.5,
                    1.0, 0.7762, 0.8994, 1.0, 0.7752, 1.0,
                    0.7535, 1.0, 0.7324, 0.9931, 0.7125, 0.9803
                }, w, h);
                cr.clip();

                ctx.render_background(cr, 0, 0, w, h);
                ctx.render_frame(cr, 0, 0, w, h);

                return false;   // false to propagate draw event further
            });
        }
    }
}
