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
	[GtkChild] Gtk.Box   statusbar;
	[GtkChild] Gtk.Adjustment zoom_adjustment;
	[GtkChild] Gtk.Label zoom_label;
	[GtkChild] Gtk.Label size_label;
	[GtkChild] Gtk.Label selection_size_label;

	[GtkChild] Gtk.Grid new_dialog;
	[GtkChild] Gtk.SpinButton new_width;
	[GtkChild] Gtk.SpinButton new_height;

	public Canvas canvas { get; set; }

	construct {
		this.register_actions();

		this.titlebar = new Aero.HeaderBar();
		(this.titlebar as Aero.HeaderBar).add_action("save-as-default");
		(this.titlebar as Aero.HeaderBar).add_action("undo");
		(this.titlebar as Aero.HeaderBar).add_action("redo");

		this.notify["canvas"].connect(() => {
			var old = this.canvas_box.get_first_child();
			if (old != null)
				this.canvas_box.remove(old);
			this.canvas_box.append(this.canvas);
			this.canvas.show();

			this.size_label.label = @"$(canvas.width) × $(canvas.height)px";

			this.zoom_adjustment.bind_property("value", this.canvas, "scale", BindingFlags.BIDIRECTIONAL|BindingFlags.SYNC_CREATE);

			//
			var cont = new Gtk.EventControllerMotion();
			cont.leave.connect(() => { this.selection_size_label.label = ""; });
			cont.motion.connect((x, y) => { this.selection_size_label.label = "%0.2f, %0.2f".printf(x / canvas.scale, y / canvas.scale); });
			this.canvas.add_controller(cont);
		});
		this.canvas = new Canvas(400, 400);

		this.zoom_adjustment.notify["value"].connect(() => {
			this.zoom_label.label = "%0.1f%%".printf(this.zoom_adjustment.value * 100);
		});

		this.ribbon.menu_model = (new Gtk.Builder.from_resource("/com/github/albert-tomanek/aero/apps/mspaint/menu.ui")).get_object("menu") as GLib.MenuModel;
	}

	void register_actions()
	{
		Aero.ActionEntry[] actions = {
			{ "help", this.show_help, null, null, null, "shell32_24", "Help", null },
			{ "about", this.show_help, null, null, null, "mspaint_60208", "Abou_t Paint", null },

			{ "new", this.dia_new_document, null, null, null, "mspaint_60008", "New", "Create a new picture." },
			{ "open", niy, null, null, null, "mspaint_60016", "Open", null },
			{ "save", niy, null, null, null, "mspaint_60024", "Save", null },
			{ "save-as-default", this.save_as_svg, null, null, null, "mspaint_60040", "Save _as", "Save the current picture as a new file." },
			{ "save-as-png", niy, null, null, null, "mspaint_60064", "Save as _PNG", "Standard image file" },
			{ "save-as-svg", this.save_as_svg, null, null, null, "mspaint_60080", "Save as _SVG", "This file type can be scaled to any size" },

			{ "print", niy, null, null, null, "mspaint_60096", "Print", null },
			{ "import-scanner", niy, null, null, null, "mspaint_60136", "Fro_m scanner or camera", null },
			{ "email", niy, null, null, null, "mspaint_60144", "Sen_d in e-mail", null },

			{ "set-desktopbg", niy, null, null, null, "mspaint_60168", "Set as desktop _background", null },
			{ "show-imgprops", niy, null, null, null, "mspaint_60200", "Prop_erties", null },

			{ "undo", this.undo, null, null, null, "mspaint_38004", "Undo", null },
			{ "redo", niy, null, null, null, "mspaint_38008", "Redo", null },
			{ "clear", () => { this.canvas.clear(); }, null, null, null, "mspaint_60008", "Clear", null },

			{ "cut", niy, null, null, null, "mspaint_60335", "Cut", null },
			{ "copy", niy, null, null, null, "mspaint_60340", "Copy", null },
			{ "copy-selection", niy, null, null, null, "mspaint_60343", "Copy selection", null },
			{ "paste", niy, null, null, null, "mspaint_60320", "Paste", "Paste image data from the clipboard." },

			{ "hflip", () => { this.canvas.hflip(); }, null, null, null, "mspaint_60407", "Flip _horizontally", null },
			{ "vflip", () => { this.canvas.vflip(); }, null, null, null, "mspaint_60403", "Flip _vertically", null },

			{ "zoom-in", () => { this.zoom_adjustment.value += 0.1; }, null, null, null, "mspaint_60520", "Zoom in", "" },
			{ "zoom-out", () => { this.zoom_adjustment.value -= 0.1; }, null, null, null, "mspaint_60528", "Zoom out", "" },
			{ "100pct", niy, null, null, null, "mspaint_60488", "100 %", "" },
			{ "fullscreen", () => { if (this.is_fullscreen()) { this.unfullscreen(); } else { this.fullscreen(); } }, null, null, null, "mspaint_60504", "Full screen", "" },
			{ "show-rulers", null, "b", "false", null, "", "Rulers", "" },
			{ "show-gridlines", null, "b", "false", null, "", "Gridlines", "" },
			{ "show-statusbar", () => {}, "b", "true", (act, val) => { this.statusbar.visible = val.get_boolean(); }, "", "Status bar", "" },
		};
		Aero.ActionEntry.add(actions, this);
	}

	void undo()
	{
		if (this.canvas.strokes.length > 0)
		{
			this.canvas.strokes.remove_index(this.canvas.strokes.length - 1);
			this.canvas.queue_draw();
		}
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

	void save_as_svg()
	{
		var ff = new Gtk.FileFilter() { name = "SVG files" };
		ff.add_suffix(".svg");
		var dia = new Gtk.FileChooserDialog("Save as SVG", this, Gtk.FileChooserAction.SAVE, "_Cancel", 0, "_Save", 1) {
			filter = ff,
		};
		dia.show();

		dia.response.connect((rc) => {
			try {
				if (rc == 1)
				{
					var file = dia.get_file();
					var stream = file.append_to(FileCreateFlags.REPLACE_DESTINATION);

					stream.write(@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n".data);
					stream.write(@"<svg width=\"$(this.canvas.width)\" height=\"$(this.canvas.height)\"><g>\n".data);

					stream.write(@"<rect x=\"0\" y=\"0\" width=\"$(this.canvas.width)\" height=\"$(this.canvas.height)\" style=\"fill:#ffffff;\" />\n".data);

					foreach (var stroke in this.canvas.strokes)
					{
						string path = "M ";

						for (int i = 0; i < stroke.points.length; i += 2)
						{
							double x = stroke.points[i];
							double y = stroke.points[i+1];

							path += @"$x,$y ";
						}

						stream.write(@"<path d=\"$path\" style=\"fill:none; stroke:#000000; stroke-width: $(stroke.line_width)px; stroke-linecap:round; stroke-linejoin:round;\" />\n".data);
					}

					stream.write(@"</g></svg>\n".data);
					stream.close();
				}
			}
			catch (GLib.IOError e) {
				var msg = new Aero.MsgBox.error(this, "Error", @"Error writing SVG file.\n$(e.message)");
				msg.show();
			}
			catch (GLib.Error e) {
				var msg = new Aero.MsgBox.error(this, "Error", @"Error writing SVG file.\n$(e.message)");
				msg.show();
			}
		
			dia.close();
		});
	}

	void show_help()
	{
		var text = (
			"This is an application made to showcase the use of libaero.\n" +
			"\n" +
			"Copyright (C) 2023,  Albert Tománek and contributors."
		);
		(new Aero.MsgBox.info(this, "Help with Aero Paint", text)).show();
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

	public GenericArray<Stroke?> strokes = new GenericArray<Stroke?>();

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

		set_size_request(width, height);

		this.notify["scale"].connect(() => {
			set_size_request((int)(scale * (double) width), (int)(scale * (double) height));
		});	

		this.notify["undo-count"].connect(() => {
			this.queue_draw();
		});

		set_draw_func((da, cr, w, h) => {
			cr.rectangle(0, 0, w, h);
			cr.set_source_rgb(255, 255, 255);
			cr.fill();

			foreach (var stroke in strokes)
			{
				stroke.render(cr, w, h, scale);
			}
		});

		var ges = new Gtk.GestureDrag();
		this.add_controller(ges);

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
			st.points += n;
			n = _origin_y + y;
			st.points += n;

			this.queue_draw();
		});

		var ges2 = new Gtk.GestureClick() {
			button = Gdk.BUTTON_SECONDARY,
		};
		this.add_controller(ges2);

		var popover = new Gtk.PopoverMenu.from_model(
			(new Gtk.Builder.from_resource("/com/github/albert-tomanek/aero/apps/mspaint/rclick.ui")).get_object("menu") as GLib.MenuModel
		) {
			has_arrow = false,
			halign = Gtk.Align.START,
		};
		popover.set_parent(this);
		ges2.released.connect((n, x, y) => {
			popover.set_pointing_to(Gdk.Rectangle() { x = (int) x, y = (int) y, width = 0, height = 0 });
			popover.popup();
		});
	}

	public void hflip()
	{
		double half_w = this.width / 2;

		foreach (var stroke in strokes)
		{
			for (int i = 0; i < stroke.points.length; i += 2)
				stroke.points[i] = half_w + (half_w - stroke.points[i]);
		}

		this.queue_draw();
	}

	public void vflip()
	{
		double half_h = this.height / 2;

		foreach (var stroke in strokes)
		{
			for (int i = 1; i < stroke.points.length; i += 2)
				stroke.points[i] = half_h + (half_h - stroke.points[i]);
		}

		this.queue_draw();
	}

	public void clear()
	{
		this.strokes = new GenericArray<Stroke?>();
		this.queue_draw();
	}

	public class Stroke
	{
		public double[] points = {};
		public double line_width = 1;

		public double c_r = 0;
		public double c_g = 0;
		public double c_b = 0;

		public void render(Cairo.Context cr, int w, int h, double s)
		{
			for (uint i = 0; i < points.length; i += 2)
			{
				var x = points[i] * s;
				var y = points[i+1] * s;

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
