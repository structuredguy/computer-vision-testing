import ezdxf


def export_revit_data(file_path):
    doc = ezdxf.readfile(file_path)
    msp = doc.modelspace()

    revit_data = []

    for entity in msp:
        layer = entity.dxf.layer
        etype = entity.dxftype()

        # Only look at our BIM layers
        if layer.startswith("BEM-"):
            if etype == 'LWPOLYLINE':
                # Get all vertices of the wall
                points = [p[:2] for p in entity.get_points()]
                revit_data.append({
                    'layer': layer,
                    'type': etype,
                    'coordinates': points
                })

            elif etype == 'INSERT':
                # Get the insertion point of the Door/Window
                ipoint = entity.dxf.insert
                name = entity.dxf.name
                revit_data.append({
                    'layer': layer,
                    'type': 'BLOCK',
                    'name': name,
                    'insertion_point': (ipoint.x, ipoint.y)
                })
    return revit_data


if __name__ == "__main__":
    # Update this to your file path
    file_path = r"C:\Users\tglla\OneDrive - Universidad de La Laguna\Desktop\EG Aplicada a la Arquitectura\Floor Plan\Floor_Plan_260320.dxf"
    
    extracted_data = export_revit_data(file_path)

    print(f"{'LAYER':<20} | {'TYPE':<10} | {'DETAILS'}")
    print("-" * 60)

    for item in extracted_data:
        if item['type'] == 'LWPOLYLINE':
            print(f"{item['layer']:<20} | {item['type']:<10} | {item['coordinates']}")
        elif item['type'] == 'BLOCK':
            print(f"{item['layer']:<20} | {item['type'] + ':' + item['name']:<10} | ({item['insertion_point'][0]:.2f}, {item['insertion_point'][1]:.2f})")
