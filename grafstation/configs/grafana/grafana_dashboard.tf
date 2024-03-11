resource "grafana_dashboard" "life-metrics" {
  org_id = grafana_organization.main.org_id
  config_json = jsonencode({
    title       = "Life Metrics",
    description = "E:${var.IS_EARTHQUAKE} RE:${var.IS_REFRESHTIME} RA:${var.IS_RACETIME} DAY:${var.IS_DAYMODE} S:${var.IS_STREAM_ONAIR} C1M:${var.IS_TV_CHANNEL1_MUTED}, C2M:${var.IS_TV_CHANNEL2_MUTED}, YM:${var.IS_YOUTUBE_MUTED}",
    timezone    = "browser",
    version     = 0,
    refresh     = "30m"
    panels = [

      # channel1
      {
        libraryPanel = zipmap(local.libpanel_keys, [grafana_library_panel.channel1.uid])
        gridPos = { h = 11, w = 9, x = 0, y = 0 }
      },

      # channel2
      {
        libraryPanel = zipmap(local.libpanel_keys, [grafana_library_panel.channel2.uid])
        gridPos = { h = 11, w = 9, x = 0, y = 11 }
      },

      # aphorism
      {
        libraryPanel = zipmap(local.libpanel_keys, [grafana_library_panel.aphorism.uid])
        gridPos      = { h = 6, w = 9, x = 0, y = 22 }
      },

      # news
      {
        libraryPanel = zipmap(local.libpanel_keys, [grafana_library_panel.news-domestic.uid])
        gridPos      = local.grid_position.E1
      },
      {
        libraryPanel = zipmap(local.libpanel_keys, [grafana_library_panel.news-world.uid])
        gridPos      = local.grid_position.E2
      },
      {
        libraryPanel = zipmap(local.libpanel_keys, [grafana_library_panel.news-business.uid])
        gridPos      = local.grid_position.E3
      },
      {
        libraryPanel = zipmap(local.libpanel_keys, [grafana_library_panel.news-sports.uid])
        gridPos      = local.grid_position.E4
      },

      # clock
      {
        libraryPanel = zipmap(local.libpanel_keys, [grafana_library_panel.clock.uid])
        gridPos      = local.grid_position.A5
      },

      ### asken
      {
        libraryPanel = zipmap(local.libpanel_keys, [grafana_library_panel.asken-score.uid])
        gridPos      = local.grid_position.C1
      },

      # moneyforward
      {
        libraryPanel = zipmap(local.libpanel_keys, [grafana_library_panel.moneyforward-balance.uid])
        gridPos      = local.grid_position.D1
      },
      {
        libraryPanel = zipmap(local.libpanel_keys, [grafana_library_panel.moneyforward-balancesheet.uid])
        gridPos      = local.grid_position.D2
      },
      {
        libraryPanel = zipmap(local.libpanel_keys, [grafana_library_panel.moneyforward-deposit-withdrawal.uid])
        gridPos      = local.grid_position.D3
      },
      
      # nature remo
      {
        libraryPanel = zipmap(local.libpanel_keys, [grafana_library_panel.remo-temperature.uid])
        gridPos      = local.grid_position.B4
      },
      {
        libraryPanel = zipmap(local.libpanel_keys, [grafana_library_panel.remo-humidity.uid])
        gridPos      = local.grid_position.C4
      },
      {
        libraryPanel = zipmap(local.libpanel_keys, [grafana_library_panel.remo-power-consumption.uid])
        gridPos      = local.grid_position.D4
      },

      # openweather
      {
        libraryPanel = zipmap(local.libpanel_keys, [grafana_library_panel.openweather-condition.uid])
        gridPos      = local.grid_position.A4
      },
      {
        libraryPanel = zipmap(local.libpanel_keys, [grafana_library_panel.openweather-temperature.uid])
        gridPos      = local.grid_position.B5
      },
      {
        libraryPanel = zipmap(local.libpanel_keys, [grafana_library_panel.openweather-humidity.uid])
        gridPos      = local.grid_position.C5
      },

      # oura
      {
        libraryPanel = zipmap(local.libpanel_keys, [grafana_library_panel.oura-readiness-score.uid])
        gridPos      = local.grid_position.A1
      },
      {
        libraryPanel = zipmap(local.libpanel_keys, [grafana_library_panel.oura-sleep-score.uid])
        gridPos      = local.grid_position.A3
      },
      {
        libraryPanel = zipmap(local.libpanel_keys, [grafana_library_panel.oura-activity-score.uid])
        gridPos      = local.grid_position.A2
      },

      # snmp
      {
        libraryPanel = zipmap(local.libpanel_keys, [grafana_library_panel.snmp-speedtest-occupancy.uid])
        gridPos      = local.grid_position.D5
      },

      # todoist
      {
        libraryPanel = zipmap(local.libpanel_keys, [grafana_library_panel.todoist-office.uid])
        gridPos      = local.grid_position.C3
      },
      {
        libraryPanel = zipmap(local.libpanel_keys, [grafana_library_panel.todoist-private.uid])
        gridPos      = local.grid_position.C2
      },

      # withings
      {
        libraryPanel = zipmap(local.libpanel_keys, [grafana_library_panel.withings-bmi.uid])
        gridPos      = local.grid_position.B1
      },
      {
        libraryPanel = zipmap(local.libpanel_keys, [grafana_library_panel.withings-bpm-max.uid])
        gridPos      = local.grid_position.B2
      },
      {
        libraryPanel = zipmap(local.libpanel_keys, [grafana_library_panel.withings-body-temperature.uid])
        gridPos      = local.grid_position.B3
      },
    ]
  })
}

resource "grafana_dashboard" "node-exporter" {
  config_json = data.curl.node-exporter-full.response
}
