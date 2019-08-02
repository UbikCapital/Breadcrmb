# Ubik Capital Breadcrmb App SCORE
# Created by Russell Shirey on 19 July 2019
# Copyright (c) 2019 SparkTex, LLC. All rights reserved. 

from iconservice import *

TAG = 'Breadcrmb'

class Breadcrmb(IconScoreBase):

	def __init__(self, db: IconScoreDatabase) -> None:
		super().__init__(db)
		self.place = DictDB('place', db, value_type=str, depth = 3)
		self.placecount = DictDB('placecount', db, value_type=str, depth = 1)
		self.ratings = DictDB('ratings', db, value_type=str, depth = 2)
		self._whitelist = DictDB("whitelist", db, int)

	def on_install(self) -> None:
		super().on_install()

	def on_update(self) -> None:
		super().on_update()

	def _check_owner(self):
		if self.tx.origin != self.owner:
			revert("Invalid SCORE owner")

	@staticmethod
	def _check_proportion(proportion: int):
		if not (0 <= proportion <= 100):
			revert(f"Invalid proportion: {proportion}")

	@external(readonly=True)
	def getProportion(self, address: Address) -> int:
		return self._whitelist[address]

	@external
	def addToWhitelist(self, address: Address, proportion: int = 100):
		self._check_owner()
		self._check_proportion(proportion)
		self._whitelist[address] = proportion

	def place_to_dict(self, address: str, index: str) -> dict:
		return {
			'id': self.place[address][index]["id"],
 			'date': self.place[address][index]["date"],
 			'location': self.place[address][index]["location"],
			'name': self.place[address][index]["name"],
 			'place_address': self.place[address][index]["place_address"]
			}

	@external
	def new_account(self):
		address = str(self.msg.sender)
		self.placecount[address] = ""

	@external(readonly=True)
	def get_ind_place_location(self, index: str) -> str:
		address = str(self.msg.sender)
		return self.place[address][index]["location"]

	@external(readonly=True)
	def get_ind_place_date(self, index: str) -> str:
		address = str(self.msg.sender)
		return self.place[address][index]["date"]

	@external(readonly=True)
	def get_ind_place_id(self, index: str) -> str:
		address = str(self.msg.sender)
		return self.place[address][index]["id"]

	@external(readonly=True)
	def get_ind_place(self, index: str) -> str:
		address = str(self.msg.sender)
		thisPlaceDict = self.place_to_dict(address, index)
		return thisPlaceDict

	@external(readonly=True)
	def get_all_places(self) -> str:
		places = list()
		address = str(self.msg.sender)
		placeCount = int(self.placecount[address])
		
		for i in range(placeCount):		
			thisPlaceDict = self.place_to_dict(address, str(i))
			places.append(thisPlaceDict) 	
		return places

	@external(readonly=True)
	def get_place_count(self) -> int:
		address = str(self.msg.sender)
		return self.placecount[address]

	@external(readonly=True)
	def get_rating(self, placeId: str) -> str:
		address = str(self.msg.sender)
		return self.ratings[address][placeId]

	@external
	def write_rating(self, placeId: str, rating: str):
		address = str(self.msg.sender)
		proportion: int = self._whitelist[address]
		self.set_fee_sharing_proportion(proportion)
		self.ratings[address][placeId] = rating

	@external
	def write_place(self, new_location: str, placeId: str, date: str, name: str, place_address: str):
		address = str(self.msg.sender)
		proportion: int = self._whitelist[address]
		self.set_fee_sharing_proportion(proportion)
		current_place_count = self.placecount[address]
		if not (current_place_count.isdigit()):
			self.placecount[address] = "0"
			current_place_count = "0"
		self.place[address][current_place_count]["location"] = new_location
		self.place[address][current_place_count]["date"] = date
		self.place[address][current_place_count]["id"] = placeId
		self.place[address][current_place_count]["name"] = name
		self.place[address][current_place_count]["place_address"] = place_address
		new_place_count = int(current_place_count) + 1
		self.placecount[address] = str(new_place_count)
