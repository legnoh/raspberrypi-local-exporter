resource "grafana_library_panel" "youtube" {
  name = "youtube"
  model_json = jsonencode({
    type        = "innius-video-panel",
    transparent = true,
    options = {
      autoPlay  = true,
      videoType = "iframe",
      iframeURL = "http://grafstation.local/player/youtube.html?list=${var.YOUTUBE_PLAYLIST_ID}",
    },
  })
}

resource "grafana_library_panel" "youtube-muted" {
  name = "youtube-muted"
  model_json = jsonencode({
    type        = "innius-video-panel",
    transparent = true,
    options = {
      autoPlay  = true,
      videoType = "iframe",
      iframeURL = "http://grafstation.local/player/youtube.html?list=${var.YOUTUBE_PLAYLIST_ID}&muted=true",
    },
  })
}

# resource "grafana_library_panel" "youtube-daymode-muted" {
#   name = "youtube-daymode-muted"
#   model_json = jsonencode({
#     type        = "innius-video-panel",
#     transparent = true,
#     options = {
#       autoPlay  = true,
#       videoType = "iframe",
#       iframeURL = "http://grafstation.local/player/youtube.html?v=Q-sZipetAEc&muted=true",
#     },
#   })
# }

resource "grafana_library_panel" "youtube-nightmode-muted" {
  name = "youtube-nightmode-muted"
  model_json = jsonencode({
    type        = "innius-video-panel",
    transparent = true,
    options = {
      autoPlay  = true,
      videoType = "iframe",
      iframeURL = "http://grafstation.local/player/youtube.html?v=Q-sZipetAEc&muted=true",
    },
  })
}
