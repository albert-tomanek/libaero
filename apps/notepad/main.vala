
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
		// https://wiki.gnome.org/Projects/GLib/GApplication/GMenuModel

		/* Add Actions */
		GLib.SimpleAction act;

		act = new GLib.SimpleAction.stateful("wrap", null, new Variant.boolean(true));
		act.activate.connect(() => {});
		GLib.Application.get_default().add_action(act);	// this.application.add_action(act);

		act = new GLib.SimpleAction.stateful("encoding", VariantType.STRING, new Variant.string("utf8"));
		act.activate.connect(() => {});
		GLib.Application.get_default().add_action(act);	// this.application.add_action(act);

		var b = new Gtk.ColorButton();
		this.menubar.add_child(b, "cbutton");

		/* Load menu tree from UI file */
		menubar.menu_model = (new Gtk.Builder.from_resource("/com/github/albert-tomanek/aero/apps/notepad/menu.ui")).get_object("menu") as GLib.MenuModel;
	}
}