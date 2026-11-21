import ezdxf
import json


def extract_bim_to_json(dxf_path, json_output_path):
    doc = ezdxf.readfile(dxf_path)
    msp = doc.modelspace()

    # Structure the payload exactly how the Revit listener will expect it
    payload = {
        "exterior_walls": [],
        "interior_walls": [],
        "doors": []
    }

    for entity in msp:
        layer = entity.dxf.layer
        etype = entity.dxftype()

        # 1. Process Exterior Walls
        if layer == "BEM-WALLS-EXT" and etype == 'LWPOLYLINE':
            pts = [p[:2] for p in entity.get_points()]
            # Break polyline into individual line segments
            for i in range(len(pts) - 1):
                payload["exterior_walls"].append({
                    "start": [round(pts[i][0], 2), round(pts[i][1], 2)],
                    "end": [round(pts[i + 1][0], 2), round(pts[i + 1][1], 2)]
                })

        # 2. Process Interior Walls
        elif layer == "BEM-WALLS-INT" and etype == 'LWPOLYLINE':
            pts = [p[:2] for p in entity.get_points()]
            for i in range(len(pts) - 1):
                payload["interior_walls"].append({
                    "start": [round(pts[i][0], 2), round(pts[i][1], 2)],
                    "end": [round(pts[i + 1][0], 2), round(pts[i + 1][1], 2)]
                })

        # 3. Process Doors
        elif layer == "BEM-DOORS" and etype == 'INSERT':
            ipoint = entity.dxf.insert
            payload["doors"].append({
                "type": entity.dxf.name,
                "location": [round(ipoint.x, 2), round(ipoint.y, 2)]
            })

    # Save to file for human inspection before sending
    with open(json_output_path, 'w') as f:
        json.dump(payload, f, indent=4)

    print(f"SUCCESS: Data extracted and formatted to {json_output_path}")


if __name__ == "__main__":
    # Update these paths as needed
    file_path = r"C:\Users\tglla\OneDrive - Universidad de La Laguna\Desktop\EG Aplicada a la Arquitectura\Floor Plan\Floor_Plan_260320.dxf"

    extract_bim_to_json(file_path, "payload.json")