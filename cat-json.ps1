

cd /usr/local/cat-20180521/data/json
function get-cddacollection {
  $jsonfiles = get-childitem *.json -recurse
  $collection = $null
  foreach ($jsonfile in $jsonfiles){
    $filedata = get-content $jsonfile
    $fileobj = $filedata | convertfrom-json
    $collection += $fileobj
  }
  return $collection
}
cd /usr/local/cat-20180521/data

<#
# e.g. armor
$armorcollection = $collection | where-object { $_.type -eq "ARMOR" }
$lightarmor = $armorcollection | where-object { $_.id -like "power*light" }

# e.g. ammo
$ammocollection = $collection | where-object { $_.type -eq "AMMO" }
#>

function get-cddaguns($collection){
  $guncollection = $collection | where-object { $_.type -eq "GUN" } | select-object skill,abstract,copy-from,id,name,ammo,range,ranged_damage
  $abstractarr = "flamethrower_base","gun_base","launcher_base","pistol_base","pistol_revolver","rifle_auto","rifle_base","rifle_manual","rifle_semi","shotgun_base","shotgun_pump","smg_base"
  $guns = @()
  $abstracts = @()
  foreach ($gun in $guncollection){
    $abstract = $false
    $id = ""
    if (!$gun.id){ $id = $gun.abstract } else { $id = $gun.id }
    if ($gun.abstract){
      $abstract = $true
    }
    $protoitem = [pscustomobject]@{
      "id" = $id
      "name" = $gun.name
      "abstract" = $abstract
      "skill" = $gun.skill
      "ammo" = $gun.ammo
      "parent" = $gun.'copy-from'
      "range" = $gun.range
      "damage" = $gun.ranged_damage
      "totalrange" = ""
      "totaldamage" = ""
    }
    if ($abstract -eq $true){
      if ($gun.abstract -like "rifle*"){ $protoitem.skill = "rifle"}
      if ($gun.abstract -like "pistol*"){ $protoitem.skill = "pistol"}
      if ($gun.abstract -like "shotgun*"){ $protoitem.skill = "shotgun"}
      $protoitem.range = 0
      $protoitem.damage = 0
    }
    if ((!$protoitem.parent) -or $abstractarr.Contains($protoitem.parent)) {
      if (!$protoitem.range){ $protoitem.range = 0 }
      if (!$protoitem.damage){ $protoitem.damage = 0 }
    }
    if ($protoitem.parent -like "rifle*" -and (!$protoitem.skill)){ $protoitem.skill = "rifle" }
    if ($protoitem.parent -like "pistol*" -and (!$protoitem.skill)){ $protoitem.skill = "pistol" }
    if ($protoitem.parent -like "launcher*" -and (!$protoitem.skill)){ $protoitem.skill = "launcher" }
    if ($protoitem.parent -like "shotgun*" -and (!$protoitem.skill)){ $protoitem.skill = "shotgun" }
    if ($protoitem.id -eq "acid_spit"){ $protoitem.damage = 4 }
    $guns += $protoitem
  }
  #$guns | sort-object abstract,skill,id | format-table -auto
  # if I was a good programmer I would put this in a function.  after about 4-5 passes all the parent inheritance problems are sorted out.

  foreach ($gun in $guns){
    if ($gun.abstract -eq $true){ continue }
    if ((!$gun.range) -or (!$gun.skill) -or (!$gun.ammo) -or (!$gun.damage)){
      $parentgun = $guns | where-object { $_.id -eq $gun.parent }
      if (!$gun.range) { $gun.range = $parentgun.range }
      if (!$gun.damage){ $gun.damage = $parentgun.damage }
      if (!$gun.skill){ $gun.skill = $parentgun.skill }
      if (!$gun.ammo){ $gun.ammo = $parentgun.ammo }
    }
  }
  foreach ($gun in $guns){
    if ($gun.abstract -eq $true){ continue }
    if ((!$gun.range) -or (!$gun.skill) -or (!$gun.ammo) -or (!$gun.damage)){
      $parentgun = $guns | where-object { $_.id -eq $gun.parent }
      if (!$gun.range) { $gun.range = $parentgun.range }
      if (!$gun.damage){ $gun.damage = $parentgun.damage }
      if (!$gun.skill){ $gun.skill = $parentgun.skill }
      if (!$gun.ammo){ $gun.ammo = $parentgun.ammo }
    }
  }
  foreach ($gun in $guns){
    if ($gun.abstract -eq $true){ continue }
    if ((!$gun.range) -or (!$gun.skill) -or (!$gun.ammo) -or (!$gun.damage)){
      $parentgun = $guns | where-object { $_.id -eq $gun.parent }
      if (!$gun.range) { $gun.range = $parentgun.range }
      if (!$gun.damage){ $gun.damage = $parentgun.damage }
      if (!$gun.skill){ $gun.skill = $parentgun.skill }
      if (!$gun.ammo){ $gun.ammo = $parentgun.ammo }
    }
  }
  foreach ($gun in $guns){
    if ($gun.abstract -eq $true){ continue }
    if ((!$gun.range) -or (!$gun.skill) -or (!$gun.ammo) -or (!$gun.damage)){
      $parentgun = $guns | where-object { $_.id -eq $gun.parent }
      if (!$gun.range) { $gun.range = $parentgun.range }
      if (!$gun.damage){ $gun.damage = $parentgun.damage }
      if (!$gun.skill){ $gun.skill = $parentgun.skill }
      if (!$gun.ammo){ $gun.ammo = $parentgun.ammo }
    }
  }
  #$guns | sort-object abstract,skill,id | format-table -auto
  $gunammos = $guns.ammo | sort-object -unique
  $ammocollection = $collection | where-object { $_.type -eq "AMMO" }
  $gunammolist = @()
  foreach ($ammo in $ammocollection){
    if ($gunammos.Contains($ammo.ammo_type)){ $gunammolist += $ammo }
  }
  $ammosort = @()
  foreach ($ammo in $gunammolist){
    if (!$ammo.range){ $range = 0 } else { $range = $ammo.range }
    if (!$ammo.damage){ $damage = 0 } else { $damage = $ammo.damage }
    if (!$ammo.pierce){ $pierce = 0 } else { $pierce = $ammo.pierce }
    if (!$ammo.id){ $id = "null_element" } else { $id = $ammo.id }
    $thisammo = [pscustomobject]@{
      "name" = $id
      "range" = $range
      "damage" = $damage
      "pierce" = $pierce
      "total" = $damage + $pierce # will have to check on this formula.
      "type" = $ammo.ammo_type
    }
    $ammosort += $thisammo
  }
  $gunsammo = @()
  $ammosort = $ammosort | sort-object -property type,total
  foreach ($gun in $guns){
    if ($gun.abstract -eq $true){ continue }
    $thisammotype = $gun.ammo
    $thisammo = $ammosort | where-object { $_.type -eq $thisammotype }
    $thisgunammo = $gun
    if (!$thisgunammo.range){ $thisgunammo.range = 0 }
    if (!$thisgunammo.damage){ $thisgunammo.damage = 0 }
    $thisgunammo.totalrange = [int]$gun.range + [int]$thisammo.range
    $thisgunammo.totaldamage = [int]$gun.damage + [int]$thisammo.total
    $gunsammo += $thisgunammo
  }
  return $gunsammo
}
function get-cddaarmor ($collection){
  $armorcollection = $collection | where-object { $_.type -eq "ARMOR" }
  $toolarmor = $collection | where-object { $_.type -eq "TOOL_ARMOR" }
  $armor = $armorcollection | where-object { $_.category -eq "armor" }
  $armor += $toolarmor | where-object { $_.category -eq "armor" }
  return $armor
}


