import random 

class BaseEntity(object):
	def update(self, step_size):
		pass

	def render(self, screen):
		pass

class PseudoRandom:
	@classmethod
	def randint(cls, mn, mx, ammount):
		total = 0
		for i in range(ammount):
			total += random.randint(mn, mx)
		return int(total / ammount)

	@classmethod
	def random(cls, ammount):
		total = 0
		for i in range(ammount):
			total += random.random()
		return total / ammount

class Singleton(object):
    _instance = None
    def __new__(cls, *args, **kwargs):
        if not cls._instance:
            cls._instance = super(Singleton, cls).__new__(
                                cls, *args, **kwargs)
        return cls._instance