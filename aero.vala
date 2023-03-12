namespace Aero
{
    class Window : Gtk.Window
    {
        construct {
            this.get_style_context().add_class("aero");

            //  this.titlebar = new Gtk.HeaderBar();

            // We style the window child
            this.notify["child"].connect(() => {
                this.child.get_style_context().add_class("aero-window-contents");
            });
        }

        static construct {
            // Import the aero stylesheet into Gtk when the Aero classes are loaded.

            var css_provider = new Gtk.CssProvider();
            css_provider.load_from_resource("/com/github/albert-tomanek/gkeep/style.css");
            Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);    
        }
    }
}