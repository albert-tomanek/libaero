# GENERATED MOSTLY USING ChatGPT
# Unfortunately neither Glade nor Cambalache have a UI to edit GMenuModels, so we generated one that does it ourselves.
# Don't ask why this doens't use Gtk

# This is the schema for GMenu xml definitions
# <?xml encoding="UTF-8"?>
#
# <!-- This is the root element -->
# <!ELEMENT menu (item|submenu|section)*>
# <!ATTLIST menu
#   xmlns CDATA #FIXED ''
#   id ID #REQUIRED
#   domain CDATA #IMPLIED>
#
# <!ELEMENT item (attribute|link)*>
# <!ATTLIST item
#   xmlns CDATA #FIXED ''
#   id ID #IMPLIED>
# <!-- `item` elements can contain attributes with the following IDs (make these into a dropdown menu)
#     "label"
#     "use-markup"
#     "action"
#     "target"
#     "icon"
#     "submenu-action"
#     "hidden-when"
#     "custom"
# -->
#
# <!ELEMENT attribute ((#PCDATA)?)*>
# <!ATTLIST attribute
#   xmlns CDATA #FIXED ''
#   name CDATA #REQUIRED
#   type CDATA #IMPLIED
#   translatable (yes|no) #IMPLIED
#   context CDATA #IMPLIED
#   comments CDATA #IMPLIED>
#
# <!ELEMENT link (item)*>
# <!ATTLIST link
#   xmlns CDATA #FIXED ''
#   id ID #IMPLIED
#   name CDATA #REQUIRED>
#
# <!ELEMENT submenu (attribute|item|submenu|section)*>
# <!ATTLIST submenu
#   xmlns CDATA #FIXED ''
#   id ID #IMPLIED>
# <!-- `section` elements can contain attributes with the following IDs (make these into a dropdown menu)
#     "label"
#     "icon"
# -->
#
# <!ELEMENT section (attribute|item|submenu|section)*>
# <!ATTLIST section
#   xmlns CDATA #FIXED ''
#   id ID #IMPLIED>
# <!-- `section` elements can contain attributes with the following IDs (make these into a dropdown menu)
#     "label"
#     "display-hint"
#     "text-direction"
# -->

import tkinter as tk
from tkinter import ttk
from tkinter import filedialog
from tkinter import messagebox
import xml.etree.ElementTree as ET
import uuid
import sys

