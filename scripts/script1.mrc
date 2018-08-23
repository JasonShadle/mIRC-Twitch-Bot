;grab current game on a live channel
on *:text:!game*:#cakeraider: {
  /* if ((%floodGame) || ($($+(%,floodGame.,$nick),2))) { 
    return 
  }
  set -u10 %floodGame On
  set -u30 %floodGame. $+ $nick On
  */
  var %api = https://api.twitch.tv/kraken/streams/ $+ $right($chan,-1)
  var %game = $json(%api,stream,game)
  msg # %api Game: " $+ %game $+ "
  if ($2 == $null) {

    ;%game is null if the stream is offline. API changes if stream is on/off.
    if (%game == $null) {
      msg # @ $+ $nick $+ , the channel is offline. Unable to retrieve game.

    }
    else {
      msg # The current game is: %game
    }
  }
  else {
    if (%game == $null) {
      msg # 3
      msg # @ $+ $2 $+ , the channel is offline. Unable to retrieve game.

    }
    else {
      msg # @ $+ $2 $+ , the current game is %game $+ ,
    }
  }

}

on *:text:!followers*:#cakeraider: {
  if ((%floodFollowers) || ($($+(%,floodFollowers.,$nick),2))) { 
    return 
  }

  set -u10 %floodFollowers On
  set -u30 %floodFollowers. $+ $nick On
  ;/kraken/channels/ appears whether the channel is offline or online
  var %api = http://api.twitch.tv/kraken/channels/ $+ $right($chan,-1)
  var %followers = $json(%api,followers)

  if ($2 == $null) {
    msg # @ $+ $nick $+ , this channel has %followers followers.
  }
  else {
    msg # @ $+ $2 $+ , this channel has %followers followers.
  }
}

on *:text:!viewers*:#cakeraider: {
  if ((%floodViewers) || ($($+(%,floodViewers.,$nick),2))) { 
    return 
  }

  set -u10 %floodViewers On
  set -u30 %floodViewers. $+ $nick On

  var %api = http://api.twitch.tv/kraken/streams/ $+ $right($chan,-1)
  var %viewers = $json(%api,stream,viewers)

  if ($2 == $null) {
    if (%viewers == $null) {
      msg # @ $+ $nick $+ , the channel is offline. Unable to retrieve viewers.
    }
    else {
      msg # @ $+ $nick $+ , there are %viewers viewers.
    }
  }
  else {
    if (%viewers == $null) {
      msg # @ $+ $2 $+ , the channel is offline. Unable to retrieve viewers.
    }
    else {
      msg # @ $+ $2 $+ , there are %viewers viewers.
    }
  }
}

on *:text:!title*:#cakeraider: {
  if ((%floodTitle) || ($($+(%,floodTitle.,$nick),2))) { 
    return 
  }
  set -u10 %floodTitle On
  set -u30 %floodTitle. $+ $nick On

  var %api = http://api.twitch.tv/kraken/streams/ $+ $right($chan,-1)
  var %title = $json(%api,stream,channel,status)

  if ($2 == $null) {
    if (%title == $null) {
      msg # @ $+ $nick $+ , the channel is offline. Unable to retrieve title.
    }
    else {
      msg # @ $+ $nick $+ , the title is " $+ %title $+ ".
    }
  }
  else {
    if (%title == $null) {
      msg # @ $+ $nick $+ , the channel is offline. Unable to retrieve title.
    }
    else {
      msg # @ $+ $2 $+ , the title is " $+ %title $+ ".
    }
  }
}

/*
Custom Commands              
*/

on *:text:!addcom !*:#cakeraider: {  
  if ($nick isop #) {
    if ($readini(settings $+ $chan $+ .ini,n,commands, $2) == $null) {
      writeini settings $+ $chan $+ .ini commands $2 $3-
      msg # @ $+ $nick $+ , the command $2 has been added.
    }
    else {
      msg # @ $+ $nick $+ , the command $2 already exists.W
    }
  }
}

on *:text:!delcom !*:#cakeraider: {
  if ($nick isop #) {
    if ($readini(settings $+ $chan $+ .ini,n,commands, $2) == $null) {
      msg # @ $+ $nick $+ , $2 was not previously a command.
    }
    else {
      remini settings $+ $chan $+ .ini commands $2
      msg # @ $+ $nick $+ , $2 has been removed.
    }
  }
} 

on *:text:!editcom !*:#cakeraider: {
  if ($nick isop #) {
    if ($readini(settings $+ $chan $+ .ini,n,commands, $2) == $null) {
      msg # @ $+ $nick $+ , $2 is not a command.
    }
    else {
      writeini settings $+ $chan $+ .ini commands $2 $3-
      msg # @ $+ $nick $+ , $2 has been changed.
    }
  }
}

