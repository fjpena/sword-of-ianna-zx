import pygame
import struct
import constants

"""
Sprite class
 
Simple sprite, loaded from a SevenuP file
 
package: ianna
"""

class SevSprite():
	""" SevenuP Sprite """

#	frames=[]
#	nframes=0
#	sizex=0
#	sizey=0

	def __init__ (self, filename):
		# Initialize SevenuP sprite parameters

		self.frames=[]
		self.nframes=0
		self.sizex=0
		self.sizey=0
		self.name = filename.split('/')[-1]

		if filename:
			# Read file and create list
			f=file(filename,"rb")
			buffer=f.read()
			f.close()			# Close file
			myarray=[]
			for i in range(0,len(buffer)):
				myarray+=struct.unpack("B",buffer[i])	# Convert file read into an array
			# Now we go and check the file
			if (buffer[0] == 'S') and (buffer[1] == 'e') and (buffer[2] == 'v') and (buffer[3]=='\0'):
				if constants.DEBUG:
					print "This is a SevenuP file"
			if (myarray[4] == 0) and (myarray[5] == 8):
				if constants.DEBUG:
					print "version 0.8"
			properties = myarray[7] * 256 + myarray[6]
			nframes = myarray[9] * 256 + myarray[8] + 1
			sizex = myarray [11] * 256 + myarray[10]
			sizey = myarray[13] * 256 + myarray[12]
			self.sizex = sizex
			self.sizey = sizey
			self.nframes = nframes
			bytesperframe=(sizex/8) * (sizey/8) * 9
			if constants.DEBUG:
				print filename,"Number of frames: ",nframes," properties: ",properties,"X: ",sizex,"Y: ",sizey,"bytes per frame: ",bytesperframe
			# Load frame as array
			i=14			# 14 is the beginning of the actual frames
			for j in range(0,nframes):
				#print i
				thisframe=[]
				for y in range(0,sizey/8):
					xline=[]
					for x in range(0,sizex/8):	
						char=[]
						for z in range(0,8):
							char.append(myarray[i])
							i=i+1
						# Ignore attribute for now
						i=i+1
						xline.append(char)
					thisframe.append(xline)

				# We have the frame in Spectrum format. Lets create a useable image
				goodframe=pygame.Surface((sizex,sizey),depth=32)
				ar=pygame.PixelArray(goodframe)
				for y in range(0,sizey/8):
					xline=thisframe[y]
					for x in range(0,sizex/8):
						char=xline[x]
						for z in (range(0,8)):
							# Bit 7
							value = ((char[z] & 128) >> 7) * 255
							ar[x*8,y*8+z] = (value,value,value,255-value)
							# Bit 6
							value = ((char[z] & 64) >> 6) * 255
							ar[x*8+1,y*8+z] = (value,value,value,value)
							# Bit 5
							value = ((char[z] & 32) >> 5) * 255
							ar[x*8+2,y*8+z] = (value,value,value,value)
							# Bit 4
							value = ((char[z] & 16) >> 4) * 255
							#ar[(y*8+z)*sizex+x*8+3] = (value,value,value,value)
							ar[x*8+3,y*8+z] = (value,value,value,value)
							# Bit 3
							value = ((char[z] & 8) >> 3) * 255
							#ar[(y*8+z)*sizex+x*8+4] = (value,value,value,value)
							ar[x*8+4,y*8+z] = (value,value,value,value)
							# Bit 2
							value = ((char[z] & 4) >> 2) * 255
							#ar[(y*8+z)*sizex+x*8+5] = (value,value,value,value)
							ar[x*8+5,y*8+z] = (value,value,value,value)
							# Bit 1
							value = ((char[z] & 2) >> 1) * 255
							#ar[(y*8+z)*sizex+x*8+6] = (value,value,value,value)
							ar[x*8+6,y*8+z] = (value,value,value,value)
							# Bit 0
							value = ((char[z] & 1)) * 255
							#ar[(y*8+z)*sizex+x*8+7] = (value,value,value,value)
							ar[x*8+7,y*8+z] = (value,value,value,value)
				del ar
				goodframe.set_colorkey((0,0,0))
				self.frames.append(goodframe)


	def export(self, filename):
		with open(filename, 'a') as fp:
			fp.write('; ASM source file created by SevenuP v1.21\n')
			fp.write('; SevenuP (C) Copyright 2002-2007 by Jaime Tejedor Gomez, aka Metalbrain\n\n')
			fp.write(';GRAPHIC DATA:\n')
			fp.write(';Pixel Size:      ( 24,  32)\n')
			fp.write(';Char Size:       (  3,   4)\n')
			fp.write(';Frames:             6\n')
			fp.write(';Sort Priorities: X char, Char line, Y char, Frame number\n')
			fp.write(';Data Outputted:  Gfx\n')
			fp.write(';Interleave:      Sprite\n')
			fp.write(';Mask:            No\n\n')

			fp.write("%s:\n" % self.name)
			for myframe in self.frames[:len(self.frames)/2]:
				frame = pygame.PixelArray(myframe)
				for y in range(0,self.sizey):
					fp.write("    DEFB ")
					for x in range(0,self.sizex/8):
						char = self.getbit(frame[x*8, y]) *128
						char = char | (self.getbit(frame[x*8+1, y]) * 64)
						char = char | (self.getbit(frame[x*8+2, y]) * 32)
						char = char | (self.getbit(frame[x*8+3, y]) * 16)
						char = char | (self.getbit(frame[x*8+4, y]) * 8)
						char = char | (self.getbit(frame[x*8+5, y]) * 4)
						char = char | (self.getbit(frame[x*8+6, y]) * 2)
						char = char | (self.getbit(frame[x*8+7, y]))
						fp.write("%s " % char)
						if x < (self.sizex/8)-1:
							fp.write(',')
					fp.write("\n")
			fp.write("\n\n")


	def getbit(self, bit):
		if bit != 0:
			return 1
		return 0


	def flip(self):
		"""
		Flip all frames of a sprite
		Attach frames at the end
		"""
#		newsprite=SevSprite("")
#		newsprite.nframes=self.nframes
#		newsprite.sizex=self.sizex
#		newsprite.sizey=self.sizey
		for frame in range (0, self.nframes):
			newframe=pygame.transform.flip(self.frames[frame],True,False)
			newframe.set_colorkey((0,0,0))
			self.frames.append(newframe)
#		return newsprite
