
public class AeroPhotosApp : Gtk.Application {
	public AeroPhotosApp () {
		Object(application_id: "com.github.albert-tomanek.aero-apps.photos",
				flags: ApplicationFlags.FLAGS_NONE);
	}

	protected override void activate () {
		var win = new AeroPhotos() { application = this };
		win.set_size_request(800, 600);
		win.show();
	}

	public static int main(string[] args)
	{
		var app = new AeroPhotosApp();
		return app.run(args);
	}
}

[GtkTemplate (ui = "/com/github/albert-tomanek/aero/apps/photos/main.ui")]
class AeroPhotos : Gtk.Window
{
	[GtkChild] Gtk.Box contents;

	construct {
		this.titlebar = new Aero.HeaderBar();
	}
}