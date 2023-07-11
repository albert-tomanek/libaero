/*
Todo:
 - Look up how Glib.Actions work so that you can link the Ribbon to them.
   Including disabling to eg. disable ribbon buttons.
*/

public class MsPaintApp : Gtk.Application {
	public MsPaintApp () {
		Object(application_id: "com.github.albert-tomanek.aero.mspaint",
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
		var app = new MsPaintApp();
		return app.run(args);
	}
}

[GtkTemplate (ui = "/com/github/albert-tomanek/aero/apps/mspaint/main.ui")]
class MsPaint : Gtk.Window
{
	[GtkChild]
	Gtk.Image help_icon;

	construct {
		this.titlebar = new Aero.HeaderBar();
	}

	[GtkCallback]
	void show_help()
	{
		var text = (
			"This is an application made to showcase the use of libaero.\n" +
			"\n" +
			"Copyright (C) 2023,  Albert Tománek"
		);
		(new Aero.MsgBox.info(this, "Help with Aero Paint", text)).show();
	}

	[GtkCallback]	
	void niy()
	{
		var box = new Aero.MsgBox.error(this, "Not implemented", "This feature is not implemented yet.");
		box.show();
	}
}

public class Aero.MsgBox : Gtk.Dialog
{
    public enum Type
    {
        NONE = 0,
        INFO,
        QUESTION,
        WARNING,
        ERROR,
    }

    public delegate void OnResponceFunc(int response_id);

    public MsgBox.error(Gtk.Window? modal_to, string title, string? msg)
    {
        Object(transient_for: modal_to, modal: (modal_to != null));

		this.title = title;
		this.get_content_area().append(make_contents(Type.ERROR, title, msg));
		this.add_button("Ok", 0);

		this.response.connect(() => { this.close(); });
    }

	public MsgBox.info(Gtk.Window? modal_to, string title, string? msg)
    {
        Object(transient_for: modal_to, modal: (modal_to != null));

		this.title = title;
		this.get_content_area().append(make_contents(Type.INFO, title, msg));
		this.add_button("Ok", 0);

		this.response.connect(() => { this.close(); });
    }

    public MsgBox.question(Gtk.Window? modal_to, string title, string? msg, OnResponceFunc cb)
    {
        Object(transient_for: modal_to, modal: (modal_to != null));
		this.get_content_area().append(make_contents(Type.QUESTION, title, msg));
		this.add_button("Ok", 0);

		this.title = title;
		this.response.connect((id) => {
			cb(id);
		});
    }

    construct
    {
		this.resizable = false;
        this.add_css_class("aero");

		// Gtk.Dialog installs its own HeaderBar so we have to wait until after itsconstructor is called to install our one.
		(this as Gtk.Widget).realize.connect(() => {
			this.titlebar = new Aero.HeaderBar();
		});

		var ca = this.get_content_area();
		ca.parent.add_css_class("content");
		ca.add_css_class("markup");
    }

	static Gtk.Widget make_contents(Type type, string title, string? msg)
	{
		var g = new Gtk.Grid() {
			hexpand = true,
			vexpand = true
		};
		Gtk.Label l;

		l = new Gtk.Label(title) {
			halign = Gtk.Align.START,
			valign = Gtk.Align.START	
		};
		l.add_css_class("heading");
		g.attach(l, 1, 0);

		if (msg != null)
		{
			l = new Gtk.Label(msg) {
				halign = Gtk.Align.START,
				valign = Gtk.Align.START	
			};
			g.attach(l, 1, 1);
		}

		if (type != Type.NONE)
		{
			var img = new Gtk.Image();
			img.icon_size = Gtk.IconSize.LARGE;
			g.attach(img, 0, 0);
			
			switch (type)
			{
				case Type.INFO:     img.resource = "/com/github/albert-tomanek/aero/icons/orig/user32_104.png"; break;
				case Type.QUESTION: img.resource = "/com/github/albert-tomanek/aero/icons/orig/user32_102.png"; break;
				case Type.WARNING:  img.resource = "/com/github/albert-tomanek/aero/icons/orig/user32_101.png"; break;
				case Type.ERROR:    img.resource = "/com/github/albert-tomanek/aero/icons/orig/user32_103.png"; break;
			}
		}

		return g;
	}
}