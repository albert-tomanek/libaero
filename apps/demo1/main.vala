
public class KeepApp : Gtk.Application {
	public KeepApp () {
		Object(application_id: "com.github.albert-tomanek.aero.demo",
				flags: ApplicationFlags.FLAGS_NONE);
	}

	protected override void activate () {
		//  var window = new Keep (this);
		//  window.show ();

		var win = new Demo1() { application = this };
		win.set_size_request(300, 200);
		win.show();
	}

	public static int main(string[] args)
	{
		var app = new KeepApp();
		return app.run(args);
	}
}

// Uhh how do templates work again?
//  [GtkTemplate (ui = "/com/github/albert-tomanek/aero/demo_menu.ui")]
//  class Keep : Gtk.ApplicationWindow
//  {
//  	[GtkChild]
//  	unowned Gtk.IconView icons_right;
//  	//  [GtkChild]
//  	//  unowned Gtk.ListStore icons_right_store;

//  	public Keep(Gtk.Application app)
//  	{
//  		this.application = app;
//  		//  this.load_style();
//  	}

//  	//  construct {
//  	//  	{
//  	//  		Gtk.TreeIter iter;

//  	//  		icons_right_store.get_iter(out iter, new Gtk.TreePath.first());

//  	//  		do
//  	//  		{
//  	//  			Value icon_name;
//  	//  			icons_right_store.get_value(iter, 2, out icon_name);
//  	//  			var pixbuf = Gtk.IconTheme.get_default().lookup_icon(icon_name.get_string(), 48, 0);
//  	//  			stdout.printf("%p\n", (void*) pixbuf);
//  	//  			icons_right_store.set_value(iter, 0, pixbuf);
//  	//  		} while (icons_right_store.iter_next(ref iter));
//  	//  	}

//  	//  	icons_right.text_column = 1;
//  	//  	icons_right.pixbuf_column = 0;
//  	//  }

//  	//  private void load_style()
//  	//  {
//  	//  	var css_provider = new Gtk.CssProvider();
//  	//  	css_provider.load_from_resource("/com/github/albert-tomanek/gkeep/style.css");
//  	//  	Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
//  	//  }
//  }

[GtkTemplate (ui = "/com/github/albert-tomanek/aero/apps/demo1/demo1.ui")]
class Demo1 : Gtk.Window
{
	[GtkChild] Gtk.Box titlebar_content;
	[GtkChild] Gtk.CheckButton wrap_check;
	[GtkChild] Gtk.TextView text_view;
	[GtkChild] Aero.NavButtons navs;

	construct {
		navs.right.sensitive = false;
		navs.orientation = Gtk.Orientation.VERTICAL;
		this.titlebar = new Aero.HeaderBar.with_contents(titlebar_content);

		wrap_check.notify["active"].connect(() => {
			text_view.wrap_mode = wrap_check.active ? Gtk.WrapMode.WORD : Gtk.WrapMode.NONE;
		});

		page2.ref();
	}

	[GtkCallback]
	void cb_open_wizard()
	{
		var wiz = new Aero.Wizard() { title = "Example wizard" };
		make_stack(wiz);
		wiz.show();
	}

	[GtkChild] Gtk.Box page2;

	void make_stack(Aero.Wizard wiz)
	{
		var stack = wiz.stack;
		Gtk.Widget w;
		Gtk.Box b;

		{
			b = new Gtk.Box(Gtk.Orientation.VERTICAL, 0) { spacing = 19 };
			w = new Gtk.Label("Page 1") { halign = Gtk.Align.START };
			w.add_css_class("heading");
			b.append(w);
			var v = new Aero.Wizard.ChoiceButton("Continue", "Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet.");
			v.clicked.connect(wiz.next_page);
			b.append(v);
			w = new Aero.Wizard.ChoiceButton("Quit", "Exit this wizard");
			b.append(w);
			stack.add_named(b, "1");
		}

		stack.add_named(page2, "2");
	}
}