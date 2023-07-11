
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

	public Notepad()
	{
		Object();
		this.make_menu();
	}

	construct {
		this.titlebar = new Aero.HeaderBar();
	}

	void make_menu()
	{
		GLib.Menu sub;
		GLib.MenuItem item;
		GLib.SimpleAction act;

		menubar.menu_model = new GLib.Menu();
		var menu = new GLib.Menu();
		(menubar.menu_model as GLib.Menu).append_submenu("_Menu", menu);

		sub = new GLib.Menu();
		{
			item = new GLib.MenuItem("_Open", null);
			item.set_attribute("icon", "s", "media-floppy");
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

			{	
				var b = new Gtk.ColorButton();
				this.menubar.add_child(b, "cbutton");

				item = new GLib.MenuItem("_Color", null);
				//  item.set_attribute("custom", "s", "cbutton");
				sub.append_item(item);

				// https://stackoverflow.com/questions/70334091/gtk4-example-of-gtk-popover-menu-bar-add-child
				// https://github.com/GNOME/gtk/blob/1f3db35271020ec7a266e0a350fd25f9725567af/gtk/gtkpopovermenu.c
			}
		}
		menu.append_section("Settings", sub);
	}
}