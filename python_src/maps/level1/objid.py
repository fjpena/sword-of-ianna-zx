#!/usr/bin/env python

import tmxlib

map=tmxlib.Map.open("mapa_nivel01c.tmx")
for obj in map.layers['Objetos']:
	print obj.properties['objid']
