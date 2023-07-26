// https://developer-old.gnome.org/gtk4/stable/ch41s02.html

namespace Aero
{
    public void make_aero(Gtk.Window win)
    {
    }

    internal void push_path(Cairo.Context cr, double start_x, double start_y, double[] coords, double w, double h)
    {
        cr.move_to(start_x * w, start_y * h);

        for (int i = 0; i < coords.length; i += 6)
            cr.curve_to(coords[i+0]*w, coords[i+1]*h, coords[i+2]*w, coords[i+3]*h, coords[i+4]*w, coords[i+5]*h);
        
        cr.close_path();
    }
}

internal class Separator : Gtk.Widget
{
    static construct {
        set_css_name("separator");
    }
}
