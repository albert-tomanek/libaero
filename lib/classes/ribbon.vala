public class Aero.Ribbon : Gtk.Box
{
    public Gtk.Notebook rib = new Gtk.Notebook();

    construct {
        this.get_style_context().add_class("ribbon");
        this.pack_start(rib);

        this.hexpand = true;
        rib.hexpand = true;
    }
}
