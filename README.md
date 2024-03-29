# Half-Life 2's H.E.V Mark V Auxiliary Power

![](https://img.shields.io/github/v/release/DyaMetR/auxpower)
![](https://img.shields.io/steam/views/1758584347)
![](https://img.shields.io/steam/downloads/1758584347)
![](https://img.shields.io/steam/favorites/1758584347)
![](https://img.shields.io/github/issues/DyaMetR/auxpower)
![](https://img.shields.io/github/license/DyaMetR/auxpower)

### Re-enabling you the ability to drown because you left your flashlight on

This addon for Garry's Mod attempts to replicate the Auxiliary Power feature from Valve's 2004 game 'Half-Life 2'.

## Installation

### Steam Workshop

+   Go to the addon's [Steam Workshop page](https://steamcommunity.com/sharedfiles/filedetails/?id=1758584347) and **subscribe** to it.

### Legacy install

#### Cloning the repository

+   Go to your Garry's Mod `addons` folder.
+   Open a _terminal_.
+   `git clone git@github.com:DyaMetR/auxpower.git`

#### Download latest release

+   **Download** the [latest release](https://github.com/DyaMetR/auxpower/releases).
+   Go to your Garry's Mod `addons` folder.
+   Unzip the _downloaded `.zip` file_ there.

## Features

+   Limited sprinting
+   Limited oxygen underwater
    +   Drowning
+   Limited flashlight
+   Half-Life 2: Episode 2 standalone flashlight

## Utilizing the API
The public API is small, and I will only list the generally useful functions, but in case you want to take advantage of it:

### Clientside

`AUXPOW:GetPower()`
> Returns the amount of power the client acknowledges the player has
>
> **@return** {*number*} power

`AUXPOW:GetFlashlight()`
> Returns the amount of EP2 flashlight battery the client acknowledges the player has
>
> **@return** {*number*} flashlight battery

#### In case you want to override the HUD elements
`"AuxPowerHUDPaint"` is the event that makes the default Aux. Power HUD be painted. Return **false** if you want to hide it (and draw something in it's place).
> **@param** {*number*} auxiliary power left
>
> **@param** {*table*} list of expenses

`"EP2FlashlightHUDPaint"` is the event that makes the EP2 flashlight HUD be painted. Return **false** if you want to hide it (and draw something in it's place).
> **@param** {*number*} flashlight battery left

### Serverside

`AUXPOW:GetData(player)`
> Returns a player's auxiliary power data
>
> **@param** {*Player*} player
>
> **@return** {*table*} auxiliary power data

`AUXPOW:GetExpenses(player)`
> Returns a player's auxiliary power expenses
>
> **@param** {*Player*} player
>
> **@return** {*table*} expenses

`AUXPOW:HasExpenses(player)`
> Whether a player has active auxiliary power expenses
>
> **@param** {*Player*} player
>
> **@return** {*boolean*} has expenses

`AUXPOW:GetPower(player)`
> Returns a player's current auxiliary power levels
>
> **@param** {*Player*} player
>
> **@return** {*number*} power level

`AUXPOW:HasPower(player)`
> Whether a player has auxiliary power
>
> **@param** {*Player*} player
>
> **@return** {*boolean*} has auxiliary power

`AUXPOW:SetPower(player, power)`
> Sets a new level for a player's auxiliary power
>
> **@param** {*Player*} player
>
> **@param** {*number*} power

`AUXPOW:AddPower(player, power)`
> Adds power to a player's auxiliary power supply
>
> **@param** {*Player*} player
>
> **@param** {*number*} power to add

`AUXPOW:AddExpense(player, id, label, rate, expense, downtime)`
> Adds an active expense to the auxiliary power system
>
> **@param** {*Player*} player
>
> **@param** {*string*} identifier
>
> **@param** {*string*} label
>
> **@param** {*number*} rate of energy consumption in seconds
>
> **@param** {*number|nil*} how much energy it consumes per tick
>
> **@param** {*number|nil*} how many seconds of downtime will the aux. power have after being drained

`AUXPOW:GetFlashlightPower(player)`
> Returns the amount of EP2 flashlight power a player has
>
> **@param** {*Player*} player

`AUXPOW:HasFlashlightPower(player)`
> Returns whether the player's EP2 flashlight has power
>
> **@param** {*Player*} player
>
> **@return** {*boolean*} has enough power

`AUXPOW:SetFlashlightPower(player, amount)`
> Sets an amount of EP2 flashlight power to a player
>
> **@param** {*Player*} player
>
> **@param** {*number*} amount

`AUXPOW:AddFlashlightPower(player, amount)`
> Adds power amount to the flashlight and sends it to the player
>
> Turns the flashlight off if it reaches 0
>
> **@param** {*Player*} player
>
> **@param** {*number*} amount
