import yaml
from PIL import Image
import math

def yaml_as_python(val):
    """Convert YAML to dict"""
    try:
        return yaml.load_all(val)
    except yaml.YAMLError as exc:
        return exc

new_frame_size = 23
center = math.floor(new_frame_size / 2)

img = Image.open("rabbit_sprite_sheet.png")
new_img = Image.new("RGBA", (9 * new_frame_size, 4 * new_frame_size))

with open('rabbit-data.yml','r') as input_file:
    results = yaml_as_python(input_file)
    frame = 1
    new_frame = 1
    face_right = True
    for value in results:
        if face_right:
            print(value)
            slice = img.crop((value["x"], value["y"], value["x"] + value["width"],  value["y"] + value["height"]))
            new_x = ((new_frame - 1) % 9) * new_frame_size
            new_y = math.floor((new_frame - 1) / 9) * new_frame_size
            new_img.paste(slice, (new_x, new_y))

            # top left corner green
            new_img.putpixel((new_x,new_y), (0,255,0,255))

            # center blue
            new_img.putpixel((new_x + center,new_y + center), (0,0,255,255))

            # hot spot red
            new_img.putpixel((new_x + center + value["hotspot_x"],new_y + center + value["hotspot_y"]), (255,0,0,255))

            new_frame += 1
        frame += 1
        if frame % 9 == 0: face_right = not face_right
    new_img.save("test.png")
