let $season_info := doc("season_info.xml")/season_info
let $season := $season_info/season
let $competitors := $season_info/stages/stage/groups/group/competitors/competitor
let $standings := doc("season_standings.xml")/season_standings/season_standing[@type="total"]/groups/group/standings/standing

return
  <handball_data>
    {
      if (exists($season)) then
        (
          <season>
            <name>{$season/@name}</name>
            <year>{$season/@year}</year>
            <category>{$season_info/category/@name}</category>
            <gender>{$season_info/competition/@gender}</gender>
          </season>,
          <competitors>
            {
              for $competitor in $competitors
              return
                <competitor name="{$competitor/@name}" country="{$competitor/@country}">
                  <standings>
                    {
                      let $comp_standings := $standings[competitor/@id = $competitor/@id]
                      for $standing in $comp_standings
                      let $group := $standing/ancestor::group
                      return
                        <standing group_name_code="{$group/@group_name}"
                                  group_name="{$group/@name}"
                                  rank="{$standing/@rank}"
                                  played="{$standing/@played}"
                                  win="{$standing/@win}"
                                  loss="{$standing/@loss}"
                                  draw="{$standing/@draw}"
                                  goals_for="{$standing/@goals_for}"
                                  goals_against="{$standing/@goals_against}"
                                  goals_diff="{$standing/@goals_diff}"
                                  points="{$standing/@points}"/>
                    }
                  </standings>
                </competitor>
            }
          </competitors>
        )
      else
        <error>No season data found</error>
    }
  </handball_data>