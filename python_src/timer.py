"""
Simple timer class
"""

class IannaTimer():
	def __init__ (self):
		self.timer = 0
		self.active = False

	def activate (self):
		self.active = True

	def deactivate (self):
		self.active = False

	def isactive (self):
		return self.active

	def tick(self):
		if self.active:
			self.timer = self.timer - 1
			if self.timer == 0:
				self.deactivate()
						
	def setvalue(self,value):
		self.timer = value

	def getvalue(self):
		return self.timer

	def reset(self):
		self.timer = 0

global_timer = IannaTimer()
