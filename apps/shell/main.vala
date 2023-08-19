// https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/desktop_migration_and_administration_guide/user-sessions

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

		// Actions
		Aero.ActionEntry[] actions = {
			{ "shutdown", () => { this.close(); }, null, null, null, "", "Show down", "Shut down your computer." },
		};

		Aero.ActionEntry.add(actions, this);
	}
}

[GtkTemplate (ui = "/com/github/albert-tomanek/aero/shell/templates/taskbar.ui")]
class TaskBar : Gtk.Box
{
	[GtkChild] Aero.Orb start_button;
	[GtkChild] Gtk.Label clock_time;
	[GtkChild] Gtk.Label clock_date;

	StartMenu start_menu;
	bool      start_menu_open = false;

	construct {
		// Start button & menu
		this.start_button.icon = Gdk.Texture.from_resource("/com/github/albert-tomanek/aero/shell/icons/logo1.svg");

		this.start_menu = new StartMenu();
		this.start_menu.set_parent(this);

		Gtk.Allocation alloc;
		this.start_button.get_allocation(out alloc);
		this.start_menu.set_pointing_to(alloc);

		this.start_button.clicked.connect(() => {
			if (this.start_menu_open)
				this.start_menu.popdown();
			else
				this.start_menu.popup();
			
			this.start_menu_open = !this.start_menu_open;
		});
		this.start_menu.closed.connect(() => { this.start_menu_open = false; });

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

[GtkTemplate (ui = "/com/github/albert-tomanek/aero/shell/templates/startmenu.ui")]
class StartMenu : Gtk.Popover
{
	[GtkChild] Gtk.Label user_name;
	[GtkChild] Gtk.Box   powerbutton_hole;
	Aero.ActionButton powerbutton;

	Act.User user = Act.UserManager.get_default().get_user("albert");	// Environment.get_user_name()

	construct {
		//  user.bind_property("real-name", user_name, "label", BindingFlags.SYNC_CREATE);
		user_name.label = "John Doe";

		this.powerbutton = new Aero.ActionButton("shutdown", Gtk.Orientation.HORIZONTAL, Gtk.IconSize.NORMAL);
		this.powerbutton.icon.hide();
		this.powerbutton.arrow_button.direction = Gtk.ArrowType.RIGHT;
		this.powerbutton.arrow_button.menu_model = (new Gtk.Builder.from_resource("/com/github/albert-tomanek/aero/shell/templates/shutdown_menu.ui")).get_object("menu") as GLib.MenuModel;
		this.powerbutton.arrow_button.popover.valign = Gtk.Align.END;
		this.powerbutton_hole.append(powerbutton);
	}
}