class App:
    def __init__(self, path=None):
        self.filepath = path

        self.root = tk.Tk()
        self.root.title("GMenuModel Editor")
        
        # Create the root menu element
        self.xml_data = ET.Element("menu")
        self.xml_data.set("id", "menu")
        
        # Create the item-to-element mapping dictionary
        self.item_to_element = {}
        self.attr_entries = []  # attribute entry widgets

        # Build the user interface
        self.make_ui()
                
        # Connect UI callbacks to the loaded document
        self.connect_callbacks()

        if self.filepath:
            self.load_xml_file(self.filepath)

        
    def make_ui(self):
        self.root.grid_rowconfigure(0, weight=1)
        self.root.grid_columnconfigure(0, weight=1)

        # Create a frame to hold the tree view
        tree_frame = tk.Frame(self.root)
        tree_frame.grid(column=0, row=0, columnspan=1, rowspan=1, sticky='NSEW')

        # Create a scrollable tree view
        tree_scrollbar = tk.Scrollbar(tree_frame)
        tree_scrollbar.pack(side=tk.RIGHT, fill=tk.BOTH, expand=False)

        self.tree = ttk.Treeview(tree_frame, yscrollcommand=tree_scrollbar.set)
        self.tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        tree_scrollbar.config(command=self.tree.yview)

        # Just info about the toplevel element
        self.menu_info_label = tk.Label(self.root)
        self.menu_info_label.grid(column=1, row=0, columnspan=1, rowspan=1, sticky='N')

        self.table_frame = tk.Frame(self.root)

        # Create a frame to hold the buttons
        buttons_frame = tk.Frame(self.root)
        buttons_frame.grid(column=0, row=1, columnspan=3, rowspan=1, sticky='W')

        # Create buttons for adding and deleting elements
        self.add_button = tk.Button(buttons_frame, text="Add Element", command=self.add_element)
        self.add_button.pack(side=tk.LEFT, fill='x')

        # Create a variable to store the selected element type
        self.selected_element = tk.StringVar(buttons_frame)

        # Create a dropdown menu with the element types from the DTD
        element_types = ["item", "submenu", "section"]  # Replace with your actual element types from the DTD
        element_dropdown = tk.OptionMenu(buttons_frame, self.selected_element, *element_types)
        element_dropdown.pack(side=tk.LEFT, fill='x')

        self.delete_button = tk.Button(buttons_frame, text="Delete Element", command=self.delete_element)
        self.delete_button.pack(side=tk.LEFT, pady=10, fill='x')

        # Create the file menu
        menu_bar = tk.Menu(self.root)
        self.root.config(menu=menu_bar)

        file_menu = tk.Menu(menu_bar)
        menu_bar.add_cascade(label="File", menu=file_menu)

        file_menu.add_command(label="Open", command=lambda: self.load_xml_file(
            filedialog.askopenfilename(filetypes=[("UI Files", "*.ui")])
        ))
        file_menu.add_command(label="Save", command=lambda: self.save_xml_file(
            filedialog.asksaveasfilename(initialfile=self.filepath, defaultextension=".ui", filetypes=[("UI Files", "*.ui")])
        ))
        file_menu.add_command(label="Exit", command=self.root.quit)

        # Populate the tree view with XML elements
        self.populate_tree_view(self.xml_data)

    def populate_tree_view(self, element, parent=""):
        # Recursively populate the tree view with XML elements
        item_id = self.tree.insert(parent, "end", text=element.tag, open=True)

        # Store the mapping between the tree item and XML element
        self.item_to_element[item_id] = element

        for child in element:
            self.populate_tree_view(child, parent=item_id)

    def connect_callbacks(self):
        # Connect the "Add Element" button callback
        add_button = self.add_button
        add_button.config(command=self.add_element)

        # Connect the "Delete Element" button callback
        delete_button = self.delete_button
        delete_button.config(command=self.delete_element)

        # Connect the tree view selection callback
        tree = self.tree
        tree.bind("<<TreeviewSelect>>", self.treeview_select_callback)

    def treeview_select_callback(self, event):
        # Get the selected item from the tree view
        tree = event.widget
        selected_item = tree.focus()

        if selected_item in self.item_to_element:
            element = self.item_to_element[selected_item]
        else:
            element = self.xml_data  # Use the root 'menu' element from the XML data

        if element is not None:
            # Clear the existing widgets in the table_frame
            self.clear_table_view()

            if element.tag == 'menu':
                self.menu_info_label.config(text='Builder id="menu"')
            else:
                self.menu_info_label.config(text="")

            self.populate_table_view(element)


    def clear_table_view(self):
        # Create a frame to hold the table of entry widgets
        self.table_frame.destroy()
        self.table_frame = tk.Frame(self.root)
        self.table_frame.grid(column=1, row=0, columnspan=1, rowspan=1, sticky='N')

        # Clear the attribute names list and entry widgets list
        self.attr_names = []
        self.attr_entries = []

    def get_element_attributes(self, element_name):
        # Dictionary mapping element names to their attributes
        dtd_attributes = {
            "item": ["label", "use-markup", "action", "target", "icon", "submenu-action", "hidden-when", "custom"],
            "submenu": ["label", "icon"],
            "section": ["label", "display-hint", "text-direction"]
        }

        if element_name in dtd_attributes:
            return dtd_attributes[element_name]
        else:
            return []

    @staticmethod
    def find_attr(element, name):
        # Find the attribute element with the specified name within the given element
        for attr_element in element.findall('attribute'):
            attr_name = attr_element.attrib['name']
            if attr_name == name:
                return attr_element
        return None


    def update_element_attribute(self, element, name, value):
        # Update the attribute value for the specified name within the given element
        attr_element = self.find_attr(element, name)

        if attr_element is None:
            # Create a new attribute element if it doesn't exist
            attr_element = ET.Element('attribute')
            attr_element.set('name', name)
            element.append(attr_element)

        attr_element.text = value

    def update_element_attributes(self, element):
        attributes = self.get_element_attributes(element.tag)

        for name, entry in zip(attributes, self.attr_entries):
            if entry.get():
                self.update_element_attribute(element, name, entry.get())

    def populate_table_view(self, element):
        # Get the attributes for the element
        attributes = self.get_element_attributes(element.tag)

        # Iterate over the attributes dictionary
        for name in attributes:
            # Create a label widget for the attribute name
            label = tk.Label(self.table_frame, text=name)
            label.grid(column=0, row=len(self.attr_entries), padx=5, pady=5)

            # Create an entry widget for the attribute value
            entry = tk.Entry(self.table_frame)
            entry.grid(column=1, row=len(self.attr_entries), padx=5, pady=5)

            attr = self.find_attr(element, name)
            if attr != None:
                entry.insert(0, attr.text.strip())
            
            # Update the XML tree whenever this is edited
            entry.bind("<FocusOut>", lambda _: self.update_element_attributes(element))

            # Add the attribute entry widgets to the list
            self.attr_entries.append(entry)

    def add_element(self):
        # Get the selected item from the tree view
        try:
            selected_item = self.tree.selection()[0]
        except IndexError:
            messagebox.showerror("Error", "No parent element selected.")
            return

        if selected_item:
            # Prompt the user to choose the element type
            element_type = self.selected_element.get()
            if element_type:
                # Get the parent element based on the selected item
                parent_element = self.item_to_element[selected_item]
                # if parent_item:
                #     parent_element = self.item_to_element[parent_item]
                # else:
                #     parent_element = self.xml_data  # Root 'menu' element

                # Create the new element
                new_element = ET.Element(element_type)

                # Append the new element as a child to the parent element
                parent_element.append(new_element)

                # Insert the new element into the tree view
                new_item = self.tree.insert(selected_item, "end", text=element_type)

                # Update the item_to_element mapping
                self.item_to_element[new_item] = new_element

    def get_element_from_tree_item(self, item):
        # Get the XML element associated with the given tree item
        tree = self.tree
        element_name = tree.item(item, "text")
        parent_item = tree.parent(item)

        if parent_item:
            parent_element = self.get_element_from_tree_item(parent_item)
            return parent_element.find(element_name)
        else:
            return self.xml_data.find(element_name)

    def delete_element(self):
        try:
            selected_item = self.tree.selection()[0]
        except IndexError:
            messagebox.showerror("Error", "No element selected.")
            return

        if selected_item:
            # Get the XML element associated with the selected item
            element = self.item_to_element[selected_item]

            # Get the parent item of the selected item
            parent_item = self.tree.parent(selected_item)

            # Check if the parent item exists in the mapping
            if parent_item in self.item_to_element:
                parent_element = self.item_to_element[parent_item]
            else:
                messagebox.showerror("Error", "Can't delete root element.")
                return

            # Remove the element from its parent element
            parent_element.remove(element)

            # Remove the item from the tree view
            self.tree.delete(selected_item)

            # Remove the element from the item_to_element mapping
            del self.item_to_element[selected_item]

    def load_xml_file(self, file_path):
        if file_path:
            try:
                # Clear the tree view
                self.clear_tree_view()

                # Parse the XML file
                root = ET.parse(file_path).getroot()

                if root.tag != 'interface':
                    messagebox.showerror("Error", "File is not a Gtk UI file.")
                    return

                self.xml_data = root.find('*')

                # Clear the existing mapping
                self.item_to_element.clear()

                # Re-populate the tree view and update the item_to_element mapping
                self.populate_tree_view(self.xml_data)

            except ET.ParseError:
                # Handle parsing errors
                messagebox.showerror("Error", "Failed to parse the XML file.")

    def clear_tree_view(self):
        # Clear the tree view
        tree = self.tree
        tree.delete(*tree.get_children())

    def populate_tree_view(self, xml_data, parent_item=""):
        if not parent_item:
            # Create a unique ID for the root menu element
            root_id = str(uuid.uuid4())

            # Insert the root menu element into the tree view
            root_item = self.tree.insert(parent_item, "end", text="menu", values=(root_id,))
            
            # Add the root menu element to the item_to_element mapping
            self.item_to_element[root_item] = xml_data

            self.populate_tree_view(xml_data, root_item)
        else:
            for element in xml_data:
                if element.tag == "attribute":
                    continue

                # Create a unique ID for the element
                element_id = str(uuid.uuid4())

                # Insert the element into the tree view
                item_id = self.tree.insert(parent_item, "end", text=element.tag, values=(element_id,))
                
                # Add the element to the item_to_element mapping
                self.item_to_element[item_id] = element
                
                # Recursively populate the tree view for child elements
                self.populate_tree_view(element, item_id)

    def save_xml_file(self, file_path):
        if file_path:
            try:
                # Create an ElementTree object with the XML data
                root = ET.Element("interface")
                root.append(self.xml_data)
                tree = ET.ElementTree(root)

                # Save the XML data to the selected file
                tree.write(file_path, encoding="UTF-8", xml_declaration=True)

                messagebox.showinfo("Save Successful", "UI file saved successfully.")
            except:
                messagebox.showerror("Error", "Failed to save the UI file.")

    def run(self):
        self.root.mainloop()

if __name__ == '__main__':
    file = sys.argv[1] if len(sys.argv) > 1 else None

    app = App(file)
    app.run()
