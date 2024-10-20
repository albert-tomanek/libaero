/*
Usage: 
var b = new Box();
var l = new CheckButton();
b.add(l);

var p = new Aero.WizardPage() { next = "page2" };
this.add_page(p, "page1");
*/

public class Aero.WizardPageProps : Object
{
    // Wizard binds widgets to these on every page change.
	public string? next { get; set; }	// If this page is shown, widgets respond to changes in these properties.
    public bool can_next { get; set; }
	public bool can_back { get; set; }
}

[GtkTemplate (ui = "/com/github/albert-tomanek/aero/templates/wizard.ui")]
public class Aero.Wizard : Gtk.Window
{
    [GtkChild] Gtk.Box header;

    [GtkChild] Gtk.Label title_label;
    [GtkChild] Gtk.Image icon;
    Gtk.Button back;
    [GtkChild] Gtk.Button next;
    [GtkChild] Gtk.Button cancel;
    [GtkChild] protected Gtk.Stack stack;

    ulong cb_notify_next;       // We attach callbacks to the current page's properties. These handles are used to remove callbacks to the old page when the page changes.
    ulong cb_notify_can_next;
    ulong cb_notify_can_back;

    [GtkChild] Gtk.Box footer;

    GLib.Queue<string> history = new GLib.Queue<string>();

    private WizardPageProps current_page_props {
        get {
            Gtk.StackPage current_page = this.stack.get_page(this.stack.visible_child);
            return current_page.get_data<WizardPageProps>("props");
        }
    }

    protected signal void page_changed(string? from, string? to);   /// Null on creation or deletion.

    construct {
        this.resizable = false;

        var titlebar = new Aero.HeaderBar.with_contents(header);
        this.bind_property("title", this.title_label, "label", BindingFlags.SYNC_CREATE);
        titlebar.icon.bind_property("paintable", this.icon, "paintable", BindingFlags.SYNC_CREATE);
        titlebar.show_info = false;
        this.titlebar = titlebar;

        back = new Orb() {
            icon = Gdk.Texture.from_resource("/com/github/albert-tomanek/aero/images/orb_arrow_left.svg")
        };
        back.sensitive = false;
        header.prepend(back);

        /* Bind UI */
        this.page_changed.connect(this.rebind_buttons);    // Any code changing the page should bake sure to unbind() the existing bindings first.
        this.close_request.connect(() => { this.page_changed(this.stack.visible_child_name, null); });
        
        this.next.clicked.connect(() => { this.next_page(); });
        this.back.clicked.connect(() => { this.prev_page(); });
        this.cancel.clicked.connect(() => { this.close(); });

        /* Install swipe gesture */
        //  var ges = new Gtk.GestureSwipe();
        //  ges.swipe.connect((dx, dy) => {
        //      message("swipe %f %f", dx, dy);
        //      if (dx > 0 && can_next)
        //          this.next_page();
        //      if (dx < 0 && page != 0)
        //          this.prev_page();
        //  });
        //  this.stack.add_controller(ges);
    }

    void rebind_buttons(string? id_from, string? id_to)
    {
        // Unbind UI from previous page attibutes
        if (this.cb_notify_can_next != 0)
        {
            var old_page_props = this.page_props(id_from);

            old_page_props.disconnect(this.cb_notify_next);
            old_page_props.disconnect(this.cb_notify_can_next);
            old_page_props.disconnect(this.cb_notify_can_back);        
        }

        // Bind UI to new page attributes

        this.cb_notify_can_next = current_page_props.notify["can-next"].connect(() => {
            this.next.sensitive = current_page_props.can_next;
        });

        this.cb_notify_can_back = current_page_props.notify["can-back"].connect(() => {
            this.back.sensitive = current_page_props.can_back && (history.length != 0);
        });

        this.cb_notify_next = current_page_props.notify["next"].connect(() => {
            this.next.visible   = (current_page_props.next != null);
            this.next.label     = (current_page_props.next == Wizard.FINAL_PAGE) ? "_Finish" : "_Next";
            this.cancel.visible = (current_page_props.next != Wizard.FINAL_PAGE);
        });

        current_page_props.notify_property("can-next"); // Call the callbacks on the existing values
        current_page_props.notify_property("can-back");
        current_page_props.notify_property("next");
    }

    public void add_page(string name, Gtk.Widget content, string? id_next, WizardPageProps? props = null)
    {
        Gtk.StackPage stack_page = this.stack.add_named(content, name);
        stack_page.set_data<WizardPageProps>(
            "props",
            props ?? new WizardPageProps() {
                next = id_next,
                can_next = true,
                can_back = true 
            }
        );

        if (this.stack.pages.get_n_items() == 1)    // We've just added the first page
        {
            this.stack.set_visible_child_name(name);
            this.page_changed(null, name);
        }
    }

    // This just exists for code clarity
    public delegate Gtk.Widget PageMakerFn(WizardPageProps page);
    public void add_page_cb(string name, PageMakerFn cb, string? id_next)
    {
        var props = new WizardPageProps() { next = id_next, can_next = true, can_back = true };
        this.add_page(name, cb(props), null, props);
    }

    public void next_page()
    {
        if (current_page_props.next == null)
        {
            return;
        }
        else if (current_page_props.next == Wizard.FINAL_PAGE)
        {
            this.close();
        }
        else
        {
            this.goto_page(current_page_props.next);
        }
    }

    public void goto_page(string to_name)
    {
        var from_name = this.stack.visible_child_name;

        // Add step to history so that we can go back here.
        this.history.push_head(from_name);

        // Change the page
        this.stack.set_visible_child_name(to_name);

        // Invoke event listeners
        this.page_changed(from_name, to_name);
    }

    public void prev_page()
    {
        if (this.history.length > 0)
        {
            string cur_name = this.stack.visible_child_name;
            string prev_name = this.history.pop_head();

            this.stack.set_visible_child_full(prev_name, Gtk.StackTransitionType.SLIDE_RIGHT);
            this.page_changed(cur_name, prev_name);
        }
    }

    public delegate void OnPageChangeCb(string? from, string? to);
    public ulong on_page_change(string? from, string? to, OnPageChangeCb cb)    /// Remember, the wizard might be returning to this page from a later page. You should better store the state of one-time operations in a variable inside your Wizard-derived class.
    {
        return this.page_changed.connect((cur_from, cur_to) => {
            bool call = true;

            if (from != null)
                call = call && (cur_from == from);
            if (to != null)
                call = call && (cur_to == to);
            
            if (call)
                cb(cur_from, cur_to);
        });
    }

    public WizardPageProps? page_props(string name)
    {
        var? child = this.stack.get_child_by_name(name);

        if (child != null)
        {
            Gtk.StackPage current_page = this.stack.get_page(child);
            return current_page.get_data<WizardPageProps>("props");
        }
        else
        {
            return null;
        }
    }

    // Nested stuff

    public static string FINAL_PAGE = "quit";

    [GtkTemplate (ui = "/com/github/albert-tomanek/aero/templates/wizardoptionbutton.ui")]
    public class OptionButton : Gtk.Button
    {
        public string title { get; set; }
        public string description { get; set; }

        [GtkChild] Gtk.Label label_title;
        [GtkChild] Gtk.Label label_desc;

        public OptionButton(string title, string desc)
        {
            this.title = title;
            this.description = desc;
        }

        //  static construct {
        //      set_css_name("navbuttons");
        //  }    

        construct {
            this.add_css_class("optionbutton");

            this.bind_property("title", label_title, "label", BindingFlags.SYNC_CREATE);
            this.bind_property("description", label_desc, "label", BindingFlags.SYNC_CREATE);
        }
    }
}
