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
	[GtkChild] Gtk.Box      r_pane;
	[GtkChild] Gtk.Label    user_name;
	[GtkChild] Gtk.Picture  user_icon;
	[GtkChild] Gtk.ListView places;

	[GtkChild] Gtk.Stack    search_stack;
	[GtkChild] Gtk.ListView search_results;
	[GtkChild] Gtk.Stack    allprogs_stack;
	[GtkChild] Gtk.ListView recent_apps;
	[GtkChild] Gtk.ListView recent_files;
	[GtkChild] Gtk.ListView allprogs_list;
	
	[GtkChild] Gtk.Button allprogs_button;
	[GtkChild] Gtk.Entry  search_entry;
	[GtkChild] Gtk.Box    powerbutton_hole1;
	[GtkChild] Gtk.Box    powerbutton_hole2;
	Aero.ActionButton     powerbutton;

	Act.User user;

	construct {
		this.set_default_widget(this.search_entry);
		this.get_first_child().overflow = Gtk.Overflow.VISIBLE;	// This is so that the user icon can jut out from the top of the start menu.

		// Setup right pane
		var store = new GLib.ListStore(typeof(Gtk.StringList));

		store.append(new Gtk.StringList({"<Username>", "Documents", "Pictures", "Music"}));
		store.append(new Gtk.StringList({"Games", "Computer"}));
		store.append(new Gtk.StringList({"Control Panel", "Devices and Printers", "Default Programs", "Help and Support", "Run..."}));

		this.places.model = new Gtk.NoSelection(
			new Gtk.FlattenListModel(store)
		);
		this.places.factory = Aero.new_signal_list_item_factory(
			(_, li) => {
				var button = new Gtk.Button();
				li.child = button;
				button.add_css_class("flat");
				button.add_css_class("text-button");

				var label = new Gtk.Label(null) {
					hexpand = true,
					halign = Gtk.Align.START,
				};
				button.child = label;
			},
			null,
			(_, li) => {
				var button = li.child as Gtk.Button;

				string name;
				li.item.get("string", ref name);
				(button.child as Gtk.Label).label = name;
				
				ulong handler_id = button.clicked.connect(() => {
					this.popdown();
					//  (this.get_ancestor(typeof(Gtk.ApplicationWindow)) as Gtk.ApplicationWindow).lookup_action("open").activate(new Variant.string(uri));
				});

				//  li.set_data<ulong>("handler-id", handler_id);
			},
			(_, li) => {
				//  li.disconnect(li.get_data<ulong>("handler-id"));
			}
		);
		// FIXME: Only from 4.12
		//  this.places.header_factory = Aero.new_signal_list_item_factory(
		//  	(_, li) => {
		//  		li.child = new Gtk.Separator(Gtk.Orientation.HORIZONTAL);
		//  	},
		//  	null, null, null
		//  );

		// Create power button
		this.powerbutton = new Aero.ActionButton("shutdown", Gtk.Orientation.HORIZONTAL, Gtk.IconSize.NORMAL, false);
		this.powerbutton.icon.hide();
		this.powerbutton.arrow_button.direction = Gtk.ArrowType.RIGHT;
		this.powerbutton.arrow_button.menu_model = (new Gtk.Builder.from_resource("/com/github/albert-tomanek/aero/shell/templates/shutdown_menu.ui")).get_object("menu") as GLib.MenuModel;
		this.powerbutton.arrow_button.popover.valign = Gtk.Align.END;
		this.powerbutton_hole1.append(powerbutton);
		//  this.powerbutton_hole2.append(powerbutton);

		// Get user name & icon
		var mgr = Act.UserManager.get_default();
		mgr.notify["is-loaded"].connect(() => {
			this.user = mgr.get_user(Environment.get_user_name());
			this.user.notify["is-loaded"].connect(() => {
				//  user.bind_property("real-name", user_name, "label", BindingFlags.SYNC_CREATE);
				(store.get_item(0) as Gtk.StringList).splice(0, 1, {user.real_name});

				this.user_icon.paintable = Gdk.Texture.from_filename(user.icon_file);
			});
		});

		// Setup search
		this.search_entry.buffer.notify["length"].connect(() => {
			if (this.search_entry.buffer.length != 0)
			{
				this.search_stack.set_visible_child(this.search_stack.get_first_child().get_next_sibling());
				this.r_pane.hide();
				this.powerbutton_hole2.show();
			}
			else
			{
				this.search_stack.set_visible_child(this.search_stack.get_first_child());
				this.r_pane.show();
				this.powerbutton_hole2.hide();
			}
		});
	}

	//  [GtkCallback]
	void about() {
		var diag = new Aero.MsgBox.info(null, "About Aerospace", "Copyright (C) 2023, Albert Tománek\nDistributed under the terms of the GPLv3");

		var grid = diag.get_content_area().get_first_child() as Gtk.Grid;
		grid.remove(grid.get_child_at(0, 0));
		grid.remove(grid.get_child_at(1, 0));
		grid.attach(new Gtk.Picture.for_resource("/com/github/albert-tomanek/aero/shell/icons/logo-large.svg") {
			height_request = 48,
			content_fit = Gtk.ContentFit.SCALE_DOWN
		}, 1, 0);

		diag.show();
	}
}