function get-cddafancy ($collection){
  $fancystuff = $collection | where-object { $_.flags -like "*FANCY*" }
  return $fancystuff
}

# diver's watch should be updated to include the rolex submariner, which is super_fancy.

function parse-mapdata($savepath){
  cd $savepath
  $files = get-childitem o.*
  $mapdata = @()
  foreach ($file in $files){
    $filecoord = $file.name -split "o."
    $coord = $filecoord[1] -split "\."
    $filedata = get-content $file
    $skipfirst = $filedata | select-object -skip 1
    $filejson = $skipfirst | convertfrom-json
    $mapregion = [pscustomobject]@{
      "name" = $filecoord[1]
      "x" = $coord[0]
      "y" = $coord[1]
      "cities" = $filejson.cities
      "roads_out" = $filejson.roads_out
      "radios" = $filejson.radios
      "monster_map" = $filejson.monster_map
      "tracked_vehicles" = $filejson.tracked_vehicles
      "scent_traces" = $filejson.scent_traces
      "npcs" = $filejson.npcs
      "monster_groups" = $filejson.monster_groups
      "layers" = $filejson.layers
    }
    $mapdata += $mapregion
  }
  return $mapdata
}


function get-cddacities($mycities){
  $citylist = @()
  foreach ($region in $maps){
    foreach ($city in $region.cities){
      $known = $false
      if ($mycities -contains $city.name) { $known = $true }
      $thiscity = [pscustomobject]@{
        "name" = $city.name
        "mapX" = $region.x
        "mapY" = $region.y
        "cityx" = $city.x
        "cityy" = $city.y
        "size" = $city.size
        "known" = $known
      }
      $citylist += $thiscity
    }
  }
  return $citylist
}

<#
  overmap is the world map
  each overmap tile is a tinymap, 24x24
  most often used is the map, which is 156x156.  teh reality bubble.
  submaps erge the tinymap and map; a submap is 12x12
  one tinymap is 2x2 submaps
  one map is 13x13 submaps

#>

