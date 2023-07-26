// I know Gtk deprecated this after Gtk3 but Aero apps need it.

namespace Aero
{
    // Needed to appease the compiler
    public delegate void SimpleActionActivateCallback (SimpleAction action, Variant? parameter);
    public delegate void SimpleActionChangeStateCallback (SimpleAction action, Variant value);

    [Compact]
    public struct ActionEntry  
    {
        // Copied from GLib.ActionEntry
        unowned string name;
        unowned Aero.SimpleActionActivateCallback? activate;
        unowned string? parameter_type;
        unowned string? state;
        unowned Aero.SimpleActionChangeStateCallback? change_state ;

        // Our own
        unowned string icon;
        unowned string title;
        unowned string? description;

        public static void add(Aero.ActionEntry[] entries, GLib.ActionMap map)
        {
            foreach (var ent in entries)
            {
                GLib.SimpleAction act;
                VariantType? vtype = (ent.parameter_type != null) ? new VariantType(ent.parameter_type) : null;

                if (ent.state == null)
                {
                    act = new GLib.SimpleAction(ent.name, vtype);
                }
                else
                {
                    act = new GLib.SimpleAction.stateful(ent.name, vtype, Variant.parse(vtype, ent.state));
                }

                if (ent.activate != null)
                    act.activate.connect((param) => {
                        ent.activate(act, param);
                    });
                if (ent.change_state != null)
                    act.activate.connect((param) => {
                        ent.change_state(act, param);
                    });

                act.set_data<string>("icon", ent.icon);
                act.set_data<string>("title", ent.title);
                act.set_data<string>("description", ent.description);

                map.add_action(act);
            }
        }

        public static GLib.Action? find(Gtk.Widget? wij, string action_name)
        {
            GLib.Action? action = null;

            if (wij != null)
            {
                var aw = wij.root as Gtk.ApplicationWindow;

                if (aw != null)
                    action = aw.lookup_action(action_name);
            }

            if (action == null)
                critical("Could not find action `%s`.", action_name);

            return action;
        }

        public static Aero.ActionEntry extract(GLib.Action? act)
        {
            Aero.ActionEntry ent = {};

            if (act != null)
            {
                ent.name           = act.name;
                ent.activate       = (Aero.SimpleActionActivateCallback) act.activate;
                //  ent.parameter_type = act.parameter_type;
                //  ent.state          = act.state;
                ent.change_state   = (Aero.SimpleActionChangeStateCallback) act.change_state;
        
                ent.icon  = act.get_data<string>("icon");
                ent.title = act.get_data<string>("title");
                ent.description = act.get_data<string>("description");
            }
            else
            {
                ent.icon = "image-missing";
                ent.title = "????";
            }

            return ent;
        }
    }
}