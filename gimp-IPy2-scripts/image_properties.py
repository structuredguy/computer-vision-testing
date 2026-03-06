img = gimp.image_list()[0]
if img:
    print "--- Image Properties ---"
    print "Name: %s" % img.name
    print "Dimensions: %d x %d px" % (img.width, img.height)
    print "Layers: %d" % len(img.layers)
    print "Precision: %s" % pdb.gimp_image_get_precision(img)
    
    # Calculate raw size for 8-bit RGBA
    raw_mb = (img.width * img.height * 4 * len(img.layers)) / (1024.0 * 1024.0)
    print "Est. Raw Pixel Data: %.2f MB" % raw_mb
else:
    print "No image opened."
