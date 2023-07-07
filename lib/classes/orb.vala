public class Aero.Orb : Gtk.Button
{
    public Orb(string icon_res)
    {
        var overlay = new Gtk.Overlay();
        var style_dummy = new DummyWidget() { visible = false };     // We steal the CSS style ctx from this one. Haven;t found a way to make a dummy css node.
        overlay.add_overlay(style_dummy);
        overlay.add_overlay(new Reflection(style_dummy.get_style_context()));
        overlay.add_overlay(new Gtk.Image.from_resource(icon_res) {
            //  halign = Gtk.Align.CENTER,
            //  valign = Gtk.Align.CENTER
        });

        Object(child: overlay);
    }

    construct {
        //  this.set_size_request(37, 37);
        this.set_size_request(25, 25);

        valign = Gtk.Align.CENTER;
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
            this.draw.connect((cr) => {
                var w = this.get_allocated_width();
                var h = this.get_allocated_height();

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

                return false;   // false to propagate draw event further
            });
        }
    }
}
