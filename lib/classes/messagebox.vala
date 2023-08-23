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

    public delegate bool OnResponceFunc(int response_id);	// Return true to keep the dialog open.

    public MsgBox.error(Gtk.Window? modal_to, string title, string? msg, Gtk.ButtonsType buttons = Gtk.ButtonsType.OK)
    {
        Object(transient_for: modal_to, modal: (modal_to != null));

		this.title = title;
		this.get_content_area().append(make_contents(Type.ERROR, title, msg));
		make_buttons(buttons);

		this.response.connect(() => { this.close(); });
    }

	public MsgBox.info(Gtk.Window? modal_to, string title, string? msg, Gtk.ButtonsType buttons = Gtk.ButtonsType.OK)
    {
        Object(transient_for: modal_to, modal: (modal_to != null));

		this.title = title;
		this.get_content_area().append(make_contents(Type.INFO, title, msg));
		make_buttons(buttons);

		this.response.connect(() => { this.close(); });
    }

    public MsgBox.question(Gtk.Window? modal_to, string title, string? msg, OnResponceFunc cb, Gtk.ButtonsType buttons = Gtk.ButtonsType.OK_CANCEL)
    {
        Object(transient_for: modal_to, modal: (modal_to != null));
		this.get_content_area().append(make_contents(Type.QUESTION, title, msg));
		make_buttons(buttons);

		this.title = title;
		this.response.connect((rc) => {
			if (!cb(rc))
				this.close();
		});
    }

    construct
    {
		this.resizable = false;
        this.add_css_class("aero");

		// Gtk.Dialog installs its own HeaderBar so we have to wait until after its constructor is invoked to install our own one.
		(this as Gtk.Widget).realize.connect(() => {
			this.titlebar = new Aero.HeaderBar();
		});

		var ca = this.get_content_area();
		ca.parent.add_css_class("window-content");
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

	void make_buttons(Gtk.ButtonsType buttons)	// The return code is the index of the button in the name and not its common sense boolean value.
	{
		switch (buttons)
		{
		case Gtk.ButtonsType.NONE:
			break;
		case Gtk.ButtonsType.CANCEL:
			this.add_button("Cancel", 0);
			break;
		case Gtk.ButtonsType.CLOSE:
			this.add_button("Close", 0);
			break;
		case Gtk.ButtonsType.OK:
			this.add_button("OK", 0);
			break;
		case Gtk.ButtonsType.OK_CANCEL:
			this.add_button("OK", 0);
			this.add_button("Cancel", 1);
			break;
		case Gtk.ButtonsType.YES_NO:
			this.add_button("Yes", 0);
			this.add_button("No", 1);
			break;
		}

	}
}