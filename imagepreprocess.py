## opens image sequence (gif) and saves individual frames
## brandon sim, 12/08/2012
import Image
import os, sys

def save_JPEG_sequence(filename):
	im = Image.open(filename)
	counter = 0
	try:
	    while True:
	    	im = Image.open(filename)

	    	while im.tell() < counter:
	        	im.seek(im.tell()+1)

	        if im.mode != "RGB":
	        	im = im.convert("RGB")

	        # saves files in sequenceDir
	        os.chdir("sequenceDir")
	        im.save("t2_axial" + str(counter) + ".jpg", "JPEG")
	        os.chdir("..")
	        # returns back to original directory

	        print "t2_axial" + str(counter)
	        counter+=1
	except EOFError:
	    pass # end of sequence

	im.close()
	return

# main
if __name__ == "__main__":
	save_JPEG_sequence("t2_axial.gif")

