public class Aero.Ribbon : Gtk.Box
{
    public Gtk.Notebook rib = new Gtk.Notebook();

    construct {
        this.add_css_class("ribbon");
        this.append(rib);

        this.hexpand = true;
        rib.hexpand = true;
    }
}