function get-cddarawmap($x,$y,$argmaps){
  $region = $argmaps | where-object { $_.x -eq $x -and $_.y -eq $y }
  $ground = $region.layers[10]
  $curtile = ""
  #$acc = 0
  $regionstr = ""
  $mapkeyaddarr = @()
  foreach ($objentry in $ground){
    $tile = $objentry[0]
    $count = $objentry[1]
    switch -wildcard ($tile){
      "river*" { $curtile = "~"}
      "road*" { $curtile = "-"}
      "forest*" { $curtile = "^"}
      "field*" { $curtile = " "}
      "pond*" { $curtile = "O"}
      "mansion" { $curtile = "M"}
      "*house*" { $curtile = "H"}
      "s_*" { $curtile = "$" }
      "estate" { $curtile = "M" }
      "crater" { $curtile = "X"}
      "cave" { $curtile = "C" }
      "lmoe" { $curtile = "+" }
      "*camp*" { $curtile = "c" }
      "fema*" { $curtile = "f" }
      "spider*" { $curtile = "s"}
      "bridge*" { $curtile = "="}
      "riverside_dwelling" { $curtile = "H" }
      default {
        $curtile = "#"
        $mapkeyaddarr += $tile
      }
    }
    while ($count -gt 0){
      $regionstr += $curtile
      $count--
    }
  }
  return $regionstr
}


function write-cddamap($regionstr){
  $lineacc = 0
  $mapstr = ""
  $chararray = $regionstr.ToCharArray()
  foreach ($char in $chararray){
    $mapstr += $char
    $lineacc += 1
    if ($lineacc -eq 180){
      $lineacc = 0
      $mapstr += "`r`n"
    }
  }
  return $mapstr
}

function write-cddacolormap($regionstr){
  $prevfgc = $host.UI.RawUI.ForegroundColor
  $prevbgc = $host.UI.RawUI.BackgroundColor
  $lineacc = 0
  $mapstr = ""
  $chararray = $regionstr.ToCharArray()
  foreach ($char in $chararray){
    $host.UI.RawUI.ForegroundColor = $prevfgc
    $host.UI.RawUI.BackgroundColor = $prevbgc
    switch($char){
      "~" { $host.UI.RawUI.ForegroundColor = "Blue" }
      "^" { $host.UI.RawUI.ForegroundColor = "Green"}
      " " { $host.UI.RawUI.BackgroundColor = "Black"}
      "-" { $host.UI.RawUI.ForegroundColor = "Gray" }
      "=" { $host.UI.RawUI.ForegroundColor = "Gray"}
      Default { $host.UI.RawUI.ForegroundColor = "Yellow" }
    }
    [Console]::Write($char)
    $host.UI.RawUI.ForegroundColor = $prevfgc
    $host.UI.RawUI.BackgroundColor = $prevbgc
    $lineacc += 1
    if ($lineacc -eq 180){
      $lineacc = 0
      [Console]::Write("`n")
    }
  }
}

# get the maps for boxcars
$boxcarmaps = parse-mapdata("/usr/local/cat-20180521/save/Boxcars/")
$boxcarknowncitynames = "Beddington","Centerville","Epsom","Ashland","New Ashford","Amesbury","Middlesex","Pittsburg"
$boxcarcities = get-cddacities($boxcarknowncitynames)
$boxcarknowncities = $cities | where-object { $_.known -eq $true }

# get the maps as a one line string.
$bcrawhwsto = get-cddarawmap 1 -1 $boxcarmaps # home is where the hardware store is.
$bcrawsouth = get-cddarawmap 1 0 $boxcarmaps # south 1 map is where I explored the most so far.
$bcrawspawn = get-cddarawmap 2 -1 $boxcarmaps # 1 east of hwstore is where I spawned in the campground.


# parse the maps as a multiline string, which is 180x180.
$bchomemap = write-cddamap $bcrawhwsto
$bcsouthmap = write-cddamap $bcrawsouth
$bcspawnmap = write-cddamap $bcrawspawn

# output maps to the console for more readability
write-cddacolormap $bcrawhwsto
write-cddacolormap $bcrawsouth
write-cddacolormap $bcrawspawn

# get wasteland maps as a one line string
$wlmaps = parse-mapdata("/usr/local/cat-20180521/save/Wasteland/")
$wlknowncitynames = "Beaver Cove","North Canaan","Arlington"
$wlcities = get-cddacities($wlknowncitynames)
$wlknowncities = $wlcities | where-object { $_.known -eq $true }

$wlrawspawn = get-cddarawmap 1 -2 $wlmaps
$wlspawnmap = write-cddamap $wlrawspawn
write-cddacolormap $wlrawspawn

<# map notes
# layer 10 seems like it is the ground layer with z-levels enabled.
# setting an accumulator and adding all of the counts in a single layer results in 32400
# so it looks like an overmap region is 180x180.
#>

<#
# e.g. armor
$armor = $collection | where-object { $_.type -eq "ARMOR" }
$lightarmor = $armor | where-object { $_.id -like "power*light" }
#>
