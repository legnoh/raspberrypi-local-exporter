resource "grafana_library_panel" "gch" {
  count  = length(var.GCH_STREAMS)
  org_id = grafana_organization.main.org_id
  name   = "GREEN Ch.(ch${count.index + 1})"
  model_json = jsonencode({
    title       = var.GCH_STREAMS[count.index].program_name,
    type        = "innius-video-panel",
    transparent = true,
    options = {
      autoPlay  = true,
      videoType = "iframe",
      iframeURL = "http://grafstation.local/player/hls.html?url=${urlencode(var.GCH_STREAMS[count.index].stream_url)}?mute=${count.index > 0 ? 1 : 0}",
    },
  })
}