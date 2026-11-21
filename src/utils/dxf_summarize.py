import ezdxf
import os


def summarize_dxf(file_path):
    if not os.path.exists(file_path):
        print(f"ERROR: Could not find file at {file_path}")
        return

    print(f"Loading {file_path}...\n")

    try:
        doc = ezdxf.readfile(file_path)
    except Exception as e:
        print(f"Failed to read DXF: {e}")
        return

    msp = doc.modelspace()

    # 1. Analyze Layers
    print("=========================================")
    print(" 1. LAYERS DETECTED")
    print("=========================================")
    for layer in doc.layers:
        print(f" - {layer.dxf.name}")

    # 2. Analyze Entities in Modelspace
    print("\n=========================================")
    print(" 2. ENTITY TYPES (What is drawn?)")
    print("=========================================")
    entity_counts = {}
    layer_counts = {}

    for entity in msp:
        # Tally entity types (LINE, LWPOLYLINE, INSERT, etc.)
        e_type = entity.dxftype()
        entity_counts[e_type] = entity_counts.get(e_type, 0) + 1

        # Tally which layers are actually being used
        l_name = entity.dxf.layer
        layer_counts[l_name] = layer_counts.get(l_name, 0) + 1

    for e_type, count in entity_counts.items():
        print(f" - {e_type}: {count} found")

    # 3. Analyze Layer Usage
    print("\n=========================================")
    print(" 3. ACTIVE GEOMETRY PER LAYER")
    print("=========================================")
    for l_name, count in layer_counts.items():
        print(f" - Layer '{l_name}': {count} entities")

    # 4. Analyze Blocks (INSERTS)
    print("\n=========================================")
    print(" 4. BLOCKS (Doors, Windows, etc.)")
    print("=========================================")
    block_found = False
    for block in doc.blocks:
        # Ignore AutoCAD's hidden/anonymous blocks (they start with *)
        if not block.name.startswith('*') and not block.name.startswith('A$C'):
            print(f" - Block Definition: {block.name}")
            block_found = True

    if not block_found:
        print(" - No standard blocks found.")


if __name__ == "__main__":
    # --- CHANGE THIS TO YOUR DIRECTORY PATH ---
    DIRECTORY_PATH = r"C:\Users\tglla\OneDrive - Universidad de La Laguna\Desktop\EG Aplicada a la Arquitectura\Floor Plan"

    # Iterate over all .dxf files in the directory
    dxf_files = [f for f in os.listdir(DIRECTORY_PATH) if f.lower().endswith('260320.dxf')]

    if not dxf_files:
        print(f"No .dxf files found in {DIRECTORY_PATH}")
    else:
        print(f"Found {len(dxf_files)} .dxf file(s)\n")
        for dxf_file in dxf_files:
            file_path = os.path.join(DIRECTORY_PATH, dxf_file)
            summarize_dxf(file_path)
            print("\n" + "="*60 + "\n")