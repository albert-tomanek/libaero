[GtkTemplate (ui = "/com/github/albert-tomanek/aero/templates/wizard.ui")]
public class Aero.Wizard : Gtk.Window
{
    [GtkChild] Gtk.Box header;

    [GtkChild] private Gtk.Label title_label;
    [GtkChild] private Gtk.Image icon;
    Gtk.Button back;
    [GtkChild] Gtk.Button next;
    [GtkChild] Gtk.Button cancel;
    [GtkChild] public Gtk.Stack stack;

    [GtkChild] public Gtk.Box footer;

    public bool can_next { get; set; default = true; }

    public uint page { get; set; default = 0; }
    public bool last_page { get { return (page == this.stack.pages.get_n_items() - 1); } }

    construct {
        this.resizable = false;

        ((Gtk.Widget) this).realize.connect(() => {    // Gtk.Dialog installs its own headerbar in its constructor so we have to run after that.
            var titlebar = new Aero.HeaderBar.with_contents(header);
            this.bind_property("title", this.title_label, "label", BindingFlags.SYNC_CREATE);
            titlebar.icon.bind_property("paintable", this.icon, "paintable", BindingFlags.SYNC_CREATE);
            titlebar.show_info = false;

            this.titlebar = titlebar;

            this.page = 0;
        });

        back = new Orb() {
            icon = Gdk.Texture.from_resource("/com/github/albert-tomanek/aero/images/orb_arrow_left.svg")
        };
        back.sensitive = false;
        header.prepend(back);

        /* Bind UI */
        this.notify["page"].connect(() => {
            this.stack.visible_child = (this.stack.pages.get_item(this.page) as Gtk.StackPage).child;

            this.back.sensitive = (page != 0);
            this.next.visible   = !last_page;
            this.cancel.label   = last_page ? "_Finish" : "_Cancel";
        });
        
        this.bind_property("can_next", this.next, "sensitive");
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

    public void next_page()
    {
        this.page += 1;
    }

    public void prev_page()
    {
        this.page -= 1;
    }

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
