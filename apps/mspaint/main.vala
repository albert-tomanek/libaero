
public class KeepApp : Gtk.Application {
	public KeepApp () {
		Object(application_id: "com.github.albert-tomanek.aero.demo",
				flags: ApplicationFlags.FLAGS_NONE);
	}

	protected override void activate () {
		//  var window = new Keep (this);
		//  window.show ();

		var win = new MsPaint() { application = this };
		win.show();
	}

	public static int main(string[] args)
	{
		var app = new KeepApp();
		return app.run(args);
	}
}

[GtkTemplate (ui = "/com/github/albert-tomanek/aero/apps/mspaint/main.ui")]
class MsPaint : Gtk.Window
{
	construct {
		this.titlebar = new Aero.HeaderBar();
	}
}