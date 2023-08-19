public class ShellApp : Gtk.Application {
	public ShellApp () {
		Object(application_id: "com.github.alberttomanek.aero.shell",
				flags: ApplicationFlags.FLAGS_NONE);
	}

	protected override void activate () {
		Aero.init();

		//  Gtk.IconTheme.get_for_display(Gdk.Display.get_default()).add_resource_path("/com/github/albert-tomanek/aero/apps/mspaint/icons/");
		var css_provider = new Gtk.CssProvider();
        css_provider.load_from_resource("/com/github/albert-tomanek/aero/shell/style/shell.css");
        Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default(), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);    

		var win = new TaskBarWindow() { application = this };
		win.show();
	}

	public static int main(string[] args)
	{

		var app = new ShellApp();
		return app.run(args);
	}
}

class TaskBarWindow : Gtk.ApplicationWindow
{
	construct {
		add_css_class("aero");
		name = "taskbar";

		set_size_request(800, -1);

		this.titlebar = new Gtk.WindowHandle() {
			child = new TaskBar(),
		};
	}
}

[GtkTemplate (ui = "/com/github/albert-tomanek/aero/shell/templates/taskbar.ui")]
class TaskBar : Gtk.Box
{
	[GtkChild] Aero.Orb start_button;
	[GtkChild] Gtk.Label clock_time;
	[GtkChild] Gtk.Label clock_date;

	construct {
		this.start_button.icon = Gdk.Texture.from_resource("/com/github/albert-tomanek/aero/shell/icons/logo1.svg");

		// Init the clock
		var now = Time.local(new time_t());
		update_clock(now);

		// Set the clock to update on each new minute.
		Timeout.add_once(61 - now.second, () => {
			Timeout.add(60, () => { this.update_clock(Time.local(new time_t())); return true; });
		});
	}

	void update_clock(Time t)
	{
		clock_time.label = "%d:%02d %s".printf(t.hour % 12, t.minute, (t.hour < 12) ? "AM" : "PM");
		clock_date.label = "%d/%d/%d".printf(t.day, t.month, 1900 + t.year);

		//  clock_time.label = t.format("%X %p");
		//  clock_time.label = t.format("%x");
	}
}
