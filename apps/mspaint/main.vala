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

		Gtk.IconTheme.get_for_display(Gdk.Display.get_default()).add_resource_path("/com/github/albert-tomanek/aero/apps/mspaint/icons/");

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
class MsPaint : Gtk.ApplicationWindow
{
	[GtkChild] Aero.Ribbon ribbon;
	[GtkChild] Gtk.Box   canvas_box;
	[GtkChild] Gtk.Adjustment zoom_adjustment;
	[GtkChild] Gtk.Label size_label;
	[GtkChild] Gtk.Label zoom_label;

	[GtkChild] Gtk.Grid new_dialog;
	[GtkChild] Gtk.SpinButton new_width;
	[GtkChild] Gtk.SpinButton new_height;

	public Canvas canvas { get; set; }

	construct {
		this.titlebar = new Aero.HeaderBar();

		this.notify["canvas"].connect(() => {
			var old = this.canvas_box.get_first_child();
			if (old != null)
				this.canvas_box.remove(old);
			this.canvas_box.append(this.canvas);
			this.canvas.show();

			this.size_label.label = @"$(canvas.width) × $(canvas.height)px";

			this.zoom_adjustment.bind_property("value", this.canvas, "scale", BindingFlags.BIDIRECTIONAL|BindingFlags.SYNC_CREATE);
		});
		this.canvas = new Canvas(400, 400);

		this.zoom_adjustment.notify["value"].connect(() => {
			this.zoom_label.label = "%0.1f%%".printf(this.zoom_adjustment.value * 100);
		});

		this.register_actions();

		this.ribbon.menu_model = (new Gtk.Builder.from_resource("/com/github/albert-tomanek/aero/apps/mspaint/menu.ui")).get_object("menu") as GLib.MenuModel;
	}

	void register_actions()
	{
		Aero.ActionEntry[] actions = {
			{ "help", this.show_help, null, null, null, "", "Help", "" },
			{ "new", this.dia_new_document, null, null, null, "", "New", "" },
			{ "zoom-in", () => { this.zoom_adjustment.value += 0.1; }, null, null, null, "mspaint_60520", "Zoom in", "" },
			{ "zoom-out", () => { this.zoom_adjustment.value -= 0.1; }, null, null, null, "mspaint_60528", "Zoom out", "" },
			{ "100pct", null, null, null, null, "mspaint_60488", "100 %", "" },
			{ "fullscreen", () => { 
				if (this.is_fullscreen())
					this.unfullscreen();
				else
					this.fullscreen();
			}, null, null, null, "mspaint_60504", "Full screen", "" },
		};

		Aero.ActionEntry.add(actions, this);

		SimpleAction simple_action = new SimpleAction ("simple-action", null);
		simple_action.activate.connect (() => {
			print ("Simple action %s activated\n", simple_action.get_name ());
		});
		this.add_action (simple_action);

	}

	void show_help()
	{
		var text = (
			"This is an application made to showcase the use of libaero.\n" +
			"\n" +
			"Copyright (C) 2023,  Albert Tománek"
		);
		(new Aero.MsgBox.info(this, "Help with Aero Paint", text)).show();
	}

	void dia_new_document()
	{
		var dia = new Aero.MsgBox.question(this, "New Painting", null, (rc) => {
			if (rc == 0)
			{
				this.canvas = new Canvas(
					(uint16) this.new_width.adjustment.value,
					(uint16) this.new_height.adjustment.value
				);
			}

			return false;
		});

		this.new_width.adjustment.value = 400;
		this.new_height.adjustment.value = 400;

		// Replace default widgets with our Grid
		var ca = dia.get_content_area();
		ca.remove(ca.get_first_child());
		ca.append(this.new_dialog);

		dia.show();
	}

	[GtkCallback]
	bool pixel_spin_button_output(Gtk.SpinButton but)
	{
		but.set_text(@"$(but.adjustment.value)px");
		return true;
	}

	//  [GtkCallback]	
	void niy()
	{
		var box = new Aero.MsgBox.error(this, "Not implemented", "This feature is not implemented yet.");
		box.show();
	}
}

class Canvas : Gtk.DrawingArea
{
	public uint16 width  { get; private set; }
	public uint16 height { get; private set; }
	public double scale  { get; set; default = 1.0; }

	GenericArray<Stroke?> strokes = new GenericArray<Stroke?>();

	double _origin_x;
	double _origin_y;

	public Canvas(uint16 w, uint16 h)
	{
		this.width = w;
		this.height = h;
	}

	construct {
		this.halign = Gtk.Align.START;
		this.valign = Gtk.Align.START;

		this.notify["scale"].connect(() => {
			set_size_request((int)(scale * (double) width), (int)(scale * (double) height));
		});	

		this.realize.connect(() => {
			set_size_request(width, height);
		});	

		set_draw_func((da, cr, w, h) => {
			cr.rectangle(0, 0, w, h);
			cr.set_source_rgb(255, 255, 255);
			cr.fill();

			foreach (var stroke in strokes)
			{
				//  message("rendering stroke %p %d", (void *)stroke, strokes.length);
				stroke.render(cr, w, h, scale);
			}
		});

		var ges = new Gtk.GestureDrag();
		ges.drag_begin.connect((x, y) => {
			this.strokes.add(new Stroke());

			x /= this.scale;
			y /= this.scale;

			_origin_x = x;
			_origin_y = y;
		});
		ges.drag_update.connect((x, y) => {
			var st = this.strokes.get(this.strokes.length - 1);

			x /= this.scale;
			y /= this.scale;

			double n;
			n = _origin_x + x;
			st.points.append_val(n);
			n = _origin_y + y;
			st.points.append_val(n);

			this.queue_draw();
		});
		this.add_controller(ges);
	}

	class Stroke
	{
		public Array<double> points = new Array<double>();
		public float line_width = 1;

		public double c_r = 0;
		public double c_g = 0;
		public double c_b = 0;

		public void render(Cairo.Context cr, int w, int h, double s)
		{
			for (uint i = 0; i < points.length; i += 2)
			{
				var x = points.index(i) * s;
				var y = points.index(i+1) * s;

				if (i == 0)
					cr.move_to(x, y);
				else {
					cr.line_to(x, y);
				}
			}

			cr.set_source_rgb(c_r, c_g, c_b);
			cr.set_line_width(line_width * s);
			cr.stroke();
		}
	}
}
