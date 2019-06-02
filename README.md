# Half-Life 2's H.E.V Mark V Auxiliary Power
### Re-enabling you the ability to drown because you left your flashlight on

This addon for Garry's Mod attempts to replicate the Auxiliary Power feature from Valve's 2004 game 'Half-Life 2'.

## Features
+   Limited sprinting
+   Limited oxygen underwater
    +   Drowning
+   Limited flashlight
+   Half-Life 2: Episode 2 standalone flashlight

## Customization includes
+   Toggle the whole system
+   Toggle each feature
+   Toggle between using vanilla flashlight or Episode 2's flashlight system
+   Change colour of HUD elements
+   Change position of HUD elements
+   Change rates of energy consumption and recovery globally
+   Change rates of energy consumption and recovery per feature

## Additional content
+   Support for **H0L-D4: Holographic Heads up Display**
+   Support for **GoldSrc HUD**

## Utilizing the API
The public API is small, and I will only list the generally useful functions, but in case you want to take advantage of it:

### Clientside

`AUXPOW:GetPower()`
> Returns the amount of power the client acknowledges the player has

> **@return** {*number*} power

`AUXPOW:GetFlashlight()`
> Returns the amount of EP2 flashlight battery the client acknowledges the player has

> **@return** {*number*} flashlight battery

#### In case you want to override the HUD elements
`"AuxPowerHUDPaint"` is the event that makes the default Aux. Power HUD be painted. Return **false** if you want to hide it (and draw something in it's place).
> **@param** {*number*} auxiliary power left
> **@param** {*table*} list of expenses

`"EP2FlashlightHUDPaint"` is the event that makes the EP2 flashlight HUD be painted. Return **false** if you want to hide it (and draw something in it's place).
> **@param** {*number*} flashlight battery left

### Serverside

`AUXPOW:GetData(player)`
> Returns a player's auxiliary power data

> **@param** {*Player*} player

> **@return** {*table*} auxiliary power data

`AUXPOW:GetExpenses(player)`
> Returns a player's auxiliary power expenses

> **@param** {*Player*} player

> **@return** {*table*} expenses

`AUXPOW:HasExpenses(player)`
> Whether a player has active auxiliary power expenses

> **@param** {*Player*} player

> **@return** {*boolean*} has expenses

`AUXPOW:GetPower(player)`
> Returns a player's current auxiliary power levels

> **@param** {*Player*} player

> **@return** {*number*} power level

`AUXPOW:HasPower(player)`
> Whether a player has auxiliary power

> **@param** {*Player*} player

> **@return** {*boolean*} has auxiliary power

`AUXPOW:SetPower(player, power)`
> Sets a new level for a player's auxiliary power

> **@param** {*Player*} player

> **@param** {*number*} power

`AUXPOW:AddPower(player, power)`
> Adds power to a player's auxiliary power supply

> **@param** {*Player*} player

> **@param** {*number*} power to add

`AUXPOW:AddExpense(player, id, label, rate, expense, downtime)`
> Adds an active expense to the auxiliary power system

> **@param** {*Player*} player

> **@param** {*string*} identifier

> **@param** {*string*} label

> **@param** {*number*} rate of energy consumption in seconds

> **@param** {*number|nil*} how much energy it consumes per tick

> **@param** {*number|nil*} how many seconds of downtime will the aux. power have after being drained

`AUXPOW:GetFlashlightPower(player)`
> Returns the amount of EP2 flashlight power a player has

> **@param** {*Player*} player

`AUXPOW:HasFlashlightPower(player)`
> Returns whether the player's EP2 flashlight has power

> **@param** {*Player*} player

> **@return** {*boolean*} has enough power

`AUXPOW:SetFlashlightPower(player, amount)`
> Sets an amount of EP2 flashlight power to a player

> **@param** {*Player*} player

> **@param** {*number*} amount

`AUXPOW:AddFlashlightPower(player, amount)`
> Adds power amount to the flashlight and sends it to the player

> Turns the flashlight off if it reaches 0

> **@param** {*Player*} player

> **@param** {*number*} amount

## That's all for now. Have fun!
