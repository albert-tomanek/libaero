
public class KeepApp : Gtk.Application {
	public KeepApp () {
		Object(application_id: "testing.my.application",
				flags: ApplicationFlags.FLAGS_NONE);
	}

	protected override void activate () {
		var window = new Keep (this);
		window.show ();
	}

	public static int main(string[] args)
	{
		var app = new KeepApp();
		return app.run(args);
	}
}

// Uhh how do templates work again?
[GtkTemplate (ui = "/com/github/albert-tomanek/gkeep/example.ui")]
class Keep : Gtk.ApplicationWindow
{
	[GtkChild]
	unowned Gtk.IconView icons_right;
	//  [GtkChild]
	//  unowned Gtk.ListStore icons_right_store;

	public Keep(Gtk.Application app)
	{
		this.application = app;
		this.load_style();
	}

	//  construct {
	//  	{
	//  		Gtk.TreeIter iter;

	//  		icons_right_store.get_iter(out iter, new Gtk.TreePath.first());

	//  		do
	//  		{
	//  			Value icon_name;
	//  			icons_right_store.get_value(iter, 2, out icon_name);
	//  			var pixbuf = Gtk.IconTheme.get_default().lookup_icon(icon_name.get_string(), 48, 0);
	//  			stdout.printf("%p\n", (void*) pixbuf);
	//  			icons_right_store.set_value(iter, 0, pixbuf);
	//  		} while (icons_right_store.iter_next(ref iter));
	//  	}

	//  	icons_right.text_column = 1;
	//  	icons_right.pixbuf_column = 0;
	//  }

	private void load_style()
	{
		var css_provider = new Gtk.CssProvider();
		css_provider.load_from_resource("/com/github/albert-tomanek/gkeep/style.css");
		Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
	}
}