/*
Chat Filter
*/

on *:text:!blacklist:#cakeraider: {

}
on *:text:!blacklist on:#cakeraider: {
  if ($nick isop #) {
    if ($readini(settings $+ $chan $+ .ini,n,blacklist, mode) == on) {
      msg # @ $+ $nick $+ , blacklist is already on.
    }
    else {
      writeini settings $+ $chan $+ .ini blacklist mode on
      msg # @ $+ $nick $+ , blacklist is now turned on.
    }
  }
}

on *:text:!blacklist off:#cakeraider: {
  if ($nick isop #) {
    if ($readini(settings $+ $chan $+ .ini,n,blacklist, mode) == off) {
      msg # @ $+ $nick $+ , blacklist is already off.
    }
    else {
      writeini settings $+ $chan $+ .ini blacklist mode off
      msg # @ $+ $nick $+ , blacklist is now turned off.
    }
  }
}

on *:text:!blacklist add *:#cakeraider: {
  if ($nick isop #) {
    var %blacklistLine = 1
    while (%blacklistLine <= $lines(blacklistWords $+ $chan $+ .txt)) {
      if ($3- == $read(blacklistWords $+ $chan $+ $+ .txt,n, %blacklistLine)) {
        msg # @ $+ $nick $+ , that word/phrase is already added
        break
      }
      inc %blacklistLine 1
    }
    if (%blacklistLine > $lines(blacklistWords $+ $chan $+ .txt)) {
      write blacklistWords $+ $chan $+ $+ .txt $3-
      msg # @ $+ $nick $+ , " $+ $3- $+ " has been added to the blacklist.
    }
  }
}

on *:text:!blacklist del *:#cakeraider: {
  if ($nick isop #) {
    var %temp = 1
    while (%temp <= $lines(blacklistWords $+ $chan $+ .txt)) {
      if ($3- == $read(blacklistWords $+ $chan $+ .txt,n, %temp)) {
        write -dl $+ %temp blacklistWords $+ $chan $+ .txt
        msg # @ $+ $nick $+ , " $+ $3- $+ " has been removed from the blacklist.
        dec %temp 1
        break
      }
      inc %temp 1
    }
    if (%temp > $lines(blacklistWords $+ $chan $+ .txt)) {
      msg # @ $+ $nick $+ , that word/phrase wasn't in the blacklist.
    }
  }
}


/* 
Things that involve two or more commands
*/

on *:text:!*:#cakeraider: {
  if ($readini(settings $+ $chan $+ .ini,n,commands,$1) != $null) {
    if ($2 == $null) {
      msg # @ $+ $nick $+ , $readini(settings $+ $chan $+ .ini,n,commands,$1)
    }
    else {
      msg # @ $+ $2 $+ , $readini(settings $+ $chan $+ .ini,n,commands,$1)
    }
  }
}

on *:text:*:#cakeraider: {
  if ($readini(settings $+ $chan $+ .ini,n,blacklist,mode) == on) {
    %temp = 1
    while (%temp <= $lines(blacklistWords $+ $chan $+ .txt)) {
      if ($nick isop #) { }
      else {    
        if ($1- == $read(blacklistWords $+ $chan $+ .txt,n,%temp)) {
          if ($readini(settings $+ $chan $+ .ini,n,BlacklistChatters, $nick) == $null) {
            writeini settings $+ $chan $+ .ini BlacklistChatters $nick 1
            msg # /timeout $nick 1
            msg # [Purge] $nick has been purged for saying a blacklisted word.
            %temp = $lines(blacklistWords $+ $chan $+ .txt) + 1 
          }
          elseif ($readini(settings $+ $chan $+ .ini,n,BlacklistChatters, $nick) == 1) {
            writeini settings $+ $chan $+ .ini BlacklistChatters $nick 2
            msg # /timeout $nick 300
            msg # [Timeout] $nick has been timed out for saying a blacklist word.
            %temp = $lines(blacklistWords $+ $chan $+ .txt) + 1
          }
          elseif ($readini(settings $+ $chan $+ .ini,n,BlackListChatters, $nick) > 1) {
            var %tempValue = $readini(settings $+ $chan $+ .ini,n,BlacklistChatters, $nick)
            msg # /timeout $nick 600
            msg # [Timeout] $nick has been timed out for saying a blacklist word.
            %temp = $lines(blacklistWords $+ $chan $+ .txt) + 1
          }
        }
        inc %temp 1
      }
    }
  }
}
}
