struct Page
{
    Gtk.Widget content;
}

[GtkTemplate (ui = "/com/github/albert-tomanek/aero/templates/wizard.ui")]
public class Aero.Wizard : Gtk.Window
{
    [GtkChild] Gtk.Box header;

    [GtkChild] private Gtk.Label title_label;
    [GtkChild] private Gtk.Image icon;
    Gtk.Button back;
    [GtkChild] Gtk.Button next;
    [GtkChild] Gtk.Button cancel;
    [GtkChild] protected Gtk.Stack stack;

    [GtkChild] protected Gtk.Box footer;

    GLib.Queue<string> history = new GLib.Queue<string>();

    private string? next_name {
        get {
            Gtk.StackPage current_page = this.stack.get_page(this.stack.visible_child);
            return current_page.get_data<string?>("next_page");
        }
    }

    protected signal void need_can_next(string page_name, ref bool can_next);   // Handlers should only set the bool if the page name happens to be theirs.
    protected void update_can_next()    // Call this when the state of your page has changed. Your `need_can_next` handler will be called back.
    {
        bool can_next = true;   // If there's no handlers, assume the user can change pages at will
        this.need_can_next(this.stack.visible_child_name, ref can_next);
        this.next.sensitive = can_next;
    }

    protected signal void page_changed();

    construct {
        this.resizable = false;

        ((Gtk.Widget) this).realize.connect(() => {    // Gtk.Dialog installs its own headerbar in its constructor so we have to run after that.
            var titlebar = new Aero.HeaderBar.with_contents(header);
            this.bind_property("title", this.title_label, "label", BindingFlags.SYNC_CREATE);
            titlebar.icon.bind_property("paintable", this.icon, "paintable", BindingFlags.SYNC_CREATE);
            titlebar.show_info = false;

            this.titlebar = titlebar;
        });

        back = new Orb() {
            icon = Gdk.Texture.from_resource("/com/github/albert-tomanek/aero/images/orb_arrow_left.svg")
        };
        back.sensitive = false;
        header.prepend(back);

        /* Bind UI */
        this.page_changed.connect(() => {
            this.back.sensitive = (history.length != 0);
            this.next.visible   = (next_name != null);
            this.next.label     = (next_name == Wizard.FINAL_PAGE) ? "_Finish" : "_Cancel";
            this.cancel.visible = (next_name != Wizard.FINAL_PAGE);

            this.update_can_next();
        });
        
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

    public void add_page(string name, Gtk.Widget content, string? id_next)
    {
        var stack_page = this.stack.add_named(content, name);
        stack_page.set_data<string?>("next_page", id_next);

        if (this.stack.pages.get_n_items() == 1)    // We've just added the first page
        {
            this.stack.set_visible_child_name(name);
            this.page_changed();
        }
    }

    // This exists just for code clarity
    public delegate Gtk.Widget PageMakerFn();
    public void add_page_cb(string name, PageMakerFn cb, string? id_next)
    {
        this.add_page(name, cb(), id_next);
    }

    public void next_page()
    {
        if (next_name == null)
        {
            return;
        }
        else if (next_name == Wizard.FINAL_PAGE)
        {
            this.close();
        }
        else
        {
            this.goto_page(next_name);
        }
    }

    public void goto_page(string name)
    {
        this.history.push_head(this.stack.visible_child_name);
        this.stack.set_visible_child_name(name);
        this.page_changed();
    }

    public void prev_page()
    {
        if (this.history.length > 0)
        {
            string prev_name = this.history.pop_head();
            this.stack.set_visible_child_full(prev_name, Gtk.StackTransitionType.SLIDE_RIGHT);
            this.page_changed();
        }
    }

    // Nested stuff

    public static string FINAL_PAGE = "quit";

    [GtkTemplate (ui = "/com/github/albert-tomanek/aero/templates/wizardchoicebutton.ui")]
    public class ChoiceButton : Gtk.Button
    {
        public string title { get; set; }
        public string description { get; set; }

        [GtkChild] Gtk.Label label_title;
        [GtkChild] Gtk.Label label_desc;

        public ChoiceButton(string title, string desc)
        {
            this.title = title;
            this.description = desc;
        }

        construct {
            this.add_css_class("choicebutton");

            this.bind_property("title", label_title, "label", BindingFlags.SYNC_CREATE);
            this.bind_property("description", label_desc, "label", BindingFlags.SYNC_CREATE);
        }
    }
}
