public class Aero.Orb : Gtk.Button
{
    public Gdk.Texture icon { get; set; }

    construct {
        this.set_size_request(25, 25);

        valign = Gtk.Align.CENTER;

        var overlay = new Gtk.Overlay();
        this.child = overlay;
        var style_dummy = new DummyWidget() { visible = false };     // We steal the CSS style ctx from this one. Haven;t found a way to make a dummy css node.
        overlay.add_overlay(style_dummy);
        overlay.add_overlay(new Reflection(style_dummy.get_style_context()));

        var img = new Gtk.Picture() {
            //  halign = Gtk.Align.CENTER,
            //  valign = Gtk.Align.CENTER
        };
        this.bind_property("icon", img, "paintable");
        overlay.add_overlay(img);
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
    }
}

//  class PathFill : Gtk.Box
//  {
//      public PathFill(string css_class, double[] path)
//      {
//          Object();

//          var ov = new Gtk.Overlay();
//          this.add(ov);

//          this.hexpand = true; this.vexpand = true;
//          ov.hexpand = true;   ov.vexpand = true;
//      }
//  }
