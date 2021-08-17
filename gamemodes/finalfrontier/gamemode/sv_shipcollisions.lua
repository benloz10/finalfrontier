-- Copyright (c) 2014 James King [metapyziks@gmail.com]
--
-- This file is part of Final Frontier.
--
-- Final Frontier is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as
-- published by the Free Software Foundation, either version 3 of
-- the License, or (at your option) any later version.
--
-- Final Frontier is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with Final Frontier. If not, see <http://www.gnu.org/licenses/>.

-- jit.on()



function collisionTest()
	local obj = ents.FindByClass("info_ff_object")
	local ship1 = nil
	local ship2 = nil

	for _, ship in pairs(obj) do
		if ship:GetObjectType() == objtype.SHIP then
			if ship1 == nil then
				ship1 = ship
			end
			if ship != ship1 then
				ship2 = ship
			end
		end
	end

	local ship1Pos = Vector(ship1:GetCoordinates())
	local ship2Pos = Vector(ship2:GetCoordinates())

	local ship1Vel = Vector(ship1:GetVel())
	local ship2Vel = Vector(ship2:GetVel())


	local nx1 = ship1Pos.x + ship1Vel.x
	local ny1 = ship1Pos.y + ship1Vel.y

	local nx2 = ship2Pos.x + ship2Vel.x
	local ny2 = ship2Pos.y + ship2Vel.y

	local distancex = math.abs((nx1) - (nx2))
	local distancey = math.abs((ny1) - (ny2))


	if distancex <= 0.015 and distancey <= 0.015 then


		vel1 = ship1Vel:LengthSqr()
		vel2 = ship2Vel:LengthSqr()
		velDiff = ship1Vel - ship2Vel
		velDiff = velDiff:LengthSqr()

		for _, ship in ipairs(ents.FindByClass("info_ff_ship")) do
			for i = 1, math.random(1, #ship:GetRooms()) do
				ship:DoRoomDamage(velDiff*10000, table.Random(ship:GetRooms()), 0, 1)
			end
		end

		ship1:SetVel(ship2Vel.x*0.9,ship2Vel.y*0.9)
		ship2:SetVel(ship1Vel.x*0.9,ship1Vel.y*0.9)

	end

end

hook.Add( "Think", "ff_collide_think", collisionTest )
