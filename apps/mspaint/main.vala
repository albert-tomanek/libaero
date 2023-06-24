
public class MsPaintApp : Gtk.Application {
	public MsPaintApp () {
		Object(application_id: "com.github.albert-tomanek.aero-apps.mspaint",
				flags: ApplicationFlags.FLAGS_NONE);
	}

	protected override void activate () {
		var win = new MsPaint() { application = this };
		win.set_size_request(300, 200);
		win.show();
	}

	public static int main(string[] args)
	{
		var app = new MsPaintApp();
		return app.run(args);
	}
}

[GtkTemplate (ui = "/com/github/albert-tomanek/aero/apps/mspaint/main.ui")]
class MsPaint : Gtk.Window
{
	[GtkChild] Gtk.Box contents;
	Aero.Ribbon ribbon;

	construct {
		this.titlebar = new Aero.HeaderBar();

		this.ribbon = new Aero.Ribbon();
		{
			var b = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			var l = new Gtk.Label("Home");
			this.ribbon.rib.append_page(b, l);
		}
		{
			var b = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			var l = new Gtk.Label("View");
			this.ribbon.rib.append_page(b, l);
		}
        this.contents.prepend(this.ribbon);
	}
}