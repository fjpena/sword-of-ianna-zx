#!/usr/bin/env python

import sys              # para tener argv
import tmxlib


"""
IannaTileset class
 
This is a simple tileset class, derived from the Tiled map
 
package: ianna
"""
class IannaTileset():
	""" Tileset for game """
	tilelist=[]			# Tiles
	tilelist_unique=[]		# List of unique tiles, to be exported later
	stilelist=[]			# List of supertiles

	def __init__ (self, tile_file, height, width):
		f=file(tile_file,"r")
		newZXtile=[]
		while True:
		        line = f.readline()
        		if len(line)==0:        # EOF
		                break
		        if line[0] != 'd':
				continue	# ignore lines not starting by defb
		        line = line.rstrip("\n\r")
		        line = line.lstrip("defb ")
		        spline = line.split(',')
		        #print int(spline[0],16)
        		line2 = f.readline()
		        if len(line2)==0:        # EOF
		                break
		        if line2[0] != 'd':
				continue	# ignore lines not starting by defb
		        line2 = line2.rstrip("\n\r")
		        line2 = line2.lstrip("defb ")
		        spline2 = line2.split(',')
			#newZXtile = [int(spline[0],16),int(spline[1],16),int(spline[2],16),int(spline[3],16),int(spline[4],16),int(spline[5],16),int(spline[6],16),int(spline[7],16),int(spline2[0],16)]
			newZXtile = [int(spline[0],16),int(spline[1],16),int(spline[2],16),int(spline[3],16),int(spline[4],16),int(spline[5],16),int(spline[6],16),int(spline[7],16)]
			self.tilelist.append(newZXtile)
		f.close()				

		# Now, identify unique tiles
		self.tilelist_unique.append(self.tilelist[0])
		for i in range(0,height*width):
			if self.tilelist[i] not in self.tilelist_unique:
				self.tilelist_unique.append(self.tilelist[i])	

		print "There are "+str(len(self.tilelist_unique))+" unique tiles"

		# Finally, find supertiles
		for y in range(0,height/2):
			for x in range(0,width/2):	
				supertile=[]		
				# first tile
				for i in range(0,len(self.tilelist_unique)):	# find the first supertile tile
					if self.tilelist_unique[i] == self.tilelist[y*64+x*2]: # FIXME assuming width = 32
						supertile.append(i)
				# second tile
				for i in range(0,len(self.tilelist_unique)):	# find the second supertile tile
					if self.tilelist_unique[i] == self.tilelist[y*64+x*2+1]:
						supertile.append(i)
				# third tile
				for i in range(0,len(self.tilelist_unique)):	# find the third supertile tile
					if self.tilelist_unique[i] == self.tilelist[y*64+x*2+32]:
						supertile.append(i)
				# fourth tile
				for i in range(0,len(self.tilelist_unique)):	# find the fourth supertile tile
					if self.tilelist_unique[i] == self.tilelist[y*64+x*2+33]:
						supertile.append(i)
				self.stilelist.append(supertile)

		print "There are "+str(len(self.stilelist))+" stiles"

# Main function

if len(sys.argv) < 3:
        print "Uso: count_tiles.py <nombredefichero.tmx> <nombreficherotiles.asm>"
        sys.exit()

map=tmxlib.Map.open(sys.argv[1])

# print "El tamano del mapa es " + str(map.size)

tileset=IannaTileset(sys.argv[2],map.tilesets[0].image.height / 8,map.tilesets[0].image.width / 8 )
