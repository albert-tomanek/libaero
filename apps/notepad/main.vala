
public class NotepadApp : Gtk.Application {
	public NotepadApp () {
		Object(application_id: "com.github.albert-tomanek.aero.apps.notepad",
				flags: ApplicationFlags.FLAGS_NONE);
	}

	protected override void activate () {
		var win = new Notepad() { application = this };
		win.application = this;
		win.set_size_request(400, 300);
		win.show();
	}

	public static int main(string[] args)
	{
		var app = new NotepadApp();
		return app.run(args);
	}
}

[GtkTemplate (ui = "/com/github/albert-tomanek/aero/apps/notepad/main.ui")]
class Notepad : Gtk.Window
{
	[GtkChild] Gtk.PopoverMenuBar menubar;

	construct {
		this.titlebar = new Aero.HeaderBar();

		GLib.Menu sub;
		GLib.MenuItem item;
		GLib.SimpleAction act;

		menubar.menu_model = new GLib.Menu();
		var menu = new GLib.Menu();
		(menubar.menu_model as GLib.Menu).append_submenu("_Menu", menu);

		sub = new GLib.Menu();
		{
			item = new GLib.MenuItem("_Open", null);
			sub.append_item(item);
		}
		menu.append_section(null, sub);

		sub = new GLib.Menu();
		{
			act = new GLib.SimpleAction.stateful("wrap", null, new Variant.boolean(true));
			act.activate.connect(() => {});
			GLib.Application.get_default().add_action(act);	// this.application.add_action(act);

			item = new GLib.MenuItem("_Wrap text", "app.wrap");
			sub.append_item(item);

			var subsub = new GLib.Menu();
			{
				act = new GLib.SimpleAction.stateful("encoding", VariantType.STRING, new Variant.string("utf8"));
				act.activate.connect(() => {});
				GLib.Application.get_default().add_action(act);	// this.application.add_action(act);
	
				item = new GLib.MenuItem("UTF-8", "app.encoding::utf8");
				subsub.append_item(item);

				item = new GLib.MenuItem("Windows 1250", "app.encoding::windows1250");
				subsub.append_item(item);
			}
			sub.append_submenu("_Encoding", subsub);
		}
		menu.append_section(null, sub);
	}
}