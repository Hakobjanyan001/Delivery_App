from PIL import Image

def process_img():
    # Load image and ensure it has an alpha channel
    img = Image.open('assets/images/masoor_branch.png').convert("RGBA")
    data = img.getdata()
    
    new_data = []
    for item in data:
        r, g, b, a = item
        # If the pixel is mostly red (r is much higher than g and b), keep it
        if r > 100 and r > g + 50 and r > b + 50:
            new_data.append((r, g, b, a))
        # Else if it's visible (alpha > 0), turn it white (to make text white)
        elif a > 0:
            # We preserve the original alpha to keep anti-aliasing smooth
            new_data.append((255, 255, 255, a))
        else:
            new_data.append(item)
            
    img.putdata(new_data)
    img.save('assets/images/masoor_branch_fixed.png')

process_img()
